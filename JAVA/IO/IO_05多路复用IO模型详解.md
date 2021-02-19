---
title: 多路复用IO模型详情
date: 2021-02-19 12:14:10
tags:
  - IO
categories:
  - IO
topdeclare: true
reward: true
---

- I/O是指网络I/O
- 多路指多个TCP连接(即socket或者channel）,复用指复用一个或几个线程。

**NOTE:** **同一个线程内同时处理多个TCP连接**。 最大优势是减少系统开销小，不必创建/维护过多的线程。

IO多路复用模型是建立在内核提供的多路分离函数select基础之上的，使用select函数可以避免同步非阻塞IO模型中轮询等待的问题。

![img](IO_05多路复用IO模型详解/1593096-20190215160424313-590681659.png)

用户首先将需要进行IO操作的socket添加到select中，然后阻塞等待select系统调用返回。当数据到达时，socket被激活，select函数返回。用户线程正式发起read请求，读取数据并继续执行。

从流程上来看，使用select函数进行IO请求和同步阻塞模型没有太大的区别，甚至还多了添加监视socket，以及调用select函数的额外操作，效率更差。

但是，使用select以后最大的优势是用户可以在一个线程内同时处理多个socket的IO请求。

用户可以注册多个socket，然后不断地调用select读取被激活的socket，即可达到在同一个线程内同时处理多个IO请求的目的。而在同步阻塞模型中，必须通过多线程的方式才能达到这个目的。

伪代码：

```java
{

select(socket);
while(1) {//while循环前将socket添加到select监视中
    sockets = select();
    for(socket in sockets) {
        if(can_read(socket)) {//while内一直调用select获取被激活的socket
            read(socket, buffer);//一旦socket可读，便调用read函数将socket中的数据读取出来
            process(buffer);
            }
        }
    }
}
```

用select函数的优点并不仅限于此。虽然上述方式允许单线程内处理多个IO请求，但是每个IO请求的过程还是阻塞的（在select函数上阻塞），平均时间甚至比同步阻塞IO模型还要长。

如果用户线程只注册自己感兴趣的socket或者IO请求，然后去做自己的事情，等到数据到来时再进行处理，则可以提高CPU的利用率。

IO多路复用模型使用了**Reactor(反应堆)**设计模式实现了这一机制。

![img](IO_05多路复用IO模型详解/1593096-20190215160457631-2078886987.png)

- EventHandler抽象类表示IO事件处理器，它拥有IO文件句柄Handle（通过get_handle获取），以及对Handle的操作handle_event（读/写等）
- 继承EventHandler的子类可以对事件处理器的行为进行定制。
- Reactor类用于管理EventHandler（注册、删除等），并使用handle_events实现事件循环，不断调用同步事件多路分离器（一般是内核）的多路分离函数select，只要某个文件句柄被激活（可读/写等），select就返回（阻塞），handle_events就会调用与文件句柄关联的事件处理器的handle_event进行相关操作。

![img](IO_05多路复用IO模型详解/1593096-20190215160540553-1263619538.png)

- 通过Reactor的方式，可以将用户线程轮询IO操作状态的工作统一交给handle_events事件循环进行处理。

- 用户线程注册事件处理器之后可以继续执行做其他的工作（异步），而Reactor线程负责调用内核的select函数检查socket状态。

- 当有socket被激活时，则通知相应的用户线程（或执行用户线程的回调函数），执行handle_event进行数据读取、处理的工作。

  **由于select函数是阻塞的，因此多路IO复用模型也被称为异步阻塞IO模型。**

  **这里的所说的阻塞是指select函数执行时线程被阻塞，而不是指socket。**

一般在使用IO多路复用模型时，socket都是设置为NONBLOCK的，不过这并不会产生影响，因为用户发起IO请求时，数据已经到达了，用户线程一定不会被阻塞。

用户线程使用IO多路复用模型的伪代码描述为

```java
void UserEventHandler::handle_event() {
    if(can_read(socket)) {
        read(socket, buffer);
        process(buffer);
    }
}

{
Reactor.register(new UserEventHandler(socket));
}
```

用户需要重写EventHandler的handle_event函数进行读取数据、处理数据的工作，用户线程只需要将自己的EventHandler注册到Reactor即可。Reactor中handle_events事件循环的伪代码大致如下。

```java
Reactor::handle_events() {
    while(1) {
        sockets = select();
        for(socket in sockets) {
           get_event_handler(socket).handle_event();
        }
    }
}
```

- 事件循环不断地调用select获取被激活的socket，然后根据获取socket对应的EventHandler，执行器handle_event函数即可。
- IO多路复用是最常使用的IO模型，但是其异步程度还不够“彻底”，因为它使用了会阻塞线程的select系统调用。
- 因此IO多路复用只能称为异步阻塞IO，而非真正的异步IO。

