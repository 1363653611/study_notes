## RabbitMQ 简介

---
title: RabbitMQ 简介
date: 2020-02-11 10:14:10
tags:
  - mq
categories:
  - mq
topdeclare: true
reward: true
---

官方推出的六种模式
### 1.1 "Hello World!"
![在这里插入图片描述](./imgs/20190720145646828.png)
###### 简单模式 一对一生产消费

<!--more-->

### 1.2 Work Queues
![在这里插入图片描述](./imgs/20190720145947947.png)
###### 一个生产者对应多个消费队列
###### 默认情况下，RabbitMQ将按顺序将每条消息发送给下一个消费者。平均而言，每个消费者将获得相同数量的消息

### 1.3 Publish/Subscribe
![在这里插入图片描述](./imgs/2019072015044025.png)
###### 订阅发布：多个队列订阅一个交换机，每个队列都会接收到自己订阅的交换机

### 1.4 Routing
![在这里插入图片描述](./imgs/2019072015100250.png)
###### 路由模式：对消息进行过滤，把控消费队列获取消息的信息量

### 1.5 Topics
![在这里插入图片描述](./imgs/20190720151402627.png)
###### 订阅发布

## 二、AMQP模式
![full stack developer tutorial](./imgs/AMQP.png)

#### RabiitMQ Kafka RocketMQ 性能对比

###### Kafka
Kafka的吞吐量高达17.3w/s，不愧是高吞吐量消息中间件的行业老大。
这主要取决于它的队列模式保证了写磁盘的过程是线性IO。此时broker磁盘IO已达瓶颈。

###### RocketMQ
RocketMQ也表现不俗，吞吐量在11.6w/s，磁盘IO %util已接近100%。
RocketMQ的消息写入内存后即返回ack，由单独的线程专门做刷盘的操作，所有的消息均是顺序写文件。

###### RabbitMQ
RabbitMQ的吞吐量5.95w/s，CPU资源消耗较高。它支持AMQP协议，实现非常重量级，
为了保证消息的可靠性在吞吐量上做了取舍。我们还做了RabbitMQ在消息持久化场景下的性能测试，吞吐量在2.6w/s左右。

#### **测试结论**
![full stack developer tutorial](./imgs/20170604013849172.png)
###### 在服务端处理同步发送的性能上，Kafka>RocketMQ>RabbitMQ。
###### 测试环境
###### 服务端为单机部署，机器配置如下：
![在这里插入图片描述](./imgs/20170604013940344.png)

##### 应用版本：
![在这里插入图片描述](./imgs/20170604014004240.png)

##### 测试脚本
![在这里插入图片描述](./imgs/20170604014019485.png)
###### 原文链接：https://blog.csdn.net/yunfeng482/article/details/72856762

## 三、MQ应用场景
### 3.1用户注册后，需要发注册邮件和注册短信,传统的做法有两种
#### (1)串行方式:将注册信息写入数据库后,发送注册邮件,再发送注册短信,以上三个任务全部完成后才返回给客户端。
- 这有一个问题是,邮件,短信并不是必须的,它只是一个通知,而这种做法让客户端等待没有必要等待的东西.
 ![在这里插入图片描述](./imgs/20170209145852454.png)
#### (2)并行方式:将注册信息写入数据库后,发送邮件的同时,发送短信,以上三个任务完成后,返回给客户端,并行的方式能提高处理的时间。
 ![在这里插入图片描述](./imgs/20170209150218755.png)
- 假设三个业务节点分别使用50ms,串行方式使用时间150ms,并行使用时间100ms。
- 虽然并性已经提高的处理时间,但是,前面说过,邮件和短信对我正常的使用网站没有任何影响，
- 客户端没有必要等着其发送完成才显示注册成功,英爱是写入数据库后就返回.  
#### (3)消息队列
- 引入消息队列后，把发送邮件,短信不是必须的业务逻辑异步处理
 ![在这里插入图片描述](./imgs/20170209150824008.png)
- 由此可以看出,引入消息队列后，用户的响应时间就等于写入数据库的时间+写入消息队列的时间(可以忽略不计),引入消息队列后处理后,响应时间是串行的3倍,是并行的2倍。`

### 3.2 应用解耦
#### 场景：双11是购物狂节,用户下单后,订单系统需要通知库存系统.
##### 传统的做法就是订单系统调用库存系统的接口.
![这里是插入图片描述](./imgs/20170209151602258.png)
- 这种做法有一个缺点:
    1. 当库存系统出现故障时,订单就会失败。
    2. 订单系统和库存系统高耦合. `
##### 引入消息队列
![这里是插入图片描述](./imgs/20170209152116530.png)
- 订单系统:用户下单后,订单系统完成持久化处理,将消息写入消息队列,返回用户订单下单成功。
- 库存系统:订阅下单的消息,获取下单消息,进行库操作。
- 就算库存系统出现故障,消息队列也能保证消息的可靠投递,不会导致消息丢失。
### 2.3流量削峰
流量削峰一般在秒杀活动中应用广泛
#### 场景:秒杀活动，一般会因为流量过大，导致应用挂掉,为了解决这个问题，一般在应用前端加入消息队列。
##### 作用:
  1. 可以控制活动人数，超过此一定阀值的订单直接丢弃(我为什么秒杀一次都没有成功过呢^^)
  2. 可以缓解短时间的高流量压垮应用(应用程序按自己的最大处理能力获取订单)
