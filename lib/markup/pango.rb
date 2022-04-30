require 'gtk3'

module Markup::Pango

  def self.insert textbuffer, text, **tags
    start, finish = textbuffer.get_selection_bounds()
    tags.each do |tag|
      textbuffer.apply_tag(tag, start, finish)
    end
  end

  def self.bold textbuffer, text
    @@tag_bold ||= self.textbuffer.create_tag("bold", weight: Pango.Weight.BOLD)
    insert textbuffer, text, @@tag_bold
  end

  def self.cyan textbuffer, text
    text
  end

  def self.faint textbuffer, text
    text
  end

  def self.h1 textbuffer, text
    text
  end

  def self.red textbuffer, text
    text
  end

  def self.underline textbuffer, text
    text
  end

  def self.yellow textbuffer, text
    text
  end
end
