---
title: 基本设置和常用操作 api
date: 2021-02-12 13:33:36
tags:
  - elasticsearch    
categories:
  - elasticsearch
#top: 1
topdeclare: false
reward: true
---

# 基本设置和常用操作 api

```bash
# 指定分词器获取分词结果
POST /_analyze
{
  "analyzer": "ik_smart",
  "text": "铝合金营养不粘微压锅6L" 
}

# 集群的监控状态
GET /_cat/health?v

# 集群的节点
GET /_cat/nodes?v

# 集群的索引
GET /_cat/indices?v

# 创建一个索引
PUT /customer?pretty=true

# 添加一个文档到索引中
PUT /customer/_doc/1?pretty
{
  "name": "John Doe",
  "age":25,
  "genter":"男",
  "country":"中国"
}

# 从指定索引中获取文档
GET /customer/_doc/1?pretty

# 搜索
GET /customer/_search?pretty
{
  "query":{
    "match": {
      "name": {
        "query": "John",
        "operator": "and",
        "boost": 1
      }
    }
     
  },
 
  "_source":["name","age"]
}


# 查询所有文档
GET /customer/_search?q=*&sort=name:DESC&pretty

# 将sql 语句翻译成 DSL 语言
POST /_sql/translate 
{
  "query": "SELECT sum(age) FROM customer group by age"
}

# 查看索引定义
GET /twitter/_mapping?pretty

# 删除索引
DELETE /twitter

# 创建索引
PUT /twitter?pretty
{
  "settings": {
    "number_of_replicas": 3,
    "number_of_shards": 2
  }
}

# 创建索引附带mapping
PUT /twitter?pretty
{
  "settings": {
    "number_of_shards": 3, 
    "number_of_replicas": 2
  },
  "mappings": {
    "properties": {
      "name":{
        "type": "text",
        "index": true
      }
    }
  }
  
}

# 更新索引
PUT /twitter/_settings
{
    "index" : {
        "number_of_replicas" : 2
    }
}

# 查看所有索引
GET _cat/indices

# 查看索引
GET /twitter?pretty

# 查看索引模版
GET /_template/.logstash-management

# 索引监控
GET /_stats

# 查看指定索引

GET /user,twitter/_stats

# 清除缓存
POST /twitter/_cache/clear

# 将缓存在内存中的索引数据刷新到持久存储中
POST /twitter/_flush

# 重新打开读取索引
POST /twitter/_refresh


# 查看索引的段信息
GET /twitter/_segments 

# 查看索引的恢复信息
GET /twitter/_recovery

# 索引的分片存储信息
GET /twitter/_shard_stores


```

<!--more-->

# 数据插入 API

## PUT 指定 id 创建

索引API在特定索引中添加或更新类型化的JSON文档，使其可搜索。以下示例将JSON文档插入ID为1的_doc类型的“ twitter”索引中

```shell
# 添加或者更新一个json 数据通过指定索引(id)
# 插入一个json数据到 twitter 索引下的 _doc 类别下，数据的 _id 为1
PUT twitter/_doc/1
{
    "user" : "kimchy",
    "post_date" : "2009-11-15T14:12:12",
    "message" : "trying out Elasticsearch"
}

# 返回值
{
  "_index" : "twitter",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 2,
  "result" : "updated",
  "_shards" : {
    "total" : 3,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 1,
  "_primary_term" : 1
}

# op_type=create指定操作为创建，如果 当前 id 对应的文档存在，则抛出异常
PUT /twitter/_doc/1?op_type=create
{
    "user" : "kimchy",
    "post_date" : "2009-11-15T14:12:12",
    "message" : "trying out Elasticsearch"
}
# 另外一种指定创建的方法
PUT twitter/_doc/1/_create
{
    "user" : "kimchy",
    "post_date" : "2009-11-15T14:12:12",
    "message" : "trying out Elasticsearch"
}

```

### `_shards` 索引操作的复制过程

- `total` 应对索引操作执行多少个分片副本（主和副本分片）
- `successful` 索引操作成功进行的分片副本数
- `failed` 在副本分片上进行索引操作失败的情况下，包含与复制相关的错误的数组

## 自动创建索引

如果索引操作尚不存在，它会自动创建一个索引，并应用已配置的任何索引模板。索引操作还会为指定的类型创建动态类型映射（如果尚不存在）。默认情况下，如果需要，新字段和对象将自动添加到指定类型的映射定义中。

