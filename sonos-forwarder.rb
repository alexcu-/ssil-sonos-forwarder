require 'sinatra'
require 'sonos'
require 'ngrok/tunnel'

# Get the sonos
system = Sonos::System.new
speaker = system.speakers.first

# Forward the port
PORT = 8885
set :port, PORT
Ngrok::Tunnel.start({ port: PORT })

#
# Get the currently playing song
#
get '/playing' do
  speaker.now_playing
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