以前一直使用的是`jjwt`这个JWT库，虽然小巧够用, 但对JWT的一些细节封装的不是很好。最近发现了一个更好用的JWT库`nimbus-jose-jwt`，简单易用，API非常易于理解，对称加密和非对称加密算法都支持。

# 简介

`nimbus-jose-jwt`是最受欢迎的JWT开源库，基于Apache 2.0开源协议，支持所有标准的签名(JWS)和加密(JWE)算法。

# JWT 概念关系

- JWT(JSON Web Token)指的是一种规范，这种规范允许我们使用JWT在两个组织之间传递安全可靠的信息。
- 而JWS(JSON Web Signature)和JWE(JSON Web Encryption)是JWT规范的两种不同实现，我们平时最常使用的实现就是JWS。

# 使用

接下来我们将介绍下`nimbus-jose-jwt`库的使用，主要使用对称加密（HMAC）和非对称加密（RSA）两种算法来生成和解析JWT令牌。

## 对称加密　ＨＭＡＣ

> 对称加密指的是使用`相同`的秘钥来进行加密和解密，如果你的秘钥不想暴露给解密方，考虑使用非对称加密。

要使用`nimbus-jose-jwt`库，首先在`pom.xml`添加相关依赖；

```xml
<!--JWT解析库-->
<dependency>
    <groupId>com.nimbusds</groupId>
    <artifactId>nimbus-jose-jwt</artifactId>
    <version>8.16</version>
</dependency>
```

创建`PayloadDto`实体类，用于封装JWT中存储的信息；

```java
@EqualsAndHashCode(callSuper = false)
@Builder
@Data
public class PayloadDto {

    @ApiModelProperty("主题")
    private String sub;
    @ApiModelProperty("签发时间")
    private Long iat;
    @ApiModelProperty("过期时间")
    private Long exp;
    @ApiModelProperty("JWT的ID")
    private String jti;
    @ApiModelProperty("用户名称")
    private String username;
    @ApiModelProperty("用户拥有的权限")
    private List<String> authorities;
}
```

创建`JwtTokenServiceImpl`作为JWT处理的业务类，添加根据`HMAC`算法生成和解析JWT令牌的方法，可以发现`nimbus-jose-jwt`库操作JWT的API非常易于理解

```java
@Service
public class JwtTokenServiceImpl implements JwtTokenService {
    @Override
    public String generateTokenByHMAC(String payloadStr, String secret) throws JOSEException {
        //创建JWS头，设置签名算法和类型
        JWSHeader header = new JWSHeader.Builder(JWSAlgorithm.HS256)
                .type(JOSEObjectType.JWT)
                .build();
        //将负载信息封装到Payload中
        Payload payload = new Payload(payloadStr);
        //创建JWS对象
        JWSObject jwsObject = new JWSObject(header, payload);
        //创建HMAC签名器
        MACSigner jwsSigner = new MACSigner(secret);
        //签名
        jwsObject.sign(jwsSigner);

        return jwsObject.serialize();
    }

    @Override
    public PayloadDto verifyTokenByHMAC(String token, String secret) throws ParseException, JOSEException {
        //从token中解析JWS对象
        JWSObject jwsObject  = JWSObject.parse(token);
        //创建HMAC验证器
        JWSVerifier jwsVerifier = new MACVerifier(secret);
        if (!jwsObject.verify(jwsVerifier)) {
            throw new JwtInvalidException("token签名不合法！");
        }
        String payload  = jwsObject.getPayload().toString();
        PayloadDto payloadDto = JSONUtil.toBean(payload, PayloadDto.class);

        if(payloadDto.getExp() < new Date().getTime()){
            throw new JwtExpiredException("token已过期！");
        }

        return payloadDto;
    }
}
```

在`JwtTokenServiceImpl`类中添加获取默认的PayloadDto的方法，JWT过期时间设置为`60min`；

