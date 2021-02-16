---
title: python 基础学习笔记
date: 2021-02-09 15:14:10
tags:
 - python
categories:
 - python
topdeclare: true
reward: true
---

### python 基础学习笔记 ###

### 变量

- 变量类型
    * 整形
    * 浮点型 (数学写法， 科学计数写法)
    * boolean -> True False
    * 字符串
        - 单引号 'hello'
        - 双引号 "hello"
        - 多行的形式（用三个单引号或三个双引号开头，三个单引号或三个双引号结尾）
    * 复数形
- 变量命名：
    * 硬性规定：
        - 以字母、数字、下划线组成，数字不能开头
        - 大小写敏感
        - 不要和关键字和系统保留字冲突
    * PEP 8要求
        - 用小写字母拼写，多个单词之间用下划线链接
        - 受 保护的实例属性以单个下划线开头
        - 私有的属性以双下滑线开头

<!--more-->

- 变量使用：
    * 算数运算
    * 使用 `type()` 做类型检查
    * 变量的类型转换：
        - int()：将一个数值或字符串转换成整数，可以指定进制。
        - float()：将一个字符串转换成浮点数。
        - str()：将指定的对象转换成字符串形式，可以指定编码。
        - chr()：将整数转换成该编码对应的字符串（一个字符）。
        - ord()：将字符串（一个字符）转换成对应的编码（整数）。

    >1. 使用input()函数获取键盘输入(字符串)
    >2. 使用int()函数将输入的字符串转换成整数
    >3. 使用print()函数输出带占位符的字符串
    >4. ** 说明：**  上面的print函数中输出的字符串使用了占位符语法，其中%d是整数的占位符，%f是小数的占位符，%%表示百分号（因为百分号代表了占位符，所以带占位符的字符串中要表示百分号必须写成%%），字符串之后的%后面跟的变量值会替换掉占位符然后输出到终端中，运行上面的程序，看看程序执行结果就明白啦。                                                                                                                                                             


### 运算符

Python支持多种运算符，下表大致按照优先级从高到低的顺序列出了所有的运算符，运算符的优先级指的是多个运算符同时出现时，先做什么运算然后再做什么运算。除了我们之前已经用过的赋值运算符和算术运算符，我们稍后会陆续讲到其他运算符的使用。

| 运算符                                                       | 描述                           |
| ------------------------------------------------------------ | ------------------------------ |
| `[]` `[:]`                                                   | 下标，切片                     |
| `**`                                                         | 指数                           |
| `~` `+` `-`                                                  | 按位取反, 正负号               |
| `*` `/` `%` `//`                                             | 乘，除，模，整除               |
| `+` `-`                                                      | 加，减                         |
| `>>` `<<`                                                    | 右移，左移                     |
| `&`                                                          | 按位与                         |
| `^` `\|`                                                      | 按位异或，按位或               |
| `<=` `<` `>` `>=`                                            | 小于等于，小于，大于，大于等于 |
| `==` `!=`                                                    | 等于，不等于                   |
| `is`  `is not`                                               | 身份运算符                     |
| `in` `not in`                                                | 成员运算符                     |
| `not` `or` `and`                                             | 逻辑运算符                     |
| `=` `+=` `-=` `*=` `/=` `%=` `//=` `**=` `&=` `^=` `>>=` `<<=` `\|=`  | （复合）赋值运算符             |          

### 分支结构

1. if 语句 `if ... elef ...else...`

### 循环结构

1. for-in循环
```python
"""
用for循环实现1~100求和
"""
sum = 0
for x in range(101):
    sum += x
print(sum)
```

2. while循环


### 函数（方法）

1. 函数定义 `def` 开头

