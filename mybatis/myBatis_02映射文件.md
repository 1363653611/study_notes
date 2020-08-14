---
title: 02.MyBatis 映射文件
date: 2019-10-8 13:14:10
tags:
 - mybatis
 - sql
categories:
 - mybatis
 - 动态sql
topdeclare: true
reward: true
---
### xml 映射文件

#### 映射 文件的顶级元素
- cache 给定命名空间的缓存配置
- cache-ref 对其他命名空间的缓存引用
- resultMap 最复杂也是最强大的.描述如合从数据库结果中加载对象
- sql 可被其他语句引用的可重用的语句块.
- insert 插入语句
- update 更新语句
- delete 删除语句
- select 选择语句

<!--more-->

#### select 语句
- 属性分析
```xml
<select
  id="selectPerson" //在命名空间中唯一的标识符，可以被用来引用这条语句。
  parameterType="int" //将会传入这条语句的参数类的完全限定名或别名。这个属性是可选的，因为 MyBatis 可以通过类型处理器（TypeHandler） 推断出具体传入语句的参数，默认值为未设置（unset）。
  parameterMap="deprecated"// 弃用
  resultType="hashmap"//从这条语句中返回的期望类型的类的完全限定名或别名。 注意如果返回的是集合，那应该设置为集合包含的类型，而不是集合本身。可以使用 resultType 或 resultMap，但不能同时使用。
  resultMap="personResultMap"//外部 resultMap 的命名引用。结果集的映射是 MyBatis 最强大的特性，如果你对其理解透彻，许多复杂映射的情形都能迎刃而解。可以使用 resultMap 或 resultType，但不能同时使用。
  flushCache="false" //将其设置为 true 后，只要语句被调用，都会导致本地缓存和二级缓存被清空，默认值：false。
  useCache="true"//将其设置为 true 后，将会导致本条语句的结果被二级缓存缓存起来，默认值：对 select 元素为 true。
  timeout="10"//这个设置是在抛出异常之前，驱动程序等待数据库返回请求结果的秒数。默认值为未设置（unset）（依赖驱动）
  fetchSize="256" //这是一个给驱动的提示，尝试让驱动程序每次批量返回的结果行数和这个设置值相等。 默认值为未设置（unset）（依赖驱动）
  statementType="PREPARED" //STATEMENT，PREPARED 或 CALLABLE 中的一个。这会让 MyBatis 分别使用 Statement，PreparedStatement 或 CallableStatement，默认值：PREPARED。
  resultSetType="FORWARD_ONLY"> //STATEMENT，PREPARED 或 CALLABLE 中的一个。这会让 MyBatis 分别使用 Statement，PreparedStatement 或 CallableStatement，默认值：PREPARED。
```


#### insert, update 和 delete

```xml
<insert
  id="insertAuthor" //	命名空间中的唯一标识符，可被用来代表这条语句。
  parameterType="domain.blog.Author" //将要传入语句的参数的完全限定类名或别名。这个属性是可选的，因为 MyBatis 可以通过类型处理器推断出具体传入语句的参数，默认值为未设置（unset）
  flushCache="true" //将其设置为 true 后，只要语句被调用，都会导致本地缓存和二级缓存被清空，默认值：true（对于 insert、update 和 delete 语句）。
  statementType="PREPARED" //TATEMENT，PREPARED 或 CALLABLE 的一个。这会让 MyBatis 分别使用 Statement，PreparedStatement 或 CallableStatement，默认值：PREPARED。
  keyProperty=""//仅对 insert 和 update 有用）唯一标记一个属性，MyBatis 会通过 getGeneratedKeys 的返回值或者通过 insert 语句的 selectKey 子元素设置它的键值，默认值：未设置（unset）。如果希望得到多个生成的列，也可以是逗号分隔的属性名称列表。
  keyColumn="" //仅对 insert 和 update 有用）通过生成的键值设置表中的列名，这个设置仅在某些数据库（像 PostgreSQL）是必须的，当主键列不是表中的第一列的时候需要设置。如果希望使用多个生成的列，也可以设置为逗号分隔的属性名称列表。
  useGeneratedKeys="" //(仅对 insert 和 update 有用）这会令 MyBatis 使用 JDBC 的 getGeneratedKeys 方法来取出由数据库内部生成的主键（比如：像 MySQL 和 SQL Server 这样的关系数据库管理系统的自动递增字段），默认值：false。
  timeout="20">

<update
  id="updateAuthor"
  parameterType="domain.blog.Author"
  flushCache="true"
  statementType="PREPARED"
  timeout="20">

<delete
  id="deleteAuthor"
  parameterType="domain.blog.Author"
  flushCache="true"
  statementType="PREPARED"
  timeout="20">
```

