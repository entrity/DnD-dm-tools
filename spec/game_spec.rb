require 'spec_helper'

describe Game do
  subject { Game.instance.tap do |game|
    game.cast.push Pc.new 'jack', 3
    game.cast.push Pc.new 'jill', 4
  end }

  describe '#dump' do
    it 'raises no error' do
      expect { subject.dump }.to_not raise_error
    end
  end

  describe '#encounter' do
    it 'raises no error' do
      expect(subject.encounter).to be_a Encounter
    end
  end
end
