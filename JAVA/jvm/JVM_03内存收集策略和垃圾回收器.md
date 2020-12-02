---
title: 03 垃圾收集器和内存分配策略
date: 2019-12-10 18:14:10
tags:
  - JVM
  - java
categories:
  - JVM
  - java
topdeclare: true
reward: true
---

# 堆内存的基本结构

![image-20200731115054798](JVM_03内存收集策略和垃圾回收器/image-20200731115054798.png)

大部分情况，对象都会首先在 Eden 区域分配，在一次新生代垃圾回收后，如果对象还存活，则会进入 s0 或者 s1，并且对象的年龄还会加 1(Eden 区->Survivor 区后对象的初始年龄变为 1)，当它的年龄增加到一定程度（默认为 15 岁），就会被晋升到老年代中。对象晋升到老年代的年龄阈值，可以通过参数 `-XX:MaxTenuringThreshold` 来设置。

Hotspot遍历所有对象时，按照年龄从小到大对其所占用的大小进行累积，当累积的某个年龄大小超过了survivor区的一半时，取这个年龄和MaxTenuringThreshold中更小的一个值，作为新的晋升年龄阈值

经过Minor GC后，Eden区和"From"区已经被清空。这个时候，"From"和"To"会交换他们的角色，也就是新的"To"就是上次GC前的“From”，新的"From"就是上次GC前的"To"。不管怎样，都会保证名为To的Survivor区域是空的。Minor GC会一直重复这样的过程，直到“To”区被填满，"To"区被填满之后，会将所有对象移动到老年代中。

**关于默认的晋升年龄是15，这个说法的来源大部分都是《深入理解Java虚拟机》这本书。** 如果你去Oracle的官网阅读[相关的虚拟机参数](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/java.html)，你会发现`-XX:MaxTenuringThreshold=threshold`这里有个说明

**Sets the maximum tenuring threshold for use in adaptive GC sizing. The largest value is 15. The default value is 15 for the parallel (throughput) collector, and 6 for the CMS collector.默认晋升年龄并不都是15，这个是要区分垃圾收集器的，CMS就是6.**

## 垃圾收集器和内存分配策略

![image-20200731115405426](JVM_03内存收集策略和垃圾回收器/image-20200731115405426.png)

###  对象已死

![image-20200731133431380](JVM_03内存收集策略和垃圾回收器/image-20200731133431380.png)

- 算法
	- 引用计数算法
	- 问题：无法解决循环引用问题
	
	<!--more-->
	
- 可达性分析算法

	![image-20200731133646168](JVM_03内存收集策略和垃圾回收器/image-20200731133646168.png)
	
	
	
	- GC roots
		1. 虚拟机栈（栈帧中本地变量表）中引用的对象
		2. 方法区中类静态属性引用的对象
		3. 方法区中常量引用的对象
		4. 本地方法栈中JNI(native方法)引用的对象

### 对象引用

- 强引用Strong reference
	- 圾回收器绝不会回收它。当内存空间不足，Java 虚拟机宁愿抛出 `OutOfMemoryError` 错误，使程序异常终止，也不会靠随意回收具有强引用的对象来解决内存不足问题。
	- 垃圾收集器永远不会回收
- 软引用 soft reference
	- 在系统发生内存溢出之前，将会把这些对象列进回收范围之内进行二次回收
	- 软引用可用来实现内存敏感的高速缓存
	- 软引用可以和一个引用队列（`ReferenceQueue`）联合使用，如果软引用所引用的对象被垃圾回收，JAVA 虚拟机就会把这个软引用加入到与之关联的引用队列中。
- 弱引用 weak reference
	- 该引用的对象只能生存到下一次垃圾回收之前
	- 弱引用与软引用的区别在于：只具有弱引用的对象拥有更短暂的生命周期。在垃圾回收器线程扫描它所管辖的内存区域的过程中，一旦发现了只具有弱引用的对象，不管当前内存空间足够与否，都会回收它的内存