2. 函数参数
    * 默认参数：在参数中指定参数的名称，并且付默认值 `add(a=2, b=3, c = 4):`
        ```python
         def add(a=2, b=3, c = 4):
           return a +b +c
        ```
    * 可变参数：在参数名前面的*表示args是一个可变参数

        ```python
        # 在参数名前面的*表示args是一个可变参数
        def add(*args):
            total = 0
            for val in args:
                total += val
            return total

        ```
        eg：可变参数允许你传入0个或任意个参数，这些可变参数在函数调用时自动组装为一个tuple.

    * 关键字参数:
        eg: `**kw`,关键字参数允许你传入0个或任意个含参数名的参数，这些关键字参数在函数内部自动组装为一个dict

    * 命名关键字参数: 如果要限制关键字参数的名字，就可以用命名关键字参数.
        eg: `person(name, age, *, city, job):` . 命名关键字参数需要一个特殊分隔符*，*后面的参数被视为命名关键字参数。
         如果函数定义中已经有了一个可变参数，后面跟着的命名关键字参数就不再需要一个特殊分隔符 \*了
    * 参数组合: 顺序必须是：必选参数、默认参数、可变参数、命名关键字参数和关键字参数
3. 切片
    - 有了切片操作，很多地方循环就不再需要了
4. 迭代 `for` `while`

5. 列表生成器

6. 生成器

7. 迭代器
    * __可迭代对象__
        - 一类是集合数据类型，如list、tuple、dict、set、str等；
        - 一类是generator，包括生成器和带yield的generator function。

3. 高阶函数
    - map
        * map 接受两个参数， 一个是函数，一个是Iterable
        * 作用是将函数作用捣 迭代序列的每个元素，以函数的返回值为元素生成新的序列    

    - reduce
        * 函数必须接收两个参数，reduce把结果继续和序列的下一个元素做累积计算
            ```python
            from functools import reduce
            def add(x, y):
                 return x + y

            reduce(add, [1, 3, 5, 7, 9])
            ```
    - filter
        * filter()也接收一个函数和一个序列
        * filter()把传入的函数依次作用于每个元素，然后根据返回值是True(保留)还是False(丢弃)决定保留还是丢弃该元素

    - sorted 排序
        * sorted()排序的关键在于实现一个映射函数
        * eg:绝对值大小排序: `sorted([36, 5, -12, 9, -21], key=abs)`

    - 返回函数
        * 函数作为返回值
            ```python
            # 返回一个函数时，牢记该函数并未执行，返回函数中不要引用任何可能会变化的变量。
            def lazy_sum(*args):
                def sum():
                    ax = 0
                    for n in args:
                        ax = ax + n
                    return ax
                return sum
            ```
    - 闭包
        * 注意到返回的函数在其定义内部引用了局部变量args，所以，当一个函数返回了一个函数后，其内部的局部变量还被新函数引用，所以，闭包用起来简单，实现起来可不容易
        * 返回闭包时牢记一点：返回函数不要引用任何循环变量，或者后续会发生变化的变量。

    - lambda 匿名函数

    - 装饰器 (注解)
        
        - 函数可以被看成对象，而且可以被赋值给变量，所以通过变量可以调用函数
        - 加入我们想要增强还苏的功能，但是不想修改函数的定义和结构。这种在运行期间动态增加功能的方式称之为装饰器（Decorator） 
        - decorator 是一个返回函数的高阶函数
           ```python
          # 定义： 以函数作为参数
          def log(func):
              def wrapper(*args, **kw):
                  print('call %s():' % func.__name__)
                  return func(*args, **kw)
              return wrapper
          
          # 使用：借助于Python的@语法，把decorator置于函数的定义处：相当于执行了：`now = log(now)`
          @log
          def now():
              print('2015-3-25')
          
           ```
    - 偏函数
        * functools.partial就是帮助我们创建一个偏函数
        `int2 = functools.partial(int, base=2)`

#### 字符串和常用的数据结构

1. 字符串：由 0 个或者多个字符构成的有限序列
    ```python
       s1 = 'hello, world!'
       s2 = "hello, world!"
       # 以三个双引号或单引号开头的字符串可以折行
       s3 = """
       hello,
       world!
       """
    ```

