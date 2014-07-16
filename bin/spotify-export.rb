#!/usr/bin/env ruby

require 'bundler/setup'
require 'fileutils'
require 'ruby-progressbar'
require_relative '../lib/spotify-playlist'
require_relative 'output_generator'

# Copy the template SQLite file for new users, unless it
# already exists
unless File.exist?("#{ ROOT }/db/spotify-cache.db")
  FileUtils.cp("#{ ROOT }/db/spotify-cache-template.db",
               "#{ ROOT }/db/spotify-cache.db")
end

output      = String.new
playlist    = SpotifyPlaylist.new(ARGV.first)
progressbar = ProgressBar.create(format: "%t: %c/%C |%B|", total: playlist.tracks.size)

if ARGV.second
  output_generator = M3uGenerator.new(playlist.tracks, progressbar, ARGV.second)
else
  output_generator = PlainTextGenerator.new(playlist.tracks, progressbar)
end
output_generator.generate
