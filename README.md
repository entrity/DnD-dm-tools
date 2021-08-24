# DM a D&D session

(/-_・)/D ------ →
(ಠ o ಠ)¤=[]:::::>
(∩ᄑ_ᄑ)⊃━☆ﾟ*･｡*･:≡( ε:)
(￣▽￣)/♫•*¨*•.¸¸♪
(◕‿◕✿)

## Startup

```bash
./main.rb $GAME_NAME
# EXAMPLE
./main.rb thursday-crew
```

You will find yourself in a pry inside of a Game object. See [#Playing](#playing) for commands.

## Playing on the command line
Even in the gui, there is a command-line I/O.

* `char` - enter `char` to get the currently selected character, the one displayed in the main pane.

```ruby
# Save progress to a file
dump

# Roll a die
r # It will prompt you for a string
r '3d20 + 6d4 + 3'

# Add a note
note 'This is my note'

# List monsters from library
monsters
monsters :challenge_rating, :name
monsters :challenge_rating, :name, sort: :challenge_rating
monsters :challenge_rating, :name, type: 'humanoid'
monsters :challenge_rating, :name, type: 'humanoid', sort: :name
# Print monsters (or any array of arrays) in a table
table monsters :name, :type
# Get monster attributes by name or array index
attrs = $monsters['Goblin']
attrs = $monsters[234]

# Build Monster object from monster attributes
mon = Monster.new $monsters['Goblin']
# View formatted stats+description of monster (or any character)
puts mon
# Update hp, etc.
mon.hp -= 3

# List pcs
pcs # aliased to `party`
# Add a pc
pcs['jack'] = Pc.new 'jack', 3
# List CRs for party
crs_for_party

# Start a random encounter (difficulty based on your party's abilities)
enc = encounter Encounter::HARD
enc = encounter Encounter::HARD, Encounter::ARCTIC
# Build a planned encounter
enc = Encounter.new pcs
# Set initiative (npc initiative gets re-rolled every time this is called)
enc.init 'David', 8 # It can be done with a name
enc.init pcs.first, 17 # It can be done with a Character object
enc.init # Roll initiative for NPCs
# Add NPCs to encounter
enc.npcs << Monster.new(monster_attrs)
# Get player whose turn it is and increment the cursor
p = enc.next
```
