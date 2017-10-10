class Drafter::PotentialSlotsForPicker
  def initialize(picker:, slot_counts:)
    @picker = picker
    @slot_counts = slot_counts
  end

  def slots
    unfilled_slots = previously_unfilled_slots
    picker.cache_assignments(assignments_to_cache)

    if unfilled_slots.empty?
      unfilled_slots
    else
      eligible_slots.keys
    end
  end

  def assignments_to_cache
    permutation_builder.single_option_assignments
  end

  private

  attr_reader :picker, :slot_counts

  def pitcher_shortcut?
    @_pitcher_shortcut ||= picker.players_at(:u) >= max_hitters
  end

  def slots_to_consider
    if pitcher_shortcut?
      slot_counts.select do |slot, _count|
        [:p, :sp, :rp].include?(slot)
      end
    else
      slot_counts
    end
  end

  def previously_unfilled_slots
    @_previoulsy_unfilled_slots ||= slots_to_consider.reject do |position, _|
      picker.filled_slots.count(position) >= slot_counts.fetch(position, 0)
    end
  end

  def filled_slots
    @_filled_slots = picker.filled_slots
  end

  def eligible_slots
    @_eligible_slots ||= previously_unfilled_slots.select do |position, count|
      valid_assignments.any? do |assignments|
        assignments.count(position) < count
      end
    end
  end

  def valid_assignments
    @_valid_assignments ||= position_assignments_without_duplicated_players.
      reject do |assignments|
        positions = assignments.uniq.sort.reverse

        positions.any? do |position|
          assignments.count(position) > slot_counts.fetch(position, 0)
        end
      end
  end

  def position_assignments_without_duplicated_players
    @_position_assignments_without_duplicated_players ||=
      permutation_builder.build
  end

  def permutation_builder
    @_permutation_builder ||= Drafter::LineupPermutations.new(
      picker: picker,
      pitchers_only: pitcher_shortcut?,
      slot_counts: slot_counts,
    )
  end

  def max_hitters
    slot_counts.reduce(0) do |memo, (slot, count)|
      unless [:p, :rp, :sp].include?(slot)
        memo += count
      end

      memo
    end
  end
end
