require 'spec_helper'

describe Encounter do
  let(:jack) { Pc.new 'jack', '', 3 }
  let(:jill) { Pc.new 'jill', '', 4 }
  let(:game) { Game.instance.tap do |g|
    g.cast.clear
    g.cast.add jack
    g.cast.add jill
  end }
  let(:party) { game.pcs }
  let(:monsters) { MonsterLibrary.instance }
  let(:enc) { Encounter.new party }

  describe '#cr' do
    it 'returns expected cr' do
      expect(enc.cr).to eq(0)
      enc.npcs.add Monster.build 'thug'
      expect(enc.cr).to eq(0.5)
      enc.npcs.add Monster.build 'thug'
      expect(enc.cr).to eq(1)
      enc.npcs.add Monster.build 'thug'
      expect(enc.cr).to eq(3)
      enc.npcs.add Monster.build 'bandit'
      expect(enc.cr).to eq(3)
    end
  end

  describe '#cr_for_party' do
    it 'returns expected cr' do
      expect(enc.cr_for_party Encounter::EASY).to eq 1
      expect(enc.cr_for_party Encounter::MEDIUM).to eq 2
      expect(enc.cr_for_party Encounter::HARD).to eq 3
      expect(enc.cr_for_party Encounter::DEADLY).to eq 3
      jack.level = 5
      expect(enc.cr_for_party Encounter::EASY).to eq 2
      expect(enc.cr_for_party Encounter::MEDIUM).to eq 3
      expect(enc.cr_for_party Encounter::HARD).to eq 4
      expect(enc.cr_for_party Encounter::DEADLY).to eq 5
    end
  end

  describe '#new' do
    it 'returns a playable encounter' do
      enc = Encounter.new party
      enc.set_initiative jack, 13
      enc.set_initiative jill, 12
      enc.npcs.add gob1 = Monster.build('Goblin')
      enc.npcs.add gob2 = Monster.build('Goblin')
      enc.roll_npcs_initiative # Roll for npcs
      expect(enc.initiative_order).to include gob1
      expect(enc.initiative_order).to include gob2
      expect(enc.initiative_order).to include jill
      expect(enc.initiative_order).to include jack
    end
  end

  describe '#xp' do
    it 'returns expect xp' do
      expect(enc.xp).to eq(0)
      enc.npcs.add Monster.build('thug')
      expect(enc.xp).to eq(100)
      enc.npcs.add Monster.build('thug')
      expect(enc.xp).to eq(300) # 200*1.5
      enc.npcs.add Monster.build('bandit')
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

  xdescribe '.random' do
    it 'returns a encounter with at least one npc' do
      enc = Encounter.random party, Encounter::HARD, Encounter::ARCTIC
      pcs, npcs = enc.npcs.partition { |char| char.is_a? Pc }
      pc_count = pcs.length
      npc_count = npcs.length
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
