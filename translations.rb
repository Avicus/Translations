#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require 'open-uri'
require 'zip'

@project_id = 'atlas-game-manager'
@langs = {
    'en' => 'en',
    'de' => 'de',
    'es-ES' => 'es',
    'en-PT' => 'en_PT',
    'sv-SE' => 'sv'
}
@files = {
    'atlas.xml' => 'target/atlas/%s.xml',
    'docs.yml' => 'target/docs/%s.yml',
}


program :name, './translations'
program :version, '0.0.1'
program :description, 'Builds translations from translate.avicus.net into proper folders.'

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

      say 'Downloading translations...'
      FileUtils.mkpath('target')
      open('target/all.zip', 'wb') do |file|
        file << open(download_url(key)).read
      end
      extract('target/all.zip')

      @langs.each do |lang, rename|
        @files.each do |file, format|
          target = format % rename
          say target

          dir = File.expand_path('..', target)
          FileUtils.mkdir_p(dir)

          say File.join(lang, file) + "->" + dir
          FileUtils.cp(File.join('target', 'all', lang, file), target)
        end
      end
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
  "https://api.crowdin.com/api/project/#{@project_id}/export?key=#{key}"
end

def download_url(key, lang = 'all')
  "https://api.crowdin.com/api/project/#{@project_id}/download/#{lang}.zip?key=#{key}"
end