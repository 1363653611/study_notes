# MySQL 中的事务控制机制

# 自动提交

默认情况下，MySQL 是自动提交（autocommit）的。也就意味着：**如果不是显式地开始一个事务，每个查询都会被当做一个事务执行 commit**。这是和 Oracle 的事务管理明显不同的地方，如果应用是从Oracle 数据库迁移至 MySQL 数据库，则需要确保**应用中是否对事务进行了明确的管理**。

在当前连接中，可以通过设置 autocommit 来修改自动提交模式：

```sql
mysql> show variables like 'autocommit';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| autocommit    | ON    |
+---------------+-------+
1 row in set (0.00 sec)

mysql> set autocommit = 1;
Query OK, 0 rows affected (0.00 sec)
-- 1或ON表示启用自动提交模式，0或OFF表示禁用自动提交模式

```

如果设置了autocommit=0，当前连接所有事务都需要通过明确的命令来提交或回滚。

对于 MyISAM 这种非事务型的表，修改 autocommit 不会有任何影响，因为非事务型的表，没有 commit或 rollback 的概念，它会一直处于 autocommit 启用的状态。

有些命令，在执行之前会强制执行 commit 提交当前连接的事务。比如 DDL 中的 alter table，以及lock tables 等语句。

# 隔离级别调整

默认情况下，MySQL 的隔离级别是可重复读（repeatable read）。MySQL 可以通过 set transaction_isolation 命令来调整隔离级别，新的隔离级别会在下一个事务开始时生效。

调整隔离级别的方法有两种：

- 临时：在 MySQL 中直接用命令行执行：

```sql
mysql> show variables like 'transaction_isolation';
+-----------------------+-----------------+
| Variable_name         | Value           |
+-----------------------+-----------------+
| transaction_isolation | REPEATABLE-READ |
+-----------------------+-----------------+
1 row in set (0.00 sec)

mysql> SET transaction_isolation = 'REPEATABLE-READ';
Query OK, 0 rows affected (0.00 sec)
```

永久：将以下两个参数添加至配置文件 my.cnf，并重启 MySQL：

```sql
transaction_isolation = 'REPEATABLE-READ'
```

# 事务中使用不同的存储引擎

MySQL 的服务层并不负责事务的处理，事务都是由存储引擎层实现。

在同一事务中，使用多种存储引擎是不可靠的，尤其在事务中混合使用了事务型和非事务型的表。如同一事务中，使用了 InnoDB 和 MyISAM 表：

- 如果事务正常提交，不会有什么问题；
- 如果事务遇到异常需要回滚，非事务型的表就无法撤销表更，这就会直接导致数据处于不一致的状态。

# 小结

本小节主要介绍了 MySQL 中事务控制的一些特点，如何调整自动提交（autocommit）、如何调整隔离级别调整、以及讲解了在事务中使用混合存储引擎的缺点。

