# 响应首部字段

响应的头部字段很大一部分跟请求是对应的，客户端提了自己的诉求并根据优先级列举，服务端会根据自身情况选择一种回复客户端，这种过程就叫做内容协商（content negotiation）。内容协商的字段一般请求的首部是 Accept 开头，而响应的首部是 Content 开头。

## Content-Encoding

告知客户端内容的编码方式： `Content-Encoding: gzip`

## Content-Language

告知客户端返回内容的语言：`Content-Language: zh-CN`

## Content-Length

告知客户端内容的长度： 	`Content-Length: 5106`

## Content-Location

客户端请求某个 URL 资源，通过内容协商 比如：Accept-Language，后端会有对应的 URL_language 更具体的资源路径。此时响应的 Content-Location 就是后端具体的资源位置。

![image-20201201203722205](HTTP_HEADER_03响应首部字段/image-20201201203722205.png)

## Location

Location 跟 Content-location 是没什么关系的，Location 主要是在重定向的场景中表明访问的原始 URL 是什么。

##  Content-MD5

告诉客户端响应内容按照 MD5 签名后的值是什么，客户端根据返回内容也按照MD5算法生产一个 MD5值。如果两者的值一样证明传输过程中 Http 的内容没有被篡改过，否则就代表内容可能被人伪造过，是不可信的。

## Content-Range

断点续传中，告知客户端返回的内容范围，字段值以字节为单位。

## Accept-Ranges

告知客户端服务器是否能处理范围 请求，以指定获取服务器端某个部分的资源。可指定的字段值有两种，可处理范围请求时指定其为 bytes，反之 则指定其为 none。

## Content-Type

```http
Content-Type: text/html; charset=UTF-8
```

告知客户端，响应内容的媒体类型，如 Json 报文/ Html 文件 / JavaScript 脚本 / 图片 / 视频 等。

## Age

Age 主要记录的是代理服务器跟原站的响应时间差，如果 Age: 0，它可能只是从原始服务器获取; 否则它通常是根据代理的当前日期和Date HTTP 响应中包含的通用头部之间的差异来计算的。

## ETag

告知客户端实体标识。

##  Proxy-Authenticate

把由代理服务器所要求的认证信息 发送给客户端。

## WWW-Authenticate

告知客户端所指定资源的认证方案(Basic 或是 Digest)，状态码 401 Unauthorized 响应中，肯定 带有首部字段 WWW-Authenticate。

```http
WWW-Authenticate: Basic realm="Usagidesign Auth"
```



## Retry-After

告知客户端应该在多久之后再次发送请求。主 要配合状态码 503 Service Unavailable 响应，或 3xx Redirect 响应一起 使用。

## Server

告知客户端服务器所使用的 Web 服务软件及版本信息，该字段尽量不要暴露，否则会有安全问题。假设黑客知道你用的是 Tomcat 并且是 XX 版本，他就会去查找这个 Tomcat 版本的软件有什么漏洞，然后攻击你的服务器。

## Vary

主要是在缓存场景中使用，一般我们都说 URL 是可以唯一定位一个资源的，其实不完全正确，比如 客户端对语言不同需求，同一个 URL 可能得到不同的资源。缓存服务器会配合 Vary 字段判断哪些需要缓冲。

```http
Vary: Accept-Language
```

可以避免用户访问是英文的资源请求，而服务端将之前缓存的中文资源提供给客户。

## Expires

告知客户端资源失效的日期，如果是缓存服务器会在 Expires 指定的时间到了才会额外发起请求。

# 小结

响应首部信息通常标志了请求资源的属性，如过期时间是什么时候，资源编码，请求是否经过代理等。