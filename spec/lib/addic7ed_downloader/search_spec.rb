require 'spec_helper'

describe Addic7edDownloader::Search do
  subject { build :search }
  let(:success_url) { 'http://www.addic7ed.com/serie/Game+Of+Thrones/6/2/1' }

  before(:each) do
    stub_request(:get, success_url).to_return File.new('spec/http_stubs/addic7ed_successful_search.http')
  end

  it 'generates Subtitle instances' do
    expect(subject.results.first).to be_a Addic7edDownloader::Subtitle
  end
end
