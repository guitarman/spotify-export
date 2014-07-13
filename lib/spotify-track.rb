require 'net/http'
require 'json'
require_relative 'spotify-cache'

class SpotifyTrack
  attr_reader :local, :uri

  def initialize(uri)
    @local = uri.include? ':local:'
    @uri   = uri
  end

  def album
    attributes[:album]
  end

  def artist
    attributes[:artist]
  end

  def name
    attributes[:name]
  end

  def duration
    attributes[:duration]
  end

  def m3u_record
    "#EXTINF:#{duration}, #{artist} - #{name}\n#{uri}\n"
  end

  private

  def attributes
    @attributes ||= begin
      cache = SpotifyCache.where(uri: uri).first

      if cache.blank?
        get_track_attributes
      else
        { name: cache[:name], artist: cache[:artist], album: cache[:album], duration: cache[:duration] }
      end
    end
  end

  def cache_track(cache_name, cache_artist, cache_album, cache_duration)
    SpotifyCache.create(uri: uri,
                        name: cache_name,
                        artist: cache_artist,
                        album: cache_album,
                        duration: cache_duration)
  end

  def format_artists(artists)
    artist_list = []

    artists.each do |artist|
      artist_list << artist["name"]
    end

    artist_list.join(", ")
  end

  def get_track_attributes
    if local
      # The array should be length 6
      # ["spotify", "local", "artist", "album", "song title", "duration"]
      uriArr = uri.split(':')
      name   = URI.decode(uriArr[4].gsub('+', ' '))
      album  = URI.decode(uriArr[3].gsub('+', ' '))
      artist = URI.decode(uriArr[2].gsub('+', ' '))
      duration = URI.decode(uriArr[5].gsub('+', ' '))
    else
      target  = URI.parse("http://ws.spotify.com/lookup/1/.json?uri=#{ uri }")
      http    = Net::HTTP.new(target.host, target.port)
      request = Net::HTTP::Get.new(target.request_uri)

      begin
        response = http.request(request)
        json     = JSON.parse(response.body)
      rescue Errno::ECONNREFUSED, JSON::ParserError
        puts "Spotify API error. Retrying in five seconds..."
        sleep 5
        retry
      end

      name   =  json["track"]["name"]
      artist =  format_artists( json["track"]["artists"] )
      album  =  json["track"]["album"]["name"]
      duration = json["track"]["length"].to_f.round

      cache_track(name, artist, album, duration) if response.code == "200"
    end

    { name: name, artist: artist, album: album, duration: duration }
  end

end
