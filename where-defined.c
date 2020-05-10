
#include <backtrace.h>
#include <janet.h>

static struct backtrace_state *bt_state = NULL;

static void bt_error_callback(void *data, const char *msg, int errnum) {
    *((Janet*)data) = janet_cstringv(msg);
}

static int bt_full_callback(void *data, uintptr_t pc, const char *filename, int lineno, const char *function) {
    JanetKV *s = janet_struct_begin(4);
    janet_struct_put(s, janet_ckeywordv("line"), filename ? janet_wrap_number(lineno) : janet_wrap_nil());
    janet_struct_put(s, janet_ckeywordv("file"), filename ? janet_cstringv(filename) : janet_wrap_nil());
    janet_struct_put(s, janet_ckeywordv("name"), function ? janet_cstringv(function) : janet_wrap_nil());
    *((Janet*)data) = janet_wrap_struct(janet_struct_end(s));
    return 0;
}

static Janet func_info(int32_t argc, Janet *argv) {
    (void)argv;
    janet_fixarity(argc, 1);


    if (janet_checktype(argv[0], JANET_CFUNCTION)) {
        if (!bt_state)
            janet_panicf("libbacktrace failed to initialize.");

        JanetCFunction cf = janet_getcfunction(argv, 0);

        Janet v = janet_wrap_nil();
        backtrace_pcinfo(bt_state, (uintptr_t)cf, bt_full_callback, bt_error_callback, &v);
        if (janet_checktype(v, JANET_STRING))
            janet_panicv(v);
        return v;
    } else if (janet_checktype(argv[0], JANET_FUNCTION)) {
        JanetFunction *f = janet_getfunction(argv, 0);
        JanetFuncDef *fd = f->def;
        JanetKV *s = janet_struct_begin(4);
        janet_struct_put(s, janet_ckeywordv("line"), fd->sourcemap ? janet_wrap_number(fd->sourcemap->line) : janet_wrap_nil());
        janet_struct_put(s, janet_ckeywordv("file"), fd->source ? janet_wrap_string(fd->source) : janet_wrap_nil());
        janet_struct_put(s, janet_ckeywordv("name"), fd->name ? janet_wrap_string(fd->name) : janet_wrap_nil());
        return janet_wrap_struct(janet_struct_end(s));
    } else {
        return janet_wrap_nil();
    }
}


static const JanetReg cfuns[] = {
    {"func-info", func_info, NULL},
    {NULL, NULL, NULL}
};


JANET_MODULE_ENTRY(JanetTable *env) {
    bt_state = backtrace_create_state (NULL, 1, NULL, NULL);
    janet_cfuns(env, "where-defined", cfuns);
}
