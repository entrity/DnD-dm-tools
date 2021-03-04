require 'gtk3'
require 'singleton'
require_relative 'markup'

class CastUI
  include Singleton

  @@builder = nil

  def self.init builder
    @@builder = builder
  end

  def add character
    game = Game.instance
    game.cast.push(character) unless game.cast.include?(character)
    reload
  end

  def children; widget.children; end

  def reload hard=false
    hard ? reload_hard : reload_soft
  end

  def remove character
    Game.instance.cast.delete character
    reload
  end

  def widget; @widget ||= @@builder.get_object('cast ListBox'); end

  private

  def initialize
    widget.set_sort_func {|a,b|
      if a.character.is_pc != b.character.is_pc
        a.character.is_pc ? -1 : 1
      else
        a.text <=> b.text
      end
    }
  end

  def reload_hard
    children.each {|child| widget.remove(child) }
    Game.instance.cast.each {|c| widget.add CastMemberRow.new(c) }
    widget.invalidate_sort
  end

  def reload_soft
    cast_hash = Game.instance.cast.map {|c| [c, nil] }.to_h
    children.each do |child|
      widget.remove(child) unless cast_hash.has_key?(child.character)
      cast_hash.delete(child.character)
    end
    cast_hash.each do |character, _|
      widget.add CastMemberRow.new(character)
    end
    widget.invalidate_sort
  end
end

class CastMemberRow < Gtk::ListBoxRow
  include Markup

  attr_reader :character, :label

  def initialize character
    super()
    set_visible true
    @character = character
    # Make event box
    evt_box = Gtk::EventBox.new
    evt_box.set_visible true
    add evt_box
    # Make label
    @label = Gtk::Label.new.tap do |label|
      label.set_markup text
      label.set_xalign 0.0
      label.set_visible true
      label.set_ellipsize Pango::EllipsizeMode::END
      evt_box.add label
    end
    # Add signals
    evt_box.signal_connect('button-press-event') do |widget|
      CharacterViewLoader.content_set character
    end
    signal_connect('focus-in-event') do |widget|
      CharacterViewLoader.content_set character
    end
  end

  def text
    @text ||= begin
      ctrl = character.is_pc ? green('P') : red('N')
      "%s %s" % [ctrl, colored_character(@character, true)]
    end
  end
end
