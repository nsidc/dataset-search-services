# frozen_string_literal: true

module ClassModule
  def included(base)
    if const_defined?('ClassMethods') && const_get('ClassMethods').is_a?(Module)
      base.extend const_get('ClassMethods')
    end

    return unless const_defined?('InstanceMethods') && const_get('InstanceMethods').is_a?(Module)

    base.send :include, const_get('InstanceMethods')
  end
end
