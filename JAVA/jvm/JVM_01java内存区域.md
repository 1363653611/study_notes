---
title: 01 JVM- java内存区域
date: 2019-12-09 18:14:10
tags:
  - JVM
  - java
categories:
  - JVM
  - java
topdeclare: true
reward: true
---
### JVM
#### java内存区域

##### 运行时数据区域  
	有些区域随着虚拟机的进程的启动而存在  
	有些区域随着用户线程的启动/结束来建立和销毁  

<!--more-->
###### 线程私有
1. 程序计数器（Program Counter Register）
- 标记:__线程私有__
- 一块较小的内存区域
- 唯一一个在java内存中没有规定OutOfMemoryError
- 作用
	- 当前线程所执行的字节码的行号指示器
	- 记录线程的执行的位置。多线程切换时，每个线程能正确回到之前执行的位置。
	- 线程特点
		- 如果执行java方法。记录的时虚拟机字节码指令的地址
		- netive方法，则这个计数器则为空（Undefined）

2. java虚拟机栈(java virtual machine stacks)
- 标记: __线程私有__
- 生命周期与线程相同
- 异常情况
	- StackOverflowError
		- 线程请求栈的深度大于虚拟机所允许的深度
	- OutOfMemoryError
		- 如果虚拟机栈可以动态扩展，如果拓展时无法申请到足够的内存
	- 栈帧（Stack Frame）
		- 局部变量
			1. boolean
			2. byte
			3. char
			4. short
			5. int
			6. float
			7. long
			8. double
			9. 对象引用
			10. returnAddress类型

  	- 操作数栈
  	- 动态链接
  	- 方法出口

- 容量大小的设置: `-Xxs128k`

3. 本地方法栈（native Method Stack）
标记: __线程私有__
- 虚拟机使用到的native方法服务

###### 线程共享
1. java堆 （java Heap）
- 标记: __线程共享__
- GC 堆
- 说明
	- java堆时垃圾收集管理的主要区域
	- 线程共享的区域。在虚拟机启动时创建
	- java内存可以物理上不连续，只要逻辑上连续即可
- 划分:
	- 分代收集算法
		1. 新年代
		2. 老年代
	- 细分
		1. Eden空间
		2. From Survivor
		3. To Survivor
    4. 老年代
    5. 永久代

	- 内存分配角度
		- 线程共享的java堆中可能划分出多个线程私有的分配缓冲区 `TLAB(Thread Local Allocation Buffer)`
	- 异常划分
		- OutOfMemoryError
	- 容量设置
		```
		-Xms20m   堆的最小容量
		-Xmx20m  堆的最大容量
		-XX：+HeapDumpOnOutOfMemoryError  将异常时dump出当前的内存转储快照
		```

2. 方法区（Method Area）
- 标记: __线程共享__
- 说明
	- java规范把方法区描述为堆的逻辑部分，但是它却有一个名字叫非堆（Non-Heap）
	- 存储
		1. 虚拟机加载的类信息
		2. 常量
		3. 静态变量
		4. 即时编译后的代码数据

	- 永久带（Permanent Generation）
		- 使用永久代来实现方法区
		- 垃圾回收：主要是针对常量池的回收和类型的卸载
		- 容量的设置
			```
			-XX：PermSize=10M
			-XX:MaxPermSize=10M
			```
3. 运行时常量池（RunTime Constant Pool）
- 标记: __线程共享__
- 说明
	- 方法区的一部分
	- 动态特性
		- 运行时也可以将常量放入常量池中
		- eg：`String.intern()`
- 常量池（Constant Pool Table）
	- 编译期生成的各种字面常量和符号引用
	- 直接引用

4. 直接内存(Direct  Memory)
- NIO引入
  - DirectByteBuffer
- 异常
  - OutofMemoryError
  - 容量的小：可以通过-XX：MaxDirectMemorySize=10M来指定，如果不指定，则和堆内存-Xmx的大小一致
