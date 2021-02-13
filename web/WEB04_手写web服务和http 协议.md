---
title: 手写 WEB 服务器和 HTTP 协议
date: 2021-01-22 12:14:10
tags:
  - newwork
categories:
  - newwork
topdeclare: true
reward: true
---

# 手写 WEB 服务器和 HTTP 协议

本节我们将借助 Socket 实现服务的端口监听并根据 Http 协议的请求和响应结构，实现一个简单的 Web 服务器，加深体验 Web 服务和 Http 协议的原理。

# Http服务基本要素

## 监听连接

浏览器每发起一次请求都需要跟服务端建立连接，服务端要时刻监听有没有客户端连接。传输层协议有 TCP/UDP 两种，实现起来并没有强制说用哪一种，下面是官方文档对 Http 连接的说明：

> HTTP communication usually takes place over TCP/IP connections. The default port is TCP 80 .

文档中指明了连接通常用的是 TCP， TCP 不用考虑数据包乱序，丢失这些问题，实现起来更简单，高效。在代码层我们可以用 Socket 来实现我们的 TCP 传输服务。

## 接收数据

Socket 监听连接，在没有连接到来之前一直是阻塞在 `serverSocket.accept();` 有请求过来就可以运行到下面的代码，然后可以根据我们的输入流读取信息，根据 Http 协议拆开获取我们要的请求数据。

## 返回数据

根据业务处理完获得返回实体数据，然后遵从 Http 协议格式构造返回的消息报文。浏览器获得到的数据也会根据 Http 协议进行渲染。

# Http报文格式

Http 协议请求报文的本质就是一堆字符串，只是这堆字符是有格式的，发送方跟接收方都需要按照这个格式来拼接和拆解内容。我们要实现一个 Web 服务，了解这个是最基本的要素。

以下截图的报文是通过 `tcpflow`（一款功能强大的、基于命令行的免费开源工具）在 Linux 系统抓包获取的。

```shell
sudo tcpflow -c port 8080
```

## Request

![image-20201201160355069](WEB04_手写web服务/image-20201201160355069.png)

![image-20201201160437733](WEB04_手写web服务/image-20201201160437733.png)

## Response

一般情况下，服务器收到客户端的请求后，就会有一个 Http 的响应消息，Http 响应也由 4 部分组成，分别是：状态行、响应头、空行 和 响应实体。

![image-20201201160535828](WEB04_手写web服务/image-20201201160535828.png)



# 实现



上面的代码初学者可以自己模仿着写一个，相信对 Http 会有很深刻的体验。代码中主要是监听连接，客户端连接后，根据 Http 协议进行字符串的拼接返回给客户端，客户端浏览器接收到是标准的 Http 格式就会进行渲染。

```java
ublic class MyTomcat {

    public static void main(String[] args) {
        MyTomcat myTomcat = new MyTomcat();
        myTomcat.start();
    }

    /**
     * 开启一个socket 服务
     */
    private void start(){
        try {
            //开启一个 Socket 服务端，并监听 8090 端口
            ServerSocket serverSocket = new ServerSocket(8090);
            do{
                //阻塞，直到有客户端连接上，才会执行后面的逻辑
                Socket accept = serverSocket.accept();
                accept.setSoTimeout(1000);
                accept.setKeepAlive(false);
                //处理数据
                handle(accept);
                accept.close();
            }while (true);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * http response
     *  第一行 协议 返回状态
     *  第二行 媒体类型 josn/html
     *  第三行 空
     *  内容
     * @param accept
     */
    private void handle(Socket accept) {

        //拼接返回的 request 报文
        StringBuilder responseBuilder = new StringBuilder();
        responseBuilder
                //返回 200 状态码，表示请求成功
                .append("HTTP/1.1 200 OK \r\n")
                //告诉请求的客户端，返回的内容是 text/html 格式的
                .append("Content-Type: text/html; charset=UTF-8 \r\n")
                .append("Cache-Control: no-cache \r\n")
                .append("Connection: close \r\n")
                //首部字段和消息实体中间的空行
                .append("\r\n")
                //内容部分
                .append("hello tomcat");
        try (
                //取得对方socket的输入流并对其操作封装为对象流，但如果对方socket不先输出的话
                //是无法取得该输入流的，这样会一直处理阻塞状态，界面会卡住
                //获取客户端通道的输入流
                InputStream inputStream = accept.getInputStream();
                //获取客户端通道的输出流
                OutputStream outputStream = accept.getOutputStream()
                ){
//            List<String> list = IOUtils.readLines(inputStream, "utf-8");
//            for (String s : list) {
//                System.out.println("请求内容： "+s);
//            }
            /**
             * 值得注意的是，如果接受的网页数据量很大，先把这些数据全部保存在
             * ByteArrayOutputStream的缓存中不是明智的做法，因为这些数据
             * 会占用大量的内存。更有效的方法是利用scanner来读取网页数据：
             */
//            Scanner scannerSocket=new Scanner(inputStream);
//            String data;
//            while (scannerSocket.hasNextLine()){
//                data=scannerSocket.nextLine();
//                System.out.println(data);
//            }
            // //往输出流通道写消息
            outputStream.write(responseBuilder.toString().getBytes());
            //流是有缓存机制的，写消息的时候不一定立马发出去，刷一下才能保证数据发送出去
            outputStream.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

### 说明： 

当读入输入流的数据时，对导致卡死： `at java.net.SocketInputStream.socketRead0(Native Method)` 一直卡住。网上说是JDK1.8.0XX 版本的bug 。待验证。

# 小结

这边的代码虽然很简单，但是最核心的 Http 服务雏形已经展示出来了，成熟的 Http 服务可以在这基础上对以下模块进行优化：

- 针对请求事件的 线程 / IO 优化；
- Servlet 协议支持；
- 配置独立管理；
- Http协议内容完善（比如缓存机制）；
- 支持虚拟主机配置；
- 支持代理；
- rewrite 机制；
- 安全认证。