# spingCloud gateway  启动报错： xxx.ReactiveJwtDecoder that could not be found

- 报错信息如下：
```shell
Parameter 0 of method setSecurityWebFilterChains in org.springframework.security.config.annotation.web.reactive.WebFluxSecurityConfiguration required a bean of type 'org.springframework.security.oauth2.jwt.ReactiveJwtDecoder' that could not be found.
Action:
Consider defining a bean of type 'org.springframework.security.oauth2.jwt.ReactiveJwtDecoder' in your configuration.
```
解决方案： 
1. 检查配置文件是否正确
```yaml
spring:
 security:
    oauth2:
      resourceserver:
        jwt:
          jwk-set-uri: http://localhost:9401/rsa/publicKey #配置RSA的公钥访问地址
```
2. pom.xml 是否有 `spring-boot-starter-web` 依赖。gateway  和 `spring-boot-starter-web` 包冲突，即：
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

### 总结
网上竟然没有解决方案，记录一下哦，给踩坑的朋友们。