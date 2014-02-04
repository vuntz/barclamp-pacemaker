require File.expand_path('../../libraries/pacemaker/resource/group',
                         File.dirname(__FILE__))

module Chef::RSpec
  module Pacemaker
    module Config
      RESOURCE_GROUP = \
        ::Pacemaker::Resource::Group.new('group1')
      RESOURCE_GROUP.members = ['resource1', 'resource2']
      RESOURCE_GROUP_DEFINITION = 'group group1 resource1 resource2'
    end
  end
end
