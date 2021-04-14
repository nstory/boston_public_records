class Line
  RE = / {3,}/

  attr_reader :line

  def initialize(line)
    @line = line
  end

  def field_count
    offsets.count + 1
  end

  def offsets
    return [] unless /[^\s]/.match(line)
    last_offset = $~.offset(0).first
    a = []
    loop do
      md = RE.match(@line, last_offset)
      break unless md
      last_offset = md.offset(0)[1]
      a << last_offset
    end
    a
  end

  def fields(offsets)
    ([0] + offsets + [2**32]).each_cons(2).map do |start_idx, end_idx|
      (@line[start_idx ... end_idx] || "").strip
    end
  end
end
