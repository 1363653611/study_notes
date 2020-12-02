# 请求首部字段

请求的首部字段主要是客户端用来告知服务端自己能够支持的内容，让服务端尽量根据自己满足的优先级内容来响应。
请求的首部字段很多都是支持多个值的，并且有下面两个常见特性：

- 通配符：值类型支持用通配符表示，如 `*`；
- 添加因子权重 `q` 任何值都按照称为权重的相对质量值的优先顺序排列。

## Accept

告知服务端客户侧能够处理的媒体类型，一般是 `类型/子类型`的格式，支持多种类型根据优先级排序。

```http
GET /9_Q4simg2RQJ8t7jm9iCKT-xh_/s.gif HTTP/1.1
Accept: image/png,image/svg+xml,image/*;q=0.8,video/*;q=0.8,*/*;q=0.5
```



## Accept-Charset

告知服务端客户侧能够接收的字符集类型，支持多个根据优先级排序。服务端选择一个提议，使用它并在 Content-Type 响应头中通知客户它选择的内容。

```http
Accept-Charset: iso-8859-5, unicode-1-1;q=0.8
```



## Accept-Encoding

告知服务端客户侧能够支持的内容编码，通常是一种压缩算法。

```http
Accept-Encoding: br, gzip, deflate
```

## Accept-Language

告知服务端客户侧支持的语言类型，让服务端从中选择一种响应。

```http
Accept-Language: zh-cn
```

## From

告知服务器使用用户代理的用户的电子邮件地址，以便在出现异常时候通知你。

```http
From: imooc@example.org
```



## Host

告诉服务器自己要访问的的服务域名信息，有可能一台服务器绑定了多个不同域名，并且不同域名对应了不同服务。

```http
Host: www.imocc.com
```



## Authorization

```http
Authorization: <type> <credentials>
```

- `<type>` 认证类型。常见的类型是`Basic`；

- `<credentials>` 如果使用 `Basic` 身份验证方案，则凭证的构造方式如下所示：

  **base64(user:passwd)**

  ```shell
  Authorization: Basic GJxhZGRpbjpvcGWun3VzYW1l
  ```

  这种认证方式目前是比较少用了，比较用户名和密码放在请求头，而且 base64 简单加密是可逆的。建议用 Https 的加密协议。

## Proxy-Authorization

跟 Authorization 类似，不同的是 Authorization 是客户端与服务端的认证，Proxy-Authorization 是客户端与代理服务器的认证。

## If-Match

在请求头部添加资源条件，服务器会验证条件为真才会返回请求的资源。

```http
If-Match: <etag_value>, <etag_value>, …
```

**ETag（Entity Tag）** 是资源版本的标识符。工作方式类似于 Last-Modified，只是 ETag 值是资源的 Digest（比如，MD5 hash）：

![image-20201201202827032](HTTP_HEADER_02请求首部字段/image-20201201202827032.png)

## if-None-Match

与 if-Match 的作用相反，即 **Etag** 判断为 false 服务端才会处理该请求：

```http
If-None-Match: <etag_value>
```

## if-Modified-Since

也是在请求头部的条件，只是它关注的是资源的更新时间。如果服务端端资源在客户端 if-Modified-Since 指定的日期没有更新过，即资源不够新鲜就不会返回给客户端。

##  if-Range

if-Range 通常会带一个 Range 属性，当 if-Range 对应的 Etag 匹配时，服务端需要返回 Range 范围内的资源。最常见的场景就是断点续传，先根据 Etag 确定好一个资源。在断点续传中时间比较久资源更能会被修改到，可能会影响到客户端的资源 Range。如果 Etag 对应的 Digest 摘要一致就代表资源跟客户端想要的是一样，此时根据客户端要的 Range 部分返回。

```http
If-Match: "123456"
Range: bytes=1000-2000
```



## If-Unmodified-Since

If-Unmodified-Since 和 If-Modified-Since 的作用 相反。它的作用的是告知服务器，指定的请求资源只有在字段值内指定的日期时间之后，未发生更新的情况下，才能处理请求。

## Max-Forwards

客户端端请求有可能被服务端转发到其它代理服务，该字段限制服务端的转发次数。

## User-Agent

通常存储了浏览器客户端的信息

```http
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.5 Safari/605.1.15
```



## Referer

资源在请求的过程中有可能被转发，Referer 字段记录了请求的原始地址
比如在 `www.google.com` 里有一个 `www.baidu.com` 链接，那么点击这个 `www.baidu.com` ，它的 header信息里就有如下

```http
Referer=http://www.google.com
```

## TE

Transfer Encode 告诉服务端自己能够处理的传输编码。



# 小结

后台的开发人员能够从请求头部信息或者到很多有价值的东西，如 **User-Agent** 获取客户端信息，假设某个客户端一直访问，有可能是爬虫代码来抓取我们网站的资源了。**Referer** 字段可以知道请求从哪里来，假如别人的网站引用了你的图片，我们是可以从该字段得知的，可以禁用这类请求的响应。当然，根据具体的场景其它字段也可能有很多用处，利用好头部信息，也可以某种程度避免我们所有信息都定义在请求体参数中，也许都能实现，但是不够规范。