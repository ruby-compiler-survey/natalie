#include "natalie.hpp"

namespace Natalie {

void ExceptionValue::build_backtrace(Env *env) {
    m_backtrace = new ArrayValue {};
    Env *bt_env = env;
    do {
        if (bt_env->file()) {
            auto method_name = env->build_code_location_name(bt_env);
            m_backtrace->push(StringValue::format(env, "{}:{}:in `{}'", bt_env->file(), bt_env->line(), method_name));
        }
        bt_env = bt_env->caller();
    } while (bt_env);
}

ValuePtr ExceptionValue::initialize(Env *env, ValuePtr message) {
    if (!message) {
        auto name = m_klass->class_name_or_blank();
        set_message(new StringValue { *name });
    } else {
        if (!message->is_string()) {
            message = message.send(env, SymbolValue::intern("inspect"));
        }
        set_message(message->as_string());
    }
    return this;
}

ValuePtr ExceptionValue::inspect(Env *env) {
    return StringValue::format(env, "#<{}: {}>", m_klass->inspect_str(env), m_message);
}

ValuePtr ExceptionValue::backtrace(Env *env) {
    return m_backtrace ? m_backtrace->dup(env) : NilValue::the();
}

void ExceptionValue::visit_children(Visitor &visitor) {
    Value::visit_children(visitor);
    visitor.visit(m_message);
    visitor.visit(m_backtrace);
}

}
