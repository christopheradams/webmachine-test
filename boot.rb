require_relative "app"

Order.new(:email => "eric@example.com", :date => Date.parse("2012-09-04")).save
Order.new(:email => "eric+second@example.com", :date => Date.parse("2012-09-06")).save

App.run
