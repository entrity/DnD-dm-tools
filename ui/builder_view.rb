require 'gtk3'

class BuilderView < Gtk::Box

  attr_reader :dict

  def initialize dict
    super :vertical
    @dict = dict
    @builder = Gtk::Builder.new(file: self.class::BUILDER_FILE)
    @viewport = obj('Viewport')
    add obj('top'), expand: true
    set_visible true
  end

  def obj id
    @builder.get_object(id)
  end

  private

  def add_section heading_text, content, opts={}
    return if content.nil? || content.empty?
    container = opts.fetch :container, @viewport.child
    Gtk::Label.new.tap do |title|
      title.set_markup markedup(:span, bold(heading_text), size: 'larger')
      title.set_visible true
      title.set_xalign 0.0
      title.set_line_wrap true
      container.add title
    end
    Gtk::Label.new.tap do |content_label|
      if content.is_a? Array
        content = content.map {|dict| [dict['name'], dict['desc']] }
      elsif content.is_a? Hash
        content = content.to_a
      end
      if content.is_a? String
        markup = content
      elsif content.is_a? Array
        markup = content.map {|arr|
          key = gray(underline(bold(arr[0])))
          [key, arr[1]].join(" ")
        }.join(opts.fetch :delimiter, "\n")
      end
      content_label.set_line_wrap true
      content_label.set_xalign 0.0
      content_label.set_markup markup
      content_label.set_margin_left 24
      content_label.set_visible true
      container.add content_label
    end
  end

  def gray text
    '<span color="#aaaaaa">%s</span>' % text
  end

  def keyval_markup key, label=nil
    label ||= key.capitalize
    labeled label, @dict[key]
  end

  def labeled label, value, opts={}
    '%s %s' % [gray(label), value] if opts.fetch(:always, value.presence)
  end

  def scroll vinc, hinc=nil
    if vinc
      vadj = @viewport.vadjustment
      vadj.set_value vadj.value + vinc
    end
    if hinc
      hadj = @viewport.hadjustment
      hadj.set_value hadj.value + hinc
    end
  end

  def set id, markup
    obj(id).set_markup markup if markup
  end
end
