class Drafter::Picker
  attr_reader :filled_slots, :picks

  def initialize
    @picks = []
    @filled_slots = []
  end

  def pick(choice)
    picks << choice
  end

  def mark_slots_filled(slots)
    @filled_slots = slots
  end

  def to_a
    picks
  end
end
