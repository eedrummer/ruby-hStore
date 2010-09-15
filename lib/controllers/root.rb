module HStore
  class Root < Sinatra::Base
    helpers Sinatra::UrlForHelper

    get '/records/:id' do
      @record = Record.find(params[:id])
      if request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('application/atom+xml')
        builder :root_atom
      else
        erb :index
      end
    end

    put '/records/:id' do
      headers 'Allow' => 'GET, HEAD, POST'
      status 405
      "PUT is undefined at this level of the hData Record"
    end

    delete '/records/:id' do
      headers 'Allow' => 'GET, HEAD, POST'
      status 405
      "DELETE is undefined at this level of the hData Record"
    end

    post '/records/:id' do
      @record = Record.find(params[:id])
      extension = @record.extensions.find_by_extension_id(params[:extensionId])
      unless extension
        extension = @record.extensions.create(:extension_id => params[:extensionId])
      end
      if @record.sections.path_exists?(params[:path])
        halt 409, "A section already exists at that path"
      else
        section = @record.sections.create(:name => params[:name], :path => params[:path], 
                                          :extension_id => params[:extensionId])
        if section.valid?
          status 201
        else
          halt 400, section.errors.full_messages.join(' ')
        end
      end
    end

    get '/records/:id/root.xml' do
      @record = Record.find(params[:id])
      content_type 'application/xml', :charset => 'utf-8'
      builder :root
    end

    post '/records' do
      record = Record.new
      record.save
      status 201
      url_for("/records/#{record.id}")
    end

    def handle_section
      extension = @record.extensions.find_by_extension_id(params[:extensionId])
      if extension
        if @record.sections.path_exists?(params[:path])
          halt 409, "A section already exists at that path"
        else
          section = @record.sections.create(:name => params[:name], :path => params[:path], 
                                            :extension_id => params[:extensionId])
          if section.valid?
            status 201
          else
            halt 400, section.errors.full_messages.join(' ')
          end
        end
      else
        halt 400, "Couldn't find the extension for the extensionId specified"
      end
    end
  end
end