#### 复杂的带 `selectKey`

```xml
<insert id="insertAuthor">
  <selectKey keyProperty="id" resultType="int" order="BEFORE">
    select CAST(RANDOM()*1000000 as INTEGER) a from SYSIBM.SYSDUMMY1
  </selectKey>
  insert into Author
    (id, username, password, email,bio, favourite_section)
  values
    (#{id}, #{username}, #{password}, #{email}, #{bio}, #{favouriteSection,jdbcType=VARCHAR})
</insert>
```

在上面的示例中，selectKey 元素中的语句将会首先运行，Author 的 id 会被设置，然后插入语句会被调用。这可以提供给你一个与数据库中自动生成主键类似的行为，同时保持了 Java 代码的简洁。
- selectKey 元素描述
 ```xml
 <selectKey
  keyProperty="id" //selectKey 语句结果应该被设置的目标属性。如果希望得到多个生成的列，也可以是逗号分隔的属性名称列表。
  resultType="int"  //结果的类型。MyBatis 通常可以推断出来，但是为了更加精确，写上也不会有什么问题。MyBatis 允许将任何简单类型用作主键的类型，包括字符串。如果希望作用于多个生成的列，则可以使用一个包含期望属性的 Object 或一个 Map。
  resultColumn = "name" //匹配属性的返回结果集中的列名称。如果希望得到多个生成的列，也可以是逗号分隔的属性名称列表。
  order="BEFORE" //这可以被设置为 BEFORE 或 AFTER。如果设置为 BEFORE，那么它会首先生成主键，设置 keyProperty 然后执行插入语句。如果设置为 AFTER，那么先执行插入语句，然后是 selectKey 中的语句 - 这和 Oracle 数据库的行为相似，在插入语句内部可能有嵌入索引调用。
  statementType="PREPARED"> //与前面相同，MyBatis 支持 STATEMENT，PREPARED 和 CALLABLE 语句的映射类型，分别代表 PreparedStatement 和 CallableStatement 类型。

 ```

#### sql
这个元素可以被用来定义可重用的 SQL 代码段，这些 SQL 代码可以被包含在其他语句中。它可以（在加载的时候）被静态地设置参数。 在不同的包含语句中可以设置不同的值到参数占位符上。
```xml
<!--定义-->
<sql id="userColumns"> ${alias}.id,${alias}.username,${alias}.password </sql>
<!--使用-->
<select id="selectUsers" resultType="map">
  select
    <include refid="userColumns"><property name="alias" value="t1"/></include>,
    <include refid="userColumns"><property name="alias" value="t2"/></include>
  from some_table t1
    cross join some_table t2
</select>

<!--属性值也可以被用在 include 元素的 refid 属性里或 include 元素的内部语句中-->

<sql id="sometable">
  ${prefix}Table
</sql>

<sql id="someinclude">
  from
    <include refid="${include_target}"/>
</sql>

<select id="select" resultType="map">
  select
    field1, field2, field3
  <include refid="someinclude">
    <property name="prefix" value="Some"/>
    <property name="include_target" value="sometable"/>
  </include>
</select>
```
#### 参数 (#{...})
像 MyBatis 的其它部分一样，javaType 几乎总是可以根据参数对象的类型确定下来，除非该对象是一个 HashMap。这个时候，你需要显式指定 javaType 来确保正确的类型处理器（TypeHandler）被使用。  

__提示:__
- JDBC 要求，如果一个列允许 null 值，并且会传递值 null 的参数，就必须要指定 JDBC Type。
- 要更进一步地自定义类型处理方式，你也可以指定一个特殊的类型处理器类（或别名）`#{age,javaType=int,jdbcType=NUMERIC,typeHandler=MyTypeHandler}`
- 对于数值类型，还有一个小数保留位数的设置，来指定小数点后保留的位数。`#{height,javaType=double,jdbcType=NUMERIC,numericScale=2}`

#### 字符串替换 (${...})
默认情况下,使用 #{} 格式的语法会导致 MyBatis 创建 PreparedStatement 参数占位符并安全地设置参数（就像使用 ? 一样）。 这样做更安全，更迅速，通常也是首选做法，不过有时你就是想直接在 SQL 语句中插入一个不转义的字符串。 比如，像 ORDER BY，你可以这样来使用:`ORDER BY ${columnName}`.这里 MyBatis 不会修改或转义字符串。
__提示__: 用这种方式接受用户的输入，并将其用于语句中的参数是不安全的，会导致潜在的 SQL 注入攻击，因此要么不允许用户输入这些字段，要么自行转义并检验。

