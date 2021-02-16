---
title: 06.缓存机制
date: 2021-02-16 13:14:10
tags:
 - mybatis
 - sql
categories:
 - mybatis
 - 动态sql
topdeclare: true
reward: true
---

# 一级缓存

在应用运行过程中，我们有可能在一次数据库会话中，执行多次查询条件完全相同的SQL，MyBatis提供了一级缓存的方案优化这部分场景，如果是相同的SQL语句，会优先命中一级缓存，避免直接对数据库进行查询，提高性能。具体执行过程如下图所示。

![img](mybatis_06缓存机制/6e38df6a.jpg)

每个SqlSession中持有了Executor，每个Executor中有一个LocalCache。当用户发起查询时，MyBatis根据当前执行的语句生成`MappedStatement`，在Local Cache进行查询，如果缓存命中的话，直接返回结果给用户，如果缓存没有命中的话，查询数据库，结果写入`Local Cache`，最后返回结果给用户。具体实现类的类关系图如下图所示。

![img](mybatis_06缓存机制/d76ec5fe.jpg)

## 一级缓存配置

开启一级缓存，只要在 myBatis 配置文件的 settings 节点下配置 `<setting name="localCacheScope" value="SESSION"/>`

共有两个选项，`SESSION`或者`STATEMENT`，默认是`SESSION`级别，即在一个MyBatis会话中执行的所有语句，都会共享这一个缓存。一种是`STATEMENT`级别，可以理解为缓存只对当前执行的这一个`Statement`有效。

## 一级缓存测试

### 测试 1

开启一级缓存，调用 4次查询，

```java
  public static void main(String[] args) throws IOException {
        SqlSessionFactory sessionFactory = getSqoSessionFactory();
        try (SqlSession sqlSession = sessionFactory.openSession(true)){
            BlogMapper mapper = sqlSession.getMapper(BlogMapper.class);
            Blog blog = mapper.selectOne(4);
            System.out.println("查询1："+ JSON.toJSONString(blog));
            Blog blog2 = mapper.selectOne(4);
            System.out.println("查询2："+ JSON.toJSONString(blog2));
            Blog blog3 = mapper.selectOne(4);
            System.out.println("查询3："+ JSON.toJSONString(blog3));
            Blog blog4 = mapper.selectOne(4);
            System.out.println("查询4："+ JSON.toJSONString(blog4));
        }
    }
```

控制台打印

```shell
DEBUG [main] - Opening JDBC Connection
DEBUG [main] - Created connection 1427646530.
DEBUG [main] - ==>  Preparing: select * from blog where id = ?
DEBUG [main] - ==> Parameters: 4(Integer)
DEBUG [main] - <==      Total: 1
查询1：{"authorId":0,"content":"测试博客","id":4,"name":"张三","title":"我的北漂时光"}
查询2：{"authorId":0,"content":"测试博客","id":4,"name":"张三","title":"我的北漂时光"}
查询3：{"authorId":0,"content":"测试博客","id":4,"name":"张三","title":"我的北漂时光"}
查询4：{"authorId":0,"content":"测试博客","id":4,"name":"张三","title":"我的北漂时光"}
```

我们可以看到，只有第一次真正查询了数据库，后续的查询使用了一级缓存。

### 测试2

增加了对数据库的修改操作，验证在一次数据库会话中，如果对数据库 **表中的数据发生了修改操作，一级缓存会失效**

```java
private static void test2(BlogMapper mapper) {
        Blog blog = mapper.selectOne(4);
        System.out.println("查询1："+ JSON.toJSONString(blog));
        Blog blog2 = mapper.selectOne(4);
        System.out.println("查询2："+ JSON.toJSONString(blog2));
        Blog blog3 = mapper.selectOne(4);
        System.out.println("查询3："+ JSON.toJSONString(blog3));
        insert(mapper);
        Blog blog4 = mapper.selectOne(4);
        System.out.println("查询4："+ JSON.toJSONString(blog4));
    }
    private static void insert(BlogMapper mapper){
        Blog blog = new Blog();
        blog.setAuthorId(1);
        blog.setContent("测试博客");
        blog.setCreateTime(new Date());
        blog.setName("张三");
        blog.setTitle("我的北漂时光");
        mapper.insert(blog);
    }
```

### 测试3

