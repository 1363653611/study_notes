---
title: security_01jwt
date: 2019-12-12 13:33:36
tags:
  - jwt
categories:
  - jwt
#top: 1
topdeclare: false
reward: true
---
### JWT （json web token）
#### 什么是token？
- Token(令牌)通常是指Security Token(安全令牌)
- 分类:
  - 可分为Hardware Token(硬件令牌)
  - Authentication Token(授权令牌)
  - USB Token(USB令牌)
  - Cryptographic Token(加密令牌)
  - Virtual Token(虚拟令牌)
  -  Key Fob(钥匙卡)
- 作用：主要作用是验证身份的合法性，以允许计算机系统的用户可以操作系统资源
- 生活中常见的令牌：登录密码，指纹，声纹，门禁卡，银行电子卡等。
<!--more-->
#### 什么是JSON Web Token  
![jsonWebToken](./img/json_web_token.jpg)
  - JSON Web Token(JWT)是一个基于RFC7519的开放数据标准，它定义了一种宽松且紧凑的数据组合方式，使用JSON对象在各应用之间传输加密信息。

  - 该JSON对象可以通过数字签名进行鉴签和校验，一般可采用HMAC算法、RSA或者ECDSA的公钥/私钥对数据进行签名操作。

  - JWT 包含信息 （三者之间使用 `.` 链接）
    - HEADER (头)：JSON 对象，描述 JWT 的元数据。其中 alg 属性表示签名的算法（algorithm）。默认是 HMAC SHA256（写成 HS256）；typ 属性表示这个令牌（token）的类型（type），统一写为 JWT
    - PAYLOAD (有效载荷)：JSON 对象，存放实际需要传递的数据，支持自定义字段
    - SIGNATURE (签名):这部分就是 JWT 防篡改的精髓，其值是对前两部分 base64UrlEncode 后使用指定算法签名生成，以默认 HS256 为例，指定一个密钥（secret），就会按照如下公式生成：
    
    ```java
    HMACSHA256(
     base64UrlEncode(header) + "." + base64UrlEncode(payload),
     secret,
    )
    ```
    
    
    
  - 格式：`head.payload.singature`
#### 如何创建JWT?  
JWT通常由“标头.有效载荷.签名”的格式组成。其中，标头用于存储有关如何计算JWT签名的信息，如对象类型，签名算法等。下面是JWT中Header部分的JSON对象实例：  

__标头__

```json
//标头：type表示该对象为JWT,alg表示创建JWT时使用HMAC-SHA256散列算法计算签名
{
  "type":"jwt",
  "alg":"hs256"
}
```
__有效载荷__
```json
//有效载荷：主要用于存储用户信息，如用户id，email，角色和权限信息等
{
  "uid":"1234556",
  "role":"admin",
  "name":"zhangsan"
}
```
__签名__ 需要使用Base64URL编码技术对标头和有效载荷进行编码，并作为参数和秘钥一同传递给签名算法,生成最终的签名 (Signature)
```js
//伪代码
var data = base64UrlEncode(head) + base64UrlEncode(payload)
var hashData = hmacSha256(data.secret)
var signature = base64UrlEncode(hashData)
```
#### 基于 Java 实现的 JWT  
导入包

