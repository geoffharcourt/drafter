class Picker
  attr_reader :picks

  def initialize
    @picks = []
  end

  def pick(choice)
    picks << choice
  end

  def to_a
    picks
  end
end
