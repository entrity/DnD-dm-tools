require_relative '../abstract_library'
require_relative '../characters'

class Character::PlayerClassLibrary < AbstractLibrary
  DATA_FILE_GLOB = 'open5e-player-classes*.json'
end
