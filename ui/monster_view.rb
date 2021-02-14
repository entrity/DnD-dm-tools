require_relative './character_ui.rb'

class MonsterView < Gtk::Box
  def initialize monster
    super(:vertical)
    @monster = monster
    Gtk::Label.new(monster['name']).tap {|lbl|
      lbl.set_visible true
      add lbl
    }
    add_stats
    # add_stats 'Misc', %w[damage_vulnerabilities damage_resistances damage_immunities condition_immunities legendary_desc legendary_actions]
    add_section_w_label 'Actions', monster['actions']
    add_section_w_label 'Spell list', monster['spell_list']
    add_section_w_label 'Special abilities', monster['special_abilities']
    set_visible true
  end

  private

  def add_section label, &block
    btn = Gtk::Button.new(label: label).tap {|btn|
      btn.set_visible true
      add btn
    }
    rev = Gtk::Revealer.new.tap {|rev|
      rev.set_visible true
      rev.set_reveal_child true
      rev.set_can_focus false
      rev.set_transition_type :slide_up
    }
    rev.add yield(rev)
    add rev
    btn.signal_connect("clicked") do |widget, event|
      rev.set_reveal_child !rev.reveal_child?
    end
  end

  def add_section_w_label label, markup
    add_section label do |revealer|
      if markup.is_a? Array
        markup = markup.map {|data| "<b>#{data['name']}</b>\n#{data['desc']}" }.join("\n\n")
      end
      Gtk::Label.new().tap {|txt|
        txt.set_visible true
        txt.set_line_wrap true
        txt.set_markup markup
      }
    end if markup.length > 0
  end

  def add_stats
    builder_file = "#{File.expand_path(File.dirname(__FILE__))}/character.ui"
    # Construct a Gtk::Builder instance and load our UI description
    builder = Gtk::Builder.new(:file => builder_file)

    # box = Gtk::FlowBox.new
    # box.add
    character_ui = CharacterUI.new @monster
    markup = <<~EOF
    #{character_ui.stats_markup}
    AC
    size type subtype group
    alignment
    EOF
    add_section_w_label 'Stats', markup
  end
end
