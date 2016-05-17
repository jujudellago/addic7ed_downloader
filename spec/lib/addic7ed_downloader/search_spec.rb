require 'spec_helper'

shared_examples 'a file search' do |filename, showname, season, episode, tag|
  context "with #{filename}" do
    let(:search) { described_class.by_filename(filename) }

    it 'parses the showname' do
      expect(search.showname).to eq(showname)
    end

    it 'parses the season' do
      expect(search.season).to eq(season)
    end

    it 'parses the episode' do
      expect(search.episode).to eq(episode)
    end

    it 'generates tags' do
      expect(search.tags).to include(tag) unless tag.empty?
    end
  end
end

describe Addic7edDownloader::Search do
  subject { build :search }
  let(:success_url) { 'http://www.addic7ed.com/serie/Game+Of+Thrones/6/2/1' }

  before(:each) do
    stub_request(:get, success_url).to_return File.new('spec/http_stubs/addic7ed_successful_search.http')
  end

  it 'generates Subtitle instances' do
    expect(subject.results.first).to be_a Addic7edDownloader::Subtitle
  end

  describe '.by_filename' do
    it 'returns nil if the parser was unsuccesful' do
      search = Addic7edDownloader::Search.by_filename('')
      expect(search).to be_nil
    end

    it_behaves_like 'a file search',
                    'Game of Thrones S06E03 1080p HDTV x264-BATV[ettv].mkv',
                    'Game of Thrones', 6, 3, 'BATV'

    it_behaves_like 'a file search',
                    'Game of Thrones S06E03 Oathbreaker 1080p WEB-DL DD5 1 H264-NTb[rartv].mkv',
                    'Game of Thrones', 6, 3, 'WEB-DL'

    it_behaves_like 'a file search',
                    'Game.of.Thrones.S06E03.Oathbreaker.1080p.WEB-DL.DD5.1.H264-NTb[rartv].mkv',
                    'Game of Thrones', 6, 3, 'WEB-DL'

    it_behaves_like 'a file search',
                    'BoJack Horseman - 01x07 - Say Anything.W4F.English.HI.C.orig.Addic7ed.com.avi',
                    'BoJack Horseman', 1, 7, 'W4F'

    it_behaves_like 'a file search',
                    'game of thrones s06e03',
                    'game of thrones', 6, 3, ''

    it_behaves_like 'a file search',
                    'Frasier 1x06 - The Crucible dvdmux ITA-ENG',
                    'Frasier', 1, 6, 'dvdmux'

    it_behaves_like 'a file search',
                    'Scrubs.S06E19.PDTV.XviD-XOR.avi',
                    'Scrubs', 6, 19, 'XOR'
  end
end
