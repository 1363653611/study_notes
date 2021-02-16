---
title: raab_py 技术选型
date: 2021-02-09 15:14:10
tags:
 - python
categories:
 - python
topdeclare: true
reward: true
---

## raab_py 技术选型
### 什么是WSGI？
>维基百科上面的定义是：web 服务网关接口（Python Web Service GateWay Interface），简写为 `WSGI`.是为python 语言定义的web服务器和web应用程序之间的一种简单而通用的接口。
WSGI[1] （有时发音作'wiz-gee'）

- 规范说明  
  - WSGI区分为两个部分：
    1. “服务器”或“网关”
    2. “应用程序”或“应用框架”
  - 在处理一个WSGI请求时，服务器会为应用程序提供环境信息及一个回调函数（Callback Function）。当应用程序完成处理请求后，透过前述的回调函数，将结果回传给服务器
  - WSGI 中间件
    - 时实现了API的两方，因此可以在WSGI服务器和WSGI应用之间起调解作用
      - 从Web服务器的角度来说，中间件扮演应用程序
      - 而从应用程序的角度来说，中间件扮演服务器
    - 中间间提供的功能
      - 重写环境变量后，根据目标URL，将请求消息路由到不同的应用对象。
      - 允许在一个进程中同时运行多个应用程序或应用框架。
      - 负载均衡和远程处理，通过在网络上转发请求和响应消息。
      - 进行内容后处理，例如应用XSLT样式表。

<!--more-->

### 技术选型
> raab_py 使用 Flask 提供 web框架支持, 使用 setuptools 提供打包功能,在 正式环境中使用 `gunicorn` 和 `gevent` 配合提供部署功能.

#### Flask
  - `Flask` 本身只是 `Werkezug` 和 `Jinja2` 的之间的桥梁，`Werkezug`实现一个合适的 WSGI 应用，`Jinja2`处理模板。 `Flask` 也绑定了一些通用的标准库包，例如 `Logging` 功能 。
  - `FLask` 美其名曰 __微框架__; 不可能把所有的需求都囊括在核心里.
  核型理念是是为所有应用建立一个良好的基础，其余的一切都取决于你自己或者扩展。包括 数据库、缓存 等等。
##### Werkzeug
>Werkzeug 并不是 一个框架，它是一个 WSGI 工具集的库，你可以通过它来创建你自己的框架或 Web 应用。

- `Flask` 选择 `Werkzeug` 为路由系统
- 功能
  - 路由处理：如何根据请求 URL 找到对应的视图函数
  - request 和 response 封装: 提供更好的方式处理request和生成response对象
  - 自带的 WSGI server: 测试环境运行WSGI应用

##### Jinja2
> Jinja2 是一个 Python 的功能齐全的模板引擎。它有完整的 unicode 支持，一个可选 的集成沙箱执行环境，被广泛使用，以 BSD 许可证授权

- `Flask` 原生的模板引擎。
- raab_py 目前没用到页面渲染，所以也没用到 `Jinja2` 模板引擎功能

##### setuptools
>setuptools 作为Python标准的打包及分发工具。它会随着Python一起安装在开发人员的机器上。项目中只需写一个简短的setup.py安装文件，执行相关打包命令，就可以将Python应用打包.


#### 独立 WSGI 容器
>Flask 自带的 `app.run(host=SERVER_IP, port=5000,  threaded=True)`方式启动服务只是适合开发测试使用，业界生产环境中，一般要单独使用 `WSGI UNIX HTTP` 服务器，业界一般常用 `gunicorn` + `grent` + `Nginx` 方式部署web项目。也有其他方案。考虑到没有很多并发量，raab_py 目前使用 `gunicorn` + `grent` 完成任务。

#### gunicorn
> Gunicorn“绿色独角兽”是一个被广泛使用的高性能的Python WSGI UNIX HTTP服务器。  
Gunicorn 服务器作为wsgi app的容器，能够与各种Web框架兼容（flask，django等）,得益于gevent等技术，使用Gunicorn能够在基本不改变wsgi app代码的前提下，大幅度提高wsgi app的性能。