开启两个`SqlSession`，在`sqlSession1`中查询数据，使一级缓存生效，在`sqlSession2`中更新数据库，验证一级缓存只在数据库会话内部共享。

```java
private static void test3(SqlSessionFactory sessionFactory) {
        try (SqlSession sqlSession1 = sessionFactory.openSession(true);
             SqlSession sqlSession2 = sessionFactory.openSession(true)){
            BlogMapper mapper1 = sqlSession1.getMapper(BlogMapper.class);
            BlogMapper mapper2 = sqlSession2.getMapper(BlogMapper.class);
            Blog blog = mapper1.selectOne(4);
            System.out.println("查询1："+ JSON.toJSONString(blog));
            Blog blog2 = mapper1.selectOne(4);
            System.out.println("查询2："+ JSON.toJSONString(blog2));
            System.out.println("mapper2 新增数据");
            insert(mapper2);
            Blog blog3 = mapper1.selectOne(4);
            System.out.println("mapper1查询3："+ JSON.toJSONString(blog3));
            Blog blog4 = mapper2.selectOne(4);
            System.out.println("mapper2查询4："+ JSON.toJSONString(blog4));

        }
    }
```



结果：

![image-20200922192251914](mybatis_06缓存机制/image-20200922192251914.png)

sesson2 新增了一条数据，session1 没有从数据库重新查询数据，依旧走的是缓存，说明：**一级缓存只在数据库会话内部共享**。

## 一级缓存工作流程&源码分析

### 工作流

![img](mybatis_06缓存机制/bb851700.png)

### 源码分析

#### **SqlSession**

 对外提供了用户和数据库之间交互需要的所有方法，隐藏了底层的细节。默认实现类是`DefaultSqlSession`

![img](mybatis_06缓存机制/ba96bc7f.jpg)

### **Executor**

`SqlSession`向用户提供操作数据库的方法，但和数据库操作有关的职责都会委托给Executor。

![img](mybatis_06缓存机制/ef5e0eb3.jpg)

- Executor有若干个实现类，为Executor赋予了不同的能力，

![img](mybatis_06缓存机制/83326eb3.jpg)

### **BaseExecutor**

`BaseExecutor`是一个实现了Executor接口的抽象类，定义若干抽象方法，在执行的时候，把具体的操作委托给子类进行执行。

```java
protected abstract int doUpdate(MappedStatement ms, Object parameter) throws SQLException;
protected abstract List<BatchResult> doFlushStatements(boolean isRollback) throws SQLException;
protected abstract <E> List<E> doQuery(MappedStatement ms, Object parameter, RowBounds rowBounds, ResultHandler resultHandler, BoundSql boundSql) throws SQLException;
protected abstract <E> Cursor<E> doQueryCursor(MappedStatement ms, Object parameter, RowBounds rowBounds, BoundSql boundSql) throws SQLException;
```

- 在一级缓存的介绍中提到对`Local Cache`的查询和写入是在`Executor`内部完成的。在阅读`BaseExecutor`的代码后发现`Local Cache`是`BaseExecutor`内部的一个成员变量，如下代码所示。

  ```java
  public abstract class BaseExecutor implements Executor {
      protected ConcurrentLinkedQueue<DeferredLoad> deferredLoads;
      protected PerpetualCache localCache;
  }
  ```

  ### **Cache**

  MyBatis中的Cache接口，提供了和缓存相关的最基本的操作，如下图所示：

  ![img](mybatis_06缓存机制/793031d0.jpg)

有若干个实现类，使用装饰器模式互相组装，提供丰富的操控缓存的能力，部分实现类如下图所示：

![img](mybatis_06缓存机制/cdb21712.jpg)

`BaseExecutor`成员变量之一的`PerpetualCache`，是对Cache接口最基本的实现，其实现非常简单，内部持有HashMap，对一级缓存的操作实则是对HashMap的操作。如下代码所示：

```java
public class PerpetualCache implements Cache {
  private String id;
  private Map<Object, Object> cache = new HashMap<Object, Object>();
}
```

为执行和数据库的交互，首先需要初始化`SqlSession`，通过`DefaultSqlSessionFactory`开启`SqlSession`

```java
private SqlSession openSessionFromDataSource(ExecutorType execType, TransactionIsolationLevel level, boolean autoCommit) {
    ............
    final Executor executor = configuration.newExecutor(tx, execType);     
    return new DefaultSqlSession(configuration, executor, autoCommit);
}
```

