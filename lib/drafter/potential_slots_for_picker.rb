class Drafter
  class PotentialSlotsForPicker
    def initialize(picker:, slot_counts:)
      @picker = picker
      @slot_counts = slot_counts
    end

    def slots
      unfilled_positions
    end

    attr_reader :picker, :slot_counts

    def unfilled_positions
      slot_counts.reject do |position, _|
        picker.filled_slots.include?(position)
      end.select do |position, count|
        valid_combinations.any? do |combination|
          puts "evaluating combination for free positions: #{combination}"
          combination.count do |combo|
            combo[:slot] == position
          end < count
        end
      end.keys
    end

    def valid_combinations
      all_combinations.select do |combination|
        ids = combination.map { |combo| combo[:id] }.sort

        ids == ids.uniq
      end.reject do |combination|
        puts "evaluation combination for validity: #{combination}"
        positions = combination.map { |combo| combo[:slot] }.uniq

        positions.any? do |position|
          combination.
            count { |combo| combo[:slot] == position } > slot_counts.fetch(position, 0)
        end
      end
    end

    def all_combinations
      collected_slot_options.combination(picker.picks.count).to_a.uniq
    end

    def collected_slot_options
      picker.picks.flat_map do |pick|
        pick[:slots].map do |slot|
          { id: pick[:id], slot: slot }
        end
      end
    end
  end
end
