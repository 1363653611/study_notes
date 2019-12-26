---
title: 07 java 中的并发工具类
date: 2019-12-25 18:30:10
tags:
 - concurrency
 - 并发
 - java
categories:
 - java
 - concurrency
topdeclare: true
reward: true
---
- CountDownLatch、CyclicBarrier和Semaphore工具类提供了一种并发流程控制的手段
- Exchanger工具类则提供了在线程间交换数据的一种手段

<!--more-->

### 等待多线程完成的CountDownLatch
> CountDownLatch允许一个或多个线程等待其他线程完成操作。

- CountDownLatch的构造函数接收一个int类型的参数作为计数器，如果你想等待N个点完成，这里就传入N。`staticCountDownLatch c = new CountDownLatch(2);`
- 调用CountDownLatch的countDown方法时，N就会减1
- CountDownLatch的await方法会阻塞当前线程，直到N变成零

```java
public class CountDownLatchTest {
    static CountDownLatch c = new CountDownLatch(2);
    public static void main(String[] args) throws InterruptedException {
        new Thread(new Runnable() {
            @Override
            public void run() {
                System.out.println(1);
                c.countDown();
                System.out.println(2);
                c.countDown();
            }
        }).start();
        c.await();
        System.out.println("3");
    }
}
```

- 注意：
  1. 计数器必须大于等于0，只是等于0时候，计数器就是零，调用await方法时不会阻塞当前线程。
  2. CountDownLatch不可能重新初始化或者修改CountDownLatch对象的内部计数器的值。
  3. 一个线程调用countDown方法happen-before，另外一个线程调用await方法。

### 同步屏障CyclicBarrier
> CyclicBarrier的字面意思是可循环使用（Cyclic）的屏障（Barrier）。它要做的事情是，让一组线程到达一个屏障（也可以叫同步点）时被阻塞，直到最后一个线程到达屏障时，屏障才会开门，所有被屏障拦截的线程才会继续运行。

#### 　CyclicBarrier简介
CyclicBarrier默认的构造方法是CyclicBarrier（int parties），其参数表示屏障拦截的线程数量，每个线程调用await方法告诉CyclicBarrier我已经到达了屏障，然后当前线程被阻塞
```java
public class CyclicBarrierTest {
    static CyclicBarrier c = new CyclicBarrier(2);
    public static void main(String[] args) {
        new Thread(new Runnable() {
            @Override
            public void run() {
            try {
            c.await();
            } catch (Exception e) {
            }
            System.out.println(1);
            }
        }).start();
        try {
          c.await();
        } catch (Exception e) {

        }
        System.out.println(2);
    }
}
```
- CyclicBarrier还提供一个更高级的构造函数CyclicBarrier（int parties，Runnable barrier-Action），用于在线程到达屏障时，优先执行barrierAction，方便处理更复杂的业务场景，
```java
import java.util.concurrent.CyclicBarrier;
public class CyclicBarrierTest2 {
    static CyclicBarrier c = new CyclicBarrier(2, new A());
    public static void main(String[] args) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                  c.await();
                } catch (Exception e) {
                }
                System.out.println(1);
            }
        }).start();
        try {
            c.await();
        } catch (Exception e) {
        }
        System.out.println(2);
  }
  static class A implements Runnable {
    @Override
    public void run() {
      System.out.println(3);
    }
  }
}
```

#### CyclicBarrier的应用场景
> CyclicBarrier可以用于多线程计算数据，最后合并计算结果的场景

#### CyclicBarrier和CountDownLatch的区别
- CountDownLatch的计数器只能使用一次，而CyclicBarrier的计数器可以使用reset()方法重置。所以CyclicBarrier能处理更为复杂的业务场景
- CyclicBarrier还提供其他有用的方法，比如getNumberWaiting方法可以获得Cyclic-Barrier阻塞的线程数量。isBroken()方法用来了解阻塞的线程是否被中断。
```java
importjava.util.concurrent.BrokenBarrierException;
importjava.util.concurrent.CyclicBarrier;
public class CyclicBarrierTest3 {
    static CyclicBarrier c = new CyclicBarrier(2);
    public static void main(String[] args) throws InterruptedException，
    BrokenBarrierException {
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    c.await();
                } catch (Exception e) {
                }
            }
        });
        thread.start();
        thread.interrupt();
        try {
            c.await();
        } catch (Exception e) {
            System.out.println(c.isBroken());
        }
    }
}
```