在初始化`SqlSesion`时，会使用`Configuration`类创建一个全新的`Executor`，作为`DefaultSqlSession`构造函数的参数，创建Executor代码如下所示：

```java
public Executor newExecutor(Transaction transaction, ExecutorType executorType) {
    executorType = executorType == null ? defaultExecutorType : executorType;
    executorType = executorType == null ? ExecutorType.SIMPLE : executorType;
    Executor executor;
    if (ExecutorType.BATCH == executorType) {
      executor = new BatchExecutor(this, transaction);
    } else if (ExecutorType.REUSE == executorType) {
      executor = new ReuseExecutor(this, transaction);
    } else {
      executor = new SimpleExecutor(this, transaction);
    }
    // 尤其可以注意这里，如果二级缓存开关开启的话，是使用CahingExecutor装饰BaseExecutor的子类
    if (cacheEnabled) {
      executor = new CachingExecutor(executor);                      
    }
    executor = (Executor) interceptorChain.pluginAll(executor);
    return executor;
}
```

`SqlSession`创建完毕后，根据Statment的不同类型，会进入`SqlSession`的不同方法中，如果是`Select`语句的话，最后会执行到`SqlSession`的`selectList`，代码如下所示：

```java
@Override
public <E> List<E> selectList(String statement, Object parameter, RowBounds rowBounds) {
      MappedStatement ms = configuration.getMappedStatement(statement);
      return executor.query(ms, wrapCollection(parameter), rowBounds, Executor.NO_RESULT_HANDLER);
}
```

`SqlSession`把具体的查询职责委托给了Executor。如果只开启了一级缓存的话，首先会进入`BaseExecutor`的`query`方法。代码如下所示：

```java
@Override
public <E> List<E> query(MappedStatement ms, Object parameter, RowBounds rowBounds, ResultHandler resultHandler) throws SQLException {
    BoundSql boundSql = ms.getBoundSql(parameter);
    CacheKey key = createCacheKey(ms, parameter, rowBounds, boundSql);
    return query(ms, parameter, rowBounds, resultHandler, key, boundSql);
}
```

在上述代码中，会先根据传入的参数生成CacheKey，进入该方法查看CacheKey是如何生成的，代码如下所示

```java
CacheKey cacheKey = new CacheKey();
cacheKey.update(ms.getId());
cacheKey.update(rowBounds.getOffset());
cacheKey.update(rowBounds.getLimit());
cacheKey.update(boundSql.getSql());
//后面是update了sql中带的参数
cacheKey.update(value);
```

在上述的代码中，将`MappedStatement`的Id、SQL的offset、SQL的limit、SQL本身以及SQL中的参数传入了CacheKey这个类，最终构成CacheKey。以下是这个类的内部结构：

```java
private static final int DEFAULT_MULTIPLYER = 37;
private static final int DEFAULT_HASHCODE = 17;

private int multiplier;
private int hashcode;
private long checksum;
private int count;
private List<Object> updateList;

public CacheKey() {
    this.hashcode = DEFAULT_HASHCODE;
    this.multiplier = DEFAULT_MULTIPLYER;
    this.count = 0;
    this.updateList = new ArrayList<Object>();
}
```

首先是成员变量和构造函数，有一个初始的`hachcode`和乘数，同时维护了一个内部的`updatelist`。在`CacheKey`的`update`方法中，会进行一个`hashcode`和`checksum`的计算，同时把传入的参数添加进`updatelist`中。如下代码所示

```java
public void update(Object object) {
    int baseHashCode = object == null ? 1 : ArrayUtil.hashCode(object); 
    count++;
    checksum += baseHashCode;
    baseHashCode *= count;
    hashcode = multiplier * hashcode + baseHashCode;
    
    updateList.add(object);
}
```

同时重写了`CacheKey`的`equals`方法，代码如下所示：

```java
@Override
public boolean equals(Object object) {
    .............
    for (int i = 0; i < updateList.size(); i++) {
      Object thisObject = updateList.get(i);
      Object thatObject = cacheKey.updateList.get(i);
      if (!ArrayUtil.equals(thisObject, thatObject)) {
        return false;
      }
    }
    return true;
}
```

