module HStore
  class Application < Sinatra::Base
    helpers Sinatra::UrlForHelper
    
    include Root
    include SectionController
  end
end