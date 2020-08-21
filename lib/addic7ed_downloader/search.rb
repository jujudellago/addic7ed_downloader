require 'httparty'
require 'nokogiri'

module Addic7edDownloader
  class Search
    BASE_URL = 'http://www.addic7ed.com'.freeze
    DEFAULTS = {
      lang: 'en',
      tags: []
    }.freeze

    attr_accessor :showname, :season, :episode, :lang, :tags, :path

    def self.by_filename(filename, options = {})
      showname = filename[SHOWNAME_REGEXP, :showname].strip
      season   = filename[SEASON_EPISODE_REGEXP, :season].to_i
      episode  = filename[SEASON_EPISODE_REGEXP, :episode].to_i
      options[:tags] = filename[TAGS_REGEXP, :tags].split(TAGS_FILTER_REGEXP)

      new(showname, season, episode, options)
    rescue NoMethodError
      # Failed to parse
      nil
    end
    # search = Addic7edDownloader::Search.by_attributes("24",1,5, {lang: "en"})
    
    def self.by_attributes(title, season_number, episode_number, options={})
        #options[:tags] = filename[TAGS_REGEXP, :tags].split(TAGS_FILTER_REGEXP)
        new(title, season_number, episode_number, options)
      rescue NoMethodError
        # Failed to parse
        nil            
    end

    def initialize(showname, season, episode, options = {})
      # Replace dots with spaces only if not followed by a space (Mr. Robot)
      @showname = showname.gsub(/\.(\S)/, ' \1')
      @season = season.to_i
      @episode = episode.to_i

      opts = DEFAULTS.merge(options)
      @lang, @tags = opts.values_at(:lang, :tags)
    end

    def to_s
      "#{@showname.split.map(&:capitalize).join(' ')} #{sprintf('%02dx%02d', @season, @episode)}"
    end

    def extract_tags(filename)
      @tags = filename[TAGS_REGEXP, :tags].split(TAGS_FILTER_REGEXP) if filename
    end

    def results
      @results ||= build_subtitles_list
    end

    def find_best_subtitle
      return if results.empty?

      # We can refine the search with tags
      unless @tags.empty?
        results.each do |subtitle|
          return subtitle if @tags.any? { |tag| subtitle.works_with?(tag) }
        end
      end

      # If no matches, return most downloaded
      results.first
    end

    def download_best(path = './')
      download_subtitle(find_best_subtitle, path)
    end

    def download_subtitle(subtitle, path = './')
      return unless subtitle

      # Addic7ed needs the correct Referer to be set
      response = HTTParty.get(
        BASE_URL + subtitle.url,
        headers: { 'Referer' => url, 'User-Agent' => USER_AGENTS.sample }
      )

      raise unless response.headers['content-type'].include? 'text/srt'

      # Get file name from headers
      filename = response.headers['content-disposition'][/filename=\"(.+?)\"/, 1]
      open(File.join(path, filename), 'w') { |f| f << response }

      # return subtitle filename
      filename
    end

    private

    def page
      @page ||= Nokogiri::HTML(HTTParty.get(url, headers: { 'User-Agent' => USER_AGENTS.sample }))
    end

    def url
      @url ||= "#{BASE_URL}/serie/#{CGI.escape(@showname)}/#{@season}/#{@episode}/#{LANGUAGES[@lang][:id]}"
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
      subtitles.select(&:completed?).sort!.reverse!
    end
  end
end
