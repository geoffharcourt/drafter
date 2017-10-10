require "spec_helper"

RSpec.describe Drafter::LineupPermutations do
  describe "#build" do
    it "returns an array of potential positions without using a player twice" do
      center_fielder = { id: 1, slots: [:cf, :of, :u] }
      right_fielder = { id: 2, slots: [:rf, :u] }
      picker = Drafter::Picker.new
      picker.pick(center_fielder)
      picker.pick(right_fielder)
      slot_counts = { cf: 1, of: 1, rf: 1, u: 1 }

      permutations = Drafter::LineupPermutations.
        new(picker: picker, slot_counts: slot_counts).
        build

      expect(permutations).not_to include([:cf, :of])
    end

    it "returns all possible combinations that don't duplicate a player" do
      infielder = { id: 1, slots: ["1b".to_sym, "3b".to_sym] }
      outfielder = { id: 2, slots: [:of, :rf] }
      picker = Drafter::Picker.new
      picker.pick(infielder)
      picker.pick(outfielder)
      slot_counts = { "1b".to_sym => 1, of: 1, rf: 1, "3b".to_sym => 1 }

      permutations = Drafter::LineupPermutations.
        new(picker: picker, slot_counts: slot_counts).
        build

      expect(permutations).to match_array([
        ["1b".to_sym, :of],
        ["1b".to_sym, :rf],
        ["3b".to_sym, :of],
        ["3b".to_sym, :rf],
      ])
    end

    context "with a single-position (plus utility) hitter" do
      it "will assign up to the allowed number of players at that position" do
        first_catcher = { id: 1, slots: [:c, :u] }
        second_catcher = { id: 2, slots: [:c, :u] }
        third_catcher = { id: 3, slots: [:c, :u] }
        picker = Drafter::Picker.new
        picker.pick(first_catcher)
        picker.pick(second_catcher)
        picker.pick(third_catcher)
        slot_counts = { c: 2, u: 2 }

        permutations = Drafter::LineupPermutations.
        new(picker: picker, slot_counts: slot_counts).
          build

        expect(permutations).to match_array([[:c, :c, :u]])
      end
    end

    context "with a multi-position (plus utility) hitter" do
      it "will not assign more than the allowed number of players at that position" do
        shortstop = { id: 1, slots: [:ss, :u] }
        utility = { id: 2, slots: [:c, :ss, :u] }
        catcher = { id: 3, slots: [:c, :u] }
        picker = Drafter::Picker.new
        picker.pick(shortstop)
        picker.pick(utility)
        picker.pick(catcher)
        slot_counts = { c: 2, ss: 1, u: 2 }

        permutations = Drafter::LineupPermutations.new(
          picker: picker,
          slot_counts: slot_counts
        ).build

        expect(permutations).to match_array([[:c, :c, :ss]])
      end
    end

    context "with prior cached assignments" do
      it "uses those assignments to reduce the number of permutations created" do
        shortstop = { id: 1, slots: ["2b".to_sym, :ss] }
        picker = Drafter::Picker.new
        picker.pick(shortstop)
        picker.cache_assignments([{ id: 1, slot: :ss }])
        slot_counts = { "2b".to_sym => 2, ss: 2 }

        permutations = Drafter::LineupPermutations.new(
          picker: picker,
          slot_counts: slot_counts,
        ).build

        expect(permutations).to match_array([[:ss]])
      end
    end
  end
end
