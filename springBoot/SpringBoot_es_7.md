---
title: elastic7 学习
date: 2021-02-12 13:33:36
tags:
  - springBoot
categories:
  - springBoot
#top: 1
topdeclare: false
reward: true
---

# 特性

- 分布式的文档存储引擎
- 分布式的搜索引擎和分析引擎
- 分布式，支持PB级数据

# 使用场景

- 搜索领域： 如百度、谷歌，全文检索等。
- 门户网站：访问统计、文章点赞、留言评论等。
- 广告推广：记录员工行为数据、消费趋势、员工群体进行定制推广等。
- 信息采集：记录应用的埋点数据、访问日志数据等，方便大数据进行分析。

<!--starter-->

# ElasticSearch 基础概念

## ElasticSearch 和 DB 的关系

在 Elasticsearch 中，文档归属于一种类型 type，而这些类型存在于索引 index 中，我们可以列一些简单的不同点，来类比传统关系型数据库：

- Relational DB -> Databases -> Tables -> Rows -> Columns

- Elasticsearch -> Indices -> Types -> Documents -> Fields

Elasticsearch 集群可以包含多个索引 indices，每一个索引可以包含多个类型 types，每一个类型包含多个文档 documents，然后每个文档包含多个字段 Fields。而在 DB 中可以有多个数据库 Databases，每个库中可以有多张表 Tables，没个表中又包含多行Rows，每行包含多列Columns。

> 注意： 7.0 以后的版本已经消除了 type。



## 索引

### 索引基本概念（indices）

索引是含义相同属性的文档集合，是 ElasticSearch 的一个逻辑存储，可以理解为关系型数据库中的数据库，ElasticSearch 可以把索引数据存放到一台服务器上，也可以 sharding 后存到多台服务器上，每个索引有一个或多个分片，每个分片可以有多个副本。

### ~~索引类型（index_type）~~

索引可以定义一个或多个类型，文档必须属于一个类型。在 ElasticSearch 中，一个索引对象可以存储多个不同用途的对象，通过索引类型可以区分单个索引中的不同对象，可以理解为关系型数据库中的表。每个索引类型可以有不同的结构，但是不同的索引类型不能为相同的属性设置不同的类型。

## 文档

###  文档（document）

文档是可以被索引的基本数据单位。存储在 ElasticSearch 中的主要实体叫文档 document，可以理解为关系型数据库中表的一行记录。每个文档由多个字段构成，ElasticSearch 是一个非结构化的数据库，每个文档可以有不同的字段，并且有一个唯一的标识符。

## 映射

### 映射（mapping）

ElasticSearch 的 Mapping 非常类似于静态语言中的数据类型：声明一个变量为 int 类型的变量，以后这个变量都只能存储 int 类型的数据。同样的，一个 number 类型的 mapping 字段只能存储 number 类型的数据。

同语言的数据类型相比，Mapping 还有一些其他的含义，Mapping 不仅告诉 ElasticSearch 一个 Field 中是什么类型的值， 它还告诉 ElasticSearch 如何索引数据以及数据是否能被搜索到。

ElaticSearch 默认是动态创建索引和索引类型的 Mapping 的。这就相当于无需定义 Solr 中的 Schema，无需指定各个字段的索引规则就可以索引文件，很方便。但有时方便就代表着不灵活。比如，ElasticSearch 默认一个字段是要做分词的，但我们有时要搜索匹配整个字段却不行。如有统计工作要记录每个城市出现的次数。对于 name 字段，若记录 new york 文本，ElasticSearch 可能会把它拆分成 new 和 york 这两个词，分别计算这个两个单词的次数，而不是我们期望的 new york。

# SpringBoot 项目引入 ElasticSearch 依赖

通过 elasticsearch-rest-high-level-client 工具操作 ElasticSearch，

为什么没有使用 Spring 家族封装的 spring-data-elasticsearch。

主要原因是灵活性和更新速度，Spring 将 ElasticSearch 过度封装，让开发者很难跟 ES 的 DSL 查询语句进行关联。再者就是更新速度，ES 的更新速度是非常快，但是 spring-data-elasticsearch 更新速度比较缓慢。

所以选择了官方推出的 Java 客户端 elasticsearch-rest-high-level-client，它的代码写法跟 DSL 语句很相似，懂 ES 查询的使用其上手很快。

> - springboot 是  2.3.0.RELEASE 版本
> - elasticSearch 版本 为 7.4

## 引入依赖

- lombok：lombok 工具依赖。
- fastjson：用于将 JSON 转换对象的依赖。
- spring-boot-starter-web： SpringBoot 的 Web 依赖。
- elasticsearch：ElasticSearch：依赖，需要和 ES 版本保持一致。
- elasticsearch-rest-high-level-client：用于操作 ES 的 Java 客户端。

```xml
 <!--web-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <!--lombok-->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <!--fastjson-->
        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>fastjson</artifactId>
            <version>1.2.61</version>
        </dependency>
        <!--elasticsearch-->
        <dependency>
            <groupId>org.elasticsearch.client</groupId>
            <artifactId>elasticsearch-rest-high-level-client</artifactId>
            <version>7.6.2</version>
        </dependency>
        <dependency>
            <groupId>org.elasticsearch</groupId>
            <artifactId>elasticsearch</artifactId>
            <version>7.6.2</version>
        </dependency>
```

## ElasticSearch 连接配置

###  application.yml 配置文件

为了方便更改连接 ES 的连接配置，所以我们将配置信息放置于 application.yaml 中：

```yml
elasticsearch:
  schema: http
  host: 47.99.133.237
  port: 9200
  user_name: elastic
  password: 123456
  connectTimeout: 5000
  socketTimeout: 5000
  connectionRequestTimeout: 5000
  maxConnectNum: 100
  maxConnectPerRoute: 100
```

# java elasicSearch 链接配置

这里需要写一个 Java 配置类读取 application 中的配置信息：

```java
@Configuration
@ConfigurationProperties(prefix = "elasticsearch")
@Data
public class EsConfig {
    /**
     * 协议
     */
    private String schema;
    /**
     * ip地址
     */
    private String address;

    /**
     * 用户名
     */
    private String userName;

    /**
     * 密码
     */
    private String password;

    /**
     * 连接超时时间
     */
    private int connectTimeout;

    /**
     * Socket 连接超时时间
     */
    private int socketTimeout;

    /**
     * 获取连接的超时时间
     */
    private int connectionRequestTimeout;

    /**
     * 最大连接数
     */
    private int maxConnectNum;

    /**
     * 最大路由连接数
     */
    private int maxConnectPerRoute;

    @Bean
    public RestHighLevelClient client(){
        // 拆分地址
        String[] split = StringUtils.split(address, ",");
        int length = split.length;
        HttpHost[] hostList = new HttpHost[length];
        for(int i = 0; i < length; i++){
            String ip = split[i].split(":")[0];
            String port = split[i].split(":")[1];
            HttpHost httpHost = new HttpHost(ip, Integer.valueOf(port), schema);
            hostList[i] = httpHost;
        }
        //用户名，密码
        final CredentialsProvider credentialsProvider = new BasicCredentialsProvider();
        credentialsProvider.setCredentials(AuthScope.ANY, new UsernamePasswordCredentials(userName, password));

        RestClientBuilder builder = RestClient.builder(hostList).setRequestConfigCallback(new RestClientBuilder.RequestConfigCallback() {
            @Override
            public RequestConfig.Builder customizeRequestConfig(RequestConfig.Builder builder) {
                builder.setConnectTimeout(connectTimeout);
                builder.setSocketTimeout(socketTimeout);
                builder.setConnectionRequestTimeout(connectionRequestTimeout);
                return builder;
            }
        }).setHttpClientConfigCallback(new RestClientBuilder.HttpClientConfigCallback() {
            @Override
            public HttpAsyncClientBuilder customizeHttpClient(HttpAsyncClientBuilder httpAsyncClientBuilder) {
                httpAsyncClientBuilder.setMaxConnTotal(maxConnectNum);
                httpAsyncClientBuilder.setMaxConnPerRoute(maxConnectPerRoute);
                httpAsyncClientBuilder.disableAuthCaching();
                return httpAsyncClientBuilder.setDefaultCredentialsProvider(credentialsProvider);
            }
        });
        return new RestHighLevelClient(builder);
    }
}
```

