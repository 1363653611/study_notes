---
title: Spring Cloud Security：Oauth2结合JWT使用
date: 2021-01-15 13:14:10
tags:
 - springCloud
categories:
 - springCloud
topdeclare: true
reward: true
---

# Spring Cloud Security：Oauth2结合JWT使用

Spring Cloud Security 为构建安全的SpringBoot应用提供了一系列解决方案，结合Oauth2还可以实现更多功能，比如使用JWT令牌存储信息，刷新令牌功能，本文将对其结合JWT使用进行详细介绍。

# JWT简介

JWT是JSON WEB TOKEN的缩写，它是基于 RFC 7519 标准定义的一种可以安全传输的的JSON对象，由于使用了数字签名，所以是可信任和安全的。

## JWT的组成

- JWT token的格式：header.payload.signature；
- header中用于存放签名的生成算法；

```json
{
"alg": "HS256",
"typ": "JWT"
}
```

- payload中用于存放数据，比如过期时间、用户名、用户所拥有的权限等；

```json
{
"exp": 1572682831,
"user_name": "zbcn",
"authorities": [
  "admin"
],
"jti": "c1a0645a-28b5-4468-b4c7-9623131853af",
"client_id": "admin",
"scope": [
  "all"
]
}
```

- signature为以header和payload生成的签名，一旦header和payload被篡改，验证将失败。

## JWT实例

这是一个JWT的字符串：

```shell
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NzI2ODI4MzEsInVzZXJfbmFtZSI6InpiY24iLCJhdXRob3JpdGllcyI6WyJhZG1pbiJdLCJqdGkiOiJjMWEwNjQ1YS0yOGI1LTQ0NjgtYjRjNy05NjIzMTMxODUzYWYiLCJjbGllbnRfaWQiOiJhZG1pbiIsInNjb3BlIjpbImFsbCJdfQ.dlFafcwO7wOP9Y2Hw0aJYD4tVdS1GIx6EpqJD_ICe1I
```

- 可以在该网站上获得解析结果：https://jwt.io/

![image-20201215193219755](springcloud15-sc/image-20201215193219755.png)

# 创建oauth2-jwt-server模块

该模块只是对oauth2-server模块的扩展，直接复制过来扩展下下即可。

## oauth2中存储令牌的方式

在入门学习时，我们都是把令牌存储在内存中的，这样如果部署多个服务，就会导致无法使用令牌的问题。 Spring Cloud Security中有两种存储令牌的方式可用于解决该问题，一种是使用Redis来存储，另一种是使用JWT来存储。

## 使用Redis存储令牌

- 在pom.xml中添加Redis相关依赖：

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

- 在application.yml中添加redis相关配置

```yml
spring:
  redis: #redis相关配置
    password: 123456 #有密码时设置
```

- 添加在Redis中存储令牌的配置：

```java
@Configuration
public class RedisTokenStoreConfig {
    @Autowired
    private RedisConnectionFactory redisConnectionFactory;

    @Bean
    public TokenStore redisTokenStore (){
        return new RedisTokenStore(redisConnectionFactory);
    }
}
```

- 在认证服务器配置中指定令牌的存储策略为Redis：

```java
/**
 * 认证服务器配置
 */
@Configuration
@EnableAuthorizationServer
public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private UserService userService;

    @Autowired
    @Qualifier("redisTokenStore")
    private TokenStore tokenStore;

    /**
     * 使用密码模式需要配置
     */
    @Override
    public void configure(AuthorizationServerEndpointsConfigurer endpoints) {
        endpoints.authenticationManager(authenticationManager)
                .userDetailsService(userService)
                .tokenStore(tokenStore);//配置令牌存储策略
    }

    //省略代码...
}
```

- 运行项目后使用密码模式来获取令牌，访问如下地址：http://localhost:9401/oauth/token

![image-20201216092734785](springcloud15-sc/image-20201216092734785.png)

- 进行获取令牌操作，可以发现令牌已经被存储到Redis中。

![image-20201216093007189](springcloud15-sc/image-20201216093007189.png)

## 使用JWT存储令牌

- 添加使用JWT存储令牌的配置：

```java
@Configuration
public class JwtTokenStoreConfig {
    @Bean
    public TokenStore jwtTokenStore() {
        return new JwtTokenStore(jwtAccessTokenConverter());
    }

    @Bean
    public JwtAccessTokenConverter jwtAccessTokenConverter() {
        JwtAccessTokenConverter accessTokenConverter = new JwtAccessTokenConverter();
        accessTokenConverter.setSigningKey("test_key");//配置JWT使用的秘钥
        return accessTokenConverter;
    }
}
```

- 在认证服务器配置中指定令牌的存储策略为JWT：

