require_relative "../src/line.rb"

describe Line do
  it "finds offsets" do
    line = Line.new("   foo    bar")
    expect(line.offsets).to eql([10])
    expect(line.field_count).to eql(2)
  end

  it "gets fields using offsets" do
    line = Line.new("abcdef")
    expect(line.fields([3])).to eql(["abc", "def"])
  end

  it "gets fields for short line" do
    line = Line.new("abc")
    expect(line.fields([4])).to eql(["abc", ""])
  end
end
