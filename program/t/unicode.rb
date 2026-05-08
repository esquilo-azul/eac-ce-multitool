#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

Class.new do
  runner_with :help do
    pos_arg :string
  end

  def run
    parsed.string.chars.each { |c| infov c, c.ord.to_s(16) }
  end
end.run
