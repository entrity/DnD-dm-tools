require "gtk3"
require_relative './util/string_ops'

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
    obj_text = list_obj.get_value(0)
    current_token_prefix = StringOps.token_up_to_cursor @entry
    return current_token_prefix && obj_text.start_with?(current_token_prefix)
  end

  def match_selected entry_completion, list_store, iter, user_data=nil
    selection = list_store.get_value iter, entry_completion.text_column
    pre, _, post = StringOps.split3 @entry.text, @entry.position
    entry_completion.entry.tap { |entry|
      entry.set_text [pre, selection, post].join
      entry.set_position [pre, selection].join.length
    }
    return true # Prevent default signal callback
  end
end
