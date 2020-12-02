# SOCKET 协议

Socket 是**传输层协议**的具体软件实现，它封装了**协议底层**的复杂实现方法，为开发人员提供了便利的网络连接。Socket 是网络编程的基石，像 Http 的请求，MySQL 数据库的连接等绝大部分的网络连接都是基于 Socket 实现的。

##  传输层协议

传输层有 TCP/UDP 两种连接方式，所以对应的 Socket 也有两种不同实现方式，掌握 Socket 的前提是了解清楚这两种协议。

### TCP 协议

面向连接，且具备顺序控制和重发机制的可靠传输。他的可靠性是在于传输数据前要先建立连接，确保要传输的对方有响应才进行数据的传输。因此 TCP 有个经典的 3 次握手和 4 次挥手。

#### 3 次握手

握手的目的是为了相互确认通信双方的状态都是正常的，没有问题后才会进行正式的通信：

1. **第一次握手**：客户端发送请求连接的消息给服务端，但发出去的消息是否到达并不清楚，要基于第二次握手的反馈；
2. **第二次握手**：服务端返回消息说明客户端的消息收到了，此时它也纠结了，我的反馈信息对方有没有收到，所以得依托第三次得握手；
3. **第三次握手**：客户端反馈第二次握手的消息收到了。至此，通信双发的发送消息和接受消息能力都得到了检验。

#### 4 次挥手

1. **第一次挥手**：客户端（服务端也可以主动断开）向服务端说明想要关闭连接；
2. **第二次挥手**：服务端首先回复第一次的消息已经收到。但是并不是立马关闭，因为此时服务端可能还有数据在传输中；
3. **第三次挥手**：待到数据传输都结束后，服务端向客户端发出消息，告知一切都准备好了，我要断开连接了；
4. **第四次挥手**：客户端收到服务端的断开信息后，给予确认。服务端收到确认后正式关闭。客户端自己也发出关闭信息，因为服务端已经关闭了无法确认，等到一段时间后客户端正式关闭。

### UDP 协议

UDP 是一种不可靠的传输机制，但是它的数据报文比 TCP 小，所以相同数据的传输 UDP 所需的带宽更少，传输速度更快。它不要事先建立连接，知道对方的地址后直接数据包就扔过去，也不保证对方有没有收到。

## 连接方式

我们知道 TCP 数据发送前要建立连接，UDP 不需要，而 Socket 的连接又有如下区分：

### 长连接

1. 两个节点建立连接并保持不断开的状态；
2. 两边双向自由的进行数据传输；
3. 直到数据全部交互结束才断开。

### 短连接

1. 节点 A 向节点 B 建立连接；
2. A 发送数据给 B；
3. 一条数据发送完立马断开。

### 适用场景

- 连接的建立需要开销，频繁的重建连接容易造成资源浪费，**长连接适合客户端和服务端都比较明确且传输数据比较大的情况**；
- 每台服务器的连接数都是有限制的，如果太多的长连接阻塞会影响到新连接的建立。Http 是一种短连接的方式，这样有利于他处理高并发的请求。有一种 `slowHttp` 的攻击，就是利用 Http 协议的特点，故意制造了一个很长的报文，然后每次发送很少量的数据，使请求一直占用最终耗尽服务器的连接。所以 Http 虽然是短连接，但是一般是等到数据传输完成才断开的，我们应该根据具体业务设置 Http 请求的超时时间。

# socket 编程

下面的代码实现了一个 Socket 的服务端服务和一个客户端，服务端在 6000 端口上面监听连接，收到客户端的连接后向客户端发出 `hello` 问候语，客户端打印出服务端发送过来的消息。

## 服务端

```java
public class Server {
    public static void main(String[] args) {
        // 创建一个serverSocket监听本地的6000端口
        try(ServerSocket server = new ServerSocket (6000)) {
            // 当有客户端连接上就建立一个socket通道
            Socket socket = server.accept();
            OutputStream outputStream = socket.getOutputStream();
            // 有客户端连接上来就主动发送问候语
            outputStream.write("hello".getBytes());
            outputStream.flush();
            outputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}


```

## 客户端

```java
public class Client {
    public static void main(String[] args) {
        // 根据{IP}+{port}与服务器建立连接
        try( Socket socket=new Socket("127.0.0.1",6000)){
            BufferedReader bufferedReader=new BufferedReader(new InputStreamReader(socket.getInputStream()));
            // 打印服务端发送的信息
            System.out.println("Client:"+bufferedReader.readLine());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

# websocket

Websocket 是一种升级版的 Http 服务，传统的 Http 服务都是客户端发起，服务端响应，**而 Websocket 支持服务端向客户端主动推送消息**，增强了浏览器的交互场景。Websocket 也是应用层协议，跟 Http 一样具体的实现都要基于 Socket，除此之外并没有什么特殊。

![image-20201201111909701](HTTP04_SOCKET协议/image-20201201111909701.png)

# 小结

几乎所有的软件都需要通信，而几乎所有的通信都是基于 Socket 实现的，Socket 从软件的层面屏蔽了传输层的细节，开发人员可以很方便的使用。Socket 起源于 Unix，而 Unix/Linux 基本哲学之一就是“一切皆文件”，使用的时候就打开，不用就关闭。