# 索引操作示例

这里示例会指出通过 Kibana 的 Restful 工具操作与对应的 Java 代码操作的两个示例。扩展:某小公司RESTful、共用接口、前后端分离、接口约定的实践

## Restful 操作示例

### 创建索引

创建名为 zbcn-user 的索引与对应 Mapping。

```json
PUT /zbcn-user
{
  "mappings": {
    "dynamic": true,
    "properties": {
      "name": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "keyword"
          }
        }
      },
      "address": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "keyword"
          }
        }
      },
      "remark": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "keyword"
          }
        }
      },
      "age": {
        "type": "integer"
      },
      "salary": {
        "type": "float"
      },
      "birthDate": {
        "type": "date",
        "format": "yyyy-MM-dd"
      },
      "createTime": {
        "type": "date"
      }
    }
  }
}
```

### 删除索引

删除 zbcn-user 索引。

```json
DELETE /zbcn-user
```

### java 实例代码

```java
@Service
@Slf4j
public class IndexServiceImpl implements IndexService {

    @Autowired
    private RestHighLevelClient client;

    @Override
    public void createIndex() {
        //创建索引
        try {
            XContentBuilder builder = XContentFactory.jsonBuilder()
                    .startObject()
                        .field("dynamic",true)
                        .startObject("properties")
                            .startObject("name")
                                .field("type","text")
                                .startObject("fields")
                                    .startObject("keyword")
                                         .field("type", "keyword")
                                    .endObject()
                                .endObject()
                            .endObject()
                            .startObject("address")
                                .field("type","text")
                                .startObject("fields")
                                    .startObject("keyword")
                                        .field("type","keyword")
                                    .endObject()
                                .endObject()
                            .endObject()
                            .startObject("remark")
                                .field("type","text")
                                .startObject("fields")
                                    .startObject("keyword")
                                        .field("type","keyword")
                                    .endObject()
                                .endObject()
                            .endObject()
                            .startObject("age")
                                .field("type","integer")
                            .endObject()
                            .startObject("salary")
                                .field("type","float")
                            .endObject()
                            .startObject("birthDate")
                                .field("type","date")
                                .field("format", "yyyy-MM-dd")
                            .endObject()
                            .startObject("createTime")
                                .field("type","date")
                            .endObject()
                        .endObject()
                    .endObject();
            //打印日志
            log.debug(Strings.toString(builder));
            // 创建索引配置信息，配置
            Settings settings = Settings.builder()
                    .put("index.number_of_shards", 1)
                    .put("index.number_of_replicas", 0)
                    .build();
            // 新建创建索引请求对象，然后设置索引类型（ES 7.0 将不存在索引类型）和 mapping 与 index 配置
            CreateIndexRequest request = new CreateIndexRequest("zbcn-user");
            request.settings(settings);
            request.mapping(builder);
            // RestHighLevelClient 执行创建索引;
            CreateIndexResponse createIndexResponse = client.indices().create(request, RequestOptions.DEFAULT);
            // 判断是否创建成功
            boolean isCreated = createIndexResponse.isAcknowledged();
            log.info("是否创建成功：{}", isCreated);
        } catch (IOException e) {
            log.error("创建失败。", e);
        }
    }

    @Override
    public void deleteIndex() {
        try {
            // 新建删除索引请求对象
            DeleteIndexRequest deleteIndexRequest = new DeleteIndexRequest("zbcn-user");
            // 执行删除索引
            AcknowledgedResponse delete = client.indices().delete(deleteIndexRequest, RequestOptions.DEFAULT);
            // 判断是否删除成功
            boolean siDeleted = delete  .isAcknowledged();
            log.info("是否删除成功：{}", siDeleted);
        } catch (IOException e) {
            log.error("删除失败。", e);
        }
    }
}
```

## 文档操作示例

## Restful 操作示例

### 增加文档信息

在索引 zbcn-user 中增加一条文档信息。

```json
POST zbcn-user/_doc
{
    "address": "北京市",
    "age": 29,
    "birthDate": "1990-01-10",
    "createTime": 1579530727699,
    "name": "张三",
    "remark": "来自北京市的张先生",
    "salary": 100
}
```

### 获取文档信息

获取 zbcn-user 的索引 id=1 的文档信息。

```json
GET zbcn-user/_doc/WAUbZ3cBP-7LnBQt-fT6
```

### 更新文档信息

更新之前创建的 id=1 的文档信息。

```json
PUT zbcn-user/_doc/WAUbZ3cBP-7LnBQt-fT6
{
    "address": "北京市海淀区",
    "age": 29,
    "birthDate": "1990-01-10",
    "createTime": 1579530727699,
    "name": "张三",
    "remark": "来自北京市的张先生",
    "salary": 100
}
```

### java 代码示例

