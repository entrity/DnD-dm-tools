require 'spec_helper'

describe 'Foe' do
  let(:monsters) { MonsterLibrary.new }
  subject { Monster.new monsters['Kitsune'] }

  describe '.attr' do
    it 'makes getter (#wisdom) and alias (#wis)' do
      expect(subject.wisdom).to eq 15
      expect(subject.wis).to eq 15
    end

    it 'makes setter (#wisdom=) and alias (#wis=)' do
      expect(subject.wisdom).not_to eq 88
      subject.wisdom = 88
      expect(subject.wisdom).to eq 88
      subject.wis = 77
      expect(subject.wisdom).to eq 77
    end
  end

  describe '#to_s' do
    it 'gives expected text' do
      puts subject.to_s
      no_color_s = strip_ansi subject.to_s
      expect(no_color_s).to match /Kitsune cr 2 hp 49 ac 12 spd/
      expect(no_color_s).to match /str 8 dex 15 con 11 int 12 wis 15 cha 14/
      expect(no_color_s).to match /Actions/
      expect(no_color_s).to match /Special abilities/
    end
  end
end
