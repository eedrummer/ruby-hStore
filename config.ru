begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
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
Dir[File.dirname(__FILE__) + '/lib/models/*.rb'].each {|file| require file }

# Load the web request handlers, order is significant
require 'lib/controllers/document'
require 'lib/controllers/root'
require 'lib/controllers/section'
require 'lib/controllers/hstore'

HStore::Application.run!(:root => File.dirname(__FILE__))
