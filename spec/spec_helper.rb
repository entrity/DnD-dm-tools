Dir['./lib/*.rb'].each do |fpath|
  require fpath
end

require './main.rb'

load_monsters
