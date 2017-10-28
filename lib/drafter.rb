require "drafter/version"
require "drafter/picker"
require "drafter/lineup_permutations"
require "drafter/choice"
require "drafter/potential_slots_for_picker"

class Drafter
  def initialize(candidates:, pickers:, dispositions: [1.0], slot_counts:, debug: false)
    @candidates = candidates.sort_by { |candidate| candidate[:value] }.reverse
    @slot_counts = slot_counts
    @debug = debug

    @results = []
    until results.count == pickers do
      results << Drafter::Picker.new(
        disposition: dispositions[results.count % dispositions.count],
      )
    end
  end

  def draft
    make_choices
    results
  end

  private

  attr_reader :candidates, :debug, :results, :slot_counts

  def make_choices
    round_number = 1
    loop do
      make_picks_for_round(results, round_number)
      round_number += 1
      make_picks_for_round(results.reverse, round_number)
      round_number += 1
    end
  rescue NoFurtherCandidates
    # noop
  end

  def make_picks_for_round(pickers_in_order, round_number)
    time = Time.now
    debug_puts ""
    debug_puts "Round #{round_number}"
    pickers_in_order.each { |picker| make_pick_for_picker(picker) }
    debug_puts "...finished in #{Time.now - time} seconds"
    debug_puts ""
  end

  def make_pick_for_picker(picker)
    time = Time.now
    top_candidate = Choice.new(
      candidates: candidates,
      slot_counts: slot_counts,
      picker: picker,
    ).top_candidate

    if top_candidate
      debug_puts "#{top_candidate[:name]}, (disposition #{picker.disposition} took #{Time.now - time}s"
      picker.picks << top_candidate
      @candidates -= [top_candidate]
    else
      fail NoFurtherCandidates
    end
  end

  def debug_puts(text)
    if debug
      puts text
    end
  end

  class NoFurtherCandidates < StandardError; end
end