除去hashcode、checksum和count的比较外，只要updatelist中的元素一一对应相等，那么就可以认为是CacheKey相等。只要两条SQL的下列五个值相同，即可以认为是相同的SQL。

> Statement Id + Offset + Limmit + Sql + Params

BaseExecutor的query方法继续往下走，代码如下所示：

```java
list = resultHandler == null ? (List<E>) localCache.getObject(key) : null;
if (list != null) {
    // 这个主要是处理存储过程用的。
    handleLocallyCachedOutputParameters(ms, key, parameter, boundSql);
    } else {
    list = queryFromDatabase(ms, parameter, rowBounds, resultHandler, key, boundSql);
}
```

如果查不到的话，就从数据库查，在`queryFromDatabase`中，会对`localcache`进行写入。

在`query`方法执行的最后，会判断一级缓存级别是否是`STATEMENT`级别，如果是的话，就清空缓存，这也就是`STATEMENT`级别的一级缓存无法共享`localCache`的原因。代码如下所示：

```java
if (configuration.getLocalCacheScope() == LocalCacheScope.STATEMENT) {
        clearLocalCache();
}
```

在源码分析的最后，我们确认一下，如果是`insert/delete/update`方法，缓存就会刷新的原因。

```java
@Override
public int insert(String statement, Object parameter) {
    return update(statement, parameter);
  }
   @Override
  public int delete(String statement) {
    return update(statement, null);
}
```

`update`方法也是委托给了`Executor`执行。`BaseExecutor`的执行方法如下所示：

```java
@Override
public int update(MappedStatement ms, Object parameter) throws SQLException {
    ErrorContext.instance().resource(ms.getResource()).activity("executing an update").object(ms.getId());
    if (closed) {
      throw new ExecutorException("Executor was closed.");
    }
    clearLocalCache();
    return doUpdate(ms, parameter);
}
```

每次执行`update`前都会清空`localCache`。

## 总结

1. MyBatis一级缓存的生命周期和SqlSession一致。
2. MyBatis一级缓存内部设计简单，只是一个没有容量限定的HashMap，在缓存的功能性上有所欠缺。
3. MyBatis的一级缓存最大范围是SqlSession内部，有多个SqlSession或者分布式的环境下，数据库写操作会引起脏数据，建议设定缓存级别为Statement。

# 二级缓存

## 二级缓存介绍

在上文中提到的一级缓存中，其最大的共享范围就是一个SqlSession内部，如果多个SqlSession之间需要共享缓存，则需要使用到二级缓存。开启二级缓存后，会使用CachingExecutor装饰Executor，进入一级缓存的查询流程前，先在CachingExecutor进行二级缓存的查询，具体的工作流程如下所示。

![img](mybatis_06缓存机制/28399eba.png)

二级缓存开启后，同一个namespace下的所有操作语句，都影响着同一个Cache，即二级缓存被多个SqlSession共享，是一个全局的变量。

当开启缓存后，数据的查询执行的流程就是 **二级缓存 -> 一级缓存 -> 数据库**。

## 二级缓存配置

1. 在MyBatis的配置文件中开启二级缓存。 `<setting name="cacheEnabled" value="true"/>`
2. 在MyBatis的映射XML中配置cache或者 cache-ref 。

cache标签用于声明这个namespace使用二级缓存，并且可以自定义配置。 `<cache/>   `

- `type`：cache使用的类型，默认是`PerpetualCache`，这在一级缓存中提到过。
- `eviction`： 定义回收的策略，常见的有FIFO，LRU。
- `flushInterval`： 配置一定时间自动刷新缓存，单位是毫秒。
- `size`： 最多缓存对象的个数。
- `readOnly`： 是否只读，若配置可读写，则需要对应的实体类能够序列化。
- `blocking`： 若缓存中找不到对应的key，是否会一直blocking，直到有对应的数据进入缓存。

3. `cache-ref`代表引用别的命名空间的Cache配置，两个命名空间的操作使用的是同一个Cache。`<cache-ref namespace="mapper.StudentMapper"/>`

## 二级缓存测试

### 测试1

测试二级缓存效果，不提交事务，`sqlSession1`查询完数据后，`sqlSession2`相同的查询是否会从缓存中获取数据。

