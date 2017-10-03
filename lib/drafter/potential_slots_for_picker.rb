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
      slot_counts.select do |position, count|
        valid_combinations.any? do |combination|
          combination.count { |combo| combo[:slot] == position } < count
        end
      end.keys
    end

    def valid_combinations
      all_combinations.select do |combination|
        ids = combination.map { |combo| combo[:id] }.sort

        ids == ids.uniq
      end.reject do |combination|
        positions = combination.map { |combo| combo[:slot] }.uniq

        positions.any? do |position|
          combination.
            count { |combo| combo[:slot] == position } > slot_counts[position]
        end
      end
    end

    def all_combinations
      collected_slot_options.combination(picker.picks.count).to_a
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
