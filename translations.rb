#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require 'open-uri'
require 'zip'

PROJECT_ID = 'atlas-game-manager'

program :name, './translations'
program :version, '0.0.1'
program :description, 'Builds translations from translate.avicus.net into proper folders.'

command :list do |c|
  c.syntax = './translations list [api-key]'
  c.description = 'View the translation files.'
  c.action do |args, options|
    # Do something or c.when_called Avicus translations::Commands::List
  end
end

command :build do |c|
  c.syntax = './translations build [api-key]'
  c.description = 'Build the translation files.'
  c.action do |args, options|
    if args.length != 1
      say 'Please specify your API key.'
    else
      key = args[0]
      say 'Exporting new translations...'
      open(export_url(key)).read

      open('all.zip', 'wb') do |file|
        file << open(download_url(key)).read
      end
      extract('all.zip')
    end
    # Do something or c.when_called Avicus translations::Commands::Build
  end
end

def extract(zip)
  folder = zip.gsub('.zip', '')
  FileUtils.rm_rf(folder)

  Zip::File.open(zip) do |zipfile|
    zipfile.each do |file|
      path = File.join(folder, file.name)
      FileUtils.mkdir_p(File.dirname(path))
      zipfile.extract(file, path)
    end
  end
end


def export_url(key)
  "https://api.crowdin.com/api/project/#{PROJECT_ID}/export?key=#{key}"
end

def download_url(key, lang = 'all')
  "https://api.crowdin.com/api/project/#{PROJECT_ID}/download/#{lang}.zip?key=#{key}"
end