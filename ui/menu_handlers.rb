require_relative '../lib/roll'
require_relative '../lib/table'
require_relative './markup'

module MenuHandlers
  include Markup

  def roll_camping_event
    puts case rand(12)
    when 1
      case rand(100)
      when 0;      red "DEADLY encounter"
      when 1..20;  red "HARD encounter"
      when 21..49; red "MEDIUM encounter"
      else;        red "EASY encounter"
      end
    when 2..3; yellow Table['camping-events.tsv'].roll[0]
    else; green "Peaceful night"
    end
  end

  def roll_inn_event
    puts case rand(12)
    when 1..2; yellow Table['inn-events.tsv'].roll
    else; green "Peaceful night"
    end
  end

  def roll_rumour
    Table['rumours.tsv'].roll
  end

  def roll_travel_event
    puts case rand(8)
    when 1
      case rand(100)
      when 0;      red "DEADLY encounter"
      when 1..20;  red "HARD encounter"
      when 21..49; red "MEDIUM encounter"
      else;        red "EASY encounter"
      end
    when 2..3; yellow Table['travel-events.tsv'].roll[0]
    else; green "Peaceful travel"
    end
  end

  def roll_treasure trigger_widget
    label = trigger_widget.label
    if matched = trigger_widget.label.match(/\d+/)
      if label =~ /Hoard/
        bounty = Treasure.hoard matched[0].to_i
      elsif label =~ /Individual/
        bounty = Treasure.individual matched[0].to_i
      end
      puts gray("Treasure:")
      puts yellow("cp %d" % bounty.cp) if bounty.cp
      puts yellow("sp %d" % bounty.sp) if bounty.sp
      puts yellow("ep %d" % bounty.ep) if bounty.ep
      puts yellow("gp %d" % bounty.gp) if bounty.gp
      puts yellow("pp %d" % bounty.pp) if bounty.pp
      puts orange(bounty.items) if bounty.items
      puts purple(bounty.magic_items) if bounty.magic_items
    end
  end

  def roll_trinket
    trinket = Table['trinkets.tsv'].roll[1]
    puts "%s %s" % [gray('Trinket'), yellow(trinket)]
  end

  def toggle_terrain widget
    $stderr.puts widget.inspect
  end
end
