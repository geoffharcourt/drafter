class Drafter::LineupPermutations
  attr_reader :single_option_assignments

  def initialize(picker:, slot_counts:)
    @locked_positions = []
    @picker = picker
    @slot_counts = slot_counts
    @single_option_assignments = []
  end

  def build
    @_position_assignments_without_duplicated_players ||=
      combinations_without_duplicated_players.map do |combination|
        combination.map { |combo| combo[:slot] }.sort
    end.uniq
  end

  private

  attr_reader :locked_positions, :picker, :slot_counts

  def cached_assignments
    picker.cached_assignments
  end

  def combinations_without_duplicated_players
    all_combinations.select do |combination|
      ids = combination.map { |combo| combo[:id] }.uniq

      ids.length == picks_count
    end
  end

  def all_combinations
    collected_slot_options.combination(picks_count).to_a.uniq
  end

  def collected_slot_options
    picker.picks.flat_map do |pick|
      cached_assignment = cached_assignments.detect do |assignment|
        assignment[:id] == pick[:id]
      end

      if cached_assignment
        single_option_assignments << cached_assignment
        cached_assignment
      else
        excludables = positions_to_exclude
        non_u_slots = pick[:slots] - [:u] - excludables

        if non_u_slots.length == 1
          non_u_slot = non_u_slots[0]

          if excludables.include?(non_u_slot)
            assignment = { id: pick[:id], slot: :u }
            single_option_assignments << assignment
            [assignment]
          else
            locked_positions << non_u_slot
            assignment = { id: pick[:id], slot: non_u_slot }
            single_option_assignments << assignment
            [assignment]
          end
        else
          (pick[:slots] - positions_to_exclude).map do |slot|
            { id: pick[:id], slot: slot }
          end
        end
      end
    end
  end

  def positions_to_exclude
    locked_positions.uniq.select do |position|
      locked_positions.count(position) >= slot_counts.fetch(position, 0)
    end
  end

  def picks_count
    @_picks_count ||= picker.picks.length
  end
end