- 虚引用 phantom reference
	- 对象是否有虚引用存在，完全不会对其生存时间造成影响。
	- 作用是能在这个对象被收集器回收时收到一个系统通知

> 在程序设计中一般很少使用弱引用与虚引用，使用软引用的情况较多，这是因为**软引用可以加速 JVM 对垃圾内存的回收速度，可以维护系统的运行安全，防止内存溢出（OutOfMemory）等问题的产生**

### 对象生存还是死亡
	- 注：可达性分析算法中，的不可达对象，要宣布死亡，需要经历两次标记过程。
	- 标记过程：
		- 第一次标记/筛选
			- 条件：对象是否有必要执行finalize方法
				- 没必要执行的条件：
					1. 对象没有覆盖finalize方法
					2. finalize方法已经执行过
			- 第一次标记后存放到F-queue的队列中
	 - 第二次小规模标记
	 	- 将f-queue中的对象最后一次标记
		- 执行finalize方法。finalize方法中对象逃脱回收的最后机会

### 回收方法区（永久代的垃圾回收）
- 废弃的常量
	- string
	- 类（接口）、方法、字段符号的引用

- 无用的类
	- 条件：
		1. 该类所有的实例已经被回收
		2. 加载该类的classload已经被回收
		3. 该类对应的java.lang.class 对象没有在任何地方被引用，无法在任何地方通过反射访问该类的方法

	- hotSpot配置参数观察无用类回收情况
		```shell
		-verbose:class
		-XX:+TraseClassLoading
		-XX:+TraseClassUnLoading
		```

## 垃圾收集算法

### 标记-清除算法（Mark-Sweep）

<img src="JVM_03内存收集策略和垃圾回收器/image-20200731134943967.png" alt="image-20200731134943967" style="zoom: 50%;" />

- 不足
	1. 效率问题，标记和清除过程的效率都不高
	2. 空间问题：标记清除之后会产生大量不连续的碎片。

### 复制算法

<img src="JVM_03内存收集策略和垃圾回收器/image-20200731135153159.png" alt="image-20200731135153159" style="zoom: 80%;" />

### 标记整理算法

<img src="JVM_03内存收集策略和垃圾回收器/image-20200731135421938.png" alt="image-20200731135421938" style="zoom: 80%;" />

### 分代收集算法

当前虚拟机的垃圾收集都采用分代收集算法，这种算法没有什么新的思想，只是根据对象存活周期的不同将内存分为几块。一般将 java 堆分为新生代和老年代，这样我们就可以根据各个年代的特点选择合适的垃圾收集算法。

- 新生代: 每次收集都会有大量对象死去，所以可以选择复制算法.只需要付出少量对象的复制成本就可以完成每次垃圾收集
- 老年代: 对象存活几率是比较高的，而且没有额外的空间对它进行分配担保.所以我们必须选择“标记-清除”或“标记-整理”算法进行垃圾收集

# hotSpot 的算法实现
1. 枚举根节点
2. 安全点
3. 安全区域

# 垃圾收集器(收集器类型)

## Serial 收集器（复制算法）

![image-20200731140138672](JVM_03内存收集策略和垃圾回收器/image-20200731140138672.png)

它的 **“单线程”** 的意义不仅仅意味着它只会使用一条垃圾收集线程去完成垃圾收集工作，更重要的是它在进行垃圾收集工作的时候必须暂停其他所有的工作线程（ **"Stop The World"** ），直到它收集结束。

__新生代采用 复制算法,老年代采用 标记-整理 算法.__

- 缺点
	- 线程收集器：他进行垃圾收集时，必须暂停其他所有工作线程（stop the word）
- 用途
	- Client 模式下默认的新生代收集器
	- 和CMS收集器配合使用
- 特点
	- 与其他收集器的线程比简单而高效（没有线程切换的开销）

## ParNew收集器（复制算法）

![image-20200731140614867](JVM_03内存收集策略和垃圾回收器/image-20200731140614867.png)

**ParNew 收集器其实就是 Serial 收集器的多线程版本，除了使用多线程进行垃圾收集外，其余行为（控制参数、收集算法、回收策略等等）和 Serial 收集器完全一样。**

