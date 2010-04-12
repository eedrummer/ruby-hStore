module HStore
  class Application < Sinatra::Base
    helpers Sinatra::UrlForHelper

    include Root
    include Document
    include SectionController
  end
end