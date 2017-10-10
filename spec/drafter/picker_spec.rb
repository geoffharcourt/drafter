require "spec_helper"

RSpec.describe Drafter::Picker do
  describe "#to_a" do
    it "returns picks as an array in the order picks were added" do
      picker = Drafter::Picker.new
      first_pick = { id: 2 }
      second_pick = { id: 1 }
      picker.picks << first_pick
      picker.picks << second_pick

      expect(picker.to_a).to match_array([first_pick, second_pick])
    end
  end
end
