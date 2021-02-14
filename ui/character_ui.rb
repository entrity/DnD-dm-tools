class CharacterUI
  def initialize character
    @character = character
  end

  def stats_markup
    hp = @character['hit_points']
    hp = bold colored(hp_color(hp), hp)
    <<~EOF
    hp #{hp} \
    str #{attr :strength} \
    dex #{attr :dexterity} \
    con int wis cha
    saves: str dex con int wis cha
    perception:
    speed: walk() fly() swim()
    senses: 
    languages: 
    EOF
  end

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

  def hp_color hp
    if hp <= 0
      'red'
    elsif hp <= 5
      'yellow'
    else
      'green'
    end
  end
end
