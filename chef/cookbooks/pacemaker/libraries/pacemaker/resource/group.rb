require File.expand_path('../resource', File.dirname(__FILE__))

class Pacemaker::Resource::Group < Pacemaker::Resource
  TYPE = 'group'
  register_type TYPE

  attr_accessor :members

  def self.from_chef_resource(resource)
    attrs = %w(members)
    new(resource.name).copy_attrs_from_chef_resource(resource, *attrs)
  end

  def parse_definition
    rsc_re = /(\S+?)(?::(Started|Stopped))?/
    unless definition =~ /^#{TYPE} (\S+) (.+?)\s*$/
      raise Pacemaker::CIBObject::DefinitionParseError, \
        "Couldn't parse definition '#{definition}'"
    end
    self.name  = $1
    self.members = $2.split
  end

  def definition_string
    "#{TYPE} #{name} " + members.join(' ')
  end

  def crm_configure_command
    "crm configure " + definition_string
  end

end
