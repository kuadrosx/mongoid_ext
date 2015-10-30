module MongoidExt
  class File < EmbeddedHash
    attr_accessor :_root_document
    attr_accessor :_list_name

    field :name, :type => String
    field :extension, :type => String
    field :content_type, :type => String
    field :md5, :type => String
    field :updated_at, :type => Time

    alias_method :filename, :name

    def put(filename, io, options = {})
      self['name'] = filename

      io = StringIO.new(io) if io.is_a?(String)
      setup_content_data(io, filename)

      if MONGOID5
        old = gridfs.find_one(:filename => grid_filename)
        gridfs.delete_one(old) if old

        # MONGO::Grid::File don't accept the same options that Mongoid::Gridfs
        file = Mongo::Grid::File.new(io.read, :filename => grid_filename)
        fileid = gridfs.insert_one(file)

        self['md5'] = file.md5 if fileid
      else
        gridfs.delete(grid_filename)
        setup_metadata(options)
        gridfs.put(io, options)
      end
      self['updated_at'] = Time.now

      io.close unless io.closed?

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
            data
          end
        rescue Mongoid::Errors::DocumentNotFound => _e
          return nil
        end
        io
      end
    end

    def reset
      @io = nil
    end

    def grid_filename
      self._id ||= BSON::ObjectId.new
      @grid_filename ||= "#{_root_document.collection.name}/#{id}"
    end

    def mime_type
      content_type || get.content_type
    end

    def size
      get.file_length
    rescue
      nil
    end

    def read(size = nil)
      if size.nil?
        puts "#{__FILE__}:#{__LINE__} Passing size to read() is deprecated and will be removed soon. Use .each {} to read in blocks."
      end

      get.data
    end

    def data
      if get
        get.data
      else
        puts "WARNING: the file you are trying to read doesn't exist: #{inspect}"
        nil
      end
    end

    def delete
      @io = nil
      if MONGOID5
        file = get
        gridfs.delete_one(get) if file
      else
        gridfs.delete(grid_filename)
      end
    end

    protected

    def gridfs
      _root_document.class.gridfs
    end

    def setup_metadata(options)
      options[:_id] = grid_filename
      options[:metadata] ||= {}
      options[:metadata][:collection] = _root_document.collection.name
      content_type = fetch('content_type', nil)
      options[:content_type] = content_type unless content_type.nil?
      options[:filename] = grid_filename
      options
    end

    def setup_content_data(io, filename)
      extension = nil
      extension = Regexp.last_match(1) if filename =~ /\.([\w]{2,4})$/
      content_type = guess_content_type(io)
      self['content_type'] = content_type
      self['extension'] = extension

      return if content_type.nil? || !extension.nil?

      self['extension'] = content_type.to_s.split('/').last.split('-').last
    end

    private

    def guess_content_type(io)
      return unless WITH_MAGIC
      data = io.read(256) # be nice with memory usage
      content_ype = Magic.guess_string_mime_type(data.to_s)
      if io.respond_to?(:rewind)
        io.rewind
      else
        io.seek(0)
      end
      content_ype
    end
  end
end
