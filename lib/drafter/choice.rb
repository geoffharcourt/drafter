class Drafter::Choice
  def initialize(candidates:, picker:, slot_counts:)
    @candidates = candidates
    @picker = picker
    @slot_counts = slot_counts
  end

  def top_candidate
    if best_available_player_can_be_assigned?
      puts "BPA: "
      best_available_player
    else
      puts "Potential slots: #{potential_slots}:"
      candidate = weighted_candidates.detect do |candidate|
        candidate[:slots].any? do |slot|
          potential_slots.include?(slot)
        end
      end

      picker.cache_assignments(slot_generator.assignments_to_cache)

      candidate
    end
  end

  private

  attr_reader :candidates, :picker, :slot_counts

  def best_available_player_can_be_assigned?
    return nil unless best_available_player

    best_available_player[:slots].any? do |slot|
      picker.players_at(slot) < slot_counts.fetch(slot, 0)
    end
  end

  def best_available_player
    @_best_available_player ||= weighted_candidates.first
  end

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

  def weighted_candidates
    @_weighted_candidates ||= candidates.sort_by do |candidate|
      if candidate[:slots].include?(:u)
        candidate[:value] * picker.disposition
      else
        candidate[:value]
      end
    end.reverse
  end
end
