# RESTFUL 开发设计规范

- URI : 是一种资源标识
- URL :  schema = Http 的子标识

Restful 从小的讲是对 URL 格式提出了限制，对接口设计规范的倡导，大的说它是一种通信架构的指导。

# RESTFUL 的诞生

## 作者

Restful 是由 Roy Thomas Fielding 博士在 2000 年所著的博士论文提起的，系统全面地阐述了 REST 的架构风格和设计思想，这位作者同时是 HTTP、URI等 Web 架构标准的主要设计者，因此他提出的 REST 概念得到很多人的关注和响应。

## 背景

Web 网站从最初的静态资源展示，演变成后来的动态网站，到现在大部分的软件都在往云上迁移，之前很多桌面应用现在都尽量地改造成 Web 系统，用户不需要下载安装繁琐的软件，打开浏览器输入地址即可使用。

在这么一个背景下，Web 系统的通信架构变得尤为重要。Roy Thomas Fielding 在论文中提到：“我这篇文章的写作目的，就是想在符合架构原理的前提下，理解和评估以网络为基础的应用软件的架构设计，得到一个功能强、性能好、适宜通信的架构。REST 指的是一组架构约束条件和原则。”

## RESTFUL 的思想内容

Rest（Representational State Transfer），从词面上来解析是 **表述性状态转移**。我们知道 URI 是一种标识，这个标识不管是地址还是昵称，他都只是一个名词（**URL 上面最好不要用动词**）.API 接口是有 **增删改查** 一系列动作，将 URL 与行为状态的结合就是 Restful 的核心思想。一个 API 请求我们既要知道它要操作的是哪个资源，也要知道它要对这个资源进行什么操作。

### API 接口规范

Restful 提倡将接口的行为状态放到了 Http 的头部 method 里. 对同一个资源的不同操作，接口 URL 可能是一样的。行为规约主要有下面几项：

#### GET

查询资源，不会对资源产生变化的都用 GET.

eg: 查询某网站资源

```http
GET http://www.imooc.com/http
```

如果资源查询的过程需要带过滤参数，建议使用 URL 参数的形式：

eg1: 查询慕课网 http 小节中作者是 rj 的文章

```http
GET http://www.imooc.com/http?author=rj
```

eg2: 查询慕课网 http 里面 id = 1 的文章

```http
GET http://www.imooc.com/http/1
```



#### POST

新增某个资源：

```http
POST http://www.imooc.com/http
```

具体的参数放请求体中

```json
{
"title":"restful",
"author":"rj",
"content":"xxxxxx"
}
```



#### PUT

资源的修改：

```http
PUT http://www.imooc.com/http/{articleId}
```

具体参数放在请求体中：

```json
{
"title":"restful",
"author":"rj",
"content":"xxxxxx"
}
```



#### PATCH

```http
PATCH http://www.imooc.com/http/{articleId}
```

`patch` 跟 `put` 都是修改的意思，put 类型的修改请求体中需要包含全量的对象信息，而 patch 只需要带上要修改的某几个对象即可，没有带上的参数就代表不更新，采用原来的值。

具体的参数放请求体中：

```json
{
"title":"aaa"
}
```

#### DELETE

删除资源：

```http
DELETE http://www.imooc.com/http/{articleId}
```

# REST 架构

大部分人认识的 REST 都是一个 API 的定义风格，但它其实定义的是一整个软件的通信架构。不过我觉得不理解这部分问题不大，因为如果要说 Web 的架构，那真的是太丰富了，主要还是要寻找适合自己业务的。本着知识拓展，我们来了解下 REST 对架构都做了哪些约束：

- Client-Server：客户端/服务端 模式的架构；
- Stateless：无状态，服务端不保存客户端信息；
- Cache：客户端可以缓存服务端数据；
- Uniform Interface：统一接口（包含上面讲的 API 约束）；
- Layered System：分层架构，职责明确，方便拓展等；
- Code-on-Demand：客户端从服务器获取需要的代码，在客户端处执行。这个我觉得在边缘计算的场景可以应用，客户端按需从中心拉取代码，实现不同效果的处理计算。比如我要识别天气就拉取天气相关代码，要识别花草就拉取花草的识别算法，就可以无限的赋能（可能将传感器识别的信息上传到云端分析所消耗的带宽比获取一个相应场景的算法来得大），想想还是不错的。

**Tips**：[REST 相应的论文部分](https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#fig_5_9)。

# 小结

Restful 风格一般指的是 API 的设计规范，REST 是由 Roy Thomas Fielding 教授提出来的，该作者同时是 HTTP 协议的重要参与者。REST 的论文中对 Web 系统机构提出了一些指导的理论，这些思想都非常不错，但是我们今天的软件架构正变得越来越复杂，熔断 / 限流 / 链路跟踪 等等，还有很多要考虑的。