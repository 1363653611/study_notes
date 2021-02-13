---
title: 01 mysql 基本命令
date: 2019-12-09 18:14:10
tags:
  - redis
categories:
  - redis
topdeclare: true
reward: true
---
1. 启动命令：`redis-server.exe redis.windows.conf`
2. 建立链接`：redis-cli.exe -h 127.0.0.1 -p 6379`  （这时候另启一个 cmd 窗口，原来的不要关闭，不然就无法访问服务端了。）

<!--more-->

# redis 支持数据类型 #
* Strings(字符串)
  - character：
   1. Redis 字符串是二进制安全的，也就是说，一个 Redis 字符串可以包含任意类型的数据，例如一张 JPEG 图像，或者一个序列化的 Ruby 对象。
   2. 一个字符串最大为 512M 字节。
  - 使用：
    > 1. 使用 `INCR` 命令族 (`INCR`，`DECR`，`INCRBY`)，将字符串作为原子计数器。
    > 2. 使用 `APPEND `命令追加字符串。
    > 3. 使用 `GETRANGE `和 `SETRANGE `命令，使字符串作为随机访问向量 (vectors)。
    > 4.  编码大量数据到很小的空间，或者使用 `GETBIT `和 `SETBIT `命令，创建一个基于 Redis 的布隆 (Bloom) 过滤器。

* Lists(列表)
  - Redis 列表仅仅是按照插入顺序排序的字符串列表。
  - `LPUSH `命令用于插入一个元素到列表的头部，`RPUSH `命令用于插入一个元素到列表的尾部。
  - 列表的最大长度是 2^23-1 个元素 (4294967295，超过 40 亿个元素)。
  - 使用：
   > 1.为社交网络时间轴 (timeline) 建模，使用 `LPUSH `命令往用户时间轴插入元素，使用 `LRANGE `命令获得最近事项。
    > 2.使用 `LPUSH `和 `LTRIM `命令创建一个不会超出给定数量元素的列表，只存储最近的 N 个元素。
    > 3.列表可以用作消息传递原语，例如，众所周知的用于创建后台任务的 Ruby 库 Resque。
    > 4.你可以用列表做更多的事情，这种数据类型支持很多的命令，包括阻塞命令，如 BLPOP。

* Sets(无需集合)
    - Redis 集合是没有顺序的字符串集合 (collection)。可以在 O(1) 的时间复杂度添加、删除和测试元素存在与否 (不管集合中有多少元素都是常量时间)。
    - Redis 集合具有你需要的不允许重复成员的性质。
    - 支持很多服务器端的命令，可以在很短的时间内和已经存在的集合一起计算并集，交集和差集。
    - 使用
        > 1.你可以使用 Redis 集合追踪唯一性的事情。你想知道访问某篇博客文章的所有唯一 IP 吗？只要 每次页面访问时使用 SADD 命令就可以了。你可以放心，重复的 IP 是不会被插入进来的。

        > 2.Redis 集合可以表示关系。你可以通过使用集合来表示每个标签，来创建一个标签系统。然后你可以把所有拥有此标签的对象的 ID 通过 SADD 命令，加入到表示这个标签的集合中。你想获得同时拥有三个不同标签的对象的全部 ID 吗？用 SINTER 就可以了。

        > 3.你可以使用 SPOP 或 SRANDMEMBER 命令来从集合中随机抽取元素。

* Hashes(哈希/散列)
 - Redis 哈希是字符串字段 (field) 与字符串值之间的映射，所以是表示对象的理想数据类型 (例如：一个用户对象有多个字段，像用户名，姓氏，年龄等等)：
    ```shell
        @cli  
        HMSET user:1000 username antirez password P1pp0 age 34  
        HGETALL user:1000  
        HSET user:1000 password 12345  
        HGETALL user:1000

    ```
    - 拥有少量字段 (少量指的是大约 100) 的哈希会以占用很少存储空间的方式存储，所以你可以在一个很小的 Redis 实例里存储数百万的对象。
    - 由于哈希主要用来表示对象，对象能存储很多元素，所以你可以用哈希来做很多其他的事情
    - 每个哈希可以存储多达 2^23-1 个字段值对 (field-value pair)(多于 40 亿个)。
