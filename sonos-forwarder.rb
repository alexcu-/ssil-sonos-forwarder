require 'sinatra'
require 'sonos'
require 'ngrok/tunnel'
require 'json'

# Get the sonos
system = Sonos::System.new
speaker = system.speakers.first
unless speaker
	raise "No speaker found"
end
puts "Found a speaker: #{speaker.name}, playing #{speaker.now_playing[:title] || 'nothing'} by #{speaker.now_playing[:artist] || 'no one'}"

# Forward the port
PORT = 8885
set :port, PORT
Ngrok::Tunnel.start({ port: PORT })

puts "Forwarding to #{Ngrok::Tunnel.ngrok_url}"

#
# Get the currently playing song
#
get '/playing' do
  speaker.now_playing.to_json
end

#
# Get the forwarding url
#
get '/forwarding/url' do
  if Ngrok::Tunnel.stopped?
    return "forwarding not running... have you requested /forwarding/start yet?"
  end
  Ngrok::Tunnel.ngrok_url
end

#
# Start forwarding
#
get '/forwarding/start' do
  unless Ngrok::Tunnel.running?
    Ngrok::Tunnel.start({ port: PORT })
  end
  "forwarding port #{PORT} to #{Ngrok::Tunnel.ngrok_url}"
end

#
# Stop forwarding
#
get '/forwarding/stop' do
  if Ngrok::Tunnel.stopped?
    return "forwarding not running... have you requested /forwarding/start yet?"
  end
  Ngrok::Tunnel.stop
  "stopped forwarding"
end

#
# Get ngrok log
#
get '/forwarding/log' do
  if Ngrok::Tunnel.stopped?
    return "forwarding not running... have you requested /forwarding/start yet?"
  end
  Ngrok::Tunnel.log.read
end