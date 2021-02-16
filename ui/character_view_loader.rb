# View character in centre pane
class CharacterViewLoader
  def initialize builder, character
    @builder = builder
    @character = character
    set 'char-view name', color(character_color, character.name)
    set 'char-view stats', stats_markup
  end

  private

  def bold text
    %Q{<b>#{text}</b>}
  end
  def color val, text
    %Q{<span color="#{val}">#{text}</span>}
  end
  def character_color
    is_player? ? '#aaeeaa' : '#ddaadd'
  end
  def is_player?
    !@character.is_a? Monster
  end
  def set id, markup
    @builder.get_object(id).set_markup markup
  end
  def stats_markup
    
  end
end