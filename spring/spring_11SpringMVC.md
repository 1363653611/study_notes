---
title: Spring_11 spring MVC
date: 2020-20-21 13:33:36
tags:
  - spring
categories:
  - spring
#top: 1
topdeclare: false
reward: true
---
# spring mvc 
1. web.xml 配置说明

<!--more-->

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
         version="4.0">

    <!--1. listener 监听器-->
    <!--spring 配置文件的加载位置-->
    <!--最常用的上下文载入器是一个Servlet 监听器，其名称为ContextLoaderListener-->
    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>
     <context-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath*:/applicationContext.xml</param-value>
    </context-param>

    <!--自定义监听器监听多环境配置中激活的prifile-->
    <listener>
        <listener-class>com.zbcn.web.pub.listener.ProfileContextListener</listener-class>
    </listener>
    <!-- 多环境配置 在上下文context-param中设置profile.active的默认值 -->
    <!-- 设置active后default失效，web启动时会加载对应的环境信息 -->
    <context-param>
        <param-name>spring.profiles.active</param-name>
        <param-value>test</param-value>
    </context-param>

     <!-- logback的监听器-->
     <listener>
        <listener-class>ch.qos.logback.ext.spring.web.LogbackConfigListener</listener-class>
    </listener>
    <context-param>
        <param-name>logbackConfigLocation</param-name>
        <param-value> classpath:/logback.xml</param-value>
    </context-param>
    
    <!--2. servlet 容器-->
    <servlet>
        <servlet-name>dispatcher</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <!--配置dispatcher_servlet.xml作为mvc的配置文件-->
            <!--如果不配置该属性，则默认取 servlet-name 对应的值 如：dispatcher.xml-->
            <param-name>contextConfigLocation</param-name>
            <param-value>classpath:/dispatcher-servlet.xml</param-value>
        </init-param>
        <!--多环境支持 可选-->
        <init-param>
            <param-name>spring.profiles.default</param-name>
            <param-value>dev</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
        <!--添加异步支持：可选-->
        <async-supported>true</async-supported>
    </servlet>
    <!--映射路径-->
    <servlet-mapping>
        <servlet-name>dispatcher</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>


     <!--拦截器：字符集控制-->
    <filter>
        <filter-name>encodingFilter</filter-name>
        <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
        <init-param>
            <param-name>encoding</param-name>
            <param-value>UTF-8</param-value>
        </init-param>
        <init-param>
            <param-name>forceEncoding</param-name>
            <param-value>true</param-value>
        </init-param>
    </filter>
    <filter-mapping>
        <filter-name>encodingFilter</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>
</web-app>
```

- 映射路径  /* 和/ 的区别：
    - /* ：覆盖所有其它的servlet，不管你发出了什么样的请求，最终都会在这个servlet中结束。会匹配所有的url：路径型的和后缀型的url(包括/springmvc，.jsp，.js和*.html等)
    - /: 覆盖任何其它的servlet。它仅仅替换了servlet容器中内建的默认servlet.种形式通常只用来请求静态资源（CSS/JS/image等）和展示目录的列表.会匹配到/springmvc这样的路径型url，不会匹配到模式为*.jsp

- contextConfigLocation：Spring 的核心配置文件，
- DispatcherServlet：包含了SpringMVC 的请求逻辑， Spring 使用此类拦截Web 请求并进行相应的逻辑处理。

## ContextloaderListener 
- 当使用编程方式时，我们使用 `ApplicationContext ac = new ClassPathXmlApplicationContext(" applicationContext.xml");` 来加载spring 的容器，但是在springMvc 的web 项目下，通常是使用 context-paramd的方式注册，使用ContextloaderListener的方式监听。
```xml
    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>
     <context-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath*:/applicationContext.xml</param-value>
    </context-param>
```
- ContextloaderListener 的作用是在启动web 容器时，自动装配 ApplicationContext的信息。因为他实现了 ServletContextListener 接口，在web.xml 配置这个监昕器，启动容器时，就会默认执行它实现的方法，使用ServletContextListener 接口，开发者能够在为客户端请求提供服务之前向ServletContext 中添加任意的对象。这个对象在ServletContext 启动的时候被初始化， 然后在ServletContext  整个运行期间都是可见的。
- 每一个Web 应用都有一个ServletContext 与之相关联。ServletContext 对象在应用启动时被创建，在应用关闭的时候被销毁。ServletContext 在全局范围内有效，类似于应用中的一个全局变量。
- 在ServletContextListener 中的核心逻辑便是初始化WebApplicationContext 实例并存放至ServletContext 中。

### ServletContextlistener 的使用
- 创建自定义的 ServletContextlistener
```java
public class MyDataContextListener implements ServletContextListener {

    private ServletContext context = null;

    //该方法在ServletContext 启动之后被调用，并准备好处理客户端请求
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        this.context = sce.getServletContext();
        //可以实现自己的逻辑并将结果记录在属性中
        context.setAttribute("myData", "test ServletContextListener");
    }

    //在servlet关闭的时候调用
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        this.context = null;
    }
}
```
- web.xml 中配置监听
```xml
<!--自定义contextListener-->
    <listener>
        <listener-class>com.zbcn.web.listener.MyDataContextListener</listener-class>
    </listener>
```
- 一旦Web 应用启动的时候，我们就能在任意的S巳rvlet 或者JSP 中通过下面的方式获取我们初始化的参数，
```java
```

### Spring 中的ContextloaderListener
- ServletContext 启动之后会调用ServletContextListener 的contextlnitialized 方法，那么，我们就从这个函数开始进行分析。
```java
//ContextLoaderListener  extends ContextLoader implements ServletContextListener
@Override
public void contextInitialized(ServletContextEvent event) {
    initWebApplicationContext(event.getServletContext());
}

```
这里涉及了一个常用类WebApplicationContext ：在Web 应用中，我们会用到WebApplicationContext,继承自AplicationContext,在ApplicationContext 的基础上又追加了一些特定于Web 的操作及属性，非常类似于我们通过编程方式使用Spring 时使用的
ClassPathXmlApplicationCont巳xt 类提供的功能.
- 初始化  WebApplicationContext
```java
//ContextLoader
public WebApplicationContext initWebApplicationContext(ServletContext servletContext) {
		if (servletContext.getAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE) != null) {
            ////web.xml 中存在多次ContextLoader 定义
			throw new IllegalStateException(
					"Cannot initialize context because there is already a root application context present - " +
					"check whether you have multiple ContextLoader* definitions in your web.xml!");
		}

		Log logger = LogFactory.getLog(ContextLoader.class);
		servletContext.log("Initializing Spring root WebApplicationContext");
		if (logger.isInfoEnabled()) {
			logger.info("Root WebApplicationContext: initialization started");
		}
		long startTime = System.currentTimeMillis();

		try {
			// Store context in local instance variable, to guarantee that
			// it is available on ServletContext shutdown.
			if (this.context == null) {
                //初始化 webApplicationContext
				this.context = createWebApplicationContext(servletContext);
			}
			if (this.context instanceof ConfigurableWebApplicationContext) {
				ConfigurableWebApplicationContext cwac = (ConfigurableWebApplicationContext) this.context;
				if (!cwac.isActive()) {
					// The context has not yet been refreshed -> provide services such as
					// setting the parent context, setting the application context id, etc
					if (cwac.getParent() == null) {
						// The context instance was injected without an explicit parent ->
						// determine parent for root web application context, if any.
						ApplicationContext parent = loadParentContext(servletContext);
						cwac.setParent(parent);
					}
					configureAndRefreshWebApplicationContext(cwac, servletContext);
				}
			}
            //将WebApplicationContext记录在 servletContext中
			servletContext.setAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE, this.context);

			ClassLoader ccl = Thread.currentThread().getContextClassLoader();
			if (ccl == ContextLoader.class.getClassLoader()) {
				currentContext = this.context;
			}
			else if (ccl != null) {
				currentContextPerThread.put(ccl, this.context);
			}

			if (logger.isDebugEnabled()) {
				logger.debug("Published root WebApplicationContext as ServletContext attribute with name [" +
						WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE + "]");
			}
			if (logger.isInfoEnabled()) {
				long elapsedTime = System.currentTimeMillis() - startTime;
				logger.info("Root WebApplicationContext: initialization completed in " + elapsedTime + " ms");
			}

			return this.context;
		}
		catch (RuntimeException ex) {
			logger.error("Context initialization failed", ex);
			servletContext.setAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE, ex);
			throw ex;
		}
		catch (Error err) {
			logger.error("Context initialization failed", err);
			servletContext.setAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE, err);
			throw err;
		}
	}
 ```
__大体步骤__:

- WebApplicationContext 存在性的验证:在配置中只允许声明一次ServletContextListener ， 多次声明会扰乱Spring 的执行逻辑,所以这里首先做的就是对此验证，在Spring 中如果创建WebApplicationContext 实例会记录在ServletContext 中以方便全局调用，而使用的key 就是 `WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRBUTE`
- 创建WebApplicationContext 实例。
```java
//ContextLoader
protected WebApplicationContext createWebApplicationContext(ServletContext sc) {
    //获取applicationContext 容器创建所需要的class
    Class<?> contextClass = determineContextClass(sc);
    if (!ConfigurableWebApplicationContext.class.isAssignableFrom(contextClass)) {
        throw new ApplicationContextException("Custom context class [" + contextClass.getName() +
                "] is not of type [" + ConfigurableWebApplicationContext.class.getName() + "]");
    }
    return (ConfigurableWebApplicationContext) BeanUtils.instantiateClass(contextClass);
}
        ```   
在ContextLoader 类中有这样的静态代码块
```java
//ContextLoader
private static final Properties defaultStrategies;
static {
    // Load default strategy implementations from properties file.
    // This is currently strictly internal and not meant to be customized
    // by application developers.
    try {
        ClassPathResource resource = new ClassPathResource(DEFAULT_STRATEGIES_PATH, ContextLoader.class);
        defaultStrategies = PropertiesLoaderUtils.loadProperties(resource);
    }
    catch (IOException ex) {
        throw new IllegalStateException("Could not load 'ContextLoader.properties': " + ex.getMessage());
    }
}
``` 
根据以上静态代码块的内容，我们推断在当前类ContextLoader 同样目录下必定会存在属性文件ContextLoader.properties ，在初始化的过程中，程序首先会读取ContextLoader 类的同目录下的属性文件ContextLoader.properties ，并根据其中的配置提取将要实现WebApplicationContext 接口的实现类，并根据这个实现类通过反射的方式进行实例的创建。

- 将实例记录在servletContext 中。
- 映射当前的类加载器与创建的实例到全局变量currentContextPerThread 中

## DispatcherServlet
spring  MVC 真正的实现逻辑是 dispatcherServlet. DispactherServlet 是 实现 Servlet 接口的实现类.

servlet 是一个java 编写的程序,此程序是基于http协议的,在服务器端运行的(如:tomcat). 是按照servlet 规范编写的一个java 类,主要是处理客户端的请求并将其结果发送到客户端. servlet 的生命周期是按照servlet 容器来控制的,分为三个阶段:初始化,运行,销毁

- 初始化阶段
    1. servlet 容器加载servlet 类，把servlet 类的.class 文件中的数据读到内存中。
    2. servlet 容器创建一个ServletConfig 对象。ServletConfig 对象包含了servlet 的初始化配置信息。
    3. servlet 容器创建一个servlet 对象。
    4. servlet 容器调用servlet 对象的init 方法进行初始化。
- 运行阶段
    > 当servlet 容器接收到一个请求时， servlet 容器会针对这个请求创建servletRequest 和servletResponse 对象,然后调用servic巳方法.并把这两个参数传递给service 方法。service 方法通过servletRequest 对象获得请求的信息。并处理该请求。再通过servletResponse 对象生成这个请求的响应结果。然后销毁servletRequest 和servletResponse 对象。不管这个请求是post 提交的还是get 提交的，最终这个请求都会由service 方法来处理。

- 销毁阶段
    > 当web 容器被终止时，selvet 容器首先会调用 sevlet 的destory 方法，然后再销毁 sevlet 容器，同时销毁sevletConfig对象。可以在 sevlet 的destory 方法中，释放sevlet容器占用的资源。 如关闭数据库链接，关闭文件输入输出流等。

    > sevlet 的框架是由两个java 组成：javax.sevlet 和java.sevlet.http.
    javax.sevlet 包中定义了所有的sevlet 都必须实现或者扩展的通用接口和类。
    > javax.servlet.http 包中定义了采用http通信协议的HttpServlet类。

    > servlet 被设计成请求驱动， servlet 的请求可能包含多个数据项,当Web 容器接收到某个servlet 请求时， servlet 把请求封装成一个HttServletRequest 对象.然后把对象传给servlet 的对应的服务方法。

    > HTTP 的请求方式包括delete 、get 、options 、post 、put 和trace ，在HttpServlet 类中分别提
供了相应的服务方法，它们是doDelete()、doGet() 、doOptions() 、doPost() 、doPut()和 doTrace() 。

### servlet 的使用
1. 建立servlet
```java
public MyServlet extends HttpServlet{
    //初始化方法
    public void init();
    public void doGet(HttpServletRequest request, HttpServletResponse response) {
        handleLogic ( request , response);
    }
    public void doPost(HttpServletRequest request, HttpServletResponse response) {
        handleLogic(request , response );
    }

    //处理逻辑的核心方法
    public void handleLogic();
｝
```
  - init 方法保证在Servlet加载的时候能做一些逻辑操作
  - 而HttpServlet 类则会帮助我们根据方法类型的不同而将逻辑引人不同的函数
  - 子类中我们只需要重写对应的函数逻辑便可： 如handleLogic方法。

2. 添加配置
```xml
<servlet>
    <servlet-name>myservlet</servlet-name>
    <servlet-class>test.servlet.MyServlet</servlet- class>
    <load-on-startup>l</load-on-startup>
</servlet>
<servlet- mapping>
    <servlet-name>myservlet</servlet-name>
    <url-pattern ＞*.htm</url-pattern>
</servlet-mapping>
```

### DispatcherServlet 的初始化
对于 DispatcherServlet， 在其父类 HttpServletBean 中重写了 Servlet 的init 方法。
```java
//HttpServletBean extends HttpServlet implements EnvironmentCapable, EnvironmentAware
@Override
	public final void init() throws ServletException {
        //解析init-param 并且填充到pvs中
		// Set bean properties from init parameters.
		PropertyValues pvs = new ServletConfigPropertyValues(getServletConfig(), this.requiredProperties);
		if (!pvs.isEmpty()) {
			try {
                //将当前的servlet 转换为一个beanWrapper，从而能够已spring的方式来对init-param 的值进行处理。
				BeanWrapper bw = PropertyAccessorFactory.forBeanPropertyAccess(this);
				ResourceLoader resourceLoader = new ServletContextResourceLoader(getServletContext());
                //注册自定义属性编辑器，一旦遇到Resource 类型的属性将会使用ResourceEditor进行解析
				bw.registerCustomEditor(Resource.class, new ResourceEditor(resourceLoader, getEnvironment()));
				//空实现， 留给子类覆盖
                initBeanWrapper(bw);
				bw.setPropertyValues(pvs, true);
			}
			catch (BeansException ex) {
				if (logger.isErrorEnabled()) {
					logger.error("Failed to set bean properties on servlet '" + getServletName() + "'", ex);
				}
				throw ex;
			}
		}
		// Let subclasses do whatever initialization they like.
		initServletBean();

		if (logger.isDebugEnabled()) {
			logger.debug("Servlet '" + getServletName() + "' configured successfully");
		}
	}
```
- spring的 DispartcherServlet的初始化主要是将servlet 类型的实例转换为BeanWarpper 类型，以便于spring 提供的注入功能对属性值进行注入，如：contextAttribute 、contextClass 、nameSpace 、contextConfigLocation 等，都可以在web.xml 文件中以初始化参数的方
式配置在servlet 的声明中。
- DisPatcherServlet 继承自FrameWorkServlet.Frameworkservlet 类上包含对应的同名属性， Spring 会保证这些参数被注入到对应的值中。

#### 属性注入主要包含以下几个步骤。
1. 封装及验证初始化参数
ServletConfigPropertyValues 除了封装属性外还有对属性验证的功能。
```java
//ServletConfigPropertyValues
public ServletConfigPropertyValues(ServletConfig config, Set<String> requiredProperties)
				throws ServletException {

			Set<String> missingProps = (!CollectionUtils.isEmpty(requiredProperties) ?
					new HashSet<String>(requiredProperties) : null);
			Enumeration<String> paramNames = config.getInitParameterNames();
			while (paramNames.hasMoreElements()) {
				String property = paramNames.nextElement();
				Object value = config.getInitParameter(property);
				addPropertyValue(new PropertyValue(property, value));
				if (missingProps != null) {
					missingProps.remove(property);
				}
			}
			// Fail if we are still missing properties.
			if (!CollectionUtils.isEmpty(missingProps)) {
				throw new ServletException(
						"Initialization from ServletConfig for servlet '" + config.getServletName() +
						"' failed; the following required properties were missing: " +
						StringUtils.collectionToDelimitedString(missingProps, ", "));
			}
		}
	}
