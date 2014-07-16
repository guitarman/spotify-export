class OutputGenerator
  attr_reader :filename, :tracks

  def initialize(tracks, progressbar, filename=nil)
    @filename = filename
    @tracks = tracks
    @progressbar = progressbar
  end

  def open_file
    @file = File.new(@filename, 'w:utf-8')
  end

  def close_file
    @file.close
  end

  def generate
    @filename = 'output.txt' unless filename
    open_file
    @tracks.each_with_index do |track, count|
      # Sanity check
      unless track.nil?
        @file.write generate_track_record(track)
        @progressbar.increment
      end
    end
    close_file
  end
end

class M3uGenerator < OutputGenerator

  def open_file
    super
    @file.write "#EXTM3U\n"
  end

  def generate_track_record(track)
    track.m3u_record
  end
end

class PlainTextGenerator < OutputGenerator

  def generate_track_record(track)
    "#{ track.name } -- #{ track.artist } -- #{ track.album }\n"
  end
end
