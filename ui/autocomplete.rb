require "gtk3"

class MyAutocomplete
  def initialize entry, values
    @entry = entry
    @completion = Gtk::EntryCompletion.new
    @completion.set_minimum_key_length 0
    @completion.set_text_column 0
    @completion.set_inline_completion true
    @completion.signal_connect('match-selected') {|*args| match_selected *args }
    @completion.set_match_func {|*args| match_func *args }
    @completion.set_model Gtk::ListStore.new String
    values.each {|v| @completion.model.append.set_value 0, v.to_s }
    @entry.set_completion @completion
  end

  def match_func(entry_completion, entry_value, list_obj)
    _, current_token, _ = split
    obj_text = list_obj.get_value(0)
    return current_token&.length > 0 && obj_text.start_with?(current_token)
  end

  def match_selected entry_completion, list_store, iter, user_data=nil
    selection = list_store.get_value iter, entry_completion.text_column
    pre, _, post = split
    entry_completion.entry.set_text [pre, selection, post].join
    entry_completion.entry.set_position [pre, selection].join.length
    return true # Prevent default signal callback
  end

  private

  def split
    text = @entry.text
    pre = text[0...@entry.position].match(/(.*?)(\W+)?(\w+)?$/).captures
    post = text[@entry.position..-1].match(/(\w+)?(\W+)?(.*)$/).captures
    token = [pre.pop, post.shift].join
    return pre.join, token, post.join
  end
end