```java
public static void main(String[] args) throws IOException {
    SqlSessionFactory sessionFactory = getSqoSessionFactory();
    try (SqlSession session = sessionFactory.openSession(true);
         SqlSession session2 = sessionFactory.openSession(true)) {
        BlogAuthorMapper mapper = session.getMapper(BlogAuthorMapper.class);
        BlogAuthorMapper mapper2 = session2.getMapper(BlogAuthorMapper.class);
        BlogAuthor author = mapper.getBlogAuthorById(1L);
        System.out.println(JSON.toJSONString(author));
        BlogAuthor author1 = mapper2.getBlogAuthorById(1L);
        System.out.println(JSON.toJSONString(author1));
    }
}
```

执行结果：

![image-20200923095149583](mybatis_06缓存机制/image-20200923095149583.png)

结论：**当`sqlsession`没有调用`commit()`方法时，二级缓存并没有起到作用。**

### 测试2

测试二级缓存效果，当提交事务时，`sqlSession1`查询完数据后，`sqlSession2`相同的查询是否会从缓存中获取数据。

```java
private static void test2(SqlSession session, SqlSession session2) {
    BlogAuthorMapper mapper = session.getMapper(BlogAuthorMapper.class);
    BlogAuthorMapper mapper2 = session2.getMapper(BlogAuthorMapper.class);
    BlogAuthor author = mapper.getBlogAuthorById(1L);
    System.out.println(JSON.toJSONString(author));
    session.commit();
    BlogAuthor author1 = mapper2.getBlogAuthorById(1L);
    System.out.println(JSON.toJSONString(author1));
}
```



执行结果：

![image-20200923095558861](mybatis_06缓存机制/image-20200923095558861.png)

结论：第一个session 的事物提交时，二级缓存生效，而且缓存的命中率是0.5

### 测试3

测试`update`操作是否会刷新该`namespace`下的二级缓存。

```java
/**
     * 数据更新后,提交事务,则二级缓存失效
     * @throws IOException
     */
    private static void test3() throws IOException {
        SqlSessionFactory sessionFactory = getSqoSessionFactory();
        try (SqlSession session = sessionFactory.openSession(true);
             SqlSession session2 = sessionFactory.openSession(true);
             SqlSession session3 = sessionFactory.openSession(true)) {
            BlogAuthorMapper mapper = session.getMapper(BlogAuthorMapper.class);
            BlogAuthorMapper mapper2 = session2.getMapper(BlogAuthorMapper.class);
            BlogAuthorMapper mapper3 = session3.getMapper(BlogAuthorMapper.class);
            BlogAuthor author = mapper.getBlogAuthorById(1L);
            System.out.println(JSON.toJSONString(author));
            session.commit();
            BlogAuthor author3 = new BlogAuthor();
            author3.setId(2L);
            author3.setName("王五");
            mapper3.updateById(author3);
            session3.commit();
            BlogAuthor author1 = mapper2.getBlogAuthorById(1L);
            System.out.println(JSON.toJSONString(author1));
        }
    }
```



执行结果

![image-20200923101043505](mybatis_06缓存机制/image-20200923101043505.png)

结论: 在`sqlSession3`更新数据库，并提交事务后，`sqlsession2`的`StudentMapper namespace`下的查询走了数据库，没有走Cache。

### 测试4

验证MyBatis的二级缓存不适应用于映射文件中存在多表查询的情况。

通常我们会为每个单表创建单独的映射文件，由于**MyBatis的二级缓存是基于`namespace`的**，多表查询语句所在的`namspace`无法感应到其他`namespace`中的语句对多表查询中涉及的表进行的修改，引发脏数据问题。

```java
private static void test4() throws IOException {
    SqlSessionFactory sessionFactory = getSqoSessionFactory();
    try (SqlSession session = sessionFactory.openSession(true);
         SqlSession session2 = sessionFactory.openSession(true);
         SqlSession session3 = sessionFactory.openSession(true)) {
        BlogAuthorMapper authorMapper = session.getMapper(BlogAuthorMapper.class);
        BlogAuthorMapper authorMapper2 = session2.getMapper(BlogAuthorMapper.class);
        BlogMapper blogMapper = session3.getMapper(BlogMapper.class);
        BlogAuthor author = authorMapper.getAuthorWithBlog(1L);
        System.out.println("authorMapper:"+JSON.toJSONString(author));
        session.close();
        AuthorWithBlog authorWithBlog = authorMapper2.getAuthorWithBlog(1L);
        System.out.println("authorMapper2:" + JSON.toJSONString(authorWithBlog));
        //blogMapper插入没有二级缓存的 blog
        insertBlog(blogMapper);
        session3.commit();
        //第二次重复读取
        AuthorWithBlog authorWithBlog2 = authorMapper2.getAuthorWithBlog(1L);
        System.out.println("authorMapper2:" + JSON.toJSONString(authorWithBlog2));
    }
}
```



