# SpringBoot Starter 的约定

- groupId不要用官方的org.springframework.boot 而要用你自己独特的
- 对于artifactId的命名，Spring Boot官方建议非官方的Starter命名格式遵循 xxxx-spring-boot-starter，例如 mybatis-spring-boot-starter 。官方starter会遵循spring-boot-starter-xxxx

# SpringBoot starter 组成

一个完整的Spring Boot Starter可能包含以下组件：

- **autoconfigure**模块：包含自动配置的代码
- **starter**模块：提供对**autoconfigure**模块的依赖，以及一些其它的依赖

（PS：如果你不需要区分这两个概念的话，也可以将自动配置代码模块与依赖管理模块合并成一个模块）

简而言之，starter应该提供使用该库所需的一切

##　命名

- 模块名称不能以**spring-boot**开头
- 如果你的starter提供了配置keys，那么请确保它们有唯一的命名空间。而且，不要用Spring Boot用到的命名空间（比如：**server**， **management**， **spring** 等等）

举个例子，假设你为“acme”创建了一个starter，那么你的auto-configure模块可以命名为**acme-spring-boot-autoconfigure**，starter模块可以命名为**acme-spring-boot-starter**。如果你只有一个模块包含这两部分，那么你可以命名为**acme-spring-boot-starter**。

## autoconfigure模块

建议在autoconfigure模块中包含下列依赖：

```xml
<dependency>
 	<groupId>org.springframework.boot</groupId>
 	<artifactId>spring-boot-autoconfigure-processor</artifactId>
 	<optional>true</optional>
 </dependency>
```

## starter模块

事实上，**starter是一个空jar**。它唯一的目的是提供这个库所必须的依赖。

你的starter必须直接或间接引用核心的Spring Boot starter（spring-boot-starter）

# SpringBoot Starter 加载原理

## Spring Boot对Spring Boot Starter的Jar包是如何加载的？

SpringBoot 在启动时会去依赖的 starter 包中寻找 /META-INF/spring.factories 文件，然后根据文件中配置的 Jar 包去扫描项目所依赖的 Jar 包，这类似于 Java 的 SPI 机制。

细节上可以使用@Conditional 系列注解实现更加精确的配置加载Bean的条件。

> JavaSPI 实际上是“基于接口的编程＋策略模式＋配置文件”组合实现的动态加载机制。

# SpringBoot 自定义Starter

省略了samples和test模块模版。

![image-20210106194812118](SpringBoot_03自定义starter/image-20210106194812118.png)



## com-zbcn-utils-starter

`com-zbcn-starter`  作用是依赖管理。所以创建一个maven 父项目。用来管理 `com-zbcn-autoConfig` 和 `com-redis-util-starter`.

## com-zbcn-starter-config

该模块主要用来定义配置参数、以及自动配置对外暴露的功能（一般是抽象的接口Spring Bean）。

###  com-zbcn-starter-config 基本项目搭建

- pom 中 引入依赖包

```xml
<!--元数据生成依赖-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
<!--starter 配置依赖-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-autoconfigure</artifactId>
    <optional>true</optional>
</dependency>
</dependencies>
```

- pom中删除 builder 中的 springboot 相关特性
- pom中增加 对父项目的依赖

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>com.zbcn</groupId>
            <artifactId>com-zbcn-utils-starter</artifactId>
            <version>1.0-SNAPSHOT</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```



### 配置参数

一般配置参数都是在Spring Boot 的application.yml中。我们会定义一个前缀标识来作为名称空间隔离各个组件的参数.对应的组件会定义一个XXXXProperties 来自动装配这些参数。自动装配的机制基于@ConfigurationProperties注解，请注意一定要显式声明你配置的前缀标识（prefix）。

例如我们定义redis 配置:

```java
@ConfigurationProperties(prefix = "zbcn.redis")
@Data
public class RedisProperty {

    private String host;

    private String port;

    private String username;

    private String password;
}
```

后期在使用 该starter 的项目中,在配置文件中配置如下信息:

```yaml
zbcn.redis:
	host: xxxx
	port: 6379
	username:
	password: 
```

集成了Spring Boot 校验库, 可以对SmsProperties进行校验。在配置application.yml时细心的java开发者会发现参数配置都有像下面一样的参数描述:

首先在pom.xml 中引入校验库

```xml
<!--元数据生成依赖-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