```xml
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt</artifactId>
    <version>0.9.0</version>
</dependency>
```
1. 创建 token
```java
	/**
	 * 创建 Jwt
	 * @param type 数据类型 ：jwt
	 * @param subject  主题
	 * @param ttlMillis 过期时长
	 * @return
	 */
	public static String creatJwt(String type,String subject,long ttlMillis){
		//签名算法
		SignatureAlgorithm alg = SignatureAlgorithm.HS512;
		long startMillis = System.currentTimeMillis();
		Date date = new Date(startMillis);//签名时间
		Map<String, Object> claims = new HashMap<>(); //创建有效载荷(payload)
		claims.put("oid","91d2465c-77d9-429a-b4cf-4d61cbad8e3b");
		claims.put("org","www.zbcn.com");
		SecretKey key = key();
		JwtBuilder jwtBuilder = Jwts.builder().
				setClaims(claims)
				.setId(type)
				.setIssuedAt(date) //签发时间
				.setSubject(subject) //主题:是JWT 主题的拥有者,如:uuid,email,roles 等
				.signWith(alg, key);
		if(ttlMillis > 0){
			long expiredMillis = startMillis + ttlMillis;
			Date expiredDate = new Date(expiredMillis);
			jwtBuilder.setExpiration(expiredDate); //签名过期时间
		}
		return jwtBuilder.compact(); //生成jwt
	}
```
2. 生成密钥
```java
	/**
	 * 生成签名密钥
	 * @return
	 */
	private static SecretKey key(){
		byte[] decode = Base64Codec.BASE64.decode(SECRET_KEY);
		SecretKey key = new SecretKeySpec(decode, 0, decode.length, "AES");
		return key;
	}
```
3. 解析密钥
```java
	/**
	 * 解析jwt
	 * @param jwt
	 * @return
	 */
	public static Claims parse(String jwt){
		SecretKey key = key(); //获取签名密钥
		Claims body = Jwts.parser() //开始解析
				.setSigningKey(key)//设置密钥信息
				.parseClaimsJws(jwt)//解析主题信息
				.getBody();
		return body;
	}
```
4. 解析结果
```json
sub={"uid":"1234556","role":"admin","name":"zhangsan"}, # 有效载荷主体
org=www.zbcn.com,//
oid=91d2465c-77d9-429a-b4cf-4d61cbad8e3b,
 exp=1576143065, //过期时间
 iat=1576142465, //签发时间
 jti=jwt//对象类型
```
### jwt 工作流
![jwt工作流](./img/jwt工作流.png)

- 在身份验证中，当用户成功登录系统时，授权服务器将会把JWT返回给客户端，用户需要将此凭证信息存储在本地(cookie或浏览器缓存)。

- 当用户发起新的请求时，需要在请求头中附带此凭证信息，当服务器接收到用户请求时，会先检查请求头中有无凭证，是否过期，是否有效。

- 如果凭证有效，将放行请求；若凭证非法或者过期，服务器将回跳到认证中心，重新对用户身份进行验证，直至用户身份验证成功。以访问API资源为例，上图显示了获取并使用JWT的基本流程.

- 当客户端对应用服务器发起调用时，应用服务器会使用秘钥对签名进行校验，如果签名有效且未过期，则允许客户端的请求，反之则拒绝请求。

- 使用 JWT 的优势
  - 更少的数据库连接：因其基于算法来实现身份认证，在使用JWT时查询数据的次数更少(更少的数据连接不等于不连接数据库)，可以获得更快的系统响应时间。
  - 构建更简单：如果应用程序本身是无状态的，那么选择JWT可以加快系统构建过程。
  - 跨服务调用：可以构建一个认证中心来处理用户身份认证和发放签名的工作，其他应用服务在后续的用户请求中不需要(理论上)在询问认证中心，可使用自有的公钥对用户签名进行验证
  - 无状态：不需要向传统的Web应用那样将用户状态保存于Session中。
- 使用 JWT 的弊端
  - 严重依赖于秘钥
    - WT的生成与解析过程都需要依赖于秘钥(Secret)，且都以硬编码的方式存在于系统中(也有放在外部配置文件中的)。如果秘钥不小心泄露，系统的安全性将受到威胁。
  - 服务端无法管理客户端的信息:
    - 如果用户身份发生异常(信息泄露，或者被攻击)，服务端很难向操作Session那样主动将异常用户进行隔离。
  - 服务端无法主动推送消息
    - 服务端由于是无状态的，将无法使用像Session那样的方式推送消息到客户端，例如过期时间将至，服务端无法主动为用户续约，需要客户端向服务端发起续约请求。
  - 冗余的数据开销
    - 一个JWT签名的大小要远比一个Session ID长很多，如果对有效载荷(payload)中的数据不做有效控制，其长度会成几何倍数增长，且在每一次请求时都需要负担额外的网络开销。
  - JWT相比于Session,OIDC(OpenId Connect)等技术还比较新，支持的库还比较少。而且JWT也并非比传统Session更安全，它们都没有解决CSRF和XSS的问题。因此，在决定使用JWT前，需要仔细考虑其利弊。

### JWT 并非银弹
#### 考虑这样一个问题：如果客户端的JWT令牌泄露或者被盗取，会发生什么严重的后果？有什么补救措施？

