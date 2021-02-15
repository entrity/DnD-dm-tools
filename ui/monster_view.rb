require_relative './character_ui.rb'
require_relative './character_ui/stats_ui.rb'
require_relative './markup.rb'

class MonsterView < Gtk::Box
  include Markup

  def initialize monster
    super(:vertical)
    @monster = monster
    Gtk::Label.new(monster['name']).tap {|lbl|
      lbl.set_visible true
      add lbl
    }
    add_stats
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
      box = Gtk::Box.new(:vertical).tap do |box|
        box.set_visible true
        yield box
      end
      rev.add box
    }
    add rev
    btn.signal_connect("clicked") do |widget, event|
      rev.set_reveal_child !rev.reveal_child?
    end
  end

  def add_section_w_label label, markup
    add_section label do |box|
      if markup.is_a? Array
        markup = markup.map {|data| "<b>#{data['name']}</b>\n#{data['desc']}" }.join("\n\n")
      end
      box.add Gtk::Label.new().tap {|txt|
        txt.set_visible true
        txt.set_line_wrap true
        txt.set_markup markup
      }
    end if markup.length > 0
  end

  def add_stats
    add_section 'Stats' do |box|
      hp_line = hp_markup @monster['hit_points']
      hp_line += " #{colored 'gray', 'dice'} #{@monster['hit_dice']}"
      box.add label hp_line
      box.add Gtk::FlowBox.new.tap { |flow|
        flow.set_visible true
        flow.add attr_label :str, :strength
        flow.add attr_label :dex, :dexterity
        flow.add attr_label :con, :constitution
        flow.add attr_label :int, :intelligence
        flow.add attr_label :wis, :wisdom
        flow.add attr_label :cha, :charisma
      }
      box.add Gtk::FlowBox.new.tap { |flow|
        flow.set_visible true
        flow.add field_label :ac, :armor_class
        flow.add field_label nil, :armor_desc
      }
    end
    add_section 'Extended stats' do |box|
      box.add Gtk::FlowBox.new.tap { |flow|
        flow.set_visible true
        flow.add field_label :size
        flow.add field_label :type
        flow.add field_label :subtype
        flow.add field_label :group
        flow.add field_label :alignment
      }
      box.add label 'Saves'
      box.add Gtk::FlowBox.new.tap { |flow|
        flow.set_visible true
        flow.add attr_label :str, :strength_save
        flow.add attr_label :dex, :dexterity_save
        flow.add attr_label :con, :constitution_save
        flow.add attr_label :int, :intelligence_save
        flow.add attr_label :wis, :wisdom_save
        flow.add attr_label :cha, :charisma_save
      }
      box.add label 'Speed'
      box.add Gtk::FlowBox.new.tap { |flow|
        flow.set_visible true
        flow.add field_label :walk, :speed, :walk
        flow.add field_label :fly, :speed, :fly
        flow.add field_label :swim, :speed, :swim
      }
      box.add field_label 'Senses', :senses, wrap: true
      box.add field_label 'Languages', :languages, wrap: true
      box.add field_label 'Damage vulnerabilities', :damage_vulnerabilities, wrap: true
      box.add field_label 'Damage resistances', :damage_resistances, wrap: true
      box.add field_label 'Damage immunities', :damage_immunities, wrap: true
      box.add field_label 'Condition immunities', :condition_immunities, wrap: true
    end
  end

  def attr_label lbl, *keys
    val = @monster.dig *keys.map(&:to_s)
    markup = colored 'gray', lbl
    markup += " #{val} (#{((val - 10) / 2).floor})" if val
    label markup
  end

  def field_label lbl, *keys, **opts
    keys = [lbl] if keys.empty?
    val = @monster.dig *keys.map(&:to_s)
    markup = "#{colored 'gray', lbl} #{val || '-'}"
    label(markup).tap {|lbl|
      if opts[:wrap]
        lbl.set_line_wrap true
        lbl.set_xalign 0.0
      end
    }
  end

  def label markup=nil, &block
    Gtk::Label.new.tap { |lbl|
      markup.nil? ? yield(lbl) : lbl.set_markup(markup)
      lbl.set_visible true
    }
  end
end
