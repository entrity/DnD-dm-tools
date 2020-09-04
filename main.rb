#!/usr/bin/ruby

require 'json'
require './lib/game'

def load_monsters
  $monsters ||= Dir['data/monsters*'].reduce [] do |acc, fpath|
    acc + JSON.parse(File.read fpath)['results']
  end
end

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
