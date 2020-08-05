# 什么是微服务

- 微服务是架构上的一种设计风格。主旨是将原本的单体服务拆分成多个小型服务。每个小型服务都在各自的进程中独自的运行。服务之间通过通过基于HTTP 的restful API 进行通讯协作。
- 每个小型服务都在围绕着系统中的某一项或者一些耦合度较高的业务功能进行构建。
- 每个服务都维护者自身的数据存储，业务开发，自动化测试以及独立部署机制。
- 因为轻量级的通讯协议支持，每个服务可以使用不同的语言来编写。

## 与单体服务的区别
- 单体维护困难，修改小功能，可能影响整个系统。每个功能模块的对资源的消耗，并发量都不尽相同。无法按照业务去分配资源。（__一个系统包含了所有的功能模块__）
- 微服务，将不同的模块拆分成不同的服务。每个服务单独的部署和扩展，每个服务的更新不会影响其他服务。
## 如何试试微服务

###　技术要求

- 运维的新挑战
- 接口的一致性
- 分布式的复杂性：网络延时，分布式事物，异步消息。。。。

### 微服务架构的九大特性

- 服务组件化
- 按业务组织团队
- 做“产品”的态度
- 智能端点与哑管道
  - 微服务架构中，通常使用的两种服务调用方式
    - http 的restful API 或者轻量级的消息发送协议
    - 通过轻量级的消息总线上传递消息：如 MQ（RabbitMq，RocketMQ，kafka，）提供异步的消息传递与服务触发
- 去中心化治理
- 去中心化管理数据

> 在微服务架构中，我们更强调服务之间“无事物”的调用，而对于数据的一致性问题，只要求数据在最后的处理状态是一直的即可。若在过程中发现错误，通过补偿机制来进行处理。使得错误数据最终能达到一致性。

- 基础设施的自动化

  - **持续交付，持续集成**
  - 自动化测试
  - 自动化部署

- 容错设计

  > 通常，我们希望每个服务中集成监控和日志记录的组件，比如：服务状态，断路器状态，吞吐量，网络延迟等关键数据的仪表盘等可视化。

- 演进式设计

# 为何选择 springCloud

- 服务治理
- 分布式服务配置管理
- 批量任务
- 服务跟踪
- 。。。。。

# Spring cloud 简介

spring clooud 是一个基于springboot 实现的微服务架构开发工具。涉及的内容有：配置服务管理，服务治理，断路器，智能路由，微代理，控制总线，全局锁，决策竞选，分布式会话，集群状态管理等

## spring cloud涉及到的子项目

### Spring  Cloud  Config： 配置管理工具

### Spring Cloud Netfix 核心组件

#### Eureka 服务治理组件

#### Hystrix 容错管理组件

#### Ribbon 客户端负载均衡的服务调用组件

####　Feign　基于Ribbon 和 Hystrix 的申明式服务调用组件

#### Zuul 网关组件，提供只能路由，访问过滤等功能

#### Archaius 外部配置关键

###　Spring Cloud Bus 事件，消息总线

- 用于传播集群中的状态变化或者事件，触发后续的处理，比如用来动态刷新配置等。

### Spring  Cloud Cluster

- 针对 zookeeper，Redis，Hazlcast，Console 的选举算法和通用的状态模式实现。

### Spring Cloud Cloudfoundry：提供Pivotal Cloudfoundry 的整合支持

### Spring Cloud Console： 服务发现与配置管理工具

###  Spring Cloud  Stream 

- 通过Redis，Rabbit 或者 Kafka 实现的消费微服务，可以通过简单的声明式模型发送和接受消息

### Spring Cloud AWS : 用于简化Amazon Web Service 的组件

###　Spring Cloud Security:

- 安全工具包,提供在zuul代理中对OAtuh2 客户端请求的中继器

### Spring Cloud Sleuth: 

- spring cloud 应用的分布式跟踪实现，完美整合Zipkin

### Spring Cloud ZooKeeper 

- 基于ZooKeeper 的服务发现与配置管理组件

### Spring Cloud Starts 

- springCloud的基础组件，他是基于springboot 风格项目的基础依赖组件

### Spring Cloud CLI

- 用于 Groovy 中快速创建Spring Cloud 应用的Spring Boot CLI 插件

。。。。

# 版本说明

spring cloud 的版本号采用了伦敦地铁站的名字，依据字母表的顺序来对应版本的顺序。