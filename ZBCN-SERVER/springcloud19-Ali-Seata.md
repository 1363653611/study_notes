
---
title: Spring Cloud Alibaba：Ali-Seata
date: 2021-01-19 13:14:10
tags:
 - SpringCloud
categories:
 - SpringCloud
topdeclare: true
reward: true
---

使用Seata彻底解决Spring Cloud中的分布式事务问题！

Seata是Alibaba开源的一款分布式事务解决方案，致力于提供高性能和简单易用的分布式事务服务，本文将通过一个简单的下单业务场景来对其用法进行详细介绍。

# 什么是分布式事务问题？

## 单体应用

单体应用中，一个业务操作需要调用三个模块完成，此时数据的一致性由本地事务来保证。

![img](springcloud19-Ali-Seata/springcloud_seata_05.png)

## 微服务应用

随着业务需求的变化，单体应用被拆分成微服务应用，原来的三个模块被拆分成三个独立的应用，分别使用独立的数据源，业务操作需要调用三个服务来完成。此时每个服务内部的数据一致性由本地事务来保证，但是全局的数据一致性问题没法保证。

![img](springcloud19-Ali-Seata/springcloud_seata_06.png)

## 小结

在微服务架构中由于全局数据一致性没法保证产生的问题就是分布式事务问题。简单来说，一次业务操作需要操作多个数据源或需要进行远程调用，就会产生分布式事务问题。

# Seata简介

Seata 是一款开源的分布式事务解决方案，致力于提供高性能和简单易用的分布式事务服务。Seata 将为用户提供了 AT、TCC、SAGA 和 XA 事务模式，为用户打造一站式的分布式解决方案。

# Seata原理和设计

## 定义一个分布式事务

我们可以把一个分布式事务理解成一个包含了若干分支事务的全局事务，全局事务的职责是协调其下管辖的分支事务达成一致，要么一起成功提交，要么一起失败回滚。此外，通常分支事务本身就是一个满足ACID的本地事务。这是我们对分布式事务结构的基本认识，与 XA 是一致的。

![img](springcloud19-Ali-Seata/springcloud_seata_07.png)

## 协议分布式事务处理过程的三个组件

- Transaction Coordinator (TC)： 事务协调器，维护全局事务的运行状态，负责协调并驱动全局事务的提交或回滚；
- Transaction Manager (TM)： 控制全局事务的边界，负责开启一个全局事务，并最终发起全局提交或全局回滚的决议；
- Resource Manager (RM)： 控制分支事务，负责分支注册、状态汇报，并接收事务协调器的指令，驱动分支（本地）事务的提交和回滚。

![img](springcloud19-Ali-Seata/springcloud_seata_08.png)

## 一个典型的分布式事务过程

- TM 向 TC 申请开启一个全局事务，全局事务创建成功并生成一个全局唯一的 XID；
- XID 在微服务调用链路的上下文中传播；
- RM 向 TC 注册分支事务，将其纳入 XID 对应全局事务的管辖；
- TM 向 TC 发起针对 XID 的全局提交或回滚决议；
- TC 调度 XID 下管辖的全部分支事务完成提交或回滚请求。

![img](springcloud19-Ali-Seata/springcloud_seata_09.png)



# 启动 nacos 

这里我们使用Nacos作为注册中心，Nacos的安装及使用可以参考：[springcloud17-Ali-nacos](./springcloud17-Ali-nacos.md)

- 启动 nacos `startup.cmd  -m standalone`

# seata-server的安装与配置

## 我们先从官网下载seata-server，这里下载的是`seata-server-1.4.0.zip`，下载地址：https://github.com/seata/seata/releases

## 解压seata-server安装包到指定目录，

## 修改 register.conf 文件

> https://github.com/seata/seata/blob/develop/script/server/config/registry.conf

- 指明注册中心

