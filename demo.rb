#!/usr/bin/ruby

require './lib/game'
require './lib/characters'

game = Game.new 'demo'
game.party['jack'] = Pc.new 'jack', 3
game.party['jill'] = Pc.new 'jill', 4
game.start
