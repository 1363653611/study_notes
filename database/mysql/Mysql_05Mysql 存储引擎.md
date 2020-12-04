# MySQL 存储引擎概述

MySQL 的存储引擎是插件式的，用户可以根据实际的应用场景，选择最佳的存储引擎。MySQL默认支持多种存储引擎，以适应不同的应用需求。

MySQL 5.7 支持的存储引擎有：InnoDB、MyISAM、MEMORY、CSV、MERGE、FEDERATED 等。从 5.5.5 版本开始，InnoDB 成为 MySQL 的默认存储引擎，也是当前最常用的存储引擎，5.5.5 版本之前，默认引擎为 MyISAM。创建新表时，如果不指定存储引擎，MySQL 会使用默认存储引擎。

## 查看数据库当前的默认引擎：

```sql
show variables like 'default_storage_engine';
```

```shell
+------------------------+--------+
| Variable_name          | Value  |
+------------------------+--------+
| default_storage_engine | InnoDB |
+------------------------+--------+
1 row in set (0.00 sec)
```

## 查看数据库当前所支持的存储引擎

```sql
show engines
```

```shell
mysql> show engines\G
*************************** 1. row ***************************
      Engine: MEMORY
     Support: YES
     Comment: Hash based, stored in memory, useful for temporary tables
Transactions: NO
          XA: NO
  Savepoints: NO
*************************** 2. row ***************************
      Engine: CSV
     Support: YES
     Comment: CSV storage engine
Transactions: NO
          XA: NO
  Savepoints: NO
*************************** 3. row ***************************
      Engine: MRG_MYISAM
     Support: YES
     Comment: Collection of identical MyISAM tables
Transactions: NO
          XA: NO
  Savepoints: NO
*************************** 4. row ***************************
      Engine: BLACKHOLE
     Support: YES
     Comment: /dev/null storage engine (anything you write to it disappears)
Transactions: NO
          XA: NO
  Savepoints: NO
*************************** 5. row ***************************
      Engine: InnoDB
     Support: DEFAULT
     Comment: Supports transactions, row-level locking, and foreign keys
Transactions: YES
          XA: YES
  Savepoints: YES
*************************** 6. row ***************************
      Engine: PERFORMANCE_SCHEMA
     Support: YES
     Comment: Performance Schema
Transactions: NO
          XA: NO
  Savepoints: NO
*************************** 7. row ***************************
      Engine: ARCHIVE
     Support: YES
     Comment: Archive storage engine
Transactions: NO
          XA: NO
  Savepoints: NO
*************************** 8. row ***************************
      Engine: MyISAM
     Support: YES
     Comment: MyISAM storage engine
Transactions: NO
          XA: NO
  Savepoints: NO
*************************** 9. row ***************************
      Engine: FEDERATED
     Support: NO
     Comment: Federated MySQL storage engine
Transactions: NULL
          XA: NULL
  Savepoints: NULL
9 rows in set (0.00 sec)
```

每一行的含义大致如下：

- **Engine**：存储引擎名称；

- Support

  ：不同值的含义为：

  - **DEFAULT**：表示支持并启用，为默认引擎；
  - **YES**：表示支持并启用；
  - **NO**：表示不支持；
  - **DISABLED**：表示支持，但是被数据库禁用。

- **Comment**：存储引擎注释；

- **Transactions**：是否支持事务；

- **XA**：是否支持XA分布式事务；

- **Savepoints**：是否支持保存点。

## 创建表时，ENGINE 关键字表示表的存储引擎

```sql
mysql> create table a (id int) ENGINE = InnoDB;
Query OK, 0 rows affected (0.01 sec)

mysql> create table b (id int) ENGINE = MyISAM;
Query OK, 0 rows affected (0.01 sec)
```

## 查看表的相关信息

```sql
mysql> show table status like 'a'\G
*************************** 1. row ***************************
           Name: a
         Engine: InnoDB
        Version: 10
     Row_format: Dynamic
           Rows: 1
 Avg_row_length: 16384
    Data_length: 16384
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: NULL
    Create_time: 2020-04-21 02:29:06
    Update_time: 2020-04-29 00:24:17
     Check_time: NULL
      Collation: utf8_general_ci
       Checksum: NULL
 Create_options: 
        Comment: 
1 row in set (0.00 sec)

```

每一行的含义大致如下：

- **Name**：表名；
- **Engine**：表的存储引擎类型；
- **Version**：版本号；
- **Row_format**：行的格式
- **Rows**：表中的行数；
- **Avg_row_length**：平均每行包含的字节数；
- **Data_length**：表数据的大小（单位字节）；
- **Max_data_length**：表数据的最大容量；
- **Index_length**：索引的大小（单位字节）；
- **Data_free**：已分配但目前没有使用的空间，可以理解为碎片空间（单位字节）；
- **Auto_increment**：下一个 Auto_increment 值；
- **Create_time**：表的创建时间；
- **Update_time**：表数据的最后修改时间；
- **Check_time**：使用check table命令，最后一次检查表的时间；
- **Collation**：表的默认字符集和字符列排序规则；
- **Checksum**：如果启用，保存的是整个表的实时校验和；
- **Create_options**：创建表时指定的其他选项；
- **Comment**：表的一些额外信息。