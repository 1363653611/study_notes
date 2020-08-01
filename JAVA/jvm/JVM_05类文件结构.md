---
title: 05 类文件结构
date: 2019-12-10 18:14:10
tags:
  - JVM
  - java
categories:
  - JVM
  - java
topdeclare: true
reward: true
---
# 类文件结构

##  无关性的的基石
- 各种不同平台的虚拟机与所有平台都统一使用的程序存储格式: __字节码（byteCode）__ 是构成平台无关性的基石

- JVM 只与.class 这种特殊的二进制文件格式所关联

- class文件
	- java虚拟机指令集
	- 符号表
	- 其他辅助信息

<!--more-->
	
	![image-20200731144811221](JVM_05类文件结构/image-20200731144811221.png)
	
	**可以说`.class`文件是不同的语言在 Java 虚拟机之间的重要桥梁，同时也是支持 Java 跨平台很重要的一个原因。**

##  Class文件的结构

```java
ClassFile {
    u4             magic; //Class 文件的标志: 魔数
    u2             minor_version;//Class 的小版本号
    u2             major_version;//Class 的大版本号
    u2             constant_pool_count;//常量池的数量
    cp_info        constant_pool[constant_pool_count-1];//常量池
    u2             access_flags;//Class 的访问标记
    u2             this_class;//当前类
    u2             super_class;//父类
    u2             interfaces_count;//接口
    u2             interfaces[interfaces_count];//一个类可以实现多个接口
    u2             fields_count;//Class 文件的字段属性
    field_info     fields[fields_count];//一个类会可以有个字段
    u2             methods_count;//Class 文件的方法数量
    method_info    methods[methods_count];//一个类可以有个多个方法
    u2             attributes_count;//此类的属性表中的属性数
    attribute_info attributes[attributes_count];//属性表集合
}
```

## Class文件字节码结构组织示意图

<img src="JVM_05类文件结构/image-20200731145012679.png" alt="image-20200731145012679" style="zoom:80%;" />

## 概述
	- class文件是以8位字节为基础单位的二进制流。各个数据项目严格按照顺序紧凑地排列在class文件之中，中间没有任何分割符。
	- 当遇到需要占用8位字节以上空间额数据项时，则会按照高位在前的方式，分割成若干个8位字节进行存储
	- class文件格式采用类似与C语言结构的方式存储

###  class文件的数据类型
	- 无符号数
		- u1\u2\u4\u8 来分别代表1个字节、2个字节、4个字节和8个字节
		- 用途：
			- 描述数字
			- 索引引用
			- 数量值
			- 按照utf-8编码构成的字符串值
	- 表
		- 是由多个无符号数或者其他表作为数据项构成的复合类型
		- 表都习惯以`_info` 结尾

# 各个数据项的含义
## 魔数       

` u4             magic; //Class 文件的标志`

- 头4个字节为magic Number
- 确定这个文件是否为能被虚拟机接受的class文件

## class文件的版本

```java
  u2             minor_version;//Class 的小版本号
  u2             major_version;//Class 的大版本号
```

- 紧接着魔数的4个字节为Class文件的版本号
- Minor Version 5 \ 6 字节
- Major Version 7\ 8 字节

## 常量池

```java
 u2             constant_pool_count;//常量池的数量
 cp_info        constant_pool[constant_pool_count-1];//常量池
```

常量池的数量是 constant_pool_count-1（**常量池计数器是从1开始计数的，将第0项常量空出来是有特殊考虑的，索引值为0代表“不引用任何一个常量池项”**）。

- 主版本之后为常量池入口

- 特点

- class文件之中的资源仓库。
	- class文件结构中与其他项目关联最多的数据类型
	- Class文件中第一个出现表类型数据的项目
	- class文件中空间最大的数据项目之一
	
- 常量池容量计数器
	- 入口位置：放置u2类型的数据。代表常量池容量计数值（constant_pool_count）
	- 范围：1-21
	- 0表示指向常量池的索引值的数据在特定情况下，不引用任何一个常量池项目。

	
	
- 常量类型
	- 字面常量Literal
		- 字符串常量
		- 申明为final的常量值
		
	- 符号引用 Symbolic References
		- 类和接口的全限定性类名 Fully Qualified Name
		- 字段的名称和描述符
		- 方法名称和描述符
	
- 当虚拟机运行时，需要从常量池获得对应的符号引用，再在类创建时或者运行时解析、翻译到具体的类存地址中。

- 常量池中有14种结构类型。每一项都是一个表

14种表有一个共同的特点：**开始的第一位是一个 u1 类型的标志位 -tag 来标识常量的类型，代表当前这个常量属于哪种常量类型．**

