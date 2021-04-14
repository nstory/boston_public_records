require_relative "../src/page.rb"

describe Page do
  let(:text) { IO.read("#{__dir__}/#{filename}", encoding: "UTF-8") }
  let(:page) { Page.new(text, 1) }
  let(:field_count) { 7 }
  let(:rows) { page.extract(field_count, /^\s*[A-Z]\d{3,}-\d{6}/) }

  describe "page1" do
    let(:filename) { "page1.txt" }
    it "parses a row" do
      row = rows.first
      expect(row[0]).to eql("B000001-010120")
    end
  end

  describe "page256" do
    let(:filename) { "page256.txt" }
    it "parses a row" do
      row = rows.first
      expect(row[0]).to eql("R001167-121620")
    end
  end

  describe "police" do
    let(:field_count) { 8 }
    let(:filename) { "police.txt" }
    it "parses a row" do
      expect(rows.first[0]).to eql("R001011-111720")
    end
  end
end
