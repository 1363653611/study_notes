# MySQL 服务器级别的锁等待

使用锁来控制资源共享的应用系统，如何处理**锁的竞争问题**是个头疼事。MySQL 有两个级别的锁等待，服务器级别和存储引擎级别，本节重点介绍服务器级别的锁等待。

# 表锁

表锁可以是显式的，也可以是隐式的。

## 显式锁

通过 lock tables和unlock tables 可以控制显式锁。在 MySQL 会话中执行 lock tables 命令，在表customer上会获得一个显式锁。

```sql
mysql> lock tables customer read;
Query OK, 0 rows affected (0.00 sec)
```

在 MySQL 另一个会话中，对表 customer 执行 lock tables 命令，查询会挂起。

```sql
mysql> lock tables customer write;
```

在第一个会话中执行 show processlist 查看线程状态，可以看到线程 13239868 的状态为 Waiting for table metadata lock。在 MySQL 中，当一个线程持有该锁后，其他线程只能不断尝试获取。

```sql
mysql> show processlist\G
*************************** 1. row ***************************
     Id: 13239801
   User: root
   Host: localhost
     db: tempdb
Command: Query
   Time: 0
  State: starting
   Info: show processlist
*************************** 2. row ***************************
     Id: 13239868
   User: root
   Host: localhost
     db: tempdb
Command: Query
   Time: 12
  State: Waiting for table metadata lock
   Info: lock tables customer write
2 rows in set (0.00 sec)

```

## 隐式锁

除了显式锁会阻塞这样的操作，MySQL 在查询过程中也会隐式地锁住表。通过 sleep() 函数可以实现长时间的查询，然后 MySQL 会产生一个隐式锁。

在 MySQL 会话中执行 sleep(30)，在表 customer上 会获得一个隐式锁。

```sql
mysql> select sleep(30) from customer;
```

在 MySQL 另一个会话中，对表 customer 执行 lock tables 命令，查询会挂起。

```sql
mysql> lock tables customer write;
```

在第三个会话中执行 show processlist 查看线程状态，可以看到线程 13244135 的状态为 Waiting for table metadata lock。select 查询的隐式锁阻塞了 lock tables 中所请求的显式写锁。

```sql
mysql> show processlist\G
*************************** 1. row ***************************
     Id: 13244112
   User: root
   Host: localhost
     db: tempdb
Command: Query
   Time: 6
  State: User sleep
   Info: select sleep(30) from customer
*************************** 2. row ***************************
     Id: 13244135
   User: root
   Host: localhost
     db: tempdb
Command: Query
   Time: 2
  State: Waiting for table metadata lock
   Info: lock tables customer write
```

# 全局锁

MySQL 服务器可以支持全局读锁，可以通过 flush tables with read lock 或设置 read_only=1 来实现，全局锁与任何表锁都冲突。

在 MySQL会 话中执行 flush tables 命令，获得全局读锁。

```sql
mysql> flush tables with read lock;
Query OK, 0 rows affected (0.00 sec)
```

在 MySQL 另一个会话中，对表 customer 执行 lock tables 命令，查询会挂起。

```sql
mysql> lock tables customer write;
```

在第一个会话中执行 show processlist 查看线程状态，可以看到线程 13283816 的状态为 Waiting for global read lock。这是一个全局读锁，而不是表级别锁。

```sql
mysql> show processlist\G
*************************** 1. row ***************************
     Id: 13283789
   User: root
   Host: localhost
     db: tempdb
Command: Query
   Time: 0
  State: starting
   Info: show processlist
*************************** 2. row ***************************
     Id: 13283816
   User: root
   Host: localhost
     db: tempdb
Command: Query
   Time: 10
  State: Waiting for global read lock
   Info: lock tables customer write
2 rows in set (0.00 sec)
```

# 命名锁

命名锁是一种表级别锁，它是 MySQL 服务器在重命名或删除表时创建。命名锁与普通的表锁冲突，无论是显式的还是隐式的表锁。

在 MySQL会 话中执行 lock tables命令，在表 customer上 获得一个显式锁。

```sql
mysql> lock tables customer read;
Query OK, 0 rows affected (0.00 sec)
```

在 MySQL 另一个会话中，对表 customer 执行 rename table 命令，此时会话会挂起，会话状态为Waiting for table metadata lock：

```sql
mysql> rename table customer to customer_1;

mysql> show processlist\G
...
*************************** 2. row ***************************
     Id: 51
   User: root
   Host: localhost
     db: tempdb
Command: Query
   Time: 128
  State: Waiting for table metadata lock
   Info: rename table customer to customer_1
```

# 用户锁

MySQL 服务器还可以实现用户锁，这种锁需指定名称字符串，以及等待超时时间（单位秒）。

在 MySQL 会话中执行 get_lock 命令，成功执行并持有一把锁。

```sql
mysql> select get_lock('user_1',20);
+------------------------+
| get_lock('user_1',20) |
+------------------------+
|                      1 |
+------------------------+
1 row in set (0.00 sec)
```

在 MySQL 另一个会话中，也执行 get_lock 命令，尝试锁相同的字符串，此时会话会挂起，会话状态为User lock。

```sql
mysql> select get_lock('user_1',20);
+------------------------+
| get_lock('user_1',20) |
+------------------------+
|                      1 |
+------------------------+

mysql> show processlist\G
...
*************************** 2. row ***************************
     Id: 51
   User: root
   Host: localhost
     db: tempdb
Command: Query
   Time: 3
  State: User lock
   Info: select get_lock('user_1',20)
```

# 小结

服务器级别的锁等待：表锁、全局锁、命名锁、用户锁。

表锁可以是显式的，也可以是隐式的。显式锁通过 lock tables 和 unlock tables 进行控制，隐式锁在查询过程中产生。全局锁可以通过 flush tables with read lock 或设置 read_only=1 来 实现，它与任何表锁都冲突。