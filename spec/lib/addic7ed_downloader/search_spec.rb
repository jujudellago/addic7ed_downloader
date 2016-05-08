require 'spec_helper'

describe Addic7edDownloader::Search do
  subject { build :search }

  before(:each) do
    stub_request(:get, url).to_return File.new('spec/http_stubs/addic7ed_successful_search.http')
  end
end