__新生代采用 复制算法,老年代采用 标记-整理 算法.__

- 多线程收集器（多条垃圾回收线程同时执行，工作线程仍就处于等待状态）
- 用途
	- 可以和CMS收集器配合使用
	- server模式下虚拟集中首选的新生代收集器
- 其他
	- 使用 -XX:UseConcMarkSweepGC  后，新生代使用ParNew收集器为默认收集器
	- -XX:UserParNewGC  强制制定ParNewGC为新生代收集器
	- -XX:ParallelGCThreads  控制垃圾收集线程的数量

## Parallel Scavenge 收集器（复制算法）

- 组合1

![image-20200731141241168](JVM_03内存收集策略和垃圾回收器/image-20200731141241168.png)

- 组合2

![image-20200731141417357](JVM_03内存收集策略和垃圾回收器/image-20200731141417357.png)

Parallel Scavenge 收集器也是使用复制算法的多线程收集器，它看上去几乎和ParNew都一样。

> `-XX:+UseParallelGC `
>      使用 Parallel 收集器+ 老年代串行
> `-XX:+UseParallelOldGC`
>     使用 Parallel 收集器+ 老年代并行

__新生代采用 复制算法,老年代采用 标记-整理 算法.__

  - 特点
      	- 新生代收集器（复制算法）
            	- 并行的多线程收集器
  - 关注点
      	- 达到一个可控制的吞吐量（吞吐量优先收集器）(高效率的利用 CPU)
            	- 吞吐量 = 运行用户代码时间/（运行用户代码时间+垃圾收集时间）
  - 用途
  	- 适合在后台运算而不需要太多交互任务的地方
   - 配置参数
        - `-XX:MaxGCPauseMillis`   最大垃圾收集停顿时间（大于0的数值）
        - `-XX: GCTimeRatio` 直接设置吞吐量（0-100 的整数）
        - `-XX:+UseAdaptiveSizePolicy `  --GC自适应调整策略： 虚拟机根据当前系统的运行情况收集性能监控信息，动态调整堆内存中的相关参数，以提供最适合的停顿时间或者最大的吞吐量

## Serial Old 收集器（标记整理算法）

  -	Serial 的老年代版本
  - 标记-整理算法
  - Client模式
  -	其他
       - JDK1.5之前，如果新生代使用了Parallel Scavenge 收集器，老年代必须使用Serial Old收集器 
       - CMS 收集器的后备方案

## Parallel Old 收集器（标记-整理）

  - Parallel Scavenge 收集器的老年代版本
  - JDK1.6 之后提供
  - 和 parallel Sacvenge收集器配合，提供吞吐量
## CMS 收集器(Concurrent Mark Sweep) (标记整理算法)

**CMS（Concurrent Mark Sweep）收集器是一种以获取最短回收停顿时间为目标的收集器。它非常符合在注重用户体验的应用上使用**

**CMS（Concurrent Mark Sweep）收集器是 HotSpot 虚拟机第一款真正意义上的并发收集器，它第一次实现了让垃圾收集线程与用户线程（基本上）同时工作。**

![image-20200731142230981](JVM_03内存收集策略和垃圾回收器/image-20200731142230981.png)

  - 特点
       - 重视服务的响应速度，希望系统的停顿时间最短
  - 运行过程
       - 初始标记CMS initial mark（串行）
           - 需要stop the word
           - 速度很快 ：仅仅只是标记需要GC roots 关联到的对象
       - 并发标记 CMS concurrent mark（并发）
           - 进行GC roots Tracing 的过程,这个算法里会跟踪记录这些发生引用更新的地方
           - 时间长
              - 和用户线程一起运行

       - 重新标记 CMS remark（并行）
           - 需要stop the word
               - 速度较长，但远比并发标记时间短：修正并发标记期间因用户程序继续运行而导致标记产生变化的那一部分的对象标记记录
       - 并发清除  CMS concurrent sweep（并发）
               - 时间长
                   - 和用户线程一起运行

