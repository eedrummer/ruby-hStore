class SectionDocument
  include Mongoid::Document
  
  belongs_to_related :section
  
  before_destroy :delete_grid_files
  
  field :title
  field :media_type
  field :content_type
  field :file_id, :type => BSON::ObjectID
  field :metadata_id, :type => BSON::ObjectID
  field :document_id
  field :link_info, :type => Array
  field :authors, :type => Array
  field :created_at, :type => DateTime
  field :last_modified, :type => DateTime

  def create_metadata_from_xml(node)
    ctx = NamespaceContext.new(node, 'md' => 'http://projecthdata.org/hdata/schemas/2009/11/metadata')
    self.title = ctx.first('/md:DocumentMetaData/md:Title').text
    self.document_id = ctx.first('/md:DocumentMetaData/md:DocumentId').text
    links = ctx.evaluate('/md:DocumentMetaData/md:LinkedDocuments/md:Link/md:Target')
    if links
      self.link_info = links.map {|l| l.text}
    end
    author_nodes = ctx.evaluate('//md:PedigreeInfo/md:Author')
    if author_nodes
      self.authors = author_nodes.map {|a| a.text}.uniq
    end
    created_text = ctx.first('/md:DocumentMetaData/md:RecordDate/md:CreatedDateTime').text
    self.created_at = Time.parse(created_text)
    modifications = ctx.evaluate('/md:DocumentMetaData/md:RecordDate/md:Modified/md:ModifiedDateTime')
    if modifications
      self.last_modified = modifications.map {|m| Time.parse(m.text)}.max
    else
      self.last_modified = self.created_at
    end
  end

  def create_document(content, filename, content_type)
    with_grid do |grid|
      self.file_id = grid.put(content, :filename => filename, :content_type => content_type)
      self.save!
    end
  end

  def store_metadata(metadata)
    with_grid do |grid|
      self.metadata_id = grid.put(metadata, :content_type => 'application/xml')
      self.save!
    end
  end
  
  def grid_document
    with_grid do |grid|
      grid.get(self.file_id)
    end
  end

  def metadata_document
    with_grid do |grid|
      grid.get(self.metadata_id)
    end
  end
  
  def delete_grid_files
    with_grid do |grid|
      grid.delete(self.file_id)
      if self.metadata_id
        grid.delete(self.metadata_id)	
      end
    end
  end
  
  def replace_grid_file(content, filename, content_type)
    with_grid do |grid|
      grid.delete(self.file_id)
    end
    self.create_document(content, filename, content_type)
  end

  private

  def with_grid
    yield Mongo::Grid.new(self.class.db)
  end
end

