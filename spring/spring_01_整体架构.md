---
title: Spring_01 整体架构
date: 20220-05-06 13:33:36
tags:
  - spring
categories:
  - spring
#top: 1
topdeclare: false
reward: true
---

## Spring 的整体架构
- 包含一系列的元素，大概分为20个模块
![整体架构图](./imgs/整体架构图.png)

<!--more-->

### Core Container（核心容器）
- 包含了Beans、Core、Context、SpEL(Expression Language).
- 核心组件只有三个：Core、Context 和 DI（依赖注入）的特性。
- BeanFactory 它提供工厂模式的经典实现，来消除对程序性单利模式的需要，并真正的允许我们从程序逻辑整分离依赖关系和配置。

##### Core 模块
- 主要包含spring 框架的核心工具类，spring 框架的其他包主要依赖core包下的工具类，是其他模块的核心。同时，我们可以在自己的代码中使用core包下的工具类。

##### Beans
- 包含访问配置文件，创建和管理Bean以及进行Inversion of Control / Dependency Injection(IOC/DI) 操作相关的类。

##### Context
- 构建与 Core 和Beans 的基础上，提供了一种类似与JNDI(Java Naming and Directory Interface) 注册器的框架式的对象访问方法。
- context 继承了Beans 的特性，为spring 提供了大量的扩展：国际化（资源绑定）、事件传播、资源加载、对context的透明创建的支持。
- context 同时支持J2EE的一些特性，如：EJB,JMX 和基础的远程处理。
- ApplicationContext 接口是Context 模块的关键
##### Expression Language
- 提供了强大的表达式语言，用于在运行时查询和操作对象，
- 它是JSP2.1规范中定义的unified expression language 的一个扩展。该语言支持设置和获取属性的值，属性的分配，方法的调用，访问数组上下文（accessiong the context of array）、容器、索引器、逻辑和算数运算符、命名变量以及重spring的Ioc 容器中根据名称检索对象。
- 支持list投影、选择和一般的list聚合。

### Data Access / Integration
- 包含 JDBC、ORM、OXM、JMS 和 Transaction 模块。

#### JDBC
- 提供了jdbc 抽象层，可以消除冗长的JDBC编码和解析数据厂商特有的错误代码。
- 该模块包含了spring 对JDBC数据访问进行封装的所有类。

#### ORM
- 对象关系映射API,如：JPA,JDO hibernate， myBatis等，提供了一个交互层，利用ORM 封装包，可以混合使用所有spring 提供的特性进行O/R 映射。如：声明性事物管理。
- spring 框架 可以引入若干个ORM 框架，从而提供了ORM 的对象关系工具，包括：JDO \ hibinate 和 MyBatisSQL Map，都遵循spring 的通用事物和Dao 异常层次结构。

#### OXM
- Object / XML 对象关系映射的实现的抽象层，Object/XML 映射实现包括： JAXB、Castor、XMLBean、JiBX、XStream

#### JMS （JAVA messaging Service）
- 包含一些制造和消费消息的特性

#### Transaction
- 支持编程和声明性事物管理，这些事物类必须实现特定的接口，并且对所有的POJO都适用

### WEB
web 上下文模块建立在应用程序上下文之上，为基于web 的应用程序提供了上下文。web 模块简化了处理多部分请求以及将请求参数绑定到域对象的工作。web 包含了web、web-servlet web-struct 和web-Porlet模块。

#### web 模块：
提供了基础的面向web 的集成特性。eg： 多文件上传、使用servlet-listeners 初始化ioc 容器、面向web的应用上下文。还包括Spring 远程支持中web 的相关部分。

#### web—servlet 模块（web-servlet.jar）
该模块包含spring 的 model-view-controller（MVC）实现。spring 的mvc 框架使得模型范围内的代码和web-forms之间能清晰的分离开。并与spring 的其他特性集成在一起。

#### ~web-structs 模块~（新版本已经移除）
该模块提供了 structs 的支持。

#### web-porlet
提供了用于porlet 环境和web-servlet 模块的mvc 实现。

### AOP
- AOP 模块提供了一个符合AOP联盟标准的面向切面编程的实现。它可以让我们定义例如 __方法拦截__ 和 __切点__。从而将逻辑代码分开，降低他们之间的耦合。利用source-level的元数据功能，还能将各种行为信息合并到我们的代码中。
- 通配符管理特性，Spring AOP 模块直接将面向切面的编程功能集成到了Spring 框架中。所以很容易使得Spring 框架管理的任何对象支持aop 特性。
- Spring AOP 模块为基于Spring 的应用程序中的对象提供了事物管理服务。通过Spring AOP，不用依赖与EJB 组件，就可以将声明性事物集中管理到应用程序中。

### ASPECTJ
提供了 aspectj 的支持

### Instrumentation
提供了 class Instrumentation 支持和 classloader 实现，使得可以在特定的应用服务器上使用。

### test
Test模块的支持，使得可以使用Junit 和TestNG 对spring 组件进行测试。
