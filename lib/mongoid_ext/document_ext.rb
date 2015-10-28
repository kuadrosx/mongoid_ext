module MongoidExt
  module DocumentExt
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def find!(*args)
        find(*args) || fail(Mongoid::Errors::DocumentNotFound.new(self, args))
      end
    end

    def raw_save(opts = {})
      return true if !changed? && !opts.delete(:force)

      if opts.delete(:validate) != false || valid?
        collection.save(raw_attributes, opts)
        true
      else
        false
      end
    end
  end
end
Mongoid::Document.send(:include, MongoidExt::DocumentExt)
