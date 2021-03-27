module StringOps

  def self.last_token text
    text.match(/(\w+)$/)&.[](1)
  end

  def self.last_word text
    text.match(/([.\w]+)$/)&.[](1)
  end

  # Split string into [pre, token, post]
  def self.split3 text, cursor
    pre = text[0...cursor].match(/(.*?)(\W+)?(\w+)?$/).captures
    post = text[cursor..-1].match(/(\w+)?(\W+)?(.*)$/).captures
    token = [pre.pop, post.shift].join
    return pre.join, token, post.join
  end

  def self.token_up_to_cursor entry
    last_token entry.text[0..entry.position]
  end

  def self.word_up_to_cursor entry
    last_word entry.text[0..entry.position]
  end
end
