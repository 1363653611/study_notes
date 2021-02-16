---
title: RPC 框架概述
date: 2021-02-16 13:14:10
tags:
 - RPC
categories:
 - RPC
topdeclare: true
reward: true
---


### RPC 名词解释
- rpc 全名是 remote process call(远程过程调用)

- 实现方案:
  RMI  WEBSERVICE 等...
- rpc 将原来的本地调用转换为调用远端的服务器方法.给系统的的处理能力和和吞吐量带来了近似无限制提升的可能性.

- rpc组成: 客户端, 服务端.

### 对象的序列化和反序列化
- 结论: 无论何种类型的数据,最终都要转换为二进制再网络上进行传输

- 对象序列化: 将对象转换为二进制流的过程
- 对象反序列化:将二进制流转换为序列化的过程
- java 内置序列化的代码(内置流)
  - 字节输出流:
    ```
    os = new ByteArrayOutputStream()
    out = new ObjectOutputStream(os)
    out.writeObject(object)
    ```

<!--more-->

  - 字节输入流
  ```
  in = new byteArrayInputStream()
  read = new ObjectInputStream(in)
  object = read.readObject()
  ```
- Hession(hessian包)

#### 基于TCP 实现RPC 协议
- 使用 socket 做底层TCP 协议的支持.

#### 基于 http 实现 rpc 协议
- http (Hypertext transfer protocol) 超文本传输协议
- http 应用层协议(最上层协议)
- 网络协议栈: http(应用层)--> tcp(传输层)-->Ip(网络层)--->(网络层接口)

### 浏览器输入 url 后发生了生么事情?

以请求 `http://www.google.com:80/index.hml` 为例
1. 浏览器依据 HTTP协议 ,解析出url 对应的域名 (解析出 `www.google.com`)
2. 通过dns 服务器,解析出域名(`www.google.com`) 所对应的 ip地址(xxx.xxx.xx.xx).
3. 通过url 解析出对应的端口号(如果是80端口,默认可以省略).
4. 浏览器发起并建立到`xxx.xxx.xx.xx:80` 的连接.
5. 想浏览器发送GET 请求
6. 服务器响应浏览器的请求,浏览器读取响应,渲染页面
7. 浏览器关闭与服务器的连接.

### JSON 和 XML
- JSON (javaScript object Notation)

- XML(Extensible Markup Language) 可扩展标记语言
  - 标记数据
  - 定义数据类型
  - 允许用户对自己的标记语言进行dinginess
  - 用于标记电子文件,使其具有结构性的源语言

### RESTFUL 和 rpc

## 服务器的路由和负载均衡

### 服务器的演变
- 服务器的路由:SOA架构中,服务消费者通过名称,在众多服务器中找到要调用的服务器的地址列表
- 服务器的负载均衡:在请求到来时,为了将请求均衡的分配到后端服务器,负载均衡程序将从对应的服务器列表中,通过响应的负载均衡算法 和规则,选取一台服务器进行访问.

- 服务的规模较小时,可以采用硬编码的方式,将服务器的地址和配置写在代码中,通过硬编码的方式解决服务的路由和负载均衡问题,也可以通过传统的硬件负载均衡设备等

- 服务的规模较大时, 需要使用 配置中心解决方案.
  - 配置中心:一个能动态注册和获取服务信息的地方,来统一管理服务名称和对应的服务器列表信息.
