module MongoidExt
  module Encryptor
    extend ActiveSupport::Concern

    included do
      require 'encryptor'
    end

    module ClassMethods
      def encrypted_field(name, options = {})
        key = options.delete(:key)
        fail ArgumentError, ":key option must be given" if key.nil?
        type = options.delete(:type)

        field(name, options)
        alias_method :"#{name}_encrypted", name

        define_read_encrypted_field(name, key, type)
        define_write_encrypted_field(name, key)
      end

      private

      def define_read_encrypted_field(name, key, type)
        define_method(name) do
          value = [send(:"#{name}_encrypted").to_s].pack('H*')
          return if value.blank?
          type.demongoize(Marshal.load(::Encryptor.decrypt(value, :key => key)))
        end
      end

      def define_write_encrypted_field(name, key)
        define_method("#{name}=") do |v|
          marshaled = Marshal.dump(v)
          enc_value = ::Encryptor.encrypt(marshaled, :key => key).unpack('H*')[0]

          self[name.to_sym] = enc_value
        end
      end
    end
  end
end
