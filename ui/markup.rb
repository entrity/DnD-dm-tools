require 'gtk3'

module Markup

  private

  def big text
    markedup :big, text
  end

  def bold text
    markedup :b, text
  end

  def colored_character character, append_klass=false
    code = character.is_a?(Monster) ? '#ddaadd' : '#aaeeaa'
    colored = color code, @character.name
    if @character.name != @character.klass && @character.klass.presence
      "%s (%s)" % [colored, @character.klass]
    else
      colored
    end
  end

  def color val, text
    markedup :span, text, foreground: val
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

  def markedup tag, content, attributes={}
    attr_str = attributes.map {|k,v| %Q{#{k}="#{v}"} }.join ' '
    %Q{<#{tag} #{attr_str}>#{content}</#{tag}>}
  end

  def signed val
    return nil if val.nil?
    prefix = val >= 0 ? '+' : ''
    prefix + val.to_s
  end

  def underline text
    markedup :u, text
  end

  def gray text; color 'gray', text; end
  def green text; color 'green', text; end
  def red text; color 'red', text; end
  def yellow text; color 'yellow', text; end
end
