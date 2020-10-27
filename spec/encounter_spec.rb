require 'spec_helper'

describe Encounter do
  let(:game) { Game.new('test').tap do |g|
    g.party['jack'] = Pc.new 'jack', 3
    g.party['jill'] = Pc.new 'jill', 4
  end }
  let(:party) { game.party }
  let(:monsters) { MonsterLibrary.new }
  let(:enc) { Encounter.new party }

  describe '#cr' do
    it 'returns expected cr' do
      expect(enc.cr).to eq(0)
      enc.add 'thug'
      expect(enc.cr).to eq(0.5)
      enc.add 'thug'
      expect(enc.cr).to eq(1)
      enc.add 'thug'
      expect(enc.cr).to eq(3)
      enc.add 'bandit'
      expect(enc.cr).to eq(3)
    end
  end

  describe '#cr_for_party' do
    it 'returns expected cr' do
      expect(enc.cr_for_party Encounter::EASY).to eq 1
      expect(enc.cr_for_party Encounter::MEDIUM).to eq 2
      expect(enc.cr_for_party Encounter::HARD).to eq 3
      expect(enc.cr_for_party Encounter::DEADLY).to eq 3
      game.party['jack'].level = 5
      expect(enc.cr_for_party Encounter::EASY).to eq 2
      expect(enc.cr_for_party Encounter::MEDIUM).to eq 3
      expect(enc.cr_for_party Encounter::HARD).to eq 4
      expect(enc.cr_for_party Encounter::DEADLY).to eq 5
    end
  end

  describe '#new' do
    it 'returns a playable encounter' do
      enc = Encounter.new party
      enc.init 'jack', 13
      enc.init enc.party['jill'], 12
      enc.npcs << gob1 = Monster.new(monsters['Goblin'])
      enc.npcs << gob2 = Monster.new(monsters['Goblin'])
      enc.init # Roll for npcs
      expect(enc.initiative_order).to include gob1
      expect(enc.initiative_order).to include gob2
      expect(enc.initiative_order).to include enc.party['jill']
      expect(enc.initiative_order).to include enc.party['jack']
      round_1 = (1..4).map { enc.pop }
      expect(round_1).to match_array(enc.initiative_order)
      round_2 = (1..4).map { enc.pop }
      expect(round_2).to match_array(round_1)
    end
  end

  describe '#xp' do
    it 'returns expect xp' do
      expect(enc.xp).to eq(0)
      enc.add 'thug'
      expect(enc.xp).to eq(100)
      enc.add 'thug'
      expect(enc.xp).to eq(300) # 200*1.5
      enc.add 'bandit'
      expect(enc.xp).to eq(450) # 225*2
    end
  end

  describe '.cr_for_xp' do
    it 'returns the table values' do
      expect(Encounter.cr_for_xp(25)).to eq(0.125)
      expect(Encounter.cr_for_xp(35)).to eq(0.125)
      expect(Encounter.cr_for_xp(40)).to eq(0.25)
      expect(Encounter.cr_for_xp(8500)).to eq(12)
      expect(Encounter.cr_for_xp(22000)).to eq(19)
      expect(Encounter.cr_for_xp(135000)).to eq(29)
    end
  end

  describe '.random' do
    it 'returns a encounter with at least one npc' do
      enc = Encounter.random party, Encounter::HARD, Encounter::ARCTIC
      enc.init 'jack', 4
      enc.init enc.party['jill'], 16
      expect(enc.party['jack']).to eq(game.party['jack'])
      expect(enc.party['jill']).to eq(game.party['jill'])
      pc_count = enc.initiative_order.count {|char| char.is_a?(Pc) }
      npc_count = enc.initiative_order.count {|char| char.is_a?(Npc) }
      expect(pc_count).to eq 2
      expect(npc_count).to be > 0
    end
  end

  describe '.xp_multiplier' do
    it 'returns the table values' do
      expect(Encounter.xp_multiplier(0)).to eq(0)
      expect(Encounter.xp_multiplier(1)).to eq(1)
      expect(Encounter.xp_multiplier(2)).to eq(1.5)
      expect(Encounter.xp_multiplier(3)).to eq(2)
      expect(Encounter.xp_multiplier(4)).to eq(2)
      expect(Encounter.xp_multiplier(5)).to eq(2)
      expect(Encounter.xp_multiplier(6)).to eq(2)
      expect(Encounter.xp_multiplier(7)).to eq(2.5)
      expect(Encounter.xp_multiplier(13)).to eq(3)
      expect(Encounter.xp_multiplier(28)).to eq(4)
    end
  end
end
