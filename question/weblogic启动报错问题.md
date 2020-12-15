# weblogic 11g类加载问题总结

## 问题描述

XX局点升级weblogic为11g，重新发包出错。现在记录一下处理的各种问题总结。

### 错误1: apache commons某些包的方法没有找到

这是最早出现的问题，会出现类似下面的错误信息。

```xml
<2015-10-14 下午05时57分30秒 CST> <Error> <HTTP> <BEA-101017> <[ServletContext@1385406679[app:XXService module:XXService path:/XXService spec-version:2.5]] Root cause of ServletException.
java.lang.NoSuchMethodError: org.apache.commons.io.FileUtils.copyInputStreamToFile(Ljava/io/InputStream;Ljava/io/File;)V
```

- 原因分析

这是weblogic部署最常见的问题，因为weblogic会自带I一些commons-*的包，这些包的版本还比较旧。具体可以见WEBLOGIC_HOME/modules目录的jar包。

- 此次采用的处理方式

添加weblogic.xml并设置prefer-web-inf-classes，即优先加载web应用下的类

```xml
<?xml version="1.0" encoding="UTF-8"?>
<weblogic-web-app>
	<container-descriptor>
		<prefer-web-inf-classes>true</prefer-web-inf-classes>
	</container-descriptor>
</weblogic-web-app>
```

### 错误2: jsp使用jstl时出现SAXParserFactory的ClassCastException

这是使用prefer-web-inf-classes为true之后出现的问题，会出现类似下面的错误信息。

```java
The validator class: "org.apache.taglibs.standard.tlv.JstlCoreTLV" has failed with the following exception: "java.lang.ClassCastException: weblogic.xml.jaxp.RegistrySAXParserFactory cannot be cast to javax.xml.parsers.SAXParserFactory".
```

- 原因分析

这是weblogic部署很常见的问题，jstl会调用sax，sax是通过spi机制加载实现，获取是weblogic的实现，但它使用的是jdk自带的javax.xml.parsers.SAXParserFactory接口。 刚好web应用下也带了jar包xml-apis-1.x.jar，它也有javax.xml.parsers.SAXParserFactory这个接口。根据prefer-web-inf-classes的设置，jstl代码中用的是这个接口。 由此可知，使用classloader并不一样，无法转换。

- 此次采用的处理方式

删除WEB-INF/lib/xml-apis-1.x.jar后本地测试该问题恢复。

### 错误3: 出现QName的LinkageError

这是错误2解决后，继续解析spring时出现的问题。

- 原因分析

这个问题和上面的差不多，太细就不深究了。

- 此次采用的处理方式

这种情况下，如果使用prefer-web-inf-classes为true，则需要排除存在QName的jar包并删除，但最后没有采用(改动太大，得不偿失)。
所以这次重新设置了prefer-web-inf-classes为false，但仍然优先加载commons，如下:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<weblogic-web-app>
	<container-descriptor>
		<prefer-web-inf-classes>false</prefer-web-inf-classes>
    <prefer-application-packages>  
        <package-name>org.apache.commons.*</package-name>
    </prefer-application-packages> 
	</container-descriptor>
</weblogic-web-app>
```

修改后本地测试ok，但发布到生产仍然失败。

### 错误4: MemCachedClient获取key失败(序列化问题)

错误3处理后，发布到生产仍然出错，报错信息如下:

```java
18:44:57.337 [[ACTIVE] ExecuteThread: '0' for queue: 'weblogic.kernel.Default (self-tuning)'] ERROR com.danga.MemCached.MemCachedClient - ++++ exception thrown while trying to get object from cache for key: init_error_key_0098
18:44:57.351 [[ACTIVE] ExecuteThread: '0' for queue: 'weblogic.kernel.Default (self-tuning)'] ERROR com.danga.MemCached.MemCachedClient - com.xxx.hnxx.mybatis.entity.PlaterrorCodeBean
java.io.IOException: com.xxx.hnxx.mybatis.entity.PlaterrorCodeBean
	at com.schooner.MemCached.ObjectTransCoder.decode(Unknown Source) ~[MemCached-2.6.6.jar:na]
	at com.schooner.MemCached.AscIIClient.get(Unknown Source) [MemCached-2.6.6.jar:na]
	at com.schooner.MemCached.AscIIClient.get(Unknown Source) [MemCached-2.6.6.jar:na]
	at com.schooner.MemCached.AscIIClient.get(Unknown Source) [MemCached-2.6.6.jar:na]
	at com.danga.MemCached.MemCachedClient.get(Unknown Source) [MemCached-2.6.6.jar:na]
	at com.xxx.hnxx.cache.mencached.MemcacheManagerClient.get(MemcacheManagerClient.java:162) [MemcacheManagerClient.class:na]
