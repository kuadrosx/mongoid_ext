class EmbeddedHash < Hash
  include ActiveModel::Validations

  def initialize(other = {})
    super

    p "#{self.class} NEW(#{other})"

    if other
      other.each do |k,v|
        self[k] = v
      end
    end

    self.assign_id
    self
  end

  def self.allocate
    obj = super
    obj.assign_id

    obj
  end

  def self.field(name, opts = {})
    define_method(name) do
      if fetch(name.to_s, nil).nil?
        self[name.to_s] = opts[:default].kind_of?(Proc) ? opts[:default].call : opts[:default]
      else
        self[name.to_s]
      end
    end

    define_method("#{name}=") do |v|
      self[name.to_s] = v
    end
  end

  def id
    mid = self.fetch(:_id, nil) || self.fetch('_id', nil)
    p "#{self.class} GET ID #{mid}"
    mid
  end
  alias :_id :id

  def self.mongoize(v)
    v
  end

  def self.demongoize(v)
    self.new(v)
  end

  def [](key)
    p "#{self}[#{key}]"

    super(key)
  end

  def assign_id
    old_id = self.fetch(:_id, nil) || self.fetch('_id', nil)
    if old_id.nil?
      if defined? Moped::BSON::ObjectId
        self["_id"] = Moped::BSON::ObjectId.new.to_s
      else
        self["_id"] = BSON::ObjectId.new.to_s
      end
    end
  end
end
