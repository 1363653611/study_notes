# 如何高效高性能的选择使用 MySQL 索引？

## 独立的列

独立的列，是指索引列不能是表达式的一部分，也不能是函数的参数。如果 SQL 查询中的列不是独立的，MySQL 不能使用该索引。

下面两个查询，MySQL 无法使用 id 列和 birth_date 列的索引：

```sql
mysql> select * from customer where id + 1 = 2;
mysql> select * from customer where to_days(birth_date) - to_days('2020-06-07') <= 10;
```

## 前缀索引

有时候需要对很长的字符列创建索引，这会使得索引变得很占空间，效率也很低下。碰到这种情况，一般可以索引开始的部分字符，这样可以节省索引产生的空间，但同时也会降低索引的选择性。

那我们就要选择足够长的前缀来保证较高的选择性，但是为了节省空间，前缀又不能太长，只要前缀的基数，接近于完整列的基数即可。

**Tips**：索引的选择性指，不重复的索引值（也叫基数，cardinality）和数据表的记录总数的比值，索引的选择性越高表示查询效率越高。

完整列的选择性：

```sql
mysql> select count(distinct last_name)/count(*) from customer;
+------------------------------------+
| count(distinct last_name)/count(*) |
+------------------------------------+
|                              0.053 |
+------------------------------------+
```

不同前缀长度的选择性：

```sql
mysql> select count(distinct left(last_name,3))/count(*) left_3, count(distinct left(last_name,4))/count(*) left_4, count(distinct left(last_name,5))/count(*) left_5, count(distinct left(last_name,6))/count(*) left_6 from customer;
+--------+--------+--------+--------+
| left_3 | left_4 | left_5 | left_6 |
+--------+--------+--------+--------+
|   0.043|   0.046|   0.050|   0.051|
+--------+--------+--------+--------+
```

从上面的查询可以看出，当前缀长度为 6 时，前缀的选择性接近于完整列的选择性 0.053，再增加前缀长度，能够提升选择性的幅度也很小了。

创建前缀长度为6的索引：

```sql
mysql> alter table customer add index idx_last_name(last_name(6));
```

前缀索引可以使索引更小更快，但同时也有缺点：无法使用前缀索引做 order by 和 group by，也无法使用前缀索引做覆盖扫描。

## 合适的索引列顺序

在一个多列 B-Tree 索引中，索引列的顺序表示索引首先要按照最左列进行排序，然后是第二列、第三列等。索引可以按照升序或降序进行扫描，以满足精确符合列顺序的 order by、group by 和 distinct 等的查询需求。

索引的列顺序非常重要，在不考虑排序和分组的情况下，通常我们会将选择性最高的列放到索引最前面。

以下查询，是应该创建一个 `(last_name,first_name)` 的索引，还是应该创建一个`(first_name,last_name)` 的索引？

```sql
mysql> select * from customer where last_name = 'Allen' and first_name = 'Cuba'
```

我们首先来计算下这两个列的选择性，看哪个列更高。

```sql
mysql> select count(distinct last_name)/count(*) last_name_selectivity, count(distinct first_name)/count(*) first_name_selectivity from customer;
+-----------------------+------------------------+
| last_name_selectivity | first_name_selectivity |
+-----------------------+------------------------+
|                 0.053 |                  0.372 |
+-----------------------+------------------------+
```

很明显，列 first_name 的选择性更高，所以选择 first_name 作为索引列的第一列：

```sql
mysql> alter table customer add index idx1_customer(first_name,last_name);
```

## 覆盖索引

如果一个索引包含所有需要查询的字段，称之为覆盖索引。由于覆盖索引无须回表，通过扫描索引即可拿到所有的值，它能极大地提高查询效率：索引条目一般比数据行小的多，只通过扫描索引即可满足查询需求，MySQL 可以极大地减少数据的访问量。

表 customer 有一个多列索引 `(first_name,last_name)`，以下查询只需要访问 `first_name` 和`last_name`，这时就可以通过这个索引来实现覆盖索引。

```sql
mysql> explain select last_name, first_name from customer\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: customer
   partitions: NULL
         type: index
possible_keys: NULL
          key: idx1_customer
      key_len: 186
          ref: NULL
         rows: 1
     filtered: 100.00
        Extra: Using index
1 row in set, 1 warning (0.00 sec)
```

