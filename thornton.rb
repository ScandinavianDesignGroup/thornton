require 'bundler'
Bundler.setup

require 'erb'
require 'cgi'
require 'faye'
require 'sinatra'

require './viewport-parser'

DefaultViewport = "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0"
CurrentHost = ""
CurrentURL = { 'address' => '/placeholder', 'viewport' => DefaultViewport }
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
      uri = "/placeholder"
    end

    CurrentURL.replace('address' => uri.to_s)#, 'viewport' => (doc.viewport || DefaultViewport))
    FayeClient.publish('/url', CurrentURL)
  end
end

set :public, File.dirname(__FILE__) + '/public'

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