```java
@Service
@Slf4j
public class IndexCURDServiceImpl implements IndexCURDService {

    @Autowired
    private RestHighLevelClient client;

    /**
     * 用户索引
     */
    private static String USER_INDEX = "zbcn-user";

    @Override
    public void addDocument(UserInfo userInfo) {
        try {
            IndexRequest indexRequest = new IndexRequest(USER_INDEX);
            // 将对象转换为 byte 数组
            byte[] bytes = JSON.toJSONBytes(userInfo);
            // 设置文档内容
            indexRequest.source(bytes, XContentType.JSON);
            // 执行增加文档
            IndexResponse response = client.index(indexRequest, RequestOptions.DEFAULT);
            log.info("创建状态：{}", response.status());
        } catch (IOException e) {
            log.info("创建失败.", e);
        }
    }

    @Override
    public UserInfo getDocument(String id) {
        UserInfo userInfo = null;
        try {
            GetRequest getRequest = new GetRequest(USER_INDEX,id);
            GetResponse response = client.get(getRequest, RequestOptions.DEFAULT);
            // 将 JSON 转换成对象
            if (response.isExists()) {
                userInfo = JSON.parseObject(response.getSourceAsBytes(), UserInfo.class);
                log.info("员工信息：{}", userInfo);
            }
        } catch (IOException e) {
            log.error("获取 用户信息失败.", e);
        }
        return userInfo;
    }

    @Override
    public void updateDocument(String id, UserInfo userInfo) {
        try {
            UpdateRequest updateRequest = new UpdateRequest(USER_INDEX, id);
            // 将对象转换为 byte 数组
            byte[] json = JSON.toJSONBytes(userInfo);
            // 设置更新文档内容
            updateRequest.doc(json, XContentType.JSON);
            // 执行更新文档
            UpdateResponse update = client.update(updateRequest, RequestOptions.DEFAULT);
            log.info("更新状态：{}", update.status());
        } catch (IOException e) {
            log.error("更新用户信息失败.", e);
        }
    }

    @Override
    public void deleteDocument(String id) {
        try {
            DeleteRequest deleteRequest = new DeleteRequest(USER_INDEX,id);
            DeleteResponse delete = client.delete(deleteRequest, RequestOptions.DEFAULT);
            log.info("删除状态：{}", delete.status());
        } catch (IOException e) {
            log.error("删除文档失败.", e);
        }
    }
}

```

# 插入初始化数据

执行查询示例前，先往索引中插入一批数据：

## 单条插入

```json
POST zbcn-user/_doc
{
	"name": "零零",
	"address": "北京市丰台区",
	"remark": "低层员工",
	"age": 29,
	"salary": 3000,
	"birthDate": "1990-11-11",
	"createTime": "2019-11-11T08:18:00.000Z"
}
```

## 批量插入

```json
POST _bulk
POST _bulk
{"index":{"_index":"zbcn-user"}}
{"name":"刘一","address":"北京市丰台区","remark":"低层员工","age":30,"salary":3000,"birthDate":"1989-11-11","createTime":"2019-03-15T08:18:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"陈二","address":"北京市昌平区","remark":"中层员工","age":27,"salary":7900,"birthDate":"1992-01-25","createTime":"2019-11-08T11:15:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"张三","address":"北京市房山区","remark":"中层员工","age":28,"salary":8800,"birthDate":"1991-10-05","createTime":"2019-07-22T13:22:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"李四","address":"北京市大兴区","remark":"高层员工","age":26,"salary":9000,"birthDate":"1993-08-18","createTime":"2019-10-17T15:00:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"王五","address":"北京市密云区","remark":"低层员工","age":31,"salary":4800,"birthDate":"1988-07-20","createTime":"2019-05-29T09:00:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"赵六","address":"北京市通州区","remark":"中层员工","age":32,"salary":6500,"birthDate":"1987-06-02","createTime":"2019-12-10T18:00:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"孙七","address":"北京市朝阳区","remark":"中层员工","age":33,"salary":7000,"birthDate":"1986-04-15","createTime":"2019-06-06T13:00:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"周八","address":"北京市西城区","remark":"低层员工","age":32,"salary":5000,"birthDate":"1987-09-26","createTime":"2019-01-26T14:00:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"吴九","address":"北京市海淀区","remark":"高层员工","age":30,"salary":11000,"birthDate":"1989-11-25","createTime":"2019-09-07T13:34:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"郑十","address":"北京市东城区","remark":"低层员工","age":29,"salary":5000,"birthDate":"1990-12-25","createTime":"2019-03-06T12:08:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"萧十一","address":"北京市平谷区","remark":"低层员工","age":29,"salary":3300,"birthDate":"1990-11-11","createTime":"2019-03-10T08:17:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"曹十二","address":"北京市怀柔区","remark":"中层员工","age":27,"salary":6800,"birthDate":"1992-01-25","createTime":"2019-12-03T11:09:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"吴十三","address":"北京市延庆区","remark":"中层员工","age":25,"salary":7000,"birthDate":"1994-10-05","createTime":"2019-07-27T14:22:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"冯十四","address":"北京市密云区","remark":"低层员工","age":25,"salary":3000,"birthDate":"1994-08-18","createTime":"2019-04-22T15:00:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"蒋十五","address":"北京市通州区","remark":"低层员工","age":31,"salary":2800,"birthDate":"1988-07-20","createTime":"2019-06-13T10:00:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"苗十六","address":"北京市门头沟区","remark":"高层员工","age":32,"salary":11500,"birthDate":"1987-06-02","createTime":"2019-11-11T18:00:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"鲁十七","address":"北京市石景山区","remark":"高员工","age":33,"salary":9500,"birthDate":"1986-04-15","createTime":"2019-06-06T14:00:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"沈十八","address":"北京市朝阳区","remark":"中层员工","age":31,"salary":8300,"birthDate":"1988-09-26","createTime":"2019-09-25T14:00:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"吕十九","address":"北京市西城区","remark":"低层员工","age":31,"salary":4500,"birthDate":"1988-11-25","createTime":"2019-09-22T13:34:00.000Z"}
{"index":{"_index":"zbcn-user"}}
{"name":"丁二十","address":"北京市东城区","remark":"低层员工","age":33,"salary":2100,"birthDate":"1986-12-25","createTime":"2019-03-07T12:08:00.000Z"}
```

## 查询数据

插入完成后再查询数据，查看之前插入的数据是否存在：

```json
GET zbcn-user/_search
```

## 查询操作示例

### 精确查询(term)

#### Restful 操作示例

##### 精确查询 (term)

精确查询，查询地址为 北京市通州区 的人员信息：

查询条件不会进行分词，但是查询内容可能会分词，导致查询不到。之前在创建索引时设置 Mapping 中 address 字段存在 keyword 字段是专门用于不分词查询的子字段。

```json
GET zbcn-user/_search
{
  "query": {
    "term": {
      "address.keyword": {
        "value": "北京市通州区"
      }
    }
  }
}
```

##### 精确查询-多内容查询 (terms)

精确查询，查询地址为 北京市丰台区、北京市昌平区 或 北京市大兴区 的人员信息：

```json
GET zbcn-user/_search
{
  "query": {
    "terms": {
      "address.keyword": [
        "北京市丰台区",
        "北京市昌平区",
        "北京市大兴区"
      ]
    }
  }
}
```

#### Java 代码示例

