##  MyISAM

在 MySQL 5.5 之前的版本，MyISAM 是默认的存储引擎。MyISAM 提供了全文索引、压缩、空间函数（GIS）等特性，但 MyISAM 不支持事务和行级锁，而且 MyISAM 没有 crash-safe 的能力。MySQL 5.6之后，MyISAM已经越来越少被使用。

> **Tips：** crash-safe 指数据库发生故障重启，之前提交的数据不会丢失。



### 1.1 MyISAM特性

- **加锁与并发**

MyISAM 可以对整张表加锁，而不是针对行。读数时会对表加共享锁，写入时对表加排它锁。在表有读取查询的同时，也可以对表进行插入数据。

- **延迟更新索引键**

创建 MyISAM 表时，可以指定 DELAY_KEY_WRITE 选项，在每次更新完成时，不会马上将更新的索引数据写入磁盘，而是先写到内存中的键缓冲区，当清理键缓冲区或关闭表的时候，才将对应的索引块写入磁盘。这种方式可以极大地提升写入性能。

- **压缩**

可以使用 myisampack 工具对 MyISAM 表进行压缩。压缩表可以极大地减少磁盘空间使用，从而减少磁盘 IO，提升查询性能。压缩表时不能进行数据的修改。表中的记录是独立压缩的，读取单行时，不需要解压整个表。

一般来说，如果数据在插入之后，不再进行修改，这种表比较适合进行压缩，如日志记录表、流水记录表。

- **修复**

针对 MyISAM 表，MySQL 可以手工或自动执行检查和修复操作。执行表的修复可能会导致丢失一些数据，而且整个过程非常缓慢。

可以通过check table xxx检查表的错误，如果有错误，则通过repair table xxx进行修复。在 MySQL 服务器关闭的情况下，也可以通过 myisamchk 命令行工具进行检查和修复操作。

```sql
mysql> create table t1(
    ->     c1 int not null,
    ->     c2 varchar(10) default null
    -> ) engine = myisam;
Query OK, 0 rows affected (0.06 sec)

mysql> check table t1;
+-----------+-------+----------+----------+
| Table     | Op    | Msg_type | Msg_text |
+-----------+-------+----------+----------+
| tempdb.t1 | check | status   | OK       |
+-----------+-------+----------+----------+
1 row in set (0.00 sec)

mysql> repair table t1;
+-----------+--------+----------+----------+
| Table     | Op     | Msg_type | Msg_text |
+-----------+--------+----------+----------+
| tempdb.t1 | repair | status   | OK       |
+-----------+--------+----------+----------+
1 row in set (0.00 sec)
代码块123456789101112131415161718192021
```



### 1.2 存储方式

MyISAM 在磁盘中存储成 3 个文件，文件名和表名相同

- **.frm**-存储表定义 ；
- **.MYD**-存储数据；
- **.MYI**-存储索引。

下面为 MyISAM 表的创建语句，及相应的数据文件：

```
mysql> create table a (id int) ENGINE = MyISAM;
Query OK, 0 rows affected (0.01 sec)

[root@mysql-test-1 tempdb]# ls -lrt a.*
-rw-r----- 1 mysql mysql 8556 Apr 13 02:01 a.frm
-rw-r----- 1 mysql mysql 1024 Apr 13 02:01 a.MYI
-rw-r----- 1 mysql mysql    0 Apr 13 02:01 a.MYD
代码块1234567
```



## 2. Memory

Memory 使用内存中的内容来创建表，每个 Memory 表只有一个 .frm 文件。如果需要快速访问数据，并且数据不会被修改，丢失也没有关系，使用 Memory 是非常适合的。而且 Memory 表支持 Hash 索引，查找操作非常快。

即便如此，Memory 表也无法取代基于磁盘的表

- Memory 表是表级锁，并发写的性能较差；
- 不支持BLOB或TEXT类型的列，并且每行的长度是固定的，即使指定了varchar列，实际存储也会使用char列。

一般来说，Memory 表比较适合以下场景：

- 用于查找或映射表，如邮编、省市区等变化不频繁的表；
- 用于缓存周期性聚合数据的表；
- 用于统计操作的中间结果表。



## 3. TokuDB

除了 MySQL 自带的存储引擎之外，还有一些常见的第三方存储引擎，如列式存储引擎 Infobright、高写性能和高压缩的 TokuDB。TokuDB 是一个高效写入、高压缩率、高扩展性、支持事务处理的存储引擎，最新的版本可以在 Percona Server for MySQL 中使用。

下图是官方给出的 TokuDB 与 InnoDB 的对比：
![图片描述](http://img.mukewang.com/wiki/5eb04bab098532da06330633.jpg)

官方给出的 TokuDB 与 InnoDB 的对比

一般来说，TokuDB比较适用以下场景：

- 访问频率不高的数据或历史数据归档；
- 数据表非常大并且时不时还需要进行DDL操作。



## 4. 小结

本节主要学习了 MyISAM、Memory、TokuDB 这三种存储引擎。本节课程的重点如下：

- MyISAM 的特性主要包括：加锁与并发、延迟更新索引键、压缩和修复等；
- Memory 查找数据的效率非常高，但是写的性能很差；
- TokuDB 属于第三方存储引擎，拥有高写性能和高压缩的特性。