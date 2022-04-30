require 'spec_helper'
require 'gtk3'
require 'pango'

describe EncounterUI do
  let(:monster) { Monster.build 'gnoll' }
  subject { EncounterUI.instance.tap { |enc|
    enc.init widget
  } }
  let(:widget) { Gtk::ListBox.new }

  describe '#add' do
    it 'adds a monster' do
      subject.add monster
    end
  end
end
