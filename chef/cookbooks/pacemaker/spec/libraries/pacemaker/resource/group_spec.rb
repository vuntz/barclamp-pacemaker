require 'spec_helper'
require File.expand_path('../../../../libraries/pacemaker/resource/group', File.dirname(__FILE__))
require File.expand_path('../../../fixtures/resource_group', File.dirname(__FILE__))
require File.expand_path('../../../helpers/common_object_examples', File.dirname(__FILE__))

describe Pacemaker::Resource::Group do
  let(:fixture) { Chef::RSpec::Pacemaker::Config::RESOURCE_GROUP.dup }
  let(:fixture_definition) {
    Chef::RSpec::Pacemaker::Config::RESOURCE_GROUP_DEFINITION
  }

  before(:each) do
    Mixlib::ShellOut.any_instance.stub(:run_command)
  end

  def object_type
    'group'
  end

  def pacemaker_object_class
    Pacemaker::Resource::Group
  end

  def fields
    %w(name members)
  end

  it_should_behave_like "a CIB object"

  describe "#definition_string" do
    it "should return the definition string" do
      expect(fixture.definition_string).to eq(fixture_definition)
    end
  end

  describe "#parse_definition" do
    before(:each) do
      @parsed = Pacemaker::Resource::Group.new(fixture.name)
      @parsed.definition = fixture_definition
      @parsed.parse_definition
    end

    it "should parse the members" do
      expect(@parsed.members).to eq(fixture.members)
    end
  end
end