```java
/**
 * 认证服务器配置
 */
@Configuration
@EnableAuthorizationServer
public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private UserService userService;

    @Autowired
    @Qualifier("jwtTokenStore")
    private TokenStore tokenStore;
    @Autowired
    private JwtAccessTokenConverter jwtAccessTokenConverter;

    /**
     * 使用密码模式需要配置
     */
    @Override
    public void configure(AuthorizationServerEndpointsConfigurer endpoints) {
        endpoints.authenticationManager(authenticationManager)
                .userDetailsService(userService)
                .tokenStore(tokenStore) //配置令牌存储策略
                .accessTokenConverter(jwtAccessTokenConverter);
    }

    //省略代码...
}

```

- 运行项目后使用密码模式来获取令牌，访问如下地址：http://localhost:9401/oauth/token

![image-20201216094709226](springcloud15-sc/image-20201216094709226.png)

- 发现获取到的令牌已经变成了JWT令牌，将access_token拿到https://jwt.io/ 网站上去解析下可以获得其中内容。

```json
{
  "exp": 1608086604,
  "user_name": "zbcn",
  "authorities": [
    "admin"
  ],
  "jti": "2da6377f-3d06-4830-a42e-e877a4009b5a",
  "client_id": "admin",
  "scope": [
    "all"
  ]
}
```

## 扩展JWT中存储的内容

有时候我们需要扩展JWT中存储的内容，这里我们在JWT中扩展一个key为`enhance`，value为`enhance info`的数据。

- 继承TokenEnhancer实现一个JWT内容增强器：

```java
public class JwtTokenEnhancer implements TokenEnhancer {
    @Override
    public OAuth2AccessToken enhance(OAuth2AccessToken oAuth2AccessToken, OAuth2Authentication oAuth2Authentication) {
        Map<String, Object> info = new HashMap<>();
        info.put("enhance", "enhance info");
        ((DefaultOAuth2AccessToken) oAuth2AccessToken).setAdditionalInformation(info);
        return oAuth2AccessToken;
    }
}
```

- 创建一个JwtTokenEnhancer实例：

```java
/**
 * 使用Jwt存储token的配置
 */
@Configuration
public class JwtTokenStoreConfig {

    //省略代码...

    @Bean
    public JwtTokenEnhancer jwtTokenEnhancer() {
        return new JwtTokenEnhancer();
    }
}

```

- 在认证服务器配置中配置JWT的内容增强器：

```java
/**
 * 认证服务器配置
 */
@Configuration
@EnableAuthorizationServer
public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private UserService userService;

    @Autowired
    @Qualifier("jwtTokenStore")
    private TokenStore tokenStore;
    @Autowired
    private JwtAccessTokenConverter jwtAccessTokenConverter;
    @Autowired
    private JwtTokenEnhancer jwtTokenEnhancer;

    /**
     * 使用密码模式需要配置
     */
    @Override
    public void configure(AuthorizationServerEndpointsConfigurer endpoints) {
        TokenEnhancerChain enhancerChain = new TokenEnhancerChain();
        List<TokenEnhancer> delegates = new ArrayList<>();
        delegates.add(jwtTokenEnhancer); //配置JWT的内容增强器
        delegates.add(jwtAccessTokenConverter);
        enhancerChain.setTokenEnhancers(delegates);
        endpoints.authenticationManager(authenticationManager)
                .userDetailsService(userService)
                .tokenStore(tokenStore) //配置令牌存储策略
                .accessTokenConverter(jwtAccessTokenConverter)
                .tokenEnhancer(enhancerChain);
    }

    //省略代码...
}

```

- 运行项目后使用密码模式来获取令牌，之后对令牌进行解析，发现已经包含扩展的内容。

```java
{
  "user_name": "zbcn",
  "scope": [
    "all"
  ],
  "exp": 1608087448,
  "authorities": [
    "admin"
  ],
  "jti": "80c61410-09e4-448d-a2ee-4a3c243f96c4",
  "client_id": "admin",
  "enhance": "enhance info"
}
```

## Java中解析JWT中的内容

如果我们需要获取JWT中的信息，可以使用一个叫jjwt的工具包。

- 在pom.xml中添加相关依赖：

```java
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt</artifactId>
    <version>0.9.0</version>
</dependency>
```

- 修改UserController类，使用jjwt工具类来解析Authorization头中存储的JWT内容。

```java
/**
 * Created by macro on 2019/9/30.
 */
@RestController
@RequestMapping("/user")
public class UserController {
    @GetMapping("/getCurrentUser")
    public Object getCurrentUser(Authentication authentication, HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        String token = StrUtil.subAfter(header, "bearer ", false);
        return Jwts.parser()
                .setSigningKey("test_key".getBytes(StandardCharsets.UTF_8))
                .parseClaimsJws(token)
                .getBody();
    }

}

```

