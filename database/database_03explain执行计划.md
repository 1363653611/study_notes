---
title: database_03_explain 执行计划
date: 2019-12-09 18:14:10
tags:
  - sql
categories:
  - sql
topdeclare: false
reward: true
---
### explain 执行计划

> 在日常工作中我们会遇到一些sql查询缓慢的的情况,这时,我们常常用到 `explain` 命令来查看这些命令的执行计划.查看sql 语句有没有使用索引,有没有全表扫描. 如果我们深入了解Mysql的基本开销优化器,还可以获得很多被优化器考虑到的优化策略的细节.以及当运行sql 时,那种策略预计会被sql 优化器使用.

### EXPLAIN 可以分析出的内容:
1. 表的读取顺序
2. 数据读取操作的类型
3. 那些索引可以使用
4. 那些索引被实际使用
5. 表之间的引用
6. 每张表有多少行被优化器查询
<!--more-->
### explain(计划)
> 主要是用来获取一个select 的执行计划.包括:查询操作,执行顺序,以及使用到的索引.以及返回结果集需要的执行的行数.
![执行计划](./imgs/explain1.jpg)

- 上图各列字段解释:
1. id:标识符,表示执行的顺序
2. selectType 查询类型
3. table where子查询内的表
4. partitions 使用的哪个分区,需要结合表分区才能看到(5.7 以后的版本)
5. type 查询类型: 如index 索引
6. possible_keys 可能用到的索引,如果是多个索引则用逗号隔开
7. key 实际用到的索引,保存的是索引的名称,如果是多个索引,则用逗号隔开
8. key_lens 使用索引的长度
9. ref 引用索引对应表中哪一行
10. rows mysql认为查询时,必须要返回的行数
11. filtered  通过过滤条件以后,对比总数的百分比
12. Extra 额外的信息,using file sort,using where

### ID
id表示select标识符，同时表明sql执行顺序，也就是说他是一个序列号.分为三种情况：
1. id相同 – 顺序执行:
  ![ID相同](./imgs/ID_01.png)
  对于以上三表关联查询，我们可以看到id列的值相同，都是1.在这种情况下，它们的执行顺序是按顺序执行，也是就是按列名从上往下执行。

2. id全不同 – 数字越大，越先执行
![id_02](./imgs/id_02.png)
  在这里我们可以看到在这个子查询中，ID完全不同。这对这种情况，mysql的执行机制就是数字越大，越先执行。因为要先获取到子查询里的信息做为条件，然后才能查询外面的信息。

3. id部分相同 – 先大的执行，小的顺序执行
![id_02](./imgs/id_03.png)
  对于这种id部分相同的情况，其实就是前面2种情况的综合。执行顺序是先按照数字大的先执行，然后 __数字相同的按照从上往下的顺序__ 执行。

### select_type – 查询类型
select_type包括以下几种类型：主要是用于区分普通查询、联合查询、子查询等复杂的查询
1. simple 简单查询(不包括联合(union)查询或者子查询)
2. primary 查询中包含任何子查询的复杂查询,最外层的被标记为 primary. 且只有一个
3. union union 连接两个select 查询,若第二个select出现在union之后，则被标记为union；若union包含在from子句的子查询中，外层select将被标记为derived
4. dependent union 与union一样，出现在union 或union all语句中，但是这个查询要受到外部查询的影响
5. union result (从union表获取结果的select)包含union的结果集，在union和union all语句中,因为它不需要参与查询，所以id字段为null
6. subquery (在select 或 where列表中包含了子查询)除了from字句中包含的子查询外，其他地方出现的子查询都可能是subquery
7. dependent subquery 与dependent union类似，表示这个subquery的查询要受到外部表查询的影响
8. derived from字句中出现的子查询，也叫做派生表，其他数据库中可能叫做内联视图或嵌套select(在from列表中包含的子查询被标记为derived（衍生），mysql或递归执行这些子查询，把结果放在零时表里)