```java
@Service
@Slf4j
public class TermQueryServiceImpl implements TermQueryService {

    @Autowired
    private RestHighLevelClient client;

    /**
     * 精确查询（查询条件不会进行分词，但是查询内容可能会分词，导致查询不到）
     * 构建查询条件（注意：termQuery 支持多种格式查询，如 boolean、int、double、string 等
     * @param builder
     * @return
     */
    @Override
    public List<UserInfo> termQuery(TermQueryBuilder builder) {
        List<UserInfo> result = Lists.newArrayList();
        try {
            SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
            searchSourceBuilder.query(builder);
            SearchRequest searchRequest = new SearchRequest(UserConstant.USER_INDEX);
            searchRequest.source(searchSourceBuilder);
            // 执行查询，然后处理响应结果
            SearchResponse searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
            // 根据状态和数据条数验证是否返回了数据
            if (RestStatus.OK.equals(searchResponse.status())) {
                SearchHits hits = searchResponse.getHits();
                for (SearchHit hit : hits) {
                    // 将 JSON 转换成对象
                    UserInfo userInfo = JSON.parseObject(hit.getSourceAsString(), UserInfo.class);
                    result.add(userInfo);
                }
            }
        } catch (IOException e) {
           log.error("精确查询数据", e);
        }
        return result;
    }

    /**
     * 多个内容在一个字段中进行查询:
     * termsQuery 支持多种格式查询，如 boolean、int、double、string 等
     * @param termsBuilder
     * @return
     */
    @Override
    public List<UserInfo> termsQuery(TermsQueryBuilder termsBuilder) {
        List<UserInfo> result = Lists.newArrayList();
        try {
            SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
            searchSourceBuilder.query(termsBuilder);
            // 创建查询请求对象，将查询对象配置到其中
            SearchRequest searchRequest = new SearchRequest(UserConstant.USER_INDEX);
            searchRequest.source(searchSourceBuilder);
            // 执行查询，然后处理响应结果
            SearchResponse searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
            // 根据状态和数据条数验证是否返回了数据
            if (RestStatus.OK.equals(searchResponse.status())) {
                SearchHits hits = searchResponse.getHits();
                for (SearchHit hit : hits) {
                    // 将 JSON 转换成对象
                    UserInfo userInfo = JSON.parseObject(hit.getSourceAsString(), UserInfo.class);
                    result.add(userInfo);
                }
            }
        } catch (IOException e) {
            log.error("多字段查询", e);
        }
        return result;
    }
}
```

### 匹配查询(match)

####　Restful 操作示例

##### 匹配查询全部数据与分页

匹配查询符合条件的所有数据，并且设置以 salary 字段升序排序，并设置分页：

```json
GET zbcn-user/_search
{
    "query":{
        "match_all": {}
    },
    "from":0,
    "size":10,
    "sort":[
        {
            "salary":{
                "order":"asc"
            }
        }
    ]
}
```

#####  匹配查询数据

匹配查询地址为 通州区 的数据：

```json
GET zbcn-user/_search
{
    "query":{
        "match": {
            "address":"通州区"
        }
    }
}
```

##### 词语匹配查询

词语匹配进行查询，匹配 address 中为 北京市通州区 的员工信息:

```json
GET zbcn-user/_search
{
  "query": {
    "match_phrase": {
      "address": "北京市通州区"
    }
  }
}
```

##### 内容多字段查询

查询在字段 address、remark 中存在 北京 内容的员工信息：

```json
GET zbcn-user/_search
{
    "query": {
      "multi_match": {
        "query": "北京",
        "fields": ["address","remark"]
      }
    }
}
```

#### Java 代码示例

```java
@Service
@Slf4j
public class MatchQueryServiceImpl implements MatchQueryService {

    @Autowired
    private RestHighLevelClient client;
    @Override
    public List<UserInfo> matchPageQuery(MatchAllQueryBuilder matchAllQueryBuilder,Integer page,Integer size) {
        List<UserInfo> result = Lists.newArrayList();
        try {
            // 创建查询源构造器
            SearchSourceBuilder builder = new SearchSourceBuilder();
            builder.query(matchAllQueryBuilder);
            // 设置分页
            builder.from(page);
            builder.size(size);
            //设置排序
            builder.sort("salary", SortOrder.DESC);
            SearchRequest searchRequest = new SearchRequest(UserConstant.USER_INDEX);
            searchRequest.source(builder);
            SearchResponse searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
            // 根据状态和数据条数验证是否返回了数据
            if (RestStatus.OK.equals(searchResponse.status()) && searchResponse.getHits().getTotalHits().value > 0) {
                SearchHits hits = searchResponse.getHits();
                for (SearchHit hit : hits) {
                    // 将 JSON 转换成对象
                    UserInfo userInfo = JSON.parseObject(hit.getSourceAsString(), UserInfo.class);
                    result.add(userInfo);
                }
            }
        } catch (IOException e) {
            log.error("match 查询 失败.", e);
        }
        return result;
    }

    @Override
    public List<UserInfo> matchQuery(MatchQueryBuilder matchQueryBuilder) {
        List<UserInfo> result = Lists.newArrayList();
        try {
            // 构建查询条件
            SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
            searchSourceBuilder.query(matchQueryBuilder);
            // 创建查询请求对象，将查询对象配置到其中
            SearchRequest searchRequest = new SearchRequest(UserConstant.USER_INDEX);
            searchRequest.source(searchSourceBuilder);
            // 执行查询，然后处理响应结果
            SearchResponse searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
            // 根据状态和数据条数验证是否返回了数据
            if (RestStatus.OK.equals(searchResponse.status()) && searchResponse.getHits().getTotalHits().value > 0) {
                SearchHits hits = searchResponse.getHits();
                for (SearchHit hit : hits) {
                    // 将 JSON 转换成对象
                    UserInfo userInfo = JSON.parseObject(hit.getSourceAsString(), UserInfo.class);
                    result.add(userInfo);
                }
            }
        } catch (IOException e) {
            log.error("match 查询 失败.", e);
        }

        return result;
    }

    @Override
    public List<UserInfo> matchPhraseQuery(MatchPhraseQueryBuilder matchPhraseQueryBuilder) {
        List<UserInfo> result = Lists.newArrayList();
        try {
            // 构建查询条件
            SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
            searchSourceBuilder.query(matchPhraseQueryBuilder);
            // 创建查询请求对象，将查询对象配置到其中
            SearchRequest searchRequest = new SearchRequest(UserConstant.USER_INDEX);
            searchRequest.source(searchSourceBuilder);
            // 执行查询，然后处理响应结果
            SearchResponse searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
            if (RestStatus.OK.equals(searchResponse.status()) && searchResponse.getHits().getTotalHits().value > 0) {
                SearchHits hits = searchResponse.getHits();
                for (SearchHit hit : hits) {
                    // 将 JSON 转换成对象
                    UserInfo userInfo = JSON.parseObject(hit.getSourceAsString(), UserInfo.class);
                    result.add(userInfo);
                }
            }
        } catch (IOException e) {
            log.error("match 查询 失败.", e);
        }
        return result;
    }

    @Override
    public List<UserInfo> matchMultiQuery(MultiMatchQueryBuilder multiMatchQueryBuilder) {
        List<UserInfo> result = Lists.newArrayList();
        try {
            // 构建查询条件
            SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
            searchSourceBuilder.query(multiMatchQueryBuilder);
            // 创建查询请求对象，将查询对象配置到其中
            SearchRequest searchRequest = new SearchRequest(UserConstant.USER_INDEX);
            searchRequest.source(searchSourceBuilder);
            // 执行查询，然后处理响应结果
            SearchResponse searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
            if (RestStatus.OK.equals(searchResponse.status()) && searchResponse.getHits().getTotalHits().value > 0) {
                SearchHits hits = searchResponse.getHits();
                for (SearchHit hit : hits) {
                    // 将 JSON 转换成对象
                    UserInfo userInfo = JSON.parseObject(hit.getSourceAsString(), UserInfo.class);
                    result.add(userInfo);
                }
            }
        } catch (IOException e) {
            log.error("match 查询 失败.", e);
        }
        return result;
    }
}

//测试代码
@RunWith(SpringRunner.class)
@SpringBootTest
class MatchQueryServiceImplTest {

    @Autowired
    MatchQueryService queryService;

    /**
     *  匹配查询符合条件的所有数据，并设置分页
     */
    @Test
    void matchPageQuery() {
        // 构建查询条件
        MatchAllQueryBuilder matchAllQueryBuilder = QueryBuilders.matchAllQuery();
        List<UserInfo> userInfos = queryService.matchPageQuery(matchAllQueryBuilder, 0, 10);
        System.out.println(JSONArray.toJSONString(userInfos));
    }

    /**
     * 匹配查询数据
     */
    @Test
    void matchQuery() {
        MatchQueryBuilder address = QueryBuilders.matchQuery("address", "*通州区");
        List<UserInfo> userInfos = queryService.matchQuery(address);
        System.out.println(JSONArray.toJSONString(userInfos));
    }

    /**
     * 词语匹配查询
     */
    @Test
    void matchPhraseQuery() {
        MatchPhraseQueryBuilder matchPhraseQueryBuilder = QueryBuilders.matchPhraseQuery("address", "北京市通州区");
        List<UserInfo> userInfos = queryService.matchPhraseQuery(matchPhraseQueryBuilder);
        System.out.println(JSONArray.toJSONString(userInfos));
    }

    /**
     * 内容在多字段中进行查询
     */
    @Test
    void matchMultiQuery() {
        MultiMatchQueryBuilder multiMatchQueryBuilder = QueryBuilders.multiMatchQuery("北京市", "address", "remark");
        List<UserInfo> userInfos = queryService.matchMultiQuery(multiMatchQueryBuilder);
        System.out.println(JSONArray.toJSONString(userInfos));
    }
}
```