* Sorted sets (有序集合)
  - Redis 有序集合和 Redis 集合类似，是非重复字符串集合 (collection)。不同的是，每一个有序集合的成员都有一个关联的分数 (score)，用于按照分数高低排序。尽管成员是唯一的，但是分数是可以重复的。
  - 对有序集合我们可以通过很快速的方式添加，删除和更新元素 (在和元素数量的对数成正比的时间内)。由于元素是有序的而无需事后排序，你可以通过分数或者排名 (位置) 很快地来获取一个范围内的元素。访问有序集合的中间元素也是很快的，所以你可以使用有序集合作为一个无重复元素，快速访问你想要的一切的聪明列表：有序的元素，快速的存在性测试，快速的访问中间元素！

  - 使用:
    > 1. 例如多人在线游戏排行榜，每次提交一个新的分数，你就使用 ZADD 命令更新。
    > 2. 你可以很容易地使用 `ZRANGE `命令获取前几名用户，你也可以用 `ZRANK `命令，通过给定用户名返回其排行。
    > 3. 同时使用 `ZRANK `和 `ZRANGE `命令可以展示与给定用户相似的用户及其分数。以上这些操作都非常的快。

* 位图 (Bitmaps) 和超重对数 (HyperLogLogs)

    > Redis 还支持位图和超重对数这两种基于字符串基本类型，但有自己语义的数据类型。

## 总结 ##
* 二进制安全 (binary-safe) 的字符串。
* 列表：按照插入顺序排序的字符串元素 (element) 的集合 (collection)。通常是链表。
* 集合：唯一的，无序的字符串元素集合。
* 有序集合：和集合类似，但是每个字符串元素关联了一个称为分数 (score) 的浮点数。元素总是按照分数排序，所以可以检索一个范围的元素 (例如，给我前 10，或者后 10 个元素)。
* 哈希：由字段 (field) 及其关联的值组成的映射。字段和值都是字符串类型。这非常类似于 Ruby 或 Python 中的哈希 / 散列。
* 位数组 (位图)：使用特殊的命令，把字符串当做位数组来处理：你可以设置或者清除单个位值，统计全部置位为 1 的位个数，寻找第一个复位或者置位的位，等等。
* 超重对数 (HyperLogLog)：这是一个用于估算集合的基数 (cardinality，也称势，译者注) 的概率性数据结构。不要害怕，它比看起来要简单，稍后为你揭晓。
*

## 关键字 ##
* Redis键(Keys)
  - Redis 键是二进制安全的，这意味着你可以使用任何二进制序列作为键，从像”foo” 这样的字符串到一个 JPEG 文件的内容。空字符串也是合法的键。
  - 键值规则：

  > 1. 不要使用太长的键，例如，不要使用一个 1024 字节的键，不仅是因为内存占用，而且在数据集中查找键时需要多次耗时的键比较。即使手头需要匹配一个很大值的存在性，对其进行哈希 (例如使用 SHA1) 是个不错的主意，尤其是从内存和带宽的角度。

  > 2. 不要使用太短的键。用”u1000flw” 取代”user:1000:followers” 作为键并没有什么实际意义，后者更具有可读性，相对于键对象本身以及值对象来说，增加的空间微乎其微。然而不可否认，短的键会消耗少的内存，你的任务就是要找到平衡点。

  > 3. 坚持一种模式 (schema)。例如，`object-type:id` 就不错，就像`user:1000`。点或者横线常用来连接多单词字段，如`comment:1234:reply.to`，或者`comment:1234:reply-to`。
  > 4. 键的最大大小是 512MB。

* Redis 字符串 (Strings)
  - Redis 字符串是可以关联给 redis 键的最简单值类型。字符串是 Memcached 的唯一数据类型，所以新手使用起来也是很自然的。
  - 由于 Redis 的键也是字符串，当我们使用字符串作为值的时候，我们是将一个字符串映射给另一个字符串。字符串数据类型适用于很多场景，例如，缓存 HTML 片段或者页面。

# Redis(String) #

## `set mykey somevalue` 设置内容：

```shell
127.0.0.1:6379> set name zbcn
OK
```

