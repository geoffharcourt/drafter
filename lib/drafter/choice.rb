class Drafter::Choice
  def initialize(candidates:, picker:, slot_counts:)
    @candidates = candidates
    @picker = picker
    @slot_counts = slot_counts
  end

  def top_candidate
    candidate = candidates.detect do |candidate|
      candidate[:slots].any? do |slot|
        potential_slots.include?(slot)
      end
    end

    picker.cache_assignments(slot_generator.assignments_to_cache)

    candidate
  end

  private

  attr_reader :candidates, :picker, :slot_counts

  def filled_slots
    slot_counts.keys - potential_slots
  end

  def potential_slots
    @_potential_slots ||= slot_generator.slots
  end

  def slot_generator
    @_slot_generator ||= Drafter::PotentialSlotsForPicker.new(
      picker: picker,
      slot_counts: slot_counts
    )
  end
end
