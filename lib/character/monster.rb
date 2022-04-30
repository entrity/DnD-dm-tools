require_relative '../character.rb'

# A PC has player-class levels
class Monster < Character
  def self.build slug_or_name
    new.load_open5e MonsterLibrary.instance[slug_or_name]
  end

  def initialize
    @is_pc = false # is_pc means it's controlled by the party, not that it has player class levels
    super()
  end

  alias_method :level, :challenge_rating
end
