require "drafter/version"
require "drafter/picker"
require "drafter/potential_slots_for_picker"

class Drafter
  def initialize(candidates:, pickers:, slot_counts:)
    @candidates = candidates
    @slot_counts = slot_counts
    @used_candidates = []

    @results = Array.new(pickers) { Drafter::Picker.new }
  end

  def draft
    while candidates_remain? && round_can_be_filled?
      prior_used_candidates_count = used_candidates.count

      results.each_with_index do |picker, index|
        puts "."
        puts "Team #{index + 1}"
        puts "."
        make_pick_for_picker(picker)
      end

      break if prior_used_candidates_count == used_candidates.count

      if candidates_remain? && round_can_be_filled?
        results.reverse.each_with_index do |picker, index|
          puts "."
          puts "Team #{results.count - index}"
          puts "."
          make_pick_for_picker(picker)
        end
      end

      break if prior_used_candidates_count == used_candidates.count
    end

    results
  end

  private

  attr_reader :candidates, :results, :slot_counts, :used_candidates

  def make_pick_for_picker(picker)
    top_pick = best_remaining_candidate(picker)

    if top_pick
      puts top_pick[:name]
      picker.pick(top_pick)
      used_candidates << top_pick
    end
  end

  def best_remaining_candidate(picker)
    possible_slots = slots_for_picker(picker)
    filled_slots = slot_counts.keys - possible_slots
    picker.mark_slots_filled(filled_slots)

    puts "Possible slots: #{possible_slots.inspect}"

    if possible_slots.none?
      nil
    else
      candidates_who_fit = remaining_candidates.select do |candidate|
        (candidate[:slots] & possible_slots).any?
      end

      if candidates_who_fit.any?
        candidates_who_fit.sort_by do |candidate|
          candidate[:value]
        end.reverse.first
      end
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
