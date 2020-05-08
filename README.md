# where-defined

Lookup where your janet function was defined.

```
("/home/ac/src/janet/src/core/io.c" 468)
janet:3:> (where-defined where-defined)
("/home/ac/janet/where-defined.janet" 4)
```

Requires debug symbols for C functions.