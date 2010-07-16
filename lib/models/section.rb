class Section
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :record, :inverse_of => :sections  
  has_many_related :section_documents

  field :extension_id
  field :name
  field :path

  validates_uniqueness_of :path, :message => "A section already exists at that path"
  validates_presence_of :name, :path, :extension_id, :message => "A section must specify a name, extension_id and path"
end
