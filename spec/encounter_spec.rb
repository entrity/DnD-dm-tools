require 'spec_helper'

describe Encounter do
  let(:game) { Game.new('test').tap do |g|
    g.party['jack'] = Pc.new
    g.party['jill'] = Pc.new
  end }
  let(:party) { game.party }
  let(:monsters) { MonsterLibrary.new }

  describe '#new' do
    it 'returns a playable encounter' do
      enc = Encounter.new party
      enc.init 'jack', 13
      enc.init 'jill', 12
      enc.npcs << Monster.new(monsters['Goblin'])
      enc.npcs << Monster.new(monsters['Goblin'])
      enc.init # Roll for npcs
      enc.next
    end
  end

  describe '.random' do
    it 'returns a playable encounter' do
      enc = Encounter.random party, Encounter::ARCTIC, Encounter::HARD
    end
  end
end
