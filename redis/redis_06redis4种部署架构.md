---
title: 06 redis 四种部署结构
date: 2020-02-11 09:14:10
tags:
  - redis
categories:
  - redis
topdeclare: true
reward: true
---

# Redis 搭建模式

Redis 的搭建方式：

- 单机
- 主从
- 哨兵
- 集群

单机，只要一台Redis服务器，挂了就无法工作了

主从，是备份关系， 数据也会同步到从库，还可以读写分离

哨兵：master挂了，哨兵就行选举，选出新的master，作用是监控主从，主从切换

集群：高可用，分散请求。目的是将数据分片存储，节省内存。

# 单机

![img](redis-06redis4种架构/25000004-29c2b1b61a1ba424.png)

# 主从

持久性保证了即使redis服务重启也不会丢失数据，因为redis服务重启后将硬盘上持久化的数据恢复到内存中，但是当redis服务器的硬盘损坏了可能导致数据丢失，不过通过redis的主从复制机制旧可以避免这种单点故障

![img](redis-06redis4种架构/25000004-ed07c93c8c278a15.png)

说明:

1. 主redis中的数据有两个副本(replication)即从redis1和从redis2，即使一台redis服务器宕机其他两台redis服务也可以继续提供服务。
2. 主redis中的数据和从redis上的数据保持实时同步，当主redis写入数据时通过主从复制机制会复制到两个从redis服务上。
3. 只有一个主redis，可以有多个从redis。
4. 主从复制不会阻塞master，在同步数据时，master可以继续处理client请求

## 主从配置

### 主redis配置

无需特殊配置

### 从redis配置

修改从服务器上的redis.conf文件

```shell
# slaveof <masterip> <masterport>
slaveof 192.168.31.200 6379
```

上边的配置说明当前【从服务器】对应的【主服务器】的ip是192.168.31.200，端口是6379.

### 实现原理

1. slave第一次或者重连到master发送一个**SYNC**的命令。
2. master收到SYNC的时候，会做两件事
   1. 执行bgsave(rdb的快照文件)
   2. master会把新收到的修改命令存入到缓冲区

**缺点：没有办法对master进行动态选举**

## 哨兵

### 简介

Sentinel(哨兵)进程是用于监控redis集群中Master主服务器工作的状态，在Master主服务器发生故障的时候，可以实现Master和Slave服务器的切换，保证系统的高可用，其已经被集成在redis2.6+的版本中，Redis的哨兵模式到2.8版本之后就稳定了下来。

### 哨兵进程的作用

1.  **监控**(Monitoring)：哨兵(Sentinel)会不断地检查你的Master和Slave是否运作正常。
2.  **提醒**(Notification)：当被监控的某个Redis节点出现问题时，哨兵(Sentinel)可以通过API向管理员或者其他应用程序发送通知。
3.  **自动故障迁移**(Automatic failover)：当一个Master不能正常工作时，哨兵(Sentinel)会开始一次自动故障迁移操作。
   1. 它会将失效Master的其中一个Slave升级为新的Master，并让失效Master的其他Slave改为复制新的Master；
   2. 当客户端视图连接失效的Master时，集群也会向客户端返回新Master的地址，使得集群可以使用现在的Master替换失效的Master。
   3. Master和Slave服务器切换后，Master的redis.conf、Slave的redis.conf和sentinel.conf的配置文件的内容都会发生相应的改变，即Master主服务器的redis.conf配置文件中会多一行Slave的配置，sentinel.conf的监控目标会随之调换。

### 哨兵进程的工作方式

1. 每个Sentinel(哨兵)进程以**每秒钟一次**的频率**向整个集群**中的**Master主服务器**，**Slave从服务器以及其他Sentinel(哨兵)进程**发送一个**PING命令**。
2. 如果一个实例(instance)距离最后一次有效回复PING命令的时间超过down-after-milliseconds选项所指定的值，则这个实例会被Sentinel(哨兵)进程标记为**主观下线**(**SDOWN**)。
3. 如果一个Master主服务器被标记为主观下线(SDOWN)，则正在监视这个Master主服务器的**所有Sentinel(哨兵)**进程要以每秒一次的频率**确认Master主服务器**确实**进入**了**主观下线状态**。
4. 当有**足够数量的Sentinel(哨兵)进程(**大于等于配置文件指定的值)在指定的时间范围内**确认Master主服务器进入了主观下线状态(SDOWN)**，则Master**主服务器**会被标记为**客观下线(ODOWN)**。
5. 在一般情况下，每个Sentinel(哨兵)进程会以每10秒一次的频率向集群中的所有Master主服务器、Slave从服务器发送INFO命令。
6. 当Master主服务器被Sentinel(哨兵)进程标记为客观下线(ODOWN)时，Sentinel(哨兵)进程向下线的Master主服务器的所有Slave从服务器发送INFO命令的频率会从10秒一次改为每秒一次。
7. 若没有足够数量的Sentinel(哨兵)进程同意Master主服务器下线，Master主服务器的客观下线状态就会被移除。若Master主服务器重新向Sentinel(哨兵)进程发送PING命令返回有效回复，Master主服务器的主观下线状态就会被移除。

### 实现

#### 修改从机的sentinel.conf

```shell
sentinel monitor mymaster  192.168.127.129 6379 1
```

#### 启动哨兵服务器

```shell
./redis-sentinel sentinel.conf
```



## 集群

![img](redis-06redis4种架构/25000004-58277974f918fc41.png)

### 架构细节

1. 所有的redis节点彼此互联(PING-PING机制)，内部使用二进制协议优化传输速度和带宽。
2. 节点的fail是通过集群中超过半数的节点检测失效时才生效。
3. 客户端与redis节点直连，不需要中间proxy层，客户端不需要连接集群所有节点，连接集群中任何一个可用节点即可。
4. redis-cluster把所有的物理节点映射到[0-16383]slot上，cluster负责维护node<->slot<->value

> Redis集群中内置了16384个哈希槽，当需要在Redis集群中放置一个key-value时，redis先对key使用crc16算法算出一个结果，然后把结果对16384求余数，这样每个key都会对应一个编号在0-16384之间的哈希槽，redis会根据节点数量大致均等的将哈希槽映射到不同节点。

![image-20210209083442505](redis_06redis4种部署架构/image-20210209083442505.png)

### redis-cluster投票：容错

1. 集群中所有master参与投票，如果半数以上master节点与其中一个master节点通信超过(cluster-node-timeout)，认为该master节点挂掉。

#### 什么时候整个集群不可用(cluster_state:fail)？

1. 如果集群任意master挂掉，且当前master没有slave，则集群进入fail状态。也可以理解成集群的[0-16384]slot映射不完全时进入fail状态。
2. 如果集群超过半数以上master挂掉，无论是否有slave，集群进入fail状态。

![image-20210209083516269](redis_06redis4种部署架构/image-20210209083516269.png)

# 参考

- https://www.cnblogs.com/chenyanbin/p/12073107.html