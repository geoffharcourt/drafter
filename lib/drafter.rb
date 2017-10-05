require "drafter/version"
require "drafter/picker"
require "drafter/potential_slots_for_picker"

class Drafter
  def initialize(candidates:, pickers:, slot_counts:)
    @candidates = candidates.sort_by { |candidate| candidate[:value] }.reverse
    @slot_counts = slot_counts

    @results = Array.new(pickers) { Drafter::Picker.new }
  end

  def draft
    make_choices
    results
  end

  private

  attr_reader :candidates, :results, :slot_counts

  def make_choices
    loop do
      results.each { |picker| make_pick_for_picker(picker) }
      results.reverse_each { |picker| make_pick_for_picker(picker) }
    end
  rescue NoFurtherCandidates
    # noop
  end

  def make_pick_for_picker(picker)
    top_pick = best_remaining_candidate(picker)

    unless top_pick
      fail NoFurtherCandidates
    end

    puts top_pick[:name]
    picker.pick(top_pick)
    @candidates -= [top_pick]
  end

  def top_candidate_can_be_assigned?(picker)
    top_candidate &&
      top_candidate[:slots].any? do |slot|
        picker.players_at(slot) < slot_counts[slot]
      end
  end

  def top_candidate
    candidates.first
  end

  def best_remaining_candidate(picker)
    if top_candidate_can_be_assigned?(picker)
      top_candidate
    else
      best_candidate_for_roster(picker)
    end
  end

  def best_candidate_for_roster(picker)
    possible_slots = slots_for_picker(picker)
    filled_slots = slot_counts.keys - possible_slots
    picker.mark_slots_filled(filled_slots)

    if possible_slots.any?
      candidates.detect do |candidate|
        (candidate[:slots] & possible_slots).any?
      end
    end
  end

  def slots_for_picker(picker)
    PotentialSlotsForPicker.new(picker: picker, slot_counts: slot_counts).slots
  end

  class NoFurtherCandidates < StandardError; end
end
