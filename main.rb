#!/usr/bin/ruby

require 'json'
require './lib/game'

if __FILE__ == $PROGRAM_NAME
  fpath = ARGV[0] || 'test'
  if fpath.nil?
    $stderr.puts "fpath required"
    exit 1
  end
  if File.exists?(fpath)
    game = Marshal.load File.read fpath
    game.increment_fpath
  else
    game = Game.new fpath
  end
  load_monsters
  puts "monsters..."
  puts $monsters.length
  game.start
  game.dump
end
