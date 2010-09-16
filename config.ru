real_file = Kernel.const_get('File')

$: << real_file.dirname(__FILE__)

begin
  # Try to require the preresolved locked set of gems.
  require real_file.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

Bundler.require(:default)

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('hStore')
end

require 'lib/namespace_context'

# Set up the models
Dir[real_file.dirname(__FILE__) + '/lib/models/*.rb'].each {|file| require file }

# Load the web request handlers, order is significant
require 'lib/controllers/document'
require 'lib/controllers/root'
require 'lib/controllers/section'

map '/' do 
  [HStore::Document, HStore::Root, HStore::SectionController].each_with_index do |clazz, i|
    clazz.configure do |c|
      c.set :root, real_file.dirname(__FILE__)
    end
    if i < 2
      use clazz
    else
      run clazz 
    end
  end
end
