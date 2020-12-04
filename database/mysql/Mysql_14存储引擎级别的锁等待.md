# InnoDB 存储引擎中的锁等待

一般来说，存储引擎级别的锁，比服务器级别的锁更难以调试，而且各种存储引擎的锁互不相同，有些存储引擎甚至都不提供任何方法来查看锁。本节重点介绍 InnoDB 存储引擎的锁等待。

# show engine innodb status

show engine innodb status 命令包含了 InnoDB 存储引擎的部分锁信息，但很难确定哪个事务导致这个锁的问题，因为 show engine innodb status 命令不会告诉你谁拥有锁。

如果事务正在等待某个锁，相关锁信息会体现在 show engine innodb status 输出的 TRANSACTION 部分中。在 MySQL 会话中执行如下命令，拿到表 customer 中第一行的写锁。

```sql
mysql> set autocommit=0;
Query OK, 0 rows affected (0.00 sec)

mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from customer limit 1 for update;
+------+-----------+------------+------------+--------+
| id   | last_name | first_name | birth_date | gender |
+------+-----------+------------+------------+--------+
| NULL | 111       | 222        | NULL       | 1      |
+------+-----------+------------+------------+--------+
1 row in set (0.00 sec)
```

在 MySQL 另一个会话中，对表 customer 执行相同的 select 命令，查询会被阻塞。

```sql
mysql> select * from customer limit 1 for update;
```

这时执行 show engine innodb status 命令能够看到相关的锁信息。

```sql
1 ---TRANSACTION 124178, ACTIVE 6 sec starting index read
2 mysql tables in use 1, locked 1
3 LOCK WAIT 2 lock struct(s), heap size 1136, 1 row lock(s)
4 MySQL thread id 12570, OS thread handle 139642200024832, query id 48195 localhost root Sending data
5 select * from customer limit 1 for update
6 ------- TRX HAS BEEN WAITING 6 SEC FOR THIS LOCK TO BE GRANTED:
7 RECORD LOCKS space id 829 page no 3 n bits 72 index GEN_CLUST_INDEX of table `tempdb`.`customer` trx id 124178 lock_mode X locks rec but not gap waiting
```

第 7 行表示 thread id 12570 这个查询，在等待表 customer 中的 GEN_CLUST_INDEX 索引的第 3 页上有一个排它锁（lock_mode X）。最后，锁等待超时，查询返回错误信息。

```sql
ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
```

##  imformation_schema

在 MySQL5.5 开始，一般通过 imformation_schema 的表来查询相关的事务和锁信息，通过imformation_schema 要比 show engine innodb status 命令要高效和全面。

在 MySQL 会话中执行如下命令，能看到谁阻塞和谁在等待，以及等待多久的查询。

```sql
mysql> SELECT
     IFNULL(wt.trx_mysql_thread_id, 1) BLOCKING_THREAD_ID,t.trx_mysql_thread_id WAITING_THREAD_ID, CONCAT(p. USER, '@', p. HOST) USER,
     p.info SQL_TEXT, l.lock_table LOCK_TABLE, l.lock_index LOCKED_INDEX, l.lock_type LOCK_TYPE, l.lock_mode LOCK_MODE,
     CONCAT(FLOOR(HOUR (TIMEDIFF(now(), t.trx_wait_started)) / 24),'day ',MOD (HOUR (TIMEDIFF(now(), t.trx_wait_started)),24),':',
     MINUTE (TIMEDIFF(now(), t.trx_wait_started)),':',SECOND (TIMEDIFF(now(), t.trx_wait_started))) AS WAIT_TIME,
     t.trx_started TRX_STARTED, t.trx_isolation_level TRX_ISOLATION_LEVEL, t.trx_rows_locked TRX_ROWS_LOCKED, t.trx_rows_modified TRX_ROWS_MODIFIED
     FROM INFORMATION_SCHEMA.INNODB_TRX t
     LEFT JOIN information_schema.innodb_lock_waits w ON t.trx_id = w.requesting_trx_id
     LEFT JOIN information_schema.innodb_trx wt ON wt.trx_id = w.blocking_trx_id
     INNER JOIN information_schema.innodb_locks l ON l.lock_trx_id = t.trx_id
     INNER JOIN information_schema. PROCESSLIST p ON t.trx_mysql_thread_id = p.id
     ORDER BY 1\G
*************************** 1. row ***************************
 BLOCKING_THREAD_ID: 1
  WAITING_THREAD_ID: 62751
               USER: root@localhost
           SQL_TEXT: NULL
         LOCK_TABLE: `tempdb`.`customer`
       LOCKED_INDEX: GEN_CLUST_INDEX
          LOCK_TYPE: RECORD
          LOCK_MODE: X
          WAIT_TIME: NULL
        TRX_STARTED: 2020-06-22 06:52:14
TRX_ISOLATION_LEVEL: READ COMMITTED
    TRX_ROWS_LOCKED: 1
  TRX_ROWS_MODIFIED: 0
*************************** 2. row ***************************
 BLOCKING_THREAD_ID: 62751
  WAITING_THREAD_ID: 62483
               USER: root@localhost
           SQL_TEXT: select * from customer limit 1 for update
         LOCK_TABLE: `tempdb`.`customer`
       LOCKED_INDEX: GEN_CLUST_INDEX
          LOCK_TYPE: RECORD
          LOCK_MODE: X
          WAIT_TIME: 0day 0:0:5
        TRX_STARTED: 2020-06-22 07:01:49
TRX_ISOLATION_LEVEL: READ COMMITTED
    TRX_ROWS_LOCKED: 1
  TRX_ROWS_MODIFIED: 0
2 rows in set, 2 warnings (0.00 sec)

```

从结果显示线程 62483 等待表 customer 中的锁已经 5s，它被线程 62751 所阻塞。

下面这个查询可以告诉你有多少查询被哪些线程锁阻塞。

```sql
mysql> select concat('thread ', b.trx_mysql_thread_id, ' from ', p.host) as who_blocks,
       if(p.command = "Sleep", p.time, 0) as idle_in_trx, 
       max(timestampdiff(second, r.trx_wait_started, now())) as max_wait_time, 
       count(*) as num_waiters
     from information_schema.innodb_lock_waits as w
     inner join information_schema.innodb_trx as b on b.trx_id = w.blocking_trx_id
     inner join information_schema.innodb_trx as r on r.trx_id = w.requesting_trx_id
     left join information_schema.processlist as p on p.id = b.trx_mysql_thread_id
     group by who_blocks order by num_waiters desc\G
*************************** 1. row ***************************
   who_blocks: thread 62751 from localhost
  idle_in_trx: 1206
max_wait_time: 20
  num_waiters: 5
1 row in set, 1 warning (0.00 sec)
```

从结果显示线程 62751 已经空闲了一段时间，有 5 个线程在等待线程 62751 完成提交并释放锁，有一个线程已经等待线程 62751 释放锁长达 20s。

# 小结

存储引擎级别的锁：show engine innodb status 和 imformation_schema。

show engine innodb status 仅包含了 InnoDB 存储引擎的部分锁信息，但不会告诉你谁拥有锁。通过imformation_schema 可以高效和全面定位到谁阻塞和谁在等待，以及等待多久的查询。