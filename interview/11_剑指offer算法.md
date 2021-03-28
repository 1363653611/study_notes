# 数组

# 字符串

## 把字符串中的每个空格都替换成 "%20" 

eg: we are happy   --> we%20are%20happy

### 时间为 O(n) 的解法

```java
public class StringDemo_02 {

    public static void main(String[] args) {
        String str = "we are happy";
        String replacer = "%20";
        //String s = replaceFunc(str, replacer);
        String s = replaceFunc2(str, replacer);
        System.out.println(s);
    }

    private static String replaceFunc(String str, String replacer) {
        if(StringUtils.isBlank(str)){
            return str;
        }
        //计算需要修改空格的次数
        char[] chars = str.toCharArray();
        int length = chars.length;
        int times = 0;
        for (int i = 0; i < length; i++){
            char c = chars[i];
            if(c == ' '){
                times++;
            }
        }
        if(times == 0){
            return str;
        }
        char[] replacers = replacer.toCharArray();
        char[] dest = new char[length + times*2];
        int pos = 0;
        for (int i = 0; i < chars.length; i++){
            char c = chars[i];
            if (c == ' '){
                dest[pos] = replacers[0];
                dest[++pos]= replacers[1];
                dest[++pos] = replacers[2];
            }else{
                //先使用后指针后移动
                dest[pos++] = chars[i];
            }
        }
        return new String(dest);
    }


    private static String replaceFunc2(String str, String replacer){
        if(StringUtils.isBlank(str)){
            return str;
        }
        //计算需要修改空格的次数
        char[] chars = str.toCharArray();
        int length = chars.length;
        int times = 0;
        for (int i = 0; i < length; i++){
            char c = chars[i];
            if(c == ' '){
                times++;
            }
        }
        if(times == 0){
            return str;
        }
        char[] newChars = new char[length + times*2];
        int firstPos = length-1;
        int secondPos = length-1 + times*2;
        //secondPos == firstPos 时，说明没有空格了
        while(firstPos >= 0){
            char c = chars[firstPos];
            if(c != ' '){
                newChars[secondPos--] = c;
            }else{
                newChars[secondPos] = '%';
                newChars[--secondPos] = '2';
                newChars[--secondPos] = '0';
            }
            firstPos--;
        }
        return new String(newChars);
    }
}
```

# 链表

- 链表是一种动态的数据结构，其操作就是对指针进行操作。而且链表的数据结构很灵活。
- 链表是一种动态的数据结构，创建时无需知道链表的长度。当插入一个节点时，我们只需要为新创建的节点分配内存，然后调节指针的指向来确保新节点被链接到链表中。
- 链表的内存是新添加节点时才分配，所以没有空闲的内存，因此链表的空间利用率比数组高。

## 示例代码

- 链表节点

```java
/**
* 链表节点信息
*/
@Data
static class LinkNode {
    int val;
    LinkNode next;
    public LinkNode(int val) {
        this.val = val;
    }
}
```

