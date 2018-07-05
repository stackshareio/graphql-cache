# frozen_string_literal: true

class TestCache
  def write(key, doc, opts={})
    cache[key] = doc
  end

  def read(key)
    cache[key]
  end

  def cache
    @cache ||= {}
  end

  def clear
    @cache = {}
  end
end