执行结果

![image-20200924091327402](mybatis_06缓存机制/image-20200924091327402.png)

总结:

当`sqlsession1`的`authorMapper `查询数据后，二级缓存生效,保存在authorMapper 的namespace下的cache中.当`sqlSession3`的`blogMapper`的`insertBlog`方法对blog表进行更新时，`insertBlog`不属于`authorMapper `的`namespace`，所以`authorMapper `下的cache没有感应到变化，没有刷新缓存.当`authorMapper`中同样的查询再次发起时，从缓存中读取了脏数据。

##### 踩坑

#### 异常: Error instantiating class com.zbcn.mybatis.vo.AuthorWithBlog with invalid types (List) or values (1). Cause: java.lang.IllegalArgumentException: argument type mismatch

原因:

1. Bean函数中的get/set方法与成员变量不一。
2. 构造函数被重载过，但是没有空的构造函数。

### 测试5

为了解决实验4的问题呢，可以使用Cache ref，让`blogMapper`引用`authorMapper`命名空间，这样两个映射文件对应的SQL操作都使用的是同一块缓存了。

在 BlogMapper.xml 中添加 `<cache-ref namespace="com.zbcn.mybatis.mapper.xml.BlogAuthorMapper"/>`

执行结果：

![image-20200924092330960](mybatis_06缓存机制/image-20200924092330960.png)

不过这样做的后果是，缓存的粒度变粗了，多个`Mapper namespace`下的所有操作都会对缓存使用造成影响。

### 二级缓存源码分析

源码分析从`CachingExecutor`的`query`方法展开,`CachingExecutor`的`query`方法，首先会从`MappedStatement`中获得在配置初始化时赋予的Cache。

```java
Cache cache = ms.getCache();
```

本质上是装饰器模式的使用，具体的装饰链是：

> SynchronizedCache -> LoggingCache -> SerializedCache -> LruCache -> PerpetualCache。

![img](mybatis_06缓存机制/1f5233b2.jpg)

以下是具体这些Cache实现类的介绍，他们的组合为Cache赋予了不同的能力。

- `SynchronizedCache`：同步Cache，实现比较简单，直接使用synchronized修饰方法。
- `LoggingCache`：日志功能，装饰类，用于记录缓存的命中率，如果开启了DEBUG模式，则会输出命中率日志。
- `SerializedCache`：序列化功能，将值序列化后存到缓存中。该功能用于缓存返回一份实例的Copy，用于保存线程安全。
- `LruCache`：采用了Lru算法的Cache实现，移除最近最少使用的Key/Value。
- `PerpetualCache`： 作为为最基础的缓存类，底层实现比较简单，直接使用了HashMap。

然后是判断是否需要刷新缓存，代码如下所示：

```java
flushCacheIfRequired(ms);
```

在默认的设置中`SELECT`语句不会刷新缓存，`insert/update/delte`会刷新缓存。进入该方法。代码如下所示：

```java
 private void flushCacheIfRequired(MappedStatement ms) {
    Cache cache = ms.getCache();
    if (cache != null && ms.isFlushCacheRequired()) {
      tcm.clear(cache);
    }
  }
```

MyBatis的`CachingExecutor`持有了`TransactionalCacheManager`，即上述代码中的tcm。

`TransactionalCacheManager`中持有了一个Map，代码如下所示：

```java
private Map<Cache, TransactionalCache> transactionalCaches = new HashMap<>();
```

这个Map保存了Cache和用`TransactionalCache`包装后的Cache的映射关系。

`TransactionalCache`实现了Cache接口，`CachingExecutor`会默认使用他包装初始生成的Cache，，作用是 **如果事务提交，对缓存的操作才会生效，如果事务回滚或者不提交事务，则不对缓存产生影响**。

在`TransactionalCache`的clear，有以下两句。清空了需要在提交时加入缓存的列表，同时设定提交时清空缓存，代码如下所示：

