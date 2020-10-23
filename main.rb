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
    FileUtils.cp fpath, "#{fpath}.bak"
    $game = Marshal.load File.read fpath
    $game.party.each do |pc_name, pc|
      define_method(pc_name) { pc }
    end
  else
    $game = Game.new fpath
  end
  $game.start
  $game.dump
end
