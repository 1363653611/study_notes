# 如何根据业务选择合适的存储引擎？

多存储引擎是 MySQL 有别于其他数据库的最大特点，不同的存储引擎有不同的特点，可以应对不同的应用场景，这给了我们足够的灵活性去做出选择。但同时也带来了烦恼，这么多的存储引擎，我们该如何选择最合适的呢？本文将结合实际应用，介绍选择存储引擎的一般原则。

## 1.需要考虑的因素

对于如何选择存储引擎，可以简单地归纳为一句话：“**除非需要用到某些 InnoDB 不具备的特性，并且没有其他办法可以替代，否则都应该优先选择 InnoDB 引擎**”（摘录自高性能MySQL第三版）。

确实，大部分情况下，InnoDB 都是最好的选择，从 MySQL 5.5 版本开始，将 InnoDB 作为默认存储引擎这一点就是最好的佐证。

选择不同的存储引擎，需要考虑以下几个因素：

- **事务**

如果应用场景需要事务支持，那么毫无疑问，InnoDB是目前最稳定的选择。如果不需要考虑事务，并且应用主要以读操作和插入操作为主，极少有更新和删除操作，那么MyISAM是比较好的选择，这种一般指日志型应用。

- **备份**

如果需要在线热备，那么应该考虑 InnoDB。如果可以定期关闭服务器进行冷备，那么备份这个因素可以忽略掉。

- **崩溃恢复**

MyISAM 在崩溃后，发生数据损坏的概率比 InnoDB 高很多，而且恢复速度也很慢，这也是很多人开始弃用 MyISAM 的主要原因之一。特别是数据量比较大的应用场景，数据库崩溃后，是否能快速恢复是一个非常重要的因素。

一般来讲，如果应用场景特别复杂，以至于搞不清楚需求，无法确定应该使用哪种存储引擎，那么就使用 InnoDB 吧，这是比较安全的选择。



## 2. 转换表的存储引擎

下面介绍转换存储引擎的三种方法：



### 2.1 alter table

下面语句将表 t1 的存储引擎修改为 InnoDB：

```sql
mysql> create table t1(
    ->     c1 int not null,
    ->     c2 varchar(10) default null
    -> ) engine = myisam;
Query OK, 0 rows affected (0.06 sec)

mysql> alter table t1 engine = innodb;
Query OK, 0 rows affected (0.07 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> show create table t1\G;
*************************** 1. row ***************************
       Table: t1
Create Table: CREATE TABLE `t1` (
  `c1` int(11) NOT NULL,
  `c2` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8
1 row in set (0.00 sec)
代码块123456789101112131415161718
```

alter table 的操作需要执行比较长的时间，它是将原表复制到一张新的表中，同时原表加上读锁，复制期间会耗费大量的 IO，所以一般在应用空闲时，才可进行 alter table 操作。



### 2.2 导出导入

使用 mysqldump 工具将数据导出至文件，修改文件中 create table 语句的存储引擎选项，同时修改表名，再通过 source 命令进行导入操作。

```sql
mysql> source table_new_engine.sql
```



### 2.3 create和select

这种方法先创建一个新的存储引擎表，再通过 insert xxx select xxx 语法导入数据

```sql
mysql> create table t1(
    ->          c1 int not null,
    ->          c2 varchar(10) default null
    ->      ) engine = myisam;
Query OK, 0 rows affected (0.02 sec)

mysql> create table t1_innodb like t1;
Query OK, 0 rows affected (0.01 sec)

mysql> alter table t1_innodb engine = innodb;
Query OK, 0 rows affected (0.06 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> insert into t1_innodb select * from t1;
Query OK, 0 rows affected (0.00 sec)

mysql> show create table t1_innodb\G;
*************************** 1. row ***************************
       Table: t1_innodb
Create Table: CREATE TABLE `t1_innodb` (
  `c1` int(11) NOT NULL,
  `c2` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8
1 row in set (0.00 sec)
```



## 3. 小结

本节主要学习了选择合适的存储引擎需要考虑的三个因素：事务、备份和崩溃恢复，同时还学习了转换存储引擎的三种方法：alter table、导出导入、create和select。

以一句话来总结如何选择合适的存储引擎：当你搞不清楚无法做出选择时，InnoDB 是最好的选择。