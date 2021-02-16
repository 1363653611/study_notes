---
title: interview 面试
date: 2021-02-16 13:14:10
tags:
 - interview
categories:
 - interview
topdeclare: true
reward: true
---

# java

## String，StringBuffer和StringBuilder之间的区别是什么

1. 可变性：String是一个不可变类，任何对String改变都是会产生一个新的String对象，所以String类是使用final来进行修饰的。而StringBuffer和StringBuilder是可变类，对应的字符串的改变不会产生新的对象。
2. 执行效率

当频繁对字符串进行修改时，使用String会生成一些临时对象，多一些附加操作，执行效率降低。

```java
//在对stringA进行修改时，实际上是先根据字符串创建一个StringBuffer对象，然后调用append()方法对字符串修改，再调用toString()返回一个字符串。
stringA = StringA + "2";
//实际上等价于
{
  StringBuffer buffer = new StringBuffer(stringA)
  buffer.append("2");
  return buffer.toString();
}
```

3. 线程安全

StringBuffer的读写方法都使用了synchronized修饰，同一时间只有一个线程进行操作，所以是线程安全的，而StringBuilder不是线程安全的。

## Integer类会进行缓存吗

```java
Intger a =  new Integer(127);
Intger b = Interger.valueOf(127);
Intger c = Interger.valueOf(127);
Intger d = Interger.valueOf(128);
Intger e = Interger.valueOf(128);
System.out.println(a == b); //输出false
System.out.println(b == c); //输出true
System.out.println(d == e); //输出false
```

**NOTE**:

1. 通过new Interger()创建Interger对象，每次返回全新的Integer对象
2. 通过Interger.valueOf()创建Interger对象，如果值在-128到127之间，会返回缓存的对象(初始化时)。

### 实现原理

Integer类中有一个静态内部类IntegerCach，在加载Integer类时会同时加载IntegerCache类，IntegerCache类的静态代码块中会创建值为-128到127的Integer对象，缓存到cache数组中，之后调用Integer#valueOf方法时，判断使用有缓存的Integer对象，有则返回，无则调用new Integer()创建。

PS: (127是默认的边界值，也可以通过设置JVM参数java.lang.Integer.IntegerCache.high来进行自定义。）

```java
public static Integer valueOf(int i) {
    if (i >= IntegerCache.low && i <= IntegerCache.high)
    		//cache是一个Integer数组，缓存了-128到127的Integer对象
        return IntegerCache.cache[i + (-IntegerCache.low)];
		return new Integer(i);
}
//IntegerCache是Integer类中的静态内部类，Integer类在加载时会同时加载IntegerCache类，IntegerCache类的静态代码块中会
private static class IntegerCache {
        static final int low = -128;
        static final int high;
        static final Integer cache[];

        static {
            // 127是默认的边界值，也可以通过设置JVM参数java.lang.Integer.IntegerCache.high来进行自定义。
            int h = 127;
            String integerCacheHighPropValue =            sun.misc.VM.getSavedProperty("java.lang.Integer.IntegerCache.high");
            if (integerCacheHighPropValue != null) {
                try {
                    int i = parseInt(integerCacheHighPropValue);
                    i = Math.max(i, 127);
                    // cache数组的长度不能超过Integer.MAX_VALUE
                    h = Math.min(i, Integer.MAX_VALUE - (-low) -1);
                } catch( NumberFormatException nfe) {
                    // If the property cannot be parsed into an int, ignore it.
                }
            }
            high = h;

            cache = new Integer[(high - low) + 1];
            int j = low;
            for(int k = 0; k < cache.length; k++)
                cache[k] = new Integer(j++);
          
            // high值必须大于等于127，不然会抛出异常
            assert IntegerCache.high >= 127;
        }

        private IntegerCache() {}
    }
```

