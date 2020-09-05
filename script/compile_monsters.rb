#!/usr/bin/ruby

require 'json'
require 'pry'
require 'set'

def load_monsters
  # Get monsters from https://api.open5e.com/ files
  open5e_monsters = Dir['data/open5e-monsters*'].reduce([]) do |acc, fpath|
    results = JSON.parse(File.read fpath)['results']
    results.each { |m| m['challenge_rating'] = m['challenge_rating'].to_f }
    acc + results
  end
  open5e_hash = open5e_monsters.map {|m| [m['name'], m]}.to_h
  # Apply environment data from https://donjon.bin.sh/5e/monsters/
  environments = {}
  donjon_monsters = JSON.parse(File.read 'data/donjon.bin-monsters.json')
  donjon_monsters.each do |name, v|
    v['environment'].keys.each do |env|
      if open5e_monster = open5e_hash[name]
        environments[env] ||= Set.new
        environments[env] << open5e_monster
      end
    end if v['environment']
  end
  binding.pry
end

load_monsters
