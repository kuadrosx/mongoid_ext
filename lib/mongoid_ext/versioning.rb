module MongoidExt
  module Versioning
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods

        cattr_accessor :versionable_options

        attr_accessor :rolling_back
        field :version_message

        field :versions_count, :type => Integer, :default => 0
        field :version_ids, :type => Array, :default => []

        before_save :save_version, :if => proc { |d| !d.rolling_back }
      end
    end

    def rollback!(pos = nil)
      pos ||= versions_count - 1
      version = version_at(pos)
      return false unless version

      version.load(self)

      owner_field = self.class.versionable_options[:owner_field]
      self[owner_field] = version[owner_field] unless changes.include?(owner_field)
      self.updated_at = version.date if self.respond_to?(:updated_at) && !self.updated_at_changed?

      @rolling_back = true
      r = save!
      @rolling_back = false
      r
    end

    def load_version(pos = nil)
      pos ||= versions_count - 1
      version = version_at(pos)

      return unless version
      version.load(self)
    end

    def diff(key, pos1, pos2, format = :html)
      version1 = version_at(pos1)
      version2 = version_at(pos2)

      Differ.diff(version1.content(key), version2.content(key)).format_as(format).html_safe
    end

    def diff_by_word(key, pos1, pos2, format = :html)
      version1 = version_at(pos1)
      version2 = version_at(pos2)

      Differ.diff_by_word(version1.content(key), version2.content(key)).format_as(format).html_safe
    end

    def diff_by_line(key, pos1, pos2, format = :html)
      version1 = version_at(pos1)
      version2 = version_at(pos2)

      Differ.diff_by_line(version1.content(key), version2.content(key)).format_as(format).html_safe
    end

    def diff_by_char(key, pos1, pos2, format = :html)
      version1 = version_at(pos1)
      version2 = version_at(pos2)

      Differ.diff_by_char(version1.content(key), version2.content(key)).format_as(format).html_safe
    end

    def current_version
      version_klass.new(
        :data => attributes,
        self.class.versionable_options[:owner_field] => (updated_by_id_was || updated_by_id),
        :created_at => Time.now
      )
    end

    def version_at(pos)
      return current_version if pos == 'current'

      pos = case pos.to_s
            when "first"
              version_ids.first
            when "last"
              version_ids.last
            else
              version_ids[pos]
            end

      version_klass.find(pos) if pos
    end

    def versions
      version_klass.where(:target_id => id)
    end

    def version_klass
      self.class.version_klass
    end

    module ClassMethods
      def version_klass
        parent_klass = self
        @version_klass ||= Class.new do
          include Mongoid::Document
          include Mongoid::Timestamps
          include Mongoid::Attributes::Dynamic

          cattr_accessor :parent_class
          self.parent_class = parent_klass

          store_in collection: "#{parent_class.collection_name}.versions"

          field :message, :type => String
          field :data, :type => Hash

          belongs_to :owner, :class_name => parent_klass.versionable_options[:user_class]

          belongs_to :target, :polymorphic => true

          after_create :add_version

          validates_presence_of :target_id

          define_method(:content) do |key|
            cdata = data[key.to_s]
            if cdata.respond_to?(:join)
              cdata.join(" ")
            else
              cdata || ""
            end
          end

          define_method(:load) do |doc|
            return false unless doc.is_a? target_class
            data.each do |key, value|
              doc.send("#{key}=", value)
            end
          end

          private

          define_method(:target_class) do
            @target_class ||= target_type.constantize
          end

          define_method(:add_version) do
            if MONGOID5
              target_class.collection.find(
                :_id => target_id
              ).update_one(
                :$push => { :version_ids => id },
                :$inc =>  { :versions_count => 1 }
              )
            else
              target_class.collection.find(
                :_id => target_id
              ).update_many(
                :$push => { :version_ids => id },
                :$inc =>  { :versions_count => 1 }
              )
            end
          end
        end
      end

      # example:
      #     class Foo
      #       include Mongoid::Document
      #       include MongoidExt::Versioning
      #       versionable_keys :field1, :field2, :field3, :user_class => "Customer", :owner_field => "updated_by_id"
      #       ...
      #     end
      #
      def versionable_keys(*keys)
        self.versionable_options = keys.extract_options!
        versionable_options[:owner_field] ||= "user_id"
        versionable_options[:owner_field] = versionable_options[:owner_field].to_s

        relationship = relations[versionable_options[:owner_field].sub(/_id$/, "")]
        unless relationship
          fail ArgumentError, "the supplied :owner_field => #{versionable_options[:owner_field].inspect} option is invalid"
        end
        versionable_options[:user_class] = relationship.class_name

        define_method(:save_version) do
          return true if self.new_record?

          data = {}
          message = ""
          keys.each do |key|
            change = changes[key.to_s]
            if change
              data[key.to_s] = change.first
            else
              data[key.to_s] = self[key]
            end
          end
          return true if data.empty?

          message_changes = changes["version_message"]
          if message_changes
            message = message_changes.first
          else
            message = ""
          end

          uuser_id = send(versionable_options[:owner_field] + "_was") || send(versionable_options[:owner_field])
          return true unless uuser_id

          max_versions = versionable_options[:max_versions].to_i
          if max_versions > 0 && version_ids.size >= max_versions
            old = version_ids.slice!(0, max_versions - 1)
            self.class.skip_callback(:save, :before, :save_version)
            version_klass.where(:_id.in => old).delete_all
            save
            self.class.set_callback(:save, :before, :save_version)
          end

          version_klass.create!(
            'data' => data,
            'owner_id' => uuser_id,
            'target' => self,
            'message' => message
          )
        end

        define_method(:versioned_keys) do
          keys
        end
      end
    end
  end
end
