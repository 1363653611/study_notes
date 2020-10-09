---
title: IO_00 预备知识
date: 2020-10-01 12:14:10
tags:
  - IO
categories:
  - IO
topdeclare: true
reward: true
---

# 字符与字节

- 在Java中有输入、输出两种IO流，每种输入、输出流又分为字节流和字符流两大类。

- 一个字节 8 个bit

- Java采用`unicode`编码，2个字节来表示一个字符。(C语言中采用ASCII，在大多数系统中，一个字符通常占1个字节，但是在0~127整数之间的字符映射，`unicode`向下兼容ASCII。)

- Java采用`unicode`来表示字符，一个中文或英文字符的`unicode`编码都占2个字节。但如果采用其他编码方式，一个字符占用的字节数则各不相同。

- Java中的String类是按照unicode进行编码的，当使用 `String(byte[] bytes, String encoding)`构造字符串时，encoding所指的是bytes中的数据是按照那种方式编码的，而不是最后产生的String是什么编码方式。换句话说，是让系统把bytes中的数据由encoding编码方式转换成unicode编码。如果不指明，bytes的编码方式将由jdk根据操作系统决定。

<!--more-->

- `getBytes(String charsetName)`使用指定的编码方式将此String编码为 byte 序列，并将结果存储到一个新的 byte 数组中。如果不指定将使用操作系统默认的编码方式，我的电脑默认的是`UTF-8`编码.

  ```java
  public static void main(String[] args) {
          String str = "你好hello";
          int length = str.getBytes().length;
          int len = str.length();
          System.out.println("字节长度为：" + length);
          System.out.println("字符长度为：" + len);
          System.out.println("系统默认编码方式：" + System.getProperty("file.encoding"));
      }
  ```

  输出：

  ```shell
  字节长度为：11
  字符长度为：7
  系统默认编码方式：UTF-8
  ```

  - 在UTF-8编码中，一个英文字母字符存储需要1个字节，一个汉字字符储存需要3到4个字节。
  - 在UTF-16编码中，一个英文字母字符存储需要2个字节，一个汉字字符储存需要3到4个字节（Unicode扩展区的一些汉字存储需要4个字节）。
  - 在UTF-32编码中，世界上任何字符的存储都需要4个字节。
  - 在 GB 2312 编码或 GBK 编码中，一个英文字母字符存储需要1个字节，一个汉字字符存储需要2个字节.

  **简单来讲，一个字符表示一个汉字或英文字母，具体字符与字节之间的大小比例视编码情况而定。有时候读取的数据是乱码，就是因为编码方式不一致，需要进行转换，然后再按照unicode进行编码。**

# File类

- java 文件类以抽象的方式代表文件名和目录路径名。该类主要用于文件和目录的创建、文件的查找和文件的删除等。
- File对象代表磁盘中实际存在的文件和目录。通过以下构造方法创建一个File对象。

## 构建File 对象的方式

- 通过给定的父抽象路径名和子路径名字符串创建一个新的File实例。

```java
File(File parent, String child);
```

- 通过将给定路径名字符串转换成抽象路径名来创建一个新 File 实例。

```java
File(String pathname)
```

- 根据 parent 路径名字符串和 child 路径名字符串创建一个新 File 实例。

```java
File(String parent, String child)
```

- 通过将给定的 file: URI 转换成一个抽象路径名来创建一个新的 File 实例。

```java
File(URI uri)
```

```java
//构造函数File(String pathname)
File f1 =new File("c:\\abc\\1.txt");
//File(String parent,String child)
File f2 =new File("c:\\abc","2.txt");
//File(File parent,String child)
File f3 =new File("c:"+File.separator+"abc");//separator 跨平台分隔符
File f4 =new File(f3,"3.txt");
System.out.println(f1);//c:\abc\1.txt
```

## 路径分隔符：

- windows： "/" "\\" 都可以
- linux/unix： "/"

- 如果windows选择用"/"做分割符的话,那么请记得替换成"\",因为Java中"/"代表转义字符所以推荐都使用"\"，也可以直接使用代码File.separator，表示跨平台分隔符。

## **路径**

#### 相对路径：

