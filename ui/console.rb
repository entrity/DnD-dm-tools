require_relative '../lib/roll'
require_relative './autocomplete'  

class Console
  @@dict = {}

  # Type should be :command or :console
  def self.create input_widget, output_widget
    raise KeyError.new("Duplicate key") if @@dict.has_key? input_widget.name
    @@dict[input_widget.name] = self.new(input_widget, output_widget)
  end

  def self.for_input_widget widget
    @@dict.fetch widget.name
  end

  def self.init game
    raise ArgumentError.new("Nil game") if Game.instance.nil?
  end

  attr_reader :input

  def history_visit inc
    @history_cursor ||= 0
    @history_cursor += inc
    @history_cursor = 0 if @history_cursor > 0
    return if @history_cursor == 0 || @history_cursor < history.length*-1
    if text = history[@history_cursor]
      @input.buffer.set_text text, text.length
    end
  end

  def run_command
    @history_cursor = 0
    cmd = @input.text.strip
    history.delete cmd
    history.push cmd
    @input.set_text ''
    append %Q{<span color="#aaa">%s</span>} % cmd unless cmd.strip.empty?
    begin
      append evaluate(cmd)
    rescue => ex
      puts ex.backtrace, ex.inspect
      append "#{ex.inspect}"
    end
  end

  private

  def initialize input_widget, output_widget
    @input = input_widget
    @output = output_widget
    @scroller = @output.parent
    # Auto-scroll to bottom
    @output.buffer.signal_connect("changed") {
      mark = @output.buffer.create_mark nil, @output.buffer.start_iter.forward_to_end, false
      @output.scroll_mark_onscreen mark
    }
    MyAutocomplete.add @input
  end

  def append markup
    @output.buffer.insert_markup @output.buffer.end_iter, "\n#{markup}", -1
  end

  def evaluate cmd
    if cmd == 'ls'
      params = [
        "METHODS", (Game.instance.public_methods-Object.methods).join(' '),
        "LOCALS", Game.instance.send(:local_variables).join(' '),
        "VARIABLES", Game.instance.instance_variables.join(' '),
      ]
      <<~EOF.strip % params
      <span font_family="monospace"><span color="#cc0">%-10s</span>> %s
      <span color="#cc0">%-10s</span>> %s
      <span color="#cc0">%-10s</span>> %s</span>
      EOF
    else
      output = Game.instance.send :eval, cmd
      markup = output.inspect.gsub /</, '&lt;'
      "=> %s" % markup
    end
  end

  def history
    Game.instance.console_histories[@input.name] ||= []
  end
end

class DiceConsole < Console
  def evaluate cmd
    updated_command = Roll.translate_command(cmd)
    if updated_command.strip != cmd.strip
      append updated_command
    end
    super updated_command
  end
end

module Console::Commands
  def run_console_command widget
    Console.for_input_widget(widget).run_command
  end

  def on_console_key_pressed widget, event
    case event.keyval
    when Gdk::Keyval::KEY_Up
      Console.for_input_widget(widget).history_visit(-1)
      return true
    when Gdk::Keyval::KEY_Down
      Console.for_input_widget(widget).history_visit(1)
      return true
    end
  end
end
