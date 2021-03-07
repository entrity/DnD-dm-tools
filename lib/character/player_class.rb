class Character::PlayerClass
  @@child_classes = []

  def self.inherited child_klass
    @@child_classes << child_klass
  end

  def self.library; @@child_classes; end

  private

  def initialize
  end
end

class Character::Barbarian < Character::PlayerClass
end

class Character::Bard < Character::PlayerClass
end

class Character::Cleric < Character::PlayerClass
end

class Character::Druid < Character::PlayerClass
end

class Character::Fighter < Character::PlayerClass
end

class Character::Monk < Character::PlayerClass
end

class Character::Paladin < Character::PlayerClass
end

class Character::Ranger < Character::PlayerClass
end

class Character::Rogue < Character::PlayerClass
end

class Character::Sorcerer < Character::PlayerClass
end

class Character::Warlock < Character::PlayerClass
end

class Character::Wizard < Character::PlayerClass
end
