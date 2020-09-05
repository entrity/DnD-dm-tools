require 'spec_helper.rb'

describe Pc do
  let(:pc) { Pc.new 'Alain', 3 }

  describe '#xp_threshold' do
    it 'fetches threshold for level and difficulty' do
      expect(pc.xp_threshold Encounter::EASY).to eq 75
      expect(pc.xp_threshold Encounter::DEADLY).to eq 400
      pc.level = 19
      expect(pc.xp_threshold Encounter::MEDIUM).to eq 4900
      expect(pc.xp_threshold Encounter::HARD).to eq 7300
    end
  end
end