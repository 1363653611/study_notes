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
    - HEADER (头)
    - PAYLOAD (有效载荷)
    - SIGNATURE (签名)
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
