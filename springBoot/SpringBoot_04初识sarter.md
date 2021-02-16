---
title: 初识starter
date: 2021-02-12 13:33:36
tags:
  - springBoot
categories:
  - springBoot
#top: 1
topdeclare: false
reward: true
---

#  原理

总体上，就是将Jar包作为项目的依赖引入工程。而现在之所以增加了难度，是因为我们引入的是Spring Boot Starter，所以我们需要去了解Spring Boot对Spring Boot Starter的Jar包是如何加载的？

SpringBoot 在启动时会去依赖的 starter 包中寻找 /META-INF/spring.factories 文件，然后根据文件中配置的 Jar 包去扫描项目所依赖的 Jar 包，这类似于 Java 的 SPI 机制。

细节上可以使用@Conditional 系列注解实现更加精确的配置加载Bean的条件。

> JavaSPI 实际上是“基于接口的编程＋策略模式＋配置文件”组合实现的动态加载机制。

<!--starter-->


# 项目实战

## 创建一个 starter 项目 com-boot-starter-zbcn

- 添加 pom依赖

```xml
<!--增加springboot 的自动配置包-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-autoconfigure</artifactId>
</dependency>
```

- 创建service 类 `ZbcnService`

```java
public class ZbcnService {

    private String msg;

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public String sayHello(){
        return "hello" + msg;
    }
}
```

- 创建 `ZbcnServiceProperties` 引入配置信息

```java
@ConfigurationProperties(prefix = "zbcn")
public class ZbcnServiceProperties {

    private static final String MSG = "hello";

    private String msg = MSG;

    public static String getMSG() {
        return MSG;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }
}
```

- 添加 `ZbcnServiceAutoConfiguration`自动配置类，可以理解为实现自动配置功能的一个入口

```java
@Configuration//定义为配置类
@ConditionalOnWebApplication //在web工程条件下成立
@EnableConfigurationProperties(ZbcnServiceProperties.class)//启用ZbcnServiceProperties配置功能，并加入到IOC容器中
@ConditionalOnClass(ZbcnService.class)//当某个类存在的时候自动配置这个类
public class ZbcnServiceAutoConfiguration {

    @Autowired
    private ZbcnServiceProperties zbcnServiceProperties;

    @Bean
    @ConditionalOnMissingBean(ZbcnService.class)
    public ZbcnService zbcnService(){
        ZbcnService zbcnService = new ZbcnService();
        zbcnService.setMsg(zbcnServiceProperties.getMsg());
        return zbcnService;
    }
}
```

- 在resources目录下新建META-INF目录，并在META-INF下新建spring.factories文件，写入：

```properties
# \ 是为了保证换行后能继续读properties 中的属性,如果有多个属性则用,隔开
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
  com.zbcn.ZbcnServiceAutoConfiguration
```

- 项目到这里就差不多了，不过作为依赖，最好还是再做一下收尾工作。

	1. 删除自动生成的启动类`SpringBootStarterZbcnApplication`。
	
	2. 删除resources下的除META-INF目录之外的所有文件目录。
	
	3. 删除spring-boot-starter-test依赖并且删除test目录
	
	4. 删除 pom.xml 中的build信息 `spring-boot-maven-plugin`
	
	   ```xml
	    <build>
	           <plugins>
	               <plugin>
	                   <groupId>org.springframework.boot</groupId>
	                   <artifactId>spring-boot-maven-plugin</artifactId>
	               </plugin>
	           </plugins>
	       </build>
	   ```
	
	   
	
- 执行mvn install将 `com-boot-starter-zbcn`安装到本地

- 新建 `bootbase` 工程，引入`com-boot-starter-zbcn`依赖

```xml
<!--增加自定义start-->
<dependency>
    <groupId>com.zbcn</groupId>
    <artifactId>com-boot-starter-zbcn</artifactId>
    <version>0.0.1-SNAPSHOT</version>
</dependency>
```

- 在新工程中调用starter 中定义的功能

```java
@RestController
public class SelDefStartController {

    @Autowired
    private ZbcnService zbcnService;
    @GetMapping("/self_start")
    public String selfStart(){

        return zbcnService.getMsg();

    }
}
```

-  在application.yaml 中添加starter 中自定的配置

```yaml
# 自定义start
zbcn:
  msg: zbcn
```