#### 结果映射
resultMap 元素是 MyBatis 中最重要最强大的元素。它可以让你从 90% 的 JDBC ResultSets 数据提取代码中解放出来，并在一些情形下允许你进行一些 JDBC 不支持的操作.ResultMap 的设计思想是，对于简单的语句根本不需要配置显式的结果映射，而对于复杂一点的语句只需要描述它们的关系就行了.

- 不需要resultMap   
  * 数据库列名和 java 实体类属性名称一致

  ```xml
  <select id="selectUsers" resultType="com.someapp.model.User">
    select id, username, hashedPassword
    from some_table
    where id = #{id}
  </select>

  <!--类型别名是你的好帮手。使用它们，你就可以不用输入类的完全限定名称了-->
  <!-- mybatis-config.xml 中 -->
  <typeAlias type="com.someapp.model.User" alias="User"/>

  <!-- SQL 映射 XML 中 -->
  <select id="selectUsers" resultType="User">
    select id, username, hashedPassword
    from some_table
    where id = #{id}
  </select>
  ```

  * 数据库列名和 java 实体类属性名称不一致:

  ```xml
  <select id="selectUsers" resultType="User">
    select
      user_id             as "id",
      user_name           as "userName",
      hashed_password     as "hashedPassword"
    from some_table
    where id = #{id}
  </select>
  ```

- 使用 resultMap:

```xml
<resultMap id="userResultMap" type="User">
  <id property="id" column="user_id" />
  <result property="username" column="user_name"/>
  <result property="password" column="hashed_password"/>
</resultMap>

<!--引用它的语句中使用 resultMap 属性就行了 注意去掉 resultType-->
<select id="selectUsers" resultMap="userResultMap">
  select user_id, user_name, hashed_password
  from some_table
  where id = #{id}
</select>
```

#### 高级结果映射

复杂 sql 语句:
```xml
<!-- 非常复杂的语句 -->
<select id="selectBlogDetails" resultMap="detailedBlogResultMap">
  select
       B.id as blog_id,
       B.title as blog_title,
       B.author_id as blog_author_id,
       A.id as author_id,
       A.username as author_username,
       A.password as author_password,
       A.email as author_email,
       A.bio as author_bio,
       A.favourite_section as author_favourite_section,
       P.id as post_id,
       P.blog_id as post_blog_id,
       P.author_id as post_author_id,
       P.created_on as post_created_on,
       P.section as post_section,
       P.subject as post_subject,
       P.draft as draft,
       P.body as post_body,
       C.id as comment_id,
       C.post_id as comment_post_id,
       C.name as comment_name,
       C.comment as comment_text,
       T.id as tag_id,
       T.name as tag_name
  from Blog B
       left outer join Author A on B.author_id = A.id
       left outer join Post P on B.id = P.blog_id
       left outer join Comment C on P.id = C.post_id
       left outer join Post_Tag PT on PT.post_id = P.id
       left outer join Tag T on PT.tag_id = T.id
  where B.id = #{id}
</select>
```
- 简化:
```xml
<!-- 非常复杂的结果映射 -->
<resultMap id="detailedBlogResultMap" type="Blog">
  <constructor>
    <idArg column="blog_id" javaType="int"/>
  </constructor>
  <result property="title" column="blog_title"/>
  <association property="author" javaType="Author">
    <id property="id" column="author_id"/>
    <result property="username" column="author_username"/>
    <result property="password" column="author_password"/>
    <result property="email" column="author_email"/>
    <result property="bio" column="author_bio"/>
    <result property="favouriteSection" column="author_favourite_section"/>
  </association>
  <collection property="posts" ofType="Post">
    <id property="id" column="post_id"/>
    <result property="subject" column="post_subject"/>
    <association property="author" javaType="Author"/>
    <collection property="comments" ofType="Comment">
      <id property="id" column="comment_id"/>
    </collection>
    <collection property="tags" ofType="Tag" >
      <id property="id" column="tag_id"/>
    </collection>
    <discriminator javaType="int" column="draft">
      <case value="1" resultType="DraftPost"/>
    </discriminator>
  </collection>
</resultMap>
```

- 结果映射（resultMap）

