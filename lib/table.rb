require 'csv'

class Table
  def self.[](fname)
    @tables ||= {}
    @tables[fname] ||= load_table(fname)
  end

  def self.load_table(fname)
    CSV.read File.join('tables', fname), col_sep: "\t"
  end
end
