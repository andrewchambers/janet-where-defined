#define _GNU_SOURCE

#include <dlfcn.h>
#include <janet.h>

static Janet jdladdr(int32_t argc, Janet *argv) {
    (void)argv;
    janet_fixarity(argc, 1);

    JanetCFunction cf = janet_getcfunction(argv, 0);

    Dl_info info;
    if(!dladdr((void *)cf, &info))
        return janet_wrap_nil();

    JanetKV *s = janet_struct_begin(4);
    janet_struct_put(s, janet_ckeywordv("func-address"), janet_wrap_u64((uint64_t)cf));
    janet_struct_put(s, janet_ckeywordv("file-name"), janet_cstringv(info.dli_fname));
    janet_struct_put(s, janet_ckeywordv("base-address"), janet_wrap_u64((uint64_t)info.dli_fbase));
    janet_struct_put(s, janet_ckeywordv("symbol-name"), info.dli_sname ? janet_cstringv(info.dli_sname) : janet_wrap_nil());
    janet_struct_put(s, janet_ckeywordv("symbol-address"),  info.dli_saddr ? janet_wrap_u64((uint64_t)info.dli_saddr) : janet_wrap_nil());
    return janet_wrap_struct(janet_struct_end(s));
}


static const JanetReg cfuns[] = {
    {"dladdr", jdladdr, NULL},
    {NULL, NULL, NULL}
};

JANET_MODULE_ENTRY(JanetTable *env) {
    janet_cfuns(env, "where-defined", cfuns);
}
