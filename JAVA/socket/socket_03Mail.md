---
title: JAVA MAIL
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

# 发送邮件

Email就是电子邮件。

![image-20200930093317925](socket_03Mail/image-20200930093317925.png)

- MUA(邮件软件)：Mail User Agent，意思是给用户服务的邮件代理

- MTA(邮件服务器):Mail Transfer Agent，意思是邮件中转的代理

- MDA(最终到达的邮件服务器):Mail Delivery Agent，意思是邮件到达的代理,电子邮件一旦到达MDA，就不再动了。实际上 电子邮件通常就存储在MDA服务器的硬盘上，然后等收件人通过软件或者登陆浏览器查看邮件。

  

  >  MTA和MDA这样的服务器软件通常是现成的，我们不关心这些服务器内部是如何运行的。要发送邮件，我们关心的是如何编写一个MUA的软件，把邮件发送到MTA上。
  >
  > MUA到MTA发送邮件的协议就是SMTP协议，它是Simple Mail Transport Protocol的缩写，使用标准端口25，也可以使用加密端口465或587。
  >
  > SMTP协议是一个建立在TCP之上的协议，任何程序发送邮件都必须遵守SMTP协议。使用Java程序发送邮件时，我们无需关心SMTP协议的底层原理，只需要使用JavaMail这个标准API就可以直接发送邮件。

## 准备SMTP登录信息

假设我们准备使用自己的邮件地址`me@example.com`给小明发送邮件，已知小明的邮件地址是`xiaoming@somewhere.com`，发送邮件前，我们首先要确定作为MTA的邮件服务器地址和端口号。邮件服务器地址通常是`smtp.example.com`，端口号由邮件服务商确定使用25、465还是587。以下是一些常用邮件服务商的SMTP信息：

- QQ邮箱：SMTP服务器是smtp.qq.com，端口是465/587；
- 163邮箱：SMTP服务器是smtp.163.com，端口是465；
- Gmail邮箱：SMTP服务器是smtp.gmail.com，端口是465/587。

有了SMTP服务器的域名和端口号，我们还需要SMTP服务器的登录信息，通常是使用自己的邮件地址作为用户名，登录口令是用户口令或者一个独立设置的SMTP口令。

## 使用 javaMail 来发送邮件

### 引入 JavaMail 的两个相关依赖

```xml
<dependency>
    <groupId>javax.mail</groupId>
    <artifactId>javax.mail-api</artifactId>
    <version>1.6.2</version>
</dependency>
<dependency>
    <groupId>com.sun.mail</groupId>
    <artifactId>javax.mail</artifactId>
    <version>1.6.2</version>
</dependency>
```

###　我们通过JavaMail API连接到SMTP服务器上

```java
private static Session buildMailSession() {
        Properties props = new Properties();
        props.put("mail.smtp.host", smtp); // SMTP主机名
        props.put("mail.smtp.port", port); // 主机端口号
        props.put("mail.smtp.auth", "true"); // 是否需要用户认证
        props.put("mail.smtp.starttls.enable", "true"); // 启用TLS加密

        Session session = Session.getDefaultInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(userName, pwd);
            }
        });

        // 设置debug模式便于调试:
        session.setDebug(true);
        return session;
    }
```

### 发送邮件

发送邮件时，我们需要构造一个`Message`对象，然后调用`Transport.send(Message)`即可完成发送：

```java
    private static void sendMessage(Session session){
        try {
            MimeMessage message = new MimeMessage(session);
            // 设置发送方地址:
            message.setFrom(new InternetAddress(userName));
            // 设置接收方地址:
            message.setRecipient(Message.RecipientType.TO, new InternetAddress("zbcn810@163.com"));
            // 设置邮件主题:
            message.setSubject("test Mail", "UTF-8");
            // 设置邮件正文:
            message.setText("Hi zbcn...", "UTF-8");
            // 发送:
            Transport.send(message);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
```

绝大多数邮件服务器要求发送方地址和登录用户名必须一致，否则发送将失败。

填入真实的地址，运行上述代码，我们可以在控制台看到JavaMail打印的调试信息：

