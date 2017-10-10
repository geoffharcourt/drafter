class Drafter::LineupPermutations
  attr_reader :single_option_assignments

  def initialize(picker:, slot_counts:, pitchers_only: false)
    @locked_positions = []
    @picker = picker
    @slot_counts = slot_counts
    @single_option_assignments = []
    @pitchers_only = pitchers_only
  end

  def build
    @_position_assignments_without_duplicated_players ||=
      combinations_without_duplicated_players.map do |combination|
        combination.map { |combo| combo[:slot] }.sort
    end.uniq
  end

  private

  attr_reader :locked_positions, :picker, :pitchers_only, :slot_counts

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

  def relevant_picks
    if pitchers_only
      picker.picks.select do |pick|
        (pick[:slots] & [:p, :sp, :rp]).any?
      end
    else
      picker.picks
    end
  end

  def collected_slot_options
    relevant_picks.flat_map do |pick|
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
          (pick[:slots] - excludables).map do |slot|
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
    @_picks_count ||= relevant_picks.length
  end
end
