#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class Integer
  def to_bits
    "#{self}/#{to_s(2)}"
  end
end

class TheRunner
  MAP = {
    E_ERROR: 1,
    E_WARNING: 2,
    E_PARSE: 4,
    E_NOTICE: 8,
    E_CORE_ERROR: 16,
    E_CORE_WARNING: 32,
    E_COMPILE_ERROR: 64,
    E_COMPILE_WARNING: 128,
    E_USER_ERROR: 256,
    E_USER_WARNING: 512,
    E_USER_NOTICE: 1024,
    E_STRICT: 2048,
    E_RECOVERABLE_ERROR: 4096,
    E_DEPRECATED: 8192,
    E_USER_DEPRECATED: 16_384,
    E_ALL: 6143 # 32767 in PHP 5.4.x, 30719 in PHP 5.3.x, 6143 in PHP 5.2.x, 2047 previously
  }.freeze

  runner_with :help do
    desc 'Analisa valor de "error_reporting"'
    pos_arg :value
  end

  def run
    infov 'Value', value.to_bits
    MAP.each do |name, value|
      infov "#{name} (#{value.to_bits})", constant_value_label(value)
    end
  end

  def value
    parsed.value.to_i
  end

  def constant_value_label(value)
    r = constant_value(value)
    r ? r.to_s.green : r.to_s.red
  end

  def constant_value(value)
    self.value.allbits?(value)
  end
end

TheRunner.run