- 缺点
	- 对cpu资源非常敏感
	- 无法处理浮动垃圾（floating Garbage），可能出现“Concurrent Mode Failure ”失败，导致另一侧full GC。
		- 浮动垃圾：由于cms并发清理垃圾阶段，用户线程还在执行，伴随着程序运行自然就会产生新的垃圾，这一步分垃圾在标记过程之后残生，cms无法在档次收集中处理他们，只好到下一次处理。
		- jdk1.5 的默认设置下，cms收集器，当老年代使用了68%的空间后，cms收集被激活，这是一个偏保守的设置
		- 使用 `-XX:CMSInitiatingOccupancyFraction` 的值来提高触发的cms的收集动作
	- CMS 是一个基于标记-清除的算法实现的收集器，会产生大量的空间碎片
		* `-XX:UserCMSCompactAtFullCollection` ---开起碎片合并整理过程（停顿时间变长）
		* `-XX:CMSFullGCsBeforeCompaction`  用来设置执行多少次不压缩后，执行一次压缩

## G1 收集器
- 特点
	- 并发与并行
	- 分代收集
	- 空间整合
	- 可预测停顿

- 说明：G1将整个Java堆划分为多个大小的独立区域（region）。虽然保留了新生代和老年代的区分，但是这两个概念之间不再是物理隔离了。他们都是一部分region的集合（不需要连续）

- 使用region划分内存空间以及有优先级区域（后台维护了一个优先级列表）回收的方式，保证了有效时间内可以获取尽可能高的收集效率

- 运行过程：
	- 初始标记 initial Marking（串行）
		- 记录GC roots 能关联到的对象
		- 修改TAMS (next top at mark start)的值，让用户线程并发运行时，能在正确可用的region中创建对象，这过程需要停顿线程
	- 并发标记 concurrent Marking（并发）
		- 从GC roots开始，对对象做可达性分析，找出最终存活的对象
		- 虚拟机将这段时间产生的变化记录在remembered set Logs里面
		- 耗时长
	- 最终标记 final marking（并行）
		- 修正并发标记期间因用户程序继续运行而导致标记产生变化的那一部分的对象标记记录。
		- 将remembered set log 中的数据最终和并到remembered set中
	- 筛选回收 live data counting and evacuation(并行)
		- 对各个region的回收价值和成本进行排序，依据用户所期望的GC停顿时间来定制回收计划，

# GC日志
- `[GC   /  [Full GC`  ---垃圾回收的类型
- GC发生的区域
	- `[DefNew  (defaut new generation)`
		- erial 收集器
		- 新生代
	- `[ParNew    (perallel new Generation)`
		- ParNew 收集器
	- `[Tenured`
	- `[Perm`

- 垃圾收集器参数的总结
  - 内存分配与回收策略
  	- 问题痛点
  		- 给对象分配内存
  		- 回收分配给对象的内存
  - 分配规则
    - 对象先在eden 分配
    - 大对象直接在老年代分配
    	
    	* -XX:PretenureSizeThreshold   设置对象大小阀值，新建对象大于改值时，直接在老年代分配内存
    - 长期存活的对象直接进入老年代
    	- 对象年龄
    		- 使用对象年龄计数器来记录，默认为15岁
    		- 可以认为指定：-XX：MaxTenuringThreshold   来设置
    	- 对象每熬过一次minorGC ，对象年龄增加一岁，当超过阀值时，分配到老年代

    - 动态对象年龄判定
    	
    	- 如果在survivor空间中，相同年龄所有对象大小综合大于survivor空间的一半，年龄大于或者等于改念龄的对象就直接进入老年代。
    - 空间分配担保
    - 相关配置参数
      * -verbose

         * `-verbose：class`  运行时，有多少class被加载
         * `-verbose： gc`   虚拟机发生内存回收时，在控制台显示
         * `-verbose：jni`：jni 输出native方法的调用情况。一般用于判断jni调用错误

         - `-XX:+PrintGCDetails`  -- 打印垃圾回收信息
