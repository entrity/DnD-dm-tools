require 'gtk3'

module Markup

  # private


  # def attr *keys
  #   text = @character.dig *keys.map(&:to_s)
  #   return if text.nil? || text.respond_to?(:empty?) && text.empty?
  #   modifier = ((text.to_i - 10) / 2).floor
  #   "#{text} (#{bold modifier})"
  # end

  private

  def bold text
    %Q{<b>#{text}</b>}
  end

  def character_color
    is_player? ? '#aaeeaa' : '#ddaadd'
  end

  def color val, text
    %Q{<span foreground="#{val}">#{text}</span>}
  end

  def colored_hp
    hp = @character.hp.to_i
    if hp <= 0
      red hp
    elsif hp <= 7
      yellow hp
    else
      green hp
    end
  end

  def gray text; color 'gray', text; end
  def green text; color 'green', text; end
  def red text; color 'red', text; end
  def yellow text; color 'yellow', text; end
end
