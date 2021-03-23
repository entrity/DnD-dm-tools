require 'csv'

class Table < Array
  def self.[](fname)
    @tables ||= {}
    @tables[fname] ||= load_table(fname)
  end

  def self.load_table(fname)
    new CSV.read File.join('tables', fname), col_sep: "\t", liberal_parsing: true
  end

  def roll
    self[rand(length)]
  end
end