```
从代码中得知，封装属性主要是对初始化的参数进行封装，也就是servlet 中配置的<init-param> 中配置的封装.当然，用户可以通过对requiredProperties 参数的初始化来强制验证某些属性的必要性.这样，在属性封装的过程中，一旦检测到requiredProperties 中的属性没有指定初始值，就会抛出异常。

2. 将当前servlet 实例转化成BeanWrapper 实例
PropertyAccessorFactory.forBeanPropertyAccess 是spring中提供的一个工具方法，用于将指定实例转换为spring可以处理的beanWrapper 实例。

3. 注册相对于Resource 的属性编辑器  
属性编辑器，我们在上文中已经介绍并且分析过其原理， 这里使用属性编辑器的目的是在对当前实例（ DispatcherServlet ）属性注入过程中一旦遇到Resource 类型的属性就会使用ResourceEditor 去解析。

4. 属性注入  
BeanWrapper 为Spring 中的方法， 支持Spring 的自动注入。其实我们最常用的属性注入无非是contextAttribute、contextClass 、nameSpace 、contextConfigLocation 等。

5. servletBean 的初始化
在ContextLoaderListener 加载的时候已经创建了WebApplicationContext 实例，而在这个函数中最重要的就是对这个实例进行进一步的补充初始化。继续查看initServletBean()方法 。父类FrameworkServlet 覆盖了HttpServletBean 中的initServletBean函数：
```java
//FrameworkServlet
protected final void initServletBean() throws ServletException {
		getServletContext().log("Initializing Spring FrameworkServlet '" + getServletName() + "'");
		if (this.logger.isInfoEnabled()) {
			this.logger.info("FrameworkServlet '" + getServletName() + "': initialization started");
		}
		long startTime = System.currentTimeMillis();

		try {
			this.webApplicationContext = initWebApplicationContext();
            //设计为子类覆盖
			initFrameworkServlet();
		}
		catch (ServletException ex) {
			this.logger.error("Context initialization failed", ex);
			throw ex;
		}
		catch (RuntimeException ex) {
			this.logger.error("Context initialization failed", ex);
			throw ex;
		}
		if (this.logger.isInfoEnabled()) {
			long elapsedTime = System.currentTimeMillis() - startTime;
			this.logger.info("FrameworkServlet '" + getServletName() + "': initialization completed in " +
					elapsedTime + " ms");
		}
	}
```
关键逻辑是WebApplicationContext 的初始化，initWebApplicationContext()

### WebApplicationContext 的初始化
initWebApplicationContext() 的主要逻辑就是 初始化WebApplicationContext，核心工作是创建或者刷新 WebApplicationContext实例，并对servlet功能所使用的变量进行进初始化。
```java
//FrameworkServlet
protected WebApplicationContext initWebApplicationContext() {
		WebApplicationContext rootContext =
				WebApplicationContextUtils.getWebApplicationContext(getServletContext());
		WebApplicationContext wac = null;

		if (this.webApplicationContext != null) {
			// A context instance was injected at construction time -> use it
			wac = this.webApplicationContext;
			if (wac instanceof ConfigurableWebApplicationContext) {
				ConfigurableWebApplicationContext cwac = (ConfigurableWebApplicationContext) wac;
				if (!cwac.isActive()) {
					// The context has not yet been refreshed -> provide services such as
					// setting the parent context, setting the application context id, etc
					if (cwac.getParent() == null) {
						// The context instance was injected without an explicit parent -> set
						// the root application context (if any; may be null) as the parent
						cwac.setParent(rootContext);
					}
                    //刷新上下文环境
					configureAndRefreshWebApplicationContext(cwac);
				}
			}
		}
		if (wac == null) {
			// No context instance was injected at construction time -> see if one
			// has been registered in the servlet context. If one exists, it is assumed
			// that the parent context (if any) has already been set and that the
			// user has performed any initialization such as setting the context id
            //根据contextAttribute 属性加载WebApplicationContext
			wac = findWebApplicationContext();
		}
		if (wac == null) {
			// No context instance is defined for this servlet -> create a local one
			wac = createWebApplicationContext(rootContext);
		}
		if (!this.refreshEventReceived) {
			// Either the context is not a ConfigurableApplicationContext with refresh
			// support or the context injected at construction time had already been
			// refreshed -> trigger initial onRefresh manually here.
			onRefresh(wac);
		}
		if (this.publishContext) {
			// Publish the context as a servlet context attribute.
			String attrName = getServletContextAttributeName();
			getServletContext().setAttribute(attrName, wac);
			if (this.logger.isDebugEnabled()) {
				this.logger.debug("Published WebApplicationContext of servlet '" + getServletName() +
						"' as ServletContext attribute with name [" + attrName + "]");
			}
		}

		return wac;
	}
```

#### 寻找或创建对应的WebApplicationContext 实例
1. 通过构造函数的注入进行初始化
> 在Web 中包含SpringWeb 的核心逻辑的 DispatcherServlet 只可以被声明为一次，在Spring 中已经存在验证，所以这就确保了如果this.webApplicationContext !=null ，则可以直接判定this.webApplicationContext 已经通过构造函数初始化。

2. 通过contextAttribute 进行初始化。
> 通过在web.xml 文件中配置的servlet 参数contextAttribute 来查找ServletContext 中对应的属性，默认为`WebApplicationContext.class.getName()+".ROOT"`，也就是在ContextLoaderListener加载时会创建WebApplicationContext 实例.并将实例以 `WebApplicationContext.class.getName()+". ROOT"` 为key 放入ServletContext 中.当然我们可以重写初始化逻辑使用自己创建的WebApplicationContext ， 并在servlet 的配置中通过初始化参数contextAttribute 指定key 。
```java
//FrameworkServlet
protected WebApplicationContext findWebApplicationContext() {
		String attrName = getContextAttribute();
		if (attrName == null) {
			return null;
		}
		WebApplicationContext wac =
				WebApplicationContextUtils.getWebApplicationContext(getServletContext(), attrName);
		if (wac == null) {
			throw new IllegalStateException("No WebApplicationContext found: initializer not registered?");
		}
		return wac;
	}
```

3. 重新创建WebApplicationContext 实例。
```java
//FrameworkServlet
protected WebApplicationContext createWebApplicationContext(ApplicationContext parent) {
        //／／获取servlet 的初始化参数contextClass ， 如果没有配置默认为XmlWebApplicationContext.class
		Class<?> contextClass = getContextClass();
		if (this.logger.isDebugEnabled()) {
			this.logger.debug("Servlet with name '" + getServletName() +
					"' will try to create custom WebApplicationContext context of class '" +
					contextClass.getName() + "'" + ", using parent context [" + parent + "]");
		}
		if (!ConfigurableWebApplicationContext.class.isAssignableFrom(contextClass)) {
			throw new ApplicationContextException(
					"Fatal initialization error in servlet with name '" + getServletName() +
					"': custom WebApplicationContext class [" + contextClass.getName() +
					"] is not of type ConfigurableWebApplicationContext");
		}
        //通过反射实例化context
		ConfigurableWebApplicationContext wac =
				(ConfigurableWebApplicationContext) BeanUtils.instantiateClass(contextClass);
        //设置环境变量
		wac.setEnvironment(getEnvironment());
        //parent 为在ContextLoaderListener 中创建的实例
        //在ContextLoaderListener 加载的时候初始化的WebApplicationContext 类型实例
		wac.setParent(parent);
        //／／获取contextConfigLocation 属性，配置在servlet 初始化参数中
		wac.setConfigLocation(getContextConfigLocation());
        //初始化Spring 环境包括加载配置文件等
		configureAndRefreshWebApplicationContext(wac);

		return wac;
	}
