#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class TheRunner
  STATIC_MOUNT_OPTIONS = {
    file_mode: '0777',
    dir_mode: '0777',
    iocharset: 'utf8'
  }.freeze

  runner_with :help do
    arg_opt '-u', '--username'
    arg_opt '-p', '--password'
    pos_arg :shared_dir_path
  end

  delegate :username, :password, :shared_dir_path, to: :parsed

  def run
    on_temp_credentials_file { mount_command.system! }
  end

  private

  attr_accessor :credentials_file

  def credentials_content
    "username=#{username}\npassword=#{password}\n"
  end

  def mount_command
    ::Cliutils::Core.command('a/mount/mnt', *mount_args)
  end

  def mount_args
    ['cifs', shared_dir_path, mount_options_to_s]
  end

  def mount_options_to_s
    mount_options.map { |k, v| "#{k}=#{v}" }.join(',')
  end

  def mount_options
    STATIC_MOUNT_OPTIONS.merge(dynamic_mount_options)
  end

  def dynamic_mount_options
    {
      uid: ::Process.uid,
      gid: ::Process.gid,
      credentials: credentials_file
    }
  end

  def on_temp_credentials_file
    ::EacRubyUtils::Fs::Temp.on_file do |temp_file|
      self.credentials_file = temp_file
      credentials_file.write(credentials_content)
      yield
    end
  end
end

TheRunner.run
