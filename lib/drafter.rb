require "drafter/version"
require "drafter/picker"
require "drafter/lineup_permutations"
require "drafter/choice"
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
    round = 1
    loop do
      time = Time.now
      puts ""
      puts "Round #{round}"
      results.each { |picker| make_pick_for_picker(picker) }
      puts "...finished in #{Time.now - time} seconds"
      puts ""
      round += 1

      time = Time.now
      puts ""
      puts "Round #{round}"
      results.reverse_each { |picker| make_pick_for_picker(picker) }
      puts "...finished in #{Time.now - time} seconds"
      puts ""
      round += 1
    end
  rescue NoFurtherCandidates
    # noop
  end

  def make_pick_for_picker(picker)
    time = Time.now
    top_candidate = Choice.new(candidates: candidates, slot_counts: slot_counts, picker: picker).top_candidate

    if top_candidate
      picker.picks << top_candidate
      puts "#{top_candidate[:name]}, took #{Time.now - time}s"
      @candidates -= [top_candidate]
    else
      fail NoFurtherCandidates
    end
  end

  class NoFurtherCandidates < StandardError; end
end
