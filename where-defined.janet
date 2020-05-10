(import _jmod_where_defined)

(defn func-info
  "Get a struct of {:file :line :name} for a function or cfunction. Returns nil on failure."
  [f]
  (_jmod_where_defined/func-info f))

(defn- where-value-defined
  "Lookup where a value was defined by using value metadata or scanning the module/cache"
  [x]
  (def ty (type x))
  (cond 
    (or (= ty :function) (= ty :cfunction))
      (let [{:file file :line line} (func-info x)]
        (when (and file line)
          [file line]))
    (prompt :lookup
      (each env (array/concat @[] [root-env (fiber/getenv (fiber/current))] (values module/cache))
        # We need to deep expand envs for our search.
        # This does prototype lookup etc.
        (def lookup (invert (env-lookup env)))
        (when-let [esym (lookup x)]
          (def meta (get env esym))
          (when-let [sm (get meta :source-map)]
            (return :lookup (tuple/slice sm 0 2))))))))

(defn where-defined
  "Try to find where x is defined. If x is a symbol, use this to look in the current environment,
   if this values will try to find a definition by value using where-value-defined."
  [x]
  (if (symbol? x)
    (when-let [meta (dyn x)]
        (def v  (get meta :value))
        (def sm (get meta :source-map))
        (def ty (type v))
        (cond 
          (meta :source-map)
            (tuple/slice sm 0 2)
          (or (= ty :function) (= ty :cfunction))
            (let [{:file file :line line} (func-info v)]
              (when (and file line)
                [file line]))
          nil))
    (where-value-defined x)))

