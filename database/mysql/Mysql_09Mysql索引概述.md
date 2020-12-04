# 索引概念

索引在 MySQL 中也叫“键（Key）”，是存储引擎用于快速查找记录的一种数据结构，这也是索引的基本功能。

MySQL 索引的工作原理，类似一本书的目录，如果要在一本书中找到特定的知识点，先通过目录找到对应的页码。在 MySQL 中，存储引擎用类似的方法使用索引，先在索引找到对应值，再根据索引记录找到对应的数据行。简单总结，索引就是为了提高数据查询的效率，跟一本书的目录一样。

以下查询假设字段 `c2` 上建有索引，则存储引擎将通过索引找到 `c2` 等于 `测试01` 的行。也就是说，存储引擎先在索引按值进行查找，再返回所有包含该值的数据行。

```sql
mysql> select * from t1 where c2='测试01'\G
*************************** 1. row ***************************
c1: 1
c2: 测试01
1 row in set (0.00 sec)
```

从执行计划的角度，也可以看出索引 `idx_c2` 被使用：

```sql
mysql> create table t1(
    ->     c1 int not null auto_increment,
    ->     c2 varchar(10) default null,
    ->     primary key(c1)
    -> ) engine = innodb;
Query OK, 0 rows affected (0.05 sec)

mysql> insert into t1() values(1,'测试01');
Query OK, 1 row affected (0.00 sec)

mysql> create index idx_c2 on t1(c2);
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> explain select * from t1 where c2='测试01'\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: t1
   partitions: NULL
         type: ref
possible_keys: idx_c2
          key: idx_c2
      key_len: 33
          ref: const
         rows: 1
     filtered: 100.00
        Extra: Using index
1 row in set, 1 warning (0.00 sec)

```

常见的索引类型主要有 B-Tree 索引、哈希索引、空间数据索引（R-Tree）、全文索引，在后续小节将详细介绍。

- InnoDB 和 MyISAM 存储引擎可以创建 B-Tree 索引，单列或多列都可以创建索引；
- Memory 存储引擎可以创建哈希索引，同时也支持 B-Tree 索引；
- 从 MySQL5.7 开始，InnoDB 和 MyISAM 存储引擎都可以支持空间类型索引；
- InnoDB 和 MyISAM 存储可以支持全文索引（FULLTEXT），该索引可以用于全文搜索，仅限于CHAR、VARCHAR、TEXT 列。

## 索引优点

索引最大的作用是快速查找数据，除此之外，索引还有其他的附加作用。

- B-Tree 是最常见的索引，按照顺序存储数据，它可以用来做 `order by` 和 `group by` 操作。
- 因为 B-Tree 是有序的，将相关的值都存储在一起。因为索引存储了实际的列值，某些查询仅通过索引就可以完成查询，如覆盖查询。

总的来说，索引三个优点如下：

- 索引可以大大减少 MySQL 需要扫描的数据量；
- 索引可以帮助 MySQL 避免排序和临时表；
- 索引可以将随机 IO 变为顺序 IO。

但是，索引是最好的解决方案吗？任何事物都是有两面性的，索引同样如此。索引并不总是最好的优化工具

- 对于非常小的表，大多数情况，全表扫描会更高效；
- 对于中大型表，索引就非常有效；
- 对于特大型表，建索引和用索引的代价是日益增长，这时候可能需要和其他技术结合起来，如分区表。

总的来说，只有当使用索引利大于弊时，索引才是最好的优化工具。

# 小结

索引就是为了提高数据查询的效率，跟一本书的目录一样。同时我们也要认识到，索引很好，但并不总是最好的解决方案，索引也会带来一些负面效果。

