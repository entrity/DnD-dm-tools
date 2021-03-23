class Roll
  # Critical success/failure colours
  COLORS = {20 => 32, 1 => 31}

  def self.translate_command command
    tokens = command.scan(/\w+|\W+/)
    tokens.map { |tok|
      if matched = /(\d+)?d(\d+)(([adk])(\d)?)?/.match(tok)
        "(%s)" % translate_roll(matched)
      else
        tok
      end
    }.join('')
  end

  # Pass in a regex match for something like `2d10k2` or minimally `d20`
  def self.translate_roll regex_match_data
    n = [1, regex_match_data[1].to_i].max # How many dice
    d = regex_match_data[2].to_i # How many sides on die
    mode = regex_match_data[4] # Advantage/Disadvantage/Keep
    moded = regex_match_data[5].to_i # How many to Keep
    die_rolls = (0...n).map { 1 + rand(d) }
    case mode
    when nil
      die_rolls.join(" + ")
    when 'a' # Advantage
      "#{die_rolls.inspect}.max"
    when 'd' # Disadvantage
      "#{die_rolls.inspect}.min"
    when 'k' # Keep best
      "#{die_rolls.inspect}.max(#{moded})"
    end
  end

  attr_reader :value

  def initialize command
    @command = command
    @color_string, @white_string = parse_string
    @value = eval @white_string
  end

  def to_s
    "#{@value} = #{@color_string}"
  end

  private

  def parse_string
    in_quote = nil
    color_string = @command.scan(/\\"|"|'|\s+|\$\w+|@\w+|\w+|\W/).map do |token|
      if in_quote # Don't evaluate rolls in quoted strings
        in_quote = nil if in_quote == token
        token
      elsif mat = token.match(/^(\d*)?d(\d+)$/)
        roll_dice(*mat.captures.map(&:to_i))
      else # todo: should consider #{} interpolations
        in_quote = token if token =~ /^("|')$/
        token
      end
    end.join
    white_string = color_string.gsub(/\033\[\d+m/, '')
    [color_string, white_string]
  end

  def roll_dice n, d
    rolls = (0...[n,1].max).map do
      value = 1 + rand(d)
      color = d == 20 ? COLORS.fetch(value, 33) : 0
      "\033[#{color}m#{value}\033[0m"
    end.join(' + ')
    "(#{rolls})"
  end
end

def roll command=nil
  if command.nil?
    $stdout.write "Roll: "
    command = $stdin.gets
  end
  puts Roll.new(command).to_s
end
alias :r :roll
