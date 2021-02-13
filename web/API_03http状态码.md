---
title: 协议状态码-概述
date: 2021-01-04 12:14:10
tags:
  - newwork
categories:
  - newwork
topdeclare: true
reward: true
---

# 协议状态码-概述

Http 协议根据场景约定了一系列请求返回的状态码，方便对请求结果进行细粒度管理。该状态码由**互联网号码分配局**维护管理。状态码是由3位数字组成，目前总共分为 5 大类：

## 请求状态5大类

- 1xx：消息；
- 2xx：成功；
- 3xx：重定向；
- 4xx：客户端错误；
- 5xx：服务器错误。

# 协议状态码-1XX

## 1xx 状态

`1xx` 表示的是请求还未完成，中间需要跟客户端协商信息。

## 100 Continue

初始的请求已经接受，客户应当继续发送请求的其余部分。在请求首部字段的小节中有个 `Expect` 字段。

```http
Expect: 100-continue
```

此时，如果服务器愿意接受，就会返回 100 Continue 状态码，反之则返回 417 Expectation Failed 状态码。场景可以用于，请求体比较大又不确定服务的能不能处理，可以先这样尝试询问下，待服务端接收后才发送正式大请求体。

## 101 Switching Protocols

服务器将遵从客户的请求转换到另外一种协议。常见的就是 Websocket 连接。

### **客户端**

```http
GET /websocket HTTP/1.1
Host: www.imocc.com
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Protocol: chat, superchat
Sec-WebSocket-Version: 13
```

客户端请求要将原本是 HTTP/1.1 协议升级成 Websocket 协议。

### 服务端

```http
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
```

服务端返回 101 代表协议转换成功。

## 102 Processing

由 WebDAV（RFC 2518）扩展的状态码，代表处理将被继续执行。跟 `100 Continue` 状态类似，只是 `100`的情况会立即返回，而 `102`的状态则需要等待比较久的时间，规定一般是超过 20s 以上。

# 协议状态码-2XX

`2xx` 表示的是请求已被正常处理了，以 2 开头的几个常用状态码如下：

## 200 OK

请求已成功，请求所希望的响应头或数据体将随此响应返回。出现此状态码是表示正常状态。

## 201 Created

请求已经被实现，而且有一个新的资源已经依据请求的需要而建立，且其 URI 已经随 Location 头信息返回。

### 适用场景

API 请求创建一个资源对象，返回了新资源对象的地址。目前开发中大部分是新增一个资源返回这个资源的 ID ，然后根据 ID 再查询详情。Http 的很多状态码都定很细，实践中并不都那么遵守理论。

#### 客户端

```http
POST /add-article HTTP/1.1
Content-Type: application/json
{ "article": "http" }
```

#### 服务端

```http
HTTP/1.1 201 Created
Location: /article/01
```

## 202 Accepted

表示请求已接收，但服务器未处理完成。
**适用场景**
请求作业耗时比较久的情况，后端可以先返回告诉客户端任务已开始，你可以先去处理别的事情了，而不用一直长时间等待。

## 203 Non-Authoritative Information

文档已经正常地返回，但一些应答头可能不正确，因为使用的是文档的拷贝，非权威性信息。

**适用场景**

请求借助代理服务器访问原始服务器，拿到数据后，代理服务器并没有把原始服务器的头部元数据完全拷贝过来，只是简单的把消息体传给前端的客户。甚至代理服务器把消息体都做了编码，这时候头部的 `Content-Encoding`就跟原始服务器不同了。

## 204 No Content

请求处理成功，但是服务端没有消息体返回。所以当浏览器收到 204 端请求时不需要更新数据。
**适用场景**：客户端向服务端发动消息，服务端不需要返回数据。

## 205 Reset Content

服务器成功处理了请求，且没有返回任何内容。但是与204响应不同，返回此状态码的响应要求请求者重置文档视图。该响应主要是被用于接受用户输入后，立即重置表单，以便用户能够轻松地开始另一次输入。

## 206 Partial Content

客户端对服务端的资源进行了某一部分的请求，服务端正常执行，响应报文中包含由 Content-Range 指定范围的实体内容。

### 客户端

```http
GET /imooc/video.mp4 HTTP/1.1
Range: bytes=1048576-2097152
```

