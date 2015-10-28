class Translation < String
  attr_accessor :keys

  def initialize(*args)
    super
    @keys = {}
    @keys["default"] = "en"
  end

  def []=(lang, text)
    @keys[lang.to_s] = text
  end

  def [](lang)
    @keys[lang.to_s]
  end

  def languages
    langs = @keys.keys
    langs.delete("default")
    langs
  end

  def default_language=(lang)
    @keys["default"] = lang
    replace(@keys[lang.to_s])
  end

  def self.build(keys, default = "en")
    tr = new
    tr.keys = keys
    tr.default_language = default
    tr
  end

  def self.mongoize(value)
    return value.keys if value.is_a?(self)

    @keys
  end

  def self.demongoize(value)
    return value if value.is_a?(self)

    result = new
    result.keys = value
    result.default_language = value["default"] || "en"

    result
  end
end
