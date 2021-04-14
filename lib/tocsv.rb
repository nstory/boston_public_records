require "csv"
require "logger"
require "pry"

require_relative "./page.rb"

$logger = Logger.new(STDERR)

def to_text(file)
  `pdftotext -layout "#{file}" -`
end

def tocsv(filename, field_count, row_regexp)
  text = to_text(filename)
  pages = Page.from_text(text)
  pages.each do |page|
    rows = page.extract(field_count, row_regexp)
    $logger.warn "no rows found on page #{page.page_num}" if rows.empty?
    rows.each { |r| puts r.to_csv }
  end
end

filename = ARGV.fetch(0)
field_count = ENV.fetch('FIELD_COUNT').to_i
row_regexp = Regexp.new(ENV.fetch('ROW_REGEXP'))
tocsv(filename, field_count, row_regexp)
