require 'ostruct'

module MongoidExt
  class OpenStruct < ::OpenStruct
    def mongoize
      send(:table)
    end

    def self.demongoize(value)
      value.nil? ? nil : OpenStruct.new(value)
    end

    def self.mongoize(value)
      if value.is_a?(self)
        value.mongoize
      elsif value.is_a?(Hash)
        value
            end
    end
  end
end