然后就该依赖会对SmsProperties 成员属性的注释进行提取生成一个spring-configuration-metadata.json文件，这就是配置描述的元数据文件。Spring Boot官方也对注释进行了一些规则约束：

- 不要以“The”或“A”开头描述。
- 对于boolean类型，请使用“Whether" 或“Enable”开始描述。
- 对于基于集合的类型，请使用“Comma-separated list”
- 如果默认时间单位不等同于毫秒，则使用java.time.Duration而不是long描述默认单位，例如“如果未指定持续时间后缀，则将使用秒”。
- 除非必须在运行时确定，否则不要在描述中提供默认值。

**描述尽量用英文描述**

### 配置自动暴露功能接口

根据配置来初始化我们的功能接口，我们会抽象一个redis 配置信息bean `ZbcnRedisConfigBean`,请注意autoconfigure模块的依赖几乎都是不可传递的。也就是依赖坐标配置optional为true 。

```java
@Configuration
@EnableConfigurationProperties(RedisProperty.class)
public class CustomRedisConfig {
    /**
     * redis 配置信息
     * @param redisProperty
     * @return
     */
    @Bean
    public ZbcnRedisConfigBean redisConfigBean(RedisProperty redisProperty){
        return new ZbcnRedisConfigBean(redisProperty.getHost(), redisProperty.getPort(),
                redisProperty.getUsername(), redisProperty.getPassword(),"自定义redis 配置");
    }
}
```

除了`@Configuration`注解外，`@ConfigurationProperties`会帮助我们将我们的配置类`ZbcnRedisConfigBean`加载进来。然后将我们需要暴露的功能接口声明为Spring Bean 暴露给Spring Boot应用 。有时候我们还可以通过一些条件来控制`CustomRedisConfig` 或者`ZbcnRedisConfigBean`，比如根据某个条件是否加载或加载不同的``ZbcnRedisConfigBean`。

>  有时间,可以看看redis-starter就能很明显感觉到，它会根据luttuce、redisson、jedis 的变化实例化不同的客户端链接。实现方式是使用了@Conditional系列注解，有时间可以学习一下该系列的注解。

### 主动生效和被动生效

starter集成入应用有两种方式。我们从应用视角来看有两种：

- 一种是主动生效，在starter组件集成入Spring Boot应用时需要你主动声明启用该starter才生效，即使你配置完全。这里会用到@Import注解，将该注解标记到你自定义的@Enable注解上：

```java
/**
 * 一种是主动生效，在starter组件集成入Spring Boot应用时需要你主动声明启用该starter才生效，即使你配置完全。
 * 还有一种方式是:被动生效，在starter组件集成入Spring Boot应用时就已经被应用捕捉到。这里会用到类似java的SPI机制。在autoconfigure资源包下新建META-INF/spring.factories写入
 * 配置信息
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Import(CustomRedisConfig.class)
public @interface EnableCustomRedis {
}
```

我们将该注解标记入Spring Boot应用就可以使用该自定义starter功能了。

- 另一种被动生效，在starter组件集成入Spring Boot应用时就已经被应用捕捉到。这里会用到类似java的SPI机制。在autoconfigure资源包下新建META-INF/spring.factories写入SmsAutoConfiguration全限定名。

  ```properties
  org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
    com.zbcn.config.config.CustomRedisConfig
  ```

  多个配置类逗号隔开，换行使用反斜杠。

## com-zbcn-starter

一个空jar。唯一目的是提供必要的依赖项来使用starter。可以认为它就是集成该starter功能的唯一入口。

不要对添加启动器的项目做出假设。如果自动配置的依赖库通常需要其他启动器，请同时提及它们。如果可选依赖项的数量很高，则提供一组适当的默认依赖项可能很难，因为我们应该避免包含对典型库的使用不必要的依赖项。换句话说，我们不应该包含可选的依赖项。

无论哪种方式，我们的starter必须直接或间接引用核心Spring Boot启动器（spring-boot-starter）（如果我们的启动器依赖于另一个启动器，则无需添加它）。如果只使用自定义启动器创建项目，则Spring Boot的核心功能将通过核心启动器的存在来实现。

1.  创建 springBoot 项目 `com-zbcn-starter`
2. 添加pom.xml 依赖

```xml

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
</dependency>

<!--增加springboot 的自动配置包-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-autoconfigure</artifactId>
</dependency>
```

到此为止，我们的整个短信Starter就开发完成了。

# 总结

自定义starter对于我们项目组件化、模块化是有很大帮助的。同时也是Spring Boot一大特色。