2. 字符串运算：
    - `+` 运算符来实现字符串的拼接
    - `*` 运算符来重复一个字符串的内容 :  
        `s1 = 'hello ' * 3`
    - 用in和not in来判断一个字符串是否包含另外一个字符串（成员运算）:
        `print('ll' in s1) ` `print('11' not in s1)`
    - 用 `[]` 和 `[:]` 运算符从字符串取出某个字符或某些字符（切片运算）:
        `str2[2:5]` `print(str2[2:])`

    - 其他：
        ```python
        str1 = 'hello, world!'
        # 通过内置函数len计算字符串的长度
        print(len(str1)) # 13
        # 获得字符串首字母大写的拷贝
        print(str1.capitalize()) # Hello, world!
        # 获得字符串每个单词首字母大写的拷贝
        print(str1.title()) # Hello, World!
        # 获得字符串变大写后的拷贝
        print(str1.upper()) # HELLO, WORLD!
        # 从字符串中查找子串所在位置
        print(str1.find('or')) # 8
        print(str1.find('shit')) # -1
        # 与find类似但找不到子串时会引发异常
        # print(str1.index('or'))
        # print(str1.index('shit'))
        # 检查字符串是否以指定的字符串开头
        print(str1.startswith('He')) # False
        print(str1.startswith('hel')) # True
        # 检查字符串是否以指定的字符串结尾
        print(str1.endswith('!')) # True
        # 将字符串以指定的宽度居中并在两侧填充指定的字符
        print(str1.center(50, '*'))
        # 将字符串以指定的宽度靠右放置左侧填充指定的字符
        print(str1.rjust(50, ' '))
        str2 = 'abc123456'
        # 检查字符串是否由数字构成
        print(str2.isdigit())  # False
        # 检查字符串是否以字母构成
        print(str2.isalpha())  # False
        # 检查字符串是否以数字和字母构成
        print(str2.isalnum())  # True
        str3 = '  jackfrued@126.com '
        print(str3)
        # 获得字符串修剪左右两侧空格之后的拷贝
        print(str3.strip())
        ```
#### 列表（list）

1. 定义：一种结构化的、非标量类型，它是值的有序序列，每个值都可以通过索引进行标识，定义列表可以将列表的元素放在[]中，多个元素用,进行分隔，可以使用for循环对列表元素进行遍历，也可以使用[]或[:]运算符取出列表中的一个或多个元素

2. 定义列表 和遍历列表
    ```python

    list1 = [1, 3, 5, 7, 100]
    print(list1) # [1, 3, 5, 7, 100]
    # 乘号表示列表元素的重复
    list2 = ['hello'] * 3
    print(list2) # ['hello', 'hello', 'hello']
    # 计算列表长度(元素个数)
    print(len(list1)) # 5
    # 下标(索引)运算
    print(list1[0]) # 1
    print(list1[4]) # 100
    # print(list1[5])  # IndexError: list index out of range
    print(list1[-1]) # 100
    print(list1[-3]) # 5
    list1[2] = 300
    print(list1) # [1, 3, 300, 7, 100]
    # 通过循环用下标遍历列表元素
    for index in range(len(list1)):
        print(list1[index])
    # 通过for循环遍历列表元素
    for elem in list1:
        print(elem)
    # 通过enumerate函数处理列表之后再遍历可以同时获得元素索引和值
    for index, elem in enumerate(list1):
        print(index, elem)
    ```

3. 列表中添加或移除元素
    ```python
    list1 = [1, 3, 5, 7, 100]
    # 添加元素
    list1.append(200)
    list1.insert(1, 400)
    # 合并两个列表
    # list1.extend([1000, 2000])
    list1 += [1000, 2000]
    print(list1) # [1, 400, 3, 5, 7, 100, 200, 1000, 2000]
    print(len(list1)) # 9
    # 先通过成员运算判断元素是否在列表中，如果存在就删除该元素
    if 3 in list1:
        list1.remove(3)
    if 1234 in list1:
        list1.remove(1234)
    print(list1) # [1, 400, 5, 7, 100, 200, 1000, 2000]
    # 从指定的位置删除元素
    list1.pop(0)
    list1.pop(len(list1) - 1)
    print(list1) # [400, 5, 7, 100, 200, 1000]
    # 清空列表元素
    list1.clear()
    print(list1) # []
    ```
