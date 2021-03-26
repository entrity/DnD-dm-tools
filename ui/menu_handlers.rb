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

  def roll_trinket
    trinket = Table['trinkets.tsv'].roll[1]
    puts "%s %s" % [gray('Trinket'), yellow(trinket)]
  end

  def toggle_terrain widget
    $stderr.puts widget.inspect
  end
end
