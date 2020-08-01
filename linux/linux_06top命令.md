# top 命令详解

```shell
[root@izm5edg2s72kme0kupc888z ~]# top
top - 14:06:07 up 12 days,  3:31,  1 user,  load average: 0.00, 0.03, 0.05
Tasks:  96 total,   2 running,  94 sleeping,   0 stopped,   0 zombie
%Cpu(s):  1.0 us,  0.7 sy,  0.0 ni, 98.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem :  1882072 total,    73188 free,   611904 used,  1196980 buff/cache
KiB Swap:        0 total,        0 free,        0 used.  1090732 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
 1297 root      10 -10  211196  94344   5988 S  1.7  5.0 216:24.39 AliYunDun
 2022 root      20   0  161888   2172   1548 R  0.3  0.1   0:00.94 top
25363 root      20   0   75248    680    324 S  0.3  0.0   2:08.95 getty
    1 root      20   0  191528   3676   1760 S  0.0  0.2   2:51.49 systemd
    2 root      20   0       0      0      0 S  0.0  0.0   0:00.00 kthreadd
```

## 输出分析

### 第一行  top，任务队列信息 

```shell
top - 14:06:07 up 12 days,  3:31,  1 user,  load average: 0.00, 0.03, 0.05
系统时间：14:06:07
运行时间：up 12 days,  3:31,
当前登录用户：  1 user
负载均衡(uptime)  load average: 0.00, 0.03, 0.05
     average后面的三个数分别是1分钟、5分钟、15分钟的负载情况。
load average数据是每隔5秒钟检查一次活跃的进程数，然后按特定算法计算出的数值。如果这个数除以逻辑CPU的数量，结果高于5的时候就表明系统在超负荷运转了
```

### 第二行，Tasks — 任务（进程）

```shell
Tasks:  96 total,   2 running,  94 sleeping,   0 stopped,   0 zombie
总进程:96 total, 运行:2 running, 休眠:94 sleeping, 停止: 0 stopped, 僵尸进程: 0 zombie
```

###   cpu状态信息

```shell
%Cpu(s):  1.0 us,  0.7 sy,  0.0 ni, 98.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
 1.0 us【user space】— 用户空间占用CPU的百分比。
 0.7 sy【sysctl】— 内核空间占用CPU的百分比。
 0.0 ni【】— 改变过优先级的进程占用CPU的百分比
 98.3 id【idolt】— 空闲CPU百分比
 0.0 wa【wait】— IO等待占用CPU的百分比
 0.0 hi【Hardware IRQ】— 硬中断占用CPU的百分比
 0.0 si【Software Interrupts】— 软中断占用CPU的百分比
 0.0 st 当Linux系统是在虚拟机中运行时，等待CPU资源的时间（steal time）占比。
```

### 第四行, Mem 内存状态

```shell
KiB Mem :  1882072 total,    73188 free,   611904 used,  1196980 buff/cache
1882072 total,   73188 free, 611904 used,  1196980 buffers【缓存的内存量】
```

###  第五行，swap交换分区信息

```shell
KiB Swap:        0 total,        0 free,        0 used.  1090732 avail Mem
 0 total,     0 free,   0 used,  1090732 avail Mem【可用内存】
```

>备注：
>
>可用内存=free + buffer + cached
>
>对于内存监控，在top里我们要时刻监控第五行swap交换分区的used，如果这个数值在不断的变化，说明内核在不断进行内存和swap的数据交换，这是真正的内存不够用了。
>
>第四行中使用中的内存总量（used）指的是现在系统内核控制的内存数，
>
>第四行中空闲内存总量（free）是内核还未纳入其管控范围的数量。
>
>纳入内核管理的内存不见得都在使用中，还包括过去使用过的现在可以被重复利用的内存，内核并不把这些可被重新使用的内存交还到free中去，因此在linux上free内存会越来越少，但不用为此担心。

###  第六行，空行

###  第七行以下：各进程（任务）的状态监控

```shell
PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
1297 root      10 -10  211196  94344   5988 S  1.7  5.0 216:24.39 AliYunDun

PID — 进程id
USER — 进程所有者
PR — 进程优先级
NI — nice值。负值表示高优先级，正值表示低优先级
VIRT — 进程使用的虚拟内存总量，单位kb。VIRT=SWAP+RES
RES — 进程使用的、未被换出的物理内存大小，单位kb。RES=CODE+DATA
SHR — 共享内存大小，单位kb
S —进程状态。D=不可中断的睡眠状态 R=运行 S=睡眠 T=跟踪/停止 Z=僵尸进程
%CPU — 上次更新到现在的CPU时间占用百分比
%MEM — 进程使用的物理内存百分比
TIME+ — 进程使用的CPU时间总计，单位1/100秒
COMMAND — 进程名称（命令名/命令行）
```

