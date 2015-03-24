require 'sinatra'
require 'haml'

configure do
  ## Configure these ##
  # The name of the station being streamed
  set :station, 'Sinatra Radio'
  # The url of icecast/shoutcast server's status page.
  set :server_status_page, 'http://example.com:8000/server_status'

  ## Don't mess with these unless you know what you are doing ##
  set :streamctrlver, '0.2' # Elegant? No. Does it work? Yes.
  set :environment, :production
  set :bind => '0.0.0.0', :port => 80
end

helpers do
  # returns 'on' or 'off'
  def status_str
    stream_on? ? 'on' : 'off'
  end

  # returns true or false if darkice is running or not
  def stream_on?
    reset_pid
    !`pgrep darkice`.empty? || @pid != 0
  end

  # Attempts to kill darkice with SIGTERM
  def kill_stream
    return true unless stream_on? # Stream is dead if it's already dead

    Process.detach(@pid)          # Detach the process, should already be done
    system('pkill darkice')       # Kill anything related to darkice

    reset_pid

    !stream_on?                   # If it's dead, return true for success
  end

  # Attempts to start darkice
  def start_stream
    return true if stream_on?

    @pid = spawn('darkice')     # Start darkice
    Process.detach(@pid)        # Let the process die if it wants

    reset_pid

    stream_on?                  # If it's on, true for success
  end

  # Reset (or set) the pid of darkice (kinda)
  def reset_pid
    @pid ||= 0
    @pid = 0 if `pgrep darkice`.empty?
  end

  # Nuke darkice in case of a crash
  def mega_kill
    system('pkill -9 darkice')

    reset_pid

    !stream_on?
  end
end

# Main menu
get '/' do
  haml :root
end

# Attempt to start the stream
get '/start' do
  if stream_on?
    haml '%h3 The stream is already on!'
  else
    @status = start_stream
    haml :start
  end
end

# Attempt to stop the stream
get '/stop' do
  if !stream_on?
    haml '%h3 The stream is already off!'
  else
    @status = kill_stream
    haml :stop
  end
end

# NOTE ABOUT THE RESTART FEATURE
# This system was designed with an auto-login enabled
# Raspberry Pi, so it says it will take ~60 seconds.
# This may or may not be true in other cases, modify
# the necessary haml files to fit your needs.

# Confirm the restart is intentional
get '/molly-guard' do
  haml :molly
end

# Restart the computer, but must be activated from
# /molly-guard, or rather be referred from there.
get '/pushed-the-big-red-button' do
  if request.referrer =~ /molly-guard/
    headers \
      "Refresh" => "60; request.base_url"
    haml :reboot
  else
    redirect to('/molly-guard')
  end
end
