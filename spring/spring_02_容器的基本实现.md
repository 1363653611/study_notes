---
title: Spring_02 容器的基本实现
date: 20220-05-07 13:33:36
tags:
  - spring
categories:
  - spring
#top: 1
topdeclare: false
reward: true
---

## 02_ 容器的基本实现

### bean 的定义 和获取
- 功能分析：
  1. 读取配置文件 xxx.xml
  2. 根据配置文件 xxx.xml 中的配置找到对应的类的配置，并实例化。
  3. 调用实例化后的实例

<!--more-->

### spring Bean 的结构组成
- src/main/java 用于展现spring 的主要逻辑
- src/main/resources 用于存放系统的配置文件
- src/test/java 用于对主要逻辑进行单元测试
- src/test/resources 用于存放单元测试用的配置文件

### 核心类介绍
- DefaultListableBeanFactory
  - 整个bean 加载的核心部分，XmlBeanFactory 继承自DefautlListableBeanFactory。
  - DefautlListableBeanFactory 是spring 注册及加载bean的默认实现。
  - XmlBeanFactory和  DefautlListableBeanFactory不同地方是 XmlBeanFactory 使用了自定义的XML 读取器 `XmlBeanDefinitionReader`。
  - DefautlListableBeanFactory 继承了AbstractAutowireCapableBeanFactory,并实现了ConfigurableListableBeanFactory 和 BeanDefinitionRegistry接口。

  ![DefautListableBeanFactory类图.jpg](./imgs/DefautListableBeanFactory类图.jpg)

- 上图中各个类的作用：
  1. AliasRegistry: (Interface)定义对alias 的简单增删改操作。
  2. SimpleAliasRegistry : 主要使用map 作为 alias 的缓存，并对alias 进行实现。
  3. SingletonBeanRegistry：（Interface） 定义对单例的注册及获取
  4. BeanFactory：（Interface） 定义获取bean 及bean 的各种属性的方法
  5. DefaultSingletonBeanRegistry： 对 SingletonBeanRegistry 的各种实现。
  6. HirearachicalBeanFactory: （interface）继承自beanFactory，在beanFactory 的基础上增加了对parentFactory 的支持
  7. BeanDefinitionRegistry:（interface） 定义对BeanDefinition 的各种增删改操作
  8. FactoryBeanRegistrySupport： 在defaultSingletonBeanRegistry 的基础上增加了对FactoryBean 的特殊处理功能。
  9. ConfigurableBeanFactory（interface）： 提供配置Factory 的各种方法
  10. ListableBeanFactory（interface）： 根据条件获取bean 的各种配置清单
  12. AbstractBeanFactory：综合FactoryBeanRegistrySupport 和ConfigureableBeanfactory 的功能
  13. AutowireCapableBeanFactory：（interface） 提供创建bean，自动注入，初始化，以及应用bean的后处理器。
  14. AbstractAutowireCapableBeanFactory： 综合AbstractBeanFactory 并对接口，并对AutowireCapableBeanFactory 接口进行实现。
  15. ConfigurableListAbleFactory：（interface） BeanFactory配置清单，指定忽略类型及接口等
  16. DefaultListableBeanFactory: 综合以上所有功能，主要是对bean 注册后的处理。
- XmlBeanFactory 对DefaultListableBeanFactory类进行了扩展，主要用于从 xml 配置文件中获取BeanDefinition，对于注册及获取Bean 都是从DefaultListableBeanFactory 上继承的方法实现，而唯独与父类不同的个性化实现是：增加了对XmlBeanDefinitionReader 类型的 reader 属性。XmlBeanfactory 中主要使用reader 属性对资源文件进行读取和注册。


### XmlBeanDefinitionReader
xml 配置文件的读取是spring 中的一个重要功能，spring 的大部分功能是以配置文件作为切入点的。我们可以从 XmlBeanDefinitionReader 中梳理一下资源文件的读取，解析，以及注册的大致脉络。

![xmlBeanDefinitionReader类图.png](./imgs/xmlBeanDefinitionReader类图.png)

1. EnvironmentCapable ：定义获取Environment 的方法
2. BeanDefinitionReader： 主要定义资源文件的读取并转换为Definiton的功能
3. AbstracteBeanDefinitionReader:
![AbstractBeanDefinitionReader](./imgs/AbstractBeanDefinitionReader.png)
  除了对EnvironmentCapable 和BeanDefinitionReader 的实现外，还增加了其他功能：
  1. ResourceLoader 定义资源加载器，主要用于根据给定资源文件的地址返回对应的Resource
4. XmlBeanDefinitonReader：
![XmlBeanDefinitonReader.jpg](./imgs/XmlBeanDefinitonReader.jpg)
  1. documentLoader：定义从资源文件加载的内容转换为 document 的功能
  2. DefaultDeanDefinitionDocumentReader： 定义读取document ，并且转换为 BeanDefintion

总结： XmlBeanDefinitonReader读取并解析 .xml 文件的大致流程为：
1. 通过继承自AbstractBeanDefinitionReader中的方法，使用resourceloader 将资源路径转换为resource 文件
2. 通过 documnetLoader对resource 文件进行转换，转换为Document 对象。
3. 通过实现安BeanDefinitonReader 的DefaultBeanDefinitionDocumentReader 类对document 进行解析。
4. 使用BeanDefinitionPaserDelegate 对Element 进行解析。
