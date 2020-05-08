(declare-project
  :name "where-defined"
  :author "Andrew Chambers"
  :license "MIT"
  :url "https://github.com/andrewchambers/janet-where-defined"
  :repo "git+https://github.com/andrewchambers/janet-where-defined.git")

(declare-native
  :name "_jmod_where_defined"
  :source ["where-defined.c"]
  :cflag ["-g"])

(declare-source
  :name "where-defined"
  :source ["where-defined.janet"])