### 控制并发线程数的Semaphore
> Semaphore（信号量）是用来控制同时访问特定资源的线程数量，它通过协调各个线程，以保证合理的使用公共资源。

### 应用场景
- Semaphore可以用于做流量控制，特别是公用资源有限的应用场景，比如数据库连接。
```java
public class SemaphoreTest {
    private static final int THREAD_COUNT = 30;
    private static ExecutorServicethreadPool = Executors.newFixedThreadPool(THREAD_COUNT);
    private static Semaphore s = new Semaphore(10);
    public static void main(String[] args) {
        for (int i = 0; i< THREAD_COUNT; i++) {
            threadPool.execute(new Runnable() {
                @Override
                public void run() {
                    try {
                        s.acquire();
                    System.out.println("save data");
                        s.release();
                    } catch (InterruptedException e) {
                    }
                }
            });
        }
        threadPool.shutdown();
    }
}
```
> Semaphore的用法也很简单，首先线程使用Semaphore的acquire()方法获取一个许可证，使用完之后调用release()方法归还许可证。还可以用tryAcquire()方法尝试获取许可证。

#### 其他方法
- ·intavailablePermits()：返回此信号量中当前可用的许可证数。
- ·intgetQueueLength()：返回正在等待获取许可证的线程数。
- booleanhasQueuedThreads()：是否有线程正在等待获取许可证。
- ·void reducePermits（int reduction）：减少reduction个许可证，是个protected方法。
- Collection getQueuedThreads()：返回所有等待获取许可证的线程集合，是个protected方法。

### 线程间交换数据的Exchanger
>Exchanger（交换者）是一个用于线程间协作的工具类。Exchanger用于进行线程间的数据交换。它提供一个同步点，在这个同步点，两个线程可以交换彼此的数据。这两个线程通过exchange方法交换数据，如果第一个线程先执行exchange()方法，它会一直等待第二个线程也执行exchange方法，当两个线程都到达同步点时，这两个线程就可以交换数据，将本线程生产出来的数据传递给对方。

#### xchanger的应用场景
- Exchanger可以用于遗传算法：，遗传算法里需要选出两个人作为交配对象，这时候会交换两人的数据，并使用交叉规则得出2个交配结果
- Exchanger也可以用于校对工作：比如我们需要将纸制银行流水通过人工的方式录入成电子银行流水，为了避免错误，采用AB岗两人进行录入，录入到Excel之后，系统需要加载这两个Excel，并对两个Excel数据进行校对，看看是否录入一致
```java
public class ExchangerTest {
    private static final Exchanger<String> exgr = new Exchanger<String>();
    private static ExecutorServicethreadPool = Executors.newFixedThreadPool(2);
    public static void main(String[] args) {
        threadPool.execute(new Runnable() {
            @Override
            public void run() {
                try {
                  String A = "银行流水A";　　　　// A录入银行流水数据
                  exgr.exchange(A);
                } catch (InterruptedException e) {
                }
            }
        });
        threadPool.execute(new Runnable() {
            @Override
            public void run() {
                try {
                    String B = "银行流水B";　　　　// B录入银行流水数据
                    String A = exgr.exchange("B");
                    System.out.println("A和B数据是否一致：" + A.equals(B) + "，A录入的是："
                    + A + "，B录入是：" + B);
                } catch (InterruptedException e) {
                }
            }
        });
        threadPool.shutdown();
    }
}
```
> 如果两个线程有一个没有执行exchange()方法，则会一直等待，如果担心有特殊情况发生，避免一直等待，可以使用exchange（V x，longtimeout，TimeUnit unit）设置最大等待时长