如果单纯依靠JWT解决用户认证的所有问题，那么系统的安全性将是脆弱的。

由于JWT令牌存储于客户端中，一旦客户端存储的令牌发生泄露事件或者被攻击，攻击者就可以轻而易举的伪造用户身份去修改/删除系统资源。

虽然JWT自带过期时间，但在过期之前，攻击者可以肆无忌惮的操作系统数据。通过算法来校验用户身份合法性是JWT的优势，也是最大的弊端——太过于依赖算法。

反观传统的用户认证措施，通常会包含多种组合，如手机验证码，人脸识别，语音识别，指纹锁等。

用户名和密码只做用户身份识别使用，当用户名和密码泄露后，在遇到敏感操作时(如新增，修改，删除，下载，上传)，都会采用其他方式对用户的合法性进行验证(发送验证码，邮箱验证码，指纹信息等)以确保数据安全。

与传统的身份验证方式相比，JWT过多的依赖于算法，缺乏灵活性，而且服务端往往是被动执行用户身份验证操作，无法及时对异常用户进行隔离。

那是否有补救措施呢？答案是肯定的。接下来，将介绍在发生令牌泄露事件后，如何保证系统的安全。

### JWT 爬坑指南
#### 不管是基于Sessions还是基于JWT，一旦密令被盗取，都是一件棘手的事情。下面介绍JWT发生令牌泄露是该采取什么样的措施(包含但不局限于此)。
- 清除已泄露的令牌
  - 最直接也容易实现。将JWT令牌在服务端也存储一份，若发现有异常的令牌存在，则从服务端将此异常令牌清除。当用户发起请求时，强制用户重新进行身份验证，直至验证成功。服务端令牌的存储，可以借助Redis等缓存服务器进行管理，也可使用Ehcache将令牌信息存储在内存中。
- 敏感操作保护:
  - 在涉及到诸如新增，修改，删除，上传，下载等敏感性操作时，定期(30分钟，15分钟甚至更短)检查用户身份，如手机验证码，扫描二维码等手段，确认操作者是用户本人。如果身份验证不通过，则终止请求，并要求重新验证用户身份信息。
- 地域检查
  - 常用户会在一个相对固定的地理范围内访问应用程序，可以将地理位置信息作为辅助来甄别。如果发现用户A由经常所在的地区1变到了相对较远的地区2，或者频繁在多个地区间切换，不管用户有没有可能在短时间内在多个地域活动(一般不可能)，都应当终止当前请求，强制用户重新进行验证身份，颁发新的JWT令牌，并提醒(或要求)用户重置密码。
- 监控请求频率
  - 如果JWT密令被盗取，攻击者或通过某些工具伪造用户身份，高频次的对系统发送请求，以套取用户数据。针对这种情况，可以监控用户在单位时间内的请求次数，当单位时间内的请求次数超出预定阈值值，则判定该用户密令是有问题的。例如1秒内连续超过5次请求，则视为用户身份非法，服务端终止请求并强制将该用户的JWT密令清除，然后回跳到认证中心对用户身份进行验证。
- 客户端环境检查
  - 对于一些移动端应用来说，可以将用户信息与设备(手机,平板)的机器码进行绑定，并存储于服务端中，当客户端发起请求时，可以先校验客户端的机器码与服务端的是否匹配，如果不匹配，则视为非法请求，并终止用户的后续请求。

### 总结
JWT的出现，为解决Web应用安全性问题提供了一种新思路。但JWT并不是银弹，仍然需要做很多复杂的工作才能提升系统的安全性。

当然，世上没有完美的解决方案，系统的安全性需要开发者积极主动地去提升，其过程是漫长且复杂的。

