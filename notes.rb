require "csv"

rows = CSV.read("/Users/geoff/Desktop/test.csv", headers: true).map do |x|
  {
    id: x["player_id"].to_i,
    name: x["name_display_first_last"],
    slots: x["positions"].gsub(/\{|\}/, '').split(",").map(&:to_sym),
    value: x["z_above_replacement_actual"].to_f
  }
end

drafter = Drafter.new(
  candidates: rows, pickers: 10,
  slot_counts: {
    c: 1,
    "1b".to_sym => 1,
    "2b".to_sym => 1,
    ss: 1,
    "3b".to_sym => 1,
    of: 1,
    cf: 1,
    rf: 1,
    u: 2,
  },
)

results = drafter.draft
