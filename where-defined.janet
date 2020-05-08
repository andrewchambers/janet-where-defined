(import sh)
(import _jmod_where_defined)

(defn where-defined
  [f]
  (case (type f)
    :cfunction
      (when-let [sym-info (_jmod_where_defined/dladdr f)
                 in-janet (= "janet" (sym-info :file-name))
                 module (if in-janet (os/readlink "/proc/self/exe") (sym-info :file-name))
                 _ (os/stat module)]
        (def address
          (if in-janet
            (sym-info :func-address)
            (- (sym-info :func-address) (sym-info :base-address))))
        # XXX hacky to shell out for this, 
        (def hex-address (sh/$$ ["printf" "%x" (string address)]))
        (def [file line] (string/split ":" (sh/$$_ ["addr2line" "-e" module hex-address])))
        [file (scan-number line)])
    :function
      (let [asm (disasm f)
            file (asm 'source)
            line  (get-in asm ['sourcemap 0 0])]
        [file line])
    nil))

