class Record
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_many :extensions do
    def find_by_type_id(type_id)
      @target.select {|extension| extension.type_id == type_id}.first
    end
    
    def type_id_registered?(type_id)
      @target.any? {|extension| extension.type_id == type_id}
    end
  end
  
  has_many :sections do
    def path_exists?(path)
      @target.any? {|section| section.path == path}
    end
  end
end

class Extension
  include Mongoid::Document
  
  belongs_to :record, :inverse_of => :extensions
  
  field :type_id
  field :requirement
  
  validates_format_of :requirement, :with  => /optional|mandatory/, :message => "Extension requirement must be optional or mandatory"
  validates_presence_of :type_id, :requirement, :message => "An extension must specify a typeId and requirement"
end

class Section
  include Mongoid::Document
  
  belongs_to :record, :inverse_of => :sections
  
  field :type_id
  field :name
  field :path
  
  validates_uniqueness_of :path, :message => "A section already exists at that path"
  validates_presence_of :name, :path, :type_id, :message => "A section must specify a name, type_id and path"
end

class SectionDocument
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title
end