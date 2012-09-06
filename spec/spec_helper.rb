require './app'
require 'rspec_api_documentation'
require 'json_spec'

RspecApiDocumentation.configure do |config|
  config.app = Webmachine::Adapters::Rack.new(App.configuration, App.dispatcher)
end

RSpec.configure do |config|
  config.include JsonSpec::Helpers

  config.before do
    Order.delete_all
    Order.new(:email => "eric@example.com", :date => Date.parse("2012-09-04")).save
    Order.new(:email => "eric+second@example.com", :date => Date.parse("2012-09-06")).save
  end
end
