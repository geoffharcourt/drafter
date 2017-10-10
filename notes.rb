require "csv"

time = Time.now

hitter_rows = CSV.read("/Users/geoff/Desktop/test.csv", headers: true).map do |x|
  {
    id: x["player_id"].to_i,
    name: x["name_display_first_last"],
    slots: x["positions"].gsub(/\{|\}/, '').split(",").map(&:strip).map(&:to_sym),
    value: x["z_above_replacement_actual"].to_f
  }
end

pitcher_rows = CSV.read("/Users/geoff/Desktop/test_pitchers.csv", headers: true).map do |x|
  {
    id: x["player_id"].to_i,
    name: x["name_display_first_last"],
    slots: x["positions"].gsub(/\{|\}/, '').split(",").map(&:strip).map(&:to_sym),
    value: x["z_above_replacement_actual"].to_f
  }
end

rows = hitter_rows + pitcher_rows

pickers = 16

drafter = Drafter.new(
  candidates: rows, pickers: pickers,
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
    sp: 7,
    rp: 5,
  },
)

results = drafter.draft

puts ""
puts ""
puts "Drafted for #{pickers} in #{Time.now - time} seconds."