```shell
# 这是JavaMail打印的调试信息:
DEBUG: setDebug: JavaMail version 1.6.2
DEBUG: getProvider() returning javax.mail.Provider[TRANSPORT,smtp,com.sun.mail.smtp.SMTPTransport,Oracle]
DEBUG SMTP: need username and password for authentication
DEBUG SMTP: protocolConnect returning false, host=smtp.qq.com, user=zbcn8, password=<null>
DEBUG SMTP: useEhlo true, useAuth true
# 尝试连接 smtp.qq.com 服务
DEBUG SMTP: trying to connect to host "smtp.qq.com", port 25, isSSL false
220 newxmesmtplogicsvrszb6.qq.com XMail Esmtp QQ Mail Server.
DEBUG SMTP: connected to host "smtp.qq.com", port: 25
# 发送命令EHLO:
EHLO windows10.microdone.cn
# SMTP服务器响应250:
250-newxmesmtplogicsvrszb6.qq.com
250-PIPELINING
...
# 发送命令STARTTLS:
STARTTLS
# SMTP服务器响应220:
220 Ready to start TLS from 125.35.5.253 to newxmesmtplogicsvrszb6.qq.com.
EHLO windows10.microdone.cn
...
DEBUG SMTP: protocolConnect login, host=smtp.qq.com, user=1363653611@qq.com, password=<non-null>
DEBUG SMTP: Attempt to authenticate using mechanisms: LOGIN PLAIN DIGEST-MD5 NTLM XOAUTH2 
DEBUG SMTP: Using mechanism LOGIN
DEBUG SMTP: AUTH LOGIN command trace suppressed
# 登录成功:
DEBUG SMTP: AUTH LOGIN succeeded
DEBUG SMTP: use8bit false
# 开始发送邮件，设置FROM:
MAIL FROM:<1363653611@qq.com>
250 OK.
# 设置TO:
RCPT TO:<zbcn810@163.com>
250 OK
DEBUG SMTP: Verified Addresses
DEBUG SMTP:   zbcn810@163.com
# 发送邮件数据:
DATA
354 End data with <CR><LF>.<CR><LF>.
# 真正的邮件数据
Date: Wed, 30 Sep 2020 10:03:50 +0800 (CST)
From: 1363653611@qq.com
To: zbcn810@163.com
# 邮件主题是编码后的文本:
Message-ID: <1144748369.0.1601431430697@windows10.microdone.cn>
Subject: test Mail
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hi zbcn...
.
250 OK: queued as.
DEBUG SMTP: message successfully delivered to mail server
# 发送QUIT命令:
QUIT
# 服务器响应221结束TCP连接:
221 Bye.
```

