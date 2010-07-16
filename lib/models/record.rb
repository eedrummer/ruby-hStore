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
