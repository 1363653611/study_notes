---
title: RMI
date: 2021-02-19 12:14:10
tags:
  - WEB
  - socket
categories:
  - WEB
  - socket
topdeclare: true
reward: true
---

# RMI 远程过程调用

- Java的RMI远程调用是指，一个JVM中的代码可以通过网络实现远程调用另一个JVM的某个方法。
- RMI是Remote Method Invocation的缩写。
- 要实现RMI，服务器和客户端必须共享同一个接口
- Java的RMI规定此接口必须派生自`java.rmi.Remote`，并在每个方法声明抛出`RemoteException`。

## 实现

- 编写 接口

```java
/**
 *  世界时钟
 *  <br/>
 *  @author zbcn8
 *  @since  2020/9/30 15:05
 */
public interface WorldClock extends Remote {

    LocalDateTime getLocalDateTime(String zoneId) throws RemoteException;
}
```

- 编写实现类

```java
/**
 *  世界时钟
 *  <br/>
 *  @author zbcn8
 *  @since  2020/9/30 15:11
 */
public class WorldClockService implements WorldClock {
    @Override
    public LocalDateTime getLocalDateTime(String zoneId) throws RemoteException {
        return LocalDateTime.now(ZoneId.of(zoneId)).withNano(0);
    }
}
```

- 编写服务提供方

服务器端的服务相关代码就编写完毕。我们需要通过Java RMI提供的一系列底层支持接口，把上面编写的服务以RMI的形式暴露在网络上，客户端才能调用：

```java
/**
 * rmi 服务提供者
 */
public class RmiServer {

    public static void main(String[] args) {
        System.out.println("create World clock remote service...");
        // 实例化一个WorldClock:
        WorldClock worldClock = new WorldClockService();
        // 将此服务转换为远程服务接口:
        try {
            WorldClock skeleton = (WorldClock) UnicastRemoteObject.exportObject(worldClock, 0);
            // 将RMI服务注册到1099端口:
            Registry registry = LocateRegistry.createRegistry(1099);
            // 注册此服务，服务名为"WorldClock":
            registry.rebind("WorldClock", skeleton);
        } catch (RemoteException e) {
            e.printStackTrace();
        }
    }
}
```

上述代码主要目的是通过RMI提供的相关类，将我们自己的`WorldClock`实例注册到RMI服务上。RMI的默认端口是`1099`，最后一步注册服务时通过`rebind()`指定服务名称为`"WorldClock"`。

- 客户端

RMI要求服务器和客户端共享同一个接口，因此我们要把`WorldClock.java`这个接口文件复制到客户端，然后在客户端实现RMI调用：

```java
/**
 *  rmi 客户端: 使用时,需要将 接口和 客户端复制到 对应的项目.例如 demos 项目下的 com.zbcn.socket.rmi.RmiClient
 *  <br/>
 *  @author zbcn8
 *  @since  2020/9/30 15:19
 */
public class RmiClient {

    public static void main(String[] args) {
        try {
            // 连接到服务器localhost，端口1099:
            Registry registry = LocateRegistry.getRegistry("localhost", 1099);
            // 查找名称为"WorldClock"的服务并强制转型为WorldClock接口:
            WorldClock worldClock = (WorldClock) registry.lookup("WorldClock");
            // 正常调用接口方法:
            LocalDateTime now = worldClock.getLocalDateTime("Asia/Shanghai");
            // 打印调用结果:
            System.out.println(now);
        } catch (RemoteException e) {
            e.printStackTrace();
        } catch (NotBoundException e) {
            e.printStackTrace();
        }
    }
}
```

- 先运行服务器，再运行客户端。从运行结果可知，因为客户端只有接口，并没有实现类，因此，客户端获得的接口方法返回值实际上是通过网络从服务器端获取的。

- 整个过程实际上非常简单，对客户端来说，客户端持有的`WorldClock`接口实际上对应了一个“实现类”，它是由`Registry`内部动态生成的，并负责把方法调用通过网络传递到服务器端。

- 服务器端接收网络调用的服务并不是我们自己编写的`WorldClockService`，而是`Registry`自动生成的代码。我们把客户端的“实现类”称为`stub`，而服务器端的网络服务类称为`skeleton`，它会真正调用服务器端的`WorldClockService`，获取结果，然后把结果通过网络传递给客户端。

- 整个过程由RMI底层负责实现序列化和反序列化：

  ![image-20200930152340592](socket_05RMI/image-20200930152340592.png)

Java的RMI严重依赖序列化和反序列化，而这种情况下可能会造成严重的安全漏洞，因为Java的序列化和反序列化不但涉及到数据，还涉及到二进制的字节码，即使使用白名单机制也很难保证100%排除恶意构造的字节码。因此，使用RMI时，双方必须是内网互相信任的机器，不要把1099端口暴露在公网上作为对外服务.

此外，Java的RMI调用机制决定了双方必须是Java程序，其他语言很难调用Java的RMI。如果要使用不同语言进行RPC调用，可以选择更通用的协议，例如[gRPC](https://grpc.io/)。

# 总结

- Java提供了RMI实现远程方法调用;
- RMI通过自动生成stub和skeleton实现网络调用，客户端只需要查找服务并获得接口实例，服务器端只需要编写实现类并注册为服务；
- RMI的序列化和反序列化可能会造成安全漏洞，因此调用双方必须是内网互相信任的机器，不要把1099端口暴露在公网上作为对外服务。