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
    # Override add to troubleshoot if there's a bad add
    @widget.define_singleton_method(:add) {|child|
      require 'pry'; binding.pry unless child.is_a?(row_klass)
      super child
    }
    reload
  end

  def add character
    unless character.nil? || @members[character]
      game_members << character
      @members[character] = true
      reload
    end
  end

  def copy character
    add character&.dup
  end

  def children; @widget.children; end

  def highlight_row idx
    if row = @widget.children[idx]
      @widget.select_row row
    end
  end

  def redraw
    @widget.children.each {|c| c.reset_name_text }
  end

  def reload
    children.each {|child| @widget.remove(child) }
    game_members.each {|c| @widget.add @row_klass.new(c) }
    @widget.invalidate_sort
  end

  def remove character
    game_members.delete character
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

  def game_members
    @game_members.is_a?(Proc) ? @game_members.call : @game_members
  end
end


class AbstractCharacterRow < Gtk::ListBoxRow
  include Markup

  attr_reader :character, :label

  def reset_name_text
    @name_label.set_markup build_name_text
  end

  protected

  def build_name_text
    ctrl = character.is_pc ? green('P') : red('N')
    "%s %s" % [ctrl, colored_character(@character, true)]
  end
end
