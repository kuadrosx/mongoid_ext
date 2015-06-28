module MongoidExt
  class File < EmbeddedHash
    attr_accessor :_root_document
    attr_accessor :_list_name

    field :name, :type => String
    field :extension, :type => String
    field :content_type, :type => String
    field :md5, :type => String
    field :updated_at, :type => Time

    alias :filename :name

    def put(filename, io, options = {})
      p "#{self.class}.put"
      mark_parent!
      options[:_id] = grid_filename

      options[:metadata] ||= {}
      options[:metadata][:collection] = _root_document.collection.name

      self["name"] = filename
      if filename =~ /\.([\w]{2,4})$/
        self["extension"] = $1
      end

      if io.kind_of?(String)
        io = StringIO.new(io)
      end

      if defined?(Magic) && Magic.respond_to?(:guess_string_mime_type)
        data = io.read(256) # be nice with memory usage
        self["content_type"] = options[:content_type] = Magic.guess_string_mime_type(data.to_s)

        if self.fetch("extension", nil).nil?
          self["extension"] = options[:content_type].to_s.split("/").last.split("-").last
        end

        if io.respond_to?(:rewind)
          io.rewind
        else
          io.seek(0)
        end
      end

      options[:filename] = grid_filename
      if MONGOID5
        old = gridfs.find_one(:filename => grid_filename)
        gridfs.delete_one(old) if old

        # MONGO::Grid::File don't accept the same options that Mongoid::Gridfs

        fileid = gridfs.insert_one(
          Mongo::Grid::File.new(io.read, {:filename => grid_filename})
        )
        p "saved as #{fileid} #{grid_filename}"
        self['md5'] = gridfs.find_one(:filename => grid_filename).md5 if fileid
      else
        gridfs.delete(grid_filename)
        gridfs.put(io, options)
      end
      self["updated_at"] = Time.now
      mark_parent!

      io.close if io.closed?

      self
    end

    def get
      @io ||= begin
        io = nil
        begin
          if MONGOID5
            io = gridfs.find_one(:filename => grid_filename)
          else
            io = gridfs.get(grid_filename)
          end

          def io.read
            self.data
          end
        rescue Mongoid::Errors::DocumentNotFound => e
        end
        io
      end
    end

    def reset
      @io = nil
    end

    def grid_filename
      @grid_filename ||= "#{_root_document.collection.name}/#{self.id}"
    end

    def mime_type
      self.content_type || get.content_type
    end

    def size
      get.file_length rescue nil
    end

    def read(size = nil)
      if size != nil
        puts "#{__FILE__}:#{__LINE__} Passing size to read() is deprecated and will be removed soon. Use .each {} to read in blocks."
      end

      self.get.data
    end

    def data
      if self.get
        self.get.data
      else
        puts "WARNING: the file you are trying to read doesn't exist: #{self.inspect}"
        nil
      end
    end

    def each(&block)
      if self.get
        self.get.each(&block)
      else
        puts "WARNING: the file you are trying to read doesn't exist: #{self.inspect}"
        nil
      end
    end

    def delete
      @io = nil
      if MONGOID5
        gridfs.delete_one(grid_filename)
      else
        gridfs.delete(grid_filename)
      end
    end

    protected
    def gridfs
      _root_document.class.gridfs
    end

    def mark_parent!
      _root_document.send(:"#{_list_name}_will_change!")
      p "#{self.class.to_s} mark_parent! #{_root_document.changes}"
    end
  end
end
