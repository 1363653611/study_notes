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

### redis 支持数据类型 ###
* Strings(字符串)
  - character：
   1. Redis 字符串是二进制安全的，也就是说，一个 Redis 字符串可以包含任意类型的数据，例如一张 JPEG 图像，或者一个序列化的 Ruby 对象。
   2. 一个字符串最大为 512M 字节。
  - 使用：
    > 1. 使用 INCR 命令族 (INCR，DECR，INCRBY)，将字符串作为原子计数器。
    > 2. 使用 APPEND 命令追加字符串。
    > 3. 使用 GETRANGE 和 SETRANGE 命令，使字符串作为随机访问向量 (vectors)。
    > 4.  编码大量数据到很小的空间，或者使用 GETBIT 和 SETBIT 命令，创建一个基于 Redis 的布隆 (Bloom) 过滤器。

* Lists(列表)
  - Redis 列表仅仅是按照插入顺序排序的字符串列表。
  - LPUSH 命令用于插入一个元素到列表的头部，RPUSH 命令用于插入一个元素到列表的尾部。
  - 列表的最大长度是 223-1 个元素 (4294967295，超过 40 亿个元素)。
  - 使用：
   > 1.为社交网络时间轴 (timeline) 建模，使用 LPUSH 命令往用户时间轴插入元素，使用 LRANGE 命令获得最近事项。
    > 2.使用 LPUSH 和 LTRIM 命令创建一个不会超出给定数量元素的列表，只存储最近的 N 个元素。
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

* Hashes(哈希/三列)
 - Redis 哈希是字符串字段 (field) 与字符串值之间的映射，所以是表示对象的理想数据类型 (例如：一个用户对象有多个字段，像用户名，姓氏，年龄等等)：
    ```
        @cli  
        HMSET user:1000 username antirez password P1pp0 age 34  
        HGETALL user:1000  
        HSET user:1000 password 12345  
        HGETALL user:1000

    ```
    - 拥有少量字段 (少量指的是大约 100) 的哈希会以占用很少存储空间的方式存储，所以你可以在一个很小的 Redis 实例里存储数百万的对象。
    - 由于哈希主要用来表示对象，对象能存储很多元素，所以你可以用哈希来做很多其他的事情
    - 每个哈希可以存储多达 223-1 个字段值对 (field-value pair)(多于 40 亿个)。
* Sorted sets (有序集合)
 - Redis 有序集合和 Redis 集合类似，是非重复字符串集合 (collection)。不同的是，每一个有序集合的成员都有一个关联的分数 (score)，用于按照分数高低排序。尽管成员是唯一的，但是分数是可以重复的。
 - 对有序集合我们可以通过很快速的方式添加，删除和更新元素 (在和元素数量的对数成正比的时间内)。由于元素是有序的而无需事后排序，你可以通过分数或者排名 (位置) 很快地来获取一个范围内的元素。访问有序集合的中间元素也是很快的，所以你可以使用有序集合作为一个无重复元素，快速访问你想要的一切的聪明列表：有序的元素，快速的存在性测试，快速的访问中间元素！
 -
 - 使用:
    > 1. 例如多人在线游戏排行榜，每次提交一个新的分数，你就使用 ZADD 命令更新。
    > 2. 你可以很容易地使用 ZRANGE 命令获取前几名用户，你也可以用 ZRANK 命令，通过给定用户名返回其排行。
    > 3. 同时使用 ZRANK 和 ZRANGE 命令可以展示与给定用户相似的用户及其分数。以上这些操作都非常的快。

* 位图 (Bitmaps) 和超重对数 (HyperLogLogs)

    > Redis 还支持位图和超重对数这两种基于字符串基本类型，但有自己语义的数据类型。

#### 总结 #####
* 二进制安全 (binary-safe) 的字符串。
* 列表：按照插入顺序排序的字符串元素 (element) 的集合 (collection)。通常是链表。
* 集合：唯一的，无序的字符串元素集合。
* 有序集合：和集合类似，但是每个字符串元素关联了一个称为分数 (score) 的浮点数。元素总是按照分数排序，所以可以检索一个范围的元素 (例如，给我前 10，或者后 10 个元素)。
* 哈希：由字段 (field) 及其关联的值组成的映射。字段和值都是字符串类型。这非常类似于 Ruby 或 Python 中的哈希 / 散列。
* 位数组 (位图)：使用特殊的命令，把字符串当做位数组来处理：你可以设置或者清除单个位值，统计全部置位为 1 的位个数，寻找第一个复位或者置位的位，等等。
* 超重对数 (HyperLogLog)：这是一个用于估算集合的基数 (cardinality，也称势，译者注) 的概率性数据结构。不要害怕，它比看起来要简单，稍后为你揭晓。
*

