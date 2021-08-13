# 经典算法

## Excel 中的 列问题

### 题目1： 在Excel中，用A表示第一列，B表示第二列...Z表示第26列，AA表示第27列，AB表示第28列...依次列推。请写出一个函数，输入用字母表示的列号编码，输出它是第几列。

考察点： 将 26进制转换为10 进制

思路：

1. 将输入的字符串转换成 字符数组
2. 遍历数组中的每一个字符，用这个字符减去A再加1就是该位对应的十进制数
3. 然后乘以26的相应次方，最后把这些数加起来就是结果了

note: 第二步 加 1 的原因：因为十进制是用0-9表示，那么二十六进制就应该用0-25表示，但是这里是A-Z，就相当于1-26，所以算出来的数需要加1。

ASCII 的基本知识点：

0：48

A：65
a：97

规律：

- 数字在前，大写字母其后，最后是小写字母。
- 小写字母与大写字母差32。

上边给出了字符'0'、'A'、'a'相对应的整型数，其余的字符按照顺序都可以算出来。

代码实现：T9_ExcelCloumn

```java
public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        while (sc.hasNext()){
            String str = sc.next();
            int res = erShiliuToDecimal(str);
            System.out.println(res);
        }
    }

    private static int erShiliuToDecimal(String str) {
        char[] chars = str.toCharArray();
        int exp = 0; // 指数
        int num = 0;
        for (int i = chars.length-1; i >= 0; i--){
            num += (chars[i] - 'A' + 1)* Math.pow(26,exp);
            exp++;
        }
        return num;
    }
```

### 题目2：在Excel中，用第一列用A表示，第二列用B表示...第26列用Z表示，第27列用AA表示，第28列用AB表示...依次列推。请写出一个函数，输入一个数表示第几列，输出用字母表示的列号编码。

思路：

1. 用输入的数字cols和26取模得到 temp，temp即为二十六进制数字的最后一位
2. 用temp + 'A' - 1即可得到所对应的A~Z中的字母
3. 用输入的数字cols除以26，用这个结果继续寻找倒数第二位所对应的字符，直到cols为0。

note：

temp=0的时候比较特殊，比如输入的数字cols=26，cols%26=0，本来应该输出Z，结果输出的是@，所以把temp=0的情况单独拿出来判断一下，当temp=0时，置temp=26，然后将cols-1，这时输入26将会得到正确答案Z。

刚才输出的结果都是从最后一位开始的，利用StringBuilder的reverse()方法将刚才得到的结果反转，返回就OK了。

代码实现：

```java
    private static String decimalToErShiliu(int cols){
        StringBuilder builder = new StringBuilder();
        while (cols != 0){
            //余数为最后一位
            int temp = cols % 26;
            //下一位
            cols = cols / 26;
            //则说明最后一位为 Z
            if (temp == 0){
                temp = 26;
                // 前一位 则 减 1
                cols --;
            }
            char result = (char) (temp + 'A' -1);
            builder.append(result);
        }
        // 因为计算是从最后一位开始的，所以要反转过来
        builder.reverse();
        return builder.toString();
    }
```

## 位运算

题目1： 输入两个整数，m 和 n, 计算改变m 的二进制中的多少位才能得到n. 比如：10 的二进制表示：1010，13 的二进制表示：1101.

解决方案：1. 求这两个数的异或， 2. 统计这两个数异或的结果中 1 的位数.

```java
public class T10_BitCalDemo {

    public static void main(String[] args) {
        int n = 10;
        int m = 13;
        int i = twoData(n, m);
        System.out.println("需要改变：" + i + " 位才能相等 ");
    }

    private static int twoData(int n, int m) {
        int xorData = n ^ m;
        return numOf1(xorData);
    }

    /**
     * 1 的个数
     * @param xorData
     */
    private static int numOf1(int xorData) {
        int count = 0;
        while (xorData != 0){
            // xorData & (xorData -1) 作用是把该整数的最右边的一个 1变成 0.
            xorData = xorData & (xorData -1);
            count ++;
        }
        return count;
    }
}
```



