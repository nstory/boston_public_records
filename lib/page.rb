require_relative "./line.rb"

class Page
  attr_reader :page_num

  def initialize(page, page_num)
    @page = page
    @page_num = page_num
  end

  def extract(field_count, row_regexp)
    offs = offsets(field_count)
    unless offs
      $logger.warn "unable to find offsets page #{@page_num}"
      return []
    end
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
    result.map! { |row| row.map(&:strip) }
    result
  end

  def self.from_text(text)
    # pdftotext inserts a "page break" between each page
    text.split("\f").each_with_index.map do |t,i| 
      Page.new(t, i+1)
    end
  end

  def lines
    @lines ||= @page.each_line.map { |l| Line.new(l) }
  end

  def offsets(field_count)
    # some pages have manual overrides
    key = "PAGE#{page_num}"
    if ENV[key]
      offs = ENV[key].split(",").map(&:to_i)
      raise "ENV[#{key}] = #{ENV[key]} does not match field_count #{field_count}" unless offs.count == field_count-1
      return offs
    end

    # determine the offsets automatically
    selected_lines = lines.select { |l| l.field_count == field_count }
    (selected_lines.reverse.group_by(&:offsets).max_by {|k,v| v.count } || []).first
  end
end