```yaml
registry {
  # file,nacos,eureka,redis,zk,consul,etcd3,sofa
  type = "nacos" # 选择注册中心
  loadBalance = "RandomLoadBalance"
  loadBalanceVirtualNodes = 10

  nacos {
    application = "seata-server" 
    serverAddr = "127.0.0.1:8848"  #改为nacos的连接地址
    group = "SEATA_GROUP"
    namespace = ""
    cluster = "default"
    username = ""
    password = ""
  }
  eureka {
    serviceUrl = "http://localhost:8761/eureka"
    application = "default"
    weight = "1"
  }
  redis {
    serverAddr = "localhost:6379"
    db = 0
    password = ""
    cluster = "default"
    timeout = 0
  }
  zk {
    cluster = "default"
    serverAddr = "127.0.0.1:2181"
    sessionTimeout = 6000
    connectTimeout = 2000
    username = ""
    password = ""
  }
  consul {
    cluster = "default"
    serverAddr = "127.0.0.1:8500"
  }
  etcd3 {
    cluster = "default"
    serverAddr = "http://localhost:2379"
  }
  sofa {
    serverAddr = "127.0.0.1:9603"
    application = "default"
    region = "DEFAULT_ZONE"
    datacenter = "DefaultDataCenter"
    cluster = "default"
    group = "SEATA_GROUP"
    addressWaitTime = "3000"
  }
  file {
    name = "file.conf"
  }
}
```

- 配置中心选择1(选择 file)

```yaml
config {
  # file、nacos 、apollo、zk、consul、etcd3
  type = "file" # 选择配置类型

  nacos {
    serverAddr = "127.0.0.1:8848"
    namespace = ""
    group = "SEATA_GROUP"
    username = ""
    password = ""
  }
  consul {
    serverAddr = "127.0.0.1:8500"
  }
  apollo {
    appId = "seata-server"
    apolloMeta = "http://192.168.1.204:8801"
    namespace = "application"
    apolloAccesskeySecret = ""
  }
  zk {
    serverAddr = "127.0.0.1:2181"
    sessionTimeout = 6000
    connectTimeout = 2000
    username = ""
    password = ""
  }
  etcd3 {
    serverAddr = "http://localhost:2379"
  }
  file {
    name = "file.conf"
  }
}
```

**说明：** 

1. 如果 选择为 file ，则启用 本地的 同目录的file.conf 文件的配置

2. 如果启用 nacos,则需要 将配置导入 nacos 中



## 修改`conf`目录下的`file.conf`配置文件息（registery.conf 中config.type = 'file'）

从 https://github.com/seata/seata/tree/develop/script/server/config 复制 文件内容

- 修改 store 存储模式（我们修改为mysql 的方式存储）
- 

```properties
## transaction log store, only used in seata-server
store {
  ## store mode: file、db、redis
  mode = "db" # 修改存储模式，选择为数据库

  ## file store property
  file {
    ## store location dir
    dir = "sessionStore"
    # branch session size , if exceeded first try compress lockkey, still exceeded throws exceptions
    maxBranchSessionSize = 16384
    # globe session size , if exceeded throws exceptions
    maxGlobalSessionSize = 512
    # file buffer size , if exceeded allocate new buffer
    fileWriteBufferCacheSize = 16384
    # when recover batch read size
    sessionReloadReadSize = 100
    # async, sync
    flushDiskMode = async
  }

  ## database store property
  db {
    ## the implement of javax.sql.DataSource, such as DruidDataSource(druid)/BasicDataSource(dbcp) etc.
    datasource = "druid" # 数据源
    ## mysql/oracle/h2/oceanbase etc.
    dbType = "mysql" # 数据库类型
    driverClassName = "com.mysql.cj.jdbc.Driver"
    url = "jdbc:mysql://localhost:3306/seat-server?serverTimezone=UTC&useUnicode=true&characterEncoding=utf-8"
    user = "root"
    password = "123456"
    minConn = 1
    maxConn = 10
    globalTable = "global_table"
    branchTable = "branch_table"
    lockTable = "lock_table"
    queryLimit = 100
  }

  ## redis store property
  redis {
    host = "127.0.0.1"
    port = "6379"
    password = ""
    database = "0"
    minConn = 1
    maxConn = 10
    queryLimit = 100
  }

}

service {
  #transaction service group mapping
  vgroup_mapping.fsp_tx_group = "default" #修改事务组名称为：fsp_tx_group，和客户端自定义的名称对应
  #only support when registry.type=file, please don't set multiple addresses
  default.grouplist = "127.0.0.1:8091"
  #degrade, current not support
  enableDegrade = false
  #disable seata
  disableGlobalTransaction = false
}
```

