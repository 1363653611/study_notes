---
title: 03 LUNIX查看日志方法
date: 2020-01-14 15:14:10
tags:
 - LUNIX
categories:
 - LUNIX
topdeclare: true
reward: true
---
## 查看日志
### 常规命令:
```LUNIX
cat service.log
tail -f service.log
vim serivice.log
```
- vim 操作文件
 ```lunix
  - 打开文件
  vim filename
  - 按G跳转到文件末尾
  - 按 ? + 关键字 指定位置
  - 按 n 往上查找, 按N 往下查找
 ```
 - 实时查看日志  `tail -f filename.log`


<!--more-->

### 大文件查看
- 配合 grep 来查看
  - `cat -n service.log | grep error` 将 文件中包含error d的文件索引出来,而且包含 行号,加入行号为 2908
  - `sed -n "2918,2928p" service.log` 从2918行开始检索，到2928行结束
  - 或者 `cat -n service.log | tail -n +29496 | head -n 20` 从29496行开始检索，往前推20条

- 如果关键字不太准确（日志输出的记录太多了），我们可以使用more命令来浏览或者输出到文件上再分析
  - `cat service.log | grep 13 |more` 将查询后的结果交由more输出
  - `cat service.log | grep 13 &gt; /home/sanwai/aa.txt` 将查询后的结果写到/home/sanwai/aa.txt文件上
### 统计日志输出多少行 `cat service.log | wc -l`

## 查进程和端口
- 常用命令:
```lunix
ps -ef
ps aux
```
- 通过和管道符配配合使用: `ps -ef |grep java` 查看 java 的进程
- 杀死进程 `kill -9 processId`
- 端口号查询 `netstat -nlp|grep 8080` # 查看端口号为 8080 的进程
- `netstat -lntup` 查端口也是一个很常见的操作
- 查看某个端口详细的信息：`lsof -i:4000`

## 查看系统状态
### 使用  top 查看系统状态
- load average：在特定时间间隔内运行队列中(在CPU上运行或者等待运行多少进程)的 __平均进程数__
- load average 有三个值，分别代表：1分钟、5分钟、15分钟内运行进程队列中的平均进程数量。
  - 正在运行的进程 + 准备好等待运行的进程-->   在特定时间内（1分钟，5分钟，10分钟）的平均进程数
- Linux进程可以分为三个状态：
  - 阻塞进程
  - 可运行的进程
  - 正在运行的进程
- eg: 现在系统有2个正在运行的进程，3个可运行进程，那么系统的load就是5，load average就是一定时间内的 __load数量均值__

## free查看内存使用状况
- linux的内存管理机制的思想包括（不敢说就是）内存利用率最大化，内核会把剩余的内存申请为cached，而cached不属于free范畴
- 如果free的内存不够，内核会把部分cached的内存回收，回收的内存再分配给应用程序。所以对于linux系统，可用于分配的内存不只是free的内存，还包括cached的内存（其实还包括buffers）。
- 可用内存=free的内存+cached的内存+buffers
- Buffer Cache和Page Cache。前者针对磁盘块的读写，后者针对文件inode的读写。这些Cache有效缩短了 I/O系统调用(比如read,write,getdents)的时间。磁盘的操作有逻辑级（文件系统）和物理级（磁盘块)