### 服务端

```http
HTTP/1.1 206 Partial Content
Content-Range: bytes 1048576-2097152/3145728
Content-Type: video/mp4
```



# 协议状态码-3XX

`3XX` 代表重定向，代表需要客户端采取进一步的操作才能完成请求。通常，这些状态码用来重定向，后续的请求地址（重定向目标）在本次响应的 Location 域中指明。

## 300 Multiple Choices

有多个重定向的值，需要客户端自己选择， `Location` 的值是服务端建议的值。

```http
HTTP/1.1 300 Multiple Choices
Access-Control-Allow-Headers: Content-Type,User-Agent
Access-Control-Allow-Origin: *
Link: </foo> rel="alternate"
Link: </bar> rel="alternate"
Content-Type: text/html
Location: /foo
```

## 301 Moved Permanently

请求的资源已经永久性的转移了，新资源 URI 在头部 `Location`指明，这时候如果浏览器有书签，或者请求地址的缓存，最好都能替换成 `Location` 对应的值。

```http
HTTP/1.1 301 Moved Permanently
Location: https://www.imocc.com/http/301-moved-permanently
```

## 302 Found

跟 `301` 相似，只是 `302` 代表的资源转移地址是临时的。

## 303 See Other

`303` 状态码和 `302` 状态码有着相同的功能，但 `303` 状态码明 确表示客户端应当采用 GET 方法 请求 Location 的地址获取资源。

如果是以 POST 访问某个请求，返回 `303` ，此时应该换成 GET 方法去请求新地址。

## 304 Not Modified

一般是在有缓存的情况下，客户端发起资源获取请求，服务端判断之前的资源未修改过，可以继续使用缓存的资源。经常客户端请求的头部会带上 `If-None-Match` `If-Modified-Since` `If-Match` 等带有条件的头部字段。

### 客户端

```http
GET /foo HTTP/1.1
Accept: text/html
If-None-Match: "some-string"
```

### 服务端

```http
HTTP/1.1 304 Not Modified
ETag: "some-string"
```

## 305 Use Proxy

被请求的资源必须通过指定的代理才能被访问。Location 域中将给出指定的代理所在的 URI 信息，接收者需要重复发送一个单独的请求，通过这个代理才能访问相应资源。只有原始服务器才能建立305响应。

```http
HTTP/1.1 305 Use Proxy
Location: https://proxy.example.org:8080/
```

## 306 Switch Proxy

客户端已经是在代理模式，服务端可能出于安全因素，提示客户端需要切换一个新的代理。

***306 在新的规范中已经不在使用，该编码保留。***

```http
HTTP/1.1 306 Switch Proxy
Set-Proxy: SET; proxyURI="https://proxy.imooc.com:8080/" scope="http://", seconds=100
```

## 307 Temporary Redirect

`307` 跟 `302` 一样，都是对临时资源的重定向，不同的是 `307` 明确要求重定向的请求必须跟第一次的请求类型一样。第一次是 GET 第二次也必须是 GET，同样如果第一次是 POST，第二次也必须是 POST。`302` 则没有这么明确的要求，这可能导致有些浏览器第一次发出 POST，第二次却用 GET 重定向，而第二次实际上要求的是 POST，就容易出错。
`307` 是后面新增加的，这里提倡用 `307` 代替 `302`。

# 协议状态码-4XX

4XX 的状态码指的是请求出错了，而且很有可能是客户端侧的异常。客户端侧的异常很多，有时候情况也比较复杂，下面定义的状态码有时候也只能反应一个大概情况，而不一定确切的。

## 400 Bad Request

作为客户端异常的首个状态码，`400` 代表的意思很泛（错误的请求），一般指的是 `4XX` 其它状态码没有更合适的情况下就用 `400`，毕竟客户端出错类型很多，无法准确把情况都定义好。

## 401 Unauthorized

请求没有权限，通常返回的响应头部会包含 WWW-Authenticate 的头，浏览器遇到这种响应一般会弹出一个对话框，让用户重新提交用户名和密码进行认证。

