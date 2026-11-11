=== 1. 

*Question*: 看看 trace 部分，input 函数是谁调用的？

*Answer*: main 函数调用，trace 如下：

```
[#0] 0x40197f → input()
[#1] 0x401ad1 → main()
```

=== 2.

*Question*: 看看 code:x86:64 部分，input 函数的前三条指令是在做什么？ \$rbp 此刻指向的内存地址当中的值来自哪里？

*Answer*: 如下是前三条指令。首先将上层函数的 rbp 保存到栈顶，然后把新的 rbp 指向栈顶，同时向栈中压入 0x10 的预留空间。这之后 rbp 指向的是当前函数的最底层（地址索引最大）。

```
0x401977 <input+0000>     push   rbp
0x401978 <input+0001>     mov    rbp, rsp
0x40197b <input+0004>     sub    rsp, 0x10
```