上面的调试信息可以看出，SMTP协议是一个请求-响应协议，客户端总是发送命令，然后等待服务器响应。服务器响应总是以数字开头，后面的信息才是用于调试的文本。这些响应码已经被定义在[SMTP协议](https://www.iana.org/assignments/smtp-enhanced-status-codes/smtp-enhanced-status-codes.txt)中了，查看具体的响应码就可以知道出错原因。

### 发送html 邮件

发送HTML邮件和文本邮件是类似的，只需要把：

```java
message.setText(body, "UTF-8");
```

改为：

```java
message.setText(body, "UTF-8", "html");
```

### 发送附件

要在电子邮件中携带附件，我们就不能直接调用`message.setText()`方法，而是要构造一个`Multipart`对象：

```java
 /**
     * 发送带附件邮件
     * @param session
     */
    private static void sendAnneMessage(Session session){
        try {
            MimeMessage message = new MimeMessage(session);

            Multipart multipart = new MimeMultipart();
            // 添加text:
            BodyPart textpart = new MimeBodyPart();
            textpart.setContent("带附件邮件", "text/html;charset=utf-8");
            multipart.addBodyPart(textpart);
            // 添加image:
            BodyPart imagepart = new MimeBodyPart();
            imagepart.setFileName("lunix目录说明.jpg");
            InputStream input = getFileAsStream("C:\\Users\\zbcn8\\Pictures\\lunix目录说明.jpg");
            imagepart.setDataHandler(new DataHandler(new ByteArrayDataSource(input, "application/octet-stream")));
            multipart.addBodyPart(imagepart);

            // 设置邮件内容为multipart:
            message.setContent(multipart);

            // 设置发送方地址:
            message.setFrom(new InternetAddress(userName));
            // 设置接收方地址:
            message.setRecipient(Message.RecipientType.TO, new InternetAddress("zbcn810@163.com"));
            // 设置邮件主题:
            message.setSubject("Test Anne Mail", "UTF-8");
            // 发送:
            Transport.send(message);
        } catch (MessagingException | IOException e) {
            e.printStackTrace();
        }
    }
```

- 一个`Multipart`对象可以添加若干个`BodyPart`，其中第一个`BodyPart`是文本，即邮件正文，后面的BodyPart是附件。
- `BodyPart`依靠`setContent()`决定添加的内容，
  - 如果添加文本，用`setContent("...", "text/plain;charset=utf-8")`
  - 添加纯文本，或者用`setContent("...", "text/html;charset=utf-8")`添加HTML文本。
  - 添加附件，需要设置文件名（不一定和真实文件名一致），并且添加一个`DataHandler()`，传入文件的MIME类型。二进制文件可以用`application/octet-stream`，Word文档则是`application/msword`。

最后，通过`setContent()`把`Multipart`添加到`Message`中，即可发送。

### 发送内嵌图片的HTML邮件

- HTML邮件中可以内嵌图片，这是怎么做到的？
- 如果给一个`<img src="http://example.com/test.jpg">`，这样的外部图片链接通常会被邮件客户端过滤，并提示用户显示图片并不安全。只有内嵌的图片才能正常在邮件中显示。

- 内嵌图片实际上也是一个附件，即邮件本身也是`Multipart`，但需要做一点额外的处理：

```java
Multipart multipart = new MimeMultipart();
// 添加text:
BodyPart textpart = new MimeBodyPart();
textpart.setContent("<h1>Hello</h1><p><img src=\"cid:img01\"></p>", "text/html;charset=utf-8");
multipart.addBodyPart(textpart);
// 添加image:
BodyPart imagepart = new MimeBodyPart();
imagepart.setFileName(fileName);
imagepart.setDataHandler(new DataHandler(new ByteArrayDataSource(input, "image/jpeg")));
// 与HTML的<img src="cid:img01">关联:
imagepart.setHeader("Content-ID", "<img01>");
multipart.addBodyPart(imagepart);
```

在HTML邮件中引用图片时，需要设定一个ID，用类似`<img src=\"cid:img01\">`引用，然后，在添加图片作为BodyPart时，除了要正确设置MIME类型（根据图片类型使用`image/jpeg`或`image/png`），还需要设置一个Header：

```java
imagepart.setHeader("Content-ID", "<img01>");
```

## 总结

- 使用JavaMail API发送邮件本质上是一个MUA软件通过SMTP协议发送邮件至MTA服务器；
- 打开调试模式可以看到详细的SMTP交互信息；
- 某些邮件服务商需要开启SMTP，并需要独立的SMTP登录密码。

# 接受邮件

- 经过发送给邮件后,邮件最终到达收件人的MDA服务器，所以，接收邮件是收件人用自己的客户端把邮件从MDA服务器上抓取到本地的过程。
- 接收邮件使用最广泛的协议是POP3：Post Office Protocol version 3，它也是一个建立在TCP连接之上的协议.POP3服务器的标准端口是110，如果整个会话需要加密，那么使用加密端口995。
- 另一种接收邮件的协议是IMAP：Internet Mail Access Protocol，它使用标准端口143和加密端口993。
- IMAP和POP3的主要区别是，IMAP协议在本地的所有操作都会自动同步到服务器上，并且，IMAP可以允许用户在邮件服务器的收件箱中创建文件夹。

JavaMail也提供了IMAP协议的支持。因为POP3和IMAP的使用方式非常类似，因此我们只介绍POP3的用法。

## POP3 接受邮件

使用POP3收取Email时，我们无需关心POP3协议底层，因为JavaMail提供了高层接口。首先需要连接到Store对象：

```java
 /**
  * 创建Store ,用来接受和存储邮件
  * @return
  * @throws MessagingException
  */
private static Store buildStore() throws MessagingException {
    Session session = buildSession();
    URLName url = new URLName("pop3", host, port, "", username, password);
    Store store = new POP3SSLStore(session, url);
    store.connect();
    return store;
}

/**
 * 获取连接session
 * @return
 */
public static Session buildSession(){
    Properties props = new Properties();
    props.setProperty("mail.store.protocol", "pop3"); // 协议名称
    props.setProperty("mail.pop3.host", host);// POP3主机名
    props.setProperty("mail.pop3.port", String.valueOf(port)); // 端口号

    // 启动SSL:
    props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
    props.put("mail.smtp.socketFactory.port", String.valueOf(port));
    Session session = Session.getInstance(props, null);
    session.setDebug(true); // 显示调试信息
    return session;
}
```

一个`Store`对象表示整个邮箱的存储，要收取邮件，我们需要通过`Store`访问指定的`Folder`（文件夹），通常是`INBOX`表示收件箱：

#### 获取收件箱

```java
 //创建指定文件夹("INBOX" 表示收件箱)
public static Folder buildFolder(Store store,String type){
    try {
        Folder folder = store.getFolder(type);

        // 以读写方式打开:
        folder.open(Folder.READ_WRITE);
        // 打印邮件总数/新邮件数量/未读数量/已删除数量:
        System.out.println("Total messages: " + folder.getMessageCount());
        System.out.println("New messages: " + folder.getNewMessageCount());
        System.out.println("Unread messages: " + folder.getUnreadMessageCount());
        System.out.println("Deleted messages: " + folder.getDeletedMessageCount());
        return folder;
    } catch (MessagingException e) {
        e.printStackTrace();
    }
    return null;
}
private static void handleMessages(Folder folder) throws MessagingException, UnsupportedEncodingException {
        Message[] messages = folder.getMessages();
        for (Message message : messages) {
            // 打印每一封邮件:
            printMessage((MimeMessage) message);
        }
    }
private static void printMessage(MimeMessage msg) throws MessagingException, UnsupportedEncodingException {
        // 邮件主题:
        System.out.println("Subject: " + MimeUtility.decodeText(msg.getSubject()));
        // 发件人:
        Address[] froms = msg.getFrom();
        InternetAddress address = (InternetAddress) froms[0];
        String personal = address.getPersonal();
        String from = personal == null ? address.getAddress() : (MimeUtility.decodeText(personal) + " <" + address.getAddress() + ">");
        System.out.println("From: " + from);
        // 继续打印收件人:
        Address[] allRecipients = msg.getAllRecipients();
        for (int i = 0; i < allRecipients.length; i++) {
            Address recipient =allRecipients[i];
            System.out.println("Receive"+i + ":"+ recipient);
        }
    }
```

比较麻烦的是获取邮件的正文。一个`MimeMessage`对象也是一个`Part`对象，它可能只包含一个文本，也可能是一个`Multipart`对象，即由几个`Part`构成，因此，需要递归地解析出完整的正文：

```java
private String getBody(Part part) throws MessagingException, IOException {
    if (part.isMimeType("text/*")) {
        // Part是文本:
        return part.getContent().toString();
    }
    if (part.isMimeType("multipart/*")) {
        // Part是一个Multipart对象:
        Multipart multipart = (Multipart) part.getContent();
        // 循环解析每个子Part:
        for (int i = 0; i < multipart.getCount(); i++) {
            BodyPart bodyPart = multipart.getBodyPart(i);
            String body = getBody(bodyPart);
            if (!body.isEmpty()) {
                return body;
            }
        }
    }
    return "";
}
```

最后记得关闭`Folder`和`Store`：

```java
folder.close(true); // 传入true表示删除操作会同步到服务器上（即删除服务器收件箱的邮件）
store.close();
```

## 总结

- 使用Java接收Email时，可以用POP3协议或IMAP协议。
- 使用POP3协议时，需要用Maven引入JavaMail依赖，并确定POP3服务器的域名／端口／是否使用SSL等，然后，调用相关API接收Email。
- 设置debug模式可以查看通信详细内容，便于排查错误。