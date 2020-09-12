require 'pry'
require './lib/encounter'
require './lib/roll'
require './lib/characters'
require './lib/monster_library'

class Game
  attr_reader :party
  alias :pcs :party

  def initialize fpath
    @fpath = fpath # Attr overwritten if file exists s.t. file is not overwritten
    @notes ||= []
    @party = {}
    @terrain = nil
  end

  # CRs for current party for all difficulties
  def crs_for_party
    Encounter.crs_for_party(@party)
  end

  # Save state to file
  def dump
    File.write @fpath, Marshal.dump(self)
  end

  # Start a random encounter
  def encounter difficulty, terrain=nil
    terrain ||= @terrain
    $encounter = Encounter.random @party, difficulty, terrain
  end

  def increment_fpath
    if File.exists?(@fpath)
      split = @fpath.match(/(.*?)(\d+$)/)
      stem = split&.[](1) || @fpath
      number = 1 + split&.[](2).to_i
      @fpath = "#{stem}#{number}"
    end
  end

  def monsters *fields, **search
    selection = $monsters.list
    sort_key = search.delete(:sort)&.to_s
    unless search.empty?
      selection = selection.select {|m| search.all? {|k,v| m[k.to_s] == v } }
    end
    unless sort_key.nil?
      selection = selection.sort {|a,b|
        va, vb = [a,b].map { |x|
          # Handle CR, which is stored as a string, e.g. "1/8"
          x[sort_key].to_s =~ /^\d$|^\d.*\d$/ ? eval(x[sort_key]) : x[sort_key]
        }
        va <=> vb
      }
    end
    unless fields.empty?
      selection = selection.map {|m| m.values_at *fields.map(&:to_s) }
    end
    selection
  end

  def note text; @notes << text; end

  # Roll
  def r command=nil
    command = gets if command.nil?
    puts Roll.new(command).to_s
  end

  def start
    binding.pry # Run `ls` for common commands
  end

  # Display array of arrays as a table
  def table data
    n_cols = data&.first&.length.to_i
    n_rows = data&.length.to_i
    col_lens = (0...n_cols).map {|i| data.map {|r| r[i].to_s.length }.max }
    data.each do |row|
      strings = row.map.with_index { |col, i| "%#{col_lens[i]}s" % col }
      puts strings.join(" | ")
    end
    nil
  end
end
