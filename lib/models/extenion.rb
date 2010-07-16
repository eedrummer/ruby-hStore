class Extension
  include Mongoid::Document

  embedded_in :record, :inverse_of => :extensions

  field :extension_id

  validates_presence_of :extension_id, :message => "An extension must specify a extensionId"
end
