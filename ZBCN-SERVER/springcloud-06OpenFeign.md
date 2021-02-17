---
title: Spring Cloud OpenFeign：基于Ribbon和Hystrix的声明式服务调用
date: 2021-01-06 13:14:10
tags:
 - SpringCloud
categories:
 - SpringCloud
topdeclare: true
reward: true
---

# Spring Cloud OpenFeign：基于Ribbon和Hystrix的声明式服务调用

Spring Cloud OpenFeign 是声明式的服务调用工具，它整合了Ribbon和Hystrix，拥有负载均衡和服务容错功能，本文将对其用法进行详细介绍。

#  Feign 简介

Feign是声明式的服务调用工具，我们只需创建一个接口并用注解的方式来配置它，就可以实现对某个服务接口的调用，简化了直接使用RestTemplate来调用服务接口的开发量。Feign具备可插拔的注解支持，同时支持Feign注解、JAX-RS注解及SpringMvc注解。当使用Feign时，Spring Cloud集成了Ribbon和Eureka以提供负载均衡的服务调用及基于Hystrix的服务容错保护功能。

## 创建一个feign-service模块

这里我们创建一个feign-service模块来演示feign的常用功能。

## 在pom文件中添加依赖

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

## 在application.yml中进行配置

```yaml
server:
  port: 8701
spring:
  application:
    name: feign-server
eureka:
  client:
    register-with-eureka: true
    fetch-registry: true
    service-url:
      defaultZone: http://localhost:8001/eureka/
```

## 在启动类上添加@EnableFeignClients注解来启用Feign的客户端功能

```java
@EnableFeignClients //开启声明式服务调用功能
@EnableDiscoveryClient
@SpringBootApplication
public class FeignServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(FeignServerApplication.class, args);
    }
}
```

## 添加UserService接口完成对user-service服务的接口绑定

```java
@FeignClient(value = "user-service")
public interface UserService {

    @PostMapping("/user/create")
    ResponseResult create(@RequestBody User user);

    @GetMapping("/user/{id}")
    ResponseResult<User> getUser(@PathVariable Long id);

    @GetMapping("/user/getByUsername")
    ResponseResult<User> getByUsername(@RequestParam String username);

    @PostMapping("/user/update")
    ResponseResult update(@RequestBody User user);

    @PostMapping("/user/delete/{id}")
    ResponseResult delete(@PathVariable Long id);
}
```

## 添加UserFeignController调用UserService实现服务调用

```java
@RestController
@RequestMapping("/user")
public class UserFeignController {

    @Autowired
    private UserService userService;

    @GetMapping("/{id}")
    public ResponseResult<User> getUser(@PathVariable Long id) {
        return userService.getUser(id);
    }

    @GetMapping("/getByUsername")
    public ResponseResult getByUsername(@RequestParam String username) {
        return userService.getByUsername(username);
    }

    @PostMapping("/create")
    public ResponseResult create(@RequestBody User user) {
        return userService.create(user);
    }

    @PostMapping("/update")
    public ResponseResult update(@RequestBody User user) {
        return userService.update(user);
    }

    @PostMapping("/delete/{id}")
    public ResponseResult delete(@PathVariable Long id) {
        return userService.delete(id);
    }
}
```

## 负载均衡功能演示

- 启动eureka-service，两个user-service，feign-service服务.

- 多次调用http://localhost:8701/user/1进行测试，可以发现运行在8201和8202的user-service服务交替打印

## Feign中的服务降级

Feign中的服务降级使用起来非常方便，只需要为Feign客户端定义的接口添加一个服务降级处理的实现类即可，下面我们为UserService接口添加一个服务降级实现类。

### 添加服务降级实现类UserFallbackService

需要注意的是它实现了UserService接口，并且对接口中的每个实现方法进行了服务降级逻辑的实现。

```java
@Component
public class UserFallbackService implements UserService {
    @Override
    public ResponseResult create(User user) {
        return null;
    }

    @Override
    public ResponseResult<User> getUser(Long id) {
        User defaultUser = new User(-1L, "defaultUser");
        return ResponseResult.success(defaultUser);
}

    @Override
    public ResponseResult<User> getByUsername(String username) {
        User defaultUser = new User(-1L, "defaultUser");
        return ResponseResult.success(defaultUser);
    }

    @Override
    public ResponseResult update(User user) {
        return ResponseResult.fail("服务调用失败。。。");
    }

    @Override
    public ResponseResult delete(Long id) {
        return  ResponseResult.fail("服务调用失败。。。");
    }
}

```

### 修改UserService接口，设置服务降级处理类为UserFallbackService

修改@FeignClient注解中的参数，设置fallback为UserFallbackService.class即可。

```java
@FeignClient(value = "user-service",fallback = UserFallbackService.class)
public interface UserService {
}
```

### 修改application.yml，开启Hystrix功能

```java
feign:
  hystrix:
    enabled: true #在Feign中开启Hystrix
```



## 服务降级功能测试

- 关闭两个user-service服务，重新启动feign-service;
- 调用http://localhost:8701/user/1进行测试，可以发现返回了服务降级信息。



## 日志打印功能

Feign提供了日志打印功能，我们可以通过配置来调整日志级别，从而了解Feign中Http请求的细节。

### 日志级别

- NONE：默认的，不显示任何日志；
- BASIC：仅记录请求方法、URL、响应状态码及执行时间；
- HEADERS：除了BASIC中定义的信息之外，还有请求和响应的头信息；
- FULL：除了HEADERS中定义的信息之外，还有请求和响应的正文及元数据。

### 通过配置开启更为详细的日志

我们通过java配置来使Feign打印最详细的Http请求日志信息。

```java
@Configuration
public class FeignConfig {
    @Bean
    Logger.Level feignLoggerLevel() {
        return Logger.Level.FULL;
    }
}
```

### 在application.yml中配置需要开启日志的Feign客户端

配置UserService的日志级别为debug。

```yaml
logging:
  level:
    com.macro.cloud.service.UserService: debug
```

### 查看日志

![image-20201208154022400](springcloud-06OpenFeign/image-20201208154022400.png)



## Feign的常用配置

```yaml
feign:
  hystrix:
    enabled: true #在Feign中开启Hystrix
  compression:
    request:
      enabled: false #是否对请求进行GZIP压缩
      mime-types: text/xml,application/xml,application/json #指定压缩的请求数据类型
      min-request-size: 2048 #超过该大小的请求会被压缩
    response:
      enabled: false #是否对响应进行GZIP压缩
logging:
  level: #修改日志级别
    com.zbcn.feignserver.api.UserService: debug

```

### Feign中的Ribbon配置

在Feign中配置Ribbon可以直接使用Ribbon的配置，具体可以参考：Spring Cloud Ribbon：负载均衡的服务调用

### Feign中的Hystrix配置

在Feign中配置Hystrix可以直接使用Hystrix的配置，具体可以参考：Spring Cloud Hystrix：服务容错保护

# 使用到的模块

```shell
ZBCN-SERVER
├── zbcn-register/eureka-server -- eureka注册中心
├── zbcn-business/user-service -- 提供User对象CRUD接口的服务
└── zbcn-common/ feign-server  -- feign服务调用测试服务
```

