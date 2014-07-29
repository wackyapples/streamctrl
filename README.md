# StreamCtrl

A duct-tape-and-bubble-gum web interface to control an audio streaming source. Originally designed for turning [DarkIce][darkice] on and off on a [Raspberry Pi][pi].

## Set Up

### Requirements
 * [DarkIce][darkice] - Should be version agnostic.
 * [Ruby][ruby] >= 1.9.3 - (Should be installed on most (non-Windows) systems.)
 * [Sinatra][sinrb] >= 1.4.5
 * [haml] >= 4.0.5
 * (recommended) [thin] >= 1.6.2

### Installation

There is no formal install procedure, eg this is not a Ruby gem. If using StreamCtrl on a Raspberry Pi, or most other Linux-based systems, Ruby should be installed. DarkIce, however, must be installed separately. There is a version available in the Debian (and Raspbian) repositories that does not include support for lame (MP3). If MP3 support is needed, DarkIce will need to be complied from source, but that isn't too hard. Steffen Müller has a good [guide][diguide] on how to build DarkIce on a Raspberry Pi with Raspbian.

A general guide to setting up StreamCtrl would be approximately the following:

 1. Download, build, and configure DarkIce (see above).
 2. Download StreamCtrl. Either clone the git repo or download the [zip].
   * To clone the repo, just run `git clone https://github.com/wackyapples/streamctrl.git` in the directory the StreamCtrl directory will be saved in.
 3. Install Ruby dependencies.
   * There are two options, either install them all automatically with `bundle install` or install them manually with `gem install sinatra haml thin`.
   * These commands may need to be prefaced with `sudo` if a permissions error occurs or rvm is being used.
 4. Configure StreamCtrl (see below).
 5. Use StreamCtrl.

## Configuration

There are two main options that need to be customized for StreamCtrl. Both of which are at the top of the `streamcontrol.rb` file. It looks like this:
```ruby
configure do
  ## Configure these ##
  # The name of the station being streamed
  set :station, 'Sinatra Radio'
  # The url of icecast/shoutcast server's status page.
  set :server_status_page, 'http://example.com:8000/server_status'
```

Change `Sinatra Radio` to the name of the station being streamed and `http://example.com:8000/server_status` to the status page of the IceCast/SHOUTcast server.

## Usage

### Running StreamCtrl
StreamCtrl must be run as a privileged user, at least one with the permissions that DarkIce needs and can shutdown the device. The easiest way to do this is to run StreamCtrl (and thus DarkIce and shutdown) as root. If streaming is the device's only job (like a Raspberry Pi), this isn't a huge issue. If this *is* a security concern, StreamCtrl must be configured and modified manually to work with a non-privileged user.

Ruby is being used without [RVM][rvm], then simply `sudo ruby streamctrl.rb` will start the server up. RVM is being used, `rvmsudo` must be used, information on setting up `rvmsudo` is available in the RVM [documentation][rvmsudo].

### Running at Startup

At present, the best way to start StreamCtrl is to add it to root's crontab (`sudo crontab -e`). In the future a systemd unit may be written (most likely when Debian / Raspbian move to systemd) or an init.d script.

#### Without RVM
RVM is not being used, this line will be sufficient to add to root's contab:
```
@reboot    ruby path/to/streamctrl.rb
```
The path must be changed to the correct absolute path to streamctrl.rb.

#### With RVM
If RVM is being used, there are a few extra steps to take. Primarily, wrappers will need to be used to deal with Ruby versions and gemsets. RVM's [documentation][rvmcron] on usage with cron has more information.

### Using the Web Interface

The web interface for StreamCtrl is, by default, served on port 80 of the device it is running on. So to access the web interface, navigate to the ip address of the device in a web browser. Initially, the Main Menu will be displayed.

The interface itself is very simple. At the top of the page is the station's name, and directly below is the status of the stream: on or off.

The Main Menu has four options that are all fairly self-explanatory.

* *Start* - Attempts to start the stream if not already started.
* *Stop*  - Attempts to stop the stream if not already stopped.
* *Server Status* - A link to the external server status page set in the configuration as `server_status_page`.
* *Reboot* - Reboots the device, after a confirmation page.

If start or stop are selected while the stream is already on or off, a notice will be given that no action has been taken.

Clicking reboot will bring up a page confirming the restart (a kind of [molly-guard][mg]) to prevent accidental (and annoying) restarts. The confirmation page must be accessed before the page that actually initiates the restart.

### From the Command Line

Controlling (including automating) the stream remotely is able to be done over the command line by simply requesting the appropriate pages with a tool like curl or wget. To start or start the stream, the */start* or */stop* pages have to be requested. The basic pattern would be:

Start the stream:
```
curl http://ip.of.streamer/start
```

Stop the stream:
```
curl http://ip.of.streamer/stop
```

Restart (be careful!):
```
curl --referer http://ip.of.streamer/molly-guard http://ip.of.streamer/pushed-the-big-red-button
```

## To-do List

 * Multiple configurations of DarkIce able to be used
 * Use of other streaming software
 * Built-in scheduling interface
 * Better Main Menu design
 * Better handling of restart
 * Write rspec specs
 * Proper start-up scripts (systemd/init.d)
 * Better application packaging

[darkice]: http://darkice.org/
[pi]:      http://www.raspberrypi.org/
[ruby]:    https://www.ruby-lang.org/
[sinrb]:   http://www.sinatrarb.com/
[haml]:    http://haml.info/
[thin]:    http://code.macournoyer.com/thin/
[diguide]: http://www.t3node.com/blog/live-streaming-mp3-audio-with-darkice-and-icecast2-on-raspberry-pi/
[zip]:     https://github.com/wackyapples/streamctrl/archive/master.zip
[rvm]:     https://rvm.io/
[rvmsudo]: https://rvm.io/integration/sudo
[rvmcron]: https://rvm.io/integration/cron
[mg]:      https://en.wikipedia.org/wiki/Big_red_button#Molly-guard