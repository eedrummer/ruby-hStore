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

# Set up the models
require 'lib/models'

# Load the web request handlers
require 'lib/document'
require 'lib/root'
require 'lib/section'
require 'lib/hstore'

HStore::Application.run!(:root => File.dirname(__FILE__))