require 'spec_helper'
require 'open3'

RSpec.describe 'Example' do
  Dir.glob(File.join(EXAMPLE_DIR_PATH, '*.rb')).each do |example_path|
    it File.basename(example_path, '.rb') do
      cmd = %(ruby #{example_path})
      success = false
      Open3.popen2(cmd) do |_, _, wait_thr|
        wait_thr.join
        success = wait_thr.value.success?
      end

      expect(success).to be true
    end
  end
end
