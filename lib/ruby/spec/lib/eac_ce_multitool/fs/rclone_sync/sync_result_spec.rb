# frozen_string_literal: true

require 'active_support/ordered_options'

RSpec.describe EacCeMultitool::Fs::RcloneSync::SyncResult do
  include_examples 'source_target_fixtures', __FILE__
end