## 使用索引实现排序

MySQL 可以通过排序操作，或者按照索引顺序扫描来生成有序的结果。如果 explain 的 type 列的值为index，说明该查询使用了索引扫描来做排序。

order by 和查询的限制是一样的，需要满足索引的最左前缀要求，否则无法使用索引进行排序。只有当索引的列顺序和 order by 子句的顺序完全一致，并且所有列的排序方向（正序或倒序)都一致，MySQL才能使用索引来做排序。如果查询是多表关联，只有当 order by 子句引用的字段全部为第一个表时，才能使用索引来做排序。

以表 customer 为例，我们来看看哪些查询可以通过索引进行排序。

```sql
mysql> create table customer(
		 id int,
         last_name varchar(30),
		 first_name varchar(30),
		 birth_date date,
		 gender char(1),
		 key idx_customer(last_name,first_name,birth_date)
     );
```

### 以通过索引进行排序的查询

索引的列顺序和 order by 子句的顺序完全一致：

```sql
mysql> explain select last_name,first_name from customer order by last_name, first_name, birth_date\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: customer
   partitions: NULL
         type: index
possible_keys: NULL
          key: idx_customer
      key_len: 190
          ref: NULL
         rows: 1
     filtered: 100.00
        Extra: Using index
1 row in set, 1 warning (0.00 sec)
```

索引的第一列指定为常量：

从 explain 可以看到没有出现排序操作（filesort）：

```sql
mysql> explain select * from customer where last_name = 'Allen' order by first_name, birth_date\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: customer
   partitions: NULL
         type: ref
possible_keys: idx_customer
          key: idx_customer
      key_len: 93
          ref: const
         rows: 1
     filtered: 100.00
        Extra: Using index condition
1 row in set, 1 warning (0.00 sec)

```

索引的第一列指定为常量，使用第二列排序：

```sql
mysql> explain select * from customer where last_name = 'Allen' order by first_name desc\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: customer
   partitions: NULL
         type: ref
possible_keys: idx_customer
          key: idx_customer
      key_len: 93
          ref: const
         rows: 1
     filtered: 100.00
        Extra: Using where
1 row in set, 1 warning (0.00 sec)
```

索引的第一列为范围查询，order by 使用的两列为索引的最左前缀：

```sql
mysql> explain select * from customer where last_name between 'Allen' and 'Bush' order by last_name,first_name\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: customer
   partitions: NULL
         type: range
possible_keys: idx_customer
          key: idx_customer
      key_len: 93
          ref: NULL
         rows: 1
     filtered: 100.00
        Extra: Using index condition
1 row in set, 1 warning (0.00 sec)
```

## 不能通过索引进行排序的查询

使用两种不同的排序方向：

```sql
mysql> explain select * from customer where last_name = 'Allen' order by first_name desc, birth_date asc\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: customer
   partitions: NULL
         type: ref
possible_keys: idx_customer
          key: idx_customer
      key_len: 93
          ref: const
         rows: 1
     filtered: 100.00
        Extra: Using index condition; Using filesort
1 row in set, 1 warning (0.00 sec)
```

order by 子句引用了一个不在索引的列：

```sql
mysql> explain select * from customer where last_name = 'Allen' order by first_name, gender\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: customer
   partitions: NULL
         type: ref
possible_keys: idx_customer
          key: idx_customer
      key_len: 93
          ref: const
         rows: 1
     filtered: 100.00
        Extra: Using index condition; Using filesort
1 row in set, 1 warning (0.00 sec)
```

where 条件和 order by 的列无法组成索引的最左前缀：

```sql
mysql> explain select * from customer where last_name = 'Allen' order by birth_date\G
```

第一列是范围查询，where 条件和 order by 的列无法组成索引的最左前缀：

```sql
mysql> explain select * from customer where last_name between 'Allen' and 'Bush' order by first_name\G
```

第一列是常量，第二列是范围查询（多个等于也是范围查询）：

```sql
mysql> explain select * from customer where last_name = 'Allen' and first_name in ('Cuba','Kim') order by birth_date\G
```

# 小结

独立的列、前缀索引、合适的索引列顺序、覆盖索引、使用索引实现排序。应该使用哪个索引，以及评估选择不同索引的性能影响。