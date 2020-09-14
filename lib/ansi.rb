module Ansi
  RESET             = 0
  BOLD              = 1
  FAINT             = 2
  ITALIC            = 3
  UNDERLINE         = 4
  STRIKETHROUGH     = 9
  DBL_UNDERLINE     = 21
  BOLD_OFF          = 22
  ITALIC_OFF        = 23
  UNDERLINE_OFF     = 24
  STRIKETHROUGH_OFF = 29
  # Colours
  BLACK      = 30
  RED        = 31
  BREEN      = 32
  YELLOW     = 33
  BLUE       = 34
  MAGENTA    = 35
  CYAN       = 36
  WHITE      = 37
  FG_RESET   = 39
  BG_BLACK   = 40
  BG_RED     = 41
  BG_BREEN   = 42
  BG_YELLOW  = 43
  BG_BLUE    = 44
  BG_MAGENTA = 45
  BG_CYAN    = 46
  BG_WHITE   = 47
  BG_RESET   = 49

  def self.fmt *values
    "\033[#{ values.join(';') }m"
  end

  def self.faint text
    [fmt(FAINT), text, fmt(BOLD_OFF)].join
  end

  def self.bold text
    [fmt(BOLD), text, fmt(BOLD_OFF)].join
  end

  def self.cyan text
    [fmt(CYAN), text, fmt(FG_RESET)].join
  end

  def self.yellow text
    [fmt(YELLOW), text, fmt(FG_RESET)].join
  end

  def self.red text
    [fmt(RED), text, fmt(FG_RESET)].join
  end

  def self.underline text
    [fmt(UNDERLINE), text, fmt(UNDERLINE_OFF)].join
  end
end