#### primary/subquery
```sql
explain select * from student s where s. classid = (select id from classes where classno='2017001');
```
![执行结果](./imgs/primary_subquery.png)

#### union / union result
```sql
explain select * from student where id = 1 union select * from student where id = 2;
```
![union_unionResult](./imgs/union_unionResult.png)

#### dependent union/dependent subquery
```sql
explain select * from student s where s.classid in (select id from classes where classno='2017001'
union select id from classes where classno='2017002');
```
![dependent union/dependent subquery](./imgs/dependent_subQuery_dependentUnion.png)

#### derived
```sql
explain select * from (select * from student) s;
```
-  在mysql5.5、mysql5.6.x中：
![derived5.6](./imgs/derived5.6.png)
- 但是在5.7中显示会不一样：
![derived5.7](./imgs/derived5.7.png)

### table
显示的查询表名，如果查询使用了别名，那么这里显示的是别名，如果不涉及对数据表的操作，那么这显示为null，如果显示为尖括号括起来的<derived N>就表示这个是临时表，后边的N就是执行计划中的id，表示结果来自于这个查询产生。如果是尖括号括起来的<union M,N>，与<derived N>类似，也是一个临时表，表示这个结果来自于union查询的id为M,N的结果集。

### partitions – 分区
partitions这列是建立在你的表是分区表才行。
```sql
explain select * from test_partition where id > 7;
```
![partitions](./imgs/partitions.png)
- 在5.7之前默认不显示分区信息需要手动指明: `explain partitions select * from emp;`

### type 查询结果类型
sql查询优化中一个很重要的指标，结果值从好到坏依次是：

system > const > eq_ref > ref > fulltext > ref_or_null > index_merge > unique_subquery > index_subquery > range > index > ALL

一般来说，好的sql查询至少达到range级别，最好能达到ref

表示按照某种类型来查询，例如按照索引类型查找，按照范围查找，主要是以下几种类型：

1. system：表只有一行记录（等于系统表），这是const类型的特例，平时不会出现，可以忽略不计
2. const：表示通过索引一次就找到了，const用于比较primary key 或者 unique索引。因为只需匹配一行数据，所有很快。如果将主键置于where列表中，mysql就能将该查询转换为一个const
3. eq_ref：唯一性索引扫描，对于每个索引键，表中只有一条记录与之匹配。常见于主键 或 唯一索引扫描。
4. ref：非唯一性索引扫描，返回匹配某个单独值的所有行。本质是也是一种索引访问，它返回所有匹配某个单独值的行，然而他可能会找到多个符合条件的行，所以它应该属于查找和扫描的混合体
  - ref_or_null：类似于ref，但是可以搜索包含null值的行
  - index_merge：出现在使用一张表中的多个索引时，mysql会讲这多个索引合并到一起
5. range：只检索给定范围的行，使用一个索引来选择行。key列显示使用了那个索引。一般就是在where语句中出现了bettween、<、>、in等的查询。这种索引列上的范围扫描比全索引扫描要好。只需要开始于某个点，结束于另一个点，不用扫描全部索引
6. index：Full Index Scan，index与ALL区别为index类型只遍历索引树。这通常比ALL块，因为索引文件通常比数据文件小。（Index与ALL虽然都是读全表，但index是从索引中读取，而ALL是从硬盘读取）
7. ALL：Full Table Scan，遍历全表以找到匹配的行

#### const
使用唯一索引或者主键，返回记录一定是1行记录的等值where条件时，通常type是const。其他数据库也叫做唯一索引扫描
```sql
explain select * from student where id = 1;
```
![const](./imgs/const.png)

#### eq_ref(唯一性索引扫描)
对于每个来自于前面的表的记录，从该表中读取唯一一行。

出现在要连接多个表的查询计划中，驱动表只返回一行数据，且这行数据是第二个表的主键或者唯一索引，且必须为not null，唯一索引和主键是多列时，只有所有的列都用作比较时才会出现eq_ref。
```sql
explain select * from student s, student ss where s.id = ss.id;
```
![eq_ref](./imgs/eq_ref.png)

