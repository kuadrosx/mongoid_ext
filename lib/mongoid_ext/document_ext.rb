module MongoidExt
  module DocumentExt
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def find!(*args)
        find(*args) || raise(Errors::DocumentNotFound.new(self, args))
      end

    end

    module InstanceMethods
      def raw_save(opts = {})
        return true if !changed?

        if (opts.delete(:validate) != false || valid?)
          self.collection.save(raw_attributes, opts)
          true
        else
          false
        end
      end
    end
  end
end
Mongoid::Document.send(:include, MongoidExt::DocumentExt)