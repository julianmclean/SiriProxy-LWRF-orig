# Copyright (C) 2013 by Julian Mclean <mail@julianmclean.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'cora'
require 'siri_objects'
require 'pp'
require 'lightwaverf'

#######
# This is plugin to control LightwaveRF
# It is a Siri wrapper for on LightwaveRF control via Pauly's ruby gem
######

class SiriProxy::Plugin::Lwrf < SiriProxy::Plugin
  
  @room_config = nil
  @debug = false
  
  def initialize(config)
    appname = "SiriProxy-LWRF-JM"
    
  # set debug if requested
    if (config.has_key?("debug"))
      @debug = config["debug"] == true
    else
      @debug = false
    end    
        
    @debug and (puts "[Info - Lwrf] initialize: Debug is on!")

    # load config file
    config_file = File.expand_path('~/.siriproxy/lwrf_config.yml')
    if (File::exists?( config_file ))
      @room_config = YAML.load_file(config_file)
    end

    @debug and (puts "[Info - Lwrf] initialize: Configuration is: #{@room_config}" )
            
    # set the default room
    @default_room = @room_config['default_room']
    
    @debug and (puts "[Info - Lwrf] initialize: Default room is: #{@default_room}" )

    # instantiate the lwrf gem
    @debug and (p "Instantiating LightWaveRF Gem")
    @lwrf = LightWaveRF.new rescue nil

    @debug and (p "[Info - Lwrf] initialize: Complete")
  end
  
  def translate (roomalias, devicealias, moodalias)
    @debug and (puts "[Info - Lwrf] translate_room_device: Executing... ")
    #set defaults
    response = []
    response['room'] = roomalias
    response['device'] = devicealias
    response['mood'] = moodalias
    #convert any aliases
    unless config['room_alias'].nil?
      if config['room_alias'].has_key(roomalias)
        response['room'] = config['room_alias'][roomalias]['room']
        @debug and (puts "[Info - Lwrf] translate_room_device: Translated room is: " + response['room'])
        # translate devicealias if we have one
        unless config['room_alias'][roomalias]['device_alias'].nil? or devicealias == nil
          if config['room_alias'][roomalias]['device_alias'].has_key(devicealias)
            response['device'] = config['room_alias'][roomalias]['device_alias'][devicealias]
            @debug and (puts "[Info - Lwrf] translate_room_device: Translated device is: " + response['device'])
          end      
        end
        # translate moodalias if we have one
        unless config['room_alias'][roomalias]['device_alias'].nil? or devicealias == nil
          if config['room_alias'][roomalias]['device_alias'].has_key(devicealias)
            response['device'] = config['room_alias'][roomalias]['device_alias'][devicealias]
            @debug and (puts "[Info - Lwrf] translate_room_device: Translated device is: " + response['device'])
          end      
        end
      end
    end
    response
  end
  
  #def match_device
  #  @debug and (puts "[Info - Lwrf] match_device: Executing... ")
  #  #loop the devices phrase in the config looking for a match
  #  @room_config['phrases']['device'].each do |phrase|
  #    @debug and (puts "[Info - Lwrf] match_device: Phrase is: #{phrase['match']} ")
  #    regex = "/" + phrase['match'] + "/i"
  #    @debug and (puts "[Info - Lwrf] match_device: Checking regex: #{regex} ")
  #    #look for a match
  #    listen_for regex do | action, device, room |
  #      response = translate(room, device, nil)
  #      @debug and (puts "[Info - Lwrf] match_device: Matched! Sending command")
  #      send_lwrf_command('device', response['room'], response['device'], action)
  #    end
  #  end
  #end
  #
  #def match_mood
  #  @debug and (puts "[Info - Lwrf] match_mood: Executing... ")
  #  #loop the mood phrase in the config looking for a match
  #  @room_config['phrases']['mood'].each do |phrase|
  #    @debug and (puts "[Info - Lwrf] match_mood: Phrase is: #{phrase['match']} ")
  #    regex = "/" + phrase['match'] + "/i"
  #    @debug and (puts "[Info - Lwrf] match_mood: Checking regex: #{regex} ")
  #    #look for a match
  #    listen_for regex do | room, mood |
  #      response = translate(room, nil, mood)
  #      @debug and (puts "[Info - Lwrf] match_device: Matched! Sending command")
  #      send_lwrf_command('mood', response['room'], response['mood'])
  #    end
  #  end
  #end
  #
  #def match_sequence
  #  @debug and (puts "[Info - Lwrf] match_sequence: Executing... ")
  ##loop the mood phrase in the config looking for a match
  #  @room_config['phrases']['sequence'].each do |phrase|
  #    @debug and (puts "[Info - Lwrf] match_sequence: Phrase is: #{phrase['match']} ")
  #    regex = "/" + phrase['match'] + "/i"
  #    @debug and (puts "[Info - Lwrf] match_sequence: Checking regex: #{regex} ")
  #    #look for a match
  #    listen_for regex do | sequence |
  #      @debug and (puts "[Info - Lwrf] match_sequence: Matched! Sending command")
  #      send_lwrf_command('sequence', sequence)
  #    end
  #  end
  #end
  #
  #def match_info
  #  @debug and (puts "[Info - Lwrf] match_info: Executing... ")
  #end

  def send_lwrf_command (type, room, object, action)
    @debug and (puts "[Info - Lwrf] send_lwrf_device: Starting with arguments: type => #{type}, room => #{room}, object => #{object}, action => #{action} ")
    begin
      # call the relevant command
      case type
        when 'device'
          send_lwrf_device room object action
        when 'mood'
          send_lwrf_mood room object
        when 'sequence'
          send_lwrf_sequence object
        else
          @debug and (puts "[Info - Lwrf] send_lwrf_command: Did not recognise command type: " + type)
      end
    rescue Exception
      pp $!
      say "Sorry, I encountered an error"
      @debug and (puts "[Info - Lwrf] send_lwrf_command: Error => #{$!}" )
    end
    @debug and (puts "[Info - Lwrf] send_lwrf_command: Request Completed" )
    request_completed
  end
    
  #calls lwrf for a device
  def send_lwrf_device (roomName, deviceName, action)  
    @debug and (puts "[Info - Lwrf] send_lwrf_device: Starting with arguments: roomName => #{roomName}, deviceName => #{deviceName}, action => #{action} ")
    @lwrf.send(roomName.downcase, deviceName.downcase, action, @debug)
  end
  
  #calls lwrf for a mood
  def send_lwrf_mood (roomName, moodName)
    @debug and (puts "[Info - Lwrf] send_lwrf_mood: Starting with arguments: roomName => #{roomName}, moodName => #{moodName} ")
    @lwrf.mood(roomName.downcase, moodName.downcase, @debug)
  end
  
  #calls lwrf for a sequence
  def send_lwrf_mood (sequenceName)
    @debug and (puts "[Info - Lwrf] send_lwrf_sequence: Starting with arguments: sequenceName => #{sequenceName} ")
    @lwrf.sequence(sequenceName.downcase, @debug)
  end
  
  #main execution
  
  puts "[Info - Lwrf] initialize: Configuration is now: #{@room_config}"

  @room_config['phrases']['device'].each do |phrase|
    @debug and (puts "[Info - Lwrf] match_device: Phrase is: #{phrase['match']} ")
    regex = "/" + phrase['match'] + "/i"
    @debug and (puts "[Info - Lwrf] match_device: Checking regex: #{regex} ")
    #look for a match
    listen_for regex do | action, device, room |
      response = translate(room, device, nil)
      @debug and (puts "[Info - Lwrf] match_device: Matched! Sending command")
      send_lwrf_command('device', response['room'], response['device'], action)
    end
  end

  @room_config['phrases']['mood'].each do |phrase|
    @debug and (puts "[Info - Lwrf] match_mood: Phrase is: #{phrase['match']} ")
    regex = "/" + phrase['match'] + "/i"
    @debug and (puts "[Info - Lwrf] match_mood: Checking regex: #{regex} ")
    #look for a match
    listen_for regex do | room, mood |
      response = translate(room, nil, mood)
      @debug and (puts "[Info - Lwrf] match_device: Matched! Sending command")
      send_lwrf_command('mood', response['room'], response['mood'])
    end
  end

  @room_config['phrases']['sequence'].each do |phrase|
    @debug and (puts "[Info - Lwrf] match_sequence: Phrase is: #{phrase['match']} ")
    regex = "/" + phrase['match'] + "/i"
    @debug and (puts "[Info - Lwrf] match_sequence: Checking regex: #{regex} ")
    #look for a match
    listen_for regex do | sequence |
      @debug and (puts "[Info - Lwrf] match_sequence: Matched! Sending command")
      send_lwrf_command('sequence', sequence)
    end
  end

  #no matches, so try other standard phrases

  #test that the plugin is alive
  listen_for (/test lightwave/i) do
    say "Lightwave control is available!"
    request_completed
  end