注意：
ALL全表扫描的表记录最少的表如t1表

#### ref（非唯一性索引扫描）
- 对于每个来自于前面的表的记录，所有匹配的行从这张表中取出  
- 返回匹配某个单独值的所有行。本质是也是一种索引访问，它返回所有匹配某个单独值的行，然而他可能会找到多个符合条件的行，所以它应该属于查找和扫描的混合体  
- 不像eq_ref那样要求连接顺序，也没有主键和唯一索引的要求，只要使用相等条件检索时就可能出现，常见与辅助索引的等值查找。或者多列主键、唯一索引中，使用第一个列之外的列作为等值查找也会出现，总之，返回数据不唯一的等值查找就可能出现。
```sql
explain select * from student s, student_detail sd where s.id = sd.id;
```
![ref](./imgs/ref.png)


#### ref_or_null

类似于ref，但是可以搜索包含null值的行，实际用的不多
```sql
explain select * from student_detail where address = 'xxx' or address is null;
```
![ref_or_null](./imgs/ref_or_null.png)

#### index_merge
- 出现在使用一张表中的多个索引时，mysql会讲这多个索引合并到一起.
- 表示查询使用了两个以上的索引，最后取交集或者并集，常见and ，or的条件使用了不同的索引，官方排序这个在ref_or_null之后，但是实际上由于要读取多个索引，性能可能大部分时间都不如range.
![index_merge](./imgs/index_merge.png)

#### range

- 索引范围扫描，常见于使用>,<,is null,between ,in ,like等运算符的查询中。
- 只检索给定范围的行，使用一个索引来选择行。key列显示使用了那个索引。一般就是在where语句中出现了bettween、<、>、in等的查询。这种索引列上的范围扫描比全索引扫描要好。只需要开始于某个点，结束于另一个点，不用扫描全部索引
![range](./imgs/range.png)

#### index
- 索引全表扫描，把索引从头到尾扫一遍，常见于使用索引列就可以处理不需要读取数据文件的查询、可以使用索引排序或者分组的查询。
- Full Index Scan，index与ALL区别为index类型只遍历索引树。这通常为ALL块，应为索引文件通常比数据文件小。（Index与ALL虽然都是读全表，但index是从索引中读取，而ALL是从硬盘读取）
![index](./imgs/index.png)

#### ALL
- Full Table Scan，遍历全表以找到匹配的行
- 这个就是全表扫描数据文件，然后再在server层进行过滤返回符合要求的记录。
![all](./imgs/all.png)

### possible_keys & key
- possible_keys 查询可能遇到的索引都会放在这里面

- key 查询时真正遇到的索引，select_type 为index_merge 时，这里可能会出现两个以上的索引。select_type 为其他时，只会出现一个索引。
![posssible_keys&key](./imgs/possible_keys_key.png)
注意：__查询中如果使用了覆盖索引，则该索引仅出现在key列表中__
### key_len
- 查询索引的长度，如果是单列索引，那就整个索引长度算进去，如果是多列索引，那么查询不一定都能使用到的所有列，具体用到了多少列的索引，这里就会计算进去，没有使用到的列，这里不会计算进去。

- key_len表示索引中使用的字节数，查询中使用的索引的长度（最大可能长度），并非实际使用长度，理论上长度越短越好。key_len是根据表定义计算而得的，不是通过表内检索出的.

- 留意下这个列的值，算一下你的多列索引总长度就知道有没有使用到所有的列了。要注意，mysql的ICP特性使用到的索引不会计入其中。另外，key_len只计算where条件用到的索引长度，而排序和分组就算用到了索引，也不会计算到key_len中。
![ley_len](./imgs/key_len.png)

__如果key字段值为null，则key_len字段值也为null,而且对于key_len越小越好，当然不能为null.__

