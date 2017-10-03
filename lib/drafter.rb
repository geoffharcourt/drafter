require "drafter/version"
require "drafter/picker"
require "drafter/potential_slots_for_picker"

class Drafter
  def initialize(candidates:, pickers:, slot_counts:)
    @candidates = candidates
    @slot_counts = slot_counts
    @used_candidates = []

    @results = Array.new(pickers) { Picker.new }
  end

  def draft
    while candidates_remain? && round_can_be_filled?
      results.each do |picker|
        top_pick = best_remaining_candidate(picker)
        picker.pick(top_pick)
        used_candidates << top_pick
      end

      if candidates_remain? && round_can_be_filled?
        results.reverse.each do |picker|
          top_pick = best_remaining_candidate(picker)
          picker.pick(top_pick)
          used_candidates << top_pick
        end
      end
    end

    results
  end

  private

  attr_reader :candidates, :results, :slot_counts, :used_candidates

  def best_remaining_candidate(picker)
    possible_slots = slots_for_picker(picker)

    candidates_who_fit = remaining_candidates.select do |candidate|
      (candidate[:slots] & possible_slots).any?
    end

    if candidates_who_fit.any?
      candidates_who_fit.sort_by do |candidate|
        candidate[:value]
      end.reverse.first
    end
  end

  def candidates_remain?
    remaining_candidates.any?
  end

  def remaining_candidates
    (candidates - used_candidates)
  end

  def round_can_be_filled?
    remaining_candidates.count >= results.count
  end

  def slots_for_picker(picker)
    PotentialSlotsForPicker.new(picker: picker, slot_counts: slot_counts).slots
  end
end