```
- configureAndRefreshWebApplicationContext
> 无论是通过构造函数注入还是单独创建， 都会调用configureAndRefreshWebApplicationContext方法来对已经创建的WebApplicationContext 实例进行配置及刷新，那么这个步骤又做了哪些工
作呢？
```java
protected void configureAndRefreshWebApplicationContext(ConfigurableWebApplicationContext wac) {
		if (ObjectUtils.identityToString(wac).equals(wac.getId())) {
			// The application context id is still set to its original default value
			// -> assign a more useful id based on available information
			if (this.contextId != null) {
				wac.setId(this.contextId);
			}
			else {
				// Generate default id...
				wac.setId(ConfigurableWebApplicationContext.APPLICATION_CONTEXT_ID_PREFIX +
						ObjectUtils.getDisplayString(getServletContext().getContextPath()) + '/' + getServletName());
			}
		}

		wac.setServletContext(getServletContext());
		wac.setServletConfig(getServletConfig());
		wac.setNamespace(getNamespace());
		wac.addApplicationListener(new SourceFilteringListener(wac, new ContextRefreshListener()));

		// The wac environment's #initPropertySources will be called in any case when the context
		// is refreshed; do it eagerly here to ensure servlet property sources are in place for
		// use in any post-processing or initialization that occurs below prior to #refresh
		ConfigurableEnvironment env = wac.getEnvironment();
		if (env instanceof ConfigurableWebEnvironment) {
			((ConfigurableWebEnvironment) env).initPropertySources(getServletContext(), getServletConfig());
		}

		postProcessWebApplicationContext(wac);
		applyInitializers(wac);
        //加载配置文件及整合parent 到wac
		wac.refresh();
	}
```
4.  刷新 onRefresh
> onRefresh 是FrameworkServlet 类中提供的模板方法，在其子类DispatcherServlet 中进行了重写，主要用于刷新Spring 在Web 功能实现中所必须使用的全局变量.

```java
//DispatcherServlet
@Override
	protected void onRefresh(ApplicationContext context) {
		initStrategies(context);
	}

	/**
	 * Initialize the strategy objects that this servlet uses.
	 * <p>May be overridden in subclasses in order to initialize further strategy objects.
	 */
	protected void initStrategies(ApplicationContext context) {
        //初始化MultipartResolver
		initMultipartResolver(context);
        //初始化LocaleResolver
		initLocaleResolver(context);
        //初始化ThemeResolver
		initThemeResolver(context);
        //初始化HandlerMappings
		initHandlerMappings(context);
        //初始化HandlerAdapters
		initHandlerAdapters(context);
        //初始化HandlerExceptionResolvers
		initHandlerExceptionResolvers(context);
        //初始化RequestToViewNameTranslator
		initRequestToViewNameTranslator(context);
        //初始化ViewResolvers
		initViewResolvers(context);
        //初始化FlashMapManager
		initFlashMapManager(context);
	}
```

#### 初始化MultipartResolver
在spring中multipartiResolver 主要使用来处理上传文件的。默认情况下， Spring 是没有multipart处理的，因为一些开发者想要自己处理它们。如果想使用Spring 的multipart， 则需要在Web应用的上下文中添加multipart 解析器。这样，每个请求就会被检查是否包含multipart，然而，如果请求中包含multipart ，那么上下文中定义的MultipartResolver 就会解析它。这样请求中的multipart 属性就会像其他属性一样被处理。

常用配置如下：
```xml
<!--配置文件上传相关-->
<bean id="multipartResolver" class="org.springframework.web.multipart.commons.CommonsMultipartResolver">
    <!-- 设定文件上传的最大值-->
    <property name="maxUploadSize" value="10485760"></property>
    <!-- 设定文件上传时写入内存的最大值，如果小于这个参数不会生成临时文件，默认为10240 -->
    <property name="maxInMemorySize" value="4096"></property>
    <!-- 设定默认编码 -->
    <property name="defaultEncoding" value="UTF-8"></property>
</bean>
```
当然，CommonsMultipartResolver 还提供了其他功能用于帮助用户完成上传功能,可以通过查看 CommonsMultipartResolver的属性获得。

MultipartResolver 就是在initMultipartResolv巳r 中被加入到DispatcherServlet 中的
```java
////DispatcherServlet
private void initMultipartResolver(ApplicationContext context) {
		try {
			this.multipartResolver = context.getBean(MULTIPART_RESOLVER_BEAN_NAME, MultipartResolver.class);
			if (logger.isDebugEnabled()) {
				logger.debug("Using MultipartResolver [" + this.multipartResolver + "]");
			}
		}
		catch (NoSuchBeanDefinitionException ex) {
			// Default is no multipart resolver.
			this.multipartResolver = null;
			if (logger.isDebugEnabled()) {
				logger.debug("Unable to locate MultipartResolver with name '" + MULTIPART_RESOLVER_BEAN_NAME +
						"': no multipart request handling provided");
			}
		}
	}
```
因为之前的步骤已经完成了Spring 中配置文件的解析，所以在这里只要在配置文件注册过都可以通过ApplicationContext 提供的getBean 方法来直接获取对应bean ，进而初始化MultipartResolver 中的multipartResoIver 变量.

#### 初始化LocaleResolve
在Spring 的国际化配置中一共有3 种使用方式。
- 基于URL 参数的配置
>通过URL 参数来控制国际化， 比如你在页面上加一句 `<a href="?locale=zh_CN”>`,简体中文</a>来控制项目中使用的国际化参数,而提供这个功能的就是AcceptHeaderLocaleResolver ， 默认的参数名为locale，注意大小写。里面放的就是你的提交参数，比如en_US, zh_CN 之类的，具体配置如下：
`<bean id="localeResolver" class="org.Springframework.web.servlet .il8n.AcceptHeaderLocaleResolver" />`

- 基于session 的配置。

> 它通过检验用户会话中预置的属性来解析区域.最常用的是根据用户本次会话过程中的语言设定决定语言种类（例如，用户登录时选择语言种类，则此次登录周期内统一使用此语言设
定),如果该会话属性不存在，它会根据 `accept-language HTTP` 头部确定默认区域。
`<bean id="localeResolver" class="org.Springframework.web.servlet .il8n.SessionLocaleResolver"/>`
- 基于cookie 的国际化配置
CookieLocaleResolver 用于通过浏览器的cookie 设置取得Locale 对象。这种策略在应用程序不支持会话或者状态必须保存在客户端时有用，配置如下：
`<bean id=”localeResolver" class="org.Springframework.web.servlet .il8n.CookieLocaleResol ver"/>`

这3 种方式都可以解决国际化的问题，但是， 对于LocalResolver 的使用基础是在DispatcherServlet 中的初始化。
```java
private void initLocaleResolver(ApplicationContext context) {
		try {
			this.localeResolver = context.getBean(LOCALE_RESOLVER_BEAN_NAME, LocaleResolver.class);
			if (logger.isDebugEnabled()) {
				logger.debug("Using LocaleResolver [" + this.localeResolver + "]");
			}
		}
		catch (NoSuchBeanDefinitionException ex) {
			// We need to use the default.
			this.localeResolver = getDefaultStrategy(context, LocaleResolver.class);
			if (logger.isDebugEnabled()) {
				logger.debug("Unable to locate LocaleResolver with name '" + LOCALE_RESOLVER_BEAN_NAME +
						"': using default [" + this.localeResolver + "]");
			}
		}
	}
```

#### 初始化ThemeResolver

在Web 开发中经常会遇到通过主题Theme 来控制网页风格，这将进一步改善用户体验。简单地说， 一个主题就是一组静态资源（ 比如样式表和图片）．它们可以影响应用程序的视觉效果。Spring 中的主题功能和国际化功能非常类似。Spring 主题功能的构成主要包括如下内容。

- 主题资源
`org.springframework.ui.context.ThemeSource`是Spring 中主题资源的接口， Spring 的主题需要通过 ThemeSource 接口来实现存放主题信息的资源.

`org.springframework.ui.context.support.ResourceBundleThemeSource`是ThemeSource 接口默认实现类（也就是通过 ResourceBundle 资源的方式定义主题），在Spring 中的配置如下：
```xml
<bean id="themeSource" class="org.springframework.ui.context.support.ResourceBundleThemeSource" >
    <property name= "basenamePrefix" value= "com.test.”>< lproperty>
</bean>
```
默认状态下是在类路径根目录下查找相应的资源文件， 也可以通过basenamePrefix 来制定。这样， DispatcherServlet 就会在com.test 包下查找资源文件。

- 主题解析器
ThemeSource 定义了一些主题资源，那么不同的用户使用什么主题资源由谁定义呢？
`org.springframework.web.servlet.ThemeResolver` 是主题解析器的接口， 主题解析的工作便由它的子类来完成。  
对于主题解析器的子类主要有3 个比较常用的实现。以主题文件summer.properties 为例。 

    ① FixedThemeResolver 用于选择一个固定的主题。
    ```xml 
    <bean id="themeResolver" class="org Springframework.web. servlet.theme.FixedThemeResolver” >
        <property name="defaultThemeName" value= "summer"/>
    </bean>
    ```
    以上配置的作用是设置主题文件为summer.properties ，在整个项目内固定不变。

    ② CookieThemeResolver 用于实现用户所选的主题， 以cookie 的形式存放在客户端的机器上，配置如下：
    ```xml
    <bean id= "themeResolver" class ="org.springframework.web.servlet.theme.CookieThemeResolver" >
        <property name="defaultThemeName" value="summer"/>
    </bean>
    ```
    ③ SessionThemeResolver 用于主题保存在用户的HTTP Session 中。
    ```xml
    <bean id="sessionResolver" class="org.springframework.web.servlet.theme.SessionThemeResolver">
        <property name="defaultThemeName" value="summer"/>
    </bean>
    ```
    以上配置用于设置主题名称，并且将该名称保存在用户的HttpSession 中。  
    ④ AbstractThemeResolver 是一个抽象类被SessionThemeResolver 和FixedThemeResolver继承，用户也可以继承它来自定义主题解析器。

- 拦截器
    - 如果需要根据用户请求来改变主题， 那么Spring 提供了一个已经实现的拦截器---ThemeChangeInterceptor 拦截器了，配置如下：
    ```xml
    <bean id=”themeChangeInterceptor” class="org.springframework.web.servlet.theme.ThemeChangeInterceptor">
        <property name ="paramName" value="themeName"></property>
    </bean>
    ```
    其中设置用户请求参数名为themeName ，即URL 为?themeName=具体的主题名称。此外，还需要在handlerMapping 中配置拦截器。当然需要在HandleMapping 中添加拦截器。
    ```xml
    <property name="interceptors">
        <list>
            <ref local="themeChangeinterceptor" />
        </list>
    </property>
    ```

    再来查看解析器的初始化工作，与其他变量的初始化工作相同，主题文件解析器的初始化工作并没有任何需要特别说明的地方.
    ```java
    private void initThemeResolver(ApplicationContext context) {
		try {
			this.themeResolver = context.getBean(THEME_RESOLVER_BEAN_NAME, ThemeResolver.class);
			if (logger.isDebugEnabled()) {
				logger.debug("Using ThemeResolver [" + this.themeResolver + "]");
			}
		}
		catch (NoSuchBeanDefinitionException ex) {
			// We need to use the default.
			this.themeResolver = getDefaultStrategy(context, ThemeResolver.class);
			if (logger.isDebugEnabled()) {
				logger.debug("Unable to locate ThemeResolver with name '" + THEME_RESOLVER_BEAN_NAME +
						"': using default [" + this.themeResolver + "]");
			}
		}
	}
    ```

#### 初始化HandlerMappings
> 当客户端发出Request 时DispatcherServlet 会将Request 提交给HandlerMapping ，然后HanlerMapping 根据WebApplicationContext 的配置来回传给DispatcherServlet 相应的 Controller.

> 在基于SpringMVC 的Web 应用程序中，我们可以为DispatcherServlet 提供多个HandlerMapping 供其使用.

> DispatcherServlet 在选用HandlerMapping 的过程中， 将根据我们所指定的一系列HandlerMapping 的优先级进行排序，然后优先使用优先级在前的HandlerMapping

> 如果当前的HandlerMapping 能够返回可用的Handler,DispatcherServlet 则使用当前返回的Handler进行Web 请求的处理，而不再继续询问其他的HandierMapping

