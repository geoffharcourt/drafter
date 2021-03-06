class Drafter::Picker
  attr_reader :cached_assignments, :disposition, :picks

  def initialize(disposition: 1.0)
    @picks = []
    @cached_assignments = []
    @disposition = disposition
  end

  def cache_assignments(assignments)
    @cached_assignments = assignments
  end

  def filled_slots
    cached_assignments.map do |assignment|
      assignment[:slot]
    end
  end

  def pick(choice)
    picks << choice
  end

  def players_at(slot)
    picks.count do |pick|
      pick[:slots].include?(slot)
    end
  end

  def to_a
    picks
  end
end