- 添加链表节点

  ```java
  /**
       * 添加节点
       * @param head
       * @param value
       * @return
       */
  public static LinkNode addNode(LinkNode head, int value){
      //创建新节点
      LinkNode newNode = new LinkNode(value);
      //如果头节点为空 则新节点赋值给头结点
      if(head == null){
          head = newNode;
      }else{
          //添加到节点的尾部
          while (head.next == null){
              head.next = newNode;
          }
      }
      return head;
  }
  ```

  - 移除节点

  ```java
  /**
       * 移除给定值相同的节点
       * @param head
       * @param value
       * @return
       */
      public static LinkNode removeNode(LinkNode head, int value){
          //如果链表为空
          if(head == null){
              return null;
          }
          //如果头结点就是 需要移动的节点
          LinkNode preNode = head;
          LinkNode des = head.next;
          while (des != null){
              if(preNode.val == value){ //如果为头节点,则需要改动一下头节点的指向
                  preNode = des;
                  des = des.next;
                  head = preNode;
              } else if (des.val == value){ //中间节点中找到了需要删除的内容
                  des = des.next;
                  preNode.next = des;
              }else{ //未找到节点
                  preNode = des;
                  des = des.next;
              }
          }
          return head;
      }
  
      private static LinkNode remove2(LinkNode head, int value){
          //如果头节点是需要删除的节点
          while(head != null){
              if(head.val != value){
                  break;
              }
              head = head.next;
          }
          //如果为非头节点
          //前趋节点
          LinkNode preNode = head;
          LinkNode currNode = head.next;
          while (currNode != null){
              if (currNode.val == value){
                  preNode.next = currNode.next;
              }else{
                  preNode = currNode;
              }
              currNode = currNode.next;
          }
          return head;
      }
  
      //fixme: 空间复杂度太大了
      public static LinkNode removeNodeUseStack(LinkNode head, int value){
          //如果链表为空
          if(head == null){
              return null;
          }
          Stack<LinkNode> stack = new Stack<>();
          LinkNode cur = head;
          while (cur != null){
              if(cur.val != value){
                  stack.push(cur);
              }
              cur = cur.next;
          }
          // 重新组装数据
          // 尾节点为 null, 第一次循环式, 上一次循环已经将 cur 置为 null了
          while (!stack.isEmpty()){
              stack.peek().next = cur;
              cur = stack.pop();
          }
          return cur;
      }
  ```

  

- 遍历节点(从尾到头打印链表)

输入一个链表的头节点,然后从尾部到头部打印每个节点的值

```java
 /**
     * 反转链表打印
     * @param head
     */
    private static void reversePrint(LinkNode head){
        //反转链表 打印
        if (head == null){
            return;
        }
        //反转链表
        LinkNode des = null;
        LinkNode cur = head;
        while (cur != null){
            //cur 的后继节点,接下来需要遍历的节点
            LinkNode temp = cur.next;
            // 当前节点cur 的后继节点 指向 前一次遍历时存储的节点des(第一次时,des = null)
            cur.next = des;
            // 位置交换完毕,将 des 节点指向 当前节点 cur
            des = cur;
            // 让当前节点指向之前保存的临时节点(下一次遍历的起始位置)
            cur = temp;
        }
        //循环打印
        while (des != null){
            System.out.println("-->" + des.val);
            des = des.next;
        }
    }

    /**
     * 用栈的方式打印
     * @param head
     */
    private static void printUseStack(LinkNode head){
        Stack<Integer> stack = new Stack<>();
        //将数据压入栈中
        while (head != null){
            stack.push(head.val);
            head = head.next;
        }
        //循环打印栈中的数据
        while (!stack.isEmpty()) {
            System.out.println("---->" + stack.pop());
        }
    }

    /**
     * 使用递归的方式打印
     * @param head
     */
    private static void printUseRecursion(LinkNode head){
        if(head== null){
            System.out.println("空的链表....");
        }
        if (head.next != null){ //递归
            printUseRecursion(head.next);
        }
        System.out.println("---->" + head.val);
    }
```

# 树

除了根节点外,每个节点都有一个父节点(跟节点没有父亲节点),除了叶子节点外,每个节点有一个或者多个子节点(叶子节点没有子节点)

## 二叉树

遍历方式:

- 前序遍历: root --> left --> right
- 中序遍历: left --> root --> right
- 后续遍历: left --> right --> root

没用遍历的实现,递归要比循环简单的多.

- 深度优先遍历
- 宽度优先遍历

## 二叉搜索树

- 左子树的节点总是小于或者等于根节点,右子树总是大于等于跟节点
- 我们一般可以平均在 o(logn)的时间范围内在二叉搜索树中找到目标节点.

二叉树的另外两个特里时: **堆** 和 **红黑树**

### 红黑树

### 堆

- 最大堆:跟节点值最大
- 最小堆: 跟节点值最小