require 'bundler'
Bundler.setup

require 'erb'
require 'faye'
require 'sinatra'

CurrentURL = { 'address' => '/placeholder' }
FayeServer = Faye::RackAdapter.new(Sinatra::Application, :mount => '/faye', :timeout => 20)
FayeClient = FayeServer.get_client

EM.schedule do
  FayeClient.subscribe('/update_devices') do |msg|
    url = URI.encode(msg["address"])
    url.insert(0, 'http://') unless url =~ /^(https?|ftp):/
    CurrentURL.replace('address' => url)

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

