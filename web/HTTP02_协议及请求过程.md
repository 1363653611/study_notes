# HTTP 协议及其请求过程

TCP/IP 的网络模型有 7 层，Http 协议是位于最上层的应用层。应用层协议的意思是它是服务于我们能体验到的一些电脑软件，QQ/邮箱/浏览器这些。应用层下面还有好几层，他们主要保障的是网络传输中的一些安全性（会话加密），可靠性（字节冗余校验），字符转字节，字节转高低电平实现信号的传输等。

## 调试工具

Http 协议及其请求过程是用于浏览器与后台服务的数据交互的，选择一个浏览器：

1. 打开浏览器；
2. 快捷键按下 F12；
3. 观察底部 network 栏目的网络请求信息

![image-20201201101018915](HTTP02/image-20201201101018915.png)

## 协议内容

Http 规定了会话是由客户端发起，服务端响应。发起和响应的消息格式如下：

### 请求的消息格式

#### 请求头

```http
get https://www.imooc.com/ HTTP/1.1
host:117.121.101.134:443
```

| 关键字                | 说明                               |
| --------------------- | ---------------------------------- |
| get                   | 请求的方法                         |
| https://www.baidu.com | 请求的资源定位，URL                |
| HTTP/1.1              | 告诉后台服务器具体请求的协议版本号 |
| host                  | 远端服务器的地址                   |
| ....                  | 其他                               |

#### 请求体

```http
keyword:http
name:mooc
```

请求体对应的是具体的业务数据，表单提交的字段，查询接口的参数等。

## 解释

上面的两段请求内容跟浏览器的截图不一样，原因是我上面的是 Http 协议标准的定义，浏览器毕竟面向的是用户，对请求的信息有做了解析，更人性化地展示了请求的内容。下面的内容是某个后台服务接收到浏览器请求的具体报文信息，借助 `TCPflow` 这个工具在 Linux 服务器上面监听的。或者简单的 `curl -v http://www.baidu.com/` 也可以看到协议内容。

![image-20201201101744892](HTTP02/image-20201201101744892.png)

## 响应的消息格式

### 响应头部信息

```http
HTTP/1.1 200 OK
Date:Sun, 23 Feb 2020 07:31:24 GMT
Connection: keep-alive
Content-Encoding: gzip
Content-Length: 129
Content-Type: application/json; charset=UTF-8
...
```

返回了请求的状态，200状态码对应的就是成功，还有一些链接状态，内容的编码，长度，媒体类型等。

### 响应正文

```http
{result: 0, data: ["Vue", "Python", "Java", "flutter", "springboot", "docker", "React", "小程序"],…}
data: ["Vue", "Python", "Java", "flutter", "springboot", "docker", "React", "小程序"]
msg: "成功"
result: 0
```

返回了消息的具体信息，这个消息有可能是一串 html 文本，也可能是 json 串，图片，附件都有可能，一般是跟 content-type 对应。

## 小结

在上面的请求内容中，规定了第一个(`get https://www.imooc.com/ HTTP/1.1`)是 `method` 后面是 `url` 接着是 `protocal/version` ，这样的约束就是 http 的协议，服务器收到请求就根据这个规则拆开解析。应用这样的模式，web 的客户端和服务端互相知道了请求的方法，地址，字符编码，参数，响应值等。