4. 切片操作
    ```python
    fruits = ['grape', 'apple', 'strawberry', 'waxberry']
    fruits += ['pitaya', 'pear', 'mango']
    # 列表切片
    fruits2 = fruits[1:4]
    print(fruits2) # apple strawberry waxberry
    # 可以通过完整切片操作来复制列表
    fruits3 = fruits[:]
    print(fruits3) # ['grape', 'apple', 'strawberry', 'waxberry', 'pitaya', 'pear', 'mango']
    fruits4 = fruits[-3:-1]
    print(fruits4) # ['pitaya', 'pear']
    # 可以通过反向切片操作来获得倒转后的列表的拷贝
    fruits5 = fruits[::-1]
    print(fruits5) # ['mango', 'pear', 'pitaya', 'waxberry', 'strawberry', 'apple', 'grape']
    ```
5. 排序操作
    ```python
    list1 = ['orange', 'apple', 'zoo', 'internationalization', 'blueberry']
    list2 = sorted(list1)
    # sorted函数返回列表排序后的拷贝不会修改传入的列表
    # 函数的设计就应该像sorted函数一样尽可能不产生副作用
    list3 = sorted(list1, reverse=True)
    # 通过key关键字参数指定根据字符串长度进行排序而不是默认的字母表顺序
    list4 = sorted(list1, key=len)
    print(list1)
    print(list2)
    print(list3)
    print(list4)
    # 给列表对象发出排序消息直接在列表对象上进行排序
    list1.sort(reverse=True)
    print(list1)
    ```
   
#### 元组（tuple） ####  
1. 一种有序列表叫元组：tuple。tuple和list非常类似，但是tuple一旦初始化就不能修改
2. Python在显示只有1个元素的tuple时，也会加一个逗号,以免误解成数学计算意义上的括号 `t = (1,)`

#### 字典值（dict） ####
1. Python内置了字典：dict的支持，dict全称dictionary，类似与java语言中的 `map`，使用键-值（key-value）存储，具有极快的查找速度
  - 定义 ：`d = {'Michael': 95, 'Bob': 75, 'Tracy': 85}`  
  - 取value值：
    ```python
    d['Michael']  # 值不存在，抛出异常
    d.get('Michael') #值不存在，返回None
    d.pop('Michael') #获取值后，会删除dic 的值
    ```
2. dict 的特点(相对与list):  
  查找和插入的速度极快，不会随着key的增加而变慢；  
  需要占用大量的内存，内存浪费多。  
  **而list相反**：  
  查找和插入的时间随着元素的增加而增加；  
  占用空间小，浪费内存很少。

#### set ####
1. set和dict类似，也是一组key的集合，但不存储value。由于key不能重复，所以，在set中，没有重复的key。
2. 要创建一个set，需要提供一个list作为输入集合 `s = set([1, 2, 3])`
3. 添加元素 `add(key)`
4. 删除元素 `remove(key)`

#### 生成式 和生成器

1. 生成式 生成器使用
    ```python
    import sys
    f = [x for x in range(1, 10)]
    print(f)
    f = [x + y for x in 'ABCDE' for y in '1234567']
    print(f)
    # 用列表的生成表达式语法创建列表容器
    # 用这种语法创建列表之后元素已经准备就绪所以需要耗费较多的内存空间
    f = [x ** 2 for x in range(1, 1000)]
    print(sys.getsizeof(f))  # 查看对象占用内存的字节数
    print(f)
    # 请注意下面的代码创建的不是一个列表而是一个生成器对象
    # 通过生成器可以获取到数据但它不占用额外的空间存储数据
    # 每次需要数据的时候就通过内部的运算得到数据(需要花费额外的时间)
    f = (x ** 2 for x in range(1, 1000))
    print(sys.getsizeof(f))  # 相比生成式生成器不占用存储数据的空间
    print(f)
    for val in f:
        print(val)
    ```
 #### 迭代 迭代器 生成器
 
 1. 迭代
 
 2. 迭代器
 
 3. 生成器
 
  - yield 语法
    - 如果一个函数定义中包含 yield 表达式，那么该函数是一个生成器函数（而非普通函数）
    - 实际上 yield 只能用于定义生成器 函数
    - 生成器函数被调用后，其函数体内的代码并不会立即执行，而是返回一个生成器（generator-iterator）。当返回的生成器调用成员方法时，相应的生成器函数中的代码才会执行
    - 每次从暂停恢复时，生成器函数的内部变量、指令指针、内部求值栈等内容和暂停时完全一致。
    - 调用带有yield 的函数，不会立即执行函数，而是返回一个 iterable 对象
    
    > 一个带有 yield 的函数就是一个 generator，它和普通函数不同，生成一个 generator 看起来像函数调用，但不会执行任何函数代码，直到对其调用 next()（在 for 循环中会自动调用 next()）才开始执行。虽然执行流程仍按函数的流程执行，但每执行到一个 yield 语句就会中断，并返回一个迭代值，下次执行时从 yield 的下一个语句继续执行。看起来就好像一个函数在正常执行的过程中被 yield 中断了数次，每次中断都会通过 yield 返回当前的迭代值。
  
  - yield from 
    - yield from iterable 本质上就是一个简短的形式：for item in iterable: yield item

