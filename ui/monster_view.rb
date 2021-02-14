require_relative './character_ui.rb'

class MonsterView < Gtk::Box
  include CharacterUI

  def initialize monster
    super(:vertical)
    @monster = monster
    Gtk::Label.new(monster['name']).tap {|lbl|
      lbl.set_visible true
      add lbl
    }
    add_stats
    # add_stats 'Misc', %w[damage_vulnerabilities damage_resistances damage_immunities condition_immunities legendary_desc legendary_actions]
    add_section 'Actions', monster['actions']
    add_section 'Spell list', monster['spell_list']
    add_section 'Special abilities', monster['special_abilities']
    set_visible true
  end

  private

  def add_section label, array_or_markup=nil
    if array_or_markup.length > 0
      btn = Gtk::Button.new(label: label).tap {|btn|
        btn.set_visible true
        add btn
      }
      if array_or_markup.is_a? Array
        markup = array_or_markup.map {|data| "<b>#{data['name']}</b>\n#{data['desc']}" }.join("\n\n")
      else
        markup = array_or_markup
      end
      rev = Gtk::Revealer.new.tap {|rev|
        rev.set_visible true
        rev.set_reveal_child true
        rev.set_can_focus false
        rev.set_transition_type :slide_up
      }
      info = Gtk::Label.new().tap {|txt|
        txt.set_visible true
        txt.set_line_wrap true
        txt.set_markup markup
        rev.add txt
      }
      add rev
      btn.signal_connect("clicked") do |widget, event|
        rev.set_reveal_child !rev.reveal_child?
      end
    end
  end


  def add_stats
    markup = <<~EOF
    #{character_stats_markup @monster}
    AC
    size type subtype group
    alignment
    EOF
    add_section 'Stats', markup
  end
end
