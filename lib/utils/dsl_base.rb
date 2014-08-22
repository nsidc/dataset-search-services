module DslBase
  def dsl_methods(*syms)
    syms.each { |sym| class_eval define_dsl_method_str(sym) }
  end

  private

  def define_dsl_method_str(k)
    <<-EOE
        def #{k}(n=nil)
          unless n.nil?
            @#{k}=n
          end

          @#{k}
        end
    EOE
  end
end
