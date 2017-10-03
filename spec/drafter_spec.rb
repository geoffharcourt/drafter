RSpec.describe Drafter do
  it "has a version number" do
    expect(Drafter::VERSION).not_to be nil
  end

  it "distributes the picks among the specified number of pickers" do
    candidates = []

    drafter = Drafter.new(
      candidates: candidates,
      pickers: 3,
      slot_counts: { "u" => 10 },
    )

    results = drafter.draft.map(&:picks)
    expect(results.count).to eq(3)
  end

  it "distributes candidates among the pickers efficiently" do
    candidates = [
      { id: "1st", value: 1000, slots: ["u"] },
      { id: "2nd", value: 900, slots: ["u"] },
      { id: "3rd", value: 800, slots: ["u"] },
      { id: "4th", value: 700, slots: ["u"] },
      { id: "5th", value: 600, slots: ["u"] },
      { id: "6th", value: 500, slots: ["u"] },
    ]

    drafter = Drafter.new(
      candidates: candidates,
      pickers: 3,
      slot_counts: { "u" => 10 },
    )

    results = drafter.draft.map(&:picks)
    expect(results[0]).to match_array([
      { id: "1st", value: 1000, slots: ["u"] },
      { id: "6th", value: 500, slots: ["u"] },
    ])
    expect(results[1]).to match_array([
      { id: "2nd", value: 900, slots: ["u"] },
      { id: "5th", value: 600, slots: ["u"] },
    ])
    expect(results[2]).to match_array([
      { id: "3rd", value: 800, slots: ["u"] },
      { id: "4th", value: 700, slots: ["u"] },
    ])
  end

  it "does not execute a round that cannot be filled" do
    candidates = [
      { id: "1st", value: 1000, slots: ["u"] },
      { id: "2nd", value: 900, slots: ["u"] },
      { id: "3rd", value: 800, slots: ["u"] },
      { id: "4th", value: 700, slots: ["u"] },
    ]

    drafter = Drafter.new(
      candidates: candidates,
      pickers: 3,
      slot_counts: { "u" => 10 },
    )

    results = drafter.draft.map(&:picks)
    expect(results.flatten).not_to include({ id: "4th", value: 700 })
  end

  it "respects slot counts" do
    candidates = [
      { id: "1st", value: 1000, slots: ["1b"] },
      { id: "2nd", value: 900, slots: ["2b"] },
      { id: "3rd", value: 800, slots: ["2b"] },
      { id: "4th", value: 700, slots: ["1b"] },
    ]

    drafter = Drafter.new(
      candidates: candidates,
      pickers: 2,
      slot_counts: { "1b" => 1, "2b" => 1 },
    )

    results = drafter.draft
    expect(results[1]).to match_array([
      { id: "2nd", value: 900, slots: ["2b"] },
      { id: "4th", value: 700, slots: ["1b"] },
    ])
  end
end
