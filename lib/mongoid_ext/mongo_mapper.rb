module MongoidExt
  module MongoMapper
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def find_each(*args, &block)
        all(*args).each do |doc|
          block.call(doc)
        end
      end

      def many(name, opts = {})
        opts[:stored_as] = :array if opts.delete(:in)
        fkey = opts.delete(:foreign_key)
        opts[:inverse_of] = fkey.sub(/_id$/, "") if fkey

        references_many name, opts
      end
      alias_method :has_many, :many

      def one(name, opts = {})
        fkey = opts.delete(:foreign_key)
        opts[:inverse_of] = fkey.sub(/_id$/, "") if fkey

        references_one name, opts
      end
      alias_method :has_one, :one

      def belongs_to(name, opts = {})
        fkey = opts.delete(:foreign_key)
        opts[:inverse_of] = fkey.sub(/_id$/, "") if fkey

        if opts[:polymorphic]
          fail ArgumentError, "polymorphic associations are not supported yet"
        end

        referenced_in name, opts
      end

      def timestamps!
        include Mongoid::Timestamps
      end

      def key(name, *args)
        opts = args.extract_options!

        opts[:type] = args.first unless args.empty?

        field name, opts
      end

      def ensure_index(*args)
        index(*args)
      end
    end
  end
end
