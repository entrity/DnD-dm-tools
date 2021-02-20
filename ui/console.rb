require_relative '../lib/roll'
require_relative './autocomplete'

module Commands
  def run_console_command widget
    Console.for_input_widget(widget).run_command
  end
  
  private

  class Console
    # Type should be :command or :console
    def self.create input_widget, output_widget
      @@dict ||= {}
      raise KeyError.new("Duplicate key") if @@dict.has_key? input_widget.name
      @@dict[input_widget.name] = self.new(input_widget, output_widget)
    end

    def self.for_input_widget widget
      @@dict.fetch widget.name
    end

    def self.init game
      @@game = game
      raise ArgumentError.new("Nil game") if @@game.nil?
    end

    attr_reader :input

    def run_command
      cmd = @input.text.strip
      history.push(cmd) unless history.last == cmd
      @input.set_text ''
      @output.buffer.insert_at_cursor "%s\n" % cmd
      begin
        output = evaluate cmd
        @output.buffer.insert_at_cursor "=> #{output.inspect}\n"
      rescue => ex
        puts ex.backtrace, ex.inspect
        @output.buffer.insert_at_cursor "#{ex.inspect}\n"
      end
      @output.scroll_to_iter @output.buffer.end_iter, 0.0, true, 0.5, 0.5
      vadj = @scroller.vadjustment
      vadj.set_value vadj.upper
    end

    private

    def initialize input_widget, output_widget
      @input = input_widget
      @output = output_widget
      @scroller = @output.parent.parent
      MyAutocomplete.add @input
    end

    def evaluate cmd
      @@game.send :eval, cmd
    end

    def history
      @@game.console_histories[@input.name] ||= []
    end
  end

  class DiceConsole < Console
    def evaluate cmd
      updated_command = Roll.translate_command(cmd)
      @output.buffer.insert_at_cursor "#{updated_command}\n"
      super updated_command
    end
  end
end