[原文连接](https://mp.weixin.qq.com/s/N7Np7rgQwEAAcrW7OKxPiw)



## JOSE 规范

**什么是 JOSE ，它和 JWT 之间又有什么关系呢。**

JOSE 全称 JSON Object Signing and Encryption ( **RFC 7165**[3] , **RFC 7520**[4] )，它定义了一系列的标准，**用来规范网络传输过程中使用 JSON 的方式**，我们上面一直说的 JWT 其实是 JOSE 体系之一。

![image-20220126170834772](.\security-01jwt\image-20220126170834772.png) 

其中 JWT 又可分为 JWS 和 JWE 两种不同的实现，**我们大部分日常所使用的，所说的 JWT 其实应该属于 JWS 。**



### JWA 和 JWS 以及 JWK

JWA 的全称是 JSON Web Algorithms ( **RFC 7518**[5] ) ，字如其名， **JOSE 体系中涉及到的所有算法就是它来定义的**，比如通用算法有 Base64-URL 和 SHA，签名算法有 HMAC，RSA 和 Elliptic Curve（EC 椭圆曲线）.我们上面的 JWT 例子中第一部分 Header 有个 alg 属性，其值是 HS256 ，也就是 HMAC + SHA256 算法。

JWS 的全称是 JSON Web Signature ( **RFC 7515**[6] ) ，它的核心就是**签名**，保证数据未被篡改，而检查签名的过程就叫做**验证**。更通俗的理解，就是对应前面提到的 JWT 的第三部分 Signature ，所以我才会说我们日常所使用的 JWT 都是 JWS 。

通常在客户端-服务端模式中，JWS 使用 JWA 提供的 HS256 算法加上一个密钥即可，这种方式严格依赖密钥，但在分布式场景，可能多个服务都需要验证 JWT ，若要在每个服务里面都保存密钥，那么安全性将会大打折扣，要知道，密钥一旦泄露，任何人都可以随意伪造 JWT 。

解决办法就是使用非对称加密算法 RSA ，RSA 有两把钥匙，一把公钥，一把私钥，可以使用私钥签发（签名分发） JWT ，使用公钥验证 JWT ，公钥是所有人都可以获取到的。这样一来，就只有认证服务保存着私钥，进行签发，其他服务只能验证。

如下是一个使用 RS256 ( RSA + SHA256 ) 算法生成的 JWT ：

```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjF6aXlIVG15M184MDRDOU1jUENHVERmYWJCNThBNENlZG9Wa3VweXdVeU0ifQ.eyJqdGkiOiIzWUJ5eWZ2TDB4b01QNXdwTXVsZ0wiLCJzdWIiOiI2MDE5NDI5NjgwMWRjN2JjMmExYjI3MzUiLCJpYXQiOjE2MTI0NDQ4NzEsImV4cCI6MTYxMzY1NDQ3MSwic2NvcGUiOiJvcGVuaWQgZW1haWwgbWVzc2FnZSIsImlzcyI6Imh0dHBzOi8vc3RlYW0tdGFsay5hdXRoaW5nLmNuL29pZGMiLCJhdWQiOiI2MDE5M2M2MTBmOTExN2U3Y2IwNDkxNTkifQ.cYyZ6buwAjp7DzrYQEhvz5rvUBhkv_s8xzuv2JHgzYx0jbqqsWrA_-gufLTFGmNkZkZwPnF6ktjvPHFT-1iJfWGRruOOMV9QKPhk0S5L2eedtbKJU6XIEkl3F9KbOFwYM53v3E7_VC8RBj5IKqEY0qd4mW36C9VbS695wZlvMYnmXhIopYsd5c83i39fLBF8vEBZE1Rq6tqTQTbHAasR2eUz1LnOqxNp2NNkV2dzlcNIksSDbEGjTNkWceeTWBRtFMi_o9EWaHExdm5574jQ-ei5zE4L7x-zfp9iAe8neuAgTsqXOa6RJswhyn53cW4DwWg_g26lHJZXQvv_RHZRlQ
```

把它复制到 jwt.io 上面看看:

![image-20220126171401090](D:\ZBCN\study_notes\security\security-01jwt\image-20220126171401090.png)

注意我绿色框选中的地方，里面是一段 JSON ，我们把它删掉，看看输入框的提示信息

![image-20220126171510240](.\security-01jwt\image-20220126171510240.png)

这里提示了，里面是填写公钥格式（通常为 PEM）或者 JWK （我们说过 RSA 算法是使用私钥签发 JWT，公钥进行验证），刚刚我们删掉的是一段 JSON，所以必然不是公钥格式，那是 JWK 吗？

当然是，JWK 的全称是 JSON Web Key ( **RFC 7517**[7] ) ，它就是一个 JSON ，**JWK 就是用 JSON 来表示密钥**（JSON 字段因密钥类型而异）。例如刚才删除的 JWK ：

```json
{
  "e": "AQAB",
  "kty": "RSA",
  "n": "wVKQLBUqOBiay2dkn9TlbfuaF40_edIKUmdLq6OlvzEMrP4IDzdOk50TMO0nfjJ6v5830_5x0vRg5bzZQeKpHniR0sw7qyoSI6n2eSkSnFt7P-N8gv2KWnwzVs_h9FDdeLOeVOU8k_qzkph3_tmBV7ZZG-4_DEvgvat6ifEC-WzzYqofsIrTiTT7ZFxTqid1q6zrrsmyU2DQH3WdgFiOJVVlN2D0BuZu5X7pGZup_RcWzt_9T6tQsGeU1juSuuUk_9_FVDXNNCTObfKCTKXqjW95ZgAI_xVrMeQC5nXlMh6VEaXfO83oy1j36wUoVUrUnkANhp-dnjTdvJgwN82dGQ"
}
```

其中 kty 字段是必须的，代表密钥类型，支持 EC 椭圆曲线密钥，RSA 密钥和 oct 对称密钥。

JWK 和 公钥格式 Pem 是可以互相转换的：

![image-20220126171934910](security-01jwt/image-20220126171934910.png)

我们现在已经知道，验证这个 JWT 是需要公钥或 JWK 的，那你会不会好奇 jwt.io 这个网站是怎么知道 JWK 的呢，为什么一粘贴，就自动将 JWK 填充进去了。

原理其实很简单，而且已经是一种大家都遵循的规范了，就是将 JWK 放在 `iss/.well-known/jwks.json` 下，其中 iss 就是 Payload 里面的 iss 。

![image-20220126172037844](security-01jwt/image-20220126172037844.png)

![image-20220126172059680](security-01jwt/image-20220126172059680.png)

当在 jwt.io 粘贴下 JWT 的瞬间，jwt.io 会先解析 Header ，判断出 JWT 使用的算法（JWA），接着解析出 Payload 的信息，由于这里是 RS256 算法， 所以还会去请求 Payload 里的 iss 下的 `.well-known/jwks.json`得到 JWK ，从而完成 JWS 的验证。

### 另一种 JWT 的实现 ：JWE

我们说过，经过 Signature 签名后的 JWT 就是指的 JWS ，而 JWS 仅仅是对前两部分签名，保证无法篡改，但是其 Payload（载荷） 信息是暴露的（只是作了 base64UrlEncode 处理）。因此，使用 JWS 方式的 Payload 是不适合传递敏感数据的，JWT 的另一种实现 JWE 就是来解决这个问题的。

JWE 全称是 JSON Web Encryption ( **RFC 7516**[8] ) ，JWS 的 Payload 是 Base64Url 的明文，而 **JWE 的数据则是经过加密的。它可以使 JWT 更加安全。**

JWE 提供了两种方案：共享密钥方案和公钥/私钥方案。共享密钥方案的工作原理是让各方都知道一个密钥，大家都可以签名验证，这和 JWS 是一致的。而公钥/私钥方案的工作方式就不同了，在 JWS 中私钥对令牌进行**签名**，持有公钥的各方只能**验证**这些令牌；但在 JWE 中，持有私钥的一方是唯一可以**解密**令牌的一方，公钥持有者可以引入或交换新数据然后重新**加密**，因此，当使用公钥/私钥方案时，JWS 和 JWE 是互补的。

想要理解这一点的更简单的方法是从生产者和消费者的角度进行思考。生产者对数据进行签名或加密，消费者可以对其进行验证或解密。对于 JWS ，私钥对 JWT 进行签名，公钥用于验证，也就是生产者持有私钥，消费者持有公钥，数据流动只能从私钥持有者到公钥持有者。相比之下，对于 JWE ，公钥是用于加密数据，而私钥用来解密，在这种情况下，数据流动只能从公钥持有者到私钥持有者。如下图所示（来源 **JWT Handbook**[9] ）：

![image-20220126172914393](security-01jwt/image-20220126172914393.png)

相比于 JWS 的三个部分，JWE 有**五个部分组成**（四个小数点隔开）。一个 JWE 示例如下：

```
eyJhbGciOiJSU0ExXzUiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2In0.
UGhIOguC7IuEvf_NPVaXsGMoLOmwvc1GyqlIKOK1nN94nHPoltGRhWhw7Zx0-kFm1NJn8LE9XShH59_
i8J0PH5ZZyNfGy2xGdULU7sHNF6Gp2vPLgNZ__deLKxGHZ7PcHALUzoOegEI-8E66jX2E4zyJKxYxzZIItRzC5hlRirb6Y5Cl_p-ko3YvkkysZIFNPccxRU7qve1WYPxqbb2Yw8kZqa2rMWI5ng8Otv
zlV7elprCbuPhcCdZ6XDP0_F8rkXds2vE4X-ncOIM8hAYHHi29NX0mcKiRaD0-D-ljQTPcFPgwCp6X-nZZd9OHBv-B3oWh2TbqmScqXMR4gp_A.
AxY8DCtDaGlsbGljb3RoZQ.
KDlTtXchhZTGufMYmOYGS4HffxPSUrfmqCHXaI9wOGY.
9hH0vgRfYgPnAHOd8stkvw
```

- Protected Header (受保护的头部) ：类似于 JWS 的 Header ，标识加密算法和类型。
- Encrypted Key (加密密钥) ：用于加密密文和其他加密数据的密钥。
- Initialization Vector (初始化向量) ：一些加密算法需要额外的（通常是随机的）数据。
- Encrypted Data (Ciphertext) (加密的数据) ：被加密的数据。
- Authentication Tag (认证标签) ：算法产生的附加数据，可用于验证密文内容不被篡改。

这五个部分的生成，也就是 JWE 的加密过程可以分为 7 个步骤：

1. 根据 Header alg 的声明，生成一定大小的随机数
2. 根据密钥管理方式确定 Content Encryption Key ( CEK )
3. 根据密钥管理方式确定 JWE Encrypted Key
4. 计算所选算法所需大小的 Initialization Vector (IV)。如果不需要，可以跳过
5. 如果 Header 声明了 zip ，则压缩明文
6. 使用 CEK、IV 和 Additional Authenticated Data ( AAD，额外认证数据 ) ，通过 Header enc 声明的算法来加密内容，结果为 Ciphertext 和 Authentication Tag
7. 最后按照以下算法构造出 Token：

````
base64(header) + '.' +
base64(encryptedKey) + '.' + // Steps 2 and 3
base64(initializationVector) + '.' + // Step 4
base64(ciphertext) + '.' + // Step 6
base64(authenticationTag) // Step 6
````

JWE 相比 JWS **更加安全可靠，但是不够轻量，有点复杂。**

### 安全性考虑

不管怎样，JWT 多多少少还是存在一些安全性隐患的，**下面是平时开发过程的一些建议：**

1. 始终执行算法验证

签名算法的验证固定在后端，不以 JWT 里的算法为标准。假设每次验证 JWT ，验证算法都靠读取 Header 里面的 alg 属性来判断的话，攻击者只要签发一个 "alg: none" 的 JWT ，就可以绕过验证了。

2. 选择合适的算法

具体场景选择合适的算法，例如分布式场景下，建议选择 RS256 。

3. HMAC 算法的密钥安全

除了需要保证密钥不被泄露之外，密钥的强度也应该重视，防止遭到字典攻击。

4. 避免敏感信息保存在 JWT 中

JWS 方式下的 JWT 的 Payload 信息是公开的，不能将敏感信息保存在这里，如有需要，请使用 JWE 。

5. JWT 的有效时间尽量足够短

JWT 过期时间建议设置足够短，过期后重新使用 refresh_token 刷新获取新的 token 。

### 总结

- JOSE：规范网络传输过程中使用 JSON 的一系列标准
- JWT：以 JSON 编码并由 JWS 或 JWE 安全传递的表示形式
- JWS：签名和验证 Token
- JWE：加密和解密 Token
- JWA：定义 JOSE 体系中涉及到的所有算法
- JWK：用 JSON 来表示密钥

最后，再次附上 JOSE 的体系图，相关的 RFC 均备注在图上了：

![image-20220126173517337](security-01jwt/image-20220126173517337.png)
