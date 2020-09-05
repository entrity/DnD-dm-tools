class Roll
  # Critical success/failure colours
  COLORS = {20 => 32, 1 => 31}

  def initialize command
    @command = command
  end

  def to_s
    color_string, white_string = parse_string
    "#{eval white_string} = #{color_string}"
  end

  private

  def parse_string
    in_quote = nil
    color_string = @command.scan(/\\"|"|'|\s+|\$\w+|@\w+|\w+|\W/).map do |token|
      if in_quote # Don't evaluate rolls in quoted strings
        in_quote = nil if in_quote == token
        token
      elsif mat = token.match(/^(\d*)?d(\d+)$/)
        roll_dice(*mat.captures.map(&:to_i)).join(' + ')
      else # todo: should consider #{} interpolations
        in_quote = token if token =~ /^("|')$/
        token
      end
    end.join
    white_string = color_string.gsub(/\033\[\d+m/, '')
    [color_string, white_string]
  end

    def roll_dice n, d
    (0...[n,1].max).map do
      value = 1 + rand(d)
      color = d == 20 ? COLORS.fetch(value, 33) : 0
      "\033[#{color}m#{value}\033[0m"
    end
  end
end
