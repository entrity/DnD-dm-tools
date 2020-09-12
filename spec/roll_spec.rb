require 'spec_helper'

describe Roll do

  describe '#to_s' do
    it 'outputs correct value' do
      roll = Roll.new('d20 + 4 + 3d6').to_s
      expect(strip_ansi roll).to match /^\d+ = \(\d+\) \+ 4 \+ \(\d \+ \d \+ \d\)$/
    end
  end
end