![这里是插入图片描述](./imgs/20170209161124911.png)     
1. 用户的请求,服务器收到之后,首先写入消息队列,加入消息队列长度超过最大值,则直接抛弃用户请求或跳转到错误页面.
2. 秒杀业务根据消息队列中的请求信息，再做后续处理.
###### 原文链接：https://blog.csdn.net/qq_38455201/article/details/80308771

### 四、RabbitMQ 消息传递流程
![full stack developer tutorial](./imgs/RabbitMQ消息传流程.png)

## 五、RabbitMQ可靠性投递，防止重复消费设计
![这里是插入图片描述](./imgs/2019090914591336.png)
原图地址:https://blog.csdn.net/weixin_38937840/article/details/100662457
## SQL
    案例sql在doc下SQL小的mysqlinit.sql内
## 配置介绍
springamqp介绍[https://docs.spring.io/spring-amqp/docs/1.5.6.RELEASE/reference/html/_reference.html#template-confirms][]
org.springframework.boot.autoconfigure.amqp.RabbitProperties 这里是详细的spring配置
### base
    spring.rabbitmq.host: 服务Host
    spring.rabbitmq.port: 服务端口
    spring.rabbitmq.username: 登陆用户名
    spring.rabbitmq.password: 登陆密码
    spring.rabbitmq.virtual-host: 连接到rabbitMQ的vhost
    spring.rabbitmq.addresses: 指定client连接到的server的地址，多个以逗号分隔(优先取addresses，然后再取host)
    spring.rabbitmq.requested-heartbeat: 指定心跳超时，单位秒，0为不指定；默认60s
    spring.rabbitmq.publisher-confirms: 是否启用【发布确认】
    spring.rabbitmq.publisher-returns: 是否启用【发布返回】
    spring.rabbitmq.connection-timeout: 连接超时，单位毫秒，0表示无穷大，不超时
    spring.rabbitmq.parsed-addresses:
### ssl
    spring.rabbitmq.ssl.enabled: 是否支持ssl
    spring.rabbitmq.ssl.key-store: 指定持有SSL certificate的key store的路径
    spring.rabbitmq.ssl.key-store-password: 指定访问key store的密码
    spring.rabbitmq.ssl.trust-store: 指定持有SSL certificates的Trust store
    spring.rabbitmq.ssl.trust-store-password: 指定访问trust store的密码
    spring.rabbitmq.ssl.algorithm: ssl使用的算法，例如，TLSv1.1
### cache
    spring.rabbitmq.cache.channel.size: 缓存中保持的channel数量
    spring.rabbitmq.cache.channel.checkout-timeout: 当缓存数量被设置时，从缓存中获取一个channel的超时时间，单位毫秒；如果为0，则总是创建一个新channel
    spring.rabbitmq.cache.connection.size: 缓存的连接数，只有是CONNECTION模式时生效
    spring.rabbitmq.cache.connection.mode: 连接工厂缓存模式：CHANNEL 和 CONNECTION
### listener
    spring.rabbitmq.listener.simple.auto-startup: 是否启动时自动启动容器
    spring.rabbitmq.listener.simple.acknowledge-mode: 表示消息确认方式，其有三种配置方式，分别是none、manual和auto；默认auto
    spring.rabbitmq.listener.simple.concurrency: 最小的消费者数量
    spring.rabbitmq.listener.simple.max-concurrency: 最大的消费者数量
    spring.rabbitmq.listener.simple.prefetch: 指定一个请求能处理多少个消息，如果有事务的话，必须大于等于transaction数量.
    spring.rabbitmq.listener.simple.transaction-size: 指定一个事务处理的消息数量，最好是小于等于prefetch的数量.
    spring.rabbitmq.listener.simple.default-requeue-rejected: 决定被拒绝的消息是否重新入队；默认是true（与参数acknowledge-mode有关系）
    spring.rabbitmq.listener.simple.idle-event-interval: 多少长时间发布空闲容器时间，单位毫秒

    spring.rabbitmq.listener.simple.retry.enabled: 监听重试是否可用
    spring.rabbitmq.listener.simple.retry.max-attempts: 最大重试次数
    spring.rabbitmq.listener.simple.retry.initial-interval: 第一次和第二次尝试发布或传递消息之间的间隔
    spring.rabbitmq.listener.simple.retry.multiplier: 应用于上一重试间隔的乘数
    spring.rabbitmq.listener.simple.retry.max-interval: 最大重试时间间隔
    spring.rabbitmq.listener.simple.retry.stateless: 重试是有状态or无状态
### template
    spring.rabbitmq.template.mandatory: 启用强制信息；默认false
    spring.rabbitmq.template.receive-timeout: receive() 操作的超时时间
    spring.rabbitmq.template.reply-timeout: sendAndReceive() 操作的超时时间
    spring.rabbitmq.template.retry.enabled: 发送重试是否可用
    spring.rabbitmq.template.retry.max-attempts: 最大重试次数
    spring.rabbitmq.template.retry.initial-interval: 第一次和第二次尝试发布或传递消息之间的间隔
    spring.rabbitmq.template.retry.multiplier: 应用于上一重试间隔的乘数
    spring.rabbitmq.template.retry.max-interval: 最大重试时间间隔
