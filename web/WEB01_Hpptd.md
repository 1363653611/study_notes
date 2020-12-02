# Web 服务器：概述

刚入门 Web 的小伙伴很容易迷失在 Apache、Tomcat、Httpd、Nginx 这些陌生词汇中，所以在开始本章节的内容前我们先来认识下它们。

## Apache

全球最权威的软件开源协会，很多公司会把自己内部的一些系统开源并提交申请给 Apache，让 Apache 统一来管理这些开源项目为全世界的软件做贡献，同时也提升了公司的知名度和一些商业的战略价值。**尴尬的一点是早期的 Http Server 就叫做 Apache，后来的版本改名为 Httpd 了，所以很多人习惯说 Apache 服务器，其实默认指的是 Httpd**；

## Httpd

Apache 旗下的 Web 服务器，它只提供静态资源的访问；

## Tomcat

Apache 旗下的另一个开源项目，区别于 Httpd 的是它支持动态内容服务；

## Nginx

Apache 的另一个开源服务器，但是更多时候拿他来作为代理服务器。Nginx 的功能非常强大，远超了 Http 服务器的范畴，更像是一个网络管理工具。

# APACHE HTTPD

Httpd 是 C 语言编写的遵从 Http 协议的服务器，是一个高度模块化软件，由 Server 和 Module 组成。这些模块大都是动态模块，因此可以随时加载。

- 源码开源地址：https://github.com/apache/httpd ；
- 官网地址：[https://httpd.apache.org](https://httpd.apache.org/)；

Httpd 作为起步比较早的一个 Web 开源项目，代码的稳定性/社区/文档 都是比较可靠的，他支持的功能非常丰富，并且可以按需地引入自己所需要的模块。

Httpd 一般比较的对象是 Nginx 服务器，他们两个是静态资源服务器的首选：

- Nginx 轻量且并发能力高于 Httpd；
- Nginx 能够实现负载均衡；
- Httpd 支持的功能模块比较丰富；
- Httpd 的 `rewrite` 功能强于 Nginx。

当然，也有的网站架构同时用到了 Nginx 和 Httpd ，用 Nginx 作为负载均衡，将流量分发到后面的 Httpd Web服务端。

## Httpd 的工作模型

对于请求 Httpd 有 3 种处理模型，MPM（Mulit Path Modules，多路径处理模块）它们会影响到 Httpd 的速度和可伸缩性。在编译的时候可以根据需要使用 `--with-mpm` 选项来指定 Httpd 的工作方式，默认是 `prefork` 模式。

| 工作模式  | 说明                                                         |
| :-------- | :----------------------------------------------------------- |
| `prefork` | 服务器启动时会生成多个进程，并且每一个进程处理一个请求，这种模式并发能力较差。 |
| `worker`  | 服务启动的时候也是会生成多个进程，但是每个进程又会生成多个线程，让线程来负责处理请求。这种模式会比prefork并发能力好些。 |
| `event`   | 基于事件的驱动，一个进程处理多个请求，这种模式的并发处理能力最强。 |

可以通过 `httpd -V` 命令查看当前的工作模型：

> **Tips**：比较旧的版本需要用 `apachectl -V` 命令来查看当前工作模型。

```shell
$ httpd -V
Server version: Apache/2.4.18 (Unix)
Server built:   Feb 18 2020 02:28:26
Server's Module Magic Number: 20120211:52
Server loaded:  APR 1.5.2, APR-UTIL 1.5.4
Compiled using: APR 1.5.2, APR-UTIL 1.5.4
Architecture:   64-bit
Server MPM:     event
  threaded:     yes (fixed thread count)
    forked:     yes (variable process count)

```

不同的工作模式，对应着不同的配置。

###  prefork

```shell
<IfModule prefork.c>
StartServers 5 # 启动 apache 时启动的 httpd 进程个数。
MinSpareServers 5 # 服务器保持的最小空闲进程数。
MaxSpareServers 10 # 服务器保持的最大空闲进程数。
MaxClients 150 # 最大并发连接数。
MaxRequestsPerChild 1000 # 每个子进程被请求服务多少次后被 kill 掉。0表示不限制，推荐设置为1000。
</IfModule>
```

### worker

```shell
<IfModule worker.c> 
    StartServers 2 # 启动 apache 时启动的 httpd 进程个数。 
    MaxClients 150 # 最大并发连接数。 
    MinSpareThreads 25 # 服务器保持的最小空闲线程数。 
    MaxSpareThreads 75 # 服务器保持的最大空闲线程数。 
    ThreadsPerChild 25 # 每个子进程的产生的线程数。 
    MaxRequestsPerChild 0 # 每个子进程被请求服务多少次后被 kill 掉。0表示不限制，推荐设置为1000。 
</IfModule> 
```

## event

```shell
<IfModule perchild.c> 
    NumServers 5 #服务器启动时启动的子进程数 
    StartThreads 5 #每个子进程启动时启动的线程数 
    MinSpareThreads 5 #内存中的最小空闲线程数 
    MaxSpareThreads 10 #最大空闲线程数 
    MaxThreadsPerChild 2000 #每个线程最多被请求多少次后退出。0不受限制。 
    MaxRequestsPerChild 10000 #每个子进程服务多少次后被重新 fork。0表示不受限制。 
</IfModule> 
```

## 工作模型切换

`prefork` 模式效率比较高，但要比 `worker` 使用内存更大，根据自己的需求选择合适的工作模式，假如要切换工作模式可以通过下面的方法。我们前面提到，工作模式需要编译的时候指定，下面操作生效的前提是编译的时候选择了所有模式 `--enable-mpms-shared=all` ：

```shell
vi /etc/httpd/conf.modules.d/00-mpm.conf

#LoadModule mpm_event_module modules/mod_mpm_event.so
//将注释去掉，或者修改成需要的工作模型
```

## Httpd 安装

安装模式有 2 种，手动离线安装和 yum 安装，由于 httpd 是 C 程序，如果是手动安装的话要先安装 C 对应的环境和 httpd 依赖的一些包。yum 的安装方式相对比较简单。

### yum 安装 Httpd

```shell
yum install httpd.x86_64
```

### Httpd 的主要配置

- `/etc/httpd/conf/httpd.conf`：主配置文件；
- `/etc/httpd/conf.modules.d/*.conf`：模块配置文件；
- `/etc/httpd/conf.d/*.conf`：辅助配置文件；
- `/var/log/httpd/access.log`：访问日志；
- `/var/log/httpd/error_log`：错误日志；
- `/var/www/html/`：用户的 html 项目代码。

### 启动

添加 Httpd 开机启动

```shell
[root@localhost bin]# cp /usr/local/httpd/bin/apachectl /etc/rc.d/init.d/httpd
```

启动 Httpd 服务

```shell
[root@localhost bin]# service httpd start
```

Httpd 启动后默认进入的是欢迎界面，我们的 Html 工程可以放在 `/var/www/html`，写个 demo 的 index.html 。

```html
<html>
<head></head>
<body>hello</body>
</html>
```

### Httpd 常用命令

- **httpd -v**：查看 httpd 的版本号；
- **httpd -l**：查看编译进 httpd 程序的静态模块；
- **httpd -M**：查看已经编译进 httpd 程序的静态模块和已经加载的动态模块。

## 小结

Httpd 是上面几种服务器诞生最早的一个，所以它的代码经过长时间的修改和生产实际相对来说成熟很多，功能也很丰富，有强大的 `rewrite` 机制，模块化按需加载，连工作模式都可以根据自己的需要在编译的时候指定，但是因为灵活性比较高，初学者反而不容易掌握。