### 服务端响应

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic; realm="Secured area"
```

### 客户端重新提交认证

```http
GET / HTTP/1.1
Authorization: Basic j3VsbCBkb25lOnlvdhBmb3Vu89B0aGUgZWFzdGVyIoUnZwo=
```

## 402 Payment Required

这是一个预留的状态，最初想要实现的是，一些商业网站，用户付费完后可以重复的发送请求，为支付而预留的。

## 403 Forbidden

访问被禁止了，`401` 确切指没有认证，`403` 范围就更多了，可能是登陆了但是没有这个资源的权限，可能是访问的源 `ip` 不在相应的白名单中，等所有不被允许的情况。

## 404 Not Found

很常见的一种错误码，可能是你的地址构造错了，也可能是后台服务器的资源确实没了。

## 405 Method Not Allowed

请求方法有 `POST` `GET` 这类，客户端访问的方法跟服务端能够提供的不一样，当请求状态是 `405` 的时候，响应信息头会带上 `Allow` 字段，告诉客户端被允许的请求方法是哪些。

```http
HTTP/1.1 405 Method Not Allowed
Content-Type: text/html
Allow: GET, HEAD, OPTIONS, PUT
```

## 406 Not Acceptable

指定的资源已经找到，但它的媒体类型和客户在Accpet头中所指定的不兼容，客户端浏览器不接受所请求页面的媒体类型。

### 客户端请求一个 Json 格式内容

```http
GET /foo HTTP/1.1
Accept: application/json
Accept-Language: fr-CA; q=1, fr; q=0.8 
```

### 服务端不支持 Json

```http
HTTP/1.1 406 Not Acceptable
Server: curveball/0.4
Content-Type: text/html
```

## 407 Proxy Authentication Required

要求进行代理身份验证，类似于401，表示客户必须先经过代理服务器的授权。

### 代理服务器返回需要认证的状态

```http
HTTP/1.1 407 Proxy Authentication Required
Proxy-Authenticate: Basic; realm="Secured area"
```

### 客户端发起代理认证

```http
GET / HTTP/1.1
Proxy-Authorization: Basic d2VsbCBkb25lOllvdSBmb3VuZCB0aGUgc2Vjb25kIGVhc3RlciBlZ2cK
```

### 原站需要认证，代理服务器也需要认证的情况

```http
GET / HTTP/1.1
Proxy-Authorization: Basic ZWFzdGVyIGVnZzpudW1iZXIgdGhyZWUK
Authorization: Bearer c2VuZCBtZSBhIHR3ZWV0IG9yIHNvbWV0aGluZwo
```

## 408 Request Timeout

客户端太慢了，超出了服务端允许的等待时间，服务端会返回 `408` 并断开连接。常见的有可能网速太慢了，一个请求发送太长时间还没发完。

```http
HTTP/1.1 408 Request Timeout
Connection: close
Content-Type: text/plain