>  `set key value [ex seconds] [ px millionseconds] [nx|xx]`：为指定的键设置一个值，若键已存在值则覆盖，命令执行成功返回ok，添加nx或xx时命令执行失败返回nil
>   [ex seconds] 设置指定秒数后值失效 
>
>   [px millionseconds] 设置指定毫秒数后值失效 
>
> [nx|xx] nx表示只有键不存在才设置值，xx表示只有键存在才设置值

  __note__: 如果键已经存在，SET 会替换掉该键已经存在的值，哪怕这个键关联的是一个非字符串类型的值。SET 执行的是赋值操作。
  - 值可以是任何类型的字符串 (包括二进制数据)，例如，你可以存储一个 JPEG 图像。值不能大于 512MB。

## `get mykey`  获取内容

```shell
127.0.0.1:6379> get name
"zbcn"
```



## `set mykey somevalue nx`  和 `set mykey somevalue xx`

> `set mykey somevalue nx` - 如果不存在则插入成功,如果存在则插入失败
>
> `set mykey somevalue xx` - 如果存在则插入成功,如果不存在则插入失败

```shell
# 插入 name= zbcn
127.0.0.1:6379> set name zbcn
OK
# 查询 name 的值
127.0.0.1:6379> get name
"zbcn"
# 插入失败: nx表示只有键不存在才设置值
127.0.0.1:6379> set name zbcn_1 nx
(nil)
# 插入成功: xx表示只有键存在才设置值
127.0.0.1:6379> set name zbnc_02 xx
OK

```

## `INCR`, `IINCRBY` 和 `DECR` `DECRBY`

- `INCR` 命令将字符串值解析为整数，并增加一，最后赋值后作为新值
- `INCRBY`  命令将字符串值解析为整数，命令将按照指定的整数增加
- `DECR`  命令将字符串值解析为整数，并减 一 ,最后赋值后作为新值
- `DECRBY` 命令将字符串值解析为整数，命令将按照指定的整数减少

**示例:** 

  ```shell
127.0.0.1:6379> set count 100 
OK
127.0.0.1:6379> get count
"100"
# INCR 增加 1
127.0.0.1:6379> INCR count
(integer) 101
# 查看增加后的 count
127.0.0.1:6379> get count
"101"
# INCRBY 指定数量增加 
127.0.0.1:6379> INCRBY count 2
(integer) 103
# 查看增加后的值
127.0.0.1:6379> get count
"103" 	
# DECR 自减1
127.0.0.1:6379> DECR count
(integer) 102
# DECRBY 指定数量减少
127.0.0.1:6379> DECRBY count 5
(integer) 97
  ```
## `MSET` 和 `MGET` 命令：

`MESET`表示同时设置多个值, `MGET` 表示同时获取多个值

```shell
127.0.0.1:6379> mset a 1 b 2 c 3
OK
127.0.0.1:6379> mget a b c
1) "1"
2) "2"
3) "3"
```

## 改变和查询键空间 (key space)

* `EXISTS` 命令返回 1(存在) 或者 0(不存在)，来表示键在数据库中是否存在。
* `DEL` 命令删除键及其关联的值，无论值是什么。
* `TYPE` 命令返回某个键的值的类型。
```shell
> set mykey hello  
OK  
> exists mykey  
(integer) 1  
> del mykey  
(integer) 1  
> exists mykey  
(integer) 0
> set mykey x  
OK  
> type mykey  
string  
> del mykey  
(integer) 1  
> type mykey  
none  
```

## Redis 过期 (expires)：有限生存时间的键

> 在我们继续更复杂的数据结构之前，我们先抛出一个与类型无关的特性， 称为 Redis 过期 。你可以给键设置超时，也就是一个有限的生存时间。当生存时间到了，键就会自动被销毁，就像用户调用 DEL 命令一样。

* note ：
  - 过期时间可以设置为秒或者毫秒精度。
  - 过期时间分辨率总是 1 毫秒。
  - 过期信息被复制和持久化到磁盘，当 Redis 停止时时间仍然在计算 (也就是说 Redis 保存了过期时间)。

  - `EXPIRE` 命令设置过期
  - `PERSIST` 命令可以删除过期时间使键永远存在
  - `TTL` 命令检查键的生存剩余时间。
  ```shell
  127.0.0.1:6379> set expire_key 'hello redis'
  OK
  127.0.0.1:6379> expire expire_key 10
  (integer) 1
  127.0.0.1:6379> get expire_key
  "hello redis"
  # 10 秒后
  127.0.0.1:6379> get expire_key 
(nil)
  
  # 另一种方式
  127.0.0.1:6379> set expire_key 'hello word' EX 100
  OK
  # 检查剩余时间
  127.0.0.1:6379> ttl expire_key
  (integer) 93
  127.0.0.1:6379> get expire_key
  "hello word"
  # 删除过期时间,持久化到redis
  127.0.0.1:6379> PERSIST expire_key
  (integer) 1
  ```

