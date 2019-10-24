### rpc 和 http 的区别 ###

1. rpc: (Remote Procedure Call): 远程过程调用,
    - rpc 架构:
          - 四个核心组件:
          
               > 1)客户端（Client），服务的调用方
               > 2)服务端（Server），真正的服务提供者
               > 3)客户端存根(Client Stub)，存放服务端的地址消息，再将客户端的请求参数打包成网络消息，然后通过网络远程发送给服务方。
               > 4)服务端存根(Server Stub)，接收客户端发送过来的消息，将消息解包，并调用本地的方法。
          
          - 流行的 rpc 框架
          
                > 1）gRPC是Google最近公布的开源软件，基于最新的HTTP2.0协议，并支持常见的众多编程语言。 
                > 2）Thrift是Facebook的一个开源项目，主要是一个跨语言的服务开发框架。
                > 3）Dubbo是阿里集团开源的一个极为出名的RPC框架，在很多互联网公司和企业应用中广泛使用。
                
2. http:(HyperText Transfer Protocol): 超文本传输协议.
    
    - （1）HTTP接口
    -  (2）restful： 
    
- __本质区别__
    1. rpc 主要工作在tcp 协议之上, http 服务主要工作在http 协议之上.
        
    2. http 协议建立在tcp(传输层) 协议之上,所以,效率 rpc 会更高
        
    
    