```
-> constructor - 用于在实例化类时，注入结果到构造方法中  
  -> idArg - ID 参数；标记出作为 ID 的结果可以帮助提高整体性能
  -> arg - 将被注入到构造方法的一个普通结果
-> id – 一个 ID 结果；标记出作为 ID 的结果可以帮助提高整体性能
-> result – 注入到字段或 JavaBean 属性的普通结果
-> association – 一个复杂类型的关联；许多结果将包装成这种类型
  -> 嵌套结果映射 – 关联本身可以是一个 resultMap 元素，或者从别处引用一个
-> collection – 一个复杂类型的集合
  -> 嵌套结果映射 – 集合本身可以是一个 resultMap 元素，或者从别处引用一个
-> discriminator – 使用结果值来决定使用哪个 resultMap
 -> case – 基于某些值的结果映射
   -> 嵌套结果映射 – case 本身可以是一个 resultMap 元素，因此可以具有相同的结构和元素，或者从别处引用一个
```

- id & result
```xml
<id property="id" column="post_id"/>
<result property="subject" column="post_subject"/>
```
这些是结果映射最基本的内容。id 和 result 元素都将一个列的值映射到一个简单数据类型（String, int, double, Date 等）的属性或字段。  
这两者之间的唯一不同是，id 元素表示的结果将是对象的标识属性，这会在比较对象实例时用到。 这样可以提高整体的性能，尤其是进行缓存和嵌套结果映射（也就是连接映射）的时候。
 - 包含的属性:
  - `property` 映射到列结果的字段或属性
  - `column` 数据库中的列名，或者是列的别名
  - `javaType` 一个 Java 类的完全限定名，或一个类型别名（关于内置的类型别名，可以参考上面的表格）
  - `jdbcType` JDBC 类型，所支持的 JDBC 类型
  - `typeHandler` 默认的类型处理器

- 构造方法 `constructor`
 - 对象:
 ```java
   public class User {
     //...
     public User(Integer id, String username, int age) {
       //...
    }
  //...
  }
 ```
 - mapper
 ```xml
   <constructor>
     <idArg column="id" javaType="int"/>
     <arg column="username" javaType="String"/>
     <arg column="age" javaType="_int"/>
  </constructor>
 ```
- 关联 `association `
```xml
<association property="author" column="blog_author_id" javaType="Author">
  <id property="id" column="author_id"/>
  <result property="username" column="author_username"/>
</association>
```

- 关联的嵌套 Select 查询  

```xml
<resultMap id="blogResult" type="Blog">
  <association property="author" column="author_id" javaType="Author" select="selectAuthor"/>
</resultMap>

<select id="selectBlog" resultMap="blogResult">
  SELECT * FROM BLOG WHERE ID = #{id}
</select>

<select id="selectAuthor" resultType="Author">
  SELECT * FROM AUTHOR WHERE ID = #{id}
</select>
```

- eg:
  - 原始:

  ```XML
  <select id="selectBlog" resultMap="blogResult">
    select
      B.id            as blog_id,
      B.title         as blog_title,
      B.author_id     as blog_author_id,
      A.id            as author_id,
      A.username      as author_username,
      A.password      as author_password,
      A.email         as author_email,
      A.bio           as author_bio
    from Blog B left outer join Author A on B.author_id = A.id
    where B.id = #{id}
  </select>
  ```
  - 优化:  

  ```xml
  <resultMap id="blogResult" type="Blog">
    <id property="id" column="blog_id" />
    <result property="title" column="blog_title"/>
    <association property="author" column="blog_author_id" javaType="Author" resultMap="authorResult"/>
  </resultMap>

  <resultMap id="authorResult" type="Author">
    <id property="id" column="author_id"/>
    <result property="username" column="author_username"/>
    <result property="password" column="author_password"/>
    <result property="email" column="author_email"/>
    <result property="bio" column="author_bio"/>
  </resultMap>
  ```

- 关联的多结果集（ResultSet）   
eg:
  - 存储过程 `getBlogsAndAuthors` 执行如下两个方法:

  ```sql
  -- 返回 Blog
  SELECT * FROM BLOG WHERE ID = #{id}

  - 返回 author
  SELECT * FROM AUTHOR WHERE ID = #{id}
  ```

  - mapper 文件:映射语句中，必须通过 resultSets 属性为每个结果集指定一个名字，多个名字使用逗号隔开。

  ```xml
  <select id="selectBlog" resultSets="blogs,authors" resultMap="blogResult" statementType="CALLABLE">
    {call getBlogsAndAuthors(#{id,jdbcType=INTEGER,mode=IN})}
  </select>
  ```
  - 现在我们可以指定使用 “authors” 结果集的数据来填充 “author” 关联
  ```xml
  <resultMap id="blogResult" type="Blog">
    <id property="id" column="id" />
    <result property="title" column="title"/>
    <association property="author" javaType="Author" resultSet="authors" column="author_id" foreignColumn="id">
      <id property="id" column="id"/>
      <result property="username" column="username"/>
      <result property="password" column="password"/>
      <result property="email" column="email"/>
      <result property="bio" column="bio"/>
    </association>
  </resultMap>
  ```