### 模块查询

#### Restful 操作示例

模糊查询所有以 三 结尾的姓名

```json
GET zbcn-user/_search
{
  "query": {
    "fuzzy": {
      "name": "三"
    }
  }
}
```

#### Java 代码示例

```java
@Service
@Slf4j
public class FuzzyQueryServiceImpl implements FuzzyQueryService {

    @Autowired
    private RestHighLevelClient client;

    @Override
    public List<UserInfo> fuzzyQuery(FuzzyQueryBuilder fuzzyQueryBuilder) {
        List<UserInfo> result = Lists.newArrayList();
        try {
            // 构建查询条件
            SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
            searchSourceBuilder.query(fuzzyQueryBuilder);
            // 创建查询请求对象，将查询对象配置到其中
            SearchRequest searchRequest = new SearchRequest(UserConstant.USER_INDEX);
            searchRequest.source(searchSourceBuilder);
            // 执行查询，然后处理响应结果
            SearchResponse searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
            // 根据状态和数据条数验证是否返回了数据
            if (RestStatus.OK.equals(searchResponse.status())) {
                SearchHits hits = searchResponse.getHits();
                for (SearchHit hit : hits) {
                    // 将 JSON 转换成对象
                    UserInfo userInfo = JSON.parseObject(hit.getSourceAsString(), UserInfo.class);
                    result.add(userInfo);
                }
            }
        } catch (IOException e) {
            log.error("fuzzy 查询", e);
        }
        return result;
    }
}
```

### 范围查询(range)

#### Restful 操作示例

查询岁数 ≥ 30 岁的员工数据：

```json
GET /zbcn-user/_search
{
  "query": {
    "range": {
      "age": {
        "gte": 30
      }
    }
  }
}
```

查询生日距离现在 30 年间的员工数据：

```json
GET zbcn-user/_search
{
  "query": {
    "range": {
      "birthDate": {
        "gte": "now-30y"
      }
    }
  }
}
```

#### Java 代码示例

```java
@Slf4j
@Service
public class RangeQueryServiceImpl implements RangeQueryService {

    @Autowired
    private RestHighLevelClient client;

    @Override
    public List<UserInfo> rangeQuery(RangeQueryBuilder rangeQueryBuilder) {
        List<UserInfo> result = Lists.newArrayList();
        try {
            // 构建查询条件
            SearchSourceBuilder builder = new SearchSourceBuilder();
            builder.query(rangeQueryBuilder);
            SearchRequest searchRequest = new SearchRequest(UserConstant.USER_INDEX);
            searchRequest.source(builder);
            // 执行查询，然后处理响应结果
            SearchResponse searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
            // 根据状态和数据条数验证是否返回了数据
            if (RestStatus.OK.equals(searchResponse.status()) && searchResponse.getHits().getTotalHits().value > 0) {
                SearchHits hits = searchResponse.getHits();
                for (SearchHit hit : hits) {
                    // 将 JSON 转换成对象
                    UserInfo userInfo = JSON.parseObject(hit.getSourceAsString(), UserInfo.class);
                    result.add(userInfo);
                }
            }
        } catch (IOException e) {
            log.error("range 查询失败.",e);
        }
        return result;
    }
}

//测试代码
@RunWith(SpringRunner.class)
@SpringBootTest
class RangeQueryServiceImplTest {

    @Autowired
    RangeQueryService rangeQueryService;

    @Test
    void rangeQuery() {
        //查询岁数 ≥ 30 岁的员工数据
        RangeQueryBuilder age = QueryBuilders.rangeQuery("age").gte(30);
        List<UserInfo> userInfos = rangeQueryService.rangeQuery(age);
        System.out.println(JSONArray.toJSONString(userInfos));

        System.out.println("第二次查询.");
        /**
         * 查询距离现在 30 年间的员工数据
         * [年(y)、月(M)、星期(w)、天(d)、小时(h)、分钟(m)、秒(s)]
         * 例如：
         * now-1h 查询一小时内范围
         * now-1d 查询一天内时间范围
         * now-1y 查询最近一年内的时间范围
         */
        // includeLower（是否包含下边界）、includeUpper（是否包含上边界）
        RangeQueryBuilder birthDate = QueryBuilders.rangeQuery("birthDate")
                .gte("now-30y").includeLower(true).includeUpper(true);
        List<UserInfo> userInfos1 = rangeQueryService.rangeQuery(birthDate);
        System.out.println(JSONArray.toJSONString(userInfos1));
    }
}
```

#### 通配符查询(wildcard)

##### Restful 操作示例

查询所有以 “三” 结尾的姓名：

```json
GET zbcn-user/_search
{
  "query": {
    "wildcard": {
      "name.keyword": {
        "value": "*三"
      }
    }
  }
}
```

##### Java 代码示例

