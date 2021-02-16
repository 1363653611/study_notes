
---
title: RabbitMQ 使用教程
date: 2021-02-11 11:14:10
tags:
  - mq
categories:
  - mq
topdeclare: true
reward: true
---
# rabbitmq 使用教程

# 安装

略

# 管理界面

- 地址：http://localhost:15672/
- 用户名/密码：guest/guest
- 管理界面

![image-20201024221945951](MQ_04rabbitmq使用教程/image-20201024221945951.png)

<!--more-->

## 管理界面功能

- 手动创建虚拟host
- 创建用户
- 分配权限
- 创建交换机
- 创建队列
- 等等...

其他：

- 查看队列消息
- 消费效率
- 推送效率
- 。。。

# 发送方回调机制

在创建 `RabbitTemplate` bean 时，我们用到了两个callBack 方法：

```java
 @Bean
public RabbitTemplate createRabbitTemplate(ConnectionFactory connectionFactory){
    RabbitTemplate rabbitTemplate = new RabbitTemplate();
    rabbitTemplate.setConnectionFactory(connectionFactory);
    //设置开启Mandatory,才能触发回调函数,无论消息推送结果怎么样都强制调用回调函数
    rabbitTemplate.setMandatory(true);

    rabbitTemplate.setConfirmCallback(new RabbitTemplate.ConfirmCallback() {
        @Override
        public void confirm(CorrelationData correlationData, boolean ack, String cause) {
            System.out.println("ConfirmCallback:     "+"相关数据："+correlationData);
            System.out.println("ConfirmCallback:     "+"确认情况："+ack);
            System.out.println("ConfirmCallback:     "+"原因："+cause);
        }
    });

    rabbitTemplate.setReturnCallback(new RabbitTemplate.ReturnCallback() {
        @Override
        public void returnedMessage(Message message, int replyCode, String replyText, String exchange, String routingKey) {
            System.out.println("ReturnCallback:     "+"消息："+message);
            System.out.println("ReturnCallback:     "+"回应码："+replyCode);
            System.out.println("ReturnCallback:     "+"回应信息："+replyText);
            System.out.println("ReturnCallback:     "+"交换机："+exchange);
            System.out.println("ReturnCallback:     "+"路由键："+routingKey);
        }
    });

    return rabbitTemplate;
}
```

一个叫 ConfirmCallback ，一个叫 RetrunCallback；

## 这两种回调函数都是在什么情况会触发呢？

- ①消息推送到server，但是在server里找不到交换机 --- `ConfirmCallback 回调函数`
- ②消息推送到server，找到交换机了，但是没找到队列 --- 触发的是 ConfirmCallback和RetrunCallback两个回调函数。
- ③消息推送到sever，交换机和队列啥都没找到 -----触发的是 ConfirmCallback 回调函数。
- ④消息推送成功 --- 触发的是 ConfirmCallback 回调函数。



# 消费者接收到消息的消息确认机制

和生产者的消息确认机制不同，因为消息接收本来就是在监听消息，符合条件的消息就会消费下来。

## 自动确认

 这也是默认的消息确认情况。 `AcknowledgeMode.NONE`

RabbitMQ成功将消息发出（即将消息成功写入TCP Socket）中立即认为本次投递已经被正确处理，不管消费者端是否成功处理本次投递。

所以这种情况如果消费端消费逻辑抛出异常，也就是消费端没有处理成功这条消息，那么就相当于丢失了消息。
一般这种情况我们都是使用try catch捕捉异常后，打印日志用于追踪数据，这样找出对应数据再做后续处理。

## 根据情况确认

略

## 手动确认

我们配置接收消息确认机制时，多数选择的模式。

消费者收到消息后，手动调用 `basic.ack/basic.nack/basic.reject`后，RabbitMQ收到这些消息后，才认为本次投递成功。

> basic.ack用于肯定确认 
> basic.nack用于否定确认（注意：这是AMQP 0-9-1的RabbitMQ扩展） 
> basic.reject用于否定确认，但与basic.nack相比有一个限制:一次只能拒绝单条消息 

消费者端以上的3个方法都表示消息已经被正确投递，但是basic.ack表示消息已经被正确处理。
而basic.nack,basic.reject表示没有被正确处理：

### reject

*reject，* 经常用于重入队列的场景。

 `channel.basicReject(deliveryTag, true); ` 拒绝消费当前消息.

- 如果第二参数传入true，就是将数据重新丢回队列里，那么下次还会消费这消息。

- 设置false，就是告诉服务器，我已经知道这条消息数据了，因为一些原因拒绝它，而且服务器也把这个消息丢掉就行。 下次不想再消费这条消息了。

- 使用拒绝后重新入列这个确认模式要谨慎，因为一般都是出现异常的时候，catch异常再拒绝入列，选择是否重入列。

  

  *但是如果使用不当会导致一些每次都被你重入列的消息一直消费-入列-消费-入列这样循环，会导致消息积压。*

