(import sh)
(import _jmod_where_defined)

(defn addr2line [addr exe]
    # XXX hacky to shell out for this.
    (def hex-addr (sh/$$ ["printf" "%x" (string addr)]))
    (def [file line] (string/split ":" (sh/$$_ ["addr2line" "-e" exe hex-addr])))
    [file (scan-number line)])

(defn where-defined
  [f]
  (case (type f)
    :cfunction
      (when-let [sym-info (_jmod_where_defined/dladdr f)]
        (def exe
          (if (os/lstat (sym-info :file-name))
            (sym-info :file-name)
            (os/readlink "/proc/self/exe")))
        (def address (sym-info :func-address))
        (def adjusted-address (- (sym-info :func-address) (sym-info :base-address)))

        (var loc (addr2line address exe))
        (when (= "??" (loc 0))
          # FIXME When precisely do we need to do this? PIE vs not?
          (set loc (addr2line adjusted-address exe)))
        loc)
    :function
      (let [asm (disasm f)
            file (asm 'source)
            line  (get-in asm ['sourcemap 0 0])]
        [file line])
    nil))