#### 关键字 ####
* Redis键(Keys)
  - Redis 键是二进制安全的，这意味着你可以使用任何二进制序列作为键，从像”foo” 这样的字符串到一个 JPEG 文件的内容。空字符串也是合法的键。
  - 键值规则：

  > 1. 不要使用太长的键，例如，不要使用一个 1024 字节的键，不仅是因为内存占用，而且在数据集中查找键时需要多次耗时的键比较。即使手头需要匹配一个很大值的存在性，对其进行哈希 (例如使用 SHA1) 是个不错的主意，尤其是从内存和带宽的角度。

  > 2. 不要使用太短的键。用”u1000flw” 取代”user:1000:followers” 作为键并没有什么实际意义，后者更具有可读性，相对于键对象本身以及值对象来说，增加的空间微乎其微。然而不可否认，短的键会消耗少的内存，你的任务就是要找到平衡点。

  > 3. 坚持一种模式 (schema)。例如，”object-type:id” 就不错，就像”user:1000”。点或者横线常用来连接多单词字段，如”comment:1234:reply.to”，或者”comment:1234:reply-to”。
  > 4. 键的最大大小是 512MB。

* Redis 字符串 (Strings)
  - Redis 字符串是可以关联给 redis 键的最简单值类型。字符串是 Memcached 的唯一数据类型，所以新手使用起来也是很自然的。
  - 由于 Redis 的键也是字符串，当我们使用字符串作为值的时候，我们是将一个字符串映射给另一个字符串。字符串数据类型适用于很多场景，例如，缓存 HTML 片段或者页面。

#### Redis(String) ####

