---
title: 初步了解netty
date: 2021-02-16 13:14:10
tags:
 - netty
categories:
 - netty
topdeclare: true
reward: true
---

# netty 学习

## Netty的特点

- 高并发：Netty 是一款基于 NIO（Nonblocking IO，非阻塞IO）开发的网络通信框架，对比于 BIO（Blocking I/O，阻塞IO），他的并发性能得到了很大提高。
- 传输快：Netty 的传输依赖于零拷贝特性，尽量减少不必要的内存拷贝，实现了更高效率的传输。
- 封装好：Netty 封装了 NIO 操作的很多细节，提供了易于使用调用接口。

## Netty的优势：

- 使用简单：封装了 NIO 的很多细节，使用更简单。
- 功能强大：预置了多种编解码功能，支持多种主流协议。
- 定制能力强：可以通过 ChannelHandler 对通信框架进行灵活地扩展。
- 性能高：通过与其他业界主流的 NIO 框架对比，Netty 的综合性能最优。
- 稳定：Netty 修复了已经发现的所有 NIO 的 bug，让开发人员可以专注于业务本身。
- 社区活跃：Netty 是活跃的开源项目，版本迭代周期短，bug 修复速度快。

## Netty高性能表现在哪些方面？

- IO 线程模型：同步非阻塞，用最少的资源做更多的事。
- 内存零拷贝：尽量减少不必要的内存拷贝，实现了更高效率的传输。
- 内存池设计：申请的内存可以重用，主要指直接内存。内部实现是用一颗二叉查找树管理内存分配情况。
- 串形化处理读写：避免使用锁带来的性能开销。
- 高性能序列化协议：支持 protobuf 等高性能序列化协议。

## Netty能做什么

现在互联网系统讲究的都是高并发、分布式、微服务，各类消息满天飞，Netty在这类架构里面的应用可谓是如鱼得水，如果你对当前的各种应用服务器不爽，那么完全可以基于Netty来实现自己的HTTP服务器，FTP服务器，UDP服务器，RPC服务器，WebSocket服务器，Redis的Proxy服务器，MySQL的Proxy服务器等等。

## 基于Netty 的开源框架有哪些？

- 阿里分布式服务框架 Dubbo 的 RPC 框架；
- 淘宝的消息中间件 RocketMQ；
- Hadoop 的高性能通信和序列化组件 Avro 的 RPC 框架；
- 开源集群运算框架 Spark；
- 分布式计算框架 Storm；
- 并发应用和分布式应用 Akka；
- 。。。。

## Netty的组件

- I/O：各种各样的流（文件、数组、缓冲、管道。。。）的处理（输入输出）。
- Channel：通道，代表一个连接，每个Client请对会对应到具体的一个Channel。
- ChannelPipeline：责任链，每个Channel都有且仅有一个ChannelPipeline与之对应，里面是各种各样的Handler。
- handler：用于处理出入站消息及相应的事件，实现我们自己要的业务逻辑。
- EventLoopGroup：I/O线程池，负责处理Channel对应的I/O事件。
- ServerBootstrap：服务器端启动辅助对象。
- Bootstrap：客户端启动辅助对象。
- ChannelInitializer：Channel初始化器。
- ChannelFuture：代表I/O操作的执行结果，通过事件机制，获取执行结果，通过添加监听器，执行我们想要的操作。
- ByteBuf：字节序列，通过ByteBuf操作基础的字节数组和缓冲区。


# BIO, NIO,AIO 简单说明

这三个概念分别对应三种通讯模型：阻塞、非阻塞、非阻塞异步。

Netty既可以是NIO，也可以是AIO，就看你怎么实现

三者的区别：

### BIO：

一个连接一个线程，客户端有连接请求时服务器端就需要启动一个线程进行处理,线程开销大。伪异步IO：将请求连接放入线程池，一对多，但线程还是很宝贵的资源。

### NIO

一个请求一个线程，但客户端发送的连接请求都会注册到多路复用器上，多路复用器轮询到连接有I/O请求时才启动一个线程进行处理

### AIO

一个有效请求一个线程，客户端的I/O请求都是由OS先完成了再通知服务器应用去启动线程进行处理。

**区别**

