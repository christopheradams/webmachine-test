require 'webmachine'
require 'webmachine/adapters/rack'
require 'json'

class Order
  attr_accessor :id, :email, :date

  DB = {}

  def self.all
    DB.values
  end

  def self.find(id)
    DB[id]
  end

  def self.next_id
    DB.keys.max.to_i + 1
  end

  def to_json(options = {})
    %{{"email":"#@email", "date":"#@date", "id":#@id}}
  end

  def initialize(attrs = {})
    attrs.each do |attr, value|
      send("#{attr}=", value) if respond_to?(attr)
    end
  end

  def save(id = nil)
    self.id = id || self.class.next_id
    DB[self.id] = self
  end

  def destroy
    DB.delete(id)
  end
end

class JsonResource < Webmachine::Resource
  def content_types_provided
    [["application/json", :to_json]]
  end

  def content_types_accepted
    [["application/json", :from_json]]
  end

  private
  def params
    JSON.parse(request.body.to_s)
  end
end

class OrdersResource < JsonResource
  def allowed_methods
    ["GET", "POST"]
  end

  def to_json
    {
      :orders => Order.all
    }.to_json
  end

  def create_path
    @id = Order.next_id
    "/orders/#@id"
  end

  def post_is_create?
    true
  end

  private
  def from_json
    order = Order.new(params).save(@id)
  end
end

class OrderResource < JsonResource
  def allowed_methods
    ["GET", "DELETE", "PUT"]
  end

  def id
    request.path_info[:id].to_i
  end

  def delete_resource
    Order.find(id).destroy
    true
  end

  def to_json
    order = Order.find(id)
    order.to_json
  end

  private
  def from_json
    order = Order.new(params)
    order.save(id)
  end
end

App = Webmachine::Application.new do |app|
  app.routes do
    add ["orders"], OrdersResource
    add ["orders", :id], OrderResource
    add ['trace', '*'], Webmachine::Trace::TraceResource
  end
end
