---
title: Hexo博客添加 评论
date: 2020-05-10 13:14:10
tags:
 - hexo
 - yilia
categories:
 - hexo
#top: 1
topdeclare: true
reward: true
---

最近打算给博客添加评论功能，看了下市面上一些评论插件，觉得gitment和Valine这两款插件比较符合我的要求：轻量而且配置简单。
不过gitment只支持github账号评论，虽然也没啥人看我博客，不过权衡了下，还是决定用Valine。

<!--more -->

## 我hexo博客主题用的是yilia，看了下_config.yml配置文件，发现它竟默认支持gitment，为了也能使用valine，只能魔改源码了。

1. 修改yilia主题下的_config.yml文件，添加valine配置
```yml
# valine配置
valine_appid: '填写leancloud的appid'
valine_appkey: '填写leancloud的appkey'
```
2. 修改layout/_partial/article.ejs，添加一段代码
```js
<% if (!index){ %>
    <% if (theme.valine && theme.valine.appid && theme.valine.appkey){ %>
        <section id="comments" class="comments">
          <style>
            .comments{margin:30px;padding:10px;background:#fff}
            @media screen and (max-width:800px){.comments{margin:auto;padding:10px;background:#fff}}
          </style>
          <%- partial('post/valine', {
            key: post.slug,
            title: post.title,
            url: config.url+url_for(post.path)
            }) %>
      </section>
    <% } %>
<% } %>
```
3. __新增__ layout/_partial/post/valine.ejs
```js
<div id="comment"></div>
<script src='//unpkg.com/valine/dist/Valine.min.js'></script>
<script>
new Valine({
    el: '#comment' ,
    notify:false, 
    verify:false, 
    appId: '<%=theme.valine_appid%>',
    appKey: '<%=theme.valine_appkey%>',
    placeholder: 'ヾﾉ≧∀≦)o欢迎评论!',
    path:window.location.pathname, 
    avatar:'mm' 
});
</script>
```

大功搞成了.

### 转:
- 改文章生成的评论在首页面会显示评论框: http://anata.me/2018/04/05/hexo%E4%B8%BB%E9%A2%98yilia%E6%B7%BB%E5%8A%A0valine%E8%AF%84%E8%AE%BA%E7%B3%BB%E7%BB%9F/

- 这个没问题: https://mxy493.xyz/2019/01/28/Hexo%E5%8D%9A%E5%AE%A2%EF%BC%88%E4%B8%BB%E9%A2%98%EF%BC%9Ayilia%EF%BC%89%E6%B7%BB%E5%8A%A0Valine%E8%AF%84%E8%AE%BA%E7%B3%BB%E7%BB%9F/