```java
@Override
public void clear() {
	clearOnCommit = true;
	entriesToAddOnCommit.clear();
}
```

`achingExecutor`继续往下走，`ensureNoOutParams`主要是用来处理存储过程的，暂时不用考虑。

```java
if (ms.isUseCache() && resultHandler == null) {
	ensureNoOutParams(ms, parameterObject, boundSql);
```

之后会尝试从tcm中获取缓存的列表

```java
List<E> list = (List<E>) tcm.getObject(cache, key);
```

在`getObject`方法中，会把获取值的职责一路传递，最终到`PerpetualCache`。如果没有查到，会把key加入Miss集合，这个主要是为了统计命中率。

```java
Object object = delegate.getObject(key);
if (object == null) {
	entriesMissedInCache.add(key);
}
```

`CachingExecutor`继续往下走，如果查询到数据，则调用`tcm.putObject`方法，往缓存中放入值。

```java
if (list == null) {
	list = delegate.<E> query(ms, parameterObject, rowBounds, resultHandler, key, boundSql);
	tcm.putObject(cache, key, list); // issue #578 and #116
}
```

tcm的`put`方法也不是直接操作缓存，只是在把这次的数据和key放入待提交的Map中。

```java
@Override
public void putObject(Object key, Object object) {
    entriesToAddOnCommit.put(key, object);
}
```

从以上的代码分析中，我们可以明白，如果不调用`commit`方法的话，由于`TranscationalCache`的作用，并不会对二级缓存造成直接的影响。因此我们看看`Sqlsession`的`commit`方法中做了什么。代码如下所示：

```java
@Override
public void commit(boolean force) {
    try {
      executor.commit(isCommitOrRollbackRequired(force));
```

因为我们使用了CachingExecutor，首先会进入CachingExecutor实现的commit方法。

```java
@Override
public void commit(boolean required) throws SQLException {
    delegate.commit(required);
    tcm.commit();
}
```

会把具体commit的职责委托给包装的`Executor`。主要是看下`tcm.commit()`，tcm最终又会调用到`TrancationalCache`。

```java
public void commit() {
    if (clearOnCommit) {
      delegate.clear();
    }
    flushPendingEntries();
    reset();
}
```

看到这里的`clearOnCommit`就想起刚才`TrancationalCache`的`clear`方法设置的标志位，真正的清理Cache是放到这里来进行的。具体清理的职责委托给了包装的Cache类。之后进入`flushPendingEntries`方法。代码如下所示：

```java
private void flushPendingEntries() {
    for (Map.Entry<Object, Object> entry : entriesToAddOnCommit.entrySet()) {
      delegate.putObject(entry.getKey(), entry.getValue());
    }
    ................
}
```

​	在`flushPendingEntries`中，将待提交的Map进行循环处理，委托给包装的Cache类，进行`putObject`的操作。

后续的查询操作会重复执行这套流程。如果是`insert|update|delete`的话，会统一进入`CachingExecutor`的`update`方法，其中调用了这个函数，代码如下所示：

```java
private void flushCacheIfRequired(MappedStatement ms) 
```

在二级缓存执行流程后就会进入一级缓存的执行流程，因此不再赘述。

### 总结

1.  MyBatis的二级缓存相对于一级缓存来说，实现了`SqlSession`之间缓存数据的共享，同时粒度更加的细，能够到`namespace`级别，通过Cache接口实现类不同的组合，对Cache的可控性也更强。
2.  MyBatis在多表查询时，极大可能会出现脏数据，有设计上的缺陷，安全使用二级缓存的条件比较苛刻。
3.  在分布式环境下，由于默认的MyBatis Cache实现都是基于本地的，分布式环境下必然会出现读取到脏数据，需要使用集中式缓存将MyBatis的Cache接口实现，有一定的开发成本，直接使用Redis、Memcached等分布式缓存可能成本更低，安全性也更高。

# 全文总结

本文对介绍了MyBatis一二级缓存的基本概念，并从应用及源码的角度对MyBatis的缓存机制进行了分析。最后对MyBatis缓存机制做了一定的总结，个人建议MyBatis缓存特性在生产环境中进行关闭，单纯作为一个ORM框架使用可能更为合适。



## 参考

- https://tech.meituan.com/2018/01/19/mybatis-cache.html

