# 入门级集成

## 服务端

- 定义接口

```java
public interface DemoService {

    String sayHello(String name);
}
```

- 接口实现

```java
public class DemoServiceImpl implements DemoService {
    @Override
    public String sayHello(String name) {
        return "Hello " + name;
    }
}
```

- 添加maven依赖，增加  dubbo 相关功能

```xml
 <!-- https://mvnrepository.com/artifact/com.alibaba/dubbo -->
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>dubbo</artifactId>
    <version>2.6.6</version>
</dependency>
<dependency>
    <groupId>org.apache.zookeeper</groupId>
    <artifactId>zookeeper</artifactId>
    <version>3.4.10</version>
</dependency>
<dependency>
    <groupId>com.101tec</groupId>
    <artifactId>zkclient</artifactId>
    <version>0.5</version>
</dependency>
<dependency>
    <groupId>io.netty</groupId>
    <artifactId>netty-all</artifactId>
    <version>4.1.32.Final</version>
</dependency>
<dependency>
    <groupId>org.apache.curator</groupId>
    <artifactId>curator-framework</artifactId>
    <version>2.8.0</version>
</dependency>
<dependency>
    <groupId>org.apache.curator</groupId>
    <artifactId>curator-recipes</artifactId>
    <version>2.8.0</version>
</dependency>
```

- xml 方式暴露接口

在我们项目的 resource 目录下**创建 META-INF.spring 包**，然后再创建 **provider.xml** 文件，名字可以任取

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
       xsi:schemaLocation="http://www.springframework.org/schema/beans        http://www.springframework.org/schema/beans/spring-beans.xsd        http://code.alibabatech.com/schema/dubbo        http://code.alibabatech.com/schema/dubbo/dubbo.xsd">

    <!--当前项目在整个分布式架构里面的唯一名称，计算依赖关系的标签-->
    <dubbo:application name="provider" owner="zbcn">
        <dubbo:parameter key="qos.enable" value="true"/>
        <dubbo:parameter key="qos.accept.foreign.ip" value="false"/>
        <dubbo:parameter key="qos.port" value="55555"/>
    </dubbo:application>

    <dubbo:monitor protocol="registry"/>

    <!--dubbo这个服务所要暴露的服务地址所对应的注册中心-->
    <!--<dubbo:registry address="N/A"/>-->
    <dubbo:registry address="N/A" />

    <!--当前服务发布所依赖的协议；webserovice、Thrift、Hessain、http-->
    <dubbo:protocol name="dubbo" port="20880"/>

    <!--服务发布的配置，需要暴露的服务接口-->
    <dubbo:service
                   interface="com.zbcn.provider.service.DemoService"
                   ref="providerService"/>

    <!--Bean bean定义-->
    <bean id="providerService" class="com.zbcn.provider.service.impl.DemoServiceImpl"/>

</beans>
```

① 上面的文件其实就是类似 spring 的配置文件，而且，dubbo 底层就是 spring。
② **节点：dubbo:application**
就是整个项目在分布式架构中的唯一名称，可以在 `name` 属性中配置，另外还可以配置 `owner` 字段，表示属于谁。
下面的参数是可以不配置的，这里配置是因为出现了端口的冲突，所以配置。
③ **节点：dubbo:monitor**
监控中心配置， 用于配置连接监控中心相关信息，可以不配置，不是必须的参数。
④ **节点：dubbo:registry**
配置注册中心的信息，比如，这里我们可以配置 zookeeper 作为我们的注册中心。`address` 是注册中心的地址，这里我们配置的是 `N/A` 表示由 dubbo 自动分配地址。或者说是一种直连的方式，不通过注册中心。
⑤ **节点：dubbo:protocol**
服务发布的时候 dubbo 依赖什么协议，可以配置 dubbo、webserovice、Thrift、Hessain、http等协议。
⑥ **节点：dubbo:service**
这个节点就是我们的重点了，当我们服务发布的时候，我们就是通过这个配置将我们的服务发布出去的。`interface` 是接口的包路径，`ref` 是第 ⑦ 点配置的接口的 bean。
⑦ 最后，我们需要像配置 spring 的接口一样，配置接口的 bean。

- 通过 main 方法将接口暴露出去

```java
public class XmlApp {

