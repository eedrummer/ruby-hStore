module HStore
  class Application < Sinatra::Base
    helpers Sinatra::UrlForHelper

    include Root
    include Document
    include DAS
    include SectionController
    
  end
end