| 类型                             | 标志（tag） | 描述                   |
| -------------------------------- | ----------- | ---------------------- |
| CONSTANT_utf8_info               | 1           | UTF-8编码的字符串      |
| CONSTANT_Integer_info            | 3           | 整形字面量             |
| CONSTANT_Float_info              | 4           | 浮点型字面量           |
| CONSTANT_Long_info               | ５          | 长整型字面量           |
| CONSTANT_Double_info             | ６          | 双精度浮点型字面量     |
| CONSTANT_Class_info              | ７          | 类或接口的符号引用     |
| CONSTANT_String_info             | ８          | 字符串类型字面量       |
| CONSTANT_Fieldref_info           | ９          | 字段的符号引用         |
| CONSTANT_Methodref_info          | 10          | 类中方法的符号引用     |
| CONSTANT_InterfaceMethodref_info | 11          | 接口中方法的符号引用   |
| CONSTANT_NameAndType_info        | 12          | 字段或方法的符号引用   |
| CONSTANT_MothodType_info         | 16          | 标志方法类型           |
| CONSTANT_MethodHandle_info       | 15          | 表示方法句柄           |
| CONSTANT_InvokeDynamic_info      | 18          | 表示一个动态方法调用点 |

## 访问标志 access flag

![image-20200801121834478](JVM_05类文件结构/image-20200801121834478.png)

- 2个字节
- 识别一些类或者接口层次的访问信息
	- 这个class是类还是接口
		- 类(_是否被申明为final_)
		- 接口
	- 是否定义为public
	- 是否定义为abstract类型
- 通过 `javap -v class类名` 指令来看一下类的访问标志

## 类索引、父类索引、结构索引 集合

```java
 u2             this_class;//当前类
 u2             super_class;//父类
 u2             interfaces_count;//接口
 u2             interfaces[interfaces_count];//一个类可以实现多个接口
```

> - 类索引
> 	- 标志这个类的全限定性类名
> - 父类索引
> 	- 确定这个类的父类的全限定性类名
> - 接口索引集合
> 	- 描述这些类实现了哪些接口

## 字段集合表 field_info

```java
u2             fields_count;//Class 文件的字段的个数
field_info     fields[fields_count];//一个类会可以有个字段
```

- 用于描述类或者接口中申明的变量
- field info(字段表) 的结构:

![image-20200801121803063](JVM_05类文件结构/image-20200801121803063.png)

- **access_flags:** 字段的作用域（`public` ,`private`,`protected`修饰符），是实例变量还是类变量（`static`修饰符）,可否被序列化（transient 修饰符）,可变性（final）,可见性（volatile 修饰符，是否强制从主内存读写）。
- **name_index:** 对常量池的引用，表示的字段的名称；
- **descriptor_index:** 对常量池的引用，表示字段和方法的描述符；
- **attributes_count:** 一个字段还会拥有一些额外的属性，attributes_count 存放属性的个数；
- **attributes[attributes_count]:** 存放具体属性具体内容。

上述这些信息中，各个修饰符都是布尔值，要么有某个修饰符，要么没有，很适合使用标志位来表示。而字段叫什么名字、字段被定义为什么数据类型这些都是无法固定的，只能引用常量池中常量来描述。

- 类型
	- 类级变量
	- 实例级别变量
	
- 包含的信息
	- 修饰符用boolean值来区分 ---用标志位来表示
	- 字段的定义、数据类型用常量池中的常量来表示
	- 可变性（final）
		- 访问标志 access_flag
		- 是实例变量还是类变量（static）
		- 是否可序列化（transient 修饰符）
		- 字段的作用域
		- 并发可见性 （volatile 关键字）
	- 字段数据类型
	- 字段名称

 	- 相关定义

		- 全限定性类名
		- 简单名称
		- 描述符
			- 字段
				- 数据类型
			- 方法
				- 参数
				- 返回值
- 字段列表集合中不会列出从超类或者父类接口中继承过来的字段
	
	- 字段的 access_flags 的取值
	
	![image-20200801121727496](JVM_05类文件结构/image-20200801121727496.png)
	
	
	
