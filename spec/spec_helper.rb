require 'puppet'
require 'rspec'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-hiera-puppet'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  # we don't want to run tests from submodules in fixtures/sts/..
  c.pattern = "spec/*/*_spec.rb"

  c.before :each do
    # Ensure that we don't accidentally cache facts and environment
    # between test cases.
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages

    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}
  end

  c.after :each do
    # Restore environment variables after execution of each test
    @old_env.each_pair {|k, v| ENV[k] = v}
    to_remove = ENV.keys.reject {|key| @old_env.include? key }
    to_remove.each {|key| ENV.delete key }
  end
end

Puppet::Util::Log.level = :warning
Puppet::Util::Log.newdestination(:console)
