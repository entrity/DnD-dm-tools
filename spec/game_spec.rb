require 'spec_helper'

describe Game do
  subject { Game.new('test').tap do |game|
    game.party['jack'] = Pc.new 'jack', 3
    game.party['jill'] = Pc.new 'jill', 4
  end }

  describe '#crs_for_party' do
    it 'returns an Array' do
      expect(subject.crs_for_party).to eq ["1", "2", "3", "3"]
    end
  end

  describe '#dump' do
    it 'raises no error' do
      expect { subject.dump }.to_not raise_error
    end
  end

  describe '#encounter' do
    it 'raises no error' do
      enc = subject.encounter Encounter::MEDIUM, Encounter::SWAMP
      expect(enc).to be_a Encounter
    end
  end

  describe '#monsters' do
    it 'returns an Array of Hash' do
      expect(subject.monsters).to be_a Array
      expect(subject.monsters.all? {|m| m.is_a?(Hash) }).to be true
    end
  end

  describe '#r' do
    it 'raises no error' do
      expect { subject.r 'd20 + 4 + 3d6' }.to_not raise_error
    end
  end
end
