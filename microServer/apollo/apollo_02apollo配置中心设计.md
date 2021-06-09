# Core Concepts 核心概念

## application (应用)

- 实际使用配置的应用，Apollo客户端在运行时需要知道当前应用是谁，从而可以去获取对应的配置
- 每个应用都需要有唯一的身份标识 -- appId，我们认为应用身份是跟着代码走的，所以需要在代码中配置，具体信息请参见[Java客户端使用指南](https://github.com/ctripcorp/apollo/wiki/Java客户端使用指南)。

## environment (环境)

- 配置对应的环境，Apollo客户端在运行时需要知道当前应用处于哪个环境，从而可以去获取应用的配置
- 我们认为环境和代码无关，同一份代码部署在不同的环境就应该能够获取到不同环境的配置
- 所以环境默认是通过读取机器上的配置（server.properties中的env属性）指定的，不过为了开发方便，我们也支持运行时通过System Property等指定，具体信息请参见[Java客户端使用指南](https://github.com/ctripcorp/apollo/wiki/Java客户端使用指南)。

## cluster (集群)

- 一个应用下不同实例的分组，比如典型的可以按照数据中心分，把上海机房的应用实例分为一个集群，把北京机房的应用实例分为另一个集群。
- 对不同的cluster，同一个配置可以有不一样的值，如zookeeper地址。
- 集群默认是通过读取机器上的配置（server.properties中的idc属性）指定的，不过也支持运行时通过System Property指定，具体信息请参见[Java客户端使用指南](https://github.com/ctripcorp/apollo/wiki/Java客户端使用指南)。

##  namespace (命名空间)

- 一个应用下不同配置的分组，可以简单地把namespace类比为文件，不同类型的配置存放在不同的文件中，如数据库配置文件，RPC配置文件，应用自身的配置文件等
- 应用可以直接读取到公共组件的配置namespace，如DAL，RPC等
- 应用也可以通过继承公共组件的配置namespace来对公共组件的配置做调整，如DAL的初始数据库连接数

# 自定义Cluster

# 总体设计

![img](D:\ZBCN\study_notes\apollo\apollo_02apollo配置中心设计\总体设计.png)

- Config Service提供配置的读取、推送等功能，服务对象是Apollo客户端
- Admin Service提供配置的修改、发布等功能，服务对象是Apollo Portal（管理界面）
- Config Service和Admin Service都是多实例、无状态部署，所以需要将自己注册到Eureka中并保持心跳
- 在Eureka之上我们架了一层Meta Server用于封装Eureka的服务发现接口
- Client通过域名访问Meta Server获取Config Service服务列表（IP+Port），而后直接通过IP+Port访问服务，同时在Client侧会做load balance、错误重试
- Portal通过域名访问Meta Server获取Admin Service服务列表（IP+Port），而后直接通过IP+Port访问服务，同时在Portal侧会做load balance、错误重试
- 为了简化部署，我们实际上会把Config Service、Eureka和Meta Server三个逻辑角色部署在同一个JVM进程中

## 基础模型

如下即是Apollo的基础模型：

1. 用户在配置中心对配置进行修改并发布
2. 配置中心通知Apollo客户端有配置更新
3. Apollo客户端从配置中心拉取最新的配置、更新本地配置并通知到应用

![basic-architecture](apollo_02apollo配置中心设计\basic-architecture.png)

## 各个模块的概要介绍

### Config Service

- 提供配置获取接口
- 提供配置更新推送接口（基于Http long polling）
  - 服务端使用[Spring DeferredResult](http://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/context/request/async/DeferredResult.html)实现异步化，从而大大增加长连接数量
  - 目前使用的tomcat embed默认配置是最多10000个连接（可以调整），使用了4C8G的虚拟机实测可以支撑10000个连接，所以满足需求（一个应用实例只会发起一个长连接）。
- 接口服务对象为Apollo客户端

### Admin Service

- 提供配置管理接口
- 提供配置修改、发布等接口
- 接口服务对象为Portal

### Meta Server

- Portal通过域名访问Meta Server获取Admin Service服务列表（IP+Port）
- Client通过域名访问Meta Server获取Config Service服务列表（IP+Port）
- Meta Server从Eureka获取Config Service和Admin Service的服务信息，相当于是一个Eureka Client
- 增设一个Meta Server的角色主要是为了封装服务发现的细节，对Portal和Client而言，永远通过一个Http接口获取Admin Service和Config Service的服务信息，而不需要关心背后实际的服务注册和发现组件
- **Meta Server只是一个逻辑角色**，在部署时和Config Service是在一个JVM进程中的，所以IP、端口和Config Service一致

### Eureka

- 基于[Eureka](https://github.com/Netflix/eureka)和[Spring Cloud Netflix](https://cloud.spring.io/spring-cloud-netflix/)提供服务注册和发现
- Config Service和Admin Service会向Eureka注册服务，并保持心跳
- 为了简单起见，目前Eureka在部署时和Config Service是在一个JVM进程中的（通过Spring Cloud Netflix）

### Portal

- 提供Web界面供用户管理配置
- 通过Meta Server获取Admin Service服务列表（IP+Port），通过IP+Port访问服务
- 在Portal侧做load balance、错误重试

### Client

- Apollo提供的客户端程序，为应用提供配置获取、实时更新等功能
- 通过Meta Server获取Config Service服务列表（IP+Port），通过IP+Port访问服务
- 在Client侧做load balance、错误重试

## E-R Diagram

![image-20210526130301880](apollo_02apollo配置中心设计\image-20210526130301880.png)

- App
  - App信息
- AppNamespace
  - App下Namespace的元信息
- Cluster
  - 集群信息
- Namespace
  - 集群下的namespace
- Item
  - Namespace的配置，每个Item是一个key, value组合
- Release
  - Namespace发布的配置，每个发布包含发布时该Namespace的所有配置
- Commit
  - Namespace下的配置更改记录
- Audit
  - 审计信息，记录用户在何时使用何种方式操作了哪个实体。

## 权限相关E-R Diagram

![image-20210526130635420](apollo_02apollo配置中心设计\image-20210526130635420-1622005602115.png)

- User

  - Apollo portal用户

- UserRole

  - 用户和角色的关系

- Role

  - 角色

- RolePermission

  - 角色和权限的关系

- Permission

  - 权限
  - 对应到具体的实体资源和操作，如修改NamespaceA的配置，发布NamespaceB的配置等。

- Consumer

  - 第三方应用

- ConsumerToken

  - 发给第三方应用的token

- ConsumerRole

  - 第三方应用和角色的关系

- ConsumerAudit

  - 第三方应用访问审计

  

## 服务端设计

### 配置发布后的实时推送设计

在配置中心中，一个重要的功能就是配置发布后实时推送到客户端。下面我们简要看一下这块是怎么设计实现的。

![image-20210526131113581](apollo_02apollo配置中心设计\image-20210526131113581.png)

上图简要描述了配置发布的大致过程：

1. 用户在Portal操作配置发布
2. Portal调用Admin Service的接口操作发布
3. Admin Service发布配置后，发送ReleaseMessage给各个Config Service
4. Config Service收到ReleaseMessage后，通知对应的客户端

#### 发送ReleaseMessage的实现方式

Admin Service在配置发布后，需要通知所有的Config Service有配置发布，从而Config Service可以通知对应的客户端来拉取最新的配置。

从概念上来看，这是一个典型的消息使用场景，Admin Service作为producer发出消息，各个Config Service作为consumer消费消息。通过一个消息组件（Message Queue）就能很好的实现Admin Service和Config Service的解耦。

在实现上，考虑到Apollo的实际使用场景，以及为了尽可能减少外部依赖，我们没有采用外部的消息中间件，而是通过数据库实现了一个简单的消息队列。

实现方式如下：

1. Admin Service在配置发布后会往ReleaseMessage表插入一条消息记录，消息内容就是配置发布的AppId+Cluster+Namespace，参见[DatabaseMessageSender](https://github.com/ctripcorp/apollo/blob/master/apollo-biz/src/main/java/com/ctrip/framework/apollo/biz/message/DatabaseMessageSender.java)
2. Config Service有一个线程会每秒扫描一次ReleaseMessage表，看看是否有新的消息记录，参见[ReleaseMessageScanner](https://github.com/ctripcorp/apollo/blob/master/apollo-biz/src/main/java/com/ctrip/framework/apollo/biz/message/ReleaseMessageScanner.java)
3. Config Service如果发现有新的消息记录，那么就会通知到所有的消息监听器（[ReleaseMessageListener](https://github.com/ctripcorp/apollo/blob/master/apollo-biz/src/main/java/com/ctrip/framework/apollo/biz/message/ReleaseMessageListener.java)），如[NotificationControllerV2](https://github.com/ctripcorp/apollo/blob/master/apollo-configservice/src/main/java/com/ctrip/framework/apollo/configservice/controller/NotificationControllerV2.java)，消息监听器的注册过程参见[ConfigServiceAutoConfiguration](https://github.com/ctripcorp/apollo/blob/master/apollo-configservice/src/main/java/com/ctrip/framework/apollo/configservice/ConfigServiceAutoConfiguration.java)
4. NotificationControllerV2得到配置发布的AppId+Cluster+Namespace后，会通知对应的客户端

 示意图如下：

![image-20210526131400565](apollo_02apollo配置中心设计\image-20210526131400565-1622006043464.png)

### Config Service通知客户端的实现方式

上一节中简要描述了NotificationControllerV2是如何得知有配置发布的，那NotificationControllerV2在得知有配置发布后是如何通知到客户端的呢？

实现方式如下：

1. 客户端会发起一个Http请求到Config Service的`notifications/v2`接口，也就是[NotificationControllerV2](https://github.com/ctripcorp/apollo/blob/master/apollo-configservice/src/main/java/com/ctrip/framework/apollo/configservice/controller/NotificationControllerV2.java)，参见[RemoteConfigLongPollService](https://github.com/ctripcorp/apollo/blob/master/apollo-client/src/main/java/com/ctrip/framework/apollo/internals/RemoteConfigLongPollService.java)
2. NotificationControllerV2不会立即返回结果，而是通过[Spring DeferredResult](http://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/context/request/async/DeferredResult.html)把请求挂起
3. 如果在60秒内没有该客户端关心的配置发布，那么会返回Http状态码304给客户端
4. 如果有该客户端关心的配置发布，NotificationControllerV2会调用DeferredResult的[setResult](http://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/context/request/async/DeferredResult.html#setResult-T-)方法，传入有配置变化的namespace信息，同时该请求会立即返回。客户端从返回的结果中获取到配置变化的namespace后，会立即请求Config Service获取该namespace的最新配置。

## 客户端设计

![image-20210526131659982](apollo_02apollo配置中心设计\image-20210526131659982-1622006222069.png)

上图简要描述了Apollo客户端的实现原理：

1. 客户端和服务端保持了一个长连接，从而能第一时间获得配置更新的推送。（通过Http Long Polling实现）
2. 客户端还会定时从Apollo配置中心服务端拉取应用的最新配置。
   - 这是一个fallback机制，为了防止推送机制失效导致配置不更新
   - 客户端定时拉取会上报本地版本，所以一般情况下，对于定时拉取的操作，服务端都会返回304 - Not Modified
   - 定时频率默认为每5分钟拉取一次，客户端也可以通过在运行时指定System Property: `apollo.refreshInterval`来覆盖，单位为分钟。
3. 客户端从Apollo配置中心服务端获取到应用的最新配置后，会保存在内存中
4. 客户端会把从服务端获取到的配置在本地文件系统缓存一份
   - 在遇到服务不可用，或网络不通的时候，依然能从本地恢复配置
5. 应用程序可以从Apollo客户端获取最新的配置、订阅配置更新通知

## 和Spring 的集成原理

Apollo除了支持API方式获取配置，也支持和Spring/Spring Boot集成，集成原理简述如下。

Spring从3.1版本开始增加了`ConfigurableEnvironment`和`PropertySource`：

- ConfigurableEnvironment
  - Spring的ApplicationContext会包含一个Environment（实现ConfigurableEnvironment接口）
  - ConfigurableEnvironment自身包含了很多个PropertySource
- PropertySource
  - 属性源
  - 可以理解为很多个Key - Value的属性配置

在运行时的结构形如：

![image-20210526140534362](apollo_02apollo配置中心设计\image-20210526140534362-1622009136861.png)

需要注意的是，PropertySource之间是有优先级顺序的，如果有一个Key在多个property source中都存在，那么在前面的property source优先。

所以对上图的例子：

- env.getProperty(“key1”) -> value1
- **env.getProperty(“key2”) -> value2**
- env.getProperty(“key3”) -> value4

在理解了上述原理后，Apollo和Spring/Spring Boot集成的手段就呼之欲出了：在应用启动阶段，Apollo从远端获取配置，然后组装成PropertySource并插入到第一个即可，如下图所示：

## 可用性考虑

|                        |                                      |                                                              |                                                              |
| ---------------------- | ------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 场景                   | 影响                                 | 降级                                                         | 原因                                                         |
| 某台Config Service下线 | 无影响                               |                                                              | Config Service无状态，客户端重连其它Config Service           |
| 所有Config Service下线 | 客户端无法读取最新配置，Portal无影响 | 客户端重启时，可以读取本地缓存配置文件。如果是新扩容的机器，可以从其它机器上获取已缓存的配置文件，具体信息可以参考[Java客户端使用指南 - 1.2.3 本地缓存路径](https://github.com/ctripcorp/apollo/wiki/Java客户端使用指南#123-本地缓存路径) |                                                              |
| 某台Admin Service下线  | 无影响                               |                                                              | Admin Service无状态，Portal重连其它Admin Service             |
| 所有Admin Service下线  | 客户端无影响，Portal无法更新配置     |                                                              |                                                              |
| 某台Portal下线         | 无影响                               |                                                              | Portal域名通过SLB绑定多台服务器，重试后指向可用的服务器      |
| 全部Portal下线         | 客户端无影响，Portal无法更新配置     |                                                              |                                                              |
| 某个数据中心下线       | 无影响                               |                                                              | 多数据中心部署，数据完全同步，Meta Server/Portal域名通过SLB自动切换到其它存活的数据中心 |
| 数据库宕机             | 客户端无影响，Portal无法更新配置     | Config Service开启[配置缓存](https://github.com/ctripcorp/apollo/wiki/分布式部署指南#3config-servicecacheenabled---是否开启配置缓存)后，对配置的读取不受数据库宕机影响 |                                                              |

## 监控相关

## 5.1 Tracing

### 5.1.1 CAT

Apollo客户端和服务端目前支持[CAT](https://github.com/dianping/cat)自动打点，所以如果自己公司内部部署了CAT的话，只要引入cat-client后Apollo就会自动启用CAT打点。

如果不使用CAT的话，也不用担心，只要不引入cat-client，Apollo是不会启用CAT打点的。

Apollo也提供了Tracer相关的SPI，可以方便地对接自己公司的监控系统。

更多信息，可以参考[v0.4.0 Release Note](https://github.com/ctripcorp/apollo/releases/tag/v0.4.0)

### 5.1.2 SkyWalking

可以参考[@hepyu](https://github.com/hepyu)贡献的[apollo-skywalking-pro样例](https://github.com/hepyu/k8s-app-config/tree/master/product/standard/apollo-skywalking-pro)。

## 5.2 Metrics

从1.5.0版本开始，Apollo服务端支持通过`/prometheus`暴露prometheus格式的metrics，如`http://${someIp:somePort}/prometheus`



## 参考

- https://github.com/ctripcorp/apollo/wiki/Apollo%E9%85%8D%E7%BD%AE%E4%B8%AD%E5%BF%83%E8%AE%BE%E8%AE%A1
- 