- `set mykey somevalue` 设置内容：

  __note__: 如果键已经存在，SET 会替换掉该键已经存在的值，哪怕这个键关联的是一个非字符串类型的值。SET 执行的是赋值操作。
  - 值可以是任何类型的字符串 (包括二进制数据)，例如，你可以存储一个 JPEG 图像。值不能大于 512MB。
  - `set mykey somevalue nx` - 如果我要求如果键存在 (或刚好相反) 则执行失败
  - `set mykey somevalue xx`
  - redis 可以进行基本数值的原子操作：NCR 命令将字符串值解析为整数，并增加一，最后赋值后作为新值。还有一些类似的命令 INCRBY，DECR 和 DECRBY。它们以略微不同的方式执行，但其内部都是一样的命令
  ```redis
      > set counter 100   #  
      OK  
      > incr counter  
      (integer) 101  
      > incr counter  
      (integer) 102  
      > incrby counter 50  
      (integer) 152   
  ```
  - `get mykey` --获取内容
  -  `MSET` 和 `MGET` 命令：
    ```
    > mset a 10 b 20 c 30  
    OK  
    > mget a b c  
    1) "10"  
    2) "20"  
    3) "30"
    ```
  - 改变和查询键空间 (key space)
    * `EXISTS` 命令返回 1(存在) 或者 0(不存在)，来表示键在数据库中是否存在。
    * `DEL` 命令删除键及其关联的值，无论值是什么。
    * `TYPE` 命令返回某个键的值的类型。
    ```
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

- Redis 过期 (expires)：有限生存时间的键
  > 在我们继续更复杂的数据结构之前，我们先抛出一个与类型无关的特性， 称为 Redis 过期 。你可以给键设置超时，也就是一个有限的生存时间。当生存时间到了，键就会自动被销毁，就像用户调用 DEL 命令一样。

  * note ：
    - 过期时间可以设置为秒或者毫秒精度。
    - 过期时间分辨率总是 1 毫秒。
    - 过期信息被复制和持久化到磁盘，当 Redis 停止时时间仍然在计算 (也就是说 Redis 保存了过期时间)。

    - `EXPIRE` 命令设置过期
    - `PERSIST` 命令可以删除过期时间使键永远存在
    - `TTL` 命令检查键的生存剩余时间。
    ```
      > set key some-value  
      OK  
      > expire key 5  
      (integer) 1  
      > get key (immediately)  
      "some-value"  
      > get key (after some time)  
      (nil)  

      > set key 100 ex 10  
      OK  
      > ttl key  
      (integer) 9
    ```

#### Redis 列表(Lists) ####
- 操作
  - `LPUSH` 命令从左边 (头部) 添加一个元素到列表，
  - `RPUSH` 命令从右边(尾部)添加一个元素的列表。
  - `LRANGE` 命令从列表中提取一个范围内的元素。
    ```
      > rpush mylist A  
      (integer) 1  
      > rpush mylist B  
      (integer) 2  
      > lpush mylist first  
      (integer) 3  
      > lrange mylist 0 -1  
      1) "first"  
      2) "A"  
      3) "B"  
      > rpush mylist 1 2 3 4 5 "foo bar"  
      (integer) 9  
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
    ```
- `rpop` 从左侧弹出元素
- `lpop` 从右侧弹出

#### 列表的通用场景(Common use cases) ####
- 记住社交网络中用户最近提交的更新。
- 使用生产者消费者模式来进程间通信，生产者添加项(item)到列表，消费者(通常是 worker)消费项并执行任务。Redis 有专门的列表命令更加可靠和高效的解决这种问题。
- 使用 `LTRIM` 命令仅仅只记住最新的 N 项，丢弃掉所有老的项。
- `LTRIM` 命令类似于 LRANGE，但是不同于展示指定范围的元素，而是将其作为列表新值存储

#### 自动创建和删除键 ####
- 当我们向聚合(aggregate)数据类型添加一个元素，如果目标键不存在，添加元素前将创建一个空的聚合数据类型。
- 当我们从聚合数据类型删除一个元素，如果值为空，则键也会被销毁。
- 调用一个像 LLEN 的只读命令(返回列表的长度)，或者一个写命令从空键删除元素，总是产生和操作一个持有空聚合类型值的键一样的结果。

#### Redis 哈希/散列 (Hashes) ####
- `HMSET` 添加元素
- `HGET` 获取元素
- `hgetall` 获取所有元素
- `HINCRBY` 针对单个字段的操作
  ```
      > hmset user:1000 username antirez birthyear 1977 verified 1  
      OK  
      > hget user:1000 username  
      "antirez"  
      > hget user:1000 birthyear  
      "1977"  
      > hgetall user:1000  
      1) "username"  
      2) "antirez"  
      3) "birthyear"  
      4) "1977"  
      5) "verified"  
      6) "1"  
  ```

#### Redis 集合 (Sets) ####
- `SADD `命令添加元素到集合。
 ```
    > sadd myset 1 2 3  
    (integer) 3  
    > smembers myset  
    1. 3  
    2. 1  
    3. 2

    > sismember myset 3   # 指定元素是否存在
    (integer) 1  
    > sismember myset 30  
    (integer) 0  
```

#### Redis 有序集合 (Sorted sets) ####
- 排序规则：
   * 如果 A 和 B 是拥有不同分数的元素，A.score > B.score，则 A > B。
   * 如果 A 和 B 是有相同的分数的元素，如果按字典顺序 A 大于 B，则 A > B。A 和 B 不能相同，因为排序集合只能有唯一元素。

   ```
      > zadd hackers 1940 "Alan Kay"  
      (integer) 1  
      > zadd hackers 1957 "Sophie Wilson"  
      (integer 1)  
      > zadd hackers 1953 "Richard Stallman"  
      (integer) 1  
      > zadd hackers 1949 "Anita Borg"  
      (integer) 1  
      > zadd hackers 1965 "Yukihiro Matsumoto"  
      (integer) 1  
      > zadd hackers 1914 "Hedy Lamarr"  
      (integer) 1  
      > zadd hackers 1916 "Claude Shannon"  
      (integer) 1  
      > zadd hackers 1969 "Linus Torvalds"  
      (integer) 1  
      > zadd hackers 1912 "Alan Turing"  
      (integer) 1  
   ```