自动索引的创建由action.auto_create_index设置控制。此设置默认为true，这意味着总是自动创建索引。通过将此设置的值更改为这些模式的逗号分隔列表，可以仅对匹配某些模式的索引自动创建索引。也可以通过在列表中的模式前面加上+或-来明确允许和禁止使用它。最后，可以通过将此设置更改为false来完全禁用它。

```shell
# 仅允许自动创建称为twitter，index10的索引，不允许其他与index1 *匹配的索引，以及与ind *匹配的任何其他索引。模式按照给定的顺序进行匹配。
PUT _cluster/settings
{
    "persistent": {
        "action.auto_create_index": "twitter,index10,-index1*,+ind*" 
    }
}
# 完全禁用索引的自动创建。
PUT _cluster/settings
{
    "persistent": {
        "action.auto_create_index": "false" 
    }
}
# 允许使用任何名称自动创建索引。这是默认值。
PUT _cluster/settings
{
    "persistent": {
        "action.auto_create_index": "true" 
    }
}
```



## POST 自动生成 id 方式创建

无需指定id即可执行索引操作。在这种情况下，将自动生成一个id。此外，op_type将自动设置为create。这是一个示例（请注意使用的是POST而不是PUT）

```shell
POST twitter/_doc/
{
    "user" : "kimchy",
    "post_date" : "2009-11-15T14:12:12",
    "message" : "trying out Elasticsearch"
}

#返回值
{
  "_index" : "twitter",
  "_type" : "_doc",
  "_id" : "VAWaxnYBP-7LnBQtz_TX",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 3,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 2,
  "_primary_term" : 1
}
```

## 乐观并发控制

索引操作可以是有条件的，并且仅在对文档的最后一次修改分配了由if_seq_no和if_primary_term参数指定的序列号和主要术语的情况下才能执行。如果检测到不匹配，则该操作将导致VersionConflictException和状态码409。更多的详见  [*Optimistic concurrency control*](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/optimistic-concurrency-control.html) 



## Routing - 路由

认情况下，分片放置（或路由）是通过使用文档ID值的哈希值来控制的。为了进行更明确的控制，可以使用路由参数在每个操作的基础上直接指定路由使用的哈希函数的值。

```shell
# “ _doc”文档根据提供的路由参数“ kimchy”路由到分片
POST twitter/_doc?routing=kimchy
{
    "user" : "kimchy",
    "post_date" : "2009-11-15T14:12:12",
    "message" : "trying out Elasticsearch"
}
```

设置显式映射时，可以选择使用_routing字段来指示索引操作以从文档本身提取路由值。这样做确实要付出额外的文档解析过程的费用（非常少）。如果定义了_routing映射并将其设置为必需，则如果没有提供或提取路由值，则索引操作将失败。



## Distributed 分散

索引操作基于其路由（请参见上面的“路由”部分）定向到主分片，并在包含该分片的实际节点上执行。在主分片完成操作之后，如果需要，则将更新分发到适用的副本。



### Wait For Active Shards  等待激活分片

为了提高写入系统的弹性,可以将索引操作配置为在继续操作之前等待一定数量的活动分片副本。如果必需数量的活动分片副本不可用，则写操作必须等待并重试，直到必需的分片副本已开始或发生超时为止。

默认情况下，写入操作仅在继续操作之前等待主分片处于活动状态（即，wait_for_active_shards = 1）.通过设置index.write.wait_for_active_shards，可以在索引设置中动态覆盖此默认设置。要更改每个操作的此行为，可以使用wait_for_active_shards请求参数。有效值为所有或任何正整数，直到索引中每个分片的已配置副本总数（即number_of_replicas + 1）。指定负值或大于分片副本数的数字将引发错误。

例如，假设我们有一个由三个节点组成的集群，A，B和C，我们创建索引的索引，副本数设置为3（产生4个分片副本，副本数比节点多一个）.如果我们尝试进行索引操作，则默认情况下，该操作将仅确保每个分片的主副本可用，然后再继续操作。这意味着，即使B和C崩溃了，并且A托管了主要的分片副本，索引操作仍将仅对数据的一个副本进行。如果在请求上将wait_for_active_shards设置为3（并且所有3个节点都启动）,那么索引操作将需要3个活动的分片副本，然后再继续操作，因为集群中有3个活动节点，每个节点都保存着该分片的副本，所以应该满足这一要求。但是，如果将wait_for_active_shards设置为 `all`（或设置为4，和`all`相同），则索引操作将不会继续进行，因为我们在索引中没有每个活动的分片的所有4个副本。除非在群集中调出新节点来托管分片的第四副本，否则该操作将超时。