### ref
如果使用了常量的等值查询，这里会显示const，如果是链接查询，被驱动表的执行计划这里会显示驱动表的关联字段。如果条件使用了表达式或者函数，或者条件列内部出现了隐式转换，这里可能显示为func。

### rows
这里是执行计划中估算的扫描行数，不是精确值

### extra
- 不适合在其他字段中显示，但是十分重要的额外信息：
  1. distinct：在select部分使用了distinc关键字
  2. no tables used：不带from字句的查询或者From dual查询
  3. 使用not in()形式子查询或not exists运算符的连接查询，这种叫做反连接。即，一般连接查询是先查询内表，再查询外表，反连接就是先查询外表，再查询内表。
  4. using filesort：排序时无法使用到索引时，就会出现这个。常见于order by和group by语句中
  5. using index：查询时不需要回表查询，直接通过索引就可以获取查询的数据。
  表示相应的select操作中使用了覆盖索引（Covering Index），避免了访问表的数据行，效率高  
  如果同时出现Using where，表明索引被用来执行索引键值的查找  
  如果没用同时出现Using where，表明索引用来读取数据而非执行查找动作  
  __覆盖索引（Covering Index）__：也叫索引覆盖。就是select列表中的字段，只用从索引中就能获取，不必根据索引再次读取数据文件，换句话说查询列要被所建的索引覆盖。  
  注意：
    a、如需使用覆盖索引，select列表中的字段只取出需要的列，不要使用select *  
    b、如果将所有字段都建索引会导致索引文件过大，反而降低crud性能
  6. using join buffer（block nested loop）(使用链接缓存)，using join buffer（batched key accss）：5.6.x之后的版本优化关联查询的BNL，BKA特性。主要是减少内表的循环数量以及比较顺序地扫描查询
  7. using sort_union，using_union，using intersect，using sort_intersection：
  8. using intersect：表示使用and的各个索引的条件时，该信息表示是从处理结果获取交集
  9. using union：表示使用or连接各个使用索引的条件时，该信息表示从处理结果获取并集
  10. using sort_union和using sort_intersection：与前面两个对应的类似，只是他们是出现在用and和or查询信息量大时，先查询主键，然后进行排序合并后，才能读取记录并返回。
  11. using temporary：表示使用了临时表存储中间结果。临时表可以是内存临时表和磁盘临时表，执行计划中看不出来，需要查看status变量，used_tmp_table，used_tmp_disk_table才能看出来
  12. using where：表示存储引擎返回的记录并不是所有的都满足查询条件，需要在server层进行过滤。查询条件中分为限制条件和检查条件，5.6之前，存储引擎只能根据限制条件扫描数据并返回，然后server层根据检查条件进行过滤再返回真正符合查询的数据。5.6.x之后支持ICP特性，可以把检查条件也下推到存储引擎层，不符合检查条件和限制条件的数据，直接不读取，这样就大大减少了存储引擎扫描的记录数量。extra列显示using index condition
  13. firstmatch(tb_name)：5.6.x开始引入的优化子查询的新特性之一，常见于where字句含有in()类型的子查询。如果内表的数据量比较大，就可能出现这个
  14. loosescan(m..n)：5.6.x之后引入的优化子查询的新特性之一，在in()类型的子查询中，子查询返回的可能有重复记录时，就可能出现这个

  除了这些之外，还有很多查询数据字典库，执行计划过程中就发现不可能存在结果的一些提示信息。

### 总结
 通过对上面explain中的每个字段的详细讲解。我们不难看出，对查询性能影响最大的几个列是：
 - select_type：查询类型
 - type：连接使用了何种类型
 - rows：查询数据需要查询的行
 - key：查询真正使用到的索引
 - extra：额外的信息

 尽量让自己的SQL用上索引，避免让extra里面出现file sort(文件排序),using temporary(使用临时表)。

### 参考
1. https://blog.csdn.net/u012410733/article/details/66472157
2. https://blog.csdn.net/wuseyukui/article/details/71512793
