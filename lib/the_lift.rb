require "pry-byebug"

def the_lift(queues, capacity)
  lift = TheLift::Lift.new(queues: queues, max_capacity: capacity)
  lift.check_each_floor
  lift.floor_history
end

module TheLift
 class Lift
   attr_reader :max_capacity, :queues, :current_floor, :floor_history, :up
   attr_accessor :people_in_lift

   def initialize(queues:, max_capacity:)
     @queues = queues
     @max_capacity = max_capacity
     @people_in_lift = []
     @current_floor = 0
     @floor_history = [0]
     @up = true
   end

   def check_each_floor
      until queues.flatten.empty?
        go_up
        go_down
      end
      move(floor: 0)
    end

    def go_up
      @up = true
      highest_floor = @queues.size - 1
      current_floor.upto(highest_floor).each do |floor|
        shuffle_people(floor)
      end
      @current_floor = highest_floor
    end

    def go_down
      @up = false
      @current_floor.downto(0).each do |floor|
        shuffle_people(floor)
      end
    end

    def shuffle_people(floor)
      if @people_in_lift.any?(floor) || @queues[floor].any?(&people_moving_in_direction_of_travel)
        move(floor: floor)
        let_people_out
        let_people_in if space_available?
      end
    end

    def people_moving_in_direction_of_travel
      if up
        -> (person) { person > current_floor }
      else
        -> (person) { person < current_floor }
      end
    end

    def move(floor:)
      @current_floor = floor
      floor_history << current_floor if floor_history.last != current_floor
    end

    def let_people_in
      queue_index_to_delete = []

      queues[current_floor].select(&people_moving_in_direction_of_travel).each_with_index do |person, index|
        if space_available?
          queue_index_to_delete << index
          people_in_lift << person
        end
      end
      
      reject_from_queue(queue_index_to_delete)
    end

    def space_available?
      people_in_lift.size < max_capacity 
    end

    def reject_from_queue(queue_index_to_delete)
      queue_index_to_delete.reverse.each do |e|
        queues[current_floor].delete_at(e)
      end
    end

    def let_people_out
      people_in_lift.reject! { |person| person == current_floor }
    end
  end
end