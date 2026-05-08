#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')
require 'base64'

class Integer
  def to_6bits_array
    r = to_s(2).each_char.map(&:to_i)
    r.unshift(0) while r.count < 6
    r
  end
end

class B64
  class << self
    CHARS = %w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c
               d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 + /].freeze

    def char2int(char)
      CHARS.index(char) || raise("Unknown char \"#{char}\"")
    end
  end
end

class BytesBuffer
  BYTE_BITS = 8

  attr_reader :bits

  def initialize
    @bits = []
  end

  def add_base64_char(char)
    @bits += ::B64.char2int(char).to_6bits_array
  end

  def to_bytes
    i = 0
    r = []
    while i < bits.count
      bits_to_byte(i).if_present { |v| r << v }
      i += BYTE_BITS
    end
    r
  end

  def to_bits_s
    bits.join
  end

  def bits_to_byte(offset)
    r = []
    BYTE_BITS.times.each do |i|
      ii = offset + i
      return nil unless ii < bits.count

      r << bits[ii]
    end
    r.join.to_i(2)
  end
end

class Runner
  runner_with :help do
    desc 'Utilidades para Base64'
    bool_opt '-e', '--encode'
    pos_arg :input_input
  end

  private

  def input_banner
    infov 'Input input', input_input
    infov 'Input', input
    infov 'Input size', input.length
  end

  def run
    input_banner
    infov 'Bits', bytesb.to_bits_s
    infov 'String', ::Base64.decode64(input_input).rstrip
    show_bytes
    write_file
  end

  def show_bytes
    bytesb.to_bytes.each do |byte|
      infov "  * #{byte}", byte.chr
    end
  end

  def write_file
    ::File.open('a_file', 'wb') do |file|
      bytesb.to_bytes.each do |byte|
        file.putc byte
      end
    end
  end

  def input
    if parsed.encode?
      ::Base64.encode64(input_input).rstrip
    else
      input_input
    end
  end

  def input_input
    parsed.input_input
  end

  def bytesb_uncached
    buffer = ::BytesBuffer.new
    input.each_char.to_a.each do |k|
      buffer.add_base64_char(k) unless k == '='
    end
    buffer
  end
end

Runner.run
