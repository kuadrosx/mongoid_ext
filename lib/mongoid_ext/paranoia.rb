# encoding: utf-8
module MongoidExt #:nodoc:
  # Include this module to get soft deletion of root level documents.
  # This will add a deleted_at field to the +Document+, managed automatically.
  # Potentially incompatible with unique indices. (if collisions with deleted items)
  #
  # To use:
  #
  #   class Person
  #     include Mongoid::Document
  #     include MongoidExt::Paranoia
  #   end
  module Paranoia
    extend ActiveSupport::Concern

    included do
    end

    # Delete the paranoid +Document+ from the database completely. This will
    # run the destroy callbacks.
    #
    # Example:
    #
    # <tt>document.destroy!</tt>
    def destroy!
      run_callbacks(:destroy) { delete! }
    end

    # Delete the paranoid +Document+ from the database completely.
    #
    # Example:
    #
    # <tt>document.delete!</tt>
    def delete!(options = {})
      raise Errors::ReadonlyDocument.new(self.class) if readonly?
      prepare_delete do
        if embedded?
          delete_as_embedded(options)
        else
          delete_as_root
        end
      end
      self.class.deleted.where(:"document._id" => id).destroy
    end

    # Delete the +Document+, will set the deleted_at timestamp and not actually
    # delete it.
    #
    # Example:
    #
    # <tt>document.remove</tt>
    #
    # Returns:
    #
    # true
    def remove(options = {})
      self.class.deleted.create(:document => raw_attributes)

      super
    end
    alias_method :delete, :remove

    module ClassMethods #:nodoc:
      # Find deleted documents
      #
      # Examples:
      #
      #   <tt>Person.deleted</tt>  # all deleted employees
      #   <tt>Company.first.employees.deleted</tt>  # works with a join
      #   <tt>Person.deleted.find("4c188dea7b17235a2a000001").first</tt>
      #   <tt>Person.deleted.compact!(1.week.ago)</tt>
      def deleted
        paranoia_klass
      end

      def paranoia_klass
        @paranoia_klass ||= define_paranoia_klass
      end

      private

      def define_paranoia_klass
        parent_klass = self
        Class.new do
          include Mongoid::Document
          include Mongoid::Timestamps

          cattr_accessor :parent_class
          self.parent_class = parent_klass

          collection_name = "#{parent_class.collection.name}.trash"
          store_in :collection => collection_name

          field :document, :type => Hash

          before_validation { self["_id"] = document["_id"] }

          def restore
            self.class.parent_class.create(document)
          end

          def self.compact!(date = 1.month.ago)
            delete_all(:created_at => { :$lte => date.to_time })
          end
        end
      end
    end
  end
end