### nack

nack，相当于设置不消费某条消息。

`channel.basicNack(deliveryTag, false, true);`

- 第一个参数依然是当前消息到的数据的唯一id;
- 第二个参数是指是否针对多条消息；如果是true，也就是说一次性针对当前通道的消息的tagID小于当前这条消息的，都拒绝确认。
- 第三个参数是指是否重新入列，也就是指不确认的消息是否重新丢回到队列里面去。

*同样使用不确认后重新入列这个确认模式要谨慎，因为这里也可能因为考虑不周出现消息一直被重新丢回去的情况，导致积压。*



## 消息手动确认实例

新建MessageListenerConfig.java上添加代码相关的配置代码：

```java
 
import com.elegant.rabbitmqconsumer.receiver.MyAckReceiver;
import org.springframework.amqp.core.AcknowledgeMode;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.rabbit.connection.CachingConnectionFactory;
import org.springframework.amqp.rabbit.listener.SimpleMessageListenerContainer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class MessageListenerConfig {
 
    @Autowired
    private CachingConnectionFactory connectionFactory;
    @Autowired
    private MyAckReceiver myAckReceiver;//消息接收处理类
 
    @Bean
    public SimpleMessageListenerContainer simpleMessageListenerContainer() {
        SimpleMessageListenerContainer container = new SimpleMessageListenerContainer(connectionFactory);
        container.setConcurrentConsumers(1);
        container.setMaxConcurrentConsumers(1);
        container.setAcknowledgeMode(AcknowledgeMode.MANUAL); // RabbitMQ默认是自动确认，这里改为手动确认消息
        //设置一个队列
        container.setQueueNames("TestDirectQueue");
        //如果同时设置多个如下： 前提是队列都是必须已经创建存在的
        //  container.setQueueNames("TestDirectQueue","TestDirectQueue2","TestDirectQueue3");
 
 
        //另一种设置队列的方法,如果使用这种情况,那么要设置多个,就使用addQueues
        //container.setQueues(new Queue("TestDirectQueue",true));
        //container.addQueues(new Queue("TestDirectQueue2",true));
        //container.addQueues(new Queue("TestDirectQueue3",true));
        container.setMessageListener(myAckReceiver);
 
        return container;
    }
 
 
}
```

对应的手动确认消息监听类，MyAckReceiver.java（手动确认模式需要实现 ChannelAwareMessageListener）

```java
import com.rabbitmq.client.Channel;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.rabbit.listener.api.ChannelAwareMessageListener;
import org.springframework.stereotype.Component;
import java.util.HashMap;
import java.util.Map;
@Component 
public class MyAckReceiver implements ChannelAwareMessageListener {
 
    @Override
    public void onMessage(Message message, Channel channel) throws Exception {
        long deliveryTag = message.getMessageProperties().getDeliveryTag();
        try {
            //因为传递消息的时候用的map传递,所以将Map从Message内取出需要做些处理
            String msg = message.toString();
            String[] msgArray = msg.split("'");//可以点进Message里面看源码,单引号直接的数据就是我们的map消息数据
            Map<String, String> msgMap = mapStringToMap(msgArray[1].trim(),3);
            String messageId=msgMap.get("messageId");
            String messageData=msgMap.get("messageData");
            String createTime=msgMap.get("createTime");
            System.out.println("  MyAckReceiver  messageId:"+messageId+"  messageData:"+messageData+"  createTime:"+createTime);
            System.out.println("消费的主题消息来自："+message.getMessageProperties().getConsumerQueue());
            channel.basicAck(deliveryTag, true); //第二个参数，手动确认可以被批处理，当该参数为 true 时，则可以一次性确认 delivery_tag 小于等于传入值的所有消息
//			channel.basicReject(deliveryTag, true);//第二个参数，true会重新放回队列，所以需要自己根据业务逻辑判断什么时候使用拒绝
        } catch (Exception e) {
            channel.basicReject(deliveryTag, false);
            e.printStackTrace();
        }
    }
 
     //{key=value,key=value,key=value} 格式转换成map
    private Map<String, String> mapStringToMap(String str,int entryNum ) {
        str = str.substring(1, str.length() - 1);
        String[] strs = str.split(",",entryNum);
        Map<String, String> map = new HashMap<String, String>();
        for (String string : strs) {
            String key = string.split("=")[0].trim();
            String value = string.split("=")[1];
            map.put(key, value);
        }
        return map;
    }
}
```

这时，先调用接口/sendDirectMessage， 给直连交换机xxxDirectExchange 的队列xxxDirectQueue 推送一条消息，



# 参考

- https://www.jianshu.com/p/382d6f609697
- https://blog.csdn.net/qq_35387940/article/details/100514134
- https://github.com/yanghaiji/javayh-middleware/blob/master/javayh-mq/javayh-rabbitmq/README.md
- 