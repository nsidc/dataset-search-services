# frozen_string_literal: true

module DslBase
  def dsl_methods(*syms)
    syms.each { |sym| class_eval define_dsl_method_str(sym) }
  end

  private

  def define_dsl_method_str(key)
    <<-BLOCK
        def #{key}(n=nil)
          unless n.nil?
            @#{key}=n
          end

          @#{key}
        end
    BLOCK
  end
end