Too slow! Try again
```

## 409 Conflict

客户端请求本身没问题，但是服务端对应的资源跟客户端要执行的操作有冲突。比如客户端要修改 **版本1**的某个资源，但是服务端着个资源只有在 **版本2** 才存在。

## 410 Gone

告知客户端某个资源不存在了，跟 `404` 很像，只是 `410` 更加明确该资源永久性改变了，如果客户端在许可的条件下，应该把所有指向着个地址的连接全部删除。`404` 就比较笼统，当前请求的资源不在了，不清楚后面会不会有。

`410` 响应的目的主要是帮助网站管理员维护网站，通知用户该资源已经不再可用，并且服务器拥有者希望所有指向这个资源的远端连接也被删除。

## 411 Length Required

服务器拒绝在没有定义 Content-Length 头的情况下接受请求。

## 412 Precondition Failed

请求头部带有一些先前条件，满足了才可以执行，不满足就返回 `412`。常见的就是要求某个资源过期了才能修改，不过期的时候执行 `PUT` 修改就报错。

## 413 Request Entity Too Large

服务器拒绝处理当前请求，因为该请求提交的实体数据大小超过了服务器愿意或者能够处理的范围。

## 414 Request-URI Too Long

请求的 `URI` 长度超过了服务器能够解释的长度，这种情况比较可能的是 `GET` 请求的 `URI` 携带的参数太多太大了。

## 415 Unsupported Media Type

请求实体的媒体类型不被服务器或者资源支持。例如，客户端想要返回一个 `application/json` 内容，服务端只能提供 `text/html` 类型的资源。

## 416 Requested Range Not Satisfiable

服务器不能满足客户在请求中指定的Range头。

## 417 Expectation Failed

在请求头 Expect 中指定的预期内容无法被服务器满足。

## 418 I’m a teapot

IETF 在愚人节的时候发布了一个 笑话的 RFC 提案，内容是：当客户端给一个茶壶发送泡咖啡的请求时，茶壶就返回一个418错误状态码，表示“我是一个茶壶”。后来官方想要去除该编号，竟然遭到了阻止，甚至不少浏览器都支持这个协议。是技术圈中一个错误而美好的典故。

## 421Misdirected Request

请求被指向到无法生成响应的服务器（比如由于连接重复使用）

## 422 Unprocessable Entity

请求格式正确，但是由于含有语义错误，无法响应。（RFC 4918 WebDAV）

## 423 Locked

当前资源被锁定。（RFC 4918 WebDAV）

## 424 Failed Dependency

由于之前的某个请求发生的错误，导致当前请求失败，例如 PROPPATCH。（RFC 4918 WebDAV）

## 425 Too Early

服务器不愿意冒风险来处理该请求，原因是处理该请求可能会被“重放”，从而造成潜在的重放攻击。

## 426 Upgrade Required

客户端应当切换到TLS/1.0。

## 449 Retry With

代表请求应当在执行完适当的操作后进行重试。

## 451 Unavailable For Legal Reasons

该请求因法律原因不可用。

# 协议状态码-5XX

5XX 指的是请求出错了，而且很有可能是服务端侧的异常。下面定义的状态码有时候也只能反应一个大概情况，而不一定确切的，主要是协助用户排查问题。

## 500 Internal Server Error

这是一个很常见的错误码，但这个错误码比较笼统，服务内容异常情况非常多，可能是代码问题，也可能是服务器资源问题等。如果是 500 的错误异常的话，后端开发的接口通常会把更详细的错误内容放在响应消息体里面。

## 501 Not Implemented

服务端不支持当前请求的某些功能，跟客户端异常 `405` 有点相似，只是 `405` 的情况侧重在客户端请求 Method 错误，而 `501` 侧重在，客户端请求的方法没问题，服务端本身有规划这个功能，但是还未实现。

## 502 Bad Gateway

Gateway 网关，软件架构中的网关跟网络路由器里面的网关有所不同，不能混为一体。软件架构的网关通常指的是靠近用户侧用于分发请求的代理服务，如 Nginx 作为代理接收请求，再分发到后面的具体服务提供者。

502 的状态指的是代理服务器正常，但是代理要去访问源站服务提供者发生错误了，代理服务器接收到无效的应答。



## 503 Service Unavailable

由于临时的服务器维护或者过载，服务器当前无法处理请求。这个状况是临时的，并且将在一段时间以后恢复。如果能够预计延迟时间，那么响应中可以包含一个 Retry-After 头用以标明这个延迟时间。

```http
HTTP/1.1 503 Service Unavailable
Content-Type text/plain
Retry-After: 1800
```

## 504 Gateway Timeout

网关请求源站时间超时。

## 505 HTTP Version Not Supported

服务器不支持请求中所指明的HTTP版本。

## 506 Variant Also Negotiates

一般客户端和服务端内容格式协商是在请求头部添加一系列的 `Accept-*`首部字段。当服务端有多个可选择的资源时会返回 `300 Multiple Choices`。当服务端由于某种异常无法提供客户端的请求项时，它可能会努力下，尝试返回一些资源选项让客户端去选。

## 507 Insufficient Storage

告诉客户端他们的 `POST` 或者 `PUT` 请求无法被成功，可能是因为传输的实体太大，服务端的磁盘有限。

## 509 Bandwidth Limit Exceeded

服务器达到带宽限制。

## 510 Not Extended

[RFC](https://tools.ietf.org/html/rfc2774) 中一个实验性的协议，服务端要求客户端使用一个扩展性的协议，但是客户端没有。目前基本没用到。

## 511 Network Authentication Required

告诉客户端连接的网络需要认证，可能所连接的 `Wi-Fi` 还没经过认证。