```

上面的错误信息表示获取init_error_key_0098这个可以的时候失败，实际上这个key是在应用启动的时候就塞进去的。

- 原因分析

这里有很多意想不到的事情，所以详细解释一下。

首先，这个出现了IOException让人联想到是否memcached服务器连接的问题。
实际上是因为库在实现java对象放入memcached的时候，有一个序列化/反序列化的过程(就是java自带的那个)，在反序列化的时候找不到类会出现ClassNotFoundException，然后库将错误信息(就是一个类名)取出重新包装为IOException。
所以，这实际上是一个类找不到的问题。

再者，这个问题一开始在家里的weblogic没法重现。后来我重新检查了生产上weblogic的启动日志才发现了一些差异。
关键信息如下所示，生产上的weblogic在domain的lib目录也是有jar包的，而家里的是没有的。尝试修改把jar包也拷贝一份，果然重现。

```java
<2015-10-14 下午06时44分36秒 CST> <Notice> <WebLogicServer> <BEA-000395> <Following extensions directory contents added to the end of the classpath:/weblogic/bea/user_projects/domains/PLATFORM_DOM/lib/MemCached-2.6.6.jar:/weblogic/bea/user_projects/domains/PLATFORM_DOM/lib/MyXMLSerializer-1.0.0.jar...
```

最后，这个问题就好解释多了。

1. 需要序列化/反序列化的类是在com.huawei下面的，这部分类指在web应用中存在。在system classloader是找不到的。
2. 序列化/反序列化时候，都是由web应用中的类，调用memcached库去实现的(虽然web应用中也有，但是根据prefer-web-inf-classes设置，加载的是domain中lib目录的)
3. 序列化只是没什么特别。但是反序列化需要加载类，很明显system classloader(memcached库的classloader)是加载不到web应用中的类的。

- 此次采用的处理方式

有好几种方式，都列举一下:

1. 删除domain中的jar包，这样就会加载到web应用中的类，让库和需要序列化的类都有web classloader加载
2. 让库也由web优先加载，如下所示 ```xml <?xml version=”1.0” encoding=”UTF-8”?>

false org.apache.commons.* com.danga.* com.schooner.*

3. 指定memcached库进行反序列化时的classloader，如下所示:

```java
 ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
  // MemCachedClient实例化时，会持有SockIOPool.getInstance()单利的引用
 cachedClient = new MemCachedClient((String)null, true, false, classLoader, null);
```

个人推荐的优先级是2 - 3 - 1, 尽量做到容器无关，并少动全局的东西。**由于目前生产上的weblogic版本已经回退，待后续上生产验证。**

## weblogic的类加载器介绍

- 整体的类加载器层次如下(只关注war部分)，并采用标准的双亲委托加载机制

  ```java
  WebLogic Server System classloader (classpath、<domain>/lib)
  Filtering classloader (空)
  Application classloader (EJB JARs、APP-INF/lib、APP-INF/classes、Manifest Class-Path in EJB JARs)
  Web application classloader (WAR、Manifest Class-Path in WAR)
  ```

- Web application classloader可以通过weblogic.xml中的prefer-web-inf-classes优先加载war中的类，找不到才向上请求

- Filtering classloader并不会加载任何类，而是起到控制类加载优先级的作用。通过配置可以限制对于指定的类不再向上请求，也就是限制范围内加载

- 配置prefer-application-packages/prefer-application-resources的话，prefer-web-inf-classes必须配置为false

- 资源(resource)的加载顺序，在开启Filtering之后，顺序为App - Web - System(App、Web仍然是符合双亲委托的)

## 参考材料

- https://mccxj.github.io/blog/20151023_weblogic-11g-classloader-prefer.html

- http://docs.oracle.com/cd/E23943_01/web.1111/e13712/weblogic_xml.htm#WBAPP599
- http://docs.oracle.com/cd/E12839_01/web.1111/e13706/classloading.htm#WLPRG284
- http://tobato.iteye.com/blog/1845969
- http://tobato.iteye.com/blog/1483020