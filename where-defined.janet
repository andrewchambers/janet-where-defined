(import _jmod_where_defined)

(defn func-info
  "Get a tuple of {:file :line :name} for a function or cfunction. Returns nil on failure."
  [f]
  (_jmod_where_defined/func-info f))

(defn where-defined
  "Get a tuple of [file line] for a given item, or nil on failure."
  [f]
  (def ty (type f))
  (cond 
    (or (= ty :function) (= ty :cfunction))
      (let [{:file file :line line} (func-info f)]
        [file line])
    nil))