- BIO是面向流的，NIO是面向缓冲区的；BIO的各种流是阻塞的。而NIO是非阻塞的；BIO的Stream是单向的，而NIO的channel是双向的。
- NIO的特点：事件驱动模型、单线程处理多任务、非阻塞I/O，I/O读写不再阻塞，而是返回0、基于block的传输比基于流的传输更高效、更高级的IO函数zero-copy、IO多路复用大大提高了Java网络应用的可伸缩性和实用性。基于Reactor线程模型。

# 搭建实例

## 创建 maven 项目，并且引入 Netty 包

![image-20200805163652043](Untitled/image-20200805163652043.png)

## Netty开发的基本流程

### 服务器端和客户端都是这个套路

![image-20200805163826536](Untitled/image-20200805163826536.png)

Netty开发的实际过程，这是一个简化的过程，但已经把大概流程表达出来了，绿色的代表客户端流程、蓝色的代表服务器端流程，注意标红的部分，见下图：

![image-20200805163922687](Untitled/image-20200805163922687.png)

## 创建客户端类

### **创建Handler**

​	首先创建Handler类，该类用于接收服务器端发送的数据，这是一个简化的类，只重写了消息读取方法channelRead0、捕捉异常方法exceptionCaught。

客户端的Handler一般继承的是SimpleChannelInboundHandler，该类有丰富的方法，心跳、超时检测、连接状态等等。

```java
@ChannelHandler.Sharable
public class HandlerClientHello extends SimpleChannelInboundHandler<ByteBuf> {
    @Override
    protected void channelRead0(ChannelHandlerContext channelHandlerContext, ByteBuf byteBuf) throws Exception {
        System.out.println("接收到的消息："+byteBuf.toString(CharsetUtil.UTF_8));
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
        cause.printStackTrace();
        ctx.close();
    }
}
```



__代码说明：__

- @ChannelHandler.Sharable,这个注解是为了线程安全，如果你不在乎是否线程安全，不加也可以。
- SimpleChannelInboundHandler，这里的类型可以是ByteBuf，也可以是String，还可以是对象，根据实际情况来。
- channelRead0，消息读取方法，注意名称中有个0。
- ChannelHandlerContext，通道上下文，代指Channel。
- ByteBuf,字节序列，通过ByteBuf操作基础的字节数组和缓冲区，因为JDK原生操作字节麻烦、效率低，所以Netty对字节的操作进行了封装，实现了指数级的性能提升，同时使用更加便利。
- CharsetUtil.UTF_8，这个是JDK原生的方法，用于指定字节数组转换为字符串时的编码格式。

### **创建客户端启动类**

客户端启动类根据服务器端的IP和端口，建立连接，连接建立后，实现消息的双向传输。

```java
public class AppClientHello {
    private final String host;
    private final int port;

    public AppClientHello(String host, int port) {
        this.host = host;
        this.port = port;
    }

    /**
     * 配置相应的参数，提供连接到远端的方法
     */
    public void run() throws InterruptedException {
        //I/O线程池
        NioEventLoopGroup group = new NioEventLoopGroup();
        //客户端辅助启动类
        try {
            Bootstrap bs = new Bootstrap();
            bs.group(group).channel(NioSocketChannel.class)//实例化一个Channel
                    .remoteAddress(new InetSocketAddress(host,port))
                    .handler(new ChannelInitializer<SocketChannel>() {//进行通道初始化配置
                        @Override
                        protected void initChannel(SocketChannel socketChannel) throws Exception {
                            //添加我们自定义的Handler
                            socketChannel.pipeline().addLast(new HandlerClientHello());
                        }
                    });
            //连接到远程节点；等待连接完成
            ChannelFuture future=bs.connect().sync();
            //发送消息到服务器端，编码格式是utf-8
            future.channel().writeAndFlush(Unpooled.copiedBuffer("Hello World", CharsetUtil.UTF_8));
            //阻塞操作，closeFuture()开启了一个channel的监听器（这期间channel在进行各项工作），直到链路断开
            future.channel().closeFuture().sync();

        } catch (InterruptedException e) {
            e.printStackTrace();
        }finally {
            group.shutdownGracefully().sync();
        }
    }

    public static void main(String[] args) throws InterruptedException {
        new AppClientHello("127.0.0.1",18080).run();
    }
}

```

