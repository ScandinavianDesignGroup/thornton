require 'bundler'
Bundler.setup

require 'erb'
require 'cgi'
require 'faye'
require 'sinatra'

require './viewport-parser'

CurrentHost = ""
CurrentURL = { 'address' => '/placeholder' }
FayeServer = Faye::RackAdapter.new(Sinatra::Application, :mount => '/faye', :timeout => 20)
FayeClient = FayeServer.get_client

EM.schedule do
  FayeClient.subscribe('/update_devices') do |msg|
    uri = Addressable::URI.heuristic_parse(msg["address"])
    uri.path = "/" if uri.path.empty?

    unless ['http', 'https'].include?(uri.scheme)
      # Trigger the code below
      uri.host = nil
    end

    # Very funny!
    if uri.host.nil? || uri.host == CurrentHost
      uri.scheme = 'http'
      uri.host = nil
      uri.port = nil
      uri.path = "/placeholder"
    end

    if uri.host
      parser = ViewportParser.new(uri.to_s)
      doc = parser.parse
    end

    CurrentURL.replace('address' => uri.to_s, 'viewport' => doc.viewport.to_s)

    # TODO: Find viewport
    FayeClient.publish('/url', CurrentURL)
  end
end

get '/' do
  erb :index
end

get '/controlpanel' do
  CurrentHost.replace(request.env['HTTP_HOST'])
  erb :admin
end

get '/placeholder' do
  erb :placeholder
end

