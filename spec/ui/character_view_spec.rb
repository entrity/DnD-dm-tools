require 'spec_helper.rb'

describe CharacterView do

  it 'can build from monster item' do
    monster = MonsterLibrary.instance[:gnoll]
    dict = monster.to_h.transform_keys(&:to_s)
    CharacterView.new Monster.new.load_open5e(dict)
  end
end
