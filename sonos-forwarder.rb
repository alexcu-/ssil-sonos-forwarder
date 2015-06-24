require 'sinatra'
require 'sonos'

system = Sonos::System.new
speaker = system.speakers.first

get '/playing' do
  speaker.now_playing
end