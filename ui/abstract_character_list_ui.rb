require 'gtk3'
require 'singleton'
require_relative 'markup'

class AbstractCharacterListUI
  extend Forwardable
  include Singleton

  def_delegators :'Game.instance.encounter', :include?

  def init widget, game_members, row_klass
    @widget = widget
    @game_members = game_members
    @row_klass = row_klass
    reload
  end

  def add character
    unless character.nil? || @members[character]
      @game_members << character
      @members[character] = true
      reload
    end
  end

  def children; @widget.children; end

  def reload
    children.each {|child| @widget.remove(child) }
    @game_members.each {|c| @widget.add @row_klass.new(c) }
    @widget.invalidate_sort
  end

  def remove character
    @game_members.delete character
    @members.delete character
    reload
  end

  # Load central pane with CharacterView
  def show_character character
    # todo
  end

  private

  def initialize
    @members = {} # A dict mapping character to `true`
  end
end


class AbstractCharacterRow < Gtk::ListBoxRow
  include Markup

  attr_reader :character, :label

  def reset_name_text
    @name_label.set_markup build_name_text
  end

  private

  def build_name_text
    ctrl = character.is_pc ? green('P') : red('N')
    "%s %s" % [ctrl, colored_character(@character, true)]
  end
end
