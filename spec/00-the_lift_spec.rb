RSpec.describe TheLift::Lift do
  let(:queues_1) { [[], [], [5, 5, 5], [], [], [], []] }
  let(:queues_2) { [[], [], [1, 1], [], [], [], []] }
  let(:queues_3) { [[], [3], [4], [], [5], [], []] }
  describe "lift infos" do
    subject { TheLift::Lift.new(queues: queues_1, max_capacity: 5) }

    it "initialise a lift" do
      expect(subject.max_capacity).to eq(5)
      expect(subject.queues).to eq(queues_1)
      expect(subject.floor_history).to eq([0])
      expect(subject.current_floor).to eq(0)
    end

    it "can move the lift" do
      subject.move(floor: 2)
      expect(subject.current_floor).to eq(2)
      expect(subject.floor_history).to eq([0, 2])
    end

    it "should let people in if max_capacity is NOT reached" do
      subject.move(floor: 2)
      subject.let_people_in
      expect(subject.people_in_lift).to eq([5, 5, 5])
      expect(subject.queues).to eq([[], [], [], [], [], [], []])
    end

    it "should NOT let people in if max_capacity is reached" do
      subject.move(floor: 2)
      subject.people_in_lift = [1, 2, 3, 4, 5]
      subject.let_people_in
      expect(subject.people_in_lift).to eq([1, 2, 3, 4, 5])
    end

    it "should let people out" do
      subject.move(floor: 2)
      subject.let_people_in
      subject.move(floor: 5)
      subject.let_people_out
      expect(subject.people_in_lift).to eq([])
    end

    it "should work for test1" do
      expect(subject.check_each_floor).to eq([0, 2, 5, 0])
    end
  end

  describe "test2" do
    subject { TheLift::Lift.new(queues: queues_2, max_capacity: 5) }

    it "should work for test2" do
      subject.check_each_floor
      expect(subject.floor_history).to eq([0, 2, 1, 0])
    end
  end

  describe "test3" do
    subject { TheLift::Lift.new(queues: queues_3, max_capacity: 5) }

    it "should work for test3" do
      subject.check_each_floor
      expect(subject.floor_history).to eq([0, 1, 2, 3, 4, 5, 0])
    end
  end
end
