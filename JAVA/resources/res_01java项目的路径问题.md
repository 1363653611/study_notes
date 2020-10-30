# 路径概述

![Java Class路径](res_01java项目的路径问题/1690ff94ff2fb72c)

![Web应用程序路径](res_01java项目的路径问题/1690ffab0a41226b)

## Linux和Windows路径分隔符

- Linux下：”/”
- Window下：”\\”
- Java中通用：`System.getProperty(“file.separator”);`

# 相对路径

> 则是以指定的工作目录作为基点，避开提供完整的绝对路径。文件名称就可以被视为指定工作目录为基点的一个相对路径（虽然一般不将其称之为路径）.

## Java中加载文件时使用的相对路径，究竟是相对于什么路径呢？

- 据java doc上说明，Java使用的相对路径，就是相对于“当前用户目录”，即“Java虚拟机的调用目录”。（我们在哪里调用了JVM的路径。）

## 例子

- D盘根目录下有一java源文件Test.java，如：`D:\Test.java`.
- 该Test.java文件不含package信息，在命令行窗口编译此文件(执行命令：javac Test.java)，则会在D盘自动生成Test.class文件。
- 然后在命令行窗口执行该程序(执行命令：java Test)，此时已启动一个JVM，这个JVM是在D盘根目录下被启动的，则JVM所加载程序中File类的相对路径就是相对D盘根目录的，即 D:\。
- “当前用户目录”，即Java虚拟机的调用目录，也是：D:\
- `System.getProperty("user.dir")`中系统变量"user.dir"存放的也是 D:\
- 说明：把Test.class移动到不同路径下，执行java Test命令启动JVM，发现“当前用户目录”是不断变化的，始终和在哪启动JVM的路径是一致的。

# 绝对路径

> 也可称完整路径，是指向文件系统中某个固定位置的路径，不会因当前的工作目录而产生变化。为做到这点，它必须包括根目录。

## 例子

- 文件路径： `D:\documents\develop\test.txt`（test.txt文件的绝对路径为）
- url路径：`https://www.oracle.com/index.html` (一个URL绝对路径)

# 路径操作API

## java Class 的相对路径

### 相对于classpath的相对路径

> classpath: 就是项目中存放.class文件的路径。

- IntelliJ IDEA项目中classpath为：`D:\ideaProjectDemo\java-demo\target\classes`，相对于classpath的相对路径，就是相对`D:\ideaProjectDemo\java-demo\target\classes`的相对路径。 (URL形式表示为：`file:/D:/ideaProjectDemo/java-demo/target/classes/`)
- Eclipse项目中classpath为：`D:\eclipse32\workspace\java-demo\bin`，相对于classpath的相对路径，就是相对于`D:\eclipse32\workspace\java-demo\bin`的相对路径。 (URL形式表示为：`file:/D:/eclipse32/workspace/java-demo/bin/`)

### 相对于当前用户目录的相对路径

> 当前用户目录：即Java虚拟机的调用目录，即`System.getProperty("user.dir")`返回的路径。

- 对于一般项目，就是项目的根目录，例如：java-demo项目的项目根目录为：D:\ideaProjectDemo\java-demo。
- 对于JavaEE服务器，可能是服务器的某个路径，这个没有统一的规范，例如：在Tomcat中运行Web应用，那“当前用户目录”是：%Tomcat_Home%/bin（即`System.gerProperty("user.dir")`输出%Tomcat_Home%/bin），即D:\Program Files\tomcat-5.0.28\bin，由此可以看出Tomcat服务器是在bin目录下启动JVM的（其实是在bin目录下的“catalina.bat”文件中启动JVM的）。

### 说明

- 默认情况下，java.io包中的类总是根据“当前用户目录”来分析相对路径名，此目录由系统属性user.dir指定，通常是Java虚拟机的调用目录。
- **在使用java.io包中的类时，最好不要使用相对路径。（在J2EE程序中会出问题，这个路径在不同的服务器中都是不同的）**
- **不要使用相对于“当前用户目录”的相对路径**

