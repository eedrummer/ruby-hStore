module HStore
  module Root
    def self.included(mod)
      mod.module_eval do
        get '/records/:id' do
          @record = Record.find(params[:id])
          erb :index
        end

        put '/records/:id' do
	  headers 'Allow' => 'GET, HEAD, POST'
          status 405
          "You can't PUT at this level of the hData Record"
        end

        post '/records/:id' do
          check_params
          @record = Record.find(params[:id])
          handle_extension if params[:type].eql?('extension')
          handle_section if params[:type].eql?('section')
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

        def check_params
          unless ['extension', 'section'].include? params[:type]
            halt 400, "Your request must specify a type of either section or extension"
          end
        end

        def handle_extension
          if @record.extensions.extension_id_registered?(params[:extensionId])
            halt 409, "Extension with that type id already exists"
          else
            extension = @record.extensions.create(:extension_id => params[:extensionId])
            if extension.valid?
              status 201
            else
              extension.destroy
              halt 400, extension.errors.full_messages.join(' ')
            end
          end
        end

        def handle_section
          extension = @record.extensions.find_by_extension_id(params[:extensionId])
          if extension
            if @record.sections.path_exists?(params[:path])
              halt 409, "A section already exists at that path"
            else
              section = @record.sections.create(:name => params[:name], :path => params[:path], :extension_id => params[:extensionId])
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
  end
end
