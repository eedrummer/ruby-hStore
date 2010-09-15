begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

Bundler.require(:default, :test)

db_host = nil

if ENV['TEST_DB_HOST']
  db_host = ENV['TEST_DB_HOST']
else
  db_host = 'localhost'
end


db = Mongo::Connection.new(db_host).db('hStore-test')

db.drop_collection('records')

Mongoid.configure do |config|
  config.master = db
end

require 'test/unit'

# Set up the models
Dir[File.dirname(__FILE__) + '/../lib/models/*.rb'].each {|file| require file }

require 'lib/namespace_context'

# Load the web request handlers, order is significant
require 'lib/controllers/document'
require 'lib/controllers/root'
require 'lib/controllers/section'

ROOT_DIR = File.join(File.dirname(__FILE__), '..')

class HDataTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    app = Rack::Builder.new do
      map '/' do
        [HStore::Document, HStore::Root, HStore::SectionController].each_with_index do |clazz, i|
          clazz.configure do |c|
            c.set :environment, :test
            c.set :root, ROOT_DIR
          end
          if i < 2
            use clazz
          else
            run clazz 
          end
        end
      end
    end
    app
  end
  
  def test_truth
    assert true
  end
end
