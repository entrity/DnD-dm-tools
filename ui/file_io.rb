module FileIO
  # File > Open
  def load_dialog
    dialog = Gtk::FileChooserDialog.new title: 'Load', parent: nil, action: :open,
    buttons: [[Gtk::Stock::OPEN, Gtk::ResponseType::ACCEPT], [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]]
    fpath = Gtk::ResponseType::ACCEPT == dialog.run && dialog.filename
    dialog.destroy
    puts "loading #{fpath}"
    Game.instance.load fpath
    MainUI.instance.refresh
  end

  # File > Save
  def save
    if Game.instance.fpath.nil?
      save_dialog
    else
      puts "Saving to #{Game.instance.fpath}"
      Game.instance.dump
    end
  end

  # File > Save As
  def save_dialog
    dialog = Gtk::FileChooserDialog.new title: 'Save', parent: nil, action: :save,
    buttons: [[Gtk::Stock::SAVE, Gtk::ResponseType::ACCEPT], [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]]
    return unless Gtk::ResponseType::ACCEPT == dialog.run
    Game.instance.fpath = dialog.filename
    dialog.destroy
    save
  end
end