- 访问 `http://localhost:9001/self_start`，测试功能可用性。

# 元数据的配置

在配置 `application.yaml` 文件中添加自定义 starter配置项时，想和springboot 原生的starter 一样，自带提示功能。如何做呢？

在spring 官方文档中有相关说明：在starter 项目中新建META-INF/spring-configuration-metadata.json文件，进行配置。

```json

```

# 元数据配置说明

## Group属性

“groups”中包含的JSON对象可以包含下表中显示的属性：

| **名称**     | **类型** | **用途**                                                     |
| :----------- | :------- | :----------------------------------------------------------- |
| name         | String   | “groups”的全名。这个属性是强制性的                           |
| type         | String   | group数据类型的类名。例如，如果group是基于一个被@ConfigurationProperties注解的类，该属性将包含该类的全限定名。如果基于一个@Bean方法，它将是该方法的返回类型。如果该类型未知，则该属性将被忽略 |
| description  | String   | 一个简短的group描述，用于展示给用户。如果没有可用描述，该属性将被忽略。推荐使用一个简短的段落描述，第一行提供一个简洁的总结，最后一行以句号结尾 |
| sourceType   | String   | 贡献该组的来源类名。例如，如果组基于一个被@ConfigurationProperties注解的@Bean方法，该属性将包含@Configuration类的全限定名，该类包含此方法。如果来源类型未知，则该属性将被忽略 |
| sourceMethod | String   | 贡献该组的方法的全名（包含括号及参数类型）。例如，被@ConfigurationProperties注解的@Bean方法名。如果源方法未知，该属性将被忽略 |

## Property属性

properties数组中包含的JSON对象可由以下属性构成：

| **名称**     | **类型**   | **用途**                                                     |
| :----------- | :--------- | :----------------------------------------------------------- |
| name         | String     | property的全名，格式为小写虚线分割的形式（比如server.servlet-path）。该属性是强制性的 |
| type         | String     | property数据类型的类名。例如java.lang.String。该属性可以用来指导用户他们可以输入值的类型。为了保持一致，原生类型使用它们的包装类代替，比如boolean变成了java.lang.Boolean。注意，这个类可能是个从一个字符串转换而来的复杂类型。如果类型未知则该属性会被忽略 |
| description  | String     | 一个简短的组的描述，用于展示给用户。如果没有描述可用则该属性会被忽略。推荐使用一个简短的段落描述，开头提供一个简洁的总结，最后一行以句号结束 |
| sourceType   | String     | 贡献property的来源类名。例如，如果property来自一个被@ConfigurationProperties注解的类，该属性将包括该类的全限定名。如果来源类型未知则该属性会被忽略 |
| defaultValue | Object     | 当property没有定义时使用的默认值。如果property类型是个数组则该属性也可以是个数组。如果默认值未知则该属性会被忽略 |
| deprecated   | Deprecated | 指定该property是否过期。如果该字段没有过期或该信息未知则该属性会被忽略 |
| level        | String     | 弃用级别，可以是警告(默认)或错误。当属性具有警告弃用级别时，它仍然应该在环境中绑定。然而，当它具有错误弃用级别时，该属性不再受管理，也不受约束 |
| reason       | String     | 对属性被弃用的原因的简短描述。如果没有理由，可以省略。建议描述应是简短的段落，第一行提供简明的摘要。描述中的最后一行应该以句点(.)结束 |
| replacement  | String     | 替换这个废弃属性的属性的全名。如果该属性没有替换，则可以省略该属性。 |

## hints属性

hints数组中包含的JSON对象可以包含以下属性：

| **名称**  | **类型**        | **用途**                                                     |
| :-------- | :-------------- | :----------------------------------------------------------- |
| name      | String          | 该提示引用的属性的全名。名称以小写虚构形式（例如server.servlet-path）。果属性是指地图（例如 system.contexts），则提示可以应用于map（）或values（）的键。此属性是强制性的system.context.keyssystem.context.values |
| values    | ValueHint[]     | 由ValueHint对象定义的有效值的列表（见下文）。每个条目定义该值并且可以具有描述 |
| providers | ValueProvider[] | 由ValueProvider对象定义的提供者列表（见下文）。每个条目定义提供者的名称及其参数（如果有）。 |

