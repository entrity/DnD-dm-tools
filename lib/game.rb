require 'pry'
require './lib/encounter'
require './lib/roll'

class Game
  def initialize fpath
    @fpath = fpath # Attr overwritten if file exists s.t. file is not overwritten
    @pcs = {}
  end

  def dump
    File.write @fpath, Marshal.dump(self)
  end

  def encounter difficulty, terrain
    Encounter.new difficulty, terrain, @pcs
  end

  def increment_fpath
    if File.exists?(@fpath)
      split = @fpath.match(/(.*?)(\d+$)/)
      stem = split&.[](1) || @fpath
      number = 1 + split&.[](2).to_i
      @fpath = "#{stem}#{number}"
    end
  end

  def note text
    @notes ||= []
    @notes << text
  end

  def start
    binding.pry
  end

  # Roll
  def r command=nil
    command = gets if command.nil?
    Roll.new(command).to_s
  end
end
