module MongoidExt
  module Storage
    extend ActiveSupport::Concern

    included do
      if MONGOID5 || defined?(Mongoid::GridFS)
        validate :__add_storage_errors
        file_list :file_list
      end
    end

    def put_file(name, io, options = {})
      file_list = send(options.delete(:in) || :file_list)
      file_list.put(name, io, options)
    end

    def fetch_file(name, options = {})
      file_list = send(options.delete(:in) || :file_list)
      file_list.get(name)
    end

    def delete_file(id, options = {})
      file_list = send(options.delete(:in) || :file_list)
      file_list.delete(id)
    end

    def files(options = {})
      file_list = send(options.delete(:in) || :file_list)
      file_list.files
    end

    def storage_errors
      @storage_errors ||= {}
    end

    def __add_storage_errors
      storage_errors.each do |k, msgs|
        msgs.each do |msg|
          self.errors.add(k, msg)
        end
      end
    end

    module ClassMethods
      def gridfs
        @gridfs ||= begin
          if MONGOID5
            collection.database.fs
          else
            Mongoid::GridFS
          end
        end
      end

      def file_list(name)
        field name, :type => MongoidExt::FileList

        define_method(name) do
          varname = "@file_list_#{name}"

          return instance_variable_get(varname) if instance_variable_get(varname)

          list = self[name]

          if list.nil?
            list = self[name] = MongoidExt::FileList.new
          elsif list.kind_of?(::Hash)
            list = self[name] = MongoidExt::FileList.new(list)
          end

          list.parent_document = self
          list.list_name = name.to_s

          instance_variable_set(varname, list)
          list
        end

        set_callback(:save, :after) do |doc|
          l = doc.send(name)
          l.sync_files

          query = doc._updates
          if !query.blank?
            if MONGOID5
              doc.collection.find(:_id => doc.id).update_one(query)
            else
              doc.collection.find(:_id => doc.id).update(query)
            end
          end
        end

        set_callback(:destroy, :before) do |doc|
          doc.send(name).destroy_files
        end
      end

      def file_key(name, opts = {})
        opts[:in] ||= :file_list

        define_method("#{name}=") do |file|
          if opts[:max_length] && file.respond_to?(:size) && file.size > opts[:max_length]
            errors.add(
              name,
              I18n.t("mongoid_ext.storage.errors.max_length", :default => "file is too long. max length is #{opts[:max_length]} bytes")
            )
          end

          if cb = opts[:validate]
            if cb.kind_of?(Symbol)
              send(opts[:validate], file)
            elsif cb.kind_of?(Proc)
              cb.call(file)
            end
          end

          if self.errors[name].blank?
            fl = send(opts[:in])

            if file.kind_of?(String)
              file = StringIO.new(file)
            end

            fl.put(name.to_s, file)
          else
            # we store the errors here because we want to validate before storing the file
            storage_errors.merge!(self.errors)
          end
        end

        define_method(name) do
          send(opts[:in]).get(name.to_s)
        end

        define_method("has_#{name}?") do
          send(opts[:in]).has_key?(name.to_s)
        end
      end
      private
    end
  end
end