    public static void main(String[] args) throws IOException {
        //加载xml配置文件启动
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("META-INF/spring/provider.xml");
        context.start();
        System.in.read(); // 按任意键退出
    }
}
```

发布接口非常简单，因为 dubbo 底层就是依赖 spring 的，所以，我们只需要通过 `ClassPathXmlApplicationContext` 拿到我们刚刚配置好的 xml ，然后调用 `context.start()` 方法就启动了。

### URL分析

寻找到  **dubbo 暴露出去的 url**分析分析

### dubbo 暴露的 url

```shell
[INFO ] 2021-05-28 15:32:28,887 method:com.alibaba.dubbo.config.ReferenceConfig.createProxy(ReferenceConfig.java:429)
 [DUBBO] Refer dubbo service com.zbcn.provider.service.DemoService from url dubbo://10.4.110.164:20880/com.zbcn.provider.service.DemoService?application=consumer&dubbo=2.0.2&interface=com.zbcn.provider.service.DemoService&methods=sayHello&owner=sihai&pid=49848&register.ip=10.4.110.164&side=consumer&timestamp=1622187146470, dubbo version: 2.6.6, current host: 10.4.110.164
```

① 首先，在形式上我们发现，其实这么牛逼的 dubbo 也是用**类似于 http 的协议**发布自己的服务的，只是这里我们用的是 **dubbo 协议**。

② dubbo://10.4.110.164:20880/com.zbcn.provider.service.DemoService 上面这段链接就是 `?` 之前的链接，构成：**协议://ip:端口/接口**。

③`application=consumer&dubbo=2.0.2&interface=com.zbcn.provider.service.DemoService&methods=sayHello&owner=sihai&pid=49848&register.ip=10.4.110.164&side=consumer&timestamp=1622187146470 ` ` `?` 之后的字符串，分析后你发现，这些都是刚刚在 `provider.xml` 中配置的字段，然后通过 `&` 拼接而成的. 和 http 差不多

## 消费端

服务端提供的只是点对点的方式提供服务，并没有使用注册中心，所以，消费端配置也类似不用注册中心的方式配置

- 消费端环境配置

- 在消费端的 resource 下建立配置文件 `consumer.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
       xsi:schemaLocation="http://www.springframework.org/schema/beans        http://www.springframework.org/schema/beans/spring-beans.xsd        http://code.alibabatech.com/schema/dubbo        http://code.alibabatech.com/schema/dubbo/dubbo.xsd">

    <!--当前项目在整个分布式架构里面的唯一名称，计算依赖关系的标签-->
    <dubbo:application name="consumer" owner="sihai"/>

    <!--dubbo这个服务所要暴露的服务地址所对应的注册中心-->
    <!--点对点的方式-->
    <dubbo:registry address="N/A" />
    <!--<dubbo:registry address="zookeeper://localhost:2181" check="false"/>-->

    <!--生成一个远程服务的调用代理-->
    <!--点对点方式-->
    <dubbo:reference id="demoService"
                     interface="com.zbcn.provider.service.DemoService"
                     url="dubbo://10.4.110.164:20880/com.zbcn.provider.service.DemoService"/>

    <!--<dubbo:reference id="providerService"
                     interface="com.sihai.dubbo.provider.service.ProviderService"/>-->

</beans>
```

> 分析
>
> ① 发现这里的 `dubbo:application` 和 `dubbo:registry` 是一致的。
> ② `dubbo:reference` ：我们这里采用**点对点**的方式，所以，需要配置在服务端暴露的 url 。

- maven 依赖

和服务端一样，只是要多增加一个 服务端包的依赖，因为 SPI 方式需要服务端提供调用接口

```xml
<!--dubbo 服务端-->
<dependency>
    <groupId>com.zbcn</groupId>
    <artifactId>dubbo-demo</artifactId>
    <version>1.0-SNAPSHOT</version>
</dependency>
```

- 客户端调用

```java
public class XmlConsumerApp {

    public static void main( String[] args ) throws IOException {

        ClassPathXmlApplicationContext context=new ClassPathXmlApplicationContext("consumer.xml");
        context.start();
        DemoService providerService = (DemoService) context.getBean("demoService");
        String str = providerService.sayHello("zbcn");
        System.out.println(str);
        System.in.read();

    }
}
```

# 加入zookeeper 作为注册中心

使用 dubbo + zookeeper 的方式，使用 zookeeper 作为注册中心。

