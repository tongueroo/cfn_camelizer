require "cfn_camelizer/version"
require "memoist"
require "yaml"
require "rainbow/ext/string"
require "active_support/core_ext/string"
require "active_support/core_ext/hash"

# Custom Camelizer with CloudFormation specific handling.
# Based on: https://stackoverflow.com/questions/8706930/converting-nested-hash-keys-from-camelcase-to-snake-case-in-ruby
class CfnCamelizer
  class << self
    extend Memoist

    def transform(value, parent_keys=[], resource_type=nil)
      case value
      when Array
        value.map { |v| transform(v, parent_keys, resource_type) }
      when Hash
        if value.keys.include?(:type) || value.keys.include?("Type")
          resource_type ||= value[:type] || value["Type"]
        end

        initializer = value.map do |k, v|
          new_key = camelize_key(k, parent_keys, resource_type)
          [new_key, transform(v, parent_keys+[new_key], resource_type)]
        end
        Hash[initializer]
      else
        value # do not transform values
      end
    end

    def camelize_key(k, parent_keys=[], resource_type=nil)
      k = k.to_s

      if passthrough?(k, parent_keys)
        k # pass through untouch
      elsif parent_keys.last == "EventPattern" # top-level
        k.dasherize
      elsif parent_keys.include?("EventPattern")
        # Any keys at 2nd level under EventPattern will be pascalized
        pascalize(k)
      else
        camelize(k, resource_type)
      end
    end

    def passthrough?(k, parent_keys)
      # Do not transform keys under certain parent keys or keys that contain - or /
      passthrough = camelizer_yaml["passthrough_parent_keys"]
      intersection = parent_keys & passthrough
      !intersection.empty? || k.include?('-') || k.include?('/') || k.include?('.')
    end

    def camelize(value, resource_type=nil)
      return value if value.is_a?(Integer)

      value = value.to_s.camelize
      v = special_map[value] || value # after the special_keys map
      resource_map(resource_type)[v] || v
    end

    def pascalize(value)
      new_value = value.camelize
      first_char = new_value[0..0].downcase
      new_value[0] = first_char
      new_value
    end

    # Some keys have special mappings
    def special_map
      camelizer_yaml["special_keys"]
    end

    def resource_map(resource_type)
      camelizer_yaml["resource_keys"][resource_type] || {}
    end

    def camelizer_yaml
      # default
      path = File.expand_path("camelizer.yml", File.dirname(__FILE__))
      default = YAML.load_file(path)
      # project specific
      path = "#{Dir.pwd}/configs/camelizer.yml"
      if File.exist?(path)
        project = YAML.load_file(path)
        default.deep_merge(project)
      else
        default
      end
    end
    memoize :camelizer_yaml
  end
end