- 集合
```xml
<collection property="posts" ofType="domain.blog.Post">
  <id property="id" column="post_id"/>
  <result property="subject" column="post_subject"/>
  <result property="body" column="post_body"/>
</collection>
```
- 集合的嵌套 Select 查询
```xml
<resultMap id="blogResult" type="Blog">
  <collection property="posts" javaType="ArrayList" column="id" ofType="Post" select="selectPostsForBlog"/>
</resultMap>

<select id="selectBlog" resultMap="blogResult">
  SELECT * FROM BLOG WHERE ID = #{id}
</select>

<select id="selectPostsForBlog" resultType="Post">
  SELECT * FROM POST WHERE BLOG_ID = #{id}
</select>
```

- 鉴别器(鉴别器的概念很好理解——它很像 Java 语言中的 switch 语句。)
```xml
<discriminator javaType="int" column="draft">
  <case value="1" resultType="DraftPost"/>
</discriminator>
```
 - eg:

 ```xml
 <resultMap id="vehicleResult" type="Vehicle">
    <id property="id" column="id" />
    <result property="vin" column="vin"/>
    <result property="year" column="year"/>
    <result property="make" column="make"/>
    <result property="model" column="model"/>
    <result property="color" column="color"/>
    <discriminator javaType="int" column="vehicle_type">
      <case value="1" resultMap="carResult"/>
      <case value="2" resultMap="truckResult"/>
      <case value="3" resultMap="vanResult"/>
      <case value="4" resultMap="suvResult"/>
    </discriminator>
  </resultMap>

  <resultMap id="carResult" type="Car">
    <result property="doorCount" column="door_count" />
  </resultMap>
 ```

 - eg2:

 ```xml
 <resultMap id="vehicleResult" type="Vehicle">
  <id property="id" column="id" />
  <result property="vin" column="vin"/>
  <result property="year" column="year"/>
  <result property="make" column="make"/>
  <result property="model" column="model"/>
  <result property="color" column="color"/>
  <discriminator javaType="int" column="vehicle_type">
    <case value="1" resultType="carResult">
      <result property="doorCount" column="door_count" />
    </case>
    <case value="2" resultType="truckResult">
      <result property="boxSize" column="box_size" />
      <result property="extendedCab" column="extended_cab" />
    </case>
    <case value="3" resultType="vanResult">
      <result property="powerSlidingDoor" column="power_sliding_door" />
    </case>
    <case value="4" resultType="suvResult">
      <result property="allWheelDrive" column="all_wheel_drive" />
    </case>
    </discriminator>
  </resultMap>
 ```

#### 自动映射
 1. MyBatis 默认的自动映射等级为 PARTIAL ( 对除在内部定义了嵌套结果映射（也就是连接的属性）以外的属性进行映射)
 2. 默认情况下,如果 手动配置了 ResultMap 则使用 手动配置的映射,如果没有手动配置,则使用自动映射.
 3. 在ResultMap 中可以配置自动映射的开启和关闭.
  ```xml
  <!--可以通过在结果映射上设置 autoMapping 属性来为指定的结果映射设置启用/禁用自动映射-->

  <resultMap id="userResultMap" type="User" autoMapping="false">
    <result property="password" column="hashed_password"/>
  </resultMap>
  ```

#### 缓存  
默认情况下，只启用了本地的会话缓存，它仅仅对一个会话中的数据进行缓存。 要启用全局的二级缓存，只需要在你的 SQL 映射文件中添加一行：
```xml
<cache/>
```
产生的效果如下:
1. 映射语句文件中的所有 select 语句的结果将会被缓存。
2. 映射语句文件中的所有 insert、update 和 delete 语句会刷新缓存。
3. 缓存会使用最近最少使用算法（LRU, Least Recently Used）算法来清除不需要的缓存。
4. 缓存不会定时进行刷新（也就是说，没有刷新间隔）。
5. 缓存会保存列表或对象（无论查询方法返回哪种）的 1024 个引用。
6. 缓存会被视为读/写缓存，这意味着获取到的对象并不是共享的，可以安全地被调用者修改，而不干扰其他调用者或线程所做的潜在修改。
7. 缓存只作用于 cache 标签所在的映射文件中的语句。如果你混合使用 Java API 和 XML 映射文件，在共用接口中的语句将不会被默认缓存。你需要使用 @CacheNamespaceRef 注解指定缓存作用域。


* `<Cache>` 标签的属性
```XML
<cache
  eviction="FIFO"
  flushInterval="60000"
  size="512"
  readOnly="true"/>
```
* 自定义缓存
