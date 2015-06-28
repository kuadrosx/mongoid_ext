module MongoidExt
  class FileList < EmbeddedHash
    attr_accessor :parent_document
    attr_accessor :list_name

    def put(file_id, io, metadata = {})
      get(file_id)
      (@_pending_files ||= {})[file_id] = [io, metadata]
      mark_parent!
    end

    def files
      ids = keys
      ids.delete('_id')
      ids.map { |v| get(v) }
    end

    def each_file(&_block)
      (keys - ['_id']).each do |key|
        file = get(key)
        yield key, file
      end
    end

    def get(file_id)
      if file_id.is_a?(MongoidExt::File)
        self[file_id.id] = file_id
        return file_id
      end

      file_id = file_id.to_s.tr('.', '_')

      file = begin
        f = self[file_id]
        if f.nil?
          self[file_id] = MongoidExt::File.new
        elsif !f.is_a?(MongoidExt::File) && f.is_a?(::Hash)
          self[file_id] = MongoidExt::File.new(f)
        else
          self[file_id]
        end
      end

      file._root_document = parent_document
      file._list_name = list_name
      file
    end

    def sync_files
      return unless @_pending_files
      changed = false
      @_pending_files.each do |filename, data|
        changed = true
        get(filename).put(filename, data[0], data[1])
      end
      mark_parent! if changed
      @_pending_files = nil
    end

    def delete(file_id)
      file = get(file_id)
      super(file_id)
      file.delete
      mark_parent!
      file
    end

    def destroy_files
      each_file do |file_id, _file|
        get(file_id).delete
      end
      mark_parent!
    end

    def self.mongoize(v)
      v
    end

    def self.demongoize(v)
      return if v.nil?

      doc = self.class.new
      v.each do |k, c|
        doc[k] = MongoidExt::File.new(c)
      end

      doc
    end

    def mark_parent!
      parent_document.send(:"#{list_name}_will_change!")
      parent_document.send(:"#{list_name}=", self)
    end
  end
end
