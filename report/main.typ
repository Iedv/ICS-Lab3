= TASK I: 观察栈帧 input

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

=== 3.

*Question*: 看看调用栈上 \$rbp + 8 处，那里存的值是什么？（提示：运行 disas main 来查看它的汇编代码）

*Answer*: 存放下述汇编指令的地址：

```
0x0000000000401ad1 <+14>:    mov    eax,0x0
```

=== 4. 

*Question*: 刚刚我们在 input 函数中读到的汇编代码似乎不能解释 \$rbp + 8 处值的存在，我们需要找到它的来源。请你在 input 的调用者中找到 input 被调用的位置，在这里之前下一个断点，重新运行程序，并使用 si 命令从那里逐指令执行到我们的 input 断点，观察信息，回答是哪一行汇编代码在 \$rbp + 8 处存入了值。

*Answer*: 在 main 中这一行：

```
0x0000000000401acc <+9>:     call   0x401977 <input>
```

=== 5. 

*Question*: 用同样的办法逐指令从 input 的 leave 指令之前处执行到 input 的调用者当中并观察每一步栈帧的变化，结合问题 2、问题 3 和 问题 4 回答 call、prologue、leave 和 ret 的作用。

*Answer*: call 将下一条指令的地址压入栈顶，并且跳转到对应函数。prologue 首先把之前的 rbp 的值压入栈顶，然后将新的 rbp 值指向栈顶（即原来 rbp 的地址），然后向栈顶压入预留空间。leave 等价于 prologue 的逆（即 `mov rsp rbp; pop rbp;`）。ret 相当于 call 的逆，将之前的 rbp+8 存放的下一条指令存入 rip。

= TASK II: 用不同长度的字符串输入测试 dark-calc

程序运行结果为：

```
Enter an expression (length up to 15):
01234567899876543210
Executing: echo $((012345678998765))
sh: 1: arithmetic expression: expecting EOF: "012345678998765"
Enter an expression (length up to 15):
01234567899876543210012345678977
fish: Job 1, './dark-calc' terminated by signal SIGSEGV (Address boundary error)
```

对于长度 20 的字符串，在 gets 之后 stack frame 是这样的：

```
0x0000721000800fd0│+0x0000: "01234567899876543210"       ← $rax, $rsp
0x0000721000800fd8│+0x0008: "899876543210"
0x0000721000800fe0│+0x0010: 0x0000720030313233 ("3210"?)         ← $rbp
0x0000721000800fe8│+0x0018: 0x0000000000401ad1  →  <main+000e> mov eax, 0x0
0x0000721000800ff0│+0x0020: 0x00007fffffffe250  →  0x00007fffffffe2b0  →  0x0000000000000000
0x0000721000800ff8│+0x0028: 0x0000000000401c1f  →  <__wrap_main+0011> mov rsp, r12
0x0000721000801000│+0x0030: 0x0000000000000000
0x0000721000801008│+0x0038: 0x0000000000000000
```

具体打印栈顶 32 个字节：

```
0x721000800fd0: 0x30    0x31    0x32    0x33    0x34    0x35    0x36    0x37
0x721000800fd8: 0x38    0x39    0x39    0x38    0x37    0x36    0x35    0x34
0x721000800fe0: 0x33    0x32    0x31    0x30    0x00    0x72    0x00    0x00
0x721000800fe8: 0xd1    0x1a    0x40    0x00    0x00    0x00    0x00    0x00
```

发现字符串覆盖了部分的 rbp 指向的值（即调用者的 rbp 地址）。

对于长度 32 的字符串，栈顶 64 个字节是：

```
0x721000800fd0: 0x31    0x32    0x33    0x34    0x35    0x36    0x37    0x38
0x721000800fd8: 0x39    0x30    0x30    0x39    0x38    0x37    0x36    0x35
0x721000800fe0: 0x34    0x33    0x32    0x31    0x31    0x32    0x33    0x34
0x721000800fe8: 0x35    0x36    0x37    0x38    0x39    0x30    0x36    0x36
0x721000800ff0: 0x00    0xe2    0xff    0xff    0xff    0x7f    0x00    0x00
0x721000800ff8: 0x1f    0x1c    0x40    0x00    0x00    0x00    0x00    0x00
0x721000801000: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
0x721000801008: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
```

