class BindingGen
  def initialize
    @bindings = {}
  end

  def binding(rb_class, rb_method, cpp_class, cpp_method, argc:, pass_env: false, pass_block: false, return_type: :Value)
    return_code = if return_type == :bool
                    'if (return_value) { return NAT_TRUE; } else { return NAT_FALSE; }'
                  else
                    'return return_value;'
                  end
    name = "#{cpp_class}_#{cpp_method}_binding"
    while @bindings[name]
      name = name.sub(/_binding(\d*)$/) { "_binding#{$1.to_i + 1}" }
    end
    @bindings[name] = [rb_class, rb_method]
    puts <<-FUNC
Value *#{name}(Env *env, Value *self_value, ssize_t argc, Value **args, Block *block) {
    NAT_ASSERT_ARGC(#{argc});
    #{cpp_class} *self = self_value->as_#{cpp_class.sub(/Value/, '').downcase}();
    auto return_value = self->#{cpp_method}(#{pass_env ? '*env' : ''} #{pass_env && argc > 0 ? ',' : ''} #{(0..(argc-1)).map { |i| "*args[#{i}]" }.join(', ')} #{pass_block ? ', block' : ''});
    #{return_code}
}\n
    FUNC
  end

  def init
    puts 'void init_bindings(Env *env) {'
    @bindings.each do |cpp_binding_func, (rb_class, rb_method)|
      puts "    NAT_OBJECT->const_get(env, #{rb_class.inspect}, true)->define_method(env, #{rb_method.inspect}, #{cpp_binding_func});"
    end
    puts '}'
  end
end

puts '// DO NOT EDIT THIS FILE BY HAND!'
puts '// This file is generated by the lib/natalie/compiler/binding_gen.rb script.'
puts '// Run `make src/bindings.cpp` to regenerate this file.'
puts
puts '#include "natalie.hpp"'
puts
puts 'namespace Natalie {'
puts

gen = BindingGen.new

gen.binding('Float', '==', 'FloatValue', 'eq', argc: 1, pass_env: true, pass_block: false, return_type: :bool)
gen.binding('Float', '===', 'FloatValue', 'eq', argc: 1, pass_env: true, pass_block: false, return_type: :bool)
gen.binding('Float', 'to_s', 'FloatValue', 'to_s', argc: 0, pass_env: true, pass_block: false, return_type: :Value)
gen.binding('Float', 'inspect', 'FloatValue', 'to_s', argc: 0, pass_env: true, pass_block: false, return_type: :Value)
gen.binding('Float', 'eql?', 'FloatValue', 'eql', argc: 1, pass_env: false, pass_block: false, return_type: :bool)
gen.binding('Float', '<=>', 'FloatValue', 'cmp', argc: 1, pass_env: true, pass_block: false, return_type: :Value)

gen.init

puts
puts '}'