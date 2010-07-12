class Record
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embeds_many :extensions do
    def find_by_extension_id(extension_id)
     @target.select {|extension| extension.extension_id == extension_id}.first
    end

    def extension_id_registered?(extension_id)
     @target.any? {|extension| extension.extension_id == extension_id}
    end
  end
  
  embeds_many :sections do
    def path_exists?(path)
      @target.any? {|section| section.path == path}
    end
  
    def find_by_path(path)
      @target.select {|section| section.path == path}.first
    end
  end
end

class Extension
  include Mongoid::Document

  embedded_in :record, :inverse_of => :extensions

  field :extension_id

  validates_presence_of :extension_id, :message => "An extension must specify a extensionId"
end

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

class SectionDocument
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to_related :section
  
  before_destroy :delete_grid_file
  
  field :title
  field :file_id
  
  def create_document(content, filename, content_type)
    grid = Mongo::Grid.new(self.class.db)
    self.file_id = grid.put(content, :filename => filename, :content_type => content_type)
    self.save!
  end
  
  def grid_document
    grid = Mongo::Grid.new(self.class.db)
    grid.get(BSON::ObjectID.from_string(self.file_id))
  end
  
  def delete_grid_file
    grid = Mongo::Grid.new(self.class.db)
    grid.delete(BSON::ObjectID.from_string(self.file_id))
  end
  
  def replace_grid_file(content, filename, content_type)
    self.delete_grid_file
    self.create_document(content, filename, content_type)
  end
end
