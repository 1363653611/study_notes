# [maven打包遇到Aggregator projects require 'pom' as packaging问题解决](https://www.cnblogs.com/baby123/p/12552722.html)

springboot 多模块项目打包时遇到

[ERROR]   'packaging' with value 'jar' is invalid. Aggregator projects require 'pom' as packaging. @ line 3, column 102

解决方案:

默认打包类型为jar

```xml
<packaging>jar</packaging>
```

解决的方法：

　　修改打包类型pom

```xml
<packaging>pom</packaging>
```