#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class Document
  enable_speaker
  enable_simple_cache
  common_constructor :runner, :path

  BODY_TITLE_PARSER = /^\s*=\s+(\S.+)$/.to_parser do |m|
    m[1].strip
  end

  def perform
    infov path, body_title.if_present('__NOT_FOUND__')
    return if body_title.blank?

    title_path.write(body_title)
  end

  def title_path
    path.join('title')
  end

  def body_path
    path.join('body.adoc')
  end

  private

  def body_title_uncached
    return nil unless body_path.exist?

    BODY_TITLE_PARSER.parse(body_path.read)
  end
end

class TheRunner
  runner_with :help, :filesystem_traverser

  def run
    run_filesystem_traverser
  end

  def traverser_recursive
    true
  end

  def traverser_check_file(path)
    return unless path.basename.to_path == 'body.adoc'

    ::Document.new(self, path.dirname).perform
  end
end

TheRunner.run