```java
@Service
@Slf4j
public class WildcardQueryServiceImpl implements WildcardQueryService {

    @Autowired
    private RestHighLevelClient client;

    @Override
    public List<UserInfo> wildcardQuery(WildcardQueryBuilder wildcardQueryBuilder) {
        List<UserInfo> result = Lists.newArrayList();
        try {
            SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
            searchSourceBuilder.query(wildcardQueryBuilder);
            SearchRequest searchRequest = new SearchRequest(UserConstant.USER_INDEX);
            searchRequest.source(searchSourceBuilder);
            // 执行查询，然后处理响应结果
            SearchResponse searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
            // 根据状态和数据条数验证是否返回了数据
            if (RestStatus.OK.equals(searchResponse.status())) {
                SearchHits hits = searchResponse.getHits();
                for (SearchHit hit : hits) {
                    // 将 JSON 转换成对象
                    UserInfo userInfo = JSON.parseObject(hit.getSourceAsString(), UserInfo.class);
                    result.add(userInfo);
                }
            }
        } catch (IOException e) {
            log.error("精确查询数据", e);
        }
        return result;
    }
}

// 测试
@Test
void wildcardQuery() {
    //查询所有以 “三” 结尾的姓名
    WildcardQueryBuilder wildcardQueryBuilder = QueryBuilders.wildcardQuery("name.keyword", "*三");
    List<UserInfo> userInfos = wildcardQueryService.wildcardQuery(wildcardQueryBuilder);
    System.out.println(JSONArray.toJSONString(userInfos));
}
```

#### 布尔查询(bool)

##### Restful 操作示例

查询出生在 1990-1995 年期间，且地址在 北京市昌平区、北京市大兴区、北京市房山区 的员工信息：

```json
GET zbcn-user/_search
{
  "query": {
    "bool": {
      "filter": [
        {
          "range": {
            "birthDate": {
              "format": "yyyy", 
              "gte": 1990,
              "lte": 1995
          }
          }
        }
      ],
      "must": [
        {
          "terms": {
            "address.keyword": [
              "北京市昌平区",
              "北京市大兴区",
              "北京市房山区"
            ]
          }
        }
      ]
    }
  }
}
```

##### Java 代码示例

```java
@Service
@Slf4j
public class BoolQueryServiceImpl implements BoolQueryService {

    @Autowired
    private RestHighLevelClient client;

    @Override
    public List<UserInfo> boolQuery(BoolQueryBuilder boolQueryBuilder) {
        List<UserInfo> result = Lists.newArrayList();
        try {
            // 构建查询条件
            SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
            searchSourceBuilder.query(boolQueryBuilder);
            // 创建查询请求对象，将查询对象配置到其中
            SearchRequest searchRequest = new SearchRequest(UserConstant.USER_INDEX);
            searchRequest.source(searchSourceBuilder);
            // 执行查询，然后处理响应结果
            SearchResponse searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
            // 根据状态和数据条数验证是否返回了数据
            if (RestStatus.OK.equals(searchResponse.status())) {
                SearchHits hits = searchResponse.getHits();
                for (SearchHit hit : hits) {
                    // 将 JSON 转换成对象
                    UserInfo userInfo = JSON.parseObject(hit.getSourceAsString(), UserInfo.class);
                    result.add(userInfo);
                }
            }
        } catch (IOException e) {
            log.error("fuzzy 查询", e);
        }
        return result;
    }
}

//创建 Bool 查询构建器
 @Test
void boolQuery() {
    BoolQueryBuilder boolQueryBuilder = QueryBuilders.boolQuery();
    TermsQueryBuilder termsQuery = QueryBuilders.termsQuery("address.keyword", "北京市昌平区", "北京市大兴区", "北京市房山区");
    boolQueryBuilder.must(termsQuery).filter().add(QueryBuilders.rangeQuery("birthDate").format("yyyy").gte("1990").lte("1995"));
    List<UserInfo> userInfos = boolQueryService.boolQuery(boolQueryBuilder);
    System.out.println(JSONArray.toJSONString(userInfos));
}
```





## 聚合查询

### Metric 聚合分析

统计员工总数、工资最高值、工资最低值、工资平均工资、工资总和：

```json
GET /zbcn-user/_search
{
  "size": 0,
  "aggs": {
    "salary_stats": {
      "stats": {
        "field": "salary"
      }
    }
  }
}
```

统计员工工资最低值：

```json
GET /zbcn-user/_search
{
  "size": 0,
  "aggs": {
    "salary_min": {
      "min": {
        "field": "salary"
      }
    }
  }
}
```

统计员工工资最高值：

```json
GET /zbcn-user/_search
{
  "size": 0,
  "aggs": {
    "salary_max": {
      "max": {
        "field": "salary"
      }
    }
  }
}
```

统计员工工资平均值：

```json
GET /zbcn-user/_search
{
  "size": 0,
  "aggs": {
    "salary_avg": {
      "avg": {
        "field": "salary"
      }
    }
  }
}
```

统计员工工资总值：

```json
GET /zbcn-user/_search
{
  "size": 0,
  "aggs": {
    "salary_sum": {
      "sum": {
        "field": "salary"
      }
    }
  }
}
```

统计员工总数：

```json
GET /zbcn-user/_search
{
  "size": 0,
  "aggs": {
    "employee_count": {
      "value_count": {
        "field": "salary"
      }
    }
  }
}
```

统计员工工资百分位：

```json
GET /zbcn-user/_search
{
  "size": 0,
  "aggs": {
    "salary_percentiles": {
      "percentiles": {
        "field": "salary"
      }
    }
  }
}
```

#### java api