- 架构
  - 服务模型(Server Model)
    >Gunicorn是基于 pre-fork 模型的。也就意味着有一个中心管理进程( master process )用来管理 worker 进程集合。Master从不知道任何关于客户端的信息。所有的请求和响应处理都是由 worker 进程来处理的。

  - Master(管理者)
    >主程序是一个简单的循环,监听各种信号以及相应的响应进程。master管理着正在运行的worker集合,通过监听各种信号比如TTIN, TTOU, and CHLD. TTIN and TTOU响应的增加和减少worker的数目。CHLD信号表明一个子进程已经结束了,在这种情况下master会自动的重启失败的worker。

  - worker
    >woker有很多种，包括：gevent、geventlet、gtornado等等。这里主要分析gevent。
  每个gevent worker启动的时候会启动多个server对象：worker首先为每个listener创建一个server对象（注：为什么是一组listener,因为gunicorn可以绑定一组地址,每个地址对于一个listener），每个server对象都有运行在一个单独的gevent pool对象中。真正等待链接和处理链接的操作是在server对象中进行的。

  - WSGI SERVER
  > 真正等待链接和处理链接的操作是在gevent的WSGIServer 和 WSGIHandler中进行的。

- 总结：
  >gunicorn 会启动一组 worker进程，所有worker进程公用一组listener，在每个worker中为每个listener建立一个wsgi server。每当有HTTP链接到来时，wsgi server创建一个协程来处理该链接，协程处理该链接的时候，先初始化WSGI环境，然后调用用户提供的app对象去处理HTTP请求

#### gevent
> gevent是基于协程（greenlet）的网络库。gevent有一个很有意思的东西-monkey-patch，能够使python标准库中的阻塞操作变成异步，如socket的读写。  
由于gevent是基于IO切换的协程，所以最神奇的是，我们编写的Web App代码，不需要引入gevent的包，也不需要改任何代码，仅仅在部署的时候，用一个支持gevent的WSGI服务器，立刻就获得了数倍的性能提升。  
而 `gunicorn` 可以支持 gevent。


### 项目结构
```
raab_py
  - src # 系统包
    - config # 配置文件放置位置
      - config.yaml # 项目基础配置
      - logging.yaml # logging 日志的配置
      - setting.yaml # 基本配置，开发模式，线上模式的配置，以及相关配置信息的填写。
    - factory # 全局工厂功能
      - configFactory.py # 配置文件处理工厂
      - logFactory.py # 日志处理包
    - raab # 业务功能模块
      - _init_py # 该文件比较特别。 注册了 Flask， 以及引入了需要集成flask 路由功能的模块（如果不同时注册，则@app.root(...) 不会起作用）。
      - 其他业务包...

  - test # 测试包
  - gunicorn.py # gunicorn 启动配置文件
  - MANIFEST.in # 打包配置文件
  - readme.md # 系统操作说明文件
  - run.py # 开发环境启动
  - setup.py # 打包功能
  - wsgi.py # 服务器启动功能文件
```

#### 部署环境

__详见部署说明文档__

#### 其他
  - 其他相关说明和基本命令，请详见系统中的`readme.md` 中的相关说明

#### 参考：
- [WSGI 说明](https://zh.wikipedia.org/wiki/Web%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%BD%91%E5%85%B3%E6%8E%A5%E5%8F%A3)
- [Flask设计思路](https://dormousehole.readthedocs.io/en/latest/design.html#design)
- [Werkzeug教程](https://werkzeug-docs-cn.readthedocs.io/zh_CN/latest/tutorial.html)
- [Jinja2教程](http://docs.jinkan.org/docs/jinja2/templates.html)
- [gunicorn分析](https://blog.csdn.net/bbwangj/article/details/82684573)
- [gunicornz学习](http://www.hbnnforever.cn/article/gunicornbaseintro.html)
- [setuptools打包工具](http://www.bjhee.com/setuptools.html)