- 由于我们使用了db模式存储事务日志，所以我们需要创建一个seat-server数据库，[建表sql](https://github.com/seata/seata/edit/develop/script/server/db/mysql.sql)在seata-server的`/lib/script/server.sql`中；

## 使用nacos 的配置中心

1. 从 官网的提交[配置中心script](https://github.com/seata/seata/tree/develop/script/config-center)(**config-center**) 中下载 config.txt 文件(本地位置：/lib/script/config-center)。然后修改对应配置。

2. 使用 官网提供的脚本，将 配置批量导入 nacos 配置中心。

   1. 下载 config.txt:https://github.com/seata/seata/tree/develop/script/config-center/config.txt
   2. 下载 配置导入脚本：https://github.com/seata/seata/tree/develop/script/config-center/nacos
   3. 我们使用python 来导入： `python nacos-config.py localhost:8848`
   4. 导入成功后在配置列表可看到相关信息

   ![image-20201222164020180](springcloud19-Ali-Seata/image-20201222164020180.png)

   

- 则 seata-server 使用了 配置中心的数据来启动

## 启动 seata-server

使用seata-server中`/bin/seata-server.bat`文件启动seata-server

 **注意**：

- 启动 seata-server 前，如果使用 数据库模式，启动前先 将 jdbc 包下的数据库链接驱动依据实际数据库的版本选择对应的，然后移动到lib 下面。

# 数据库准备

## 创建业务数据库

- seat-order：存储订单的数据库；
- seat-storage：存储库存的数据库；
- seat-account：存储账户信息的数据库。

### 初始化业务表

#### order表

```sql
CREATE TABLE `order` (
  `id` bigint(11) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(11) DEFAULT NULL COMMENT '用户id',
  `product_id` bigint(11) DEFAULT NULL COMMENT '产品id',
  `count` int(11) DEFAULT NULL COMMENT '数量',
  `money` decimal(11,0) DEFAULT NULL COMMENT '金额',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

ALTER TABLE `order` ADD COLUMN `status` int(1) DEFAULT NULL COMMENT '订单状态：0：创建中；1：已完结' AFTER `money` ;
```

#### storage表

```sql
CREATE TABLE `storage` (
                         `id` bigint(11) NOT NULL AUTO_INCREMENT,
                         `product_id` bigint(11) DEFAULT NULL COMMENT '产品id',
                         `total` int(11) DEFAULT NULL COMMENT '总库存',
                         `used` int(11) DEFAULT NULL COMMENT '已用库存',
                         `residue` int(11) DEFAULT NULL COMMENT '剩余库存',
                         PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

INSERT INTO `seat-storage`.`storage` (`id`, `product_id`, `total`, `used`, `residue`) VALUES ('1', '1', '100', '0', '100');
```

#### account表

```sql
CREATE TABLE `account` (
  `id` bigint(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `user_id` bigint(11) DEFAULT NULL COMMENT '用户id',
  `total` decimal(10,0) DEFAULT NULL COMMENT '总额度',
  `used` decimal(10,0) DEFAULT NULL COMMENT '已用余额',
  `residue` decimal(10,0) DEFAULT '0' COMMENT '剩余可用额度',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

INSERT INTO `seat-account`.`account` (`id`, `user_id`, `total`, `used`, `residue`) VALUES ('1', '1', '1000', '0', '1000');
```

# 创建日志回滚表

使用Seata还需要在客户端每个数据库中创建[日志表](https://github.com/seata/seata/blob/develop/script/client/at/db/mysql.sql)，建表sql在seata-server的`/lib/script/undo_log.sql`中

## 完整数据库示意图

![image-20201217164806650](springcloud19-Ali-Seata/image-20201217164806650.png)

## 制造一个分布式事务问题

这里我们会创建三个服务，一个订单服务，一个库存服务，一个账户服务。当用户下单时，会在订单服务中创建一个订单，然后通过远程调用库存服务来扣减下单商品的库存，再通过远程调用账户服务来扣减用户账户里面的余额，最后在订单服务中修改订单状态为已完成。该操作跨越三个数据库，有两次远程调用，很明显会有分布式事务问题。

# 客户端配置

对seata-order-service、seata-storage-service和seata-account-service三个seata的客户端进行配置，它们配置大致相同，我们下面以seata-order-service的配置为例；

## 引入相关jar包：



```xml
 
<!--nacos -->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
</dependency>

 <!-- seata
在 properties 属性中添加
<seata.version>1.3.0</seata.version>
-->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-seata</artifactId>
    <exclusions>
        <exclusion>
            <groupId>io.seata</groupId>
            <artifactId>seata-spring-boot-starter</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>io.seata</groupId>
    <artifactId>seata-spring-boot-starter</artifactId>
    <version>${seata.version}</version>
</dependency>

 <!--数据源-->
<!--mysql-druid-->
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>druid-spring-boot-starter</artifactId>
    <version>1.1.10</version>
</dependency>
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>2.1.4</version>
</dependency>

<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <scope>runtime</scope>
</dependency>
<!--feign -->
 <dependency>
     <groupId>org.springframework.cloud</groupId>
     <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```

## application.yml 配置

### 添加数据源

```yaml
spring:
  datasource: # 数据源配置
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/seat-account?serverTimezone=UTC&useUnicode=true&characterEncoding=utf-8
    password: 123456
    username: root
```



### 添加 nacos 注册功能

```yaml
spring:  
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848 #配置Nacos地址
        group: BUSINESS-GROUP
```



### 修改application.yml文件，添加 seata 功能

```yaml
# 分布式事物
seata:
  enabled: true
  application-id: seata-order-service
  tx-service-group: fsp_tx_group
  enable-auto-data-source-proxy: true
  config:
    type: nacos
    nacos:
      namespace:
      serverAddr: 127.0.0.1:8848
      group: SEATA_GROUP
      username: "nacos"
      password: "nacos"
  registry:
    type: nacos
    nacos:
      application: seata-server
      server-addr: 127.0.0.1:8848
      group: SEATA_GROUP
      namespace:
      username: "nacos"
      password: "nacos"
```

**如果使用以上配置，则无需在项目中添加  `registry.conf` 和 `file.conf`**

- https://gitee.com/itCjb/spring-cloud-alibaba-seata-demo

### ~~在项目的reources文件夹下 添加 registry.conf 和  file.conf文件(可选 )~~

> 如果不配置 seata 相关信息，则需要通过 文件的方式，则需要 配置如下信息

- 如果 在registry.conf 中 的 `config.type = 'file'`, 则需要在 项目的 resources 文件夹中添加  file.conf 
- 如果 在registry.conf 中 的 `config.type = 'nacos'`, 则使用nacos中的配置，则需要在 项目的 resources 文件夹中无需添加  file.conf 

源配置文件路径： https://github.com/seata/seata/tree/develop/script/client/conf

- 添加并修改file.conf配置文件，主要是修改自定义事务组名称；

```properties
service {
  #vgroup->rgroup
  vgroup_mapping.fsp_tx_group = "default" #修改自定义事务组名称
  #only support single node
  default.grouplist = "127.0.0.1:8091"
  #degrade current not support
  enableDegrade = false
  #disable
  disable = false
  #unit ms,s,m,h,d represents milliseconds, seconds, minutes, hours, days, default permanent
  max.commit.retry.timeout = "-1"
  max.rollback.retry.timeout = "-1"
  disableGlobalTransaction = false
}
```

- 添加并修改registry.conf配置文件，主要是将注册中心改为nacos；

```properties
registry {
  # file 、nacos 、eureka、redis、zk
  type = "nacos" #修改为nacos

  nacos {
    serverAddr = "localhost:8848" #修改为nacos的连接地址
    namespace = ""
    cluster = "default"
  }
}
```

## 在启动类中取消数据源的自动创建：启用自定义的数据源

```java
@SpringBootApplication(exclude = DataSourceAutoConfiguration.class)
@EnableDiscoveryClient
@EnableFeignClients
public class SeataOrderServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(SeataOrderServiceApplication.class, args);
    }

}
```

## 编写自定义数据源

```java
/**
 *  使用Seata对数据源进行代理
 *  <br/>
 *  @since  2020/12/21 13:41
 */
@Configuration
public class DataSourceProxyConfig {

    @Value("${mybatis.mapperLocations}")
    private String mapperLocations;

    @Bean
    @ConfigurationProperties(prefix = "spring.datasource")
    public DataSource druidDataSource(){
        return new DruidDataSource();
    }

    @Bean
    public DataSourceProxy dataSourceProxy(DataSource dataSource) {
        return new DataSourceProxy(dataSource);
    }

    @Bean
    public SqlSessionFactory sqlSessionFactoryBean(DataSourceProxy dataSourceProxy) throws Exception {
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSourceProxy);
        sqlSessionFactoryBean.setMapperLocations(new PathMatchingResourcePatternResolver()
                .getResources(mapperLocations));
        sqlSessionFactoryBean.setTransactionFactory(new SpringManagedTransactionFactory());
        return sqlSessionFactoryBean.getObject();
    }
}
```

## 编写 申明式调用方法，完成微服务之间的调用

```java
@FeignClient(value = "seata-account-service")
public interface AccountService {
    /**
     * 扣减账户余额
     */
    @RequestMapping("/account/decrease")
    ResponseResult decrease(@RequestParam("userId") Long userId, @RequestParam("money") BigDecimal money);
}

@FeignClient(value = "seata-storage-service")
public interface StorageService {
    /**
     * 扣减库存
     */
    @GetMapping(value = "/storage/decrease")
    ResponseResult decrease(@RequestParam("productId") Long productId, @RequestParam("count") Integer count);
}
```



## 编写创建订单入口方法，并且在 方法上添加 `@GlobalTransactional(name = "fsp-create-order",rollbackFor = Exception.class)` 注解

```java
@Slf4j
@Service
public class OrderServiceImpl implements OrderService {

    @Autowired
    private OrderDao orderDao;
    @Autowired
    private StorageService storageService;
    @Autowired
    private AccountService accountService;

    /**
     * 创建订单->调用库存服务扣减库存->调用账户服务扣减账户余额->修改订单状态
     */
    @GlobalTransactional(name = "fsp-create-order",rollbackFor = Exception.class)
    @Override
    public void create(Order order) {
        log.info("------->下单开始");
        //本应用创建订单
        orderDao.create(order);

        //远程调用库存服务扣减库存
        log.info("------->order-service中扣减库存开始");
        storageService.decrease(order.getProductId(),order.getCount());
        log.info("------->order-service中扣减库存结束");

        //远程调用账户服务扣减余额
        log.info("------->order-service中扣减余额开始");
        accountService.decrease(order.getUserId(),order.getMoney());
        log.info("------->order-service中扣减余额结束");

        //修改订单状态为已完成
        log.info("------->order-service中修改订单状态开始");
        orderDao.update(order.getUserId(),0);
        log.info("------->order-service中修改订单状态结束");

        log.info("------->下单结束");
    }
}
```

## 编写 web 访问入口

```java
@RestController
@RequestMapping(value = "/order")
public class OrderController {
    @Autowired
    private OrderService orderService;

    /**
     * 创建订单
     */
    @GetMapping("/create")
    public ResponseResult create(Order order) {
        orderService.create(order);
        return ResponseResult.success("订单创建成功!");
    }
}
```

# 分别按照以上方式 创建 seate-storage-service  和 seata-account-service 服务

# 分布式事务功能演示

调用接口进行下单操作后查看数据库：http://localhost:8180/order/create?userId=1&productId=1&count=10&money=100

# 使用到的模块

```shell
ZBCN-SERVER
├── zbcn-nacos/lib/nacos-server-1.4.0.zip -- 注册监控主服务
├── zbcn-seata/lib/seata-1.4.0 -- 分布式事物服务
├── zbcn-seata/ seate-order-service  -- 整合了seata的订单服务
├── zbcn-seata/ seate-storage-service -- 整合了seata的库存服务
└── zbcn-seata/seata-account-service -- 整合了seata的账户服务
```



