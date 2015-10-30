class EmbeddedHash < Hash
  include ActiveModel::Validations

  def initialize(other = {})
    super

    assign_id
    return self unless other
    other.each do |k, v|
      self[k] = v
    end

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
        self[name.to_s] = opts[:default]
        self[name.to_s] = opts[:default].call if opts[:default].is_a?(Proc)
      end

      self[name.to_s]
    end

    define_method("#{name}=") do |v|
      self[name.to_s] = v
    end
  end

  def id
    fetch(:_id, nil) || fetch('_id', nil)
  end
  alias_method :_id, :id

  def self.mongoize(v)
    v
  end

  def self.demongoize(v)
    new(v)
  end

  def [](key)
    super(key)
  end

  def assign_id
    old_id = id
    return unless old_id.nil?
    if defined? Moped::BSON::ObjectId
      self['_id'] = Moped::BSON::ObjectId.new.to_s
    else
      self['_id'] = BSON::ObjectId.new.to_s
    end
  end
end