代码说明：

- ChannelInitializer，通道Channel的初始化工作，如加入多个handler，都在这里进行。
- bs.connect().sync()，这里的sync()表示采用的同步方法，这样连接建立成功后，才继续往下执行。
- pipeline()，连接建立后，都会自动创建一个管道pipeline，这个管道也被称为责任链，保证顺序执行，同时又可以灵活的配置各类Handler，这是一个很精妙的设计，既减少了线程切换带来的资源开销、避免好多麻烦事，同时性能又得到了极大增强。

## 创建服务器端类

### 创建Handler

和客户端一样，只重写了消息读取方法channelRead(注意这里不是channelRead0)、捕捉异常方法exceptionCaught。

另外服务器端Handler继承的是ChannelInboundHandlerAdapter，而不是SimpleChannelInboundHandler，至于这两者的区别，这里不赘述，大家自行百度吧。

```java
@ChannelHandler.Sharable
public class HandlerServerHello extends ChannelInboundHandlerAdapter {
    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg)  throws Exception {
        //处理收到的数据，并反馈消息到到客户端
        ByteBuf in = (ByteBuf) msg;
        System.out.println("收到客户端发过来的消息: " + in.toString(CharsetUtil.UTF_8));

        //写入并发送信息到远端（客户端）
        ctx.writeAndFlush(Unpooled.copiedBuffer("你好，我是服务端，我已经收到你发送的消息", CharsetUtil.UTF_8));
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        //出现异常的时候执行的动作（打印并关闭通道）
        cause.printStackTrace();
        ctx.close();
    }
}

```

### 创建服务器端启动类

```java
public class AppServerHello {
    private int port;

    public AppServerHello(int port) {
        this.port = port;
    }

    public void run() throws Exception {
        EventLoopGroup group = new NioEventLoopGroup();//Netty的Reactor线程池，初始化了一个NioEventLoop数组，用来处理I/O操作,如接受新的连接和读/写数据
        try {
            ServerBootstrap b = new ServerBootstrap();//用于启动NIO服务
            b.group(group)
                    .channel(NioServerSocketChannel.class) //通过工厂方法设计模式实例化一个channel
                    .localAddress(new InetSocketAddress(port))//设置监听端口
                    .childHandler(new ChannelInitializer<SocketChannel>() {
                        //ChannelInitializer是一个特殊的处理类，他的目的是帮助使用者配置一个新的Channel,用于把许多自定义的处理类增加到pipline上来
                        @Override
                        public void initChannel(SocketChannel ch) throws Exception {//ChannelInitializer 是一个特殊的处理类，他的目的是帮助使用者配置一个新的 Channel。
                            ch.pipeline().addLast(new HandlerServerHello());//配置childHandler来通知一个关于消息处理的InfoServerHandler实例
                        }
                    });

            //绑定服务器，该实例将提供有关IO操作的结果或状态的信息
            ChannelFuture channelFuture= b.bind().sync();
            System.out.println("在" + channelFuture.channel().localAddress()+"上开启监听");

            //阻塞操作，closeFuture()开启了一个channel的监听器（这期间channel在进行各项工作），直到链路断开
            channelFuture.channel().closeFuture().sync();
        } finally {
            group.shutdownGracefully().sync();//关闭EventLoopGroup并释放所有资源，包括所有创建的线程
        }
    }

    public static void main(String[] args)  throws Exception {
        new AppServerHello(18080).run();
    }

}
```



代码说明：

- EventLoopGroup，实际项目中，这里创建两个EventLoopGroup的实例，一个负责接收客户端的连接，另一个负责处理消息I/O，这里为了简单展示流程，让一个实例把这两方面的活都干了。
- NioServerSocketChannel，通过工厂通过工厂方法设计模式实例化一个channel，这个在大家还没有能够熟练使用Netty进行项目开发的情况下，不用去深究。

到这里，我们就把服务器端和客户端都写完了 ，如何运行呢，先在服务器端启动类上右键，点Run 'AppServerHello.main()'菜单运行。

# 参考

https://mp.weixin.qq.com/s/rmR0VZ5D7AbfZQoSN9G5Cg