#### 详解

```shell
VIRT：virtual memory usage 虚拟内存
1、进程“需要的”虚拟内存大小，包括进程使用的库、代码、数据等
2、假如进程申请100m的内存，但实际只使用了10m，那么它会增长100m，而不是实际的使用量

RES：resident memory usage 常驻内存
1、进程当前使用的内存大小，但不包括swap out
2、包含其他进程的共享
3、如果申请100m的内存，实际使用10m，它只增长10m，与VIRT相反
4、关于库占用内存的情况，它只统计加载的库文件所占内存大小

SHR：shared memory 共享内存
1、除了自身进程的共享内存，也包括其他进程的共享内存
2、虽然进程只使用了几个共享库的函数，但它包含了整个共享库的大小
3、计算某个进程所占的物理内存大小公式：RES – SHR
4、swap out后，它将会降下来

DATA
1、数据占用的内存。如果top没有显示，按f键可以显示出来。
2、真正的该程序要求的数据空间，是真正在运行中要使用的。
```

## top 运行中可以通过 top 的内部命令对进程的显示方式进行控制。内部命令如下：

> s – 改变画面更新频率
> l – 关闭或开启第一部分第一行 top 信息的表示
> t – 关闭或开启第一部分第二行 Tasks 和第三行 Cpus 信息的表示
> m – 关闭或开启第一部分第四行 Mem 和 第五行 Swap 信息的表示
> N – 以 PID 的大小的顺序排列表示进程列表
> P – 以 CPU 占用率大小的顺序排列进程列表
> M – 以内存占用率大小的顺序排列进程列表
> h – 显示帮助
> n – 设置在进程列表所显示进程的数量
> q – 退出 top
> s – 改变画面更新周期

##  top使用方法：

- 使用格式：`top [-] [d] [p] [q] [c] [C] [S] [s] [n]`

**参数说明：**

1. d：指定每两次屏幕信息刷新之间的时间间隔。当然用户可以使用s交互命令来改变之。

2. p:通过指定监控进程ID来仅仅监控某个进程的状态。
3. 用户权限，那么top将以尽可能高的优先级运行。
4. S：指定累计模式
5. *s：使top命令在安全模式中运行。这将去除交互命令所带来的潜在危险
6. i：使top不显示任何闲置或者僵死进程。
7. c:显示整个命令行而不只是显示命令名。
8. 常用命令说明：
9. Ctrl+L：擦除并且重写屏幕
10. K：终止一个进程。系统将提示用户输入需要终止的进程PID，以及需要发送给该进程什么样的信号。一般的终止进程可以使用15信号；如果不能正常结束那就使用信号9强制结束该进程。默认值是信号15。在安全模式中此命令被屏蔽。
11. i：忽略闲置和僵死进程。这是一个开关式命令。
12. q：退出程序
13. r:重新安排一个进程的优先级别。系统提示用户输入需要改变的进程PID以及需要设置的进程优先级值。输入一个正值将使优先级降低，反之则可以使该进程拥有更高的优先权。默认值是10。
14. S：切换到累计模式。
15. s：改变两次刷新之间的延迟时间。系统将提示用户输入新的时间，单位为s。如果有小数，就换算成m s。输入0值则系统将不断刷新，默认值是5 s。需要注意的是如果设置太小的时间，很可能会引起不断刷新，从而根本来不及看清显示的情况，而且系统负载也会大大增加。
16. f或者F：从当前显示中添加或者删除项目。
17. o或者O：改变显示项目的顺序
18. l：切换显示平均负载和启动时间信息。
19. m:切换显示内存信息。
20. t:切换显示进程和CPU状态信息。
21. c:切换显示命令名称和完整命令行。
22. M:根据驻留内存大小进行排序。
23. P:根据CPU使用百分比大小进行排序。
24. T:根据时间/累计时间进行排序。
25. W:将当前设置写入~/.toprc文件中。

## Linux查看物理CPU个数、核数、逻辑CPU个数

```shell
# 总核数 = 物理CPU个数 X 每颗物理CPU的核数 
# 总逻辑CPU数 = 物理CPU个数 X 每颗物理CPU的核数 X 超线程数

# 查看物理CPU个数
cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l

# 查看每个物理CPU中core的个数(即核数)
cat /proc/cpuinfo| grep "cpu cores"| uniq

# 查看逻辑CPU的个数
cat /proc/cpuinfo| grep "processor"| wc -l
# 查看CPU信息（型号）
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c
# 查看内 存信息
cat /proc/meminfo
```

