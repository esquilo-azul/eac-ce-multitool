#!/usr/bin/env ruby
# frozen_string_literal: true

input = $stdin.read
expected = input.match(/^-([^-].+)$/)
expected = expected[1] if expected
actual = input.match(/^\+([^+].+)$/)
actual = actual[1] if expected

class File
  attr_reader :path

  def initialize(path, content)
    @path = path
    @content = content
  end

  def save
    File.write(@path, breaked_content)
  end

  def breaked_content
    b = ''
    @content.each_line do |l|
      b << "#{line_breaked(l)}\n"
    end
    b
  end

  def line_breaked(line)
    lines = []
    b = line.dup
    limit = 120
    lines << b.slice!(0, 120) while b.size > limit
    lines.join("\n")
  end
end

puts input
puts '========================================='
if expected && actual
  puts 'Matched!'
  file1 = File.new('/tmp/diff-input-1', expected)
  file1.save
  file2 = File.new('/tmp/diff-input-2', actual)
  file2.save
  system("meld #{file1.path} #{file2.path}")
else
  puts 'actual not found' unless actual
  puts 'expected not found' unless actual
end
