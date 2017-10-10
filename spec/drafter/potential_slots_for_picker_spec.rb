require "spec_helper"

RSpec.describe Drafter::PotentialSlotsForPicker do
  it "returns positions that have no candidiates" do
    slot_counts = { "1b" => 1, "2b" => 1, "3b" => 1 }
    picker = Drafter::Picker.new
    picker.pick({ id: 1, slots: ["1b"] })
    picker.pick({ id: 2, slots: ["2b"] })

    potential_slots = Drafter::PotentialSlotsForPicker.new(
      picker: picker,
      slot_counts: slot_counts
    ).slots

    expect(potential_slots).to include("3b")
  end

  it "returns positions that have not enough candidiates" do
    slot_counts = { "1b" => 2, "2b" => 1, "3b" => 1 }
    picker = Drafter::Picker.new
    picker.pick({ id: 1, slots: ["1b"] })
    picker.pick({ id: 2, slots: ["2b"] })
    picker.pick({ id: 3, slots: ["3b"] })

    potential_slots = Drafter::PotentialSlotsForPicker.new(
      picker: picker,
      slot_counts: slot_counts
    ).slots

    expect(potential_slots).to include("1b")
  end

  it "returns positions that have candidates but could accept a new candidate" do
    slot_counts = { "1b" => 1, "2b" => 1, "3b" => 1 }
    picker = Drafter::Picker.new
    picker.pick({ id: 1, slots: ["1b", "2b"] })
    picker.pick({ id: 2, slots: ["2b", "3b"] })

    potential_slots = Drafter::PotentialSlotsForPicker.new(
      picker: picker,
      slot_counts: slot_counts
    ).slots

    expect(potential_slots).to include("1b")
    expect(potential_slots).to include("2b")
    expect(potential_slots).to include("3b")
  end

  it "filters out positions that are guaranteed to be filled" do
    slot_counts = { "1b" => 1, "2b" => 1, "3b" => 1 }
    picker = Drafter::Picker.new
    picker.pick({ id: 1, slots: ["1b"] })
    picker.pick({ id: 2, slots: ["2b", "3b"] })

    potential_slots = Drafter::PotentialSlotsForPicker.new(
      picker: picker,
      slot_counts: slot_counts
    ).slots

    expect(potential_slots).not_to include("1b")
    expect(potential_slots).to include("2b")
    expect(potential_slots).to include("3b")
  end
end
