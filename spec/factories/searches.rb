FactoryGirl.define do
  factory :search, class: Addic7edDownloader::Search do
    initialize_with { new('Game Of Thrones', 6, 2) }
  end
end
