# 什么是redis？

redis: remote dictionary server 远程字典服务。

# docker 安装redis

1. 查找镜像 `docker search redis`
2. 拉去镜像 `docker pull redis:latest`
3. 查看镜像 `docker images`
4. 运行镜像 `docker run -itd --name redis-test -p 6379:6379 redis`
5. 通过 redis-cli 连接测试使用 redis 服务:
   1. 进入容器中的 redis: `docker exec -it redis-test /bin/bash`
   2. 连接 redis：`redis-cli`

# redis 的进本命令

## 数据库操作

- 查看链接 `ping` : 返回值 `pong` 说明链接成功 

- 切换数据库 `select 3`(切换到3号数据库)
- 查看数据库大小 `DBSIZE`

- 清空当前数据库 `flushdb`
- 清空所有数据库 `flushall`

# redis 是单线程的？

- 多线程的应用程序并不一定是最快的

- redis 是基于内存操作的，如果使用多线程，会出现 cpu 上下文切换的耗时。降低使用效率。

# redis 常用命令

## redisKey 基本命令

- `keys *` 查看 数据keys集合
- `exists [key]` 判断某个key 值是否存在，存在返回1， 不存在返回0.
- `move [key] [dbname]` 移除某个数据库中 的 key
- `expire [key] [time]`  设置某个 key 的过期时间,单位 位 seconds
- `ttl [key]` 查看某个key 的剩余过期时间 
- `type key` 查看 key 的数据类型

## String 类型

### 基本操作

- `set key value` 设置值
- `get key` 获取值
- `append key value`  往指定的字符串拼接 value
- `strlen key` 查看 指定字符串的长度

### 自增操作

- `incr key` 自增操作 类似于 key+1
- `decr key` 自减操作 类似于 key-1
- `incrby key len` 按照步长增加，len表示步长
- `decrby key len` 按照步长减少，len 表示步长

### 字符串范围

- `getrange key start end`  获取指定长度的字符串（闭区间）；（0，-1） 表示全部字符串
- `setrange key start value` 替换指定位置开始的字符串 start:开始位置，value 需要替换的值

### 按照条件设置

- `setex key secondes value` ： set with expire  设置一个 key 带过期时间
- `setnx key value` :set if not exist 如果 key 不存在 则设置 （分布式锁常常会使用）

### 批量设置

- `mset key value [k1 v1 k2 v2....]`  批量设置， 是一个原子性操作。
- `mget key [k1 k2 k3 ....]` 获取多个值

### 对象

#### 常规

- `set user:1 {name:zhangsan, age:2}` # 设置一个 user:1 对象。值为 对象的json 字符串格式

#### 对key巧妙的设计：user:{id}:{field}

- `mset user:1:name zhangsan user:1:age 2`  设置一个 user:1 对象
- `mget user:1:name user:1:age` 获取一个 user:1 对象 

### 组合命令

`getset key value` 如果不存在旧值，则返回nil ，如果存在旧值，则返回旧值，然后将旧值替换为新值



### 使用场景

- 字符串
- 数字（计数器）
- 缓存（利用过期时间）

## List

所有的list命令都是 以 `l` 开头

- `lpush key value [value1 value2 value3  ...]`  将一个值或者多个值插入到列表的头部(左边)
- `lrange key start stop`  获取list中指定的值 （0，-1） 全部。 
- `rpush key value [v1 v2 v3 ...]` 将一个值或者多个值插入到列表的尾部(右边)

- `lpop key` 移除list 的第一个值（左边）
- `rpop key` 移除list 的最后一个值（右边）
- `lindex key index` 获取某一个key 的某一个下标的值
- `llen key`  获取list 的长度
- `lrem key count value` 移除指定额值。count：移除指定值得数量
- `ltrim start end 截取指定的区间的值
- `rpoplpush surceKey desKey` 移除列表的最后一个元素到新的列表的头部
- `lset key index value` 将指定下标的值更新为value值。如果index 不存在则会报错，如果存在则更新
- `linsert key  before|after pivot value`  往指定的 pivot 的前面或者后面插入value 值。

### 小结

- 实际上是一个链表，before/ after（左边，右边） node 都可以插入
- 如果key 不存在则创建新链表
- 如果存在，则新增内容
- 如果移除了所有的值，空链表，也代表不存在
- 在两边插入或者改动值，效率最高，中间元素，相对来说说效率第一点

### 应用

- 消息排队
- 消息队列
- 栈
- 消息截断

## Set 集合

set 集合中的值是不能重复的，（无需不重复）

- `sadd key value`  set集合中添加元素
- `smembers key` 查看指定set 中的所有元素
- `sismember key value ` 判断value 是否在指定set 中存在
- `scard key` 获取指定set中元素个数
- `srem key value`  移除set中的指定元素
- `srandmember key [count]` 随机获取元素，count：元素的个数
- `spop key [count]` 随机删除指定set 中的元素 count: 元素个数
- `smove key1 key2 value` 将一个set集合中的指定元素移动到另一个集合

### 求交集、并集、差集

- `sdiff key1 key2` 求差集
- `sinter key1 key2` 求交集  ： --》共同好友
- `sunion key1 key2` 求并集

## Hash

Map 集合： key-map（value 是一个map 集合）

操作命令和string 很像

- `hset key field value [f1 v1 f2 v2 ...]`  往指定 key 中设置值（key -value）
- `hmset key  field value [f1 v1 f2 v2 ...]` 多个
- `hget key  field` 获取指定 hash 的指定属性值
- `hmget key  field [f1 f2 ...]` 获取指定对象的多个指定属性值。
- `hgetall key` 获取全部的字段值
- `hdel key field` 删除指定的值
- `hlen key` 获取hash表的字段数量
- `hexists key field`  获取指定 key 的 指定字段是否存在
- `hkeys key ` 获取所有的key
- `hvals key` 获取所有的value
-  `hincrby key field num`
- `hsetnx`
- ...

### 应用

- hash 变更数据 （用户信息的存储，hash 更适合对象的存储， string 更适合单字符串的存储）

## Zset 有序集合

在set 的基础上增加了一个分值（score）， 作为排序条件

-  `zadd key score member` 添加一个元素，score：添加元素的分值，用来做排序条件
- `zrangebyscore key min max [withscores]`  最小值到最大数排序。（-inf +inf）表示负无穷 到正无穷 withscores表示是带分值
- `zrevrange key min max `  从大到小
- `zrem key mem` 移除指定元素
- `zcard key` 获取有序集合的数量

- `zcount key start end` 获取指定区间的元素

### 应用

- 排序
- 访问量排序
- 带权重判断
- 排行榜：top 10

# 特殊数据类型

##  geospatial 地理位置

## hyperloglog 基础统计的算法

## bitmaps







