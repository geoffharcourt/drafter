class Drafter
  class PotentialSlotsForPicker
    def initialize(picker:, slot_counts:)
      @picker = picker
      @slot_counts = slot_counts
    end

    def slots
      unfilled_slots = previously_unfilled_slots

      if unfilled_slots.empty?
        unfilled_slots
      else
        eligible_slots.keys
      end
    end

    attr_reader :picker, :slot_counts

    def filled_slots
      @_filled_slots = picker.filled_slots
    end

    def previously_unfilled_slots
      slot_counts.reject do |position, _|
        picker.filled_slots.include?(position)
      end
    end

    def eligible_slots
      puts "Considering #{position_assignments_without_duplicated_players.length} assignments"
      puts "Considering #{valid_assignments.length} valid assignments"
      previously_unfilled_slots.select do |position, count|
        valid_assignments.any? do |assignments|
          assignments.count(position) < count
        end
      end
    end

    def valid_assignments
      @_valid_assignments ||= position_assignments_without_duplicated_players.reject do |assignments|
        positions = assignments.uniq.sort.reverse

        positions.any? do |position|
          assignments.count(position) > (slot_counts[position] || 0)
        end
      end
    end

    def position_assignments_without_duplicated_players
      @_position_assignments_without_duplicated_players ||=
        combinations_without_duplicated_players.map do |combination|
          combination.map { |combo| combo[:slot] }.sort
        end.uniq
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
      locked_positions = []

      picker.picks.flat_map do |pick|
        non_u_slots = pick[:slots] - [:u]
        if non_u_slots.length == 1 && filled_slots.include?(non_u_slots[0])
          if locked_positions.include?(non_u_slots[0])
            [{ id: pick[:id], slot: :u }]
          else
            locked_positions << non_u_slots[0]
            [{ id: pick[:id], slot: non_u_slots[0] }]
          end
        else
          pick[:slots].map do |slot|
            { id: pick[:id], slot: slot }
          end
        end
      end
    end

    def picks_count
      @_picks_count ||= picker.picks.length
    end
  end
end
