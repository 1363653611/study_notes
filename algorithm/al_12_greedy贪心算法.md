# 贪心算法实例

**问题**：假设有 可容纳 100 kg  物品的背包， 可以装以下 5种豆子，每种豆子的重量和价值个不相同，为了让背包中的物品总价值最大，我们应该在背包中装那种豆子，美中豆子又该装多少呢？

**解决问题思路**：

1. 套用贪心算法问题模型。针对一组数据，事先定义了限制值和期望值。希望选出几组数据，在满足限制的情况下，期望值最大。
   1. 限制：装在背包中的豆子不能超过 100 kg
   2. 期望： 在背包中的豆子的总价值。
   3. 总结：从现有的豆子中，选出一部分豆子，在重量不超过 100 kg 的情况下，价值最大
2. 尝试用贪心算法解决问题。每次选择对限制值同等贡献量的情况下，对期望值贡献最大的数据。
   1. 每次从剩下的豆子中选择单价最高的，也就是重量相同的情况下，对价值贡献最大的豆子
3. 举例验证算法是否正确。（大部分情况下只需举例验证一下算法能否得到最优解就ok 了）

## 贪心算法实例1: 分糖果

有 m 个糖果分给 n 个孩子吃。但是糖果少，孩子多（m < n）,所以糖果只能分给一部分孩子。每个糖果的大小是不等的，这 m 个糖果 的大小是： S1，S2，S3 .... Sm. 	每个孩子对糖果的需求也不一样。只有糖果的大小大于或者等于孩子的需求时，孩子才能得到满足。 假设 n 个孩子对糖果的需求分别是：g1,g2,g3....gn. 那么如何分配糖果才能满足绝大部分孩子呢。

** 分析：**

1. 问题的限制值：糖果的个数 m。
2. 我们从对糖果需求更小的孩子分配糖果。原因：对于一个孩子，如果小的糖果可以满足。那么就没必要分配大的糖果。这样更大的糖果就可以留给对其他对糖果需求更大的孩子。另外，满足一个对糖果需求大的孩子和满足一个对糖果需求小的孩子，对期望值的贡献是一样的。
3. 每次从剩下的孩子中，找出对糖果需求最小的孩子。然后从剩下的糖果中发给他能满足他的最小糖果。

## 贪心算法实例2:最短服务时间

假设n 个人等待被服务，但是服务窗口只有一个。每个人被服务的时间长度是不同的，如何安排被服务的先后顺序，才能让这 n 个人的总等待时间最短。

问题解决： 选择耗时最小的人有限被服务

## 贪心算法实例3: 区间覆盖

假设有n 个区间，分别是[l1,r1],[l2,r2],[l3,r3],......[ln,rn]. 从这 n 个区间中选出 某些区间，要求这些区间满足两两不相交【端点相交的情况不算相交】，最多能选出多少个区间呢？

**问题解决思路**： 

1. n 个区间 的最左侧端点 是 lmin, 最右侧端点是 rmax。 这个问题就相当于 选择几个不相交的区间，从左侧到右侧 [lmin, r max] 覆盖。
2. 我们按照右端点从小到大的顺序对这 n 个区间排序。
3. 每次选择左侧端点与前面的已经覆盖的区间不重合而右侧端点又尽量小的区间，这样可以让剩下的未覆盖的区间尽可能大，这样可以放置更多的区间。

```java
public class T22_Greedy {


    public List<Interval> findMaxNumIntervals(List<Interval> intervals){

        List<Interval> result = Lists.newArrayList();
        // 将集合 按照 right 边界 从小到大排序
        Collections.sort(intervals);
        // 已经覆盖的右侧端点
        int coveredIntervalRight = 0;
        for (int i= 0; i < intervals.size(); i++ ){
            Interval interval = intervals.get(i);
            if (coveredIntervalRight <= interval.left){
                result.add(interval);
                coveredIntervalRight = interval.right;
            }
        }
        return result;
    }


    public static class Interval implements Comparable<Interval>{

        private int left;

        private int right;

        public Interval() {
        }

        public Interval(int left, int right) {
            this.left = left;
            this.right = right;
        }

        @Override
        public int compareTo(Interval o) {
            return this.right - o.right;
        }
    }

}
```

