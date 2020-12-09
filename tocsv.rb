require "csv"
require "pry"

def to_text(file)
  `pdftotext -layout "#{file}" -`
end

class Line
  RE = / {3,}/

  attr_reader :line

  def initialize(line)
    @line = line
  end

  def field_count
    @line.split(RE).count
  end

  def offsets
    a = [0]
    loop do
      md = RE.match(@line, a.last)
      break unless md
      end_offset = md.offset(0)[1]
      a << end_offset
    end
    a
  end

  def fields(offsets)
    offsets.map do |off|
      ((@line[off .. -1] || "").split(RE).first || "").strip
    end
  end
end

class Page
  def initialize(page)
    @page = page
  end

  def extract(field_count, row_regexp)
    offs = offsets(field_count)
    result = []
    current_fields = nil
    lines.each do |l|
      if row_regexp =~ l.line
        result << current_fields if current_fields
        current_fields = l.fields(offs)
      elsif /^\s*$/ =~ l.line && current_fields
        result << current_fields
        current_fields = nil
      elsif current_fields
        l.fields(offs).each_with_index do |f,i|
          current_fields[i] += " #{f}"
        end
      end
    end
    result << current_fields if current_fields
    result
  end

  def self.from_text(text)
    # pdftotext inserts a "page break" between each page
    text.split("\f").map { |t| Page.new(t) }
  end

  private
  def lines
    @lines ||= @page.each_line.map { |l| Line.new(l) }
  end

  def offsets(field_count)
    # find a representative line containing all fields
    rep_line = lines.select { |l| l.field_count == field_count }[1]
    raise "no representative line found!" unless rep_line
    rep_line.offsets
  end
end

def tocsv(filename, field_count, row_regexp)
  text = to_text(filename)
  pages = Page.from_text(text)
  pages.each do |page|
    rows = page.extract(field_count, row_regexp)
    rows.each { |r| puts r.to_csv }
  end
end

filename = ARGV.fetch(0)
field_count = ENV.fetch('FIELD_COUNT').to_i
row_regexp = Regexp.new(ENV.fetch('ROW_REGEXP'))
tocsv(filename, field_count, row_regexp)
