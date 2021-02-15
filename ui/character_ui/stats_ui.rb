require 'gtk3'

class StatsUI < Gtk::Box
  def initialize character
    super(:vertical)
    @character = character
    add label 'Saves'
    add Gtk::FlowBox.new.tap { |box|
      box.set_visible true
      box.add attr_label :str, :strength_save
      box.add attr_label :dex, :dexterity_save
      box.add attr_label :con, :constitution_save
      box.add attr_label :int, :intelligence_save
      box.add attr_label :wis, :wisdom_save
      box.add attr_label :cha, :charisma_save
    }
    set_visible true
  end

  #   perception:
  #   speed: walk() fly() swim()
  #   senses: 
  #   languages: 


  private


  def attr *keys
    text = @character.dig *keys.map(&:to_s)
    return if text.nil? || text.respond_to?(:empty?) && text.empty?
    modifier = ((text.to_i - 10) / 2).floor
    "#{text} (#{bold modifier})"
  end

  def bold text
    "<b>#{text}</b>"
  end

  def colored color, text
    "<span foreground=\"#{color}\">#{text}</span>"
  end

  def hp_markup
    hp = @character['hit_points']
    color = if hp <= 0
      'red'
    elsif hp <= 5
      'yellow'
    else
      'green'
    end
    "#{colored 'gray', 'hp'} #{bold colored(color, hp)}"
  end
end
