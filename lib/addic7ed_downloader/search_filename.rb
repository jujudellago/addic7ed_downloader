module Addic7edDownloader
  module SearchFilename
    def self.search(filename, options = {})
      showname = filename[SHOWNAME_REGEXP, 1].strip
      season   = filename[SEASON_REGEXP, 1].to_i
      episode  = filename[EPISODE_REGEXP, 1].to_i
      options[:tags] = filename[TAGS_REGEXP, 1].split(TAGS_FILTER_REGEXP)

      Search.new(showname, season, episode, options)
    end
  end
end
