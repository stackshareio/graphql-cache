# frozen_string_literal: true

class TestCache
  def write(key, doc, opts={})
    # we duplicate the value to get rid of ruby object level caching
    cache[key] = ::Marshal.load(::Marshal.dump(doc))
  end

  def read(key)
    ::Marshal.load(::Marshal.dump(cache[key]))
  end

  def cache
    @cache ||= {}
  end

  def clear
    @cache = {}
  end
end
