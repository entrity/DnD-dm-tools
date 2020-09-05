class Roll
  # Critical success/failure colours
  COLORS = {20 => 32, 1 => 31}

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