每个"hints"元素的values属性中包含的JSON对象可以包含下表中描述的属性：

| **名称**    | **类型** | **用途**                                                     |
| :---------- | :------- | :----------------------------------------------------------- |
| value       | Object   | 提示所指的元素的有效值。如果属性的类型是一个数组，那么它也可以是一个值数组。这个属性是强制性的 |
| description | String   | 可以显示给用户的值的简短描述。如果没有可用的描述，可以省略。建议描述应是简短的段落，第一行提供简明的摘要。描述中的最后一行应该以句点(.)结束。 |

每个"hints"元素的providers属性中的JSON对象可以包含下表中描述的属性:

| **名称**   | **类型**    | **用途**                                                   |
| :--------- | :---------- | :--------------------------------------------------------- |
| name       | String      | 用于为提示所指的元素提供额外内容帮助的提供者的名称。       |
| parameters | JSON object | 提供程序支持的任何其他参数(详细信息请参阅提供程序的文档)。 |

##  自动生成  spring-configuration-metadata.json

配置上述数据是挺麻烦的，如果可以提供一种自动生成spring-configuration-metadata.json的依赖就好了。别说，还真有。`spring-boot-configuration-processor` 依赖就可以做到，它的基本原理是在编译期使用注解处理器自动生成spring-configuration-metadata.json文件。文件中的数据来源于你是如何在类中定义zbcn.msg这个属性的，它会自动采集zbcm.msg的默认值和注释信息。

在 `com.zbcn.ZbcnServiceProperties` 类上添加 注解 

```java
@PropertySource(value = {"classpath:META-INF/spring-configuration-metadata.json"},
        ignoreResourceNotFound = false, encoding = "UTF-8", name = "spring-configuration-metadata.json")
```

然后编译项目，在  `com-boot-starter-zbcn/target/classes/META-INF` 发现自动生成的 `spring-configuration-metadata.json`文件

下面我贴出使用spring-boot-configuration-processor自动生成的spring-configuration-metadata.json文件内容：

```shell
{
  "groups": [
    {
      "name": "zbcn",
      "type": "com.zbcn.ZbcnServiceProperties",
      "sourceType": "com.zbcn.ZbcnServiceProperties"
    }
  ],
  "properties": [
    {
      "name": "zbcn.msg",
      "type": "java.lang.String",
      "sourceType": "com.zbcn.ZbcnServiceProperties",
      "defaultValue": "hello"
    }
  ],
  "hints": []
}
```

可以看到properties里的description属性值来源于注释信息，defaultValue值来源于代码中书写的默认值。

> 这一步需要在idea设置中搜索Annotation Processors，勾住Enable annonation processing。

## @Conditional

之前提到了在细节上可以使用@Conditional 系列注解实现更加精确的配置加载Bean的条件。下面列举 SpringBoot 中的所有 @Conditional 注解及作用

| 注解                            | 作用                                                         |
| :------------------------------ | :----------------------------------------------------------- |
| @ConditionalOnBean              | 当容器中有指定的Bean的条件下                                 |
| @ConditionalOnClass             | 当类路径下有指定的类的条件下                                 |
| @ConditionalOnExpression        | 基于SpEL表达式作为判断条件                                   |
| @ConditionalOnJava              | 基于JVM版本作为判断条件                                      |
| @ConditionalOnJndi              | 在JNDI存在的条件下查找指定的位                               |
| @ConditionalOnMissingBean       | 当容器中没有指定Bean的情况下                                 |
| @ConditionalOnMissingClass      | 当类路径下没有指定的类的条件下                               |
| @ConditionalOnNotWebApplication | 当前项目不是Web项目的条件下                                  |
| @ConditionalOnProperty          | 指定的属性是否有指定的值                                     |
| @ConditionalOnResource          | 类路径下是否有指定的资源                                     |
| @ConditionalOnSingleCandidate   | 当指定的Bean在容器中只有一个，或者在有多个Bean的情况下，用来指定首选的Bean |
| @ConditionalOnWebApplication    | 当前项目是Web项目的条件下                                    |

比如，注解`@ConditionalOnProperty(prefix = "zbcn.service",value = "enabled",havingValue = "true")`的意思是当配置文件中`zbcn.service.enabled=true`时，条件才成立。