> 否则， DispatcherServlet 将继续按照各个HandlerMapping 的优先级进行询问， 直到获取一个可用的Handler 为止。

初始化方法如下:
```java
private void initHandlerMappings(ApplicationContext context) {
		this.handlerMappings = null;

		if (this.detectAllHandlerMappings) {
			// Find all HandlerMappings in the ApplicationContext, including ancestor contexts.
			Map<String, HandlerMapping> matchingBeans =
					BeanFactoryUtils.beansOfTypeIncludingAncestors(context, HandlerMapping.class, true, false);
			if (!matchingBeans.isEmpty()) {
				this.handlerMappings = new ArrayList<HandlerMapping>(matchingBeans.values());
				// We keep HandlerMappings in sorted order.
				AnnotationAwareOrderComparator.sort(this.handlerMappings);
			}
		}
		else {
			try {
				HandlerMapping hm = context.getBean(HANDLER_MAPPING_BEAN_NAME, HandlerMapping.class);
				this.handlerMappings = Collections.singletonList(hm);
			}
			catch (NoSuchBeanDefinitionException ex) {
				// Ignore, we'll add a default HandlerMapping later.
			}
		}

		// Ensure we have at least one HandlerMapping, by registering
		// a default HandlerMapping if no other mappings are found.
		if (this.handlerMappings == null) {
			this.handlerMappings = getDefaultStrategies(context, HandlerMapping.class);
			if (logger.isDebugEnabled()) {
				logger.debug("No HandlerMappings found in servlet '" + getServletName() + "': using default");
			}
		}
	}
```
默认情况下， SpringMVC 将加载当前系统中所有实现了HandlerMapping 接口的bean,如果只期望SpringMVC 加载指定的handlermapping 时，可以修改web.xml 中的DispatcherServlet的初始参数，将detectAllHandlerMappings 的值设置为false :
```xml
<init-pararn>
    <pararn-narne>detectAllHandlerMappings</pararn-narne>
    <pararn-value>false</pararn-value>
</init-pararn>
```
此时， SpringMVC 将查找名为"handlerMapping"的bean ，并作为当前系统中唯一的handlermapping.如果没有定义handlerMapping 的话，则SpringMVC 将按照 `org.Springframework.web.servlet.DispatcherServlet` 所在目录下的DispatcherServlet.properties 中所定义的 `org.Springframework.web.servlet.HandlerMapping` 的内容来加载默认的handlerMapping.（用户没有自定义Strategies的情况下).

#### 初始化HandlerAdapters
从名字也能联想到这是一个典型的适配器模式的使用，在计算机编程中，适配器模式将一个类的接口适配成用户所期待的。使用适配器，可以使接口不兼容而无法在一起工作的类协同工作，做法是将类自己的接口包裹在一个己存在的类中。那么在处理handler 时为什么会使用适配器模式呢？回答这个问题我们首先要分析它的初始化逻辑
```java
private void initHandlerAdapters(ApplicationContext context) {
		this.handlerAdapters = null;

		if (this.detectAllHandlerAdapters) {
			// Find all HandlerAdapters in the ApplicationContext, including ancestor contexts.
			Map<String, HandlerAdapter> matchingBeans =
					BeanFactoryUtils.beansOfTypeIncludingAncestors(context, HandlerAdapter.class, true, false);
			if (!matchingBeans.isEmpty()) {
				this.handlerAdapters = new ArrayList<HandlerAdapter>(matchingBeans.values());
				// We keep HandlerAdapters in sorted order.
				AnnotationAwareOrderComparator.sort(this.handlerAdapters);
			}
		}
		else {
			try {
				HandlerAdapter ha = context.getBean(HANDLER_ADAPTER_BEAN_NAME, HandlerAdapter.class);
				this.handlerAdapters = Collections.singletonList(ha);
			}
			catch (NoSuchBeanDefinitionException ex) {
				// Ignore, we'll add a default HandlerAdapter later.
			}
		}

		// Ensure we have at least some HandlerAdapters, by registering
		// default HandlerAdapters if no other adapters are found.
		if (this.handlerAdapters == null) {
			this.handlerAdapters = getDefaultStrategies(context, HandlerAdapter.class);
			if (logger.isDebugEnabled()) {
				logger.debug("No HandlerAdapters found in servlet '" + getServletName() + "': using default");
			}
		}
	}
```
同样在初始化的过程中涉及了一个变量detectAllHandlerAdapters , detectAllHandlerAdapters作用和detectAllHandlerMappings 类似,只不过作用对象为handlerAdapter。亦可通过如下配置来强制系统只加载beanname 为“handlerAdapter” handlerAdapter。
```xml
<int-param>
    <param-name>detectAllHandlerAdapters</param-name>
    <param-value>false</param-value>
</init-param >
```
如果无法找到对应的bean ，那么系统会尝试加载默认的适配器。
```java
protected <T> List<T> getDefaultStrategies(ApplicationContext context, Class<T> strategyInterface) {
		String key = strategyInterface.getName();
		String value = defaultStrategies.getProperty(key);
		if (value != null) {
			String[] classNames = StringUtils.commaDelimitedListToStringArray(value);
			List<T> strategies = new ArrayList<T>(classNames.length);
			for (String className : classNames) {
				try {
					Class<?> clazz = ClassUtils.forName(className, DispatcherServlet.class.getClassLoader());
					Object strategy = createDefaultStrategy(context, clazz);
					strategies.add((T) strategy);
				}
				catch (ClassNotFoundException ex) {
					throw new BeanInitializationException(
							"Could not find DispatcherServlet's default strategy class [" + className +
									"] for interface [" + key + "]", ex);
				}
				catch (LinkageError err) {
					throw new BeanInitializationException(
							"Error loading DispatcherServlet's default strategy class [" + className +
									"] for interface [" + key + "]: problem with class file or dependent class", err);
				}
			}
			return strategies;
		}
		else {
			return new LinkedList<T>();
		}
	}
```
在getDefaultStrategies 函数中， Spring 会尝试从defaultStrategies 中加载对应的HandlerAdapter的属性，那么defaultStrategies 是如何初始化的呢?
```java
private static final Properties defaultStrategies;
static {
    // Load default strategy implementations from properties file.
    // This is currently strictly internal and not meant to be customized
    // by application developers.
    try {
        ClassPathResource resource = new ClassPathResource(DEFAULT_STRATEGIES_PATH, DispatcherServlet.class);
        defaultStrategies = PropertiesLoaderUtils.loadProperties(resource);
    }
    catch (IOException ex) {
        throw new IllegalStateException("Could not load '" + DEFAULT_STRATEGIES_PATH + "': " + ex.getMessage());
    }
}
```
在系统加载的时候， defaultStrategies 根据当前路径DispatcherServlet.properties 来初始化本身，查看DispatcherServlet. properties 中对应于HandlerAdapter 的属性：
```properties
org.springframework.web.servlet.HandlerAdapter=org.springframework.web.servlet.mvc.HttpRequestHandlerAdapter,\
	org.springframework.web.servlet.mvc.SimpleControllerHandlerAdapter,\
	org.springframework.web.servlet.mvc.annotation.AnnotationMethodHandlerAdapter
```
由此得知，如果程序开发人员没有在配置文件中定义自己的适配器，那么Spring 会默认加载配置文件中的3 个适配器。

__作为总控制器的派遣器servlet 通过处理器映射得到处理器后,会轮询处理器适配器模块，查找能够处理当前HTTP 请求的处理器适配器的实现__,处理器适配器模块根据处理器映射返回的处理器类型,例如简单的控制器类型、注解控制器类型或者远程调用处理器类型，来选择某一个适当的处理器适配器的实现，从而适配当前的HTTP 请求。

- HTTP 请求处理器适配器（ HttpRequestHandlerAdapter ）。
> HTTP 请求处理器适配器仅仅支持对HTTP 请求处理器的适配。它简单地将HTTP 请求对象和响应对象传递给HTTP 请求处理器的实现，它并不需要返回值。它主要应用在基于HTTP的远程调用的实现上。

- 简单控制器处理器适配器（ SimpleControllerHandlerAdapter ）
> 这个实现类将HTTP 请求适配到一个控制器的实现进行处理,这里控制器的实现是一个简单的控制器接口的实现。简单控制器处理器适配器被设计成一个框架类的实现，不需要被改写，客户化的业务逻辑通常是在控制器接口的实现类中实现的。

- 注解方法处理器适配器（AnnotationMethodHandlerAdapter ）。
> 这个类的实现是基于注解的实现，它需要结合注解方法映射和注解方法处理器协同工作。它通过解析声明在注解控制器的请求映射信息来解析相应的处理器方法来处理当前的HTTP 请求。在处理的过程中，它通过反射来发现探测处理器方法的参数，调用处理器方法，并且映射返回值到模型和控制器对象，最后返回模型和控制器对象给作为主控制器的派遣器Servlet。

>所以我们现在基本上可以回答之前的问题了， Spring 中所使用的Handler 并没有任何特殊的联系，但是为了统一处理， Spring 提供了不同情况下的适配器。

#### 初始化HandlerExceptionResolvers
> 基于HandlerExceptionResolver 接口的异常处理，使用这种方式只需要实现resolveException方法，该方法返回一个Mode!AndView 对象，在方法内部对异常的类型进行判断，然后尝试生成对应的ModelAndView 对象，如果方法返回null了，则spring 会继续寻找其他的实现了HandlerExceptionResolver 接口的bean。

> Spring 会搜索所有注册在其环境中的实现了HandlerExceptionResolver 接口的bean ，逐个执行， 直到返回了一个ModelAndView 对象。
```java
@Component
public class MyExceptionHandler implements HandlerExceptionResolver {
    private static final Logger log = LoggerFactory.getLogger(MyExceptionHandler.class);
    @Override
    public ModelAndView resolveException(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        request.setAttribute("exception", ex.toString()) ;
        request.setAttribute ("exceptionStack", ex) ;
        log.error ( ex.toString(), ex) ;
        return new ModelAndView( "error/exception");
    }
}
```
这个类必须声明到Spring 中去，让Spring 管理它。

- 初始化方式：
```java
private void initHandlerExceptionResolvers(ApplicationContext context) {
		this.handlerExceptionResolvers = null;

		if (this.detectAllHandlerExceptionResolvers) {
			// Find all HandlerExceptionResolvers in the ApplicationContext, including ancestor contexts.
			Map<String, HandlerExceptionResolver> matchingBeans = BeanFactoryUtils
					.beansOfTypeIncludingAncestors(context, HandlerExceptionResolver.class, true, false);
			if (!matchingBeans.isEmpty()) {
				this.handlerExceptionResolvers = new ArrayList<HandlerExceptionResolver>(matchingBeans.values());
				// We keep HandlerExceptionResolvers in sorted order.
				AnnotationAwareOrderComparator.sort(this.handlerExceptionResolvers);
			}
		}
		else {
			try {
				HandlerExceptionResolver her =
						context.getBean(HANDLER_EXCEPTION_RESOLVER_BEAN_NAME, HandlerExceptionResolver.class);
				this.handlerExceptionResolvers = Collections.singletonList(her);
			}
			catch (NoSuchBeanDefinitionException ex) {
				// Ignore, no HandlerExceptionResolver is fine too.
			}
		}
		// Ensure we have at least some HandlerExceptionResolvers, by registering
		// default HandlerExceptionResolvers if no other resolvers are found.
		if (this.handlerExceptionResolvers == null) {
			this.handlerExceptionResolvers = getDefaultStrategies(context, HandlerExceptionResolver.class);
			if (logger.isDebugEnabled()) {
				logger.debug("No HandlerExceptionResolvers found in servlet '" + getServletName() + "': using default");
			}
		}
	}
```

#### 初始化RequestToViewNameTranslator
当Controller 处理器方法没有返回一个View 对象或逻辑视图名称，并且在该方法中没有直接往respons巳的输出流里面写数据的时候，Spring 就会采用约定好的方式提供一个逻辑视图名称。这个逻辑视图名称是通过Spring 定义的`org.springframework.web.servlet.RequestToViewNameTranslator` 接口的getViewName 方法来实现的.我们可以实现自己的RequestToViewNameTranslator 接口来约定好没有返回视图名称的时候如何确定视图名称. Spring 已经给我们提供了一个它自己的实现.那就是 `org.springframework.web.servlet.view.DefaultRequestToViewNameTranslator`。