## 方法集合表

	```java
	 u2             methods_count;//Class 文件的方法的数量
	 method_info    methods[methods_count];//一个类可以有个多个方法
	```
	
	- methods_count 表示方法的数量，而 method_info 表示的方法表。
	- Class 文件存储格式中对方法的描述与对字段的描述几乎采用了完全一致的方式。方法表的结构如同字段表一样，依次包括了访问标志、名称索引、描述符索引、属性表集合几项
	- method_info  方法表的结构
	
	![img](https://my-blog-to-use.oss-cn-beijing.aliyuncs.com/2019-6/%E6%96%B9%E6%B3%95%E8%A1%A8%E7%9A%84%E7%BB%93%E6%9E%84.png)


	- 包含的信息
		- 访问标志 access_flag
		- 名称索引 name_index
		- 描述符索引 descriptor_index
		- 属性表集合 attributes
	- 方法属性表里里面的Code
		- 方法体中的代码
	- 父类方法在子类中没有被重写。则方法表集合中就不会出现父类方法信息



	- 方法表的 access_flag 取值：
	![方法表的 access_flag 取值](https://my-blog-to-use.oss-cn-beijing.aliyuncs.com/2019-6/%E6%96%B9%E6%B3%95%E8%A1%A8%E7%9A%84access_flag%E7%9A%84%E6%89%80%E6%9C%89%E6%A0%87%E5%BF%97%E4%BD%8D.png)
	
	因为`volatile`修饰符和`transient`修饰符不可以修饰方法，所以方法表的访问标志中没有这两个对应的标志，但是增加了`synchronized`、`native`、`abstract`等关键字修饰方法，所以也就多了这些关键字对应的标志。


​	
​	
## 属性表集合 attribute_info

	```java
	u2             attributes_count;//此类的属性表中的属性数
	attribute_info attributes[attributes_count];//属性表集合
	```
	
	在 Class 文件，字段表，方法表中都可以携带自己的属性表集合，以用于描述某些场景专有的信息。与 Class 文件中其它的数据项目要求的顺序、长度和内容不同，属性表集合的限制稍微宽松一些，不再要求各个属性表具有严格的顺序，并且只要不与已有的属性名重复，任何人实现的编译器都可以向属性表中写 入自己定义的属性信息，Java 虚拟机运行时会忽略掉它不认识的属性。
	
	- Class文件、字段表、方法表都可以携带自己的属性表集合
	- 一些关键属性
		- code属性
		- Exceptons属性
		- LineNumberTable 属性
		- Source File 属性
		- ConstantValue 属性
		- Inner Class 属性
		- Deprecated 及 Synthetic 属性
		- Signature 属性
		- BootStrapMethods 属性

# 字节码指令简介
- 分类
	- 字节码与数据类型
- 加载和存储指令
	- 用于将数据在栈帧中的局部变量表和操作数栈之间来回传输。
	- 指令
		- 将一个局部变量加载到操作栈 `*load`
		- 将一个数值从操作数栈存储到局部变量表 `*store`
		- 将一个常量加载到操作数栈
		- 扩充局部变量表的访问索引指令：wide

- 运算指令
	- 用于对两个操作数栈上的值进行某种特定的运算，并把结果存储到操作数栈的栈顶
	- 分类
		- 加法
		- 减法
		- 乘法
		- 除法
		- 求余
		- 求反
		- 位移
		- 按位或
		- 按位与
		- 按位异或
		- 局部变量自增
		- 比较

- 类型转换指令

- 对象创建与访问指令
	- 创建类实例的指令 new
	- 创建数组的指令：newarray、anewarray、multianewarray
	- 访问静态字段指令和实例字段的指令：getfield\putfield\getstatic\putstatic
	- 把一个数组元素加载到操作数栈的指令 `*aload`
	- 将操作数栈的值存储到数组元素的指令 `*astore`
	- 取数组长度的指令 arraylength
	- 检查类实例类型的指令 ：instanceof ，chackcast

- 操作数栈管理指令
	- 将操作数栈顶的一个或者两个元素出栈：`pop、pop2`
	- 复制栈顶的一个或者两个数值并将复制值或者双份的复制值重新压入栈顶：`dup\dup2`
	- 将最栈顶端的连个数值互换： swap

- 控制转移指令
	- 条件分支
	- 符合条件分支
	- 无条件分支

- 方法调用和返回指令
	- invokevirtual 指令 用于调用对象实例方法
	- nvokeinterface 指令用调用接口方法
	- invokespecial 指令用于调用一些需要特殊处理的实例方法（实例初始化方法、私有方法、父类方法）
	- invokestatic 指令用于调用类方法
	- invokedynamic 指令 用于在运行时动态解析出调用点姓丁符所引用的方法，并执行该方法

- 异常处理指令

- 同步指令

- 简介
	- 操作码 Opcode
		- 操作码总数不能超过256条
		- 操作码的长度只有一个字节

	- 操作数 Operands

- 公有设计和私有实现

- class文件结构的发展
	- class文件格式所具备的平台中立（不依赖于操作系统）、紧凑、稳定和可扩展的特点，是java技术体系实现平台无关、语言无关两项特性的重要支柱