### java API

- 在java项目和web项目中，其最高级的目录只能是并行的`java` 目录和`resource` 目录。

- 我们只能操作`java` 中的源代码文件和`resource` 的资源文件

  

#### maven 项目结构

- 原始项目结构

  ```bash
  .
  |-- java
  |   |-- zbcn
  |   |   |-- demo1
  |   |   |   `-- DemoTest1.java
  |   |   `-- demo2
  |   |       `-- DemoTest2.java
  `-- resources
      |-- demo0.properties
      `-- ibard
          |-- demo2
          |   `-- demo2.properties
          `-- demo3
              `-- demo3.properties
  ```

- 项目打包发布后的目录结构(我们操作文件是需要针对下面的目录结构)

```bash
target
|-- classes
|   |-- zbcn
|   |   |-- demo0.properties
|   |   |-- demo1
|   |   |   `-- DemoTest1.java
|   |   `-- demo2
|   |       `-- DemoTest2.java
|   |   |   `-- demo2.properties
|   |   |-- demo3
|   |       `-- demo3.properties
```

#### 获取文件路径

- Java中取资源时，经常用到 `Class.getResource()`和 `ClassLoader.getResource()`，这里来看看他们在取资源文件时候的路径问题。

##### 资源路径的分类

- java类文件的路径（`*.java` ）
- 资源文件的路径（`*.properties`或其他资源文件）

##### 通过当前类来获取资源路径

- 其定位参照的方法都是借助`.class` 类文件来展开的（**也就是第2个目录结构图（编译后的目录结构）**）
- 我们所获取的文件路径，都是**绝对路径（相对于系统而言的全写路径）**。比如windows下会是`C:/user/ibard/desktop/....`，linux下会是`/opt/tomcat8/...`这样的物理绝对路径。

###### URL <-  `Concrete.class.getResource(String path)`方法

> path 不以’/'开头时，默认是从此类所在的包下取资源；path  以’/'开头时，则是从`ClassPath`根下获取；
>
> path可以是相对路径，也可以是绝对路径（**绝对路径的path以`/` 开头，指向你程序的根目录**）。得到的结果是`URL` 类型。

- 不以 `/` 开头和 以 `/` 开头区别

```java
 private static void getPathByClass() {
        //不以’/'开头时，默认是从此类所在的包下取资源
        URL relativePath = ResourceLoader.class.getResource("");
        System.out.println("相对路径:" + relativePath.getPath());
        //以’/'开头时，则是从ClassPath根下获取；
        URL absPath = ResourceLoader.class.getResource("/");
        System.out.println("绝对路径:" + absPath.getPath());
    }
