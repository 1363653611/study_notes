# MySQL 数据库的死锁、事务日志

# 死锁

死锁是指**两个或多个事务在执行过程中，因争夺资源而造成的一种互相等待的现象，若无外力作用，它们都将无法推进下去**。当多个事务尝试以不同的顺序锁定资源，或者多个事务同时锁定同一个资源，都有可能产生死锁。

## 场景：两个事务同时处理 customer 表

两个事务同时执行了第一条 update 语句，更新并锁定了该行数据，紧接着又都执行第二条 update 语句，此时发现该行已经被对方锁定，然后两个事务都等待对方释放锁，同时又持有对方需要的锁，陷入死循环，需要外力介入才能解除死锁。

```sql
mysql> CREATE TABLE `customer` (
  `id` int(11) NOT NULL,
  `last_name` varchar(30) DEFAULT NULL,
  `first_name` varchar(30) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `gender` char(1) DEFAULT NULL,
  `balance` decimal(10,0) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8

事务1：
start transaction;
update customer set balance = 100 where id = 1;
update customer set balance = 200 where id = 2;
commit;

事务2：
start transaction;
update customer set balance = 300 where id = 2;
update customer set balance = 400 where id = 1;
commit;
```

为了解决死锁问题，数据库实现了**各种死锁检测和死锁超时机制。越复杂的存储引擎，越能检测到死锁的循环依赖，并返回错误**，这是一种比较有效的办法。还有一种解决死锁的办法是：**当锁等待超时后，放弃锁请求**。

InnoDB 存储引擎可以自动检测事务的死锁，并回滚一个或几个事务来防止死锁。但是有些场景 InnoDB是无法检测到死锁的，比如在同一事务中使用 InnoDB 之外的存储引擎、lock tables 设定表锁定的语句，此时要通过设置 innodb_lock_wait_timeout 这个系统参数来解决。通过锁等待超时来解决死锁问题，通常不是好的办法，因为很有可能导致大量事务的锁等待。当发生锁等待超时，数据库会抛出如下报错信息：

```sql
ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
```

调整 innodb_lock_wait_timeout 的方法有两种

- 临时：在MySQL中直接用命令行执行

```sql
-- innodb_lock_wait_timeout的默认值为50秒
mysql> show variables like 'innodb_lock_wait_timeout';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| innodb_lock_wait_timeout | 50    |
+--------------------------+-------+
1 row in set (0.00 sec)

mysql> set innodb_lock_wait_timeout=51;
Query OK, 0 rows affected (0.00 sec)
```

- 永久：将以下两个参数添加至配置文件 my.cnf，并重启 MySQL：

```sql
innodb_lock_wait_timeout=50
```

我们在程序设计时，也要尽可能的减小死锁发生的概率。以下是针对 InnoDB 存储引擎减小死锁发生概率的一些建议：

- 类似业务模块，尽可能按照相同的访问顺序来访问，防止产生死锁；
- 同一个事务中，尽可能做到一次锁定需要的所有资源，减少死锁发生概率；
- 同一个事务中，不要使用不同存储引擎的表，比如 MyISAM 和 InnoDB 表出现在同一事务中；
- 尽可能控制事务的大小，减少锁定的资源量和锁定时间长度；
- 对于容易产生死锁的业务模块，尝试升级锁颗粒度，通过表级锁减少死锁发生概率。

# 事务日志

使用事务日志可以提高事务的安全性和效率：

- 修改表数据时，只需要在内存中进行修改，再持久化到磁盘上的事务日志，而不用每次都将修改的数据持久化到磁盘。事务日志持久化后，内存中所修改的数据可以慢慢再刷到磁盘，这种方式称为预写式日志，修改数据需要写两次磁盘；
- 效率快很多，因为事务日志采用追加方式，写日志的操作只是磁盘上一小块区域的顺序IO，不像随机IO需要在磁盘多个地方移动磁头；
- 万一数据库发生崩溃，可以通过已经持久化的事务日志，来自动恢复数据。

# 小结

本小节主要介绍了死锁和事务日志。需要重点关注的是，**死锁的基本概念、以及减小死锁发生概率的几种方法**。