```java
@Override
public PayloadDto getDefaultPayloadDto() {
    Date now = new Date();
    Date exp = DateUtil.offsetSecond(now, 60*60);

    return PayloadDto.builder()
        .sub("zbcn")
        .iat(now.getTime())
        .exp(exp.getTime())
        .jti(UUID.randomUUID().toString())
        .username("zbcn")
        .authorities(CollUtil.toList("ADMIN"))
        .build();
}
```

创建`JwtTokenController`类，添加根据HMAC算法生成和解析JWT令牌的接口，由于HMAC算法需要长度至少为`32个字节`的秘钥，所以我们使用MD5加密下；

```java
@Api( "JWT令牌管理")
@RestController
@RequestMapping("/token")
public class JwtTokenController {

    @Autowired
    private JwtTokenService jwtTokenService;

    @ApiOperation("使用对称加密（HMAC）算法生成token")
    @GetMapping(value = "/hmac/generate")
    public ResponseResult generateTokenByHMAC() {
        try {
            PayloadDto payloadDto = jwtTokenService.getDefaultPayloadDto();
            String token = jwtTokenService.generateTokenByHMAC(JSONUtil.toJsonStr(payloadDto), SecureUtil.md5("test"));
            return ResponseResult.success(token);
        } catch (JOSEException e) {
            return ResponseResult.fail("生成密钥失败", e);
        }
    }

    @ApiOperation("使用对称加密（HMAC）算法验证token")
    @GetMapping(value = "/hmac/verify")
    public ResponseResult verifyTokenByHMAC(String token) {
        try {
            PayloadDto payloadDto  = jwtTokenService.verifyTokenByHMAC(token, SecureUtil.md5("test"));
            return ResponseResult.success(payloadDto);
        } catch (ParseException | JOSEException e) {
            return ResponseResult.fail("验证密钥失败", e);
        }
    }
}

```

调用使用HMAC算法生成JWT令牌的接口进行测试 ` http//:localhost:9000/swagger-ui.html `；

![image-20201230104428811](security-05nimbus-jose-jwt/image-20201230104428811.png)

# 非对称加密（RSA）

> 非对称加密指的是使用公钥和私钥来进行加密解密操作。对于`加密`操作，公钥负责加密，私钥负责解密，对于`签名`操作，私钥负责签名，公钥负责验证。非对称加密在JWT中的使用显然属于`签名`操作。

## jwt.jks 生成

如果我们需要使用固定的公钥和私钥来进行签名和验证的话，我们需要生成一个证书文件，这里将使用Java自带的`keytool`工具来生成`jks`证书文件，该工具在JDK的`bin`目录下；

![image-20201230110431975](security-05nimbus-jose-jwt/image-20201230110431975.png)

以管理员方式打开CMD命令界面，使用如下命令生成证书文件，设置别名为`jwt`，文件名为`jwt.jks`；

```shell
keytool -genkey -alias jwt -keyalg RSA -keystore jwt.jks
```

![image-20201230110759772](security-05nimbus-jose-jwt/image-20201230110759772.png)

将证书文件`jwt.jks`复制到项目的`resource`目录下，然后需要从证书文件中读取`RSAKey`。

## 非对称 算法 RSA 功能 集成

- 需要在`pom.xml`中添加一个Spring Security的RSA依赖；

```xml
<!--Spring Security RSA工具类-->
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-rsa</artifactId>
    <version>1.0.9.RELEASE</version>
</dependency>
```

- 然后在`JwtTokenServiceImpl`类中添加方法，从类路径下读取证书文件并转换为`RSAKey`对象；

```java
   @Override
    public RSAKey getDefaultRSAKey() {
        //从classpath下获取RSA秘钥对
        KeyStoreKeyFactory keyStoreKeyFactory = new KeyStoreKeyFactory(new ClassPathResource("jwt.jks"),"123456".toCharArray());
        KeyPair keyPair = keyStoreKeyFactory.getKeyPair("jwt", "123456".toCharArray());
        //获取RSA公钥
        RSAPublicKey publicKey = (RSAPublicKey) keyPair.getPublic();
        //获取RSA私钥
        RSAPrivateKey privateKey = (RSAPrivateKey) keyPair.getPrivate();
        return new RSAKey.Builder(publicKey).privateKey(privateKey).build();
    }
```