重要的是要注意，此设置大大减少了写操作未写入所需数量的分片副本的机会，但这并不能完全消除这种可能性，因为此检查发生在写操作开始之前。一旦执行写操作，复制仍然有可能在任何数量的分片副本上失败，但在主副本上仍然可以成功。操作响应的_shards部分显示复制成功/失败的分片副本数。

```json
{
    "_shards" : {
        "total" : 2,
        "failed" : 0,
        "successful" : 2
    }
}
```

## Refresh

控制何时可以看到此请求所做的更改。请参阅 [refresh](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/docs-refresh.html).。

## Noop Update

使用索引API更新文档时，即使文档没有更改，也会始终创建该文档的新版本。如果不可接受，请使用_update API，将detect_noop设置为true。此选项在 index API上不可用，因为索引index API不会获取旧资源，也无法将其与新资源进行比较。

对于何时不可接受更新没有严格的规定。它综合了许多因素，例如您的数据源多久发送一次实际上是noop的更新，以及每秒在接收更新的分片上运行Elasticsearch的查询数量。



## TimeOut

执行索引操作时，分配给执行索引操作的主分片可能不可用。造成这种情况的某些原因可能是主分片当前正在从网关恢复或正在进行重定位。默认情况下，索引操作将等待主分片最多可用1分钟，然后失败并响应错误。timeout参数可用于显式指定等待时间。这是将其设置为5分钟的示例：

```shell
PUT twitter/_doc/1?timeout=5m
{
    "user" : "kimchy",
    "post_date" : "2009-11-15T14:12:12",
    "message" : "trying out Elasticsearch"
}
```

## Versioning

每个索引的文档都有一个版本号。默认情况下，使用内部版本控制，该版本从1开始，并随着每次更新（包括删除）而递增。可以选择将版本号设置为外部值（例如，如果维护在数据库中）。要启用此功能，应将version_type设置为external。要启用此功能，应将version_type设置为external。提供的值必须是大于或等于0且小于9.2e + 18左右的数字长值。

使用外部版本类型时，系统检查以查看传递给索引请求的版本号是否大于当前存储文档的版本。如果为true，将为文档建立索引并使用新的版本号。如果提供的值小于或等于存储的文档的版本号，则将发生版本冲突，并且索引操作将失败。

```shell
PUT twitter/_doc/1?version=2&version_type=external
{
    "message" : "elasticsearch now has versioning support, double cool!"
}
```

注意：版本控制是完全实时的，不受搜索操作几乎实时的影响。如果未提供任何版本，则将执行该操作而不进行任何版本检查。



# Bulk API

批量API使在单个API调用中执行许多 index/delete 操作成为可能。这样可以大大提高索引速度。

REST API端点为/ _bulk。并且期望以下换行符分隔的JSON（NDJSON）结构

```shell
action_and_meta_data\n
optional_source\n
action_and_meta_data\n
optional_source\n
....
action_and_meta_data\n
optional_source\n
```

**NOTE**:

- 数据的最后一行必须以换行符\ n结尾。每个换行符前面都可以有一个回车符\ r。向此端点发送请求时，Content-Type标头应设置为application / x-ndjson。
- 可能的操作是：index、create、delete 和update。
  - index 和 create 的资源期望在下一行，并具有与标准索引API的op_type参数相同的语义（i.e 如果已经存在具有相同索引和类型的文档，则创建将失败，而索引将根据需要添加或替换文档）; 
  - delete在下一行中不需要源，并且具有与标准delete API相同的语义;
  - update 期望在下一行指定部分doc，upsert和脚本及其选项

如果 提供文本文件输入 到 curl。您必须使用--data-binary标志，而不是简单的 `-d`。后者不会保留换行符。

```shell
$ cat requests
{ "index" : { "_index" : "test", "_type" : "_doc", "_id" : "1" } }
{ "field1" : "value1" }


$ curl -s -H "Content-Type: application/x-ndjson" -XPOST localhost:9200/_bulk --data-binary "@requests"; 

echo
{"took":7, "errors": false, "items":[{"index":{"_index":"test","_type":"_doc","_id":"1","_version":1,"result":"created","forced_refresh":false}}]}
```

由于此格式使用文字\ n作为定界符，因此请确保JSON操作和源未正确打印。这是正确的批量命令序列的示例：

