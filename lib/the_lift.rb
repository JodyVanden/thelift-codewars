require "pry-byebug"

def the_lift(queues, capacity)
  lift = TheLift::Lift.new(queues: queues, max_capacity: capacity)
  lift.floor_history
end

module TheLift
 class Lift
   attr_reader :max_capacity, :queues, :current_floor, :floor_history
   attr_accessor :people_in_lift

   def initialize(queues:, max_capacity:)
     @queues = queues
     @max_capacity = max_capacity
     @people_in_lift = []
     @current_floor = 0
     @floor_history = [0]
     @up = true
    #  check_each_floor
   end

   def check_each_floor
     until @queues.flatten.empty?
       #goes up until reachs the top floor
       until @current_floor == (@queues.size - 1)
         let_people_out if @people_in_lift.any?(@current_floor)
         if @queues[current_floor].any?{|person| person > @current_floor}
           move(floor: current_floor)
           let_people_in(up: @up) if people_in_lift.size < @max_capacity
         end
         @current_floor += 1
       end
       @up = false
       
       #goes down until bottom floor
       until @current_floor == 0
         let_people_out if  @people_in_lift.any?(@current_floor)
         if @queues[current_floor].any?{|person| person < @current_floor}
           move(floor: current_floor)
           let_people_in(up: @up) if people_in_lift.size < @max_capacity 
         end
         @current_floor -= 1
       end
       @up = true
     end
     @floor_history << 0 if @floor_history.last != 0
   end

   def move(floor:)
     @current_floor = floor
     @floor_history << current_floor if @floor_history.last != @current_floor
   end

   def let_people_in
     queue_index_to_delete = []
     queues[current_floor].each_with_index do |person, index|
       #going up
       if @up && person > @current_floor
         if people_in_lift.size < max_capacity
           queue_index_to_delete << index
           @people_in_lift << person
       end
       end
       #going down
       if !@up && person < @current_floor
         if people_in_lift.size < max_capacity
           queue_index_to_delete << index
           @people_in_lift << person
         end
       end
     end
     @people_in_lift.sort
     reject_from_queue(queue_index_to_delete)
   end

   def reject_from_queue(queue_index_to_delete)
     queue_index_to_delete.reverse.each do |e|
       @queues[current_floor].delete_at(e)
     end
   end

   def let_people_out
     @people_in_lift.reject! { |person| person == current_floor }
     @floor_history << @current_floor if @floor_history.last != @current_floor
   end
 end
end