- `JwtTokenController`中添加一个接口，用于获取证书中的公钥

```java
@ApiOperation("获取非对称加密（RSA）算法公钥")
@GetMapping(value = "/rsa/publicKey")
public ResponseResult getRSAPublicKey(){
    RSAKey defaultRSAKey = jwtTokenService.getDefaultRSAKey();
    JWKSet jwkSet = new JWKSet(defaultRSAKey);
    return ResponseResult.success(jwkSet);
}
```

- 调用该接口，查看公钥信息，公钥是可以公开访问的 `http://localhost:9000/swagger-ui.html#/jwt-token-controller/getRSAPublicKeyUsingGET`

![image-20201231095648050](security-05nimbus-jose-jwt/image-20201231095648050.png)

- 在`JwtTokenServiceImpl`中添加根据`RSA`算法生成和解析JWT令牌的方法

```java
@Override
public PayloadDto verifyTokenByRSA(String token, RSAKey rsaKey) throws ParseException, JOSEException {
    //从token中解析JWS对象
    JWSObject jwsObject = JWSObject.parse(token);
    RSAKey publicRsaKey = rsaKey.toPublicJWK();
    //使用RSA公钥创建RSA验证器
    JWSVerifier jwsVerifier = new RSASSAVerifier(publicRsaKey);
    if (!jwsObject.verify(jwsVerifier)) {
        throw new JwtInvalidException("token签名不合法！");
    }
    String payload = jwsObject.getPayload().toString();
    PayloadDto payloadDto = JSONUtil.toBean(payload, PayloadDto.class);
    if (payloadDto.getExp() < new Date().getTime()) {
        throw new JwtExpiredException("token已过期！");
    }
    return payloadDto;
}

@Override
public String generateTokenByRSA(String payloadStr, RSAKey rsaKey) throws JOSEException {
    //创建JWS头，设置签名算法和类型
    JWSHeader jwsHeader = new JWSHeader.Builder(JWSAlgorithm.RS256)
        .type(JOSEObjectType.JWT)
        .build();
    //将负载信息封装到Payload中
    Payload payload = new Payload(payloadStr);
    //创建JWS对象
    JWSObject jwsObject = new JWSObject(jwsHeader,payload);
    //创建RSA签名器
    JWSSigner jwsSigner = new RSASSASigner(rsaKey,true);
    //签名
    jwsObject.sign(jwsSigner);
    return jwsObject.serialize();
}
```

- 在`JwtTokenController`类，添加根据RSA算法生成和解析JWT令牌的接口

```java
@ApiOperation("使用非对称加密（RSA）算法生成token")
@GetMapping(value = "/hmac/generate")
public ResponseResult generateTokenByRSA(){
    PayloadDto payloadDto = jwtTokenService.getDefaultPayloadDto();
    try {
        String token = jwtTokenService.generateTokenByRSA(JSONUtil.toJsonStr(payloadDto), jwtTokenService.getDefaultRSAKey());
        return ResponseResult.success(token);
    } catch (JOSEException e) {
        return ResponseResult.fail("生成RSA token 失败。",e);
    }
}

@ApiOperation("使用非对称加密（RSA）算法验证token")
@GetMapping(value = "/rsa/verify")
public ResponseResult verifyTokenByRSA(String token){
    try {
        PayloadDto payloadDto = jwtTokenService.verifyTokenByRSA(token, jwtTokenService.getDefaultRSAKey());
        return ResponseResult.success(payloadDto);
    } catch (ParseException | JOSEException  e) {
        return ResponseResult.fail("RSA 验证token 失败。", e);
    }
}
```

- 测试：

![image-20201231113209601](security-05nimbus-jose-jwt/image-20201231113209601.png)

