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
### 垃圾收集器和内存分配策略
#### 对象已死
- 算法
	- 引用计数算法
	- 问题：无法解决循环引用问题
- 可达性分析算法
<!--more-->
	- GC roots
		1. 虚拟机栈（栈帧中本地变量表）中引用的对象
		2. 方法区中类静态属性引用的对象
		3. 方法区中常量引用的对象
		4. 本地方法栈中JNI(native方法)引用的对象

#### 对象引用

- 强引用Strong reference
	- 垃圾收集器永远不会回收
- 软引用 soft reference
	- 在系统发生内存溢出之前，将会把这些对象列进回收范围之内进行二次回收
- 弱引用 weak reference
	- 该引用的对象只能生存到下一次垃圾回收之前
- 虚引用 phantom reference
	- 对象是否有虚引用存在，完全不会对其生存时间造成影响。
	- 作用是能在这个对象被收集器回收时收到一个系统通知
- 对象生存还是死亡
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

- 回收方法区（永久代的垃圾回收）
	- 废弃的常量
		- string
		- 类（接口）、方法、字段符号的引用

- 无用的类
	- 条件：
		1. 该类所有的实例已经被回收
		2. 加载该类的classload已经被回收
		3. 该类对应的java.lang.class 对象没有在任何地方被引用，无法在任何地方通过反射访问该类的方法

	- hotSpot配置参数观察无用类回收情况
		```
		-verbose:class
		-XX:+TraseClassLoading
		-XX:+TraseClassUnLoading
		```

#### 垃圾收集算法

1. 标记-清除算法（Mark-Sweep）
	- 不足
		1. 效率问题，标记和清除过程的效率都不高
		2. 空间问题：标记清除之后会产生大量不连续的碎片。

2. 复制算法

3. 标记整理算法

4. 分代收集算法

#### hotSpot 的算法实现
1. 枚举根节点
2. 安全点
3. 安全区域

#### 垃圾收集器(收集器类型)

1. Serial 收集器（复制算法）
	- 缺点
		- 线程收集器：他进行垃圾收集时，必须暂停其他所有工作线程（stop the word）
	- 用途
		- Client 模式下默认的新生代收集器
		- 和CMS收集器配合使用
	- 特点
		- 与其他收集器的线程比简单而高效（没有线程切换的开销）

2. ParNew收集器（复制算法）
	- 多线程收集器（多条垃圾回收线程同时执行，工作线程仍就处于等待状态）
	- 用途
		- 可以和CMS收集器配合使用
		- server模式下虚拟集中首选的新生代收集器
	- 其他
		- 使用 -XX:UseConcMarkSweepGC  后，新生代使用ParNew收集器为默认收集器
		- -XX:UserParNewGC  强制制定ParNewGC为新生代收集器
		- -XX:ParallelGCThreads  控制垃圾收集线程的数量

3. Parallel Scavenge 收集器（复制算法）
	- 特点
		- 新生代收集器（复制算法）
		- 并行的多线程收集器
	- 关注点
		- 达到一个可控制的吞吐量（吞吐量优先收集器）
		- 吞吐量 = 运行用户代码时间/（运行用户代码时间+垃圾收集时间）
	- 用途
		- 适合在后台运算而不需要太多交互任务的地方
		- 配置参数
			* -XX:MaxGCPauseMillis   最大垃圾收集停顿时间（大于0的数值）
			* -XX: GCTimeRatio 直接设置吞吐量（0-100 的整数）
			* -XX:+UseAdaptiveSizePolicy   --GC自适应调整策略： 虚拟机根据当前系统的运行情况收集性能监控信息，动态调整堆内存中的相关参数，以提供最适合的停顿时间或者最大的吞吐量

4. Serial Old 收集器（标记整理算法）
	-	Serial 的老年代版本
	- 标记-整理算法
	- Client模式
	- 其他
		- JDK1.5之前，如果新生代使用了Parallel Scavenge 收集器，老年代必须使用Serial Old收集器
		- CMS 收集器的后备方案

5. Parallel Old 收集器（标记-整理）
	- JDK1.6 之后提供
	- 和 parallel Sacvenge收集器配合，提供吞吐量

6. CMS 收集器(Concurrent Mark Sweep) (标记整理算法)
	- 特点
		- 重视服务的响应速度，希望系统的停顿时间最短
	- 运行过程
		- 初始标记CMS initial mark（串行）
			- 需要stop the word
			- 速度很快 ：仅仅只是标记需要GC roots 关联到的对象
		- 并发标记 CMS concurrent mark（并发）
			- 进行GC roots Tracing 的过程
			- 时间长
			- 和用户线程一起运行

		- 重新标记 CMS remark（并行）
			-	需要stop the word
			- 速度较长，但远比并发标记时间短：修正并发标记期间因用户程序继续运行而导致标记产生变化的那一部分的对象标记记录
		- 并发清除  CMS concurrent sweep（并发）
			- 时间长
			- 和用户线程一起运行

- 缺点
	- 对cpu资源非常敏感
	- 无法处理浮动垃圾（floating Garbage），可能出现“Concurrent Mode Failure ”失败，导致另一侧full GC。
		- 浮动垃圾：由于cms并发清理垃圾阶段，用户线程还在执行，伴随着程序运行自然就会产生新的垃圾，这一步分垃圾在标记过程之后残生，cms无法在档次收集中处理他们，只好到下一次处理。
		- jdk1.5 的默认设置下，cms收集器，当老年代使用了68%的空间后，cms收集被激活，这是一个偏保守的设置
		- 使用 -XX:CMSInitiatingOccupancyFraction 的值来提高触发的cms的收集动作
	- CMS 是一个基于标记-清除的算法实现的收集器，会产生大量的空间碎片
		* -XX:UserCMSCompactAtFullCollection ---开起碎片合并整理过程（停顿时间变长）
		* -XX:CMSFullGCsBeforeCompaction  用来设置执行多少次不压缩后，执行一次压缩

#### G1 收集器
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

#### GC日志
- [GC   /  [Full GC  ---垃圾回收的类型
- GC发生的区域
	- [DefNew  (defaut new generation)
		- erial 收集器
		- 新生代
	- [ParNew    (perallel new Generation)
		- ParNew 收集器
	- [Tenured
	- [Perm

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
					* -verbose：class  运行时，有多少class被加载
					* -verbose： gc   虚拟机发生内存回收时，在控制台显示
					* -verbose：jni：jni 输出native方法的调用情况。一般用于判断jni调用错误
			* -XX:+PrintGCDetails  -- 打印垃圾回收信息
