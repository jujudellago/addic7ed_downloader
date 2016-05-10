require 'httparty'
require 'nokogiri'

module Addic7edDownloader
  class Search
    BASE_URL = 'http://www.addic7ed.com'.freeze
    DEFAULTS = {
      lang: 'en',
      tags: [],
      path: './'
    }.freeze

    attr_accessor :showname, :season, :episode, :lang, :tags, :path

    def self.by_filename(filename, options = {})
      showname = filename[SHOWNAME_REGEXP, 1].strip
      season   = filename[SEASON_REGEXP, 1].to_i
      episode  = filename[EPISODE_REGEXP, 1].to_i
      options[:tags] = filename[TAGS_REGEXP, 1].split(TAGS_FILTER_REGEXP)

      new(showname, season, episode, options)
    end

    def self.by_string(search_string, options = {})
      showname = search_string[SHOWNAME_REGEXP, 1].strip
      season   = search_string[SEASON_REGEXP, 1].to_i
      episode  = search_string[EPISODE_REGEXP, 1].to_i
      options[:tags] = options[:filename][TAGS_REGEXP, 1].split(TAGS_FILTER_REGEXP) if options[:filename]

      new(showname, season, episode, options)
    end

    def initialize(showname, season, episode, options = {})
      @showname = showname
      @season = season.to_i
      @episode = episode.to_i

      opts = DEFAULTS.merge(options)
      @lang, @tags, @path = opts.values_at(:lang, :tags, :path)
    end

    def results
      @results ||= build_subtitles_list
    end

    def find_best_subtitle
      return if results.empty?

      # We can refine the search with tags
      # Only version match
      unless @tags.empty?
        results.each do |subtitle|
          return subtitle if @tags.include?(subtitle.version) && subtitle.completed?
        end
      end

      # If no matches, return most downloaded
      results.first
    end

    def download_best
      download_subtitle(find_best_subtitle)
    end

    def download_subtitle(subtitle)
      return unless subtitle

      # Addic7ed needs the correct Referer to be set
      response = HTTParty.get(
        BASE_URL + subtitle.url,
        headers: { 'Referer' => url, 'User-Agent' => USER_AGENTS.sample }
      )

      raise unless response.headers['content-type'].include? 'text/srt'

      filename = response.headers['content-disposition'][/filename=\"(.+?)\"/, 1]
      open(filename, 'w') { |f| f << response }

      # return subtitle filename
      filename
    end

    private

    def page
      @page ||= Nokogiri::HTML(HTTParty.get(url, headers: { 'User-Agent' => USER_AGENTS.sample }))
    end

    def url
      @url ||= URI.encode("#{BASE_URL}/serie/#{@showname}/#{@season}/#{@episode}/#{LANGUAGES[@lang][:id]}")
    end

    def build_subtitles_list
      # If it doesn't find the episode it redirects to the homepage
      return [] if page.at('#containernews')

      # If it doesn't find the subtitle it shows a message
      return [] if page.at(%q(font:contains("Couldn't find any subs")))

      # Create a list with results
      subtitles = page.css('div#container95m').each_with_object([]) do |subtitle, list|
        list << Subtitle.new(subtitle) if subtitle.at('.NewsTitle')
      end

      # We return the completed subtitles, ordered by downloads desc
      # Using bang methods for memory performance
      subtitles.select(&:completed?).sort!.reverse!
    end
  end
end