可以发现，此时完全覆盖了 rbp 指向的值。

总结，超量的数据继续写入更高地址的栈空间，可能覆盖了一些原来用来控制程序进程的数据。

= TASK III: 利用缓冲区漏洞执行 ./malware

注意到，直接输入表达式 `1))&./malware #` 即可完成攻击。

接下来尝试利用 buffer overflow 攻击。

我们希望跳转到外部程序 malware，因此必需借助 system() 函数。而 system 函数调用的 `command_buf` 在退出 input 之前被赋值为了我们输入的 expression，这恰好可以让我们把 expression 改为 `./malware`，并且让溢出的数据改写 ret 的下一行代码为 system() 函数。而

= TASK IV: 用 GDB 检查 main 函数的机器码

```
0x401ac3 <main>:        0x55    0x48    0x89    0xe5    0xb8    0x00    0x00    0x00
0x401acb <main+8>:      0x00    0xe8    0xa6    0xfe    0xff    0xff    0xb8    0x00
0x401ad3 <main+16>:     0x00    0x00    0x00    0xe8    0xfc    0xfe    0xff    0xff
0x401adb <main+24>:     0xeb    0xea    0x55    0x48    0x89    0xe5    0x48    0x83
```

*Question*: 前三行汇编对应的机器码分别是什么？

*Answer*: 

1. `push   rbp` 对应 `0x55`；
2. `mov    rbp,rsp` 对应 `0x48 0x89 0xe5`；
3. `mov    eax,0x0` 对应 `0xb8 0x00 0x00 0x00 0x00`。

*Question*: 这些机器码在内存中排列的方式是什么样的？请你用文字或画一个图来说明。需要指出这三行指令分别对应的内存区间是什么。你可以在第一行指令处下一个断点，然后逐条指令执行，同时观察 rip 寄存器的值。

*Answer*: 

内存中 `push rbp` 占用 1 Byte，地址为 `0x401ac3` ~ `0x401ac3`；
内存中 `mov rbp,rsp` 占用 3 Byte，地址为 `0x401ac4` ~ `0x401ac6`；
内存中 `mov eax,0x0` 占用 5 Byte，地址为 `0x401ac7` ~ `0x401acb`；

在内存中，这些指令的长度是不一样的。

= TASK V: 任务：栈空间执行

让 input 的 ret 跳转到栈上，然后调用 `grade_eval(4)`。具体转成汇编就是：

1. `mov rdi,0x4`
2. `mov rax,[address to grade_eval]`
3. `call rax`

由于栈上地址超过 32 位整数范围，所以直接使用偏移量的 call 似乎无法实现，需要借助一个寄存器实现。

= TASK VI: 任务：ROP

最终希望使 rdi 为 4。

注意到，`0x401a33` 开始的机器码是 `0x5f 0x3c`，直接对应 `pop rdi; ret;`，所以直接利用这一条。并通过把这个地址更高位（调用这个 gadget 后的栈顶）的栈写为 4，即可让 `pop rdi` 直接赋值 `rdi` 为 4。最后直接调用 grade_eval，即 `0x401978`。

= TASK VII: 任务：Canary

主要思路是借助 `memcopy` 实现直接对 ret 的地址修改，然后通过 rop 劫持控制流。

`memcopy` 的目的地可以被 `f.len` 控制，所以我们设计好 expression 为 rop 地址和数据，然后再修改 `f.log`，把 expression 的地址恰好移动到指定位置。

*局部变量重新排布*

一方面，如果前面的 `len`，`expression` 这些都是局部变量，重新排序，那么攻击者就不能确定 `len` 相对于 `expression` 的位置，就不可能通过精心构造输入，使得 buffer overflow 正好修改 `len`。

另一方面，也可以考虑在局部变量的存储和 ret 地址以及 canary 之间增加一个随机长度的 padding，防止精细调整 buffer overflow 的偏移量正好修改 ret 的地址。