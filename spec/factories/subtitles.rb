FactoryGirl.define do
  factory :subtitles, class: Addic7edDownloader::Subtitle do
    params = Nokogiri::HTML::DocumentFragment.parse(File.read('spec/http_stubs/subtitle.http'))
    initialize_with { new(params) }
  end

  factory :subtitles_uncompleted, class: Addic7edDownloader::Subtitle do
    params = Nokogiri::HTML::DocumentFragment.parse(File.read('spec/http_stubs/subtitle_uncompleted.http'))
    initialize_with { new(params) }
  end
end
