module Addic7edDownloader
  module SearchString
    def self.search(search_string, options = {})
      showname = search_string[SHOWNAME_REGEXP, 1].strip
      season   = search_string[SEASON_REGEXP, 1].to_i
      episode  = search_string[EPISODE_REGEXP, 1].to_i
      options[:tags] = options[:filename][TAGS_REGEXP, 1].split(TAGS_FILTER_REGEXP)

      Search.new(showname, season, episode, options)
    end
  end
end