```

​	执行结果:

```bash
相对路径:/D:/baseCode/JavaBase/generalJava/target/classes/com/zbcn/common/resource/
绝对路径:/D:/baseCode/JavaBase/generalJava/target/classes/
```

- **path使用相对路径**

当使用相对路径时，其参照目录是当前类文件所在的目录。**当path传入的值为`""` 时，获取的就是当前目录的路径。**

```java
// 1.ResourceLoader.java中获取demo.properties文件的URL
URL url_1 = ResourceLoader.class.getResource("demo.properties");
// 2.生成File对象
File file_1 = new File(url_1.getFile()）;
// 3.获取文件的绝对路径值
String filepath_1 = file_1.toPath();
```

- **path使用绝对路径**
  - 当使用绝对路径时，必须是以`/` 开头，这代表了当前java源代码的根目录。当path传入的值为`/` 时，获取的就是java源代码的根目录。
  - 资源文件 的绝对路径是以 resources 目录开始.eg: `/test/demon.properties`(至resources/test 目录下的 demon.properties).在对应的 编译后的 `classes` 下的properties文件
  - java 文件是以 java 目录开始. eg: `/com/zbcn/common/resource/ResourceLoader.class` 只的是 `java/com/zbcn/common/resource/` 目录下的 ResourceLoader.java 类 在对应的 编译后的 `classes` 下的class文件.

```java
 	/**
     * 绝对路径:绝对路径以 "/" 开头
     */
    private static void getAbsolutePath() {
        //获取当前目录的路径
        URL resource = ResourceLoader.class.getResource("/");
        System.out.println("当前目录的路径："+ resource.getPath());
        URL absPath = ResourceLoader.class.getResource("/com/zbcn/common/resource/demon.properties");
        System.out.println(absPath.getPath());
    }
```

- **`Concrete.class.getResource和Concrete.class.getResourceAsStream`在使用时，路径选择上也是一样的。**

###### URL <- `Concrete.class.getClassLoader().getResource(String path)`方法

> 通过获取类加载器来获取资源文件的路径。**path只能是绝对路径，而且该绝对路径是不以/开头的**。其实介绍的第一种方法，其内部源码就是调用这种方法。
>
> path不能以’/'开头时；path是从ClassPath根下获取；

```java
private static void getPathByClassLoad() {
        URL relativePath = ResourceLoader.class.getClassLoader().getResource("");
        System.out.println("类加载路径" + relativePath.getPath());
        URL absPath = ResourceLoader.class.getClassLoader().getResource("/");
        System.out.println("未获取到路径:" + absPath);
    }

```

- 从结果来看 `TestMain.class.getResource("/") == t.getClass().getClassLoader().getResource("")`

- **`Class.getClassLoader().getResource和Class.getClassLoader().getResourceAsStream`在使用时，路径选择上也是一样的。**

###### `Thread.currentThread().getContextClassLoader().getResource("")`

**`Thread.currentThread().getContextClassLoader().getResource("")` 来得到当前的classpath的绝对路径的URI表示法。**

```java
 private static void getPathByThread() {
        //获取当前目录的路径
        URL resource = Thread.currentThread().getContextClassLoader().getResource("");
        System.out.println("获取classpath："+ resource.getPath());
        URL absPath = Thread.currentThread().getContextClassLoader().getResource("com/zbcn/common/resource/demon.properties");
        System.out.println(absPath.getPath());
    }
```

###### `ClassLoader.getSystemResource("")`

```java
private static void getPathByClassLoadClass() {
        URL systemResource = ClassLoader.getSystemResource("");
        System.out.println("类加载路径:" + systemResource.getPath());
    }
```



## Web应用程序相对路径

### **服务器端相对地址**

- 服务器端的相对地址指的是相对于你的web应用的地址，这个地址是在服务器端解析的。也就是说在jsp和servlet中的相对地址是相对于你的web应用，即相对于`http://192.168.0.1/webapp/`的。

#### 举例： 

1. servlet中：` request.getRequestDispatcher("/user/index.jsp")`，这个`/user/index.jsp`是相对于当前web应用的webapp目录的, 其绝对地址就是：http://192.168.0.1/webapp/user/index.jsp
2. jsp中：` <%response.sendRedirect("/user/a.jsp");%>` 其绝对地址是：http://192.168.0.1/webapp/user/a.jsp

### 客户端相对地址

所有的HTML页面中的相对地址都是相对于服务器根目录(`http://192.168.0.1/`)的，而不是相对于服务器根目录下Web应用目录(`http://192.168.0.1/webapp/`)的。

#### 举例： 

- HTML中form表单的action属性的地址是相对于服务器根目录(http://192.168.0.1)的， 所以提交到index.jsp为：`action="/webapp/user/index.jsp"或action="<%=request.getContextPath()%>/user/a.jsp"`;
- 说明： 一般情况下，在JSP/HTML页面等引用的CSS,JavaScript.Action等属性前面最好都加上 `<%=request.getContextPath()%>`，以确保所引用的文件都属于Web应用中的目录。 
- 注意： 应该尽量避免使用".","./","../../"等类似的相对该文件位置的相对路径，否则当文件移动时，很容易出现问题。
- "./"代表当前目录 
- "../"代表上级目录 
- "../../"代表上级目录的上级目录

# 参考

- https://blog.csdn.net/shendl/article/details/1427475
- https://blog.csdn.net/u011983531/article/details/48443195