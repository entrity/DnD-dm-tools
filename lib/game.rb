require 'pry'
require './lib/encounter'

class Game
  def initialize fpath
    @fpath = fpath # Attr overwritten if file exists s.t. file is not overwritten
    @pcs = {}
  end

  def dump
    File.write @fpath, Marshal.dump(self)
  end

  def encounter

  end

  def increment_fpath
    if File.exists?(@fpath)
      split = @fpath.match(/(.*?)(\d+$)/)
      stem = split&.[](1) || @fpath
      number = 1 + split&.[](2).to_i
      @fpath = "#{stem}#{number}"
    end
  end

  def start
    binding.pry
  end
end
