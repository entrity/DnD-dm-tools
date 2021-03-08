class Object
  def presence
    self
  end
end
class String
  def presence
    empty? ? nil : self
  end
end
