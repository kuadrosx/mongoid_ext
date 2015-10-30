class CreditCard # for encryptor
  include Mongoid::Document
  include MongoidExt::Encryptor

  encrypted_field :number, :type => Integer, :key => "my password"
  encrypted_field :data, :type => Hash, :key => "my password"
  encrypted_field :extra, :key => "my password"
end

class Event # for safe_update, and Timestamp
  include Mongoid::Document

  field :start_date, :type => Timestamp
  field :end_date, :type => Timestamp

  field :password, :type => String
end

class Recipe # for Set
  include Mongoid::Document

  field :ingredients, :type => Set
  field :description, :type => String
  field :language, :type => String, :default => 'en'
end

class Avatar # for Storage and File
  include Mongoid::Document
  include MongoidExt::Storage

  file_key :data

  file_list :alternatives
  file_key :first_alternative, :in => :alternatives
end

class UserConfig # for OpenStruct
  include Mongoid::Document
  field :entries, :type => MongoidExt::OpenStruct
end

class User
  include Mongoid::Document
  include MongoidExt::Paranoia
  include MongoidExt::Voteable

  embeds_many :pictures

  field :login
  field :email
end

class Picture # for Voteable
  include Mongoid::Document
  include MongoidExt::Voteable
  embedded_in :user

  field :title
  field :content
end

class BlogPost # for Slug and Filter
  include Mongoid::Document
  include MongoidExt::Slugizer
  include MongoidExt::Tags
  include MongoidExt::Versioning

  slug_key :title, :max_length => 18, :min_length => 3, :callback_type => :before_validation, :add_prefix => true

  field :title, :type => String
  field :body, :type => String
  field :tags, :type => Array
  field :date, :type => Time

  belongs_to :updated_by, :class_name => "User"

  versionable_keys :title, :body, :tags, :owner_field => "updated_by_id", :max_versions => 2
end

class Entry
  include Mongoid::Document
  include MongoidExt::Random

  field :v, :type => Integer
  field :a, :type => Array
end
Entry.delete_all
100.times { |v| Entry.create(:v => v) }