#### 元组

1. 元组的操作
    ```python
    # 定义元组
    t = ('骆昊', 38, True, '四川成都')
    print(t)
    # 获取元组中的元素
    print(t[0])
    print(t[3])
    # 遍历元组中的值
    for member in t:
        print(member)
    # 重新给元组赋值
    # t[0] = '王大锤'  # TypeError
    # 变量t重新引用了新的元组原来的元组将被垃圾回收
    t = ('王大锤', 20, True, '云南昆明')
    print(t)
    # 将元组转换成列表
    person = list(t)
    print(person)
    # 列表是可以修改它的元素的
    person[0] = '李小龙'
    person[1] = 25
    print(person)
    # 将列表转换成元组
    fruits_list = ['apple', 'banana', 'orange']
    fruits_tuple = tuple(fruits_list)
    print(fruits_tuple)
    ```
2. 说明：
    - 元组中的元素是无法修改的：
        * 如果不需要对元素进行添加、删除、修改的时候，可以考虑使用元组，
        * 如果一个方法要返回多个值，使用元组也是不错的选择。
    - 元组在创建时间和占用的空间上面都优于列表：我们可以使用sys模块的getsizeof函数来检查存储同样的元素的元组和列表各自占用了多少内存空间

#### 集合

集合跟数学上的集合是一致的，不允许有重复元素，而且可以进行交集、并集、差集等运算

1. 集合创建和使用
    ```python

    # 创建集合的字面量语法
    set1 = {1, 2, 3, 3, 3, 2}
    print(set1)
    print('Length =', len(set1))
    # 创建集合的构造器语法(面向对象部分会进行详细讲解)
    set2 = set(range(1, 10))
    set3 = set((1, 2, 3, 3, 2, 1))
    print(set2, set3)
    # 创建集合的推导式语法(推导式也可以用于推导集合)
    set4 = {num for num in range(1, 100) if num % 3 == 0 or num % 5 == 0}
    print(set4)
    ```
2. 集合添加和删除元素
    ```python
    set1.add(4)
    set1.add(5)
    set2.update([11, 12])
    set2.discard(5)
    if 4 in set2:
        set2.remove(4)
    print(set1, set2)
    print(set3.pop())
    print(set3)
    ```
