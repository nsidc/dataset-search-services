# frozen_string_literal: true

class String
  def to_underscore!
    gsub!(/(.)([A-Z])/, '\1_\2') || self
    self && downcase!
  end

  def to_underscore
    dup.to_underscore!
  end

  def nil_or_whitespace?
    strip.empty?
  end
end

class NilClass
  def nil_or_whitespace?
    true
  end
end
