module CharacterUI
  def character_stats_markup character
    hp = character['hit_points']
    hp = bold colored(hp_color(hp), hp)
    <<~EOF
    hp #{hp}
    str #{} dex con int wis cha
    saves: str dex con int wis cha
    perception:
    speed: walk() fly() swim()
    senses: 
    languages: 
    EOF
  end

  def attr text
    modifier = ((text.to_i - 10) / 2).floor
    "text (#{bold modifier})"
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
