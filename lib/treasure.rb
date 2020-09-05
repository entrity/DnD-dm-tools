require './lib/roll'

module Treasure

  def self.roll text
    Roll.new(text).to_s
  end

  def self.individual cr
    d100 = 1 + rand(100)
    case cr
    when 0..4
      case d100
      when 1..30;   puts "#{roll '5d6'} CP"
      when 31..60;  puts "#{roll '4d6'} SP"
      when 61..70;  puts "#{roll '3d6'} EP"
      when 71..95;  puts "#{roll '3d6'} GP"
      when 96..100; puts "#{roll '1d6'} PP"
      end
    when 5..10
      case d100
      when 1..30;   puts "#{roll '4d6 * 100'} CP #{roll '1d6 * 10'} EP"
      when 31..60;  puts "#{roll '6d6 * 10'} SP #{roll '2d6 * 10'} GP"
      when 61..70;  puts "#{roll '3d6 * 10'} EP #{roll '2d6 * 10'} GP"
      when 71..95;  puts "#{roll '4d6 * 10'} GP"
      when 96..100; puts "#{roll '2d6 * 10'} GP #{roll '3d6'} PP"
      end
    when 11..16
      case d100
      when 1..20;   puts "#{roll '4d6 * 100'} SP #{roll '1d6 * 100'} EP"
      when 21..35;  puts "#{roll '1d6 * 100'} EP #{roll '1d6 * 100'} GP"
      when 36..75;  puts "#{roll '2d6 * 100'} GP #{roll '1d6 * 10'} PP"
      when 76..100;  puts "#{roll '2d6 * 100'} GP #{roll '2d6 * 10'} PP"
      end
    else
      case d100
      when 1..15;   puts "#{roll '2d6 * 1000'} EP #{roll '8d6 * 100'} GP"
      when 16..55;  puts "#{roll '1d6 * 1000'} GP #{roll '1d6 * 100'} PP"
      when 56..100;  puts "#{roll '1d6 * 1000'} GP #{roll '2d6 * 100'} PP"
      end
    end
  end

  def self.hoard cr
    d100 = 1 + rand(100)
    treasure =
    if cr < 5
      puts [roll('6d6*100'), 'CP', roll('3d6*100'), 'SP', roll('2d6*10'), 'GP'].join ' '
      case d100
      when 1..6;   ['no gems', 'no items']
      when 7..16;  [roll('2d6'), '10 gp gems']
      when 17..26; [roll('2d4'), '25 gp art objects']
      when 27..36; [roll('2d6'), '50 gp gems']
      when 37..44; [roll('2d6'), '10 gp gems', magic_items('a', '1d6')]
      when 45..52; [roll('2d4'), '25 gp art object', magic_items('a', '1d6')]
      when 53..60; [roll('2d6'), '50 gp gems', magic_items('a', '1d6')]
      when 61..65; [roll('2d6'), '10 gp gems', magic_items('b', '1d4')]
      when 66..70; [roll('2d4'), '25 gp art objects', magic_items('b', '1d4')]
      when 71..75; [roll('2d6'), '50 gp gems', magic_items('b', '1d4')]
      when 76..78; [roll('2d6'), '10 gp gems', magic_items('c', '1d4')]
      when 79..80; [roll('2d4'), '25 gp art objects', magic_items('c', '1d4')]
      when 81..85; [roll('2d6'), '50 gp gems', magic_items('c', '1d4')]
      when 86..92; [roll('2d4'), '25 gp art objects', magic_items('f', '1d4')]
      when 91..97; [roll('2d6'), '50 gp gems', magic_items('f', '1d4')]
      when 98..99; [roll('2d4'), '25 gp art objects', magic_items('g')]
      when 100;    [roll('2d6'), '50 gp gems', magic_items('g')]
      end
    elsif cr < 11
      puts [roll('2d6*100'), 'CP', roll('2d6*1000'), 'SP', roll('6d6*100'), 'GP', roll('3d6*10'), 'PP'].join ' '
      if d100 <= 4    ; []
      elsif d100 <= 10; [roll('2d4'), '25  gp art objects']
      elsif d100 <= 16; [roll('3d6'), '50  gp gems']
      elsif d100 <= 22; [roll('3d6'), '100 gp gems']
      elsif d100 <= 28; [roll('2d4'), '250 gp art objects']
      elsif d100 <= 32; [roll('2d4'), '25  gp art objects', magic_items('a', '1d6')]
      elsif d100 <= 36; [roll('3d6'), '50  gp gems', magic_items('a', '1d6')]
      elsif d100 <= 40; [roll('3d6'), '100 gp gems', magic_items('a', '1d6')]
      elsif d100 <= 44; [roll('2d4'), '250 gp art objects', magic_items('a', '1d6')]
      elsif d100 <= 49; [roll('2d4'), '25  gp art objects', magic_items('b', '1d4')]
      elsif d100 <= 54; [roll('3d6'), '50  gp gems', magic_items('b', '1d4')]
      elsif d100 <= 59; [roll('3d6'), '100 gp gems', magic_items('b', '1d4')]
      elsif d100 <= 63; [roll('2d4'), '250 gp art objects', magic_items('b', '1d4')]
      elsif d100 <= 66; [roll('2d4'), '25  gp art objects', magic_items('c', '1d4')]
      elsif d100 <= 69; [roll('3d6'), '50  gp gems', magic_items('c', '1d4')]
      elsif d100 <= 72; [roll('3d6'), '100 gp gems', magic_items('c', '1d4')]
      elsif d100 <= 74; [roll('2d4'), '250 gp art objects', magic_items('c', '1d4')]
      elsif d100 <= 76; [roll('2d4'), '25  gp art objects', magic_items('d', '1')]
      elsif d100 <= 78; [roll('3d6'), '50  gp gems', magic_items('d', '1')]
      elsif d100 <= 79; [roll('3d6'), '100 gp gems', magic_items('d', '1')]
      elsif d100 <= 80; [roll('2d4'), '250 gp art objects', magic_items('d', '1')]
      elsif d100 <= 84; [roll('2d4'), '25  gp art objects', magic_items('f', '1d4')]
      elsif d100 <= 88; [roll('3d6'), '50  gp gems', magic_items('f', '1d4')]
      elsif d100 <= 91; [roll('3d6'), '100 gp gems', magic_items('f', '1d4')]
      elsif d100 <= 94; [roll('2d4'), '250 gp art objects', magic_items('f', '1d4')]
      elsif d100 <= 96; [roll('3d6'), '100 gp gems', magic_items('g', '1d4')]
      elsif d100 <= 98; [roll('2d4'), '250 gp art objects', magic_items('g', '1d4')]
      elsif d100 <= 99; [roll('3d6'), '100 gp gems', magic_items('h', '1')]
      else            ; [roll('2d4'), '250 gp art objects', magic_items('h', '1')]
      end
    elsif cr < 17
      puts [roll('4d6*1000'), 'GP', roll('5d6*100'), 'PP'].join ' '
      if d100 <= 3;     []
      elsif d100 <= 6;  [roll('2d4'), '250  gp art objects']
      elsif d100 <= 9;  [roll('2d4'), '750  gp art objects']
      elsif d100 <= 12; [roll('3d6'), '500  gp gems']
      elsif d100 <= 15; [roll('3d6'), '1000 gp gems']
      elsif d100 <= 19; [roll('2d4'), '250  gp art objects', magic_items('a', '1d4'), magic_items('b', '1d6')]
      elsif d100 <= 23; [roll('2d4'), '750  gp art objects', magic_items('a', '1d4'), magic_items('b', '1d6')]
      elsif d100 <= 26; [roll('3d6'), '500  gp gems', magic_items('a', '1d4'), magic_items('b', '1d6')]
      elsif d100 <= 29; [roll('3d6'), '1000 gp gems', magic_items('a', '1d4'), magic_items('b', '1d6')]
      elsif d100 <= 35; [roll('2d4'), '250  gp art objects', magic_items('c', '1d6')]
      elsif d100 <= 40; [roll('2d4'), '750  gp art objects', magic_items('c', '1d6')]
      elsif d100 <= 45; [roll('3d6'), '500  gp gems', magic_items('c', '1d6')]
      elsif d100 <= 50; [roll('3d6'), '1000 gp gems', magic_items('c', '1d6')]
      elsif d100 <= 54; [roll('2d4'), '250  gp art objects', magic_items('d', '1d4')]
      elsif d100 <= 58; [roll('2d4'), '750  gp art objects', magic_items('d', '1d4')]
      elsif d100 <= 62; [roll('3d6'), '500  gp gems', magic_items('d', '1d4')]
      elsif d100 <= 66; [roll('3d6'), '1000 gp gems', magic_items('d', '1d4')]
      elsif d100 <= 68; [roll('2d4'), '250  gp art objects', magic_items('e', '1')]
      elsif d100 <= 70; [roll('2d4'), '750  gp art objects', magic_items('e', '1')]
      elsif d100 <= 72; [roll('3d6'), '500  gp gems', magic_items('e', '1')]
      elsif d100 <= 74; [roll('3d6'), '1000 gp gems', magic_items('e', '1')]
      elsif d100 <= 76; [roll('2d4'), '250  gp art objects', magic_items('f', '1'), magic_items('g', '1d4')]
      elsif d100 <= 78; [roll('2d4'), '750  gp art objects', magic_items('f', '1'), magic_items('g', '1d4')]
      elsif d100 <= 80; [roll('3d6'), '500  gp gems', magic_items('f', '1'), magic_items('g', '1d4')]
      elsif d100 <= 82; [roll('3d6'), '1000 gp gems', magic_items('f', '1'), magic_items('g', '1d4')]
      elsif d100 <= 85; [roll('2d4'), '250  gp art objects', magic_items('h', '1d4')]
      elsif d100 <= 88; [roll('2d4'), '750  gp art objects', magic_items('h', '1d4')]
      elsif d100 <= 90; [roll('3d6'), '500  gp gems', magic_items('h', '1d4')]
      elsif d100 <= 92; [roll('3d6'), '1000 gp gems', magic_items('h', '1d4')]
      elsif d100 <= 94; [roll('2d4'), '250  gp art objects', magic_items('i')]
      elsif d100 <= 96; [roll('2d4'), '750  gp art objects', magic_items('i')]
      elsif d100 <= 98; [roll('3d6'), '500  gp gems', magic_items('i')]
      else            ; [roll('3d6'), '1000 gp gems', magic_items('i')]
      end
    else
      puts [roll('12d6*1000'), 'GP', roll('8d6*100'), 'PP'].join ' '
      if d100 <= 2    ; []
      elsif d100 <= 5;  [roll('3d6'), '1000 gp gems', magic_items('c', '1d8')]
      elsif d100 <= 8;  [roll('1d10'), '2500 gp art objects', magic_items('c', '1d8')]
      elsif d100 <= 11; [roll('1d4'), '7500 gp art objects', magic_items('c', '1d8')]
      elsif d100 <= 14; [roll('1d8'), '5000 gp gems', magic_items('c', '1d8')]
      elsif d100 <= 22; [roll('3d6'), '1000 gp gems', magic_items('d', '1d6')]
      elsif d100 <= 30; [roll('1d10'), '2500 gp art objects', magic_items('d', '1d6')]
      elsif d100 <= 38; [roll('1d4'), '7500 gp art objects', magic_items('d', '1d6')]
      elsif d100 <= 46; [roll('1d8'), '5000 gp gems', magic_items('d', '1d6')]
      elsif d100 <= 52; [roll('3d6'), '1000 gp gems', magic_items('e', '1d6')]
      elsif d100 <= 58; [roll('1d10'), '2500 gp art objects', magic_items('e', '1d6')]
      elsif d100 <= 63; [roll('1d4'), '7500 gp art objects', magic_items('e', '1d6')]
      elsif d100 <= 68; [roll('1d8'), '5000 gp gems', magic_items('e', '1d6')]
      elsif d100 <= 69; [roll('3d6'), '1000 gp gems', magic_items('g', '1d4')]
      elsif d100 <= 70; [roll('1d10'), '2500 gp art objects', magic_items('g', '1d4')]
      elsif d100 <= 71; [roll('1d4'), '7500 gp art objects', magic_items('g', '1d4')]
      elsif d100 <= 72; [roll('1d8'), '5000 gp gems', magic_items('g', '1d4')]
      elsif d100 <= 74; [roll('3d6'), '1000 gp gems', magic_items('h', '1d4')]
      elsif d100 <= 76; [roll('1d10'), '2500 gp art objects', magic_items('h', '1d4')]
      elsif d100 <= 78; [roll('1d4'), '7500 gp art objects', magic_items('h', '1d4')]
      elsif d100 <= 80; [roll('1d8'), '5000 gp gems', magic_items('h', '1d4')]
      elsif d100 <= 85; [roll('3d6'), '1000 gp gems', magic_items('i', '1d4')]
      elsif d100 <= 90; [roll('1d10'), '2500 gp art objects', magic_items('i', '1d4')]
      elsif d100 <= 95; [roll('1d4'), '7500 gp art objects', magic_items('i', '1d4')]
      else            ; [roll('1d8'), '5000 gp gems', magic_items('i', '1d4')]
      end
    end
    puts treasure&.join(" ")
  end

  def self.magic_items table_name, qty_cmd='1'
    qty = Roll.new(qty_cmd).value
    puts "Magic items:"
    (1..qty).each do |i|
      table_index = Roll.new('1d100').value
      puts MAGIC_ITEMS_TABLES[table_name][table_index]
    end
  end

  # Called only during startup
  def self.load_magic_items_table table_name
    lines = File.read("data/magic-items-table-#{table_name}.tsv").split("\n")
    lines.reduce([nil] * 100) do |acc, line|
      range, item = line.split(/\s*\t/)
      a, z = range.split('-').map(&:to_i)
      z ||= a
      (a..z).each {|i| acc[i] = item }
      acc
    end
  end

  MAGIC_ITEMS_TABLES = ('a'..'g').map { |key|
    [key, load_magic_items_table(key)]
  }.to_h
end
