require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Orders" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  get "/orders" do
    example "Getting all orders" do
      do_request

      expect(response_body).to be_json_eql({
        :orders => [
          {
            :email => "eric@example.com",
            :date => "2012-09-04"
          },
          {
            :email => "eric+second@example.com",
            :date => "2012-09-06"
          }
        ]
      }.to_json)

      expect(status).to eq(200)
    end
  end

  post "/orders" do
    parameter :email, "Email address"
    parameter :date, "Date of order"

    let(:email) { "eric+frompost@example.com" }
    let(:date ) { "2012-08-19" }

    let(:raw_post) { params.to_json }

    example "Creating an order" do
      do_request

      expect(response_body).to eq("")
      expect(response_headers["Location"]).to match /\/orders\/3$/

      expect(status).to eq(201)
    end
  end

  get "/orders/:id" do
    let(:id) { Order.all.first.id }

    example "Viewing a single order" do
      do_request

      expect(response_body).to be_json_eql({
        :email => "eric@example.com",
        :date => "2012-09-04"
      }.to_json)

      expect(status).to eq(200)
    end
  end

  delete "/orders/:id" do
    let(:id) { Order.all.first.id }

    example "Deleting an order" do
      do_request

      expect(response_body).to eq("")

      expect(status).to eq(204)
    end
  end

  put "/orders/:id" do
    parameter :email, "Email address"
    parameter :date, "Date"

    let(:order) { Order.all.first }
    let(:id) { order.id }

    let(:email) { order.email }
    let(:date) { "2012-08-10" }

    let(:raw_post) { params.to_json }

    example "Updating an order" do
      do_request

      expect(response_body).to eq("")

      expect(status).to eq(204)

      client.get("/orders/#{id}")

      expect(response_body).to be_json_eql({
        :email => "eric@example.com",
        :date => "2012-08-10"
      }.to_json)

      expect(status).to eq(200)
    end
  end
end
