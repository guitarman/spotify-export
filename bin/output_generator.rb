class OutputGenerator
  attr_reader :filename, :tracks

  def initialize(tracks, progressbar, filename=nil)
    @filename = filename
    @tracks = tracks
    @progressbar = progressbar
  end

  def generate
    @filename = "output.txt" unless filename
    @tracks.each_with_index do |track, count|
      # Sanity check
      unless track.nil?
        generate_track_record(track)
        @progressbar.increment
      end
    end
  end
end

class M3uGenerator < OutputGenerator

  def generate_track_record(track)
    puts track.m3u_record
  end
end

class PlainTextGenerator < OutputGenerator

  def generate_track_record(track)
    puts "#{ track.name } -- #{ track.artist } -- #{ track.album }\n"
  end
end