```shell
POST _bulk
{ "index" : { "_index" : "test", "_type" : "_doc", "_id" : "1" } }
{ "field1" : "value1" }
{ "delete" : { "_index" : "test", "_type" : "_doc", "_id" : "2" } }
{ "create" : { "_index" : "test", "_type" : "_doc", "_id" : "3" } }
{ "field1" : "value3" }
{ "update" : {"_id" : "1", "_type" : "_doc", "_index" : "test"} }
{ "doc" : {"field2" : "value2"} }
```

bulk 操作的结果：

```json
{
  "took" : 11,
  "errors" : true,
  "items" : [
    {
      "index" : {
        "_index" : "test",
        "_type" : "_doc",
        "_id" : "1",
        "_version" : 9,
        "result" : "updated",
        "_shards" : {
          "total" : 2,
          "successful" : 1,
          "failed" : 0
        },
        "_seq_no" : 12,
        "_primary_term" : 1,
        "status" : 200
      }
    },
    {
      "delete" : {
        "_index" : "test",
        "_type" : "_doc",
        "_id" : "2",
        "_version" : 1,
        "result" : "not_found",
        "_shards" : {
          "total" : 2,
          "successful" : 1,
          "failed" : 0
        },
        "_seq_no" : 13,
        "_primary_term" : 1,
        "status" : 404
      }
    },
    {
      "create" : {
        "_index" : "test",
        "_type" : "_doc",
        "_id" : "3",
        "status" : 409,
        "error" : {
          "type" : "version_conflict_engine_exception",
          "reason" : "[3]: version conflict, document already exists (current version [1])",
          "index_uuid" : "EKbXM364QIy9aIkqiX4MmQ",
          "shard" : "0",
          "index" : "test"
        }
      }
    },
    {
      "update" : {
        "_index" : "test",
        "_type" : "_doc",
        "_id" : "1",
        "_version" : 10,
        "result" : "updated",
        "_shards" : {
          "total" : 2,
          "successful" : 1,
          "failed" : 0
        },
        "_seq_no" : 14,
        "_primary_term" : 1,
        "status" : 200
      }
    }
  ]
}
```

端点是/ _bulk，/ {index} / _ bulk和{index} / {type} / _ bulk。 提供 index 或index/type 后，默认情况下，bulk 项中不会明确的提供他们

- https://www.elastic.co/guide/en/elasticsearch/reference/6.8/docs-bulk.html#docs-bulk

## Versiong

bulk 中每一个 item 可以包括 版本号，通过 version 字段。它基于`_version`映射自动遵循索引/删除操作的行为。 bulk 操作也支持 `version_type`. 详见： [versioning](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/docs-index_.html#index-versioning)

## Rounting

每个bulk项目都可以使用routing字段包含路由值。它根据`_routing`映射自动遵循索引/删除操作的行为。

## bulk Update

当使用 update 操作时，`etry_on_conflict` 可以被用作一个属性 项，作用的范围时 item 本身（而不是额外的负载行）中的字段，以指定在发生版本冲突时应重试多少次更新。

update 操作 支持一下功能：

`doc` (partial document), `upsert`, `doc_as_upsert`, `script`, `params` (for script), `lang` (for script), and `_source`.

实例：

```shell
POST _bulk
{ "update" : {"_id" : "1", "_type" : "_doc", "_index" : "index1", "retry_on_conflict" : 3} }
{ "doc" : {"field" : "value"} }
{ "update" : { "_id" : "0", "_type" : "_doc", "_index" : "index1", "retry_on_conflict" : 3} }
{ "script" : { "source": "ctx._source.counter += params.param1", "lang" : "painless", "params" : {"param1" : 1}}, "upsert" : {"counter" : 1}}
{ "update" : {"_id" : "2", "_type" : "_doc", "_index" : "index1", "retry_on_conflict" : 3} }
{ "doc" : {"field" : "value"}, "doc_as_upsert" : true }
{ "update" : {"_id" : "3", "_type" : "_doc", "_index" : "index1", "_source" : true} }
{ "doc" : {"field" : "value"} }
{ "update" : {"_id" : "4", "_type" : "_doc", "_index" : "index1"} }
{ "doc" : {"field" : "value"}, "_source": true}
```



# 查找API

```shell
# 搜索全部记录
GET _search
{
  "query": {
    "match_all": {}
  }
}

GET PMS _search
{
  "query":{
    "match_all": {}
  }
}
```

