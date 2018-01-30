require 'rspec'
require 'timeout'
require 'asynchronous'

module SyntaxSugarForBlockExpected
  def is_expect
    expect { subject }
  end
end

RSpec.configure do |config|
  config.include(SyntaxSugarForBlockExpected)

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

Kernel.at_exit do
  if Asynchronous::ZombiKiller::MOTHER_PID == $PROCESS_ID
    begin
      loop { Process.kill('KILL', Process.wait(-1, Process::WUNTRACED)) }
    rescue Errno::ESRCH, Errno::ECHILD
      puts 'done'
    end
  end
end

class ExampleCustomClassForValue
  attr_reader :a
  def initialize(a)
    @a = a
  end
end

EXAMPLE_DIR_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..', 'examples'))
BOOTSTRAP_FILE_PATH = File.join(EXAMPLE_DIR_PATH, 'bootstrap.rb')

RSpec::Matchers.define(:finish_within) do |duration|
  supports_block_expectations

  match { |block| expect { Timeout.timeout(duration, &block) }.to_not raise_error }
  match_when_negated { |block| expect { Timeout.timeout(duration, &block) }.to raise_error(Timeout::Error) }
end

