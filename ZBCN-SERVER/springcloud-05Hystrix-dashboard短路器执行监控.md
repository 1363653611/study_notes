---
title: Hystrix Dashboard 短路器执行监控
date: 2021-01-05 13:14:10
tags:
 - SpringCloud
categories:
 - SpringCloud
topdeclare: true
reward: true
---

# Hystrix Dashboard 短路器执行监控

Hystrix Dashboard 是Spring Cloud中查看Hystrix实例执行情况的一种仪表盘组件，支持查看单个实例和查看集群实例。

# 简介

Hystrix提供了Hystrix Dashboard来实时监控HystrixCommand方法的执行情况。 Hystrix Dashboard可以有效地反映出每个Hystrix实例的运行情况，帮助我们快速发现系统中的问题，从而采取对应措施。

# Hystrix 单个实例监控

我们先通过使用Hystrix Dashboard监控单个Hystrix实例来了解下它的使用方法。

## 创建一个hystrix-dashboard模块

用来监控hystrix实例的执行情况。

- 引入 pom依赖

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-hystrix-dashboard</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

- 在application.yml进行配置：

```yaml
server:
  port: 8501
spring:
  application:
    name: hystrix-dashboard
eureka:
  client:
    register-with-eureka: true
    fetch-registry: true
    service-url:
      defaultZone: http://localhost:8001/eureka/
```

- 在启动类上添加 @EnableHystrixDashboard来启用监控功能：

```java
@EnableHystrixDashboard
@EnableDiscoveryClient
@SpringBootApplication
public class HystrixDashboardApplication {

    public static void main(String[] args) {
        SpringApplication.run(HystrixDashboardApplication.class, args);
    }

}

```

## 启动相关服务

- 这次我们需要启动如下服务：eureka-server、user-service、hystrix-service、hystrix-dashboard，启动后注册中心显示如下。

![image-20201208110707148](springcloud-05Hystrix-dashboard实例监控/image-20201208110707148.png)

## Hystrix实例监控演示

- 访问Hystrix Dashboard：http://localhost:8501/hystrix

![img](springcloud-05Hystrix-dashboard实例监控/springcloud_hystrix_10.png)

- 填写好信息后点击监控按钮，这里我们需要注意的是，由于我们本地不支持https，所以我们的地址需要填入的是http，否则会无法获取监控信息；

  ```http
  http://localhost:8401/actuator/hystrix.stream
  hystrix-service
  ```

  

![img](springcloud-05Hystrix-dashboard实例监控/springcloud_hystrix_11.png)

- 还有一点值得注意的是，被监控的hystrix-service服务需要开启Actuator的hystrix.stream端点，配置信息如下：

```yaml
management:
  endpoints:
    web:
      exposure:
        include: 'hystrix.stream' #暴露hystrix监控端点

```

- 调用几次hystrix-service的接口：http://localhost:8401/user/testCommand/1

![img](springcloud-05Hystrix-dashboard实例监控/springcloud_hystrix_12.png)

## 异常问题

**异常1:**

现象：

![image-20201208112945743](springcloud-05Hystrix-dashboard实例监控/image-20201208112945743.png)

后台日志：` Origin parameter: http://localhost:8401/actuator/hystrix.stream is not in the allowed list of proxy host names.  If it should be allowed add it to hystrix.dashboard.proxyStreamAllowList.`

问题解决方案：

![image-20201208113240422](springcloud-05Hystrix-dashboard实例监控/image-20201208113240422.png)

接下来就很简单了，HystrixDashboard工程加入配置。

```yaml
hystrix:
  dashboard:
    proxy-stream-allow-list: "localhost"
```

参考：

https://www.jianshu.com/p/0a682e4781b0

**异常2:**

```shell
ashboardConfiguration$ProxyStreamServlet : Failed opening connection to http://localhost:8401/actuator/hystrix.stream : 404 : HTTP/1.1 404 
```

解决方案：