```java
@Slf4j
@Service
public class AggrMetricServiceImpl implements AggrMetricService {

    @Autowired
    private RestHighLevelClient client;


    @Override
    public SearchResponse aggregationStats(AggregationBuilder aggr) {
        SearchResponse response = null;
        try {
            // 查询源构建器
            SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
            searchSourceBuilder.aggregation(aggr);
            // 设置查询结果不返回，只返回聚合结果
            searchSourceBuilder.size(0);
            // 创建查询请求对象，将查询条件配置到其中
            SearchRequest request = new SearchRequest(UserConstant.USER_INDEX);
            request.source(searchSourceBuilder);
            // 执行请求
            response = client.search(request, RequestOptions.DEFAULT);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return response;
    }
}

//测试代码
@RunWith(SpringRunner.class)
@SpringBootTest
@Slf4j
class AggrMetricServiceImplTest {

    @Autowired
    AggrMetricService aggrMetricService;
    @Test
    void aggregationStats() {
        StatsAggregationBuilder aggr = AggregationBuilders.stats("salary_stats").field("salary");
        SearchResponse response = aggrMetricService.aggregationStats(aggr);
        Aggregations aggregations = response.getAggregations();
        if (RestStatus.OK.equals(response.status()) || aggregations != null){
            ParsedStats aggregation = aggregations.get("salary_stats");
            log.info("-------------------------------------------");
            log.info("聚合信息:");
            log.info("count：{}", aggregation.getCount());
            log.info("avg：{}", aggregation.getAvg());
            log.info("max：{}", aggregation.getMax());
            log.info("min：{}", aggregation.getMin());
            log.info("sum：{}", aggregation.getSum());
            log.info("-------------------------------------------");
        }
    }

    /**
     * min 统计员工工资最低值
     * @return
     */
    @Test
    public void aggregationMin(){
        MinAggregationBuilder min = AggregationBuilders.min("salary_min").field("salary");
        SearchResponse response = aggrMetricService.aggregationStats(min);
        // 获取响应中的聚合信息
        Aggregations aggregations = response.getAggregations();
        // 输出内容
        if (RestStatus.OK.equals(response.status()) || aggregations != null) {
            // 转换为 Min 对象
            ParsedMin aggregation = aggregations.get("salary_min");
            log.info("-------------------------------------------");
            log.info("聚合信息:");
            log.info("min：{}", aggregation.getValue());
            log.info("-------------------------------------------");
        }
    }


    @Test
    public void aggregationMax(){
        // 设置聚合条件
        AggregationBuilder aggr = AggregationBuilders.max("salary_max").field("salary");
        SearchResponse response = aggrMetricService.aggregationStats(aggr);
        // 获取响应中的聚合信息
        Aggregations aggregations = response.getAggregations();
        // 输出内容
        if (RestStatus.OK.equals(response.status()) || aggregations != null) {
            // 转换为 Max 对象
            ParsedMax aggregation = aggregations.get("salary_max");
            log.info("-------------------------------------------");
            log.info("聚合信息:");
            log.info("max：{}", aggregation.getValue());
            log.info("-------------------------------------------");
        }
    }

    /**
     * avg 统计员工工资平均值
     */
    @Test
    public void aggregationAvg(){
        // 设置聚合条件
        AggregationBuilder aggr = AggregationBuilders.avg("salary_avg").field("salary");
        SearchResponse response = aggrMetricService.aggregationStats(aggr);
        // 获取响应中的聚合信息
        Aggregations aggregations = response.getAggregations();
        // 输出内容
        if (RestStatus.OK.equals(response.status()) || aggregations != null) {
            // 转换为 Avg 对象
            ParsedAvg aggregation = aggregations.get("salary_avg");
            log.info("-------------------------------------------");
            log.info("聚合信息:");
            log.info("avg：{}", aggregation.getValue());
            log.info("-------------------------------------------");
        }
    }

    @Test
    public void aggregationSum(){

        // 设置聚合条件
        SumAggregationBuilder aggr = AggregationBuilders.sum("salary_sum").field("salary");
        SearchResponse response = aggrMetricService.aggregationStats(aggr);
        // 获取响应中的聚合信息
        Aggregations aggregations = response.getAggregations();
        // 输出内容
        if (RestStatus.OK.equals(response.status()) || aggregations != null) {
            // 转换为 Sum 对象
            ParsedSum aggregation = aggregations.get("salary_sum");
            log.info("-------------------------------------------");
            log.info("聚合信息:");
            log.info("sum：{}", String.valueOf((aggregation.getValue())));
            log.info("-------------------------------------------");
        }
    }

    /**
     * count 统计员工总数
     */
    @Test
    public void aggregationCount(){
        // 设置聚合条件
        AggregationBuilder aggr = AggregationBuilders.count("employee_count").field("salary");
        SearchResponse response = aggrMetricService.aggregationStats(aggr);
        // 获取响应中的聚合信息
        Aggregations aggregations = response.getAggregations();
        // 输出内容
        if (RestStatus.OK.equals(response.status()) || aggregations != null) {
            // 转换为 ValueCount 对象
            ParsedValueCount aggregation = aggregations.get("employee_count");
            log.info("-------------------------------------------");
            log.info("聚合信息:");
            log.info("count：{}", aggregation.getValue());
            log.info("-------------------------------------------");
        }
    }

    @Test
    public void aggregationPercentiles(){
        // 设置聚合条件
        AggregationBuilder aggr = AggregationBuilders.percentiles("salary_percentiles").field("salary");
        SearchResponse response = aggrMetricService.aggregationStats(aggr);
        // 获取响应中的聚合信息
        Aggregations aggregations = response.getAggregations();
        // 输出内容
        if (RestStatus.OK.equals(response.status()) || aggregations != null) {
            // 转换为 Percentiles 对象
            ParsedPercentiles aggregation = aggregations.get("salary_percentiles");
            log.info("-------------------------------------------");
            log.info("聚合信息:");
            for (Percentile percentile : aggregation) {
                log.info("百分位：{}：{}", percentile.getPercent(), percentile.getValue());
            }
            log.info("-------------------------------------------");
        }
    }

```



### Bucket 聚合分析

#### Restful 操作示例

```json
GET /zbcn-user/_search
{
  "size": 0,
  "aggs": {
    "age_bucket": {
      "terms": {
        "field": "age",
        "size": "10"
      }
    }
  }
}
```

按工资范围进行聚合分桶，统计工资在 3000-5000、5000-9000 和 9000 以上的员工信息：

```json
GET zbcn-user/_search
{
  "size": 0,
  "aggs": {
    "salary_range_bucket": {
      "range": {
        "field":"salary",
        "ranges": [
          {
            "key": "低级员工", 
            "to": 3000
          },{
            "key": "中级员工",
            "from": 5000,
            "to": 9000
          },{
            "key": "高级员工",
            "from": 9000
          }
        ]
      }
    }
  }
}
```

按照时间范围进行分桶，统计 1985-1990 年和 1990-1995 年出生的员工信息：

```json
GET zbcn-user/_search
{
  "size": 0,
  "aggs": {
    "date_range_bucket": {
      "date_range": {
        "field": "birthDate",
        "format": "yyyy", 
        "ranges": [
          {
            "key": "出生日期1985-1990的员工", 
            "from": "1985",
            "to": "1990"
          },{
            "key": "出生日期1990-1995的员工", 
            "from": "1990",
            "to": "1995"
          }
        ]
      }
    }
  }
}
```

按工资多少进行聚合分桶，设置统计的最小值为 0，最大值为 12000，区段间隔为 3000：

```json
GET zbcn-user/_search
{
  "size": 0,
  "aggs": {
    "salary_histogram": {
      "histogram": {
        "field": "salary",
        "extended_bounds": {
          "min": 0,
          "max": 12000
        }, 
        "interval": 3000
      }
    }
  }
}
```

按出生日期进行分桶：

```json
GET zbcn-user/_search
{
  "size": 0, 
  "aggs": {
    "birthday_histogram": {
      "date_histogram": {
        "format": "yyyy", 
        "field": "birthDate",
        "interval": "year"
      }
    }
  }
}
```

#### Java 代码示例

```java
@Service
@Slf4j
public class AggrBucketServiceImpl implements AggrBucketService {

    @Autowired
    private RestHighLevelClient client;

    @Override
    public SearchResponse aggrBucket(AggregationBuilder aggr) {
        SearchResponse response = null;
        try {
            // 查询源构建器
            SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
            searchSourceBuilder.size(0);
            searchSourceBuilder.aggregation(aggr);
            // 创建查询请求对象，将查询条件配置到其中
            SearchRequest request = new SearchRequest(UserConstant.USER_INDEX);
            request.source(searchSourceBuilder);
            // 执行请求
            response = client.search(request, RequestOptions.DEFAULT);
        } catch (IOException e) {
            log.error("bucket 聚合操作失败。", e);
        }
        return response;
    }
}
```

- 测试代码

