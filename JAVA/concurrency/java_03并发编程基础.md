---
title: 03 并发编程基础
date: 2019-12-10 15:14:10
tags:
 - concurrency
 - 并发
 - java
categories:
 - java
 - concurrency
topdeclare: true
reward: true
---
### 并发编程基础

#### 线程简介
1. 什么是线程 （现代操作系统调度的最小单元）
2. 为什么要使用线程
  - 更多的处理器核心
  - 更快的响应时间
  - 更好的编程模型
3. 线程优先级 （priority）
 - 默认级别是 5
 - 操作系统不同，线程的优先级可能表现出不同的效果
4. 线程状态
  - new 初始状态（还没有调用start 方法）
  - runnable 就绪和运行状态
  - blocked 阻塞于锁的状态
  - waiting 等待
  - time wating 超时等待
  - terminaled 终止状态
5. daemon 守护线程  
 在构建daemon 线程时，不能依靠finally 中的语句块来确保关闭或者清理资源的逻辑。
#### 线程的启动和终止
-  线程启动，调用start 方法
- 中断
  中断是线程的一个标识属性，表示一个运行中的线程是否被其他线程进行了中断操作。（其他线程给该线程打了个招呼）  
  线程自身可以通过isInterrupted 方法来判断是否被中断。
- 过期的 ~~suspend~~（暂停），~~resume~~（恢复），~~stop~~（停止）  
 以上操作导致不能有效的释放资源，或者导致死锁问题
- 安全的终止线程  
 使用标志位来停止线程。（interrupted 方式）
#### 线程通讯

##### volatile 和 synchronized 关键字
##### 等待/通知机制
1. 调用 wait 方法后，会释放对象的锁
2. 调用notify 方法时，不会释放对象的锁。