# Redis 列表(Lists) #
## 操作

- `LPUSH` 命令从左边 (头部) 添加一个元素到列表，

- `RPUSH` 命令从右边(尾部)添加一个元素的列表。

- `LRANGE` 命令从列表中提取一个范围内的元素。
  
- `rpop` 从左侧弹出元素
  
- `lpop` 从右侧弹出

  ```shell
    # 从左边插入 一个 值 A
    > rpush mylist A  
    (integer) 1  
    # 从右边插入一个值 B
    > rpush mylist B  
    (integer) 2  
    # 从左边插入一个 值 first
    > lpush mylist first  
    (integer) 3  
    # 获取 mylist 列表 中的全部值
    > lrange mylist 0 -1  
    1) "first"  
    2) "A"  
    3) "B"  
    # 从右边依次插入 : 1 2 3 4 5 "foo bar"
    > rpush mylist 1 2 3 4 5 "foo bar"  
    (integer) 9  
    # 获取list 中的全部值
    > lrange mylist 0 -1  
    1) "first"  
    2) "A"  
    3) "B"  
    4) "1"  
    5) "2"  
    6) "3"  
    7) "4"  
    8) "5"  
    9) "foo bar"
  # 从左边弹出 first   
  127.0.0.1:6379> lpop mylist
  "first"
  # 从左边弹出 "foo bar"
  127.0.0.1:6379> rpop mylist
  "foo bar"
  ```

### 列表的通用场景(Common use cases) ###
- 记住社交网络中用户最近提交的更新。
- 使用生产者消费者模式来进程间通信，生产者添加项(item)到列表，消费者(通常是 worker)消费项并执行任务。Redis 有专门的列表命令更加可靠和高效的解决这种问题。
- 使用 `LTRIM` 命令仅仅只记住最新的 N 项，丢弃掉所有老的项。
- `LTRIM` 命令类似于 `LRANGE`，但是不同于展示指定范围的元素，而是将其作为列表新值存储

#### 自动创建和删除键 ####
- 当我们向聚合(aggregate)数据类型添加一个元素，如果目标键不存在，添加元素前将创建一个空的聚合数据类型。
- 当我们从聚合数据类型删除一个元素，如果值为空，则键也会被销毁。
- 调用一个像 `LLEN` 的只读命令(返回列表的长度)，或者一个写命令从空键删除元素，总是产生和操作一个持有空聚合类型值的键一样的结果。

# Redis 哈希/散列 (Hashes) #
- `HMSET` 添加元素
- `HGET` 获取元素
- `hgetall` 获取所有元素
- `HINCRBY` 针对单个字段的操作
  ```shell
  # 同时将多个 field-value (域-值)对设置到哈希表 key 中。
  127.0.0.1:6379> hmset user username zbcn age 23 gender 1 addr beijing
  OK 
  # 获取在哈希表中指定 key 的所有字段和值
  127.0.0.1:6379> hgetall user
  1) "username"
  2) "zbcn"
  3) "age"
  4) "23"
  5) "gender"
  6) "1"
  7) "addr"
  8) "beijing"
  # 获取所有哈希表中的字段
  127.0.0.1:6379> hkeys user
  1) "username"
  2) "age"
  3) "gender"
  4) "addr"
  5) "money"
  # 获取哈希表中字段的数量
  127.0.0.1:6379> hlen user
  (integer) 5
  # 获取存储在哈希表中指定字段的值。
  127.0.0.1:6379> hget user username
  "zbcn"
  # 获取所有给定字段的值
  127.0.0.1:6379> hmget user username age
  1) "zbcn"
  2) "26"
  #  将哈希表 key 中的字段 field 的值设为 value 。
  127.0.0.1:6379> hset user pc mac
  (integer) 1
  
  # 只有在字段 field 不存在时，设置哈希表字段的值。
  127.0.0.1:6379> hsetnx user pc win
  (integer) 0
  127.0.0.1:6379> hsetnx user phone iphone
  (integer) 1
  
  # 查看哈希表 key 中，指定的字段是否存在。
  127.0.0.1:6379> hexists user name
  (integer) 0 # 表示不存在
  127.0.0.1:6379> hexists user username
  (integer) 1 # 表示存在
  
  # 为哈希表 key 中的指定字段的整数值加上增量 increment 
  127.0.0.1:6379> hincrby user age 3
  (integer) 26
  # 为哈希表 key 中的指定字段的浮点数值加上增量 increment 。
  127.0.0.1:6379> hincrbyfloat user money 20.3
  "40.799999999999997"
  
  # 获取哈希表中所有值。
  127.0.0.1:6379> hvals user
  1) "zbcn"
  2) "26"
  3) "1"
  4) "beijing"
  5) "40.799999999999997"
  6) "mac"
  7) "iphone"
  # 迭代哈希表中的键值对。
  127.0.0.1:6379> hscan user 0 match "age"
  1) "0"
  2) 1) "age"
     2) "26"
  
  ```

