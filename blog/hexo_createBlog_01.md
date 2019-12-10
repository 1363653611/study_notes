---
title: Hexo博客新建文章并发布
date: 2019-12-05 13:14:10
tags:
 - hexo
 - yilia
categories:
 - hexo
top: 1
topdeclare: true
reward: true
---

### 基于Hexo+Github 搭建个人博客

#### node.js
<!--more-->
##### 环境安装
1. [下载地址](https://nodejs.org/zh-cn/download/) :https://nodejs.org/zh-cn/download/
  - 这里选择 `windows64位.msi`格式安装包
2. 安装 hexo `npm i -g hexo-cli`

#### 安装 `yilia` 主题的坑
1. 头像设置
  - 在 `source\assets\image` 添加图片
  - 在 `themes\yilia\_config.yml` 配置头像 和favicon：
  ```yml
  favicon: /zbcn.github.io/assets/image/favicon.ico
  #你的头像url
  avatar: /zbcn.github.io/assets/image/head.jpg
  ```
  __notify:__ 根目录下的url 配置为博客地址:https://1363653611.github.io/zbcn.github.io, 要配置 `zbcn.github.io`,否则会引发一堆问题

2. 点击 所有文章/友联/关于我 出现 `habout:blank#blocked`页面
  - 解决方案:
    1. 找到 `themes\yilia\layout\_partial\left-col.ejs` 文件
    2. 找到 `<nav class="header-smart-menu">` 标签
    3. 个里面的a标签，加上一个 `target="_parent"` 标签,修改后的标签是
    ```html
    <nav class="header-smart-menu">
    		<% for (var i in theme.smart_menu){ %>
    			<% if(theme.smart_menu[i]){ %>
    			<a q-on="click: openSlider(e, '<%-i%>')" href="javascript:void(0)" target="_parent"><%= theme.smart_menu[i] %></a>
    			<% } %>
            <%}%>
		</nav>
    ```
3. ~添加 访问量统计1~(效果不是很好)

  - 添加本站总访问量(引入不蒜子):(pv的方式，单个用户连续点击n篇文章，记录n次访问量。)
  在 `themes/yilia/layout/_partial/footer.ejs` 的末尾 添加
  ```js
    <script async src="//dn-lbstatics.qbox.me/busuanzi/2.3/busuanzi.pure.mini.js"></script>
    <span id="busuanzi_container_site_pv">
        本站总访问量<span id="busuanzi_value_site_pv"></span>次
    </span>
  ```

  - 本站访客数:
  ```js
  //uv的方式，单个用户连续点击n篇文章，只记录1次访客数。  
  <span id="busuanzi_container_site_uv">
    本站访客数<span id="busuanzi_value_site_uv"></span>人次
  </span>
  ```

   在 `themes/yilia/layout/_partial/article.ejs`下添加
    ```js

    <% if (!index){ %>
      <span id="busuanzi_container_page_pv">
        ⋉(●本文总阅读量 <span id="busuanzi_value_page_pv"></span> 次●)⋊
      </span>
    <% } %>
    ```
4. 访问量统计2:

__网站访问量显示：__
  - 我使用了不蒜子第三方的统计插件，网址：http://ibruce.info/2015/04/04/busuanzi/
  - 在`themes\yilia\layout\_partial`下的footer.ejs中加入如下代码即可
  ```js
  <script async src="//dn-lbstatics.qbox.me/busuanzi/2.3/busuanzi.pure.mini.js">
  </script>
  <span id="busuanzi_container_site_pv">
    本站总访问量<span id="busuanzi_value_site_pv"></span>次
  </span>
  <span id="busuanzi_container_site_uv">
  总访客数<span id="busuanzi_value_site_uv"></span>人次
  </span>
  ```
__实现单篇文章浏览统计和评论统计__
  - 评论数的统计是__网易云跟帖__中获取的，下面给出
  - 修改`themes\yilia\layout\_partial`文件夹下的article.ejs文件
  - 在`<%- partial('post/title', {class_name: 'article-title'}) %>`节点下加入：
    - 注意这里网易云跟帖还没设置，而评论数中使用到了，这里运行会有问题，下面给出
    ```js
    <!-- 显示阅读和评论数 -->
      <% if (!index && post.comments && config.wangYi){ %>
      <br/>
      <a class="cloud-tie-join-count" href="javascript:void(0);"target="_parent" style="color:gray;font-size:14px;">
      <span class="icon-sort"></span>
      <span id="busuanzi_container_page_pv" style="color:#ef7522;font-size:14px;">
                阅读数: <span id="busuanzi_value_page_pv"></span>次 &nbsp;&nbsp;
      </span>
      </a>
      <a class="cloud-tie-join-count" href="javascript:void(0);" target="_parent" style="color:#ef7522;font-size:14px;">
      	<span class="icon-comment"></span>
      	<span class="join-text" style="color:#ef7522;font-size:14px;">评论数:</span>
      	<span class="join-count">0</span>次
      </a>
      <% } %>
    ```
#### 实现网易云跟帖评论
- 注册账号：https://gentie.163.com/info.html

#### 配置置顶文章
- 安装插件
```lunix
npm uninstall hexo-generator-index --save
npm install hexo-generator-index-pin-top --save
```
- 配置置顶标准
  - 打开：`/themes/*/layout（/_macro）/post.ejs`
  - 直接在最前面加入以下代码即可
  ```lunix
  <% if (page.top) { %>
    <i class="fa fa-thumb-tack"></i>
    <font color=7D26CD>置顶</font>
    <span class="post-meta-divider">|</span>
  <% } %>
  ```
- 配置文章  
  然后在需要置顶的文章的Front-matter中加上top选项即可  
  top后面的数字越大，优先级越高
```
title: 2019
date: 2019-02-14 16:10:03
top: 5
```
- 优先级配置
  修改根目录配置文件`/_config.yml`,top值-1标示根据top值倒序（正序设置为1即可），同样date也是根据创建日期倒序。

#### Hexo 实现私密文章加密
```
cd /Hexo
npm install hexo-blog-encrypt

vim /Hexo/_config.yml  添加如下内容

# Security
## 文章加密 hexo-blog-encrypt
encrypt:
    enable: true

然后在想加密的文章头部添加上对应字段，如

---
title: hello world
date: 2016-03-30 21:18:02   
tags:       
password: 12345   （密码）
abstract: Welcome to my blog, enter password to read.
message: Welcome to my blog, enter password to read.     
---

password: 是该博客加密使用的密码
abstract: 是该博客的摘要，会显示在博客的列表页
message: 这个是博客查看时，密码输入框上面的描述性文字
```

#### 增加版权声明
- 配置yilia
  - 位置 `themes/yilia/layout/_partial/article.ejs
`
  - 中标注的位置添加代码
  ```html
    <div class="article-entry" itemprop="articleBody">
    <% if (post.excerpt && index){ %>
      <%- post.excerpt %>
      <% if (theme.excerpt_link) { %>
        <a class="article-more-a" href="<%- url_for(post.path) %>#more"><%= theme.excerpt_link %> >></a>
      <% } %>
    <% } else { %>
      <%- post.content %>
    <% } %>
    <-- 在此处添加代码-->
    <% if ((theme.reward_type === 2 || (theme.reward_type === 1 && post.reward)) && !index){ %>
    <div class="page-reward">
      <a href="javascript:;" class="page-reward-btn tooltip-top">
      <div class="tooltip tooltip-east">
  ```
  - 添加的代码如下

  ```html
  <!-- 增加版权声明 -->
  <%
    var sUrl = url.replace(/index\.html$/, '');
    sUrl = /^(http:|https:)\/\//.test(sUrl) ? sUrl : 'https:' + sUrl;
  %>
  <% if ((theme.declare_type === 2 || (theme.declare_type === 1 && post.declare)) && !index){ %>
    <div class="declare">
      <strong>本文作者：</strong>
      <% if(config.author != undefined){ %>
        <%= config.author%>
      <% }else{%>
        <font color="red">请在博客根目录“_config.yml”中填入正确的“author”</font>
      <%}%>
      <br>
      <strong>本文链接：</strong>
      <a rel="license" href="<%=sUrl%>"><%=sUrl%></a>
      <br>
      <strong>版权声明：</strong>
      本作品采用
      <a rel="license" href="<%= theme.licensee_url%>"><%= theme.licensee_name%></a>
      进行许可。转载请注明出处！
      <% if(theme.licensee_img != undefined){ %>
        <br>
        <a rel="license" href="<%= theme.licensee_url%>"><img alt="知识共享许可协议" style="border-width:0" src="<%= theme.licensee_img%>"/></a>
      <% } %>
    </div>
  <% } else {%>
    <div class="declare" hidden="hidden"></div>
  <% } %>
  ```

  - 创建新文件 `themes/yilia/source-src/css/declare.scss
`
  - 并添加如下CSS代码。
  ```css
  .declare {
    background-color: #eaeaea;
    margin-top: 2em;
    border-left: 3px solid #ff1700;
    padding: .5em 1em;
  }
  ```

  - 为 `themes/yilia/source-src/css/main.scss` 添加 `@import "./declare";`
- 配置显示
 - 修改为 `themes/yilia/_config.yml`
 添加:
 ```
  版权基础设定：0-关闭声明； 1-文章对应的md文件里有declare: true属性，才有版权声明； 2-所有文章均有版权声明
  #当前应用的版权协议地址。
  #版权协议的名称
  #版权协议的Logo
  declare_type: 1
  licensee_url: https://creativecommons.org/licenses/by-nc-sa/4.0/
  licensee_name: '知识共享署名-非商业性使用-相同方式共享 4.0 国际许可协议'
  licensee_img: https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png
 ```
 - 然后在需要进行版权声明的文章的md文件头部，设置属性 `declare:true`

#### 在左侧显示总文章数
将`themes\yilia\layout_partial\left-col.ejs`文中的
```
<nav class="header-menu">
    <ul>
    <% for (var i in theme.menu){ %>
        <li><a href="<%- url_for(theme.menu[i]) %>"><%= i %></a></li>
    <%}%>
    </ul>
</nav>
```
后面加上
```
<nav>
    总文章数 <%=site.posts.length%>
</nav>
```

#### 文章顶部转载说明
- 配置yilia主题文件
在 `themes/yilia/layout/_partial/article.ejs`中下面标注的位置添加代码
`<% if (!post.noDate){ %>
        <%- partial('post/date', {class_name: 'archive-article-date', date_format: null}) %>
        <% } %>
      </header>
    <% } %>
    <div class="article-entry" itemprop="articleBody">
    <!--在这里添加新代码-->
```
添加的代码如下  
```html
      <!-- 文章头增加转载声明 -->
      <%
        var sUrl = url.replace(/index\.html$/, '');
        sUrl = /^(http:|https:)\/\//.test(sUrl) ? sUrl : 'https:' + sUrl;
      %>
      <% if ((theme.topdeclare_type === 2 || (theme.topdeclare_type === 1 && post.topdeclare)) && !index){ %>
        <div class="topdeclare">
           <hr>
          <strong>如需转载，请根据</strong>
          <a rel="license" href="<%= theme.toplicensee_url%>"><%= theme.toplicensee_name%></a>
          许可，附上本文作者及链接。
          <br>
          <strong>本文作者：</strong>
          <% if(config.author != undefined){ %>
            <%= config.author%>
          <% }else{%>
            <font color="red">请在博客根目录“_config.yml”中填入正确的“author”</font>
          <%}%>
          <br>
          <strong>作者昵称：</strong>
          <% if(theme.topnickname!= undefined){ %>
            <%= theme.topnickname%>
          <% }else{%>
            <font color="red">请在博客主题目录“_config.yml”中填入正确的“昵称”</font>
          <%}%>
          <br>
          <strong>本文链接：</strong>
          <a rel="license" href="<%=sUrl%>"><%=sUrl%></a>
          <br>
          <hr>
        </div>
      <% } else {%>
        <div class="topdeclare" hidden="hidden"></div>
      <% } %>
      <!-- 文章头增加转载声明结束 -->
```  
创建新文件`themes/yilia/source-src/css/topdeclare.scss`
并添加如下CSS代码。
```css
.declare {
    background-color: #eaeaea;
    margin-top: 2em;
    border-left: 3px solid #ff1700;
    padding: .5em 1em;
}
```  

为`themes/yilia/source-src/css/main.scss` 添加如下代码：`@import "./topdeclare";`

然后在需要进行版权声明的文章的md文件头部，设置属性 `topdeclare:true`

- 配置显示    
修改 `themes/yilia/_config.yml`在里面加入：
```yaml
#顶部版权基础设定：0-关闭声明； 1-文章对应的md文件里有topdeclare: true属性，才有版权声明； 2-所有文章均有版权声明
#当前应用的版权协议地址。
#昵称
#版权协议的名称
topdeclare_type: 1
toplicensee_url: https://creativecommons.org/licenses/by-nc-sa/4.0/
topnickname: 莫与 #你的昵称
toplicensee_name: '知识共享署名-非商业性使用-相同方式共享 4.0 国际许可协议'
```
然后在需要进行版权声明的文章的md文件头部，设置属性 `topdeclare:true`

#### 分类的构建
- 添加categories链接
打开`yilia/_config.yml`文件，menu处做出以下修改
```yaml
menu:
  主页: /
  分类: /categories
  归档: /archives
```
- 分类页面的构建
根目录执行 `hexo new page categories`  
该命令在source目录下生成一个categories目录，categories目录下有一个index.md文件。
- 修改categories/index.md为：
```
title: 文章分类
date: 2018-06-11 10:13:21
type: "categories"
layout: "categories"
comments: false
```
- 修改 yilia 主题
修改`yilia\source\main.0cf68a.css`，将下面的内容添加进去：
```css
category-all-page {
    margin: 30px 40px 30px 40px;
    position: relative;
    min-height: 70vh;
  }
  .category-all-page h2 {
    margin: 20px 0;
  }
  .category-all-page .category-all-title {
    text-align: center;
  }
  .category-all-page .category-all {
    margin-top: 20px;
  }
  .category-all-page .category-list {
    margin: 0;
    padding: 0;
    list-style: none;
  }
  .category-all-page .category-list-item-list-item {
    margin: 10px 15px;
  }
  .category-all-page .category-list-item-list-count {
    color: $grey;
  }
  .category-all-page .category-list-item-list-count:before {
    display: inline;
    content: " (";
  }
  .category-all-page .category-list-item-list-count:after {
    display: inline;
    content: ") ";
  }
  .category-all-page .category-list-item {
    margin: 10px 10px;
  }
  .category-all-page .category-list-count {
    color: $grey;
  }
  .category-all-page .category-list-count:before {
    display: inline;
    content: " (";
  }
  .category-all-page .category-list-count:after {
    display: inline;
    content: ") ";
  }
  .category-all-page .category-list-child {
    padding-left: 10px;
  }
```
- 多层分类
新建`yilia/layout/categories.ejs`，输入
```js
<article class="article article-type-post show">
  <header class="article-header" style="border-bottom: 1px solid #ccc">
  <h1 class="article-title" itemprop="name">
    <%= page.title %>
  </h1>
  </header>

  <% if (site.categories.length){ %>
  <div class="category-all-page">
    <h2>共计&nbsp;<%= site.categories.length %>&nbsp;个分类</h2>
    <%- list_categories(site.categories, {
      show_count: true,
      class: 'category-list-item',
      style: 'list',
      depth:3,    #这里代表着几层分类
      separator: ''
    }) %>
  </div>
  <% } %>
</article>

```

- 修改自己的文章
```
itle: HTML入门笔记

copyright: true
date: 2018-11-23 21:07:15

toc: true
tags: [HTML,前端]
categories: [前端,HTML]
```

#### yilia 主题 翻页报错

原因是 :`themes\yilia\layout\_partial\archive.ejs` 多出了`&laquo;` 和 `&raquo;`  
解决方案,是在分页的地方删除以上两个标签,如下:
  ```js
  //修改前
  <% if (page.total > 1){ %>
   <nav id="page-nav">
     <%- paginator({
       prev_text: '&laquo; Prev',
       next_text: 'Next &raquo;'
     }) %>
   </nav>
 <% } %>
 // 修改后
 <% if (page.total > 1){ %>
  <nav id="page-nav">
    <%- paginator({
      prev_text: 'Prev',
      next_text: 'Next'
    }) %>
  </nav>
<% } %>
 ...
 //修改前
 <% if (page.total > 1){ %>
   <nav id="page-nav">
     <%- paginator({
       prev_text: '&laquo; Prev',
       next_text: 'Next &raquo;'
     }) %>
   </nav>
 <% } %>
 //修改后
 <% if (page.total > 1){ %>
   <nav id="page-nav">
     <%- paginator({
       prev_text: 'Prev',
       next_text: 'Next'
     }) %>
   </nav>
 <% } %>

  ```