在介绍Defau ltRequestToView Nam巳Translator 是如何约定视图名称之前，先来看一下它支
持用户定义的属性。
1. prefix ：前缀，表示约定好的视图名称需要加上的前缀，默认是空串。
2. suffix ：后缀，表示约定好的视图名称需要加上的后缀， 默认是空串。
3. separator ：分隔符，默认是斜杠“／” 。
4. stripLeadingS !ash ：如果首字符是分隔符，是否要去除， 默认是true 。
5. stripTrailingSlash ：如果最后一个字符是分隔符，是否要去除，默认是true 。
6. stripExtension ：如果请求路径包含扩展名是否要去除， 默认是true 。
6. ur!Decode ： 是否需妥对URL 解码，默认是true 。它会采用request 指定的编码或者IS0-8859-1 编码对URL 进行解码。

当我们没有在SpringMVC 的配置文件中手动的定义一个名为viewNameTranlator 的Bean的时候， Spring 就会为我们提供一个默认的viewNameTranslator ， 即DefaultRequestToViewNameTranslator 。

接下来看一下， 当Controller 处理器方法没有返回逻辑视图名称时，DefaultRequestToViewNameTranslator 是如何约定视图名称的。DefaultRequestToView N ameTranslator 会获取到请求的
Url，然后根据提供的属性做一些改造， 把改造之后的结果作为视图名称返回。这里以请求路径http://localhost/app/test/index.html 为例。来说明一下DefaultRequestToViewNameTranslator
是如何工作的。该请求路径对应的请求U阳为／test/index.html ，我们来看以下几种情况， 它分别对应的逻辑视图名称是什么。
1. prefix 和suffix 如果都存在，其他为默认值， 那么对应返回的逻辑视图名称应该是prefixtest/indexsuffix 。
2. stripLeadingSlash 和stripExtension 都为false ， 其他默认， 这时候对应的逻辑视图名称是 `/product/index.html` 。
3. 都采用默认配置时，返回的逻辑视图名称应该是`product/index`

> 如果逻辑视图名称跟请求路径相同或者相关关系都是一样的， 那么我们就可以采用Spring为我们事先约定好的逻辑视图名称返回，这可以大大简化我们的开发工作，而以上功能实现的关键属性viewNameTranslator ，则是initRequestToViewNameTranslator 中完成。

```java
private void initRequestToViewNameTranslator(ApplicationContext context) {
		try {
			this.viewNameTranslator =
					context.getBean(REQUEST_TO_VIEW_NAME_TRANSLATOR_BEAN_NAME, RequestToViewNameTranslator.class);
			if (logger.isDebugEnabled()) {
				logger.debug("Using RequestToViewNameTranslator [" + this.viewNameTranslator + "]");
			}
		}
		catch (NoSuchBeanDefinitionException ex) {
			// We need to use the default.
			this.viewNameTranslator = getDefaultStrategy(context, RequestToViewNameTranslator.class);
			if (logger.isDebugEnabled()) {
				logger.debug("Unable to locate RequestToViewNameTranslator with name '" +
						REQUEST_TO_VIEW_NAME_TRANSLATOR_BEAN_NAME + "': using default [" + this.viewNameTranslator +
						"]");
			}
		}
	}
```

#### 初始化ViewResolvers
在SpringMVC 中， 当Controller 将请求处理结果放入到ModelAndView 中以后，DispatcherServlet 会根据ModelAndView 选择合适的视图进行渲染.

那么在SpringMVC 中是如何选择合适的View 呢? View 对象是是如何创建的呢? 答案就在ViewResolver 中。ViewResolver接口定义了resolverViewName 方法，根据viewName 创建合适类型的View 实现。

那么如何配置ViewResolver 呢？在Spring 中， ViewResolver 作为Spring Bean 存在，可以
在Spring 配置文件中进行配置，例如下面的代码，配置了JSP 相关的viewResolver。

```xml
<bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
    <property name="prefix" value="/WEB- INF/views/"/>
    <property name="suffix" value=".jsp"/>
</bean>
```
viewResolvers 属性的初始化工作在initViewResolvers 中完成。
```java
private void initViewResolvers(ApplicationContext context) {
		this.viewResolvers = null;

		if (this.detectAllViewResolvers) {
			// Find all ViewResolvers in the ApplicationContext, including ancestor contexts.
			Map<String, ViewResolver> matchingBeans =
					BeanFactoryUtils.beansOfTypeIncludingAncestors(context, ViewResolver.class, true, false);
			if (!matchingBeans.isEmpty()) {
				this.viewResolvers = new ArrayList<ViewResolver>(matchingBeans.values());
				// We keep ViewResolvers in sorted order.
				AnnotationAwareOrderComparator.sort(this.viewResolvers);
			}
		}
		else {
			try {
				ViewResolver vr = context.getBean(VIEW_RESOLVER_BEAN_NAME, ViewResolver.class);
				this.viewResolvers = Collections.singletonList(vr);
			}
			catch (NoSuchBeanDefinitionException ex) {
				// Ignore, we'll add a default ViewResolver later.
			}
		}
		// Ensure we have at least one ViewResolver, by registering
		// a default ViewResolver if no other resolvers are found.
		if (this.viewResolvers == null) {
			this.viewResolvers = getDefaultStrategies(context, ViewResolver.class);
			if (logger.isDebugEnabled()) {
				logger.debug("No ViewResolvers found in servlet '" + getServletName() + "': using default");
			}
		}
	}
```

#### 初始化FlashMapManager
SpringMVC Flash attributes 提供了一个请求存储属性，可供其他请求使用。在使用重定向时候非常必要,例如Post/Redirect/Get 模式.Flash attributes 在重定向之前暂存（就像存在session中）以便重定向之后还能使用，并立即删除。

SpringMVC 有两个主要的抽象来支持flash attributes 。FlashMap 用于保持flash attributes ,而FlashMapManager 用于存储、检索、管理FlashMap 实例。

flash attribute 支持默认开启（"on" ）并不需要显式启用，它永远不会导致HTTP Session 的创建。这两个FlashMap 实例都可以通过静态方法RequestContextUtils 从SpringMVC 的任何位置访问。

flashMapManager 的初始化在initFlashMapManager 中完成。
```java
private void initFlashMapManager(ApplicationContext context) {
    try {
        this.flashMapManager = context.getBean(FLASH_MAP_MANAGER_BEAN_NAME, FlashMapManager.class);
        if (logger.isDebugEnabled()) {
            logger.debug("Using FlashMapManager [" + this.flashMapManager + "]");
        }
    }
    catch (NoSuchBeanDefinitionException ex) {
        // We need to use the default.
        this.flashMapManager = getDefaultStrategy(context, FlashMapManager.class);
        if (logger.isDebugEnabled()) {
            logger.debug("Unable to locate FlashMapManager with name '" +
                    FLASH_MAP_MANAGER_BEAN_NAME + "': using default [" + this.flashMapManager + "]");
        }
    }
}
```

## DispatcherServlet 的逻辑处理
根据之前的示例，我们知道在HttpSe叫et 类中分别提供了相应的服务方法，它们是 doDelete() 、doGet() 、doOptions() 、doPost() 、doPut() 和doTrace()，它会根据请求的不同形式将程序引导至对应的函数进行处理。这几个函数中最常用的函数无非就是doGet() 和doPost()， 那么我们就直接查看DispatcherServlet 中对于这两个函数的逻辑实现。