```java
@RunWith(SpringRunner.class)
@SpringBootTest
@Slf4j
class AggrBucketServiceImplTest {

    @Autowired
    AggrBucketService aggrBucketService;

    /**
     * 按岁数进行聚合分桶
     */
    @Test
    void  aggrBucketTerms() {
        TermsAggregationBuilder terms = AggregationBuilders.terms("age_bucket").field("age").size(10);
        SearchResponse response = aggrBucketService.aggrBucket(terms);
        // 获取响应中的聚合信息
        Aggregations aggregations = response.getAggregations();
        // 输出内容
        if (RestStatus.OK.equals(response.status())) {
            // 分桶
            Terms byCompanyAggregation = aggregations.get("age_bucket");
            List<? extends Terms.Bucket> buckets = byCompanyAggregation.getBuckets();
            // 输出各个桶的内容
            log.info("-------------------------------------------");
            log.info("聚合信息:");
            for (Terms.Bucket bucket : buckets) {
                log.info("桶名：{} | 总数：{}", bucket.getKeyAsString(), bucket.getDocCount());
            }
            log.info("-------------------------------------------");
        }
    }

    /**
     * 按工资范围进行聚合分桶
     */
    @Test
    public void aggrBucketRange(){
        AggregationBuilder aggr = AggregationBuilders.range("salary_range_bucket")
                .field("salary")
                .addUnboundedTo("低级员工", 3000)
                .addRange("中级员工", 5000, 9000)
                .addUnboundedFrom("高级员工", 9000);
        SearchResponse response = aggrBucketService.aggrBucket(aggr);
        // 获取响应中的聚合信息
        Aggregations aggregations = response.getAggregations();
        // 输出内容
        if (RestStatus.OK.equals(response.status())) {
            // 分桶
            Range byCompanyAggregation = aggregations.get("salary_range_bucket");
            List<? extends Range.Bucket> buckets = byCompanyAggregation.getBuckets();
            // 输出各个桶的内容
            log.info("-------------------------------------------");
            log.info("聚合信息:");
            for (Range.Bucket bucket : buckets) {
                log.info("桶名：{} | 总数：{}", bucket.getKeyAsString(), bucket.getDocCount());
            }
            log.info("-------------------------------------------");
        }
    }

    /**
     *  按照时间范围进行分桶
     */
    @Test
    public void aggrBucketDateRange() {
        AggregationBuilder aggr = AggregationBuilders.dateRange("date_range_bucket")
                .field("birthDate")
                .format("yyyy")
                .addRange("1985-1990", "1985", "1990")
                .addRange("1990-1995", "1990", "1995");
        SearchResponse response = aggrBucketService.aggrBucket(aggr);
        // 获取响应中的聚合信息
        Aggregations aggregations = response.getAggregations();
        // 输出内容
        if (RestStatus.OK.equals(response.status())) {
            // 分桶
            Range byCompanyAggregation = aggregations.get("date_range_bucket");
            List<? extends Range.Bucket> buckets = byCompanyAggregation.getBuckets();
            // 输出各个桶的内容
            log.info("-------------------------------------------");
            log.info("聚合信息:");
            for (Range.Bucket bucket : buckets) {
                log.info("桶名：{} | 总数：{}", bucket.getKeyAsString(), bucket.getDocCount());
            }
            log.info("-------------------------------------------");
        }
    }

    /**
     *  按工资多少进行聚合分桶
     */
    @Test
    public void aggrBucketHistogram(){
        AggregationBuilder aggr = AggregationBuilders.histogram("salary_histogram")
                .field("salary")
                .extendedBounds(0, 12000)
                .interval(3000);
        SearchResponse response = aggrBucketService.aggrBucket(aggr);
        // 获取响应中的聚合信息
        Aggregations aggregations = response.getAggregations();
        // 输出内容
        if (RestStatus.OK.equals(response.status())) {
            // 分桶
            Histogram byCompanyAggregation = aggregations.get("salary_histogram");
            List<? extends Histogram.Bucket> buckets = byCompanyAggregation.getBuckets();
            // 输出各个桶的内容
            log.info("-------------------------------------------");
            log.info("聚合信息:");
            for (Histogram.Bucket bucket : buckets) {
                log.info("桶名：{} | 总数：{}", bucket.getKeyAsString(), bucket.getDocCount());
            }
            log.info("-------------------------------------------");
        }
    }

    /**
     *  按出生日期进行分桶
     */
    @Test
    public void aggrBucketDateHistogram(){
        AggregationBuilder aggr = AggregationBuilders.dateHistogram("birthday_histogram")
                .field("birthDate")
                .calendarInterval(DateHistogramInterval.YEAR)
                .format("yyyy");
        SearchResponse response = aggrBucketService.aggrBucket(aggr);
        // 获取响应中的聚合信息
        Aggregations aggregations = response.getAggregations();
        // 输出内容
        if (RestStatus.OK.equals(response.status())) {
            // 分桶
            Histogram byCompanyAggregation = aggregations.get("birthday_histogram");

            List<? extends Histogram.Bucket> buckets = byCompanyAggregation.getBuckets();
            // 输出各个桶的内容
            log.info("-------------------------------------------");
            log.info("聚合信息:");
            for (Histogram.Bucket bucket : buckets) {
                log.info("桶名：{} | 总数：{}", bucket.getKeyAsString(), bucket.getDocCount());
            }
            log.info("-------------------------------------------");
        }
    }
}
```

### Metric 与 Bucket 聚合分析

#### Restful 操作示例

按照员工岁数分桶、然后统计每个岁数员工工资最高值:

```json
GET zbcn-user/_search
{
  "size": 0,
  "aggs": {
    "salary_bucket": {
      "terms": {
        "field": "age",
        "size": "10"
      },
      "aggs": {
        "salary_max_user": {
          "top_hits": {
            "size": 1,
            "sort": [
              {
                "salary": {
                  "order": "desc"
                }
              }
            ]
          }
        }
      }
    }
  }
}
```

#### Java 代码示例

```java
    /**
     * topHits 按岁数分桶、然后统计每个员工工资最高值
     */
    @Test
    public void aggregationTopHits(){
        AggregationBuilder testTop = AggregationBuilders.topHits("salary_max_user")
                .size(1)
                .sort("salary", SortOrder.DESC);
        AggregationBuilder salaryBucket = AggregationBuilders.terms("salary_bucket")
                .field("age")
                .size(10);
        salaryBucket.subAggregation(testTop);
        SearchResponse response = aggrBucketService.aggrBucket(salaryBucket);
        // 获取响应中的聚合信息
        Aggregations aggregations = response.getAggregations();
        // 输出内容
        if (RestStatus.OK.equals(response.status())) {
            // 分桶
            Terms byCompanyAggregation = aggregations.get("salary_bucket");
            List<? extends Terms.Bucket> buckets = byCompanyAggregation.getBuckets();
            // 输出各个桶的内容
            log.info("-------------------------------------------");
            log.info("聚合信息:");
            for (Terms.Bucket bucket : buckets) {
                log.info("桶名：{}", bucket.getKeyAsString());
                ParsedTopHits topHits = bucket.getAggregations().get("salary_max_user");
                for (SearchHit hit:topHits.getHits()){
                    log.info(hit.getSourceAsString());
                }
            }
            log.info("-------------------------------------------");
        }
    }
```



