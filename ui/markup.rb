require 'gtk3'

module Markup

  # private


  # def attr *keys
  #   text = @character.dig *keys.map(&:to_s)
  #   return if text.nil? || text.respond_to?(:empty?) && text.empty?
  #   modifier = ((text.to_i - 10) / 2).floor
  #   "#{text} (#{bold modifier})"
  # end

  def bold text
    "<b>#{text}</b>"
  end

  def colored color, text
    "<span foreground=\"#{color}\">#{text}</span>"
  end

  def hp_markup hp
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
