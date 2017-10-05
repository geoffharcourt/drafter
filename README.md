# Drafter

A Ruby experiment to simulate draft a fantasy sports teams.

This library iterates through a collection of players and attempts to make a
somewhat informed decision about the best player to take next. For a sport like
baseball that has many players who could be eligible at multiple positions, the
picking process will re-evaluate who could

## Installation

Download the repository. Use `bin/console` to run it in an IRB environment.

## Usage

`Drafter` takes the following arguments in its initializer:

- `candidates`: an array of candidate players represented by hashes. Each hash
  should contain a unique `:id` key, a `:value` key that represents the player's
  production value, and a `:slots` key that represents the positions a player is
  eligible to play.
- `pickers`: an integer, the number of "teams" that will participate in the
  draft process
- `slot_counts` a hash containing keys for positions (must match the candidates'
  `slots`) and the number of players each team will roster at a given position.
  Here's what my fantasy baseball league looks like with 1 fielder at every
  batter-fielder position plus two utility players, seven starting pitchers,
  and five relievers:

  ```ruby
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
  }
  ```

  Using symbols for your slots instead of strings will allow the drafting
  process to move faster, as comparisons will be less expensive.

## How does it work?

The draft moves in a "snake-draft" direction, with teams picking in order in
odd-numbered rounds and in reverse order in even-numbered rounds.

At each team's turn, the positions at which a player could be deployed by the
picking team is evaluated. Every existing player belonging to the picker has
their potential positions put into the pool, and every possible lineup
combination is generated using the player-position pairings. Invalid lineups are
removed if a player is rostered twice or the number of players at a position
exceeds the slot count maximum.

As a team grows, the number of combinations grows very quickly. To reduce
calculation time, the following checks are made to see if we can take a
shortcut:

1. If the top unpicked player could be deployed without any further evaluation
   of a team's slot possibilities (often a pitcher), they are chosen.
2. If a player is only eligible at two positions (one of which being utility)
   and the non-utility position is known to have been previously allocated in a
   prior pick, that player is automatically assigned to that position or
   utility, cutting the number of permutations for the pick in half.
3. After every pick that involves iterating through assignment possibilities,
   the claimed assignments are saved so those positions do not need to be
   re-checked on later tests.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/geoffharcourt/drafter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Drafter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/geoffharcourt/drafter/blob/master/CODE_OF_CONDUCT.md).
