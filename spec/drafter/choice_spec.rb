require "spec_helper"

RSpec.describe Drafter::Choice do
  describe "#top_candidate" do
    context "with no constraints" do
      it "returns the first candidate from the list" do
        best = { id: 1, value: 100, slots: [:u] }
        next_best = { id: 2, value: 90, slots: [:u] }
        caddy = { id: 3, value: 80, slots: [:u] }
        candidates = [best, next_best, caddy]
        picker = Drafter::Picker.new

        choice = Drafter::Choice.new(
          candidates: candidates,
          picker: picker,
          slot_counts: { u: 1 },
        )

        expect(choice.top_candidate[:id]).to eq(best[:id])
      end

      it "respects the hitter-bias disposition" do
        pitcher = { id: 1, value: 100, slots: [:sp] }
        best_hitter = { id: 2, value: 90, slots: [:u] }
        caddy = { id: 3, value: 80, slots: [:u] }
        candidates = [pitcher, best_hitter, caddy]
        picker = Drafter::Picker.new(disposition: 1.2)

        choice = Drafter::Choice.new(
          candidates: candidates,
          picker: picker,
          slot_counts: { sp: 1, u: 1 },
        )

        expect(choice.top_candidate[:id]).to eq(best_hitter[:id])
      end
    end

    context "with a filled position" do
      it "returns the first candidate from the list that can be rostered" do
        ineligible = { id: 1, value: 100, slots: ["2b".to_sym, :u] }
        best = { id: 2, value: 90, slots: ["3b".to_sym, :u] }
        caddy = { id: 3, value: 80, slots: [:u] }
        candidates = [ineligible, best, caddy]
        picker = Drafter::Picker.new
        picker.pick({ id: 4, slots: ["2b".to_sym] })

        choice = Drafter::Choice.new(
          candidates: candidates,
          picker: picker,
          slot_counts: { "2b".to_sym => 1, "3b".to_sym => 1 },
        )

        expect(choice.top_candidate[:id]).to eq(best[:id])
      end
    end

    it "respects slot counts" do
      ineligible = { id: 1, value: 100, slots: ["2b".to_sym, :u] }
      best = { id: 2, value: 90, slots: ["3b".to_sym,:u] }
      caddy = { id: 3, value: 80, slots: [:u] }
      candidates = [ineligible, best, caddy]
      picker = Drafter::Picker.new
      picker.pick({ id: 4, slots: ["2b".to_sym] })

      choice = Drafter::Choice.new(
        candidates: candidates,
        picker: picker,
        slot_counts: { "2b".to_sym => 1, "3b".to_sym => 1 },
      )

      expect(choice.top_candidate[:id]).to eq(best[:id])
    end
  end
end