3. 集合 交集、并集、差集等运算
    ```python
    # 集合的交集、并集、差集、对称差运算
    print(set1 & set2)
    # print(set1.intersection(set2))
    print(set1 | set2)
    # print(set1.union(set2))
    print(set1 - set2)
    # print(set1.difference(set2))
    print(set1 ^ set2)
    # print(set1.symmetric_difference(set2))
    # 判断子集和超集
    print(set2 <= set1)
    # print(set2.issubset(set1))
    print(set3 <= set1)
    # print(set3.issubset(set1))
    print(set1 >= set2)
    # print(set1.issuperset(set2))
    print(set1 >= set3)
    # print(set1.issuperset(set3))
    ````

#### 字典
字典是另一种可变容器模型，Python中的字典跟我们生活中使用的字典是一样一样的，它可以存储任意类型对象，与列表、集合不同的是，字典的每个元素都是由一个键和一个值组成的“键值对”，键和值通过冒号分开

1. 字典使用    
    ```python
    # 创建字典的字面量语法
    scores = {'骆昊': 95, '白元芳': 78, '狄仁杰': 82}
    print(scores)
    # 创建字典的构造器语法
    items1 = dict(one=1, two=2, three=3, four=4)
    # 通过zip函数将两个序列压成字典
    items2 = dict(zip(['a', 'b', 'c'], '123'))
    # 创建字典的推导式语法
    items3 = {num: num ** 2 for num in range(1, 10)}
    print(items1, items2, items3)
    # 通过键可以获取字典中对应的值
    print(scores['骆昊'])
    print(scores['狄仁杰'])
    # 对字典中所有键值对进行遍历
    for key in scores:
        print(f'{key}: {scores[key]}')
    # 更新字典中的元素
    scores['白元芳'] = 65
    scores['诸葛王朗'] = 71
    scores.update(冷面=67, 方启鹤=85)
    print(scores)
    if '武则天' in scores:
        print(scores['武则天'])
    print(scores.get('武则天'))
    # get方法也是通过键获取对应的值但是可以设置默认值
    print(scores.get('武则天', 60))
    # 删除字典中的元素
    print(scores.popitem())
    print(scores.popitem())
    print(scores.pop('骆昊', 100))
    # 清空字典
    scores.clear()
    print(scores)
    ```

#### 面向对象

1. 类的定义:
    ```python
    class student(object):
        # __init__是一个特殊方法用于在创建对象时进行初始化操作
        # 通过这个方法我们可以为学生对象绑定name和age两个属性
        def __init__(self, name, message):
            self.name = name
            self.message = message

        def study(self, course_name):
                print('%s正在学习%s.' % (self.name, course_name))

        # PEP 8要求标识符的名字用全小写多个单词用下划线连接
        # 但是部分程序员和公司更倾向于使用驼峰命名法(驼峰标识)
        def watch_movie(self):
            if self.age < 18:
                print('%s只能观看《熊出没》.' % self.name)
            else:
                print('%s正在观看岛国爱情大电影.' % self.name)
    ```

2. 对象的创建 和使用
    ```python
    def main():
        # 创建学生对象并指定姓名和年龄
        stu1 = Student('骆昊', 38)
        # 给对象发study消息
        stu1.study('Python程序设计')
        # 给对象发watch_av消息
        stu1.watch_movie()
        stu2 = Student('王大锤', 15)
        stu2.study('思想品德')
        stu2.watch_movie()


    if __name__ == '__main__':
        main()
    ```
3. 访问可见性问题
    - 私有属性:用两个下滑线开头(实例的变量名如果以__开头，就变成了一个私有变量（private），只有内部可以访问，外部不能访问)
    ```python
    class Student(object):

        def __init__(self, name, score):
            self.__name = name
            self.__score = score

        def print_score(self):
            print('%s: %s' % (self.__name, self.__score))
    ```

   > 注:实例变量.__name和实例变量.__score 外部无法访问

   - 一个下划线开头的实例变量名: `_name`    
        > 实例变量外部是可以访问的，但是，按照约定俗成的规定，当你看到这样的变量时，意思就是，“虽然我可以被访问，但是，请把我视为私有变量，不要随意访问”                                                                                                                                                                                                                                                                                                                                               
        > 不能直接访问__name是因为Python解释器对外把__name变量改成了_Student__name，所以，仍然可以通过_Student__name来访问__name变量

4. 继承 和多态
    - 继承写法 `class Dog(Animal):` 其中Animal 为父类
    - 判断一个变量是否是某个类型可以用 `isinstance()` 判断: eg: `isinstance(a, list)`

5. 获取对象信息
    - 判断对象类型:
        - 使用 `type()`
            eg : `type(fn)==types.FunctionType`
        - 使用 `isinstance()` (总是优先使用isinstance()判断类型，可以将指定类型及其子类“一网打尽”。)
            eg: `isinstance(h, Object)` `isinstance([1, 2, 3], (list, tuple))`
         - 使用 `dir()` (获得一个对象的所有属性和方法)   
            eg:
            ```python
            dir('ABC')
             # ['__add__', '__class__',..., '__subclasshook__', 'capitalize', 'casefold',..., 'zfill']
            ```
            > 类似__xxx__的属性和方法在Python中都是有特殊用途                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
            > 如果你调用len()函数试图获取一个对象的长度，实际上，在len()函数内部，它自动去调用该对象的__len__()方法                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
            > `len('ABC')` 和  `'ABC'.__len__()`  等价                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 

6. 实例属性和类属性
   - 实例属性属于各个实例所有，互不干扰；

   - 类属性属于类所有，所有实例共享一个属性；

   - 不要对实例属性和类属性使用相同的名字，否则将产生难以发现的错误                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
#### 面向对象高级特性

1. 使用 `__slots__` 限制实例的属性
    eg : 只允许 Student 添加 `name` 和 `age` 属性
    ```python
    class Student(object):
        __slots__ = ('name', 'age') # 用tuple定义允许绑定的属性名称
    ```
2. 使用 `@Property` 装饰器就是负责把一个方法变成属性调用的
    ```python
    class Student(object):

        @property
        def score(self):
            return self._score

        @score.setter
        def score(self, value):
            if not isinstance(value, int):
                raise ValueError('score must be an integer!')
            if value < 0 or value > 100:
                raise ValueError('score must between 0 ~ 100!')
            self._score = value

   if __name__ =="__main__":
       s = Student()
       s.score = 60 # OK，实际转化为s.set_score(60)
       s.score # OK，实际转化为s.get_score()
   ```

3. 多重继承
    - MixIn就是一种常见的设计
    ```python
    # 为了更好地看出继承关系，我们把Runnable和Flyable改为RunnableMixIn和FlyableMixIn
    class Dog(Mammal, RunnableMixIn, CarnivorousMixIn):
        pass
    ```
4. 定制类
    - `__sorts__ `： 初始化属性
    - `__len__()` 求长度
    - ` __str__` : 返回一个定制化的String
    - `__repr__()` ：返回程序调用的字符串 --> 和 `__str__` 两者的区别是__str__()返回用户看到的字符串，而__repr__()返回程序开发者看到的字符串，也就是说，__repr__()是为调试服务的
    - `__iter__` `__next__`  : 如果一个类想被用于for ... in循环，类似list或tuple那样，就必须实现一个__iter__()方法，该方法返回一个迭代对象，然后，Python的for循环就会不断调用该迭代对象的__next__()方法拿到循环的下一个值，直到遇到StopIteration错误时退出循环
        ```python
        class Fib(object):
            def __init__(self):
                self.a, self.b = 0, 1 # 初始化两个计数器a，b

            def __iter__(self):
                return self # 实例本身就是迭代对象，故返回自己

            def __next__(self):
                self.a, self.b = self.b, self.a + self.b # 计算下一个值
                if self.a > 100000: # 退出循环的条件
                    raise StopIteration()
                return self.a # 返回下一个值
        ```
    - `__getitem__` : 把对象看成 `list` 或者 `dic`来获取值 依据参数获取属性值
        ```python
        class Fib(object):
            def __getitem__(self, n):
                  # _getitem__()传入的参数可能是一个int，也可能是一个切片对象slice，所以要做判断
                if isinstance(n, int): # n是索引
                    a, b = 1, 1
                    for x in range(n):
                        a, b = b, a + b
                    return a
                if isinstance(n, slice): # n是切片
                    start = n.start
                    stop = n.stop
                    if start is None:
                        start = 0
                    a, b = 1, 1
                    L = []
                    for x in range(stop):
                        if x >= start:
                            L.append(a)
                        a, b = b, a + b
                    return L
        ```
    - `__setitem__()` 方法，把对象视作list、tuple 或dict来对集合赋值
    - `__delitem__()` 删除值

    - `__getattr__` 动态返回属性
        ```python
        class Student(object):

            def __init__(self):
                self.name = 'Michael'

            def __getattr__(self, attr):
                if attr=='score':
                    return 99
        ```
    - `__call__` 只需要定义一个__call__()方法，就可以直接对实例进行调用
        ```python
        class Student(object):
            def __init__(self, name):
                self.name = name

            def __call__(self):
                print('My name is %s.' % self.name)
        ```
        注：
            * `__call__()` 还可以定义参数
            * 通过callable()函数，我们就可以判断一个对象是否是“可调用”对象 eg：`callable(Student())`

#### 枚举类
1. eg：
    ```python
    from enum import Enum
    # alue属性则是自动赋给成员的int常量，默认从1开始计数
    Month = Enum('Month', ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))
    ```    
2. 如果需要更精确地控制枚举类型，可以从Enum派生出自定义类
    ```python
    from enum import Enum, unique
    # @unique装饰器可以帮助我们检查保证没有重复值
    @unique
    class Weekday(Enum):
        Sun = 0 # Sun的value被设定为0
        Mon = 1
        Tue = 2
        Wed = 3
        Thu = 4
        Fri = 5
        Sat = 6
    ```
3. 枚举类的访问
     ```python
    day1 = Weekday.Mon
    Weekday['Tue']
    Weekday.Tue.value
    Weekday(1)
   ```

#### 元类使用

动态语言和静态语言最大的不同，就是函数和类的定义，不是编译时定义的，而是运行时动态创建的。

- `type()`
    - type()函数可以查看一个类型或变量的类型

    - type()函数既可以返回一个对象的类型，又可以创建出新的类型
        eg:我们可以通过type()函数创建出Hello类，而无需通过class Hello(object)...的定义：
        ```python
        def fn(self, name='world'):
           print('Hello, %s.' % name)

        Hello = type('Hello', (object,), dict(hello=fn)) # 创建Hello class
        ```
    - 要创建一个class对象，type()函数依次传入3个参数：
       * class的名称；
       * 继承的父类集合，注意Python支持多重继承，如果只有一个父类，别忘了tuple的单元素写法；
       * class的方法名称与函数绑定，这里我们把函数fn绑定到方法名hello上。  

- metaclass
    - metaclass，直译为元类，简单的解释就是:
        - 当我们定义了类以后，就可以根据这个类创建出实例，所以：先定义类，然后创建实例。
        - 但是如果我们想创建出类呢？那就必须根据metaclass创建出类，所以：先定义metaclass，然后创建类。
        - 连接起来就是：先定义metaclass，就可以创建类，最后创建实例。
        - metaclass允许你创建类或者修改类。换句话说，你可以把类看成是metaclass创建出来的“实例”
    - eg:
        ```python
        # metaclass是类的模板，所以必须从`type`类型派生：
        class ListMetaclass(type):
            def __new__(cls, name, bases, attrs):
                attrs['add'] = lambda self, value: self.append(value)
                return type.__new__(cls, name, bases, attrs)
        ```  
    - Python解释器在创建MyList时:
        ```python
        ListMetaclass.__new__()
        ```
    - `__new__()` 方法接收到的参数依次是：

      * 当前准备创建的类的对象；

      * 类的名字；

      * 类继承的父类集合；

      * 类的方法集合。

### 模块、包

- 在python 中，一个 .py 文件就是一个模块module
    - 自己创建的模块，不能和python自带的模块冲突，否则，无法导入系统自带的模块。
- python又引入了按目录来组织模块的方法，称为包（Package）（文件夹）
    - 每一个包目录下面都会有一个`__init__.py`的文件，这个文件是必须存在的，否则，Python就把这个目录当成普通目录，而不是一个包。
    
#### 模块使用：

##### 模块作用域
- 私有的 `private`：_xxx和__xxx这样的函数或变量就是非公开的（private），不应该被直接引用，比如_abc，__abc等

##### 第三方模块：
- sys 模块
    - sys模块有一个argv变量，用list存储了命令行的所有参数。argv至少有一个元素，因为第一个参数永远是该.py文件的名称
    