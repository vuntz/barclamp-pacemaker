require 'mixlib/shellout'

module Pacemaker
  class CIBObject
    attr_accessor :name, :definition

    @@subclasses = { }

    class << self
      attr_reader :object_type

      def register_type(type_name)
        @object_type = type_name
        @@subclasses[type_name] = self
      end

      def get_definition(name)
        cmd = Mixlib::ShellOut.new("crm configure show #{name}")
        cmd.environment['HOME'] = ENV.fetch('HOME', '/root')
        cmd.run_command
        begin
          cmd.error!
          cmd.stdout
        rescue
          nil
        end
      end

      def type(definition)
        unless definition =~ /\A(\w+)\s/
          raise "Couldn't extract CIB object type from '#{definition}'"
        end
        return $1
      end

      def from_name(name)
        definition = get_definition(name)
        return nil unless definition and ! definition.empty?
        from_definition(definition)
      end

      def from_definition(definition)
        if method(__method__).owner == self.singleton_class
          # Invoked via (this) base class
          obj_type = type(definition)
          subclass = @@subclasses[obj_type]
          unless subclass
            raise "No subclass of #{self.name} was registered with type '#{obj_type}'"
          end
          return subclass.from_definition(definition)
        else
          # Invoked via subclass
          obj = new(name)
          unless name == obj.name
            raise "Name '#{obj.name}' in definition didn't match name '#{name}' used for retrieval"
          end
          obj.definition = definition
          obj.parse_definition
          obj
        end
      end
    end

    def initialize(name)
      @name = name
      @definition = nil
    end

    def copy_attrs_from_chef_resource(resource, *attrs)
      attrs.each do |attr|
        value = resource.send(attr.to_sym)
        writer = (attr + '=').to_sym
        send(writer, value)
      end
      self
    end

    def copy_attrs_to_chef_resource(resource, *attrs)
      attrs.each do |attr|
        value = send(attr.to_sym)
        writer = attr.to_sym
        resource.send(writer, value)
      end
    end

    def load_definition
      @definition = self.class.get_definition(name)

      if @definition and ! @definition.empty? and type != self.class.object_type
        raise CIBObject::TypeMismatch, \
          "Expected #{self.class.object_type} type but loaded definition was type #{type}"
      end
    end

    def parse_definition
      raise NotImplementedError, "#{self.class} must implement #parse_definition"
    end

    def exists?
      !! (definition && ! definition.empty?)
    end

    def type
      self.class.type(definition)
    end

    def to_s
      "%s '%s'" % [self.class.description, name]
    end

    def delete_command
      "crm configure delete '#{name}'"
    end
  end

  class CIBObject::DefinitionParseError < StandardError
  end

  class CIBObject::TypeMismatch < StandardError
  end
end