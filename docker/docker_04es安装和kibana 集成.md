# elasticsearch 安装

## 拉去镜像 

- docker pull elasticsearch

### 查看版本

```shell
docker image inspect nginx:latest | grep -i version
```

发现是 latest 版本是5.6 的，所以指定版本拉去`docker pull elasticsearch:7.6.2`



## docker 单机版启动

### 制作配置文件

```shell
http.host: 0.0.0.0
# Uncomment the following lines for a production cluster deployment
#transport.host: 0.0.0.0
#discovery.zen.minimum_master_nodes: 1
# 跨域配置
http.cors.enabled: true
http.cors.allow-origin: "*
```

### 启动命令

```shell
docker run -d --name zbcn-es -p 9200:9200 -p 9300:9300 -v /home/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /home/elasticsearch/data:/usr/share/elasticsearch/data -e "discovery.type=single-node" -e "ES_JAVA_OPTS=-Xms64m -Xmx256m" elasticsearch:7.6.2
```

## 启动异常

```shell
# 错误截取信息
"stacktrace": ["org.elasticsearch.bootstrap.StartupException: ElasticsearchException[failed to bind service]; nested: AccessDeniedException[/usr/share/elasticsearch/data/nodes];",
# 原因是 elasticsearch/data 文件夹的权限不够导致
# 解决方案(赋值最高权限)
chmod -777 /elasticsearch/data
```



## 查看ElasticSearch内部信息

```shell
docker inspect zbcn-es 
```



## docker 集群模式启动

### 制作配置文件

- 配置文件位置`/usr/share/elasticsearch/data`

- Master 节点

```yml
http.host: 0.0.0.0
#集群名称 所有节点要相同
cluster.name: "estest"
#本节点名称
node.name: master
#作为master节点
node.master: true
#是否存储数据
node.data: true
bootstrap.system_call_filter: false
transport.host: 0.0.0.0  
discovery.zen.minimum_master_nodes: 1
```

- slave 节点

```yml
http.host: 0.0.0.0
#集群名称 所有节点要相同 
cluster.name: "estest"
#子节点名称
node.name: salve1
#不作为master节点
node.master: false
node.data: true
bootstrap.system_call_filter: false
transport.host: 0.0.0.0  
discovery.zen.minimum_master_nodes: 1  
# 注意salve节点的discovery.zen.ping.unicast.hosts设置为esmaster:9300,这里的esmaster是master节点的docker容器名字
discovery.zen.ping.unicast.hosts: ["esmaster:9300"]
```



### master 启动容器

```shell
docker run -d --name esmaster --ulimit nofile=65536:131072 -p 9200:9200 -p 9300:9300 -v /home/docker/elasticsearch/elasticsearchmaster.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /home/elasticsearch/data/master:/usr/share/elasticsearch/data -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" elasticsearch
```



```shell
--name es # 容器名称
# 避免容器启动时会报bootstrap checks failed异常
--ulimit nofile=65536:131072
# 端口映射：暴露出容器的9200,9300端口到宿主机的9200,9300端口
-p 9200:9200 -p 9300:9300

# 挂载卷到容器中，其实就是设置容器配置文件关联上面写好的配置文件，容器存储数据关联到宿主机的外部文件中
-v /home/docker/elasticsearch/elasticsearchmaster.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /home/elasticsearch/data/master:/usr/share/elasticsearch/data

# 设置容器内Java虚拟机的内存大小
-e "ES_JAVA_OPTS=-Xms512m -Xmx512m"
# 以上命令也可以写为如下，经测试不会出问题
-e ES_JAVA_OPTS="-Xms512m -Xmx512m"
```

### salve 容器启动

```shell
docker run -d --name essalve1 --ulimit nofile=65536:131072 --link esmaster:esmaster -v C:/work/docker_volume/elasticsearch/elasticsearchsalve1.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v C:/work/docker_volume/elasticsearch/data/salve1:/usr/share/elasticsearch/data -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" elasticsearch
```

- 主要是使用--link esmaster:esmaster指令，来连接master容器，别的和master容器启动参数基本一样。



# elasticsearch 头 ElasticSearch-Head

为什么要安装`ElasticSearch-Head`呢，原因是需要有一个管理界面进行查看`ElasticSearch`相关信息

## 拉去镜像

```shell
docker pull mobz/elasticsearch-head:5
```

## 运行容器

```shell
docker run -d --name es_admin -p 9100:9100 mobz/elasticsearch-head:5
```





# 安装 Kinaba

## 拉去镜像

```shell
docker pull kibana

docker pull kibana:7.6.2
```

## 运行容器

```shell
docker run --name zbcn-kibana -e ELASTICSEARCH_HOSTS=http://服务器地址:9200 -p 5601:5601 -d kibana

docker run --name zbcn-kibana -e ELASTICSEARCH_HOSTS=http://服务器地址:9200 -p 5601:5601 -d kibana:7.6.2
```

## 运行

访问： http://自己的IP地址:5601/app/kibana


#  参考：

- https://www.imooc.com/article/49888?block_id=tuijian_wz
- https://www.cnblogs.com/balloon72/p/13177872.html
- https://blog.csdn.net/luckyxl029/article/details/80066412?utm_medium=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1.pc_relevant_is_cache&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1.pc_relevant_is_cache