end
  
#  
#  #turn a device in a room on or off
#  listen_for /(on|off)(?: the) (.*) in(?: the) (.*)/i do |state,devicealias,roomalias|
  #    if (match = find_zone_device roomalias devicealias)
#      LightWaveRF.new.send match['zone'], match['device'], state, @debug
#    else
#      if (match = find_zone roomalias)
#        say "I don't recognise a device called " + devicealias + " in the " + roomalias
#      else
#        say "I don't know of a device called " + devicealias + " in a room called " + roomalias
#      end
#    end
#    request_completed
#  end
#
#  #set a device in a room to a preset dim level
#  listen_for /(.*) in(?: the) (.*) to (low|mid|high|full)/i do |devicealias,roomalias,preset|
#    if (match = find_zone_device roomalias devicealias)      
#      LightWaveRF.new.send match['zone'], match['device'], preset, @debug
#    else
#      if (match = find_zone roomalias)
#        say "I don't recognise a device called " + devicealias + " in the " + roomalias
#      else
#        say "I don't know of a device called " + devicealias + " in a room called " + roomalias
#      end
#    end
#    request_completed
#  end
#
#  #set a device in a room to a specific dim level
#  listen_for /(.*) in(?: the) (.*) to (.*) percent/i do |devicealias,roomalias,level|
#    if (match = find_zone_device roomalias devicealias)
#      LightWaveRF.new.send match['zone'], match['device'], level.to_i, @debug
#    else
#      if (match = find_zone roomalias)
#        say "I don't recognise a device called " + devicealias + " in the " + roomalias
#      else
#        say "I don't know of a device called " + devicealias + " in a room called " + roomalias
#      end
#    end
#    request_completed
#  end
#
#  #set a mood in a room
#  listen_for /(.*) mood in(?: the) (.*)/i do |moodalias,roomalias|
#    if (match = find_zone_mood moodalias roomalias)
#      LightWaveRF.new.mood match['zone'], match['mood'], @debug
#    else
#      if (match = find_zone roomalias)
#        say "I don't recognise a mood called " + devicealias + " in the " + roomalias
#      else
#        say "I don't know of a mood called " + devicealias + " in a room called " + roomalias
#      end      
#    end
#    request_completed
#  end
#
#  #turn all the devices in a room off
#  listen_for /all the(?: .*) off in(?: the) (.*)/i do |roomalias|
#    if (match = find_zone roomalias)
#      LightWaveRF.new.mood match, "alloff", @debug
#    else
#      say "I don't know of a room called " + roomalias
#    end
#    request_completed
#  end
#
