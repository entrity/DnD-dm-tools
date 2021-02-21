require "gtk3"

module MyAutocomplete
  # Add autocomplete to a Gtk::Entry object
  def self.add entry, &block
    model = Gtk::ListStore.new String
    model.append.set_value 0, 'sd'
    model.append.set_value 0, 'foo'
    model.append.set_value 0, 'six'
    completion = Gtk::EntryCompletion.new
    completion.set_minimum_key_length 0
    completion.set_text_column 0
    completion.set_inline_completion true
    completion.set_model model
    completion.set_match_func do |*args|
      self.match_func *args
    end
    yield(model, completion) if block_given?
    entry.set_completion completion   
  end
  
  def self.match_func(entry_completion, entry_value, list_obj)
    len = 0 # Counts characters into the entry text
    cursor = entry_completion.entry.position
    entry_text = entry_completion.entry.text
    entry_tokens = entry_text.scan(/[\w+@]+|[^\w@]+/)
    current_token = entry_tokens.find { |tok|
      (len += tok.length) >= cursor && tok =~ /\w/
    }
    obj_text = list_obj.get_value(0)
    return current_token && obj_text.start_with?(current_token)
  end
end
