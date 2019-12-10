---
title: myBatis 01.基本说明
date: 2019-10-07 13:14:10
tags:
 - mybatis
 - sql
categories:
 - mybatis
 - 基本说明
topdeclare: true
reward: true
---
### myBatis 01.基本说明 ###

#### 关键类:
- SqlSessionFactoryBuilder:
  - 作用:创建 ` SqlSessionFactory`, 一旦创建后,就再不需要了 `SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(configuration);`
  - 作用域: 方法作用域（也就是局部方法变量）

<!--more-->

- SqlSessionFactory:
  - 作用: 获取 `SqlSession` , `SqlSession session = sqlSessionFactory.openSession()`
  - 作用域:最简单的就是使用单例模式或者静态单例模式(使用 SqlSessionFactory 的最佳实践是在应用运行期间不要重复创建多次，多次重建 SqlSessionFactory 被视为一种代码“坏味道（bad smell）)

- SqlSession
  - 作用: 执行 SQL 语句
    ```java
    BlogMapper mapper = session.getMapper(BlogMapper.class);
    Blog blog = mapper.selectBlog(101);
    ```
  - 作用域：请求或方法作用域（如果你现在正在使用一种 Web 框架，要考虑 SqlSession 放在一个和 HTTP 请求对象相似的作用域中。 换句话说，每次收到的 HTTP 请求，就可以打开一个 SqlSession，返回一个响应，就关闭它）  
    要保证 使用后一定要关闭：
    ```java
    try (SqlSession session = sqlSessionFactory.openSession()) {
        BlogMapper mapper = session.getMapper(BlogMapper.class);
        // 你的应用逻辑代码
    }
    ```

