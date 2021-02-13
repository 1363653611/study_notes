---
title: HTTP 头请求与响应参数
date: 2021-01-12 12:14:10
tags:
  - newwork
categories:
  - newwork
topdeclare: true
reward: true
---
# HTTP 头请求与响应参数

# HTTP 通用首部字段

Http 协议除了我们的请求和响应参数，还包含了很多首部字段，这些字段使 Http 在满足基本接口的请求接收参数之余，还有更多高级丰富的扩展。这些首部字段可以分为3类：通用首部字段 / 请求首部字段 / 响应首部字段。本节我们将学习的是通用首部字段。

![image-20201201200212091](HTTP_HEADER_/image-20201201200212091.png)

#  简介

通用的首部字段指的是请求和响应的首部都能使用的字段。

- 请求示例

```http
GET / HTTP/1.1
Host: www.imooc.com
Connection: keep-alive

请求实体内容

```

- 响应实例

```http
HTTP/1.1 200 OK
Date: Web 29 Apr 2020 08:08:08 GMT
Connection: keep-alive

响应实体内容

```

# 字段介绍

## Connection

### Upgrade

该字段用来支持以一种协议建立连接后，想要升级成更高层的协议，比如 Http/1.1 想要升级成 Http/2.0 的协议，或者说要升级成 Websocket 协议。

```http
Upgrade：websocket
Connection: Upgrade
```

如果 Connection 的值是 Upgrade ，通常也需要一个 Upgrade 字段来标明要升级的协议，该值可以是多个的逗号分隔开，服务端会按照顺序查看支持的升级服务。

上面客户端想要升级成 Websocket 协议，如果服务端支持就会返回一个 `101 Switching Protocols` 响应状态码，和一个要切换到的协议的头部字段 Upgrade。 如果服务器没有（或者不能）升级这次连接，它会忽略客户端发送的 Upgrade 头部字段，返回一个常规的响应。

### Close

Http/1.1 规定了默认保持长连接（HTTP persistent connection ，也有翻译为持久连接），数据传输完成了保持 TCP 连接不断开（不发 RST 包、不四次握手），等待在同域名下继续用这个通道传输数据。当服务器端想明确断开连接时，则指定 Connection 首部字段的值为 Close。

```http
Connection: close
```

### Keep-Alive

Http/1.1 之前的 HTTP 版本的默认连接都是非持久连接。为此， 如果想在旧版本的 HTTP 协议上维持持续连接，则需要指定 Connection 首部字段的值为 Keep-Alive。

```http
Connection: Keep-Alive
```

## Cache-Control

通过指定首部字段 Cache-Control 的指令，就能操作缓存的工作机制。

#### 请求缓存

- **no-cache**：不读取过期的资源；
- **no-store**：不缓存；
- **max-age = [ 秒]**：响应的最大 Age 值；
- **max-stale( = [ 秒 ])**：接收已过期的响应；
- **min-fresh = [ 秒 ]**：期望在指定时间内的响应仍有效；
- **no-transform**：代理不可更改媒体类型；
- **only-if-cached**：只读缓存的资源；
- **cache-extension**：可以拓展 Cache-Control 首部字段内的指令

#### 响应缓存

- **public**：可向任意方提供响应的缓存；
- **private**：仅向特定用户返回响应；
- **no-cache**：缓存前必须先确认其有效性；
- **no-store**：不缓存请求或响应的任何内容；
- **no-transform**：代理不可更改媒体类型；
- **must-revalidate**：可缓存但必须再向源服务器进行确认；
- **proxy-revalidate**：可缓存但必须再向源服务器进行确认；
- **max-age = [ 秒]** ：响应的最大 Age 值；
- **s-maxage = [ 秒]**：可以拓展 Cache-Control 首部字段内的指令；

## Date

表明协议的日期，并没有什么特殊含义，在这里就不过多赘述了。

##  Trailer

Trailer 是拖车的意思，正常的报文是 `首部字段+回车符+请求体`，Trailer 允许在请求体的后面再添加首部信息。Trailer 的值会先表明请求体后面的首部字段是什么。

```shell
HTTP/1.1 200 OK
Trailer: Expires

--报文--
Expires: May, 1 Sep 2020 23:59:59 GMT
```

**使用场景**：首部字段的值是动态生成的，事先无法知道。如 content-length 请求体的长度，在分块传输中一开始无法确定内容的长度。还有一些可能是消息的数字签名，完整性校验等。

## Transfer-Encoding

可以通过此头属性确定通信内容的传输方式，如果指定 chunk 表示把大资源分为多个小块进行传输 。
通常情况下静态资源等小文件传输时可以指定 Content-Length 告知通信双方文件大小，而当传输资源无法确定大小时可以指定该属性进行传输
通信双方也无需知道文件大小，这样可以节省内存空间。此属性和 Content-Length 冲突，不能同时指定。

## Via

每经过一个代理服务器就往 head via 字段添加服务器信息，可以用来追踪请求的传输路径。

## Warning

用来告知客户端的一些告警信息。

# 小结

通用首部字段不多，一般是用来表示 缓存 / 时间 / 连接信息等通用内容。 其中 **Connection** 和 **Cache-Control** 是很常见的首部内容，要清楚的掌握它。