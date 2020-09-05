require 'spec_helper'

describe Game do
  subject { Game.new 'test' }
  
  describe '#r' do
    it 'raises no error' do
      roll = subject.r 'd20 + 4 + 3d6'
      expect(strip_ansi roll).to match /^\d+ = \(\d+\) \+ 4 \+ \(\d \+ \d \+ \d\)$/
    end
  end
end
