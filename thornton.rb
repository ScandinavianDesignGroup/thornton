require 'bundler'
Bundler.setup

require 'erb'
require 'cgi'
require 'faye'
require 'sinatra'

CurrentURL = { 'address' => '/placeholder' }
FayeServer = Faye::RackAdapter.new(Sinatra::Application, :mount => '/faye', :timeout => 20)
FayeClient = FayeServer.get_client

EM.schedule do
  FayeClient.subscribe('/update_devices') do |msg|
    uri = Addressable::URI.heuristic_parse(msg["address"])
    uri.path = "/" if uri.path.empty?
    CurrentURL.replace('address' => uri.to_s)

    # TODO: Find viewport
    FayeClient.publish('/url', CurrentURL)
  end
end

get '/' do
  erb :index
end

get '/controlpanel' do
  erb :admin
end

get '/placeholder' do
  erb :placeholder
end