```java
    //FrameworkServlet
    @Override
	protected final void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		processRequest(request, response);
	}

    @Override
	protected final void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		processRequest(request, response);
	}
```
对于不同的方法， Spring 并没有做特殊处理，而是统一将程序再一次地引导至processRequest( request, response）中。
```java
////FrameworkServlet
protected final void processRequest(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
        //记录当前时间，用于计算web请求总的花费时间
		long startTime = System.currentTimeMillis();
		Throwable failureCause = null;

		LocaleContext previousLocaleContext = LocaleContextHolder.getLocaleContext();
		LocaleContext localeContext = buildLocaleContext(request);

		RequestAttributes previousAttributes = RequestContextHolder.getRequestAttributes();
		ServletRequestAttributes requestAttributes = buildRequestAttributes(request, response, previousAttributes);

		WebAsyncManager asyncManager = WebAsyncUtils.getAsyncManager(request);
		asyncManager.registerCallableInterceptor(FrameworkServlet.class.getName(), new RequestBindingInterceptor());

		initContextHolders(request, localeContext, requestAttributes);

		try {
			doService(request, response);
		}
		catch (ServletException ex) {
			failureCause = ex;
			throw ex;
		}
		catch (IOException ex) {
			failureCause = ex;
			throw ex;
		}
		catch (Throwable ex) {
			failureCause = ex;
			throw new NestedServletException("Request processing failed", ex);
		}

		finally {
			resetContextHolders(request, previousLocaleContext, previousAttributes);
			if (requestAttributes != null) {
				requestAttributes.requestCompleted();
			}

			if (logger.isDebugEnabled()) {
				if (failureCause != null) {
					this.logger.debug("Could not complete request", failureCause);
				}
				else {
					if (asyncManager.isConcurrentHandlingStarted()) {
						logger.debug("Leaving response open for concurrent processing");
					}
					else {
						this.logger.debug("Successfully completed request");
					}
				}
			}

			publishRequestHandledEvent(request, response, startTime, failureCause);
		}
	}
```
通过以上方法可以看出，service 方法为核心处理方法，其他方法为准备工作：
1. 为了保证当前线程的LocaleContext 以及RequestAttributes 可以在当前请求后还能恢复，提取当前线程的两个属性
2. 根据当前request 创建对应的LocaleContext 和RequestAttributes ，并绑定到当前线程。
3. 委托给doService 方法进一步处理。
4. 请求处理结束后恢复线程到原始状态。
5. 请求处理结束后无论成功与否发布事件通知。

看 doService 方法的处理
```java
//DispatcherServlet
protected void doService(HttpServletRequest request, HttpServletResponse response) throws Exception {
		if (logger.isDebugEnabled()) {
			String resumed = WebAsyncUtils.getAsyncManager(request).hasConcurrentResult() ? " resumed" : "";
			logger.debug("DispatcherServlet with name '" + getServletName() + "'" + resumed +
					" processing " + request.getMethod() + " request for [" + getRequestUri(request) + "]");
		}

		// Keep a snapshot of the request attributes in case of an include,
		// to be able to restore the original attributes after the include.
		Map<String, Object> attributesSnapshot = null;
		if (WebUtils.isIncludeRequest(request)) {
			attributesSnapshot = new HashMap<String, Object>();
			Enumeration<?> attrNames = request.getAttributeNames();
			while (attrNames.hasMoreElements()) {
				String attrName = (String) attrNames.nextElement();
				if (this.cleanupAfterInclude || attrName.startsWith(DEFAULT_STRATEGIES_PREFIX)) {
					attributesSnapshot.put(attrName, request.getAttribute(attrName));
				}
			}
		}

		// Make framework objects available to handlers and view objects.
		request.setAttribute(WEB_APPLICATION_CONTEXT_ATTRIBUTE, getWebApplicationContext());
		request.setAttribute(LOCALE_RESOLVER_ATTRIBUTE, this.localeResolver);
		request.setAttribute(THEME_RESOLVER_ATTRIBUTE, this.themeResolver);
		request.setAttribute(THEME_SOURCE_ATTRIBUTE, getThemeSource());

		FlashMap inputFlashMap = this.flashMapManager.retrieveAndUpdate(request, response);
		if (inputFlashMap != null) {
			request.setAttribute(INPUT_FLASH_MAP_ATTRIBUTE, Collections.unmodifiableMap(inputFlashMap));
		}
		request.setAttribute(OUTPUT_FLASH_MAP_ATTRIBUTE, new FlashMap());
		request.setAttribute(FLASH_MAP_MANAGER_ATTRIBUTE, this.flashMapManager);

		try {
			doDispatch(request, response);
		}
		finally {
			if (!WebAsyncUtils.getAsyncManager(request).isConcurrentHandlingStarted()) {
				// Restore the original attribute snapshot, in case of an include.
				if (attributesSnapshot != null) {
					restoreAttributesAfterInclude(request, attributesSnapshot);
				}
			}
		}
	}
```
doService中做了一些请求前的准备工作。将已经初始化的功能辅助工具变量，比如localeResolver ,themeResolver 等设置在request 属性中， 而这些属性会在接下来的处理中派上用场。
```java
//DispatcherServlet
protected void doDispatch(HttpServletRequest request, HttpServletResponse response) throws Exception {
		HttpServletRequest processedRequest = request;
		HandlerExecutionChain mappedHandler = null;
		boolean multipartRequestParsed = false;

		WebAsyncManager asyncManager = WebAsyncUtils.getAsyncManager(request);

		try {
			ModelAndView mv = null;
			Exception dispatchException = null;

			try {
                //／／如果是MultipartContent 类型的request则转换request 为MultipartHttpServletRequest 类型的request
				processedRequest = checkMultipart(request);
				multipartRequestParsed = (processedRequest != request);
                // 依据request 查找对应的handler
				// Determine handler for the current request.
				mappedHandler = getHandler(processedRequest);
				if (mappedHandler == null || mappedHandler.getHandler() == null) {
                    //如果没有找到对应的handler 则通过response 反馈错误信息
					noHandlerFound(processedRequest, response);
					return;
				}
                //根据当前的handler 寻找对应的HandlerAdapter
				// Determine handler adapter for the current request.
				HandlerAdapter ha = getHandlerAdapter(mappedHandler.getHandler());
                //／／如果当前handler 支持last-modified 头处理
				// Process last-modified header, if supported by the handler.
				String method = request.getMethod();
				boolean isGet = "GET".equals(method);
				if (isGet || "HEAD".equals(method)) {
					long lastModified = ha.getLastModified(request, mappedHandler.getHandler());
					if (logger.isDebugEnabled()) {
						logger.debug("Last-Modified value for [" + getRequestUri(request) + "] is: " + lastModified);
					}
					if (new ServletWebRequest(request, response).checkNotModified(lastModified) && isGet) {
						return;
					}
				}
                //拦截榕的preHandler 方法的调用
				if (!mappedHandler.applyPreHandle(processedRequest, response)) {
					return;
				}
                //真正的激活handler 并返回视图
				// Actually invoke the handler.
				mv = ha.handle(processedRequest, response, mappedHandler.getHandler());

				if (asyncManager.isConcurrentHandlingStarted()) {
					return;
				}
                //视图名称转换应用于馆要添加前缀后缀的情况
				applyDefaultViewName(processedRequest, mv);
                //应用所有拦截器的postHandle 方法
				mappedHandler.applyPostHandle(processedRequest, response, mv);
			}
			catch (Exception ex) {
				dispatchException = ex;
			}
			catch (Throwable err) {
				// As of 4.3, we're processing Errors thrown from handler methods as well,
				// making them available for @ExceptionHandler methods and other scenarios.
				dispatchException = new NestedServletException("Handler dispatch failed", err);
			}
            // 处理最终结果
			processDispatchResult(processedRequest, response, mappedHandler, mv, dispatchException);
		}
		catch (Exception ex) {
			triggerAfterCompletion(processedRequest, response, mappedHandler, ex);
		}
		catch (Throwable err) {
			triggerAfterCompletion(processedRequest, response, mappedHandler,
					new NestedServletException("Handler processing failed", err));
		}
		finally {
			if (asyncManager.isConcurrentHandlingStarted()) {
				// Instead of postHandle and afterCompletion
				if (mappedHandler != null) {
					mappedHandler.applyAfterConcurrentHandlingStarted(processedRequest, response);
				}
			}
			else {
				// Clean up any resources used by a multipart request.
				if (multipartRequestParsed) {
					cleanupMultipart(processedRequest);
				}
			}
		}
	}
```

doDispatch 函数中展示了Spring 请求处理所涉及的主要逻辑，而我们之前设置在request中的各种辅助属性也都有被派上了用场。下面回顾一下逻辑处理的全过程。

### MultipartContent 类型的request 处理
对于请求的处理， Spring 首先考虑的是对于Multipart 的处理， 如果是MultipartContent 类型的request ，则转换request 为MultipartHttpServletRequest 类型的request。
```java
//DispatcherServlet
protected HttpServletRequest checkMultipart(HttpServletRequest request) throws MultipartException {
		if (this.multipartResolver != null && this.multipartResolver.isMultipart(request)) {
			if (WebUtils.getNativeRequest(request, MultipartHttpServletRequest.class) != null) {
				logger.debug("Request is already a MultipartHttpServletRequest - if not in a forward, " +
						"this typically results from an additional MultipartFilter in web.xml");
			}
			else if (hasMultipartException(request) ) {
				logger.debug("Multipart resolution failed for current request before - " +
						"skipping re-resolution for undisturbed error rendering");
			}
			else {
				try {
					return this.multipartResolver.resolveMultipart(request);
				}
				catch (MultipartException ex) {
					if (request.getAttribute(WebUtils.ERROR_EXCEPTION_ATTRIBUTE) != null) {
						logger.debug("Multipart resolution failed for error dispatch", ex);
						// Keep processing error dispatch with regular request handle below
					}
					else {
						throw ex;
					}
				}
			}
		}
		// If not returned before: return original request.
		return request;
	}

```

### 根据request 信息寻找对应的Handler
在Spring 中最简单的映射处理器配置如下：
```xml
<bean id= "simpleUrlMapping"
class ＝ "org.Springframework.web.servlet.handler.SimpleUrlHandlerMapping">
    <property name="mappings">
        <props>
            <prop key="/userlist.htm">userController</prop>
        </props>
    </property>
</bean>
```
在Spring 加载的过程中， Spring 会将类型为SimpleUrlHandlerMapping 的实例加载到this.handlerMappings 中，按照常理推断，根据request 提取对应的Handler ，无非就是提取当前实例中的userController ，但是userController 为继承自AbstractController 类型实例，与HandlerExecutionChain 并无任何关联，那么这一步是如何封装的呢?
```java
//DispatcherServlet
protected HandlerExecutionChain getHandler(HttpServletRequest request) throws Exception {
		for (HandlerMapping hm : this.handlerMappings) {
			if (logger.isTraceEnabled()) {
				logger.trace(
						"Testing handler map [" + hm + "] in DispatcherServlet with name '" + getServletName() + "'");
			}
			HandlerExecutionChain handler = hm.getHandler(request);
			if (handler != null) {
				return handler;
			}
		}
		return null;
	}
```
在之前的内容我们提过， 在系统启动时Spring 会将所有的映射类型的bean 注册到this.handlerMappings 变量中,所以此函数的目的就是遍历所有的HandlerMapping ， 并调用其getHandler 方法进行封装处理.以SimpleUrlHandlerMapping 为例查看其getHandler 方法如下：

```java
//AbstractHandlerMapping
public final HandlerExecutionChain getHandler(HttpServletRequest request) throws Exception {
        //根据request 获取对应的handler
		Object handler = getHandlerInternal(request);
		if (handler == null) {
            //如果没有对应request 的handler 则使用默认的handler
			handler = getDefaultHandler();
		}
        //如果也没有提供默认的handler 则无法继续处理返回null
		if (handler == null) {
			return null;
		}
		// Bean name or resolved handler?
		if (handler instanceof String) {
			String handlerName = (String) handler;
			handler = getApplicationContext().getBean(handlerName);
		}

		HandlerExecutionChain executionChain = getHandlerExecutionChain(handler, request);
		if (CorsUtils.isCorsRequest(request)) {
			CorsConfiguration globalConfig = this.globalCorsConfigSource.getCorsConfiguration(request);
			CorsConfiguration handlerConfig = getCorsConfiguration(handler, request);
			CorsConfiguration config = (globalConfig != null ? globalConfig.combine(handlerConfig) : handlerConfig);
			executionChain = getCorsHandlerExecutionChain(request, executionChain, config);
		}
		return executionChain;
	}
```
函数中首先会使用getHandlerlntemal 方法根据request 信息获取对应的Handler.如果以SimpleUrlHandlerMapping 为例分析， 那么我们推断此步骤提供的功能很可能就是根据URL 找到匹配的Controller 并返回，当然如果没有找到对应的Controller 处理器那么程序会尝试去查找配置中的默认处理器，当然，当查找的controller 为String 类型时,那就意味着返回的是配置的bean 名称，需要根据bean 名称查找对应的bean,最后，还要通过getHandlerExecutionChain 方法对返回的Handler 进行封装,以保证满足返回类型的匹配。

- 根据request 查找对应的Handler
```java
//AbstractUrlHandlerMapping
protected Object getHandlerInternal(HttpServletRequest request) throws Exception {
        //截取用于匹配的url 有效路径
		String lookupPath = getUrlPathHelper().getLookupPathForRequest(request);
        //根据路径寻找Handler
		Object handler = lookupHandler(lookupPath, request);
		if (handler == null) {
			// We need to care for the default handler directly, since we need to
			// expose the PATH_WITHIN_HANDLER_MAPPING_ATTRIBUTE for it as well.
			Object rawHandler = null;
			if ("/".equals(lookupPath)) {
                //如果请求的路径仅仅是"／" ，那么使用RootHandler 进行处理
				rawHandler = getRootHandler();
			}
			if (rawHandler == null) {
                //无法找到handler 则使用默认handler
				rawHandler = getDefaultHandler();
			}
			if (rawHandler != null) {
                //根据beanName 获取对应的bean
				// Bean name or resolved handler?
				if (rawHandler instanceof String) {
					String handlerName = (String) rawHandler;
					rawHandler = getApplicationContext().getBean(handlerName);
				}
                //模版方法
				validateHandler(rawHandler, request);
				handler = buildPathExposingHandler(rawHandler, lookupPath, lookupPath, null);
			}
		}
		if (handler != null && logger.isDebugEnabled()) {
			logger.debug("Mapping [" + lookupPath + "] to " + handler);
		}
		else if (handler == null && logger.isTraceEnabled()) {
			logger.trace("No handler mapping found for [" + lookupPath + "]");
		}
		return handler;
	}

    //lookUpHandler() 根据URL 获取对应Handler 的匹配规则代码实现起来虽然很长，但是并不难理解，考虑了直接匹配与通配符两种情况。
    protected Object lookupHandler(String urlPath, HttpServletRequest request) throws Exception {
		//直接匹配情况的处理
        // Direct match?
		Object handler = this.handlerMap.get(urlPath);
		if (handler != null) {
			// Bean name or resolved handler?
			if (handler instanceof String) {
				String handlerName = (String) handler;
				handler = getApplicationContext().getBean(handlerName);
			}
			validateHandler(handler, request);
			return buildPathExposingHandler(handler, urlPath, urlPath, null);
		}
        //通配符的处理
		// Pattern match?
		List<String> matchingPatterns = new ArrayList<String>();
		for (String registeredPattern : this.handlerMap.keySet()) {
			if (getPathMatcher().match(registeredPattern, urlPath)) {
				matchingPatterns.add(registeredPattern);
			}
			else if (useTrailingSlashMatch()) {
				if (!registeredPattern.endsWith("/") && getPathMatcher().match(registeredPattern + "/", urlPath)) {
					matchingPatterns.add(registeredPattern +"/");
				}
			}
		}
		String bestMatch = null;
		Comparator<String> patternComparator = getPathMatcher().getPatternComparator(urlPath);
		if (!matchingPatterns.isEmpty()) {
			Collections.sort(matchingPatterns, patternComparator);
			if (logger.isDebugEnabled()) {
				logger.debug("Matching patterns for request [" + urlPath + "] are " + matchingPatterns);
			}
			bestMatch = matchingPatterns.get(0);
		}
		if (bestMatch != null) {
			handler = this.handlerMap.get(bestMatch);
			if (handler == null) {
				if (bestMatch.endsWith("/")) {
					handler = this.handlerMap.get(bestMatch.substring(0, bestMatch.length() - 1));
				}
				if (handler == null) {
					throw new IllegalStateException(
							"Could not find handler for best pattern match [" + bestMatch + "]");
				}
			}
			// Bean name or resolved handler?
			if (handler instanceof String) {
				String handlerName = (String) handler;
				handler = getApplicationContext().getBean(handlerName);
			}
			validateHandler(handler, request);
			String pathWithinMapping = getPathMatcher().extractPathWithinPattern(bestMatch, urlPath);

			// There might be multiple 'best patterns', let's make sure we have the correct URI template variables
			// for all of them
			Map<String, String> uriTemplateVariables = new LinkedHashMap<String, String>();
			for (String matchingPattern : matchingPatterns) {
				if (patternComparator.compare(bestMatch, matchingPattern) == 0) {
					Map<String, String> vars = getPathMatcher().extractUriTemplateVariables(matchingPattern, urlPath);
					Map<String, String> decodedVars = getUrlPathHelper().decodePathVariables(request, vars);
					uriTemplateVariables.putAll(decodedVars);
				}
			}
			if (logger.isDebugEnabled()) {
				logger.debug("URI Template variables for request [" + urlPath + "] are " + uriTemplateVariables);
			}
			return buildPathExposingHandler(handler, bestMatch, pathWithinMapping, uriTemplateVariables);
		}

		// No handler found...
		return null;
	}
    //其中要提及的是buildPathExposingHandler 函数，它将Handler 封装成了HandlerExecutionChain 类型。
    protected Object buildPathExposingHandler(Object rawHandler, String bestMatchingPattern,
			String pathWithinMapping, Map<String, String> uriTemplateVariables) {

		HandlerExecutionChain chain = new HandlerExecutionChain(rawHandler);
		chain.addInterceptor(new PathExposingHandlerInterceptor(bestMatchingPattern, pathWithinMapping));
		if (!CollectionUtils.isEmpty(uriTemplateVariables)) {
			chain.addInterceptor(new UriTemplateVariablesHandlerInterceptor(uriTemplateVariables));
		}
		return chain;
	}
```
- 加入拦截器到执行链
getHandlerExecutionChain 函数最主要的目的是将配置中的对应拦截器加入到执行链中，以保证这些拦截器可以有效地作用于目标对象。
```java
//AbstractHandlerMapping
protected HandlerExecutionChain getHandlerExecutionChain(Object handler, HttpServletRequest request) {
		HandlerExecutionChain chain = (handler instanceof HandlerExecutionChain ?
				(HandlerExecutionChain) handler : new HandlerExecutionChain(handler));

		String lookupPath = this.urlPathHelper.getLookupPathForRequest(request);
		for (HandlerInterceptor interceptor : this.adaptedInterceptors) {
			if (interceptor instanceof MappedInterceptor) {
				MappedInterceptor mappedInterceptor = (MappedInterceptor) interceptor;
				if (mappedInterceptor.matches(lookupPath, this.pathMatcher)) {
					chain.addInterceptor(mappedInterceptor.getInterceptor());
				}
			}
			else {
				chain.addInterceptor(interceptor);
			}
		}
		return chain;
	}
```

### 没找到对应的Handler 的错误处理
每个请求都应该对应着－ Handler ，因为每个请求都会在后台有相应的逻辑对应，而逻辑的实现就是在Handler 中，所以一旦遇到没有找到Handler 的情况（正常情况下如果没有URL匹配的Handler ，开发人员可以设置默认的Handler 来处理请求，但是如果默认请求也未设置就会出现Handler 为空的情况），就只能通过respons巳向用户返回错误信息。
```java
//dispatcherServlet
protected void noHandlerFound(HttpServletRequest request, HttpServletResponse response) throws Exception {
		if (pageNotFoundLogger.isWarnEnabled()) {
			pageNotFoundLogger.warn("No mapping found for HTTP request with URI [" + getRequestUri(request) +
					"] in DispatcherServlet with name '" + getServletName() + "'");
		}
		if (this.throwExceptionIfNoHandlerFound) {
			throw new NoHandlerFoundException(request.getMethod(), getRequestUri(request),
					new ServletServerHttpRequest(request).getHeaders());
		}
		else {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
		}
	}
```
### 根据当前Handler 寻找对应的HandlerAdapter
在WebApplicationContext 的初始化过程中我们讨论了HandlerAdapters 的初始化，了解了在默认情况下普通的Web 请求会交给SimpleControllerHandlerAdapter 去处理。下面我们以
SimpleControllerHandlerAdapter 为例来分析获取适配器的逻辑。
```java
//dispatcherServlet
protected HandlerAdapter getHandlerAdapter(Object handler) throws ServletException {
    for (HandlerAdapter ha : this.handlerAdapters) {
        if (logger.isTraceEnabled()) {
            logger.trace("Testing handler adapter [" + ha + "]");
        }
        if (ha.supports(handler)) {
            return ha;
        }
    }
    throw new ServletException("No adapter for handler [" + handler +
            "]: The DispatcherServlet configuration needs to include a HandlerAdapter that supports this handler");
}
```
对于获取适配器的逻辑无非就是遍历所有适配器来选择合适的适配器并返回它，而 __某个适配器是否适用于当前的Handler 逻辑被封装在具体的适配器中__。
```java
//SimpleControllerHandlerAdapter implements HandlerAdapter
@Override
public boolean supports(Object handler) {
    return (handler instanceof Controller);
}
```
一切已经明了， SimpleControllerHandlerAdapter 就是用于处理普通的Web
请求的，而且对于SpringMVC 来说，我们会把逻辑封装至Controller 的子类中，例如我们之前的引导示例UserController 就是继承自AbstractController,而AbstractController 实现Controller 接口.

### 缓存处理
> 在研究Spring 对缓存处理的功能支持前，我们先了解一个概念：Last-Modified 缓存机制。
1. 在客户端第一次输入URL 时， 服务器端会返回内容和状态码200,表示请求成功， 同时会添加一个 `Last-Modified` 的响应头,表示此文件在服务器上的最后更新时间，eg: `Last-Modified : Wed， 14Mar2012 10:22:42 GMT` 表示最后的响应时间为： 2012-03-14 10:22

2. 客户端第二次请求此URL 时，客户端会向服务器发送请求头`If-Modified-Since`，询问服务器该时间之后当前请求内容是否有被修改过，如 `If-Modified-Since: Wed, 14 Mar 2012 10:22:42 GMT`,如果服务器端的内容没有变化， 则自动返回 `HTTP 304` 状态码（只要响应头，
内容为空，这样就节省了网络带宽）。

Spring 提供的对 `Last-Modified` 机制的支持，只需要实现LastModified 接口，如下所示：
```java
public class HelloWordLastModifiedCachedController extends AbstractController implements LastModified {

    private long lastModified;
    @Override
    protected ModelAndView handleRequestInternal(HttpServletRequest request, HttpServletResponse response) throws Exception {
       //点击后再次请求当前页面
        response.getWriter ().write ("<a href=''>this</a>") ;
        return null;
    }
    @Override
    public long getLastModified(HttpServletRequest request) {
        if ( lastModified == 01 ) {
            //第一次或者逻辑有变化的时候， 应该重新返回内容最新修改的时间戳
            lastModified = System.currentTimeMillis();
        }
        return lastModified;
    }
}
```
HelloWorldLastModifiedCacheController 只需要实现LastModified 接口的getLastModified方法，保证当内容发生改变时返回最新的修改时间即可。

Spring 判断是否过期， 通过判断请求的 `If-Modified-Since` 是否大于等于当前的getLastModified 方法的时间戳，如果是， 则认为没有修改。上面的controller 与普通的controller 并无太大差别， 声明如下：
```xml
<bean id="/helloLastModified" class="com.zbcn.web.controller.HelloWordLastModifiedCachedController"/>
```

### Handlerlnterceptor 的处理
Servlet API 定义的servlet 过滤器可以在servlet 处理每个Web 请求的前后分别对它进行前置处理和后置处理。有些时候， 你可能只想处理由某些SpringMVC 处理程序处理的Web请求,并在这些处理程序返回的模型属性被传递到视图之前，对它们进行一些操作。

SpringMVC 允许你通过处理拦截Web 请求，进行前置处理和后置处理。处理拦截是在Spring 的Web 应用程序上下文中配置的,因此它们可以利用各种容器特性，并引用容器中声明的任何bean 。处理拦截是针对特殊的处理程序映射进行注册的，因此它只拦截通过这些处理程序映射的请求。每个处理拦截都必须实现HandlerInterceptor 接口,包含三个需要你实现的回调方法： preHandle() 、postHandle()和afterCompletion()。第一个和第二个方法分别是在处理程序处理请求之前和之后被调用的。第二个方法还允许访问返回的ModelAndView 对象， 因此可以在它里面操作模型属性。最后一个方法是在所有请求处理完成之后被调用的（ 如视图呈现之后），以下是HandlerInterceptor 的简单实现：
```java
@Component
public class MyInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
       long startTime = System.currentTimeMillis();
        request.setAttribute("startTime", startTime); ;
        return true ;
    }
    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        long startTime = (Long) request.getAttribute("startTime");
        request.removeAttribute("startTime");
        long endTime= System.currentTimeMillis( );
        modelAndView.addObject("handleTime", endTime-startTime);
    }
    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {

    }
}

```
在以上拦截器中，preHandle中记录了请求的开始时间，并将它保存到请求属性中。这个方法应该返回true ，允许DispatcherServlet 继续处理请求。否则， DispatcherServlet 会认为这个方法已经处理了请求， 直接将响应返回给用户。postHandle中，从请求属性中加载起始时间，并将它与当前时间进行比较。你可以计算总的持续时间， 然后把这个时间添加到模型中，传递给视图。

### 逻辑处理
对于逻辑处理其实是通过适配器中转调用Handler 并返回视图的，对应代码如下：
```java
// Actually invoke the handler.
mv = ha.handle(processedRequest, response, mappedHandler.getHandler());
```
同样，还是以引导示例为基础进行处理逻辑分析，之前分析过，对于普通的Web 请求，Spring默认使用SimpleControllerHandlerAdapter 类进行处理， 我们进入SimpleControllerHandlerAdapter 类的handle 方法如下
```java
//SimpleControllerHandlerAdapter
@Override
public ModelAndView handle(HttpServletRequest request, HttpServletResponse response, Object handler)
        throws Exception {

    return ((Controller) handler).handleRequest(request, response);
}
```
但是回顾引导示例中的UserController ，我们的逻辑是写在handleRequestinternal 函数中而不是handleRequest 函数，所以我们还需要进一步分析这期间所包含的处理流程。
```java
//AbstractController
@Override
public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response)
        throws Exception {

    if (HttpMethod.OPTIONS.matches(request.getMethod())) {
        response.setHeader("Allow", getAllowHeader());
        return null;
    }

    // Delegate to WebContentGenerator for checking and preparing.
    checkRequest(request);
    prepareResponse(response);
    //如果需要session 内的同步执行
    // Execute handleRequestInternal in synchronized block if required.
    if (this.synchronizeOnSession) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object mutex = WebUtils.getSessionMutex(session);
            synchronized (mutex) {
                // 调用用户的逻辑
                return handleRequestInternal(request, response);
            }
        }
    }
    //调用用户逻辑
    return handleRequestInternal(request, response);
}
```
### 异常视图的处理
有时候系统运行过程中出现异常，而我们并不希望就此中断对用户的服务，而是至少告知客户当前系统在处理逻辑的过程中出现了异常，甚至告知他们因为什么原因导致的。Spring 中的异常处理机制会帮我们完成这个工作。其实，这里Spring 主要的工作就是将逻辑引导至HandlerExceptionResolver 类的resolveException 方法。而HandlerExceptionResolver 的使用，我们在讲解WebApplicationContext 的初始化的时－候已经介绍过了

processDispatchResult ->  processHandlerException
```java
//DispatcherServlet
protected ModelAndView processHandlerException(HttpServletRequest request, HttpServletResponse response,
			Object handler, Exception ex) throws Exception {

		// Check registered HandlerExceptionResolvers...
		ModelAndView exMv = null;
		for (HandlerExceptionResolver handlerExceptionResolver : this.handlerExceptionResolvers) {
			exMv = handlerExceptionResolver.resolveException(request, response, handler, ex);
			if (exMv != null) {
				break;
			}
		}
		if (exMv != null) {
			if (exMv.isEmpty()) {
				request.setAttribute(EXCEPTION_ATTRIBUTE, ex);
				return null;
			}
			// We might still need view name translation for a plain error model...
			if (!exMv.hasView()) {
				exMv.setViewName(getDefaultViewName(request));
			}
			if (logger.isDebugEnabled()) {
				logger.debug("Handler execution resulted in exception - forwarding to resolved error view: " + exMv, ex);
			}
			WebUtils.exposeErrorRequestAttributes(request, ex, getServletName());
			return exMv;
		}

		throw ex;
	}
```

### 根据视图跳转页面

无论是一个系统还是一个站点，最重要的工作都是与用户进行交互，用户操作系统后无论下发的命令成功与否都需要给用户一个反馈，以便于用户进行下一步的判断.所以，在逻辑处
```java
//DispatcherServlet
protected void render(ModelAndView mv, HttpServletRequest request, HttpServletResponse response) throws Exception {
		// Determine locale for request and apply it to the response.
		Locale locale = this.localeResolver.resolveLocale(request);
		response.setLocale(locale);

		View view;
		if (mv.isReference()) {
			// We need to resolve the view name.
			view = resolveViewName(mv.getViewName(), mv.getModelInternal(), locale, request);
			if (view == null) {
				throw new ServletException("Could not resolve view with name '" + mv.getViewName() +
						"' in servlet with name '" + getServletName() + "'");
			}
		}
		else {
			// No need to lookup: the ModelAndView object contains the actual View object.
			view = mv.getView();
			if (view == null) {
				throw new ServletException("ModelAndView [" + mv + "] neither contains a view name nor a " +
						"View object in servlet with name '" + getServletName() + "'");
			}
		}

		// Delegate to the View object for rendering.
		if (logger.isDebugEnabled()) {
			logger.debug("Rendering view [" + view + "] in DispatcherServlet with name '" + getServletName() + "'");
		}
		try {
			if (mv.getStatus() != null) {
				response.setStatus(mv.getStatus().value());
			}
			view.render(mv.getModelInternal(), request, response);
		}
		catch (Exception ex) {
			if (logger.isDebugEnabled()) {
				logger.debug("Error rendering view [" + view + "] in DispatcherServlet with name '" +
						getServletName() + "'", ex);
			}
			throw ex;
		}
	}
```
#### 解析视图名称
在上文中我们提到DispatcherServ let 会根据Mode!AndView 选择合适的视图来进行渲染，而这一功能就是在resolveViewName 函数中完成的
```java
//DispatcherServlet
protected View resolveViewName(String viewName, Map<String, Object> model, Locale locale,
			HttpServletRequest request) throws Exception {

		for (ViewResolver viewResolver : this.viewResolvers) {
			View view = viewResolver.resolveViewName(viewName, locale);
			if (view != null) {
				return view;
			}
		}
		return null;
	}
```
我们以org.Springframework.web.servletview.InternalResourceViewResolver 为例来分析
```java
//AbstractCachingViewResolver
@Override
	public View resolveViewName(String viewName, Locale locale) throws Exception {
        //不存在缓存的情况下直接创建视图
		if (!isCache()) {
			return createView(viewName, locale);
		}
		else {
            //直接从缓存中提取
			Object cacheKey = getCacheKey(viewName, locale);
			View view = this.viewAccessCache.get(cacheKey);
			if (view == null) {
				synchronized (this.viewCreationCache) {
					view = this.viewCreationCache.get(cacheKey);
					if (view == null) {
						// Ask the subclass to create the View object.
						view = createView(viewName, locale);
						if (view == null && this.cacheUnresolved) {
							view = UNRESOLVED_VIEW;
						}
						if (view != null) {
							this.viewAccessCache.put(cacheKey, view);
							this.viewCreationCache.put(cacheKey, view);
							if (logger.isTraceEnabled()) {
								logger.trace("Cached view [" + cacheKey + "]");
							}
						}
					}
				}
			}
			return (view != UNRESOLVED_VIEW ? view : null);
		}
	}
```
在父类UrlBasedViewResolver 中重写了createView 函数。
```java
//UrlBasedViewResolver
protected View createView(String viewName, Locale locale) throws Exception {
		// If this resolver is not supposed to handle the given view,
		// return null to pass on to the next resolver in the chain.
        //如果当前解析器不支持当前解析器如viewName 为空等情况
		if (!canHandle(viewName, locale)) {
			return null;
		}
        //处理前缀为redire ct : xx 的情况
		// Check for special "redirect:" prefix.
		if (viewName.startsWith(REDIRECT_URL_PREFIX)) {
			String redirectUrl = viewName.substring(REDIRECT_URL_PREFIX.length());
			RedirectView view = new RedirectView(redirectUrl, isRedirectContextRelative(), isRedirectHttp10Compatible());
			view.setHosts(getRedirectHosts());
			return applyLifecycleMethods(viewName, view);
		}
        //处理前缀为forward : xx 的情况
		// Check for special "forward:" prefix.
		if (viewName.startsWith(FORWARD_URL_PREFIX)) {
			String forwardUrl = viewName.substring(FORWARD_URL_PREFIX.length());
			return new InternalResourceView(forwardUrl);
		}
		// Else fall back to superclass implementation: calling loadView.
		return super.createView(viewName, locale);
	}
```
```java
//AbstractCachingViewResolver
protected View createView(String viewName, Locale locale) throws Exception {
		return loadView(viewName, locale);
	}
```

```java
//UrlBasedViewResolver
@Override
protected View loadView(String viewName, Locale locale) throws Exception {
    AbstractUrlBasedView view = buildView(viewName);
    View result = applyLifecycleMethods(viewName, view);
    return (view.checkResource(locale) ? result : null);
}
protected AbstractUrlBasedView buildView(String viewName) throws Exception {
    AbstractUrlBasedView view = (AbstractUrlBasedView) BeanUtils.instantiateClass(getViewClass());
    //添加前缀以及后缀
    view.setUrl(getPrefix() + viewName + getSuffix());

    String contentType = getContentType();
    if (contentType != null) {
        //设置ContentType
        view.setContentType(contentType);
    }

    view.setRequestContextAttribute(getRequestContextAttribute());
    view.setAttributesMap(getAttributesMap());

    Boolean exposePathVariables = getExposePathVariables();
    if (exposePathVariables != null) {
        view.setExposePathVariables(exposePathVariables);
    }
    Boolean exposeContextBeansAsAttributes = getExposeContextBeansAsAttributes();
    if (exposeContextBeansAsAttributes != null) {
        view.setExposeContextBeansAsAttributes(exposeContextBeansAsAttributes);
    }
    String[] exposedContextBeanNames = getExposedContextBeanNames();
    if (exposedContextBeanNames != null) {
        view.setExposedContextBeanNames(exposedContextBeanNames);
    }

    return view;
}
```
- ，我们发现对于InternalResourceViewResolver 所提供的解析功能主要考虑到了几个方面的处理。
    1. 基于效率的考虑，提供了缓存的支持。
    2. 提供了对redirect:xx 和forward:xx 前缀的支持。
    3. 添加了前缀及后缀，并向View 中加入了必需的属性设置。

#### 页面跳转
页面跳转当通过viewName 解析到对应的View 后，就可以进一步地处理跳转逻辑了。
```java
//AbstractView
@Override
public void render(Map<String, ?> model, HttpServletRequest request, HttpServletResponse response) throws Exception {
    if (logger.isTraceEnabled()) {
        logger.trace("Rendering view with name '" + this.beanName + "' with model " + model +
            " and static attributes " + this.staticAttributes);
    }

    Map<String, Object> mergedModel = createMergedOutputModel(model, request, response);
    prepareResponse(request, response);
    renderMergedOutputModel(mergedModel, getRequestToExpose(request), response);
}
```
在引导示例中，我们了解到对于ModelView 的使用，可以将一些属性直接放入其中， 然后在页面上直接通过JSTL 语法或者原始的request 获取。这是一个很方便也很神奇的功能。但是实现却并不复杂，无非是把我们将要用到的属性放入request 中，以便在其他地方可以直接调用，而解析这些属性的工作就是在createMergedOutputModel 函数中完成的。
```java
////AbstractView
protected Map<String, Object> createMergedOutputModel(Map<String, ?> model, HttpServletRequest request,
			HttpServletResponse response) {

		@SuppressWarnings("unchecked")
		Map<String, Object> pathVars = (this.exposePathVariables ?
				(Map<String, Object>) request.getAttribute(View.PATH_VARIABLES) : null);

		// Consolidate static and dynamic model attributes.
		int size = this.staticAttributes.size();
		size += (model != null ? model.size() : 0);
		size += (pathVars != null ? pathVars.size() : 0);

		Map<String, Object> mergedModel = new LinkedHashMap<String, Object>(size);
		mergedModel.putAll(this.staticAttributes);
		if (pathVars != null) {
			mergedModel.putAll(pathVars);
		}
		if (model != null) {
			mergedModel.putAll(model);
		}

		// Expose RequestContext?
		if (this.requestContextAttribute != null) {
			mergedModel.put(this.requestContextAttribute, createRequestContext(request, response, mergedModel));
		}

		return mergedModel;
	}
    //页面跳转，抽象的方法，依据不同的页面类型选择不同的页面
    protected abstract void renderMergedOutputModel(
			Map<String, Object> model, HttpServletRequest request, HttpServletResponse response) throws Exception;
```

以 InternalResourceView 为例
```java
@Override
	protected void renderMergedOutputModel(
			Map<String, Object> model, HttpServletRequest request, HttpServletResponse response) throws Exception {
        ／／将model 中的数据以属性的方式设置到request 中
		// Expose the model object as request attributes.
		exposeModelAsRequestAttributes(model, request);

		// Expose helpers as request attributes, if any.
		exposeHelpers(request);

		// Determine the path for the request dispatcher.
		String dispatcherPath = prepareForRendering(request, response);

		// Obtain a RequestDispatcher for the target resource (typically a JSP).
		RequestDispatcher rd = getRequestDispatcher(request, dispatcherPath);
		if (rd == null) {
			throw new ServletException("Could not get RequestDispatcher for [" + getUrl() +
					"]: Check that the corresponding file exists within your web application archive!");
		}

		// If already included or response already committed, perform include, else forward.
		if (useInclude(request, response)) {
			response.setContentType(getContentType());
			if (logger.isDebugEnabled()) {
				logger.debug("Including resource [" + getUrl() + "] in InternalResourceView '" + getBeanName() + "'");
			}
			rd.include(request, response);
		}

		else {
			// Note: The forwarded resource is supposed to determine the content type itself.
			if (logger.isDebugEnabled()) {
				logger.debug("Forwarding to resource [" + getUrl() + "] in InternalResourceView '" + getBeanName() + "'");
			}
			rd.forward(request, response);
		}
	}
```

## 总结

Spring Web MVC处理请求的流程
![处理流程](imgs/处理流程.jpg)

步骤：

1、  首先用户发送请求————>前端控制器，前端控制器根据请求信息（如URL）来决定选择哪一个页面控制器进行处理并把请求委托给它，即以前的控制器的控制逻辑部分；图中的1、2步骤；

2、  页面控制器接收到请求后，进行功能处理，首先需要收集和绑定请求参数到一个对象，这个对象在Spring Web MVC中叫命令对象，并进行验证，然后将命令对象委托给业务对象进行处理；处理完毕后返回一个ModelAndView（模型数据和逻辑视图名）；图中的3、4、5步骤；

3、  前端控制器收回控制权，然后根据返回的逻辑视图名，选择相应的视图进行渲染，并把模型数据传入以便视图渲染；图中的步骤6、7；

4、  前端控制器再次收回控制权，将响应返回给用户，图中的步骤8；至此整个结束。


springmvc 的核心架构
![Spring Web MVC核心架构图](imgs/springmvc架构图.jpg)

步骤：

1、  首先用户发送请求——>DispatcherServlet，前端控制器收到请求后自己不进行处理，而是委托给其他的解析器进行处理，作为统一访问点，进行全局的流程控制；

2、  DispatcherServlet——>HandlerMapping， HandlerMapping将会把请求映射为HandlerExecutionChain对象（包含一个Handler处理器（页面控制器）对象、多个HandlerInterceptor拦截器）对象，通过这种策略模式，很容易添加新的映射策略；

3、  DispatcherServlet——>HandlerAdapter，HandlerAdapter将会把处理器包装为适配器，从而支持多种类型的处理器，即适配器设计模式的应用，从而很容易支持很多类型的处理器；

4、  HandlerAdapter——>处理器功能处理方法的调用，HandlerAdapter将会根据适配的结果调用真正的处理器的功能处理方法，完成功能处理；并返回一个ModelAndView对象（包含模型数据、逻辑视图名）；

5、  ModelAndView的逻辑视图名——> ViewResolver， ViewResolver将把逻辑视图名解析为具体的View，通过这种策略模式，很容易更换其他视图技术；

6、  View——>渲染，View会根据传进来的Model模型数据进行渲染，此处的Model实际是一个Map数据结构，因此很容易支持其他视图技术；

7、返回控制权给DispatcherServlet，由DispatcherServlet返回响应给用户，到此一个流程结束。