1. `./`表示当前路径
2. `../`表示上一级路径其中当前路径：
3. 默认情况下，`java.io` 包中的类总是根据当前用户目录来分析相对路径名。此目录由系统属性 `user.dir` 指定，通常是 Java 虚拟机的调用目录。

#### 绝对路径：

绝对路径名是完整的路径名，不需要任何其他信息就可以定位自身表示的文件。

| **序号** | **方法描述**                                                 |
| -------- | ------------------------------------------------------------ |
| 1        | **public String getName()**返回由此抽象路径名表示的文件或目录的名称。 |
| 2        | **public String getParent()、** 返回此抽象路径名的父路径名的路径名字符串，如果此路径名没有指定父目录，则返回 null。 |
| 3        | **public File getParentFile()**返回此抽象路径名的父路径名的抽象路径名，如果此路径名没有指定父目录，则返回 null。 |
| 4        | **public String getPath()**将此抽象路径名转换为一个路径名字符串。 |
| 5        | **public boolean isAbsolute()**测试此抽象路径名是否为绝对路径名。 |
| 6        | **public String getAbsolutePath()**返回抽象路径名的绝对路径名字符串。 |
| 7        | **public boolean canRead()**测试应用程序是否可以读取此抽象路径名表示的文件。 |
| 8        | **public boolean canWrite()**测试应用程序是否可以修改此抽象路径名表示的文件。 |
| 9        | **public boolean exists()**测试此抽象路径名表示的文件或目录是否存在。 |
| 10       | **public boolean isDirectory()**测试此抽象路径名表示的文件是否是一个目录。 |
| 11       | **public boolean isFile()**测试此抽象路径名表示的文件是否是一个标准文件。 |
| 12       | **public long lastModified()**返回此抽象路径名表示的文件最后一次被修改的时间。 |
| 13       | **public long length()**返回由此抽象路径名表示的文件的长度。 |
| 14       | **public boolean createNewFile() throws IOException**当且仅当不存在具有此抽象路径名指定的名称的文件时，原子地创建由此抽象路径名指定的一个新的空文件。 |
| 15       | **public boolean delete()** 删除此抽象路径名表示的文件或目录。 |
| 16       | **public void deleteOnExit()**在虚拟机终止时，请求删除此抽象路径名表示的文件或目录。 |
| 17       | **public String[] list()**返回由此抽象路径名所表示的目录中的文件和目录的名称所组成字符串数组。 |
| 18       | **public String[] list(FilenameFilter filter)**返回由包含在目录中的文件和目录的名称所组成的字符串数组，这一目录是通过满足指定过滤器的抽象路径名来表示的。 |
| 19       | **public File[] listFiles()** 返回一个抽象路径名数组，这些路径名表示此抽象路径名所表示目录中的文件。 |
| 20       | **public File[] listFiles(FileFilter filter)**返回表示此抽象路径名所表示目录中的文件和目录的抽象路径名数组，这些路径名满足特定过滤器。 |
| 21       | **public boolean mkdir()**创建此抽象路径名指定的目录。       |
| 22       | **public boolean mkdirs()**创建此抽象路径名指定的目录，包括创建必需但不存在的父目录。 |
| 23       | **public boolean renameTo(File dest)** 重新命名此抽象路径名表示的文件。 |
| 24       | **public boolean setLastModified(long time)**设置由此抽象路径名所指定的文件或目录的最后一次修改时间。 |
| 25       | **public boolean setReadOnly()**标记此抽象路径名指定的文件或目录，以便只可对其进行读操作。 |
| 26       | **public static File createTempFile(String prefix, String suffix, File directory) throws IOException**在指定目录中创建一个新的空文件，使用给定的前缀和后缀字符串生成其名称。 |
| 27       | **public static File createTempFile(String prefix, String suffix) throws IOException**在默认临时文件目录中创建一个空文件，使用给定前缀和后缀生成其名称。 |
| 28       | **public int compareTo(File pathname)**按字母顺序比较两个抽象路径名。 |
| 29       | **public int compareTo(Object o)**按字母顺序比较抽象路径名与给定对象。 |
| 30       | **public boolean equals(Object obj)**测试此抽象路径名与给定对象是否相等。 |
| 31       | **public String toString()** 返回此抽象路径名的路径名字符串。 |

# 参考

- https://mp.weixin.qq.com/s/YX762wVAjVTsSyk19pABwg
