require 'spec_helper'

describe 'Foe' do
  let(:monsters) { MonsterLibrary.instance }
  subject { Monster.new.load_open5e monsters['Kitsune'] }

  describe '.attr' do
    it 'makes getter (#wisdom) and alias (#wis)' do
      expect(subject.wis).to eq 15
    end

    it 'makes setter (#wisdom=) and alias (#wis=)' do
      expect(subject.wis).not_to eq 88
      subject.attrs.wis = 88
      expect(subject.wis).to eq 88
      subject.attrs.wis = 77
      expect(subject.wis).to eq 77
    end
  end

  describe '#to_s' do
    it 'gives expected text' do
      puts subject.to_s
      no_color_s = strip_ansi subject.to_s
      expect(no_color_s).to match /Kitsune.* cr 2 hp 49/
    end
  end
end