```java
@Configuration
public class CommonConfig {
    //解决问题：使用hystrix dashboard仪表盘时,Failed opening connection to http://localhost:8091/hystrix.stream?delay=100 : 404 : HTTP/1.1 404
    @Bean
    public ServletRegistrationBean getServlet() {
        HystrixMetricsStreamServlet streamServlet = new HystrixMetricsStreamServlet();
        ServletRegistrationBean registrationBean = new ServletRegistrationBean(streamServlet);
        registrationBean.setLoadOnStartup(1);
        registrationBean.addUrlMappings("/hystrix.stream");
        registrationBean.setName("HystrixMetricsStreamServlet");
        return registrationBean;
    }
}
```

## Hystrix Dashboard 图表解读

> 图表解读如下，需要注意的是，小球代表该实例健康状态及流量情况，颜色越显眼，表示实例越不健康，小球越大，表示实例流量越大。曲线表示Hystrix实例的实时流量变化。

![img](springcloud-05Hystrix-dashboard实例监控/springcloud_hystrix_13.png)

## 使用到的模块

```shell
ZBCN-SERVER
├── zbcn-register/eureka-server -- eureka注册中心
├── zbcn-business/user-service -- 提供User对象CRUD接口的服务
└── zbcn-common/ hystrix-server -- hystrix-server服务调用测试服务
└── zbcn-common/ hystrix-dashboard  -- 展示hystrix实例监控信息的仪表盘
```



# Hystrix 集群实例监控

> 这里我们使用Turbine来聚合hystrix-service服务的监控信息，然后我们的hystrix-dashboard服务就可以从Turbine获取聚合好的监控信息展示给我们了。

## 创建一个turbine-service模块

用来聚合hystrix-service的监控信息。

- 在pom 中添加相关依赖

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-turbine</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

- 在application.yml进行配置，主要是添加了Turbine相关配置：

```yaml
server:
  port: 8601
spring:
  application:
    name: turbine-service
eureka:
  client:
    register-with-eureka: true
    fetch-registry: true
    service-url:
      defaultZone: http://localhost:8001/eureka/
turbine:
  app-config: hystrix-service #指定需要收集信息的服务名称
  cluster-name-expression: new String('default') #指定服务所属集群
  combine-host-port: true #以主机名和端口号来区分服务
```

- 在启动类上添加@EnableTurbine来启用Turbine相关功能：

```java
@EnableTurbine
@EnableDiscoveryClient
@SpringBootApplication
public class TurbineServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(TurbineServiceApplication.class, args);
    }

}
```



## 启动相关服务

使用application-replica1.yml配置再启动一个hystrix-service服务，启动turbine-service服务，此时注册中心显示如下。

启动方式 是： 在program arguements栏添加: `--spring.config.location=classpath:application-replica1.yml`

![image-20201208140108725](springcloud-05Hystrix-dashboard短路器执行监控/image-20201208140108725.png)

参考：https://www.cnblogs.com/lyp-make/p/13353321.html

## Hystrix集群监控演示

- 访问Hystrix Dashboard：http://localhost:8501/hystrix
- 添加集群监控地址，需要注意的是我们需要添加的是turbine-service的监控端点地址：

```http
http://localhost:8401/actuator/turbine.stream
turbine-service
```



![img](springcloud-05Hystrix-dashboard短路器执行监控/springcloud_hystrix_15.png)

- 调用几次hystrix-service的接口：http://localhost:8401/user/testCommand/1以及http://localhost:8402/user/testCommand/1

![image-20201208141543851](springcloud-05Hystrix-dashboard短路器执行监控/image-20201208141543851.png)

- 可以看到我们的Hystrix实例数量变成了两个。

## 使用到的模块

```shell
ZBCN-SERVER
├── zbcn-register/eureka-server -- eureka注册中心
├── zbcn-business/user-service -- 提供User对象CRUD接口的服务
└── zbcn-common/ hystrix-server -- hystrix-server服务调用测试服务
└── zbcn-common/ hystrix-dashboard  -- 展示hystrix实例监控信息的仪表盘
└── zbcn-common/ turbine-service -- 聚合收集hystrix实例监控信息的服务
```

