# where-defined

Lookup where your janet functions, C functions, symbols and values where defined.

```
janet:1:> (use where-defined)
nil
janet:2:> (where-defined printf)
("/home/ac/src/janet/src/core/io.c" 468)
janet:3:> (where-defined where-defined)
("/home/ac/janet/where-defined.janet" 4)
```

Requires debug symbols for C functions.
