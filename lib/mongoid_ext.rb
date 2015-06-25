$:.unshift File.dirname(__FILE__)
require 'bundler/setup'

Bundler.require
require 'mongoid'
require 'uuidtools'
require 'differ'
require 'active_support/inflector'
MONGOID5 = Gem.loaded_specs["mongoid"].version.to_s.starts_with? '5'

unless MONGOID5
  begin
    require 'mongoid/grid_fs'
  rescue LoadError
    $stderr.puts "disabling `storage` support. use 'gem install mongoid-grid_fs' to enable it"
  end
end

begin
  require 'magic'
rescue LoadError
  $stderr.puts "disabling `magic` support. use 'gem install magic' to enable it"
end

require 'mongoid_ext/patches'
require 'mongoid_ext/encryptor'

# types
require 'mongoid_ext/types/open_struct'
require 'mongoid_ext/types/timestamp'
require 'mongoid_ext/types/translation'
require 'mongoid_ext/types/embedded_hash'

# storage
require 'mongoid_ext/file_list'
require 'mongoid_ext/file'
require 'mongoid_ext/storage'
require 'mongoid_ext/file_server'

# update
require 'mongoid_ext/update'

# slug
require 'mongoid_ext/slugizer'

# tags
require 'mongoid_ext/tags'

require 'mongoid_ext/versioning'
require 'mongoid_ext/voteable'
require 'mongoid_ext/paranoia'

require 'mongoid_ext/random'
require 'mongoid_ext/mongo_mapper'
require 'mongoid_ext/document_ext'
require 'mongoid_ext/criteria_ext'

module MongoidExt
  def self.init
    Mongoid::GridFS.file_model.field :_id, :type => String # to keep backwards compat
    Mongoid.allow_dynamic_fields = true
    load_jsfiles(::File.dirname(__FILE__)+"/mongoid_ext/js")
  end

  def self.load_jsfiles(path)
    Dir.glob(::File.join(path, "*.js")) do |js_path|
      code = ::File.read(js_path)
      name = ::File.basename(js_path, ".js")

      # HACK: looks like ruby driver doesn't support this
      Mongoid.sessions.each do |session_name, _|
        Mongoid.session(session_name).command(:eval => "db.system.js.save({_id: '#{name}', value: #{code}})")
      end
    end
  end
end