- 在UserController中添加如下方法，使用jjwt工具类来解析Authorization头中存储的JWT内容。

```java
@GetMapping("/jwtCurrentUser")
    public Object getJwtCurrentUser(Authentication authentication, HttpServletRequest request){
        String header = request.getHeader("Authorization");
        String token = StrUtil.subAfter(header, "bearer ", false);
        return Jwts.parser()
                .setSigningKey("test_key".getBytes(StandardCharsets.UTF_8))
                .parseClaimsJws(token)
                .getBody();
    }
```

- 将令牌放入`Authorization`头中，访问如下地址获取信息：http://localhost:9401/user/getCurrentUser

![image-20201216140919273](springcloud15-oauth2结合jwt/image-20201216140919273.png)

问题：401Unauthorized 踩坑：请求后返回：

访问始终返回如下信息，而且将 user 信息中的password 清空，

```json
{
    "error": "invalid_token",
    "error_description": "Invalid access token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiJ6YmNuIiwic2NvcGUiOlsiYWxsIl0sImV4cCI6MTYwODEwMDQ3MiwiYXV0aG9yaXRpZXMiOlsiYWRtaW4iXSwianRpIjoiZmUzMTY1ODctYTY2NC00MDNhLWIyZWUtZTYwZDAyZjIxZTc5IiwiY2xpZW50X2lkIjoiYWRtaW4iLCJlbmhhbmNlIjoiZW5oYW5jZSBpbmZvIn0.JdvnhhAtufGc7L5IUS2HNtMBLzJsdxpDGHYAmANLrPM"
}
```

原因： TokenStore 冲突导致， 由于 配置为如下：

```java
//RedisTokenStoreConfig 中
@Bean
@Primary
public TokenStore redisTokenStore (){
    return new RedisTokenStore(redisConnectionFactory);
}
//JwtTokenStoreConfig 中
@Bean
public JwtTokenEnhancer jwtTokenEnhancer() {
    return new JwtTokenEnhancer();
}
```

导致 在程序运行时，将 redisTokenStore 默认使用了 redisTokenStore 。出现了问题。

在运行 DefaultTokenServices# loadAuthentication(String accessTokenValue) 方法时，默认使用了 redisTokenStore 。报错

![image-20201216141717890](springcloud15-oauth2结合jwt/image-20201216141717890.png)

解决方案：

1. 将 redis 相关的令牌配置关闭。只使用 jwt的方式。 
2. `ResourceServerConfig` 中指定使用哪个 tokenStore

```java
@Configuration
@EnableResourceServer
public class ResourceServerConfig extends ResourceServerConfigurerAdapter {

    @Autowired
    @Qualifier("redisTokenStore")
    private TokenStore tokenStore;

    @Autowired
    @Qualifier("jwtTokenStore")
    private TokenStore jwtTokenStore;

    @Override
    public void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
                .anyRequest()
                .authenticated()
                .and()
                .requestMatchers()
                .antMatchers("/user/**");//配置需要保护的资源路径
    }
    @Override
    public void configure(ResourceServerSecurityConfigurer resources) throws Exception {
        // 指定使用 哪个 tokenStore
        resources.tokenStore(jwtTokenStore);
        //resources.tokenStore(tokenStore);
    }
}
```



**仔细观察日志，里面必有问题根源。***



## 刷新令牌

在Spring Cloud Security 中使用oauth2时，如果令牌失效了，可以使用刷新令牌通过refresh_token的授权模式再次获取access_token。

- 只需修改认证服务器的配置，添加refresh_token的授权模式即可。

```java
/**
 * 认证服务器配置
 */
@Configuration
@EnableAuthorizationServer
public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {

    @Override
    public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
        clients.inMemory()
                .withClient("admin")
                .secret(passwordEncoder.encode("admin123456"))
                .accessTokenValiditySeconds(3600)
                .refreshTokenValiditySeconds(864000)
                .redirectUris("http://www.baidu.com")
                .autoApprove(true) //自动授权配置
                .scopes("all")
                .authorizedGrantTypes("authorization_code","password","refresh_token"); //添加授权模式
    }
}

```

- 使用刷新令牌模式来获取新的令牌，访问如下地址：http://localhost:9401/oauth/token

  ![image-20201216113213632](springcloud15-oauth2结合jwt/image-20201216113213632.png)

# 使用到的模块

```shell
ZBCN-SERVER
└── zbcn-author/oauth2-jwt-server -- 使用jwt的oauth2认证测试服务

```

