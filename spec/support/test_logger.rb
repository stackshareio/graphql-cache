# frozen_string_literal: true

class TestLogger
  %i(
    debug
    info
    warn
    error
    fatal
    unknown
  ).each do |lvl|
    define_method lvl do |msg|
      # msg
    end
  end
end
