---
title: springCloud 整体架构概览
date: 2021-01-01 13:14:10
tags:
 - springCloud
categories:
 - springCloud
topdeclare: true
reward: true
---

# springCloud 整体架构概览



SpringCloud为开发人员提供了快速构建分布式系统架构的工具，例如

- 配置管理，
- 服务发现，
- 断路器，
- 智能路由，
- 微代理，
- 控制总线，
- 一次性令牌，
- 全局锁定，
- 领导选举，
- 分布式会话，
- 集群状态
- 。。。。等。

# 架构

![image-20201205211757470](springcloud-00spring架构览/image-20201205211757470.png)

# SpringCloud的版本关系

SpringCloud是一个由许多子项目组成的综合项目，各子项目有不同的发布节奏。 为了管理SpringCloud与各子项目的版本依赖关系，发布了一个清单，其中包括了某个SpringCloud版本对应的子项目版本。 为了避免SpringCloud版本号与子项目版本号混淆，SpringCloud版本采用了名称而非版本号的命名，这些版本的名字采用了伦敦地铁站的名字，根据字母表的顺序来对应版本时间顺序，例如Angel是第一个版本, Brixton是第二个版本。 当SpringCloud的发布内容积累到临界点或者一个重大BUG被解决后，会发布一个"service releases"版本，简称SRX版本，比如Greenwich.SR2就是SpringCloud发布的Greenwich版本的第2个SRX版本。

# springCloud 和SpringBoot 的版本对应关系

| SpringCloud Version | SpringBoot Version |
| ------------------- | ------------------ |
| Hoxton              | 2.2.x              |
| Greenwich           | 2.1.x              |
| Finchley            | 2.0.x              |
| Edgware             | 1.5.x              |
| Dalston             | 1.5.x              |



# springCloud 各个子项目

## SpringCloud Config

集中配置管理工具，分布式系统中统一的外部配置管理，默认使用Git来存储配置，可以支持客户端配置的刷新及加密、解密操作。

## Spring Cloud Netflix

Netflix OSS 开源组件集成，包括Eureka、Hystrix、Ribbon、Feign、Zuul等核心组件。

- Eureka：服务治理组件，包括服务端的注册中心和客户端的服务发现机制；
- Ribbon：负载均衡的服务调用组件，具有多种负载均衡调用策略；
- Hystrix：服务容错组件，实现了断路器模式，为依赖服务的出错和延迟提供了容错能力；
- Feign：基于Ribbon和Hystrix的声明式服务调用组件；
- Zuul：API网关组件，对请求提供路由及过滤功能。

## spring Cloud Bus



用于传播集群状态变化的消息总线，使用轻量级消息代理链接分布式系统中的节点，可以用来动态刷新集群中的服务配置。



## SpringCloud Consul

基于Hashicorp Consul的服务治理组件。



## SpringCloud Security

安全工具包，对Zuul代理中的负载均衡OAuth2客户端及登录认证进行支持。



## SpringCloud Sleuth

SpringCloud应用程序的分布式请求链路跟踪，支持使用Zipkin、HTrace和基于日志（例如ELK）的跟踪。

## SpringCloud Stream

轻量级事件驱动微服务框架，可以使用简单的声明式模型来发送及接收消息，主要实现为Apache Kafka及RabbitMQ。

## SpringCloud Task

用于快速构建短暂、有限数据处理任务的微服务框架，用于向应用中添加功能性和非功能性的特性。



## SpringCloud Zookeeper



基于Apache Zookeeper的服务治理组件。



## SpringCloud GateWay

API网关组件，对请求提供路由及过滤功能。



## SpringClound OpenFeign

基于Ribbon和Hystrix的声明式服务调用组件，可以动态创建基于Spring MVC注解的接口实现用于服务调用，在SpringCloud 2.0中已经取代Feign成为了一等公民。