#### mybatis-config 配置结构：

  ```
  configuration（配置）
    ->properties（属性）
    ->settings（设置）
    ->typeAliases（类型别名）
    ->typeHandlers（类型处理器）
    ->objectFactory（对象工厂）
    ->plugins（插件）
    ->environments（环境配置）
       ->environment（环境变量）
       ->transactionManager（事务管理器）
       ->dataSource（数据源）
    ->databaseIdProvider（数据库厂商标识）
    ->mappers（映射器）

  ```

  1. properties（属性）： 可外部配置或者可动态替换的。既可以在典型的 Java 属性文件中配置，亦可通过 properties 元素的子元素来传递
    - 实例:  
    ```xml
    <properties resource="org/mybatis/example/config.properties">
      <property name="username" value="dev_user"/>
      <property name="password" value="F2Fa3!33TYyg"/>
    </properties>
    <!--然后其中的属性就可以在整个配置文件中被用来替换需要动态配置的属性值：
      这个例子中的 username 和 password 将会由 properties 元素中设置的相应值来替换。 driver 和 url 属性将会由 config.properties 文件中对应的值来替换-->
    <dataSource type="POOLED">
      <property name="driver" value="${driver}"/>
      <property name="url" value="${url}"/>
      <property name="username" value="${username}"/>
      <property name="password" value="${password}"/>
    </dataSource>

    ```

    - 加载顺序：通过方法参数传递的属性具有最高优先级，resource/url 属性中指定的配置文件次之，最低优先级的是 properties 属性中指定的属性
    - 占位符：
      ```xml
      <dataSource type="POOLED">
        <!-- ... -->
        <property name="username" value="${username:ut_user}"/> <!-- 如果属性 'username' 没有被配置，'username' 属性的值将为 'ut_user' -->
      </dataSource>
      ```
    - 开启占位符：
      ```xml
      <properties resource="org/mybatis/example/config.properties">
          <!-- ... -->
          <property name="org.apache.ibatis.parsing.PropertyParser.enable-default-value" value="true"/> <!-- 启用默认值特性 -->
      </properties>
      ```
    - 修改默认值分割符：
      ```xml
      <!--修改-->
      <properties resource="org/mybatis/example/config.properties">
        <!-- ... -->
        <property name="org.apache.ibatis.parsing.PropertyParser.default-value-separator" value="?:"/> <!-- 修改默认值的分隔符 -->
      </properties>

      <!--使用-->
      <dataSource type="POOLED">
        <!-- ... -->
        <property name="username" value="${db:username?:ut_user}"/>
      </dataSource>
      ```

  2. 设置（settings）

      ```xml
      <settings>
        <!--全局地开启或关闭配置文件中的所有映射器已经配置的任何缓存。默认 true-->
        <setting name="cacheEnabled" value="true"/>
        <!--延迟加载的全局开关。当开启时，所有关联对象都会延迟加载。 特定关联关系中可通过设置 fetchType 属性来覆盖该项的开关状态。默认false-->
        <setting name="lazyLoadingEnabled" value="true"/>
        <!--是否允许单一语句返回多结果集（需要驱动支持） 默认true-->
        <setting name="multipleResultSetsEnabled" value="true"/>
        <!--使用列标签代替列名。不同的驱动在这方面会有不同的表现，具体可参考相关驱动文档或通过测试这两种不同的模式来观察所用驱动的结果。默认true -->
        <setting name="useColumnLabel" value="true"/>
        <!-- 允许 JDBC 支持自动生成主键，需要驱动支持。 如果设置为 true 则这个设置强制使用自动生成主键，尽管一些驱动不能支持但仍可正常工作（比如 Derby） 默认false-->
        <setting name="useGeneratedKeys" value="false"/>
        <!--指定 MyBatis 应如何自动映射列到字段或属性。 NONE 表示取消自动映射；PARTIAL 只会自动映射没有定义嵌套结果集映射的结果集。 FULL 会自动映射任意复杂的结果集（无论是否嵌套）。 默认 PARTIAL-->
        <setting name="autoMappingBehavior" value="PARTIAL"/>
        <!-- 指定发现自动映射目标未知列（或者未知属性类型）的行为。
NONE: 不做任何反应
WARNING: 输出提醒日志 ('org.apache.ibatis.session.AutoMappingUnknownColumnBehavior' 的日志等级必须设置为 WARN)
FAILING: 映射失败 (抛出 SqlSessionException) 默认 NOTE -->
        <setting name="autoMappingUnknownColumnBehavior" value="WARNING"/>
        <!--配置默认的执行器。SIMPLE 就是普通的执行器；REUSE 执行器会重用预处理语句（prepared statements）； BATCH 执行器将重用语句并执行批量更新  默认 SIMPLE-->
        <setting name="defaultExecutorType" value="SIMPLE"/>
        <!-- 设置超时时间，它决定驱动等待数据库响应的秒数。 默认 null-->
        <setting name="defaultStatementTimeout" value="25"/>
        <!--为驱动的结果集获取数量（fetchSize）设置一个提示值。此参数只可以在查询设置中被覆盖。 默认 null -->
        <setting name="defaultFetchSize" value="100"/>
        <!-- 允许在嵌套语句中使用分页（RowBounds）。如果允许使用则设置为 false。 默认 false-->
        <setting name="safeRowBoundsEnabled" value="false"/>
        <!--是否开启自动驼峰命名规则（camel case）映射，即从经典数据库列名 A_COLUMN 到经典 Java 属性名 aColumn 的类似映射。 默认 false -->
        <setting name="mapUnderscoreToCamelCase" value="false"/>
        <!--MyBatis 利用本地缓存机制（Local Cache）防止循环引用（circular references）和加速重复嵌套查询。 默认值为 SESSION，这种情况下会缓存一个会话中执行的所有查询。 若设置值为 STATEMENT，本地会话仅用在语句执行上，对相同 SqlSession 的不同调用将不会共享数据。 -->
        <setting name="localCacheScope" value="SESSION"/>
        <!-- 当没有为参数提供特定的 JDBC 类型时，为空值指定 JDBC 类型。 某些驱动需要指定列的 JDBC 类型，多数情况直接用一般类型即可，比如 NULL、VARCHAR 或 OTHER。 默认null-->
        <setting name="jdbcTypeForNull" value="OTHER"/>
        <!--指定哪个对象的方法触发一次延迟加载。 -->
        <setting name="lazyLoadTriggerMethods" value="equals,clone,hashCode,toString"/>
      </settings>

      ```
  3. 类型别名（typeAliases）:类型别名是为 Java 类型设置一个短的名字。 它只和 XML 配置有关，存在的意义仅在于用来减少类完全限定名的冗余
    ```xml
    <typeAliases>
      <typeAlias alias="Author" type="domain.blog.Author"/>
      <typeAlias alias="Blog" type="domain.blog.Blog"/>
      <typeAlias alias="Comment" type="domain.blog.Comment"/>
      <typeAlias alias="Post" type="domain.blog.Post"/>
      <typeAlias alias="Section" type="domain.blog.Section"/>
      <typeAlias alias="Tag" type="domain.blog.Tag"/>
      <!--也可以指定一个包名-->
      <package name="domain.blog"/>
    </typeAliases>
    ```

    - 若有注解，则别名为其注解值
      ```java
      @Alias("author")
      public class Author {
          ...
      }
      ```
  4. 类型处理器（typeHandlers）
   - 数据库数据类型和 java 数据类型转换.
   - 可以自定义转换:具体做法为：实现 org.apache.ibatis.type.TypeHandler 接口， 或继承一个很便利的类 org.apache.ibatis.type.BaseTypeHandler， 然后可以选择性地将它映射到一个 JDBC 类型。比如：
    ```java
    // ExampleTypeHandler.java
    @MappedJdbcTypes(JdbcType.VARCHAR)
    public class ExampleTypeHandler extends BaseTypeHandler<String> {

      @Override
      public void setNonNullParameter(PreparedStatement ps, int i, String parameter, JdbcType jdbcType) throws SQLException {
        ps.setString(i, parameter);
      }

      @Override
      public String getNullableResult(ResultSet rs, String columnName) throws SQLException {
        return rs.getString(columnName);
      }

      @Override
      public String getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        return rs.getString(columnIndex);
      }

      @Override
      public String getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        return cs.getString(columnIndex);
      }
    }

    ```
    ```xml
    <!-- mybatis-config.xml -->
    <typeHandlers>
      <typeHandler handler="org.mybatis.example.ExampleTypeHandler"/>
    </typeHandlers>
    ```
  5. 处理枚举类型

  6. 对象工厂（objectFactory）:MyBatis 每次创建结果对象的新实例时，它都会使用一个对象工厂（ObjectFactory）实例来完成

  7. 插件（plugins）
    - MyBatis 允许你在已映射语句执行过程中的某一点进行拦截调用。默认情况下，MyBatis 允许使用插件来拦截的方法调用包括：
      ```
      Executor (update, query, flushStatements, commit, rollback, getTransaction, close, isClosed)
      ParameterHandler (getParameterObject, setParameters)
      ResultSetHandler (handleResultSets, handleOutputParameters)
      StatementHandler (prepare, parameterize, batch, update, query)
      ```
  8. 环境配置（environments）:MyBatis 可以配置成适应多种环境，这种机制有助于将 SQL 映射应用于多种数据库之中
    ```xml
    <environments default="development">
      <environment id="development">
        <transactionManager type="JDBC">
          <property name="..." value="..."/>
        </transactionManager>
        <dataSource type="POOLED">
          <property name="driver" value="${driver}"/>
          <property name="url" value="${url}"/>
          <property name="username" value="${username}"/>
          <property name="password" value="${password}"/>
        </dataSource>
      </environment>
    </environments>
    ```

    * 默认使用的环境 ID（比如：default="development"）。
    * 每个 environment 元素定义的环境 ID（比如：id="development"）。
    * 事务管理器的配置（比如：type="JDBC"）。
    * 数据源的配置（比如：type="POOLED"）

  9. 事务管理器（transactionManager）  
  mybatis 中有两种事务管理器:
  - DBC – 这个配置就是直接使用了 JDBC 的提交和回滚设置，它依赖于从数据源得到的连接来管理事务作用域。
  - MANAGED – 这个配置几乎没做什么。它从来不提交或回滚一个连接，而是让容器来管理事务的整个生命周期（比如 JEE 应用服务器的上下文）。 默认情况下它会关闭连接，然而一些容器并不希望这样，因此需要将 closeConnection 属性设置为 false 来阻止它默认的关闭行为。

  __注:__ 如果你正在使用 Spring + MyBatis，则没有必要配置事务管理器， 因为 Spring 模块会使用自带的管理器来覆盖前面的配置。

  10. 数据源（dataSource）  
  三种内建数据源: `UNPOOLED|POOLED|JNDI`
  - `UNPOOLED` :个数据源的实现只是每次被请求时打开和关闭连接.
  - `POOLED`:这种数据源的实现利用“池”的概念将 JDBC 连接对象组织起来，避免了创建新的连接实例时所必需的初始化和认证时间。 这是一种使得并发 Web 应用快速响应请求的流行处理方式。
  - `JNDI`:这个数据源的实现是为了能在如 EJB 或应用服务器这类容器中使用，容器可以集中或在外部配置数据源，然后放置一个 JNDI 上下文的引用。

  11. 数据库厂商标识（databaseIdProvider）  
  MyBatis 可以根据不同的数据库厂商执行不同的语句，这种多厂商的支持是基于映射语句中的 databaseId 属性
  ```xml
  <databaseIdProvider type="DB_VENDOR">
    <property name="SQL Server" value="sqlserver"/>
    <property name="DB2" value="db2"/>
    <property name="Oracle" value="oracle" />
  </databaseIdProvider>
  ```
  12. 映射器（mappers）  
  需要告诉 MyBatis 到哪里去找到这些语句。 Java 在自动查找这方面没有提供一个很好的方法，所以最佳的方式是告诉 MyBatis 到哪里去找映射文件。 你可以使用相对于类路径的资源引用， 或完全限定资源定位符（包括 file:/// 的 URL），或类名和包名等。

  ```xml
  <!-- 使用相对于类路径的资源引用 -->
  <mappers>
    <mapper resource="org/mybatis/builder/AuthorMapper.xml"/>
    <mapper resource="org/mybatis/builder/BlogMapper.xml"/>
    <mapper resource="org/mybatis/builder/PostMapper.xml"/>
  </mappers>

  <!-- 使用完全限定资源定位符（URL） -->
  <mappers>
    <mapper url="file:///var/mappers/AuthorMapper.xml"/>
    <mapper url="file:///var/mappers/BlogMapper.xml"/>
    <mapper url="file:///var/mappers/PostMapper.xml"/>
  </mappers>

  <!-- 使用映射器接口实现类的完全限定类名 -->
  <mappers>
    <mapper class="org.mybatis.builder.AuthorMapper"/>
    <mapper class="org.mybatis.builder.BlogMapper"/>
    <mapper class="org.mybatis.builder.PostMapper"/>
  </mappers>

  <!-- 将包内的映射器接口实现全部注册为映射器 -->
  <mappers>
    <package name="org.mybatis.builder"/>
  </mappers>
  ```
