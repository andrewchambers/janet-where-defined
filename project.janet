(declare-project
  :name "where-defined"
  :author "Andrew Chambers"
  :license "MIT"
  :url "https://github.com/andrewchambers/janet-where-defined"
  :repo "git+https://github.com/andrewchambers/janet-where-defined.git")

(rule "libbacktrace/.libs/libbacktrace.a" []
  (def wd (os/cwd))
  (defer (os/cd wd)
    (os/cd "./libbacktrace")
    (assert (= (os/execute ["./configure"] :p) 0))
    (assert (= (os/execute ["make" "CFLAGS=-fPIC"] :p) 0))))

(declare-native
  :name "_jmod_where_defined"
  :source ["where-defined.c"]
  :cflags ["-I./libbacktrace"]
  :lflags ["-L./libbacktrace/.libs" "-lbacktrace"])

(add-dep "build/where-defined.o" "libbacktrace/.libs/libbacktrace.a")
(add-dep "build/_jmod_where_defined.so" "libbacktrace/.libs/libbacktrace.a")
(add-dep "build/_jmod_where_defined.a" "libbacktrace/.libs/libbacktrace.a")
(add-dep "build/_jmod_where_defined.meta.janet" "libbacktrace/.libs/libbacktrace.a")

(declare-source
  :name "where-defined"
  :source ["where-defined.janet"])

