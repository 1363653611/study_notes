# 统一资源标志符-URI

URI，统一资源标志符(Uniform Resource Identifier， URI)，标识了网络中的某个对象或者集合。它可以是 Web 系统中的某个图片地址，也可以是某个人的邮箱地址。下面我们将详细了解 URI 的定义，格式，以及 URI 和 URL 的区别。

# URI 定义

## 什么是RFC

RFC 是一个文档，这个文档有点大也足够权威，以至于有人称它是互联网界的圣经。里面收录了互联网开发中的各种协议规范，对 URI 的定义在 `RFC2396` 也有对应的记录。

TIPS:RFC 文件是由 Internet Society（ISOC）赞助发行的，由一个个编号排列起来的文件。

## RFC2396 解读

[RFC2396](https://www.ietf.org/rfc/rfc2396.html) 的规约中对 URI 3 个单词有如下定义：
**Uniformity**

> Uniformity provides several benefits: it allows different types of
> resource identifiers to be used in the same context, even
> when the mechanisms used to access those resources may differ; it allows uniform semantic interpretation of common syntactic conventions across different types of resource identifiers; it allows introduction of new types of resource identifiers without interfering with the way that existing identifiers are used; and, it allows the identifiers to be reused in many different contexts, thus permitting new applications or protocols to leverage a pre-existing, large, and widely-used set of resource identifiers.

有一个统一的格式，这个格式允许我们访问不同类型的资源，即使他们有同样的上下文，并且这个格式是可扩展的，允许后面有新的协议加入。

**Resource**

> A resource can be anything that has identity. Familiar examples include an electronic document, an image, a service (e.g., “today’s weather report for Los Angeles”), and a collection of other resources. Not all resources are network “retrievable”; e.g., human beings, corporations, and bound books in a library can also be considered resources. The resource is the conceptual mapping to an entity or set of entities, not necessarily the entity which corresponds to that mapping at any particular instance in time. Thus, a resource can remain constant even when its content—the entities to which it currently corresponds—changes over time, provided that the conceptual mapping is not changed in the process.

资源是任何可标识的东西，文件图片甚至特定某天的天气等，它是一个或者一组实体的概念映射。

**Identifier**

> An identifier is an object that can act as a reference to something that has identity. In the case of URI, the object is a sequence of characters with a restricted syntax.

表示可标识的对象。也称为标识符。

## 格式

scheme 一般指的是协议，URI 的通用格式并没有太多限制，一般是如下，以 scheme 开头，冒号 “：” 分隔开。

```http
  <scheme>:<scheme-specific-part>
```

虽然 URI 的格式没怎么限制，但是不同 scheme 一般会遵循下面的格式来定义。

```http
<scheme>://<authority><path>?<query>
```

以 scheme = http 加以说明：

```http
http://www.imocc.com:80/index.htm?id=3937
```

Http 的 `<authority>`模块一般不会写在路径上面，即使是 Basic Authorization 也是将用户名密码 `base64（user:passwd）` 写在 head 里面。

下面的例子说明 RUI 的一般用法：

- [ftp://ftp.is.co.za/rfc/rfc1808.txt；](ftp://ftp.is.co.za/rfc/rfc1808.txt；)
- gopher://spinaltap.micro.umn.edu/00/Weather/California/Los%20Angeles；
- http://www.math.uio.no/faq/compression-faq/part1.html；
- mailto:mduerst@ifi.unizh.ch；
- news:comp.infosystems.www.servers.unix；
- telnet://melvyl.ucop.edu/0

# URL

通过前面我们知道 URI 是网络中用于标识某个对象的规约，URI 包含了多个 `<scheme>`，所以 URL 是 **scheme = http** 的 URI。URL 是 URI 的子集，只要是 URL 一定就是 URI ，反过来不成立。

URL 和 URI 只差了一个字母，Location 和 Identifier：
**Location**：定位，着重强调的是位置信息；
**Identifier**：标识，只是一种全局唯一的昵称。

**举例：**

美国是一个国家，它只是一种标识，通过美国这两个字我们无法知道这个国家在哪里。如果这个标识换成了经纬度，那我们就能知道这个经纬度对应的是美国，并且知道美国所处的位置信息。

# 小结

本小节主要学习了 URI 的概念，并且区分出了大家容易误解的 URI 和 URL 的区别。在新版的 Http/2.0 文档中已经将 URL 修改成了 URI，可能也是怕大家混淆，不过在详细地了解清楚后，改不改问题都不大了。