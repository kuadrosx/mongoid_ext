module MongoidExt
  class FileList < EmbeddedHash
    attr_accessor :parent_document
    attr_accessor :list_name

    def put(file_id, io, metadata = {})
      p "FileList.put('#{file_id}')"
      # if !parent_document.new_record?
      #   filename = file_id
      #   if io.respond_to?(:original_filename)
      #     filename = io.original_filename
      #   elsif io.respond_to?(:path) && io.path
      #     filename = ::File.basename(io.path)
      #   elsif io.kind_of?(String)
      #     io = StringIO.new(io)
      #   end

      get(file_id)

      #   file
      # else
        (@_pending_files ||= {})[file_id] = [io, metadata]
      # end
    end

    def files
      ids = self.keys
      ids.delete("_id")
      ids.map {|v| get(v) }
    end

    def each_file(&block)
      (self.keys-["_id"]).each do |key|
        file = self.get(key)
        yield key, file
      end
    end

    def get(file_id)
      if file_id.kind_of?(MongoidExt::File)
        self[file_id.id] = file_id
        return file_id
      end

      file_id = file_id.to_s.gsub(".", "_")
      p "FileList#get('#{file_id}')"

      file = self[file_id]

      if file.nil?
        p "#{self.class} create new file"
        file = self[file_id] = MongoidExt::File.new
      elsif !file.kind_of?(MongoidExt::File) && file.kind_of?(::Hash)
        p "#{self.class} #{file_id} #{self} load from db #{file}"
        file = self[file_id] = MongoidExt::File.new(file)
      end

      file._root_document = parent_document
      file._list_name = self.list_name
      file
    end

    def sync_files
      p "FileList.sync_files"
      if @_pending_files
        changed = false
        @_pending_files.each do |filename, data|
          changed = true
          p get(filename).put(filename, data[0], data[1])
        end
        mark_parent! if changed
        @_pending_files = nil
      end
    end

    def delete(file_id)
      file = self.get(file_id)
      super(file_id)
      file.delete
      mark_parent!
      file
    end

    def destroy_files
      each_file do |file_id, file|
        get(file_id).delete
      end
    end

    def self.mongoize(v)
      Hash[v]
    end

    def self.demongoize(v)
      return if v.nil?

      doc = self.class.new
      v.each do |k,c|
        doc[k] = MongoidExt::File.new(c)
      end

      doc
    end

    def mark_parent!
      parent_document.send(:"#{list_name}_will_change!")
      p "#{self.class.to_s} mark_parent! #{parent_document.changes}"
    end
  end
end