# Redis 集合 (Sets) #
- Redis 的 Set 是 String 类型的无序集合。集合成员是唯一的，这就意味着集合中不能出现重复的数据。
- Redis 中集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是 O(1)。
- 集合中最大的成员数为 232 - 1 (4294967295, 每个集合可存储40多亿个成员)。
-  `SADD `命令添加元素到集合。
 ```shell
# 向集合添加一个或多个成员
127.0.0.1:6379> sadd db redis
(integer) 1
127.0.0.1:6379> sadd db mysql es mongodb
(integer) 3
# 获取集合的成员数
127.0.0.1:6379> scard db
(integer) 4

# 获取集合中的所有成员:SMEMBERS key
127.0.0.1:6379> smembers db
1) "mongodb"
2) "es"
3) "mysql"
4) "redis"

# 添加db2 集合
127.0.0.1:6379> sadd db2 oracle mq es
(integer) 3
# 返回第一个集合与其他集合之间的差异。
127.0.0.1:6379> sdiff db db2
1) "mongodb"
2) "mysql"
3) "redis"

# 给定所有集合的差集并存储在 destination  中
127.0.0.1:6379> sdiffstore destination db db2
(integer) 3
# 获取 destination
127.0.0.1:6379> smembers destination
1) "mongodb"
2) "mysql"
3) "redis"

# 返回给定所有集合的交集
127.0.0.1:6379> sinter db db2
1) "es"
# 删除 destination
127.0.0.1:6379> del destination
(integer) 1
# 返回给定所有集合的交集并存储在 destination 中
127.0.0.1:6379> sinterstore destination db  db2
(integer) 1
# 判断 member 元素是否是集合 key 的成员: SISMEMBER key member
127.0.0.1:6379> sismember db es
(integer) 1
# 将 member 元素从 source 集合移动到 destination 集合
127.0.0.1:6379> smove db destination mysql
(integer) 1
127.0.0.1:6379> smembers db
1) "mongodb"
2) "es"
3) "redis"
127.0.0.1:6379> smembers destination
1) "mysql"
2) "es"

# 移除并返回集合中的一个随机元素
127.0.0.1:6379> spop destination
"mysql"
# 返回集合中一个或多个随机数
127.0.0.1:6379> srandmember db 2
1) "mongodb"
2) "redis"
# 移除集合中一个或多个成员
127.0.0.1:6379> srem db mongodb redis
(integer) 2
# 返回所有给定集合的并集
127.0.0.1:6379> sunion db distination
1) "es"
# 所有给定集合的并集存储在 destination 集合中
127.0.0.1:6379> sunionstore destination db db2
(integer) 3
# 迭代集合中的元素
127.0.0.1:6379> sscan db 0 MATCH my*
1) "0"
2) 1) "mysql"
 ```

# Redis 有序集合 (Sorted sets) #

```shell
 zadd key [NX|XX] [CH] [INCR] score member [score member ...]
 
```

