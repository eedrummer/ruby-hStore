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

