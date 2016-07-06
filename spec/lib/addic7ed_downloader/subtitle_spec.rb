require 'spec_helper'

describe Addic7edDownloader::Subtitle do
  subject { build :subtitles }
  let(:subtitles_uncompleted) { build :subtitles_uncompleted }

  it 'parses the version' do
    expect(subject.version).to eq('FLEET')
  end

  it 'parses the language' do
    expect(subject.language).to eq('English')
  end

  it 'parses the download url link' do
    expect(subject.url).to eq('/updated/1/111620/0')
  end

  it 'parses the notes' do
    expect(subject.notes).to eq('Resync of DIMENSION | Works with WEB-DL')
  end

  it 'parses the number of downloads' do
    expect(subject.downloads).to eq(45009)
  end

  context '#completed?' do
    it 'returns true if completed' do
      expect(subject.completed?).to be_truthy
    end

    it 'returns false if not completed' do
      expect(subtitles_uncompleted.completed?).to be_falsey
    end
  end

  context '#hearing_impaired?' do
    it 'returns true if hearing_impaired' do
      expect(subject.hearing_impaired?).to be_truthy
    end

    it 'returns false if not hearing_impaired' do
      expect(subtitles_uncompleted.hearing_impaired?).to be_falsey
    end
  end

  context '#works_with?' do
    it 'returns true if it matches the version' do
      expect(subject.works_with?('FLEET')).to be_truthy
    end

    it 'returns true if the notes say so' do
      expect(subject.works_with?('WEB-DL')).to be_truthy
    end

    it 'returns false if nothing matches' do
      expect(subject.works_with?('DIMENSION')).to be_falsey
    end

    it "doesn't explode if notes are empty" do
      expect(subtitles_uncompleted.works_with?('POTATO')).to be_falsey
    end
  end

  it 'orders by downloads count' do
    subs = [subject, subtitles_uncompleted]
    expect(subs.sort).to eq([subtitles_uncompleted, subject])
  end
end
