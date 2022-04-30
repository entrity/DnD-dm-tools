Dir['./lib/*.rb'].each do |fpath|
  require fpath
end
Dir['./lib/*/*.rb'].each do |fpath|
  require fpath
end

require './main.rb'

def strip_ansi text_w_ansi_codes
  text_w_ansi_codes.to_s.gsub(/\e\[([;\d]+)?m/, '')
end