- 排序规则：

   - Redis 有序集合和集合一样也是 string 类型元素的集合,且不允许重复的成员。
   - 不同的是每个元素都会关联一个 double 类型的分数。redis 正是通过分数来为集合中的成员进行从小到大的排序。
   - 有序集合的成员是唯一的,但分数(score)却可以重复。
   - 如果 A 和 B 是拥有不同分数的元素，A.score > B.score，则 A > B。
   - 合是通过哈希表实现的，所以添加，删除，查找的复杂度都是 O(1)。 集合中最大的成员数为 2^32 - 1 (4294967295, 每个集合可存储40多亿个成员)。
   - 如果 A 和 B 是有相同的分数的元素，如果按字典顺序 A 大于 B，则 A > B。A 和 B 不能相同，因为排序集合只能有唯一元素。

   ```shell
   # 向有序集合添加一个或多个成员，或者更新已存在成员的分数
   127.0.0.1:6379> zadd score 90 zbcn
   (integer) 1 
   127.0.0.1:6379> zadd score 79 zhangsan 80 lisi 60 wangwu
   (integer) 3
   # 获取有序集合的成员数
   127.0.0.1:6379> zcard score
   (integer) 4
   # 计算在有序集合中指定区间分数的成员数
   127.0.0.1:6379> zcount score 80 90
   (integer) 2
   # 有序集合中对指定成员的分数加上增量 increment
   127.0.0.1:6379> zincrby score 5 zbcn
   "95"
   # 计算给定的一个或多个有序集的交集并将结果集存储在新的有序集合 destination 中
   ZINTERSTORE destination numkeys key [key ...]
   # 添加集合 midd_test
   127.0.0.1:6379> zadd midd_test 70 "Li Lei" 70 "Han Meimei" 99.5 "Tom"
   (integer) 3
   # 添加集合 fin_test
   127.0.0.1:6379> ZADD fin_test 88 "Li Lei" 75 "Han Meimei" 99.5 "Tom"
   (integer) 3
   # 求 midd_test 和fin_test 的交集 并且存储到 sum_point 中
   127.0.0.1:6379> zinterstore sum_point 2 midd_test fin_test
   (integer) 3
   
   # 查看 sum_point 中的内容 ZRANGE key start stop [WITHSCORES]
   # 以 -1 表示最后一个成员， -2 表示倒数第二个成员，以此类推
   127.0.0.1:6379> zrange sum_point 0 -1
   1) "Han Meimei"
   2) "Li Lei"
   3) "Tom"
   # 带score 值查看  sum_ponit 中的值 分数由小到大
   127.0.0.1:6379> zrange sum_point 0 -1 withscores
   1) "Han Meimei"
   2) "145"
   3) "Li Lei"
   4) "158"
   5) "Tom"
   6) "199"
   
   # 返回指定区间内的成员,成员的位置按分数值递减(从大到小)来排列
   127.0.0.1:6379>  zrevrange sum_point 0 -1 withscores
   1) "Tom"
   2) "199"
   3) "Li Lei"
   4) "158"
   5) "Han Meimei"
   6) "145"
   
   # 返回有序集合中指定成员的索引
   127.0.0.1:6379> zrank score zbcn
   (integer) 4
   
   # 返回有序集合中指定成员的排名，有序集成员按分数值递减(从大到小)排序
   127.0.0.1:6379> zrevrank score zbcn
   (integer) 0
   
   # 返回有序集中，成员的分数值
   127.0.0.1:6379> zscore score zbcn
   "95"
   
   # 计算给定的一个或多个有序集的并集，并存储在新的 key 中
   127.0.0.1:6379> zunionstore union_point 2 midd_test fin_test
   (integer) 3
   127.0.0.1:6379> zrange union_point 0 -1
   1) "Han Meimei"
   2) "Li Lei"
   3) "Tom"
   
   
   # 移除有序集合中的一个或多个成员
   127.0.0.1:6379> zrem score lisi
   (integer) 1
   
   # 移除有序集合中给定的字典区间的所有成员 ZREMRANGEBYLEX key min max
   127.0.0.1:6379> zremrangebylex myzset [a [b
   (integer) 2
   # 移除有序集合中给定的排名区间的所有成员: ZREMRANGEBYRANK key start stop
   127.0.0.1:6379> zremrangebyrank myzset 0 2
   (integer) 3
   
   # 移除有序集合中给定的分数区间的所有成员
   127.0.0.1:6379> zremrangebyscore score 60 (80
   (integer) 2
   
   # 迭代有序集合中的元素（包括元素成员和元素分值）
   127.0.0.1:6379> zscan union_point 0 match "Li Lei"
   1) "0"
   2) 1) "Li Lei"
      2) "158"
   ```

   ### ZRANGEBYLEX

   `ZRANGEBYLEX key min max [LIMIT offset count]`

   当以相同的分数插入排序集中的所有元素时，为了强制按字典顺序排序，此命令将返回键中排序集中的所有元素，且其值介于min和max之间。如果排序集中的元素具有不同的分数，则返回的元素未指定.

   min 和 max 说明:

   - 有效的开始和停止必须以（或[，为了指定范围项目是分别是排他性还是包含性。
   - +和-的特殊值（对于开始和停止）具有特殊含义，或者是正无限和负无限字符串，因此，例如，命令`ZRANGEBYLEX myzset-+`保证返回排序集中的所有元素,如果所有元素都具有相同的分数. 

   ```shell
   127.0.0.1:6379> ZADD myzset 0 a 0 b 0 c 0 d 0 e
   (integer) 5
   127.0.0.1:6379> ZADD myzset 0 f 0 g
   (integer) 2
   # 移除有序集合中给定的字典区间的所有成员
   127.0.0.1:6379> zrangebylex myzset [a [g
   1) "a"
   2) "b"
   3) "c"
   4) "d"
   5) "e"
   6) "f"
   7) "g"
   127.0.0.1:6379> zrangebylex myzset [a (g
   1) "a"
   2) "b"
   3) "c"
   4) "d"
   5) "e"
   6) "f"
   127.0.0.1:6379>  zrangebylex myzset - +
   1) "a"
   2) "b"
   3) "c"
   4) "d"
   5) "e"
   6) "f"
   7) "g"
   ```

   

   ### ZLEXCOUNT

   `ZLEXCOUNT key min max`

   当以相同的分数插入排序集中的所有元素时，为了强制按字典顺序排序，此命令返回键中排序集中的元素数，其值介于min和max之间。min和max参数的含义与对ZRANGEBYLEX的描述相同。

   ```shell
   # 在有序集合中计算指定字典区间内成员数量
   127.0.0.1:6379> ZLEXCOUNT myzset - +
   (integer) 7
   127.0.0.1:6379> ZLEXCOUNT myzset [a [b
   (integer) 2
   ```

   ###  ZRANGEBYSCORE

   Zrangebyscore 返回有序集合中指定分数区间的成员列表。有序集成员按分数值递增(从小到大)次序排列。

   具有相同分数值的成员按字典序来排列(该属性是有序集提供的，不需要额外的计算)。

   默认情况下，区间的取值使用闭区间 (小于等于或大于等于)，你也可以通过给参数前增加 `( `符号来使用可选的开区间 (小于或大于)。

```shell
127.0.0.1:6379> zrangebyscore score 60 90
1) "wangwu"
2) "zhangsan"
3) "lisi"
4) "zhaoliu"
127.0.0.1:6379> zrangebyscore score 60 90 withscores
1) "wangwu"
2) "60"
3) "zhangsan"
4) "79"
5) "lisi"
6) "80"
7) "zhaoliu"
8) "80"
# 显示整个有序集
127.0.0.1:6379> zrangebyscore score -inf +inf
1) "wangwu"
2) "zhangsan"
3) "lisi"
4) "zhaoliu"
5) "zbcn"
127.0.0.1:6379> zrangebyscore score -inf +inf withscores
 1) "wangwu"
 2) "60"
 3) "zhangsan"
 4) "79"
 5) "lisi"
 6) "80"
 7) "zhaoliu"
 8) "80"
 9) "zbcn"
10) "95"

# 显示分数 <=95 的所有成员
127.0.0.1:6379> zrangebyscore score -inf 95
1) "wangwu"
2) "zhangsan"
3) "lisi"
4) "zhaoliu"
5) "zbcn"

# 显示分数 >= 60 的所有成员
127.0.0.1:6379>  zrangebyscore score 60 +inf withscores
 1) "wangwu"
 2) "60"
 3) "zhangsan"
 4) "79"
 5) "lisi"
 6) "80"
 7) "zhaoliu"
 8) "80"
 9) "zbcn"
10) "95"

# 显示分数大于 60 小于 95 的成员
127.0.0.1:6379> zrangebyscore score (60 (95
1) "zhangsan"
2) "lisi"
3) "zhaoliu"
```

