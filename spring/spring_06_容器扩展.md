---
title: Spring_06 Bean 容器扩展
date: 2020-05-10 13:33:36
tags:
  - spring
categories:
  - spring
#top: 1
topdeclare: false
reward: true
---
## spring_06_容器扩展
- ApplicationContext 用于扩展BeanFactory现有的功能。相比于BeanFactory，ApplicationContext 提供了更多的扩展功能。因为ApplicationContext 包含了BeanFactory的所有功能，所以一般建议使用ApplicationContext。除非在一些限制场合，比如字节长度对内存有很大的影响（applet）。 绝大多数的企业应用中，就是要使用ApplicationContext， 才能完成更多的业务场景需求。

<!--more-->

- BeanFactory 的bean 在调用getBean 时才解析创建。 ApplicationContext 中的bean 在 new ApplicationContext(...) 时，加载。在构造方法内调用refresh() 方法时创建。

- 使用 BeanFactory 加载：`BeanFactory bf = new XmlBeanFactory(new ClassPathResource("beanFactoryText.xml"));`
- 使用 ApplicatioinContext 加载： `ApplicatioinContext bf = new ClassPathXmlApplicationContext("beanFactoryText.xml")`

- 一下用ClassPathXmlApplicationContext 为切入点进行分析：
```java
	// 测试方法
	public void testApplicationContext(){
		ApplicationContext context = new ClassPathXmlApplicationContext("com.zbcn.test/BeanFactoryTest.xml");
		Object test = context.getBean("test");
	}
	// 调用构造方法
	public ClassPathXmlApplicationContext(String configLocation) throws BeansException {
		this(new String[] {configLocation}, true, null);
	}
	// 
	public ClassPathXmlApplicationContext(
			String[] configLocations, boolean refresh, @Nullable ApplicationContext parent)
			throws BeansException {
		super(parent);
		//设置配置路径
		setConfigLocations(configLocations);
		if (refresh) {
			// 解析功能的实现都在 refresh中
			refresh();
		}
	}
```

### 设置配置路径
- ClassPathXmlApplicationContext 中支持多个配置文件以数组的形式传入：
```java
public void setConfigLocations(@Nullable String... locations) {
		if (locations != null) {
			Assert.noNullElements(locations, "Config locations must not be null");
			this.configLocations = new String[locations.length];
			for (int i = 0; i < locations.length; i++) {
				// 解析指定路径，如果包含特殊符号，如：${var}，那么在resolvePath 中会搜寻匹配的系统变量并且替换。
				this.configLocations[i] = resolvePath(locations[i]).trim();
			}
		}
		else {
			this.configLocations = null;
		}
	}
```

### refresh 方法分析
```java
public void refresh() throws BeansException, IllegalStateException {
		synchronized (this.startupShutdownMonitor) {
			// Prepare this context for refreshing.
			prepareRefresh();
			//初始化BeanFactory，并进行xml文件读取
			// Tell the subclass to refresh the internal bean factory.
			ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();
			//对beanFactory 进行各种功能填充
			// Prepare the bean factory for use in this context.
			prepareBeanFactory(beanFactory);
			try {
				// 子类覆盖方法，做额外处理
				// Allows post-processing of the bean factory in context subclasses.
				postProcessBeanFactory(beanFactory);
				// 激活各种BeanFactory处理器
				// Invoke factory processors registered as beans in the context.
				invokeBeanFactoryPostProcessors(beanFactory);
				// 注册拦截bean 创建的bean处理器，这里只是注册，真正的调用是在get bean 时。
				// Register bean processors that intercept bean creation.
				registerBeanPostProcessors(beanFactory);
				// 为上下文处理message 信息源，即不同语言的消息体，国际化处理。
				// Initialize message source for this context.
				initMessageSource();
				//初始化应用消息广播器，并放入 applicationEventMulticaster bean 中。
				// Initialize event multicaster for this context.
				initApplicationEventMulticaster();
				// 留给子类来初始化其他bean
				// Initialize other special beans in specific context subclasses.
				onRefresh();
				//在所有的注册bean中查找 LIstener beanm，注册到消息广播器中
				// Check for listener beans and register them.
				registerListeners();
				// 初始化剩下的单实例（飞惰性）
				// Instantiate all remaining (non-lazy-init) singletons.
				finishBeanFactoryInitialization(beanFactory);
				//完成刷新过程，通知生命周期处理器 lifecycleProcessor 刷新过程，同时发出ContextRefreshEvent 通知别人
				// Last step: publish corresponding event.
				finishRefresh();
			}
			catch (BeansException ex) {
				if (logger.isWarnEnabled()) {
					logger.warn("Exception encountered during context initialization - " +
							"cancelling refresh attempt: " + ex);
				}
				// Destroy already created singletons to avoid dangling resources.
				destroyBeans();
				// Reset 'active' flag.
				cancelRefresh(ex);
				// Propagate exception to caller.
				throw ex;
			}
			finally {
				// Reset common introspection caches in Spring's core, since we
				// might not ever need metadata for singleton beans anymore...
				resetCommonCaches();
			}
		}
	}
```
功能说明：
1. 初始化前准备工作，例如对系统属性或者环境变量的准备及验证
	- 在一些情况下，项目要读取某些系统变量，而这个变量的设置很可能会影响着系统的正确性，那么ClassPathXmlApplicationContext为我们提供的这个准备函数就显得特别重要，他可以在系统启动的时候提前对必须的变量进行存在性验证。
2. 初始化BeanFactory， 并进行xml 的读取
   - ClassPathXmlApplicationContext 包含着BeanFactory的所有特性，在这一步骤会服用BeanFactory 的配置文件读取解析以及其他功能，经过该步骤后，ClassPathXmlApplicationContext 实际上就已经BeanFactory所提供的功能，也就是可以进行bean的提取等所有功能了。
3. 对BeanFactory 进行各种填充
	- @Qualifier 与 @Autowired 是我们非常熟悉的注解，类似的注解就是在该步骤解析的。
4. 子类覆盖方法做额外处理
	- spring 之所以强大，被我们所推崇，除了其在功能上能为我们提供便利外，还有一方面是spring 自身的架构设计，开放式的架构使得我们很容易根据业务需要扩展已经存在的功能。这种开放式的的设计，在spring中随处可见，例如该 `postProcessBeanFactory` 方法。

5. 激活各种BeanFactory处理器
6. 注册拦截bean创建的bean 处理器，这里只是注册，真正的调用是在getBean 的时候
7. 为上下文初始化Message源，及对不同语言的消息进行国际化处理。
8. 初始化应用消息广播器，并放入 "applicationEventMuilticaster" 的bean中。
9.  子类初始化其他bean
10. 在所有的bean中查找listener bean，注册到消息广播中
11. 初始化剩下的单例（非惰性的）
12. 完成刷新过程，通知生命周期处理器 lifecycleProcessor刷新过程。同时发出ContextRefreshEvent通知别人。

#### 环境准备 - prepareRefresh
```java
protected void prepareRefresh() {
		// Switch to active.
		this.startupDate = System.currentTimeMillis();
		this.closed.set(false);
		this.active.set(true);
		if (logger.isDebugEnabled()) {
			if (logger.isTraceEnabled()) {
				logger.trace("Refreshing " + this);
			}
			else {
				logger.debug("Refreshing " + getDisplayName());
			}
		}
		//初始化占位符，空方法，子类实现
		// Initialize any placeholder property sources in the context environment.
		initPropertySources();
		//验证需要的属性文件是不是已经放入到环境中
		// Validate that all properties marked as required are resolvable:
		// see ConfigurablePropertyResolver#setRequiredProperties
		getEnvironment().validateRequiredProperties();
		// Store pre-refresh ApplicationListeners...
		if (this.earlyApplicationListeners == null) {
			this.earlyApplicationListeners = new LinkedHashSet<>(this.applicationListeners);
		}
		else {
			// Reset local application listeners to pre-refresh state.
			this.applicationListeners.clear();
			this.applicationListeners.addAll(this.earlyApplicationListeners);
		}
		// Allow for the collection of early ApplicationEvents,
		// to be published once the multicaster is available...
		this.earlyApplicationEvents = new LinkedHashSet<>();
	}
```
说明：
1. initPropertySources 符合spring 的开放式结构设计，给用户最大扩展spring的能力，用户可以依据自己的需要重写 initPropertyResources 方法，并在方法中进行个性化的属性处理及设置。
2. validateRequiredProperties 是对属性的校验，

如何初始化自定义环境变量
```java
public class MyClassPathXmlApplicationContext extends ClassPathXmlApplicationContext{
	public MyClassPathXmlApplicationContext(String... configLocations){
		super(configLocations);
	}
	@Override
	protected vodi initPropertySources(){
		//添加自定义环境变量
		getEnvironment().setRequiredPerperties("VAR");
	}
}
```
然后在后期调用 `getEnvironment().validateRequiredProperties();` 验证时，若没有检查到 `VAR`环境变量则抛出异常。

#### 加载beanFactory - obtainFreshBeanFactory
获取beanFactory。经过该方法后，ClassPathXmlApplicationContext 包含了BeanFactory的所有功能。
```java
//AbstractApplicationContext
protected ConfigurableListableBeanFactory obtainFreshBeanFactory() {
		//初始化beanFactory，并进行xml文件的读取，并将BeanFactory 记录到当前实体的属性中。
		refreshBeanFactory();
		//返回当前实体的BeanFactory
		return getBeanFactory();
	}
```
- refreshBeanFactory
```java
//AbstractRefreshableApplicationContext extends AbstractApplicationContext
protected final void refreshBeanFactory() throws BeansException {
		if (hasBeanFactory()) {
			destroyBeans();
			closeBeanFactory();
		}
		try {
			//创建 beanFactory
			DefaultListableBeanFactory beanFactory = createBeanFactory();
			//为了序列化指定id，如果需要的话，让这个beanFactory反序列化到BeanFactory对象。
			beanFactory.setSerializationId(getId());
			//定制beanFactory，设置相关属性，包括是否覆盖同名称不同定义的对象，循环依赖，
			//以及设置@Autowired和@Qualifier注解解析器 QualifierAnnotationAutowire
			customizeBeanFactory(beanFactory);
			//初始化document 以及进行xml文件的读取及解析
			loadBeanDefinitions(beanFactory);
			synchronized (this.beanFactoryMonitor) {
				// 在AbstractRefreshableApplicationContext中添加 beanFactory
				this.beanFactory = beanFactory;
			}
		}
		catch (IOException ex) {
			throw new ApplicationContextException("I/O error parsing bean definition source for " + getDisplayName(), ex);
		}
	}
```
说明：
我们在创建BeanFactory时：`BeanFactory bf = new XmlBeanFactory("bean.xml");` 的代码。 其中 XmlBeanFactory继承自 DefaultListableBeanFactory，并提供了 XmlBeanDefinitionReader 类型的reader 属性， DefaultListableBeanFactory 是容器的基础，必须首先实例化。

##### 定制BeanFactory - customizeBeanFactory

这里已经开始对beanFactory 扩展，在基本容器的基础上，增加了是否允许覆盖、是否允许拓展的设置。
```java
//AbstractRefreshableApplicationContext
protected void customizeBeanFactory(DefaultListableBeanFactory beanFactory) {
	//是否允许覆盖同名称不同定义的对象，allowBeanDefinitionOverriding 不为空，给BeanFactory 设置响应属性，
		if (this.allowBeanDefinitionOverriding != null) {
			beanFactory.setAllowBeanDefinitionOverriding(this.allowBeanDefinitionOverriding);
		}
		//是否允许bean之间存在循环依赖
		if (this.allowCircularReferences != null) {
			beanFactory.setAllowCircularReferences(this.allowCircularReferences);
		}
	}
```
定制 beanFactory的方式
```java 
 public class MyClasspathXmlApplicationContext extends ClassPathXmlApplicationContext{
	 @Override
	 protected void customizeBeanFactory(DefaultListableBeanFactory beanFactory) {
		 super.setAllowBeanDefinitionOverriding(false);
		 super.setAllowCircularReferences(false);
		 super.customizeBeanFactory(beanFactory);
	}
 }
```

##### 加载beanDefinition -loadBeanDefinitions
DefaultListableBeanFactory中没有xml读取处理的功能，由XmlBeanDefinitionReader 完成。该步骤中首先要做的是创建 XmlBeanDefinitionReader；
```java
//AbstractXmlApplicationContext extends AbstractRefreshableConfigApplicationContext
	@Override
	protected void loadBeanDefinitions(DefaultListableBeanFactory beanFactory) throws BeansException, IOException {
		// Create a new XmlBeanDefinitionReader for the given BeanFactory.
		XmlBeanDefinitionReader beanDefinitionReader = new XmlBeanDefinitionReader(beanFactory);
		//设置环境变量
		// Configure the bean definition reader with this context's
		// resource loading environment.
		beanDefinitionReader.setEnvironment(this.getEnvironment());
		beanDefinitionReader.setResourceLoader(this);
		beanDefinitionReader.setEntityResolver(new ResourceEntityResolver(this));
		//设置beanDefinitionReader， 可以覆盖
		// Allow a subclass to provide custom initialization of the reader,
		// then proceed with actually loading the bean definitions.
		initBeanDefinitionReader(beanDefinitionReader);
		//配置文件的读取
		loadBeanDefinitions(beanDefinitionReader);
	}
```
- 配置文件的读取 loadBeanDefinition
```java
	protected void loadBeanDefinitions(XmlBeanDefinitionReader reader) throws BeansException, IOException {
		Resource[] configResources = getConfigResources();
		if (configResources != null) {
			reader.loadBeanDefinitions(configResources);
		}
		String[] configLocations = getConfigLocations();
		if (configLocations != null) {
			reader.loadBeanDefinitions(configLocations);
		}
	}
```

#### 功能扩展

在进入 prepareBeanFactory 方法前，spring 已经完成了对配置的解析。 ApplicationContext 在功能上的扩展，从 `prepareBeanFactory` 方法开始。
```java
protected void prepareBeanFactory(ConfigurableListableBeanFactory beanFactory) {
		// 设置BeanFactory 的classLoader 为当前Context 的classLoader
		// Tell the internal bean factory to use the context's class loader etc.
		beanFactory.setBeanClassLoader(getClassLoader());
		//设置beanFactory的表达式语言处理器
		// 默认可以使用 #{bean.xxx} 的形式来处理相关属性
		beanFactory.setBeanExpressionResolver(new StandardBeanExpressionResolver(beanFactory.getBeanClassLoader()));
		//为beanFactory 增加一个默认的propertyEditor，这个主要是对bean的属性等设置管理的一个工具
		beanFactory.addPropertyEditorRegistrar(new ResourceEditorRegistrar(this, getEnvironment()));

		// Configure the bean factory with context callbacks.
		//添加BeanProcessor
		beanFactory.addBeanPostProcessor(new ApplicationContextAwareProcessor(this));
		// 设置几个忽略自动装配的接口
		beanFactory.ignoreDependencyInterface(EnvironmentAware.class);
		beanFactory.ignoreDependencyInterface(EmbeddedValueResolverAware.class);
		beanFactory.ignoreDependencyInterface(ResourceLoaderAware.class);
		beanFactory.ignoreDependencyInterface(ApplicationEventPublisherAware.class);
		beanFactory.ignoreDependencyInterface(MessageSourceAware.class);
		beanFactory.ignoreDependencyInterface(ApplicationContextAware.class);

		// BeanFactory interface not registered as resolvable type in a plain factory.
		// MessageSource registered (and found for autowiring) as a bean.
		// 设置几个自动装配的特殊规则
		beanFactory.registerResolvableDependency(BeanFactory.class, beanFactory);
		beanFactory.registerResolvableDependency(ResourceLoader.class, this);
		beanFactory.registerResolvableDependency(ApplicationEventPublisher.class, this);
		beanFactory.registerResolvableDependency(ApplicationContext.class, this);

		// Register early post-processor for detecting inner beans as ApplicationListeners.
		// 设置 ApplicationListeners
		beanFactory.addBeanPostProcessor(new ApplicationListenerDetector(this));

		// 增加对 AspectJ的支持
		// Detect a LoadTimeWeaver and prepare for weaving, if found.
		if (beanFactory.containsBean(LOAD_TIME_WEAVER_BEAN_NAME)) {
			beanFactory.addBeanPostProcessor(new LoadTimeWeaverAwareProcessor(beanFactory));
			// Set a temporary ClassLoader for type matching.
			beanFactory.setTempClassLoader(new ContextTypeMatchClassLoader(beanFactory.getBeanClassLoader()));
		}
		// 怎加默认的系统环境bean
		// Register default environment beans.
		if (!beanFactory.containsLocalBean(ENVIRONMENT_BEAN_NAME)) {
			beanFactory.registerSingleton(ENVIRONMENT_BEAN_NAME, getEnvironment());
		}
		if (!beanFactory.containsLocalBean(SYSTEM_PROPERTIES_BEAN_NAME)) {
			beanFactory.registerSingleton(SYSTEM_PROPERTIES_BEAN_NAME, getEnvironment().getSystemProperties());
		}
		if (!beanFactory.containsLocalBean(SYSTEM_ENVIRONMENT_BEAN_NAME)) {
			beanFactory.registerSingleton(SYSTEM_ENVIRONMENT_BEAN_NAME, getEnvironment().getSystemEnvironment());
		}
	}
```
以上拓展功能有：
1. 增加对SPEL 语言的支持
2. 增加对属性编辑器的支持
3. 增加一些内置类； *Aware
4. 设置了一些依赖功能可忽略的接口
5. 设置一些固定依赖的属性
6. 添加 ApplicationListeners
7. 增加 aspectJ 的支持
8. 将环境变量及属性以单例模式注册

##### 增加SpEL语言支持 Spring Expression Language
- 作用：在运行时，构建复杂表达式，存取对象属性，对象方法调用等。并且与Spring功能完美整合。如：配置 Bean的定义。
- SpEL 是单独模块，只依赖于core 模块，不依赖与其他模块，可以单独使用。
- SpEL 使用 “#{...}” 为定界符，所有的在 {} 以内的字符都被认为是 SpEL语言。如：
```xml
<bean id = "saxophone" class ="xxx.xxx.Xxx"></bean>
<bean id = "aaa" class ="xxx.xxx.AAA">
	<property name="instrument" value="#{saxophone}">
</bean>
```
相当于：
```xml
<bean id = "saxophone" class ="xxx.xxx.Xxx"></bean>
<bean id = "aaa" class ="xxx.xxx.AAA">
	<property name="instrument" ref="saxophone">
</bean>
```
- SpEL解析器注册后，实际的解析时间：
之前我们讲解过Spring 在bean 进行初始化的时候会有属性填充的一步，而在这一步中Spring 会调用AbstractAutowireCapableBeanFactory 类的applyPropertyValues 函数来完成功能。就在这个函数中，会通过构造BeanDefinitionValueResolver 类型实例valueResolver 来进行属性值的解
析。同时，也是在这个步骤中一般通过AbstractBeanFactory 中的evaluateBeanDefinitionString方法去完成SpEL 的解析。
```java
protected Object evaluateBeanDefinitionString ( String value , BeanDefinition beanDefinition) (
	if (this beanExpressionResolver == null) {
		return value ;
	}
	Scope scope = (beanDefinition 1= null ? getRegisteredScope(beanCefinition.getScope()) : null) ;
	return this.BeanExpressionResolver.evaluate(value , new BeanExpressionContext (this ,scope));
}
```
当调用这个方法时会判断是否存在语言解析器，如果存在则调用语言解析器的方法进行解析， 解析的过程是在Spring 的Expression 的包内，这里不做过多解释。我们通过查看对evaluateBeanDefinitionString方法的调用层次可以看出， 应用语言解析器的调用主要是在解析依赖注入bean 的时候，以及在完成bean 的初始化和属性获取后进行属性填充的时候。

##### 增加属性注册编辑器 - beanFactory.addPropertyEditorRegistrar(new ResourceEditorRegistrar(this, getEnvironment()));
1. 使用自定义属性编辑器
使用自定义属性编辑器，通过继承PropertyEditorSupport，重写setAsText 方法，具体步骤如下：
	1. 编写自定义属性编辑器

	```java
	//自定义属性编辑器
	public class DatePropertyEditor extends PropertyEditorSupport{
		private String formart = "yyyy-MM-dd";
		public void setFormart(String formart){
			this.formart = formart;
		}

		public void setAsText(String arg0) throws IllegalArguementException{
			System.out.println("arg0:" + arg0);
			SimpleDateFormart sdf = new SimpleDateFormart(formart);
			Date d = sdf.prase(arg0);
			this.setValue(d);
		}
	}
	```
	2. 将自定义属性编辑器注册到容器中

	```xml
	<!--－向定义属性编辑器-->
	<bean class ＝ "org.Springframework.beans.factory.config.CustomEditorConfigurer">
	<property name="customEditors">
		<map>
			<entry key="java.util.Date">
				<bean class="com.test.DatePropertyEditor">
					<property name="format" value="yyyy-MM-dd"/>
				</bean>
			</entry>
		</map>
	</property>
	</bean>
	```
2. 注册Spring 自带的属性编辑器 CustomDateEditor
通过注册Spring 自带的属性编辑器CustomDateEditor，具体步骤如下：
	1. 定义属性编辑器
	```java
	public class DatePropertyEditorRegistrar implements PropertyEditorRegistrar{
		public void registerCustomEditors(PropertyEditorRegistry registry){
			registry.registerCustomEditor(Data.class,new CustomDataEditor(new SimpleDateFormart("yyyy-MM-dd"),true));
		}
	}
	```
	2. 注册到Spring中：

	```xml
	<!--注册Spring 自带编辑器-->
	<bean class= "org.Springframework.beans.factory.config.CustomEditorConfigurer">
		<property name= "propertyEditorRegistrars" >
			<list>
				<bean class= "com.test.DatePropeortyEditorRegistrar"><／bean>
			</list>
		</property>
	</bean>
	```

	通过在配置文件中将自定义的 DatePropertyEditorRegistrar 注册进入 `org.Springframework.beans.factory.config.CustomEditorConfigurer` 的 propertyEditorRegistrars中，具体的效果和方法1相同。

- ResourceEditorRegistrar 使用说明

```java
	public void registerCustomEditors(PropertyEditorRegistry registry) {
		ResourceEditor baseEditor = new ResourceEditor(this.resourceLoader, this.propertyResolver);
		doRegisterEditor(registry, Resource.class, baseEditor);
		doRegisterEditor(registry, ContextResource.class, baseEditor);
		doRegisterEditor(registry, InputStream.class, new InputStreamEditor(baseEditor));
		doRegisterEditor(registry, InputSource.class, new InputSourceEditor(baseEditor));
		doRegisterEditor(registry, File.class, new FileEditor(baseEditor));
		doRegisterEditor(registry, Path.class, new PathEditor(baseEditor));
		doRegisterEditor(registry, Reader.class, new ReaderEditor(baseEditor));
		doRegisterEditor(registry, URL.class, new URLEditor(baseEditor));

		ClassLoader classLoader = this.resourceLoader.getClassLoader();
		doRegisterEditor(registry, URI.class, new URIEditor(classLoader));
		doRegisterEditor(registry, Class.class, new ClassEditor(classLoader));
		doRegisterEditor(registry, Class[].class, new ClassArrayEditor(classLoader));

		if (this.resourceLoader instanceof ResourcePatternResolver) {
			doRegisterEditor(registry, Resource[].class,
					new ResourceArrayPropertyEditor((ResourcePatternResolver) this.resourceLoader, this.propertyResolver));
		}
	}
	private void doRegisterEditor(PropertyEditorRegistry registry, Class<?> requiredType, PropertyEditor editor) {
		if (registry instanceof PropertyEditorRegistrySupport) {
			((PropertyEditorRegistrySupport) registry).overrideDefaultEditor(requiredType, editor);
		}
		else {
			registry.registerCustomEditor(requiredType, editor);
		}
	}
```

- 通过以上代码分析，ResourceEditorRegistrar.registerCustomEditors 方法的最后还是注册了一系列常用的属性编辑器，例如，代码doRegisterEditor(registry, Class.class, new ClassEditor(classLoader)) 实现的功能就是注册class 类对应的属性编辑器。注册后，一旦在某个实体bean中中存在一些Class类的属性，那么Spring 会调用 ClassEditor 将配置的String 类型转换为对应的class 类型，并且进行赋值。
- 疑问？：

ResourceEditorRegistrar.registerCustomEditors 方法核心功能是批量注册了常用类型的属性编辑器，但是 `beanFactory.addPropertyEditorRegistrar(new ResourceEditorRegistrar(this, getEnvironment()));` 方法仅仅是注册了 `ResourceEditorRegistrar`实例，却没有调用 `ResourceEditorRegistrar.registerCustomEditors` 进行注册，所以属性又是怎么注册进去的呢？

经过产看 `ResourceEditorRegistrar.registerCustomEditors` 方法的调用关系，发现 `AbstractBeanFactory.registerCustomEditors` 方法调用了 `ResourceEditorRegistrar.registerCustomEditors`方法。

查看 `AbstractBeanFactory.registerCustomEditors` 的调用关系：
![editorRegister](./imgs/editorRegister.jpg)
上图我们看到 `AbstractBeanFactory.initBeanWrapper`方法调用了 `AbstractBeanFactory.registerCustomEditors` 方法。这是在bean 初始化时使用的一个方法,主要是在将BeanDefinition 转换为BeanWrapp巳r 后用于对属性的填充

我们可以得出结论：在bean的初始化后会调用		`ResourceEditorRegistrar.registerCustomEditors` 方法进行批量的通用属性编辑器注册。注册后，在属性填充的环节便可以直接Spring 使用这些编辑器进行属性的解析了。

- 提到了BeanWrapper，有必要强调下，Spring 中用于封装bean 的是BeanWrapper类型，而它又间接继承了PropertyEditorRegistry 类型,也就是我们之前反复看到的方法参数 `PropertyEditorRegistry registory`，其实大部分情况下都是BeanWrapper ，对于BeanWrapper 在Spring 中的默认实现是BeanWrapperlmpl,而BeanWrapperlmpl 除了实现Bean Wrapper 接口外还继承了PropertyEditorRegistrySupport类，其中 `PropertyEditorRegistrySupport.createDefaultEditors`,
```java
private void createDefaultEditors() {
		this.defaultEditors = new HashMap<>(64);

		// Simple editors, without parameterization capabilities.
		// The JDK does not contain a default editor for any of these target types.
		this.defaultEditors.put(Charset.class, new CharsetEditor());
		this.defaultEditors.put(Class.class, new ClassEditor());
		this.defaultEditors.put(Class[].class, new ClassArrayEditor());
		this.defaultEditors.put(Currency.class, new CurrencyEditor());
		this.defaultEditors.put(File.class, new FileEditor());
		this.defaultEditors.put(InputStream.class, new InputStreamEditor());
		this.defaultEditors.put(InputSource.class, new InputSourceEditor());
		this.defaultEditors.put(Locale.class, new LocaleEditor());
		this.defaultEditors.put(Path.class, new PathEditor());
		this.defaultEditors.put(Pattern.class, new PatternEditor());
		this.defaultEditors.put(Properties.class, new PropertiesEditor());
		this.defaultEditors.put(Reader.class, new ReaderEditor());
		this.defaultEditors.put(Resource[].class, new ResourceArrayPropertyEditor());
		this.defaultEditors.put(TimeZone.class, new TimeZoneEditor());
		this.defaultEditors.put(URI.class, new URIEditor());
		this.defaultEditors.put(URL.class, new URLEditor());
		this.defaultEditors.put(UUID.class, new UUIDEditor());
		this.defaultEditors.put(ZoneId.class, new ZoneIdEditor());

		// Default instances of collection editors.
		// Can be overridden by registering custom instances of those as custom editors.
		this.defaultEditors.put(Collection.class, new CustomCollectionEditor(Collection.class));
		this.defaultEditors.put(Set.class, new CustomCollectionEditor(Set.class));
		this.defaultEditors.put(SortedSet.class, new CustomCollectionEditor(SortedSet.class));
		this.defaultEditors.put(List.class, new CustomCollectionEditor(List.class));
		this.defaultEditors.put(SortedMap.class, new CustomMapEditor(SortedMap.class));

		// Default editors for primitive arrays.
		this.defaultEditors.put(byte[].class, new ByteArrayPropertyEditor());
		this.defaultEditors.put(char[].class, new CharArrayPropertyEditor());

		// The JDK does not contain a default editor for char!
		this.defaultEditors.put(char.class, new CharacterEditor(false));
		this.defaultEditors.put(Character.class, new CharacterEditor(true));

		// Spring's CustomBooleanEditor accepts more flag values than the JDK's default editor.
		this.defaultEditors.put(boolean.class, new CustomBooleanEditor(false));
		this.defaultEditors.put(Boolean.class, new CustomBooleanEditor(true));

		// The JDK does not contain default editors for number wrapper types!
		// Override JDK primitive number editors with our own CustomNumberEditor.
		this.defaultEditors.put(byte.class, new CustomNumberEditor(Byte.class, false));
		this.defaultEditors.put(Byte.class, new CustomNumberEditor(Byte.class, true));
		this.defaultEditors.put(short.class, new CustomNumberEditor(Short.class, false));
		this.defaultEditors.put(Short.class, new CustomNumberEditor(Short.class, true));
		this.defaultEditors.put(int.class, new CustomNumberEditor(Integer.class, false));
		this.defaultEditors.put(Integer.class, new CustomNumberEditor(Integer.class, true));
		this.defaultEditors.put(long.class, new CustomNumberEditor(Long.class, false));
		this.defaultEditors.put(Long.class, new CustomNumberEditor(Long.class, true));
		this.defaultEditors.put(float.class, new CustomNumberEditor(Float.class, false));
		this.defaultEditors.put(Float.class, new CustomNumberEditor(Float.class, true));
		this.defaultEditors.put(double.class, new CustomNumberEditor(Double.class, false));
		this.defaultEditors.put(Double.class, new CustomNumberEditor(Double.class, true));
		this.defaultEditors.put(BigDecimal.class, new CustomNumberEditor(BigDecimal.class, true));
		this.defaultEditors.put(BigInteger.class, new CustomNumberEditor(BigInteger.class, true));

		// Only register config value editors if explicitly requested.
		if (this.configValueEditorsActive) {
			StringArrayPropertyEditor sae = new StringArrayPropertyEditor();
			this.defaultEditors.put(String[].class, sae);
			this.defaultEditors.put(short[].class, sae);
			this.defaultEditors.put(int[].class, sae);
			this.defaultEditors.put(long[].class, sae);
		}
	}
```
我们可以看到Spring中定义了上面一系列常用的属性编辑器使我们可以方便地进行配置。如果我们定义的bean 中的某个属性的类型不在上面的常用配置中的话，才需要我们进行个性化属性编辑器的注册。

#### 添加ApplicationContextAwareProcessor 处理器 -beanFactory.addBeanPostProcessor(new ApplicationContextAwareProcessor(this));

`beanFactory.addBeanPostProcessor(new ApplicationContextAwareProcessor(this))` 的主要目的是注册一个 BeanPostProcessor。真正的逻辑还是在 `ApplicationContextAwareProcessor`中。

` ApplicationContextAwareProcessor implements BeanPostProcessor` 在bean 实例化的时候，也就是在激活 bean 的init-method 的前后，会调用 `BeanPostProcessor.postProcessorBeforeInitialization` 和 `BeanPostProcessor.postProcessorAfterInitialization`方法。同样对 `ApplicationContextAwareProcessor` 我们也关心这两个方法。

对于 `postProcessorAfterInitialization` 方法，在 `ApplicationContextAwareProcessor` 中并没有实现。所以这里只关注 `ApplicationContextAwareProcessor.postProcessorBeforeInitialization` 方法;
```java
public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
		if (!(bean instanceof EnvironmentAware || bean instanceof EmbeddedValueResolverAware ||
				bean instanceof ResourceLoaderAware || bean instanceof ApplicationEventPublisherAware ||
				bean instanceof MessageSourceAware || bean instanceof ApplicationContextAware)){
			return bean;
		}

		AccessControlContext acc = null;

		if (System.getSecurityManager() != null) {
			acc = this.applicationContext.getBeanFactory().getAccessControlContext();
		}

		if (acc != null) {
			AccessController.doPrivileged((PrivilegedAction<Object>) () -> {
				invokeAwareInterfaces(bean);
				return null;
			}, acc);
		}
		else {
			invokeAwareInterfaces(bean);
		}

		return bean;
	}

	private void invokeAwareInterfaces(Object bean) {
		if (bean instanceof EnvironmentAware) {
			((EnvironmentAware) bean).setEnvironment(this.applicationContext.getEnvironment());
		}
		if (bean instanceof EmbeddedValueResolverAware) {
			((EmbeddedValueResolverAware) bean).setEmbeddedValueResolver(this.embeddedValueResolver);
		}
		if (bean instanceof ResourceLoaderAware) {
			((ResourceLoaderAware) bean).setResourceLoader(this.applicationContext);
		}
		if (bean instanceof ApplicationEventPublisherAware) {
			((ApplicationEventPublisherAware) bean).setApplicationEventPublisher(this.applicationContext);
		}
		if (bean instanceof MessageSourceAware) {
			((MessageSourceAware) bean).setMessageSource(this.applicationContext);
		}
		if (bean instanceof ApplicationContextAware) {
			((ApplicationContextAware) bean).setApplicationContext(this.applicationContext);
		}
	}
```
主要是一些 *Aware 接口的bean 实现。这些bean 可以获取Spring容器中的一些特殊资源。供业务使用。

##### 设置忽略依赖
当Spring 将 `ApplicationContextAwareProcessor` 注册后，那么在invokeAwareInterface方法中间接调用的 Aware 类已经不是普通的bean了。如 ResourceLoaderAware，ApplicationEventPublisherAware等，那么当然需要在Spring 做 bean 的依赖注入的时候忽略它们。而  `beanFactory.ignoreDependencyInterface` 就是此作用。

##### 注册依赖
Spring 中有了忽略依赖的功能，当让必不可少也会有注册依赖的功能。
```java
beanFactory.registerResolvableDependency(BeanFactory.class, beanFactory);
beanFactory.registerResolvableDependency(ResourceLoader.class, this);
beanFactory.registerResolvableDependency(ApplicationEventPublisher.class, this);
beanFactory.registerResolvableDependency(ApplicationContext.class, this);
```
当注册了解析依赖后，例如当注册了对BeanFactory.class 的解析依赖后，当bean 的属性注入的时候，一旦检测到属性为 BeanFactory 类型便会将 beanFactory 的实例注入进去。

### BeanFactory 的后处理

beanFactory 作为Spring 中容器功能的基础，用于存放所有已经加载的bean，为了保证程序上的高拓展性。Spring 针对BeanFactory 做了大量的扩展，比如我们熟知的 `PostProcessor` 等都在这里实现的。 注册方法是 `beanFactory.addBeanPostProcessor`
#### 子类覆盖 - postProcessBeanFactory (空方法,留给子类实现对BeanFacotry做额外的处理使用).


#### 激活注册的BeanFactoryPostProcessor  -invokeBeanFactoryPostProcessors

__对 `BeanFactoryPostProcessor` 的调用__   __调用__

- BeanFactoryPostProcessor的用法：
	`BeanFactoryPostProcessor` 接口跟 `BeanPostProcessor`类似，可以对Bean 的定义（配置元数据）进行处理。也就是说，Spring IOC 容器允许BeanFactoryPostProcessor 在容器实际实例化任何其他bean 之前读取配置元数据，并且有可能修改它。如果业务需要，我们也可以配置多个 `BeanFactoryPostProcessor`。你还可能通过设置 `order` 属性来控制 BeanFactoryPostProcessor 的执行次序（仅当 BeanFactoryPostProcessor 实现了Order 接口才可以设置此属性，因此在实现 BeanFactoryPostProcessor 时，就应到考虑先实现Order 接口。）

	如果我们想改变实际的Bean 实例（如从配置元数据中创建的对象），那么我们最好还是使用 `BeanPostProcessor`. 同样的，BeanFactoryPostProcessor 的作用范围是容器级别的。它只和我们使用的容器有关。如果我们在容器中定一个 `BeanFactoryPostProcessor`，那么它仅仅是对容器中的bean 进行后置处理。`BeanFactoryPostProcessor`不会对定义在另一个容器中的bean 做后置处理，即使这两个容器都是在统一层次上。

	spring 中存在对`BeanFactoryPostProcessor`的典型应用，如：`PropertyPlaceholderConfigurer`

- BeanFactoryPostProcessor 的典型应用： PropertyPlaceholderConfigurer
有时候，阅读Spring 的bean 描述文件时，我们会遇到如下的一些配置：
```xml
<bean id="message" class = "distConfig.HelloMessage"> 
	<property name="mes">
		<value>${bean.message}</value>
	</property>
</bean>
```
其中出现了变量的引用：${bean.message}. 这就是spring 的分散配置，可以在另外的配置文件中为 bean.message 指定值。如在bean.property 配置文件如下定义：
```property
bean.message = Hi,can you find me?
```
当访问名为 message 的bean时，mes 属性就会被配置为字符串 " Hi,can you find me?",但Spring 框架是怎么知道存在这样的配置文件呢？这就要靠 `PropertyPlaceholderConfigurer`这个类的bean：
```xml
<bean id="mesHandler" class ="org.Springframework.beans.factory.config.PropertyPlaceholderConfigurer">
	<property name ="locations">
		<list>
			<value>config/bean.properties<value>
		</list>
	</property>
</bean>
```
在这个 bean 中指定了配置文件为 config/bean.properties. 这里似乎找到了问题的答案了。但是其中还有一个问题，这个 `mesHandler` 中只不过是 Spring 框架管理的一个bean，并没有被别的bean或者对象引用，Spring的BeanFactory 是怎么知道要从这个bean 中获取配置文件信息呢？

查看层级结构可以看出 `PropertyPlaceholderConfigurer` 这个类简介继承了 `BeanFactoryPostProcessor` 接口。这是一个很特别的接口，当Spring 加载任何实现了这个接口的bean的配置时，都会在bean 工厂载入所有bean 的配置之后执行 `postProcessBeanFactory`方法。在 `PropertyPlaceholderConfigurer`类中实现了 `postProcessBeanFactory` 方法，在方法中先后调用 `mergeProperties`，`convertProperties`，`processProperties` 这三个方法，分别得到配置，将得到的配置转换为合适的类型，最后将配置内容告知 BeanFactory.

正是通过实现 `BeanFactoryPostProcessor`, BeanFactory会在实例化任何bean之前获得配置信息，从而能够正确解析bean 描述文件中的变量引用。

- 使用自定义 BeanFactoryPostProcessor (使用方式)

我们以实现 一个 `BeanFactoryPostProcessor`， 去除潜在 "流氓" 属性值的功能来展示自定义 `BeanFactoryPostProcessor` 的创建及使用，例如bean 定义中留下bollocks 这样的字眼。

使用示例: 项目SpringDemon 路径: `com.zbcn.springDemon.processor.demon.PropertyConfigurerDemo`

- 激活BeanFactoryPostProcessor (源码分析) 实例化和调用所有的 已注册的 BeanFactoryPostProcessor

具体实现在 `PostProcessorRegistrationDelegate` 中
```java
public static void invokeBeanFactoryPostProcessors(
			ConfigurableListableBeanFactory beanFactory, List<BeanFactoryPostProcessor> beanFactoryPostProcessors) {

		// Invoke BeanDefinitionRegistryPostProcessors first, if any.
		Set<String> processedBeans = new HashSet<>();
		//BeanDefinitionRegistry类型的处理
		if (beanFactory instanceof BeanDefinitionRegistry) {
			BeanDefinitionRegistry registry = (BeanDefinitionRegistry) beanFactory;
			List<BeanFactoryPostProcessor> regularPostProcessors = new ArrayList<>();
			List<BeanDefinitionRegistryPostProcessor> registryProcessors = new ArrayList<>();
			//区分普通的 processor 和 BeanDefinitionRegistryPostProcessor
			for (BeanFactoryPostProcessor postProcessor : beanFactoryPostProcessors) {
				if (postProcessor instanceof BeanDefinitionRegistryPostProcessor) {
					BeanDefinitionRegistryPostProcessor registryProcessor =
							(BeanDefinitionRegistryPostProcessor) postProcessor;
					registryProcessor.postProcessBeanDefinitionRegistry(registry);
					registryProcessors.add(registryProcessor);
				}
				else {
					regularPostProcessors.add(postProcessor);
				}
			}

			// Do not initialize FactoryBeans here: We need to leave all regular beans
			// uninitialized to let the bean factory post-processors apply to them!
			// Separate between BeanDefinitionRegistryPostProcessors that implement
			// PriorityOrdered, Ordered, and the rest.
			List<BeanDefinitionRegistryPostProcessor> currentRegistryProcessors = new ArrayList<>();

			// First, invoke the BeanDefinitionRegistryPostProcessors that implement PriorityOrdered.
			String[] postProcessorNames =
					beanFactory.getBeanNamesForType(BeanDefinitionRegistryPostProcessor.class, true, false);
			for (String ppName : postProcessorNames) {
				if (beanFactory.isTypeMatch(ppName, PriorityOrdered.class)) {
					currentRegistryProcessors.add(beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class));
					processedBeans.add(ppName);
				}
			}
			sortPostProcessors(currentRegistryProcessors, beanFactory);
			registryProcessors.addAll(currentRegistryProcessors);
			invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
			currentRegistryProcessors.clear();

			// Next, invoke the BeanDefinitionRegistryPostProcessors that implement Ordered.
			postProcessorNames = beanFactory.getBeanNamesForType(BeanDefinitionRegistryPostProcessor.class, true, false);
			for (String ppName : postProcessorNames) {
				if (!processedBeans.contains(ppName) && beanFactory.isTypeMatch(ppName, Ordered.class)) {
					currentRegistryProcessors.add(beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class));
					processedBeans.add(ppName);
				}
			}
			sortPostProcessors(currentRegistryProcessors, beanFactory);
			registryProcessors.addAll(currentRegistryProcessors);
			invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
			currentRegistryProcessors.clear();

			// Finally, invoke all other BeanDefinitionRegistryPostProcessors until no further ones appear.
			boolean reiterate = true;
			while (reiterate) {
				reiterate = false;
				postProcessorNames = beanFactory.getBeanNamesForType(BeanDefinitionRegistryPostProcessor.class, true, false);
				for (String ppName : postProcessorNames) {
					if (!processedBeans.contains(ppName)) {
						currentRegistryProcessors.add(beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class));
						processedBeans.add(ppName);
						reiterate = true;
					}
				}
				sortPostProcessors(currentRegistryProcessors, beanFactory);
				registryProcessors.addAll(currentRegistryProcessors);
				invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
				currentRegistryProcessors.clear();
			}

			// Now, invoke the postProcessBeanFactory callback of all processors handled so far.
			invokeBeanFactoryPostProcessors(registryProcessors, beanFactory);
			invokeBeanFactoryPostProcessors(regularPostProcessors, beanFactory);
		}

		else {
			// Invoke factory processors registered with the context instance.
			invokeBeanFactoryPostProcessors(beanFactoryPostProcessors, beanFactory);
		}

		// Do not initialize FactoryBeans here: We need to leave all regular beans
		// uninitialized to let the bean factory post-processors apply to them!
		String[] postProcessorNames =
				beanFactory.getBeanNamesForType(BeanFactoryPostProcessor.class, true, false);

		// Separate between BeanFactoryPostProcessors that implement PriorityOrdered,
		// Ordered, and the rest.
		List<BeanFactoryPostProcessor> priorityOrderedPostProcessors = new ArrayList<>();
		List<String> orderedPostProcessorNames = new ArrayList<>();
		List<String> nonOrderedPostProcessorNames = new ArrayList<>();
		for (String ppName : postProcessorNames) {
			if (processedBeans.contains(ppName)) {
				// skip - already processed in first phase above
			}
			else if (beanFactory.isTypeMatch(ppName, PriorityOrdered.class)) {
				priorityOrderedPostProcessors.add(beanFactory.getBean(ppName, BeanFactoryPostProcessor.class));
			}
			else if (beanFactory.isTypeMatch(ppName, Ordered.class)) {
				orderedPostProcessorNames.add(ppName);
			}
			else {
				nonOrderedPostProcessorNames.add(ppName);
			}
		}
		//按照优先级
		// First, invoke the BeanFactoryPostProcessors that implement PriorityOrdered.
		sortPostProcessors(priorityOrderedPostProcessors, beanFactory);
		invokeBeanFactoryPostProcessors(priorityOrderedPostProcessors, beanFactory);
		//按照order
		// Next, invoke the BeanFactoryPostProcessors that implement Ordered.
		List<BeanFactoryPostProcessor> orderedPostProcessors = new ArrayList<>(orderedPostProcessorNames.size());
		for (String postProcessorName : orderedPostProcessorNames) {
			orderedPostProcessors.add(beanFactory.getBean(postProcessorName, BeanFactoryPostProcessor.class));
		}
		sortPostProcessors(orderedPostProcessors, beanFactory);
		invokeBeanFactoryPostProcessors(orderedPostProcessors, beanFactory);
		//其他的
		// Finally, invoke all other BeanFactoryPostProcessors.
		List<BeanFactoryPostProcessor> nonOrderedPostProcessors = new ArrayList<>(nonOrderedPostProcessorNames.size());
		for (String postProcessorName : nonOrderedPostProcessorNames) {
			nonOrderedPostProcessors.add(beanFactory.getBean(postProcessorName, BeanFactoryPostProcessor.class));
		}
		invokeBeanFactoryPostProcessors(nonOrderedPostProcessors, beanFactory);

		// Clear cached merged bean definitions since the post-processors might have
		// modified the original metadata, e.g. replacing placeholders in values...
		beanFactory.clearMetadataCache();
	}
```
__说明:__
1. registryProcessors 记录通过硬编码或者配置方式注册的 `BeanDefinitionRegistryPostProcessors`
2. regularPostProcessors 记录的是 `BeanFactoryPostProcessor` 类型的处理器

#### 注册 BeanPostProcessor - registerBeanPostProcessors

__对`BeanPostProcessor`的注册__   __注册__

Spring 中的大部分功能都是通过狗处理器的方式进行扩展的,这是Spring框架的一个特性. 但是在BeanFactory 中其实并没有实现后处理器的自动注册,所以在调用的时候如果没有手动注册,则功能不可用.所以在 ApplicationContext 中添加了自动注册的功能.
```java
//AbstractApplicationContext
protected void registerBeanPostProcessors(ConfigurableListableBeanFactory beanFactory) {
		PostProcessorRegistrationDelegate.registerBeanPostProcessors(beanFactory, this);
	}
//PostProcessorRegistrationDelegate
public static void registerBeanPostProcessors(
			ConfigurableListableBeanFactory beanFactory, AbstractApplicationContext applicationContext) {

		String[] postProcessorNames = beanFactory.getBeanNamesForType(BeanPostProcessor.class, true, false);

		// Register BeanPostProcessorChecker that logs an info message when
		// a bean is created during BeanPostProcessor instantiation, i.e. when
		// a bean is not eligible for getting processed by all BeanPostProcessors.
		/**
		*BeanPostProcessorChecker是一个普通的信息打印,可能情况:
		* 当Spring 的配置中的后处理其还没有被注册就已经开始bean的初始化.则会在BeanPostProcessorChecker中设定信息
		*/
		int beanProcessorTargetCount = beanFactory.getBeanPostProcessorCount() + 1 + postProcessorNames.length;
		beanFactory.addBeanPostProcessor(new BeanPostProcessorChecker(beanFactory, beanProcessorTargetCount));

		// Separate between BeanPostProcessors that implement PriorityOrdered,
		// Ordered, and the rest.
		List<BeanPostProcessor> priorityOrderedPostProcessors = new ArrayList<>();
		List<BeanPostProcessor> internalPostProcessors = new ArrayList<>();
		List<String> orderedPostProcessorNames = new ArrayList<>();
		List<String> nonOrderedPostProcessorNames = new ArrayList<>();
		for (String ppName : postProcessorNames) {
			if (beanFactory.isTypeMatch(ppName, PriorityOrdered.class)) {
				BeanPostProcessor pp = beanFactory.getBean(ppName, BeanPostProcessor.class);
				priorityOrderedPostProcessors.add(pp);
				if (pp instanceof MergedBeanDefinitionPostProcessor) {
					internalPostProcessors.add(pp);
				}
			}
			else if (beanFactory.isTypeMatch(ppName, Ordered.class)) {
				orderedPostProcessorNames.add(ppName);
			}
			else {
				nonOrderedPostProcessorNames.add(ppName);
			}
		}

		// First, register the BeanPostProcessors that implement PriorityOrdered.
		sortPostProcessors(priorityOrderedPostProcessors, beanFactory);
		registerBeanPostProcessors(beanFactory, priorityOrderedPostProcessors);

		// Next, register the BeanPostProcessors that implement Ordered.
		List<BeanPostProcessor> orderedPostProcessors = new ArrayList<>(orderedPostProcessorNames.size());
		for (String ppName : orderedPostProcessorNames) {
			BeanPostProcessor pp = beanFactory.getBean(ppName, BeanPostProcessor.class);
			orderedPostProcessors.add(pp);
			if (pp instanceof MergedBeanDefinitionPostProcessor) {
				internalPostProcessors.add(pp);
			}
		}
		sortPostProcessors(orderedPostProcessors, beanFactory);
		registerBeanPostProcessors(beanFactory, orderedPostProcessors);

		// Now, register all regular BeanPostProcessors.
		List<BeanPostProcessor> nonOrderedPostProcessors = new ArrayList<>(nonOrderedPostProcessorNames.size());
		for (String ppName : nonOrderedPostProcessorNames) {
			BeanPostProcessor pp = beanFactory.getBean(ppName, BeanPostProcessor.class);
			nonOrderedPostProcessors.add(pp);
			if (pp instanceof MergedBeanDefinitionPostProcessor) {
				internalPostProcessors.add(pp);
			}
		}
		registerBeanPostProcessors(beanFactory, nonOrderedPostProcessors);
		//注册所有 MergedBeanDefinitionPostProcessor,该方法不会重复注册,在执行过程中会移除已经存在的beanPostProcessor
		// Finally, re-register all internal BeanPostProcessors.
		sortPostProcessors(internalPostProcessors, beanFactory);
		registerBeanPostProcessors(beanFactory, internalPostProcessors);
		//添加 ApplicationListenerDetector 探测器
		// Re-register post-processor for detecting inner beans as ApplicationListeners,
		// moving it to the end of the processor chain (for picking up proxies etc).
		beanFactory.addBeanPostProcessor(new ApplicationListenerDetector(applicationContext));
	}
```

##### BeanPostProcessor 和 BeanFactoryPostProcessor 的源码处理区别
- BeanFactoryPostProcessor
	处理分为两种:
	1. 硬编码
	2. 配置文件的方式

	在 `invokeBeanFactoryPostProcessors`调用时同时完成了注册和激活的功能
- BeanPostProcessor
	1. 处理方式: 配置的方式
	2. `BeanPostProcessor`并不需要调用,所以不用考虑硬编码方式,只需要将其注册给BeanFactory

#### 初始化消息资源 - initMessageSource();（国际化处理）
- 国际化信息的判断
	1. 语言类型
	2. 国家/地区类型
eg：中文本地化信息包括中国大陆地区化信息，又有中国台湾，中国香港， 还有新加坡的中文
- java.util.Locale 类表示一个本地化对象，它允许通过语言参数和国家/地区参数创建一个确定的本地化对象。
- java.util.Locale 是语言和国家/地区信息的本地化类，他是创建国际化应用的基础。
- 一下是几个实例：
```java
//1. 带有语言和国家/地区信息的本地化对象
Locale locale = new Locale("zh","CN");
//2. 只有语言信息的本地化对象
Locale locale = new Locale("zh");
//3. 等于Local("zh","CN)
Locale locale = Locale.CHINA
//4. 等于 Locale("zh");
Locale locale = Locale.CHINESE
//5. 获取本地系统默认的本地化对象
Locale locale = Locale.getDefault();
```

- JDK 的java.util 包中提供了几个支持本地化的格式化操作工具类：NumberFormat、DateFormat、MessageFormat，而在Spring 中的国际化资源操作业无非是对这些类的封装操作。一下我们介绍一下MessageFormat的用法：
```java
// 1. 信息格式化串
String pattern1 = "{0},你好，你与{1}在工商银行存入{2}元。";
String pattern2 = "At {1,time,short} On {1,date,long},{0} paid {2,number,currency}";
//2. 用户动态替换占位符参数
Object[] params = {"John",new GregorianCalendar().getTime(),1.0E3}
//3. 使用默认本地化对象信息
String msg = MessageFormat(pattern1,params);
//4. 使用指定的本地对象格式化信息
MessageFormat mf = new MessageFormat(pattern2,Locale.US);
String msg = mf.format(params); 
```

- Spring 定义了访问国际化信息的MessageSource 接口，并提供了几个容易用的实现类。
MessageSource 分别被 HierarchicalMessageSource 和 ApplicationContext 接口扩展，这里我们要看一下 HierarchicalMessageSource 接口的几个实现类：
![继承关系](./imgs/messageFormat.png)

- HierarchicalMessageSource 的最重要的连个实现类是 ResourceDundleMessageSource 和 ReloadableResourceBundleMessage。 
- 他们基于java 的ResourceBundle 基础类实现，允许仅通过资源名加载国际化资源。ReloadableResourceBundleMessage。提供了定时刷新功能，允许在不重启系统的情况下更新资源信息。
- StaticMessageSource 主要用于程序测试，他允许通过编程的方式提供国际化信息。
- DelegatingMessageSource 是为方便操作父类 MessageSource而提供的代理类。

- ResourceDundleMessageSource的实现方式：
1. 定义资源文件
	- messages.properties (默认：英文)，内容仅一句：如下：
	test=test
	- message_zh_CN.properties (简体中文)：
	test=测试
	
然后 cmd，打开命令窗口，输入 `native2ascii-encoding gbk C:\message_zh_CN.properties C:\message_zh_CN_tem.properties`. 然后将`message_zh_CN_tem.properties` 中的内容替换到 `message_zh_CN.properties`中，message_zh_CN.properties就是转码后的内容了。
2. 定义配置文件
```xml
<!--bean 的id 必须命名为messageSource，否则会抛出NoSuchMessageException-->
<bean id="messageSource" class="org.Springframework.context.support.ResourceBundleMessageSource">
	<property name="basenames">
		<list>
			<value>test/messages</value>
		</list>
	<property>
</bean>
```
3. 通过ApplicationContext 访问国际化信息
```java
String[] configs = {"applicationContext.xml"};
ApplicationContext ctx = new ClassPathXmlApplicationContext(configs);
//直接通过容器访问国际化信息
String str1 = ctx.getMessage("test",Params,Local.US);
String str2 = ctx.getMessage("test",Params,Local.CHINA);
```

##### 源码分析
- initMessageResource 方法主要功能是提取配置中定义的messageResource，并将他们记录在spring 容器 `applicationContext`中。当然，如果用户未设置资源文件的化，Spring中提供了默认的配置 DelicatingMessageResource
- 在 initMessageSource 中获取自定义资源文件的方式为：`beanFactory.getBean(MESSAGE_SPIRCE_BEAN_NAME,MessageSource.class);`，在这里，是平日那个
使用了硬编码的方式硬性规定了自定义资源文件必须为message，否则获取不到自定义资源配置。
```java
protected void initMessageSource() {
		ConfigurableListableBeanFactory beanFactory = getBeanFactory();
		if (beanFactory.containsLocalBean(MESSAGE_SOURCE_BEAN_NAME)) {
			//如果在配置中已经配置了messageSource，那么将messageSource 提取并记录在 this.messageSource中
			this.messageSource = beanFactory.getBean(MESSAGE_SOURCE_BEAN_NAME, MessageSource.class);
			// Make MessageSource aware of parent MessageSource.
			if (this.parent != null && this.messageSource instanceof HierarchicalMessageSource) {
				HierarchicalMessageSource hms = (HierarchicalMessageSource) this.messageSource;
				if (hms.getParentMessageSource() == null) {
					// Only set parent context as parent MessageSource if no parent MessageSource
					// registered already.
					hms.setParentMessageSource(getInternalParentMessageSource());
				}
			}
			if (logger.isTraceEnabled()) {
				logger.trace("Using MessageSource [" + this.messageSource + "]");
			}
		}
		else {
			// 用户没有定义配置文件，那么使用 零时 DelegatingMessageSource作为调用getMessage方法返回。
			// Use empty MessageSource to be able to accept getMessage calls.
			DelegatingMessageSource dms = new DelegatingMessageSource();
			dms.setParentMessageSource(getInternalParentMessageSource());
			this.messageSource = dms;
			beanFactory.registerSingleton(MESSAGE_SOURCE_BEAN_NAME, this.messageSource);
			if (logger.isTraceEnabled()) {
				logger.trace("No '" + MESSAGE_SOURCE_BEAN_NAME + "' bean, using [" + this.messageSource + "]");
			}
		}
	}
```
- 使用时：
```java
// AbstractApplicationContext
public String getMessage(String code, Object[] args, Locale locale)throws NoSuchMessageException{
	return getMessageSource().getMessage(code,args,locale);
}
```

#### 初始化 ApplicationEventMulticaster（事件广播器） - initApplicationEventMulticaster

##### 使用
1. 定义监听事件
```java
public class TestEvent extends ApplicationEvent{
	public String msg;

	public TestEvent(Object source){
		super(source);
	}

	public TestEvent(Object source,String msg){
		super(source);
		this.msg = msg;
	}

	public void print(){
		System.out.println(msg);
	}
}
```
2. 定义监听器
```java
public class TestListener implements ApplicationListener{

	public void onApplicationEvent(ApplicationOnEvent event){
		if(event instanceof TestEvent){
			TestEvent testEvent = (TestEvent)event;
			testEvent.print();
		}
	}
}
```
3. 添加配置文件
```xml
<bean id="testListener" class ="xxx.xxx.TestListener"></bean>
```
4. 测试
```java
public class TestMain{
	public static void main(String[] args){
		ApplicationContext context = new ClassPathXmlApplicationContext("classpath:applicationContext.xml");
		TestEvent test = new TestEvent("hello","message");
		context.publishEvent(test);
	}
}
```

- 当程序运行时，Spring 会将发出的TestEvent 事件传递给我们自定义的 `TestListener`，进行进一步处理。 此处使用了 __观察者设计模式__

##### 源码分析
```java
protected void initApplicationEventMulticaster() {
		ConfigurableListableBeanFactory beanFactory = getBeanFactory();
		//如果用户自定义了事件广播器，那么使用用户自定义的
		if (beanFactory.containsLocalBean(APPLICATION_EVENT_MULTICASTER_BEAN_NAME)) {
			this.applicationEventMulticaster =
					beanFactory.getBean(APPLICATION_EVENT_MULTICASTER_BEAN_NAME, ApplicationEventMulticaster.class);
			if (logger.isTraceEnabled()) {
				logger.trace("Using ApplicationEventMulticaster [" + this.applicationEventMulticaster + "]");
			}
		}
		else {
			//否则，使用默认的 SimpleApplicationEventMulticaster
			this.applicationEventMulticaster = new SimpleApplicationEventMulticaster(beanFactory);
			beanFactory.registerSingleton(APPLICATION_EVENT_MULTICASTER_BEAN_NAME, this.applicationEventMulticaster);
			if (logger.isTraceEnabled()) {
				logger.trace("No '" + APPLICATION_EVENT_MULTICASTER_BEAN_NAME + "' bean, using " +
						"[" + this.applicationEventMulticaster.getClass().getSimpleName() + "]");
			}
		}
	}
```
依据观察者设计模式，作为广播器，一定是用于存放监听器并在适合的时候调用监听器，查看一下源码

```java
//SimpleApplicationEventMulticaster
public void multicastEvent(ApplicationEvent event) {
		multicastEvent(event, resolveDefaultEventType(event));
	}
public void multicastEvent(final ApplicationEvent event, @Nullable ResolvableType eventType) {
		ResolvableType type = (eventType != null ? eventType : resolveDefaultEventType(event));
		Executor executor = getTaskExecutor();
		for (ApplicationListener<?> listener : getApplicationListeners(event, type)) {
			if (executor != null) {
				executor.execute(() -> invokeListener(listener, event));
			}
			else {
				invokeListener(listener, event);
			}
		}
	}
```
可以判断，当产生Spring事件的时候，会默认使用 SimpleApplicationEventMulticaster的multicastEvent来广播事件，遍历所有监听器并使用监听器中的 `void onApplicationEvent(E event);` 来进行监听器的处理。而对于每一个监听器来说，所有的广播事件都可以获取到，但是是否处理由监听器自行决定。

#### 模板方法，onRefresh() 子类去继承，进一步对业务功能进行扩展

#### 注册监听器  registerListeners();
spring 的广播器时反复提到了事件监听器，那么spring 注册监听器的时候又做了哪些逻辑操作呢？
```java
protected void registerListeners() {
		// Register statically specified listeners first.
		//硬编码的方式注册监听器
		for (ApplicationListener<?> listener : getApplicationListeners()) {
			getApplicationEventMulticaster().addApplicationListener(listener);
		}
		//配置文件方式注册监听器
		// Do not initialize FactoryBeans here: We need to leave all regular beans
		// uninitialized to let post-processors apply to them!
		String[] listenerBeanNames = getBeanNamesForType(ApplicationListener.class, true, false);
		for (String listenerBeanName : listenerBeanNames) {
			getApplicationEventMulticaster().addApplicationListenerBean(listenerBeanName);
		}

		// Publish early application events now that we finally have a multicaster...
		Set<ApplicationEvent> earlyEventsToProcess = this.earlyApplicationEvents;
		this.earlyApplicationEvents = null;
		if (earlyEventsToProcess != null) {
			for (ApplicationEvent earlyEvent : earlyEventsToProcess) {
				getApplicationEventMulticaster().multicastEvent(earlyEvent);
			}
		}
	}
```
#### 初始化非延迟加载单例 - finishBeanFactoryInitialization
完成BeanFactory的初始化工作，其中包括 ConversionService 的设置，配置冻结以及非延迟加载bean的初始化工作。
```java
protected void finishBeanFactoryInitialization(ConfigurableListableBeanFactory beanFactory) {
		// Initialize conversion service for this context.
		if (beanFactory.containsBean(CONVERSION_SERVICE_BEAN_NAME) &&
				beanFactory.isTypeMatch(CONVERSION_SERVICE_BEAN_NAME, ConversionService.class)) {
			beanFactory.setConversionService(
					beanFactory.getBean(CONVERSION_SERVICE_BEAN_NAME, ConversionService.class));
		}

		// Register a default embedded value resolver if no bean post-processor
		// (such as a PropertyPlaceholderConfigurer bean) registered any before:
		// at this point, primarily for resolution in annotation attribute values.
		if (!beanFactory.hasEmbeddedValueResolver()) {
			beanFactory.addEmbeddedValueResolver(strVal -> getEnvironment().resolvePlaceholders(strVal));
		}

		// Initialize LoadTimeWeaverAware beans early to allow for registering their transformers early.
		String[] weaverAwareNames = beanFactory.getBeanNamesForType(LoadTimeWeaverAware.class, false, false);
		for (String weaverAwareName : weaverAwareNames) {
			getBean(weaverAwareName);
		}

		// Stop using the temporary ClassLoader for type matching.
		beanFactory.setTempClassLoader(null);
		//冻结所有的bean 定义，说明bean的定义将不被修改或者任何进一步的处理。
		// Allow for caching all bean definition metadata, not expecting further changes.
		beanFactory.freezeConfiguration();
		//初始化剩下的非单例的实例。
		// Instantiate all remaining (non-lazy-init) singletons.
		beanFactory.preInstantiateSingletons();
	}
```
##### ConversionService 设置
之前我们提到过使用自定义转换器从String 转换为date 的方式。但是，Spring 还提供了另外一种转换方式：使用Converter.

1. 定义转换器
	- 之前我们了解了 自定义类型转换器从String 转换为 Date的形式。
	- 在spring 中还提供了另外一种转换方式:使用Converter. 

###### 使用
1. 定义转换器
```java
public class String2DateConverter implements Converter<String,Date>{
	@Override
	public Date convert(String arg0){
		try{
			return DateUtils.parseDate(args0, new String[]("yyyy-MM-dd HH:mm:ss"));
		}catch(ParseExceptiono e){
			return null;
		}
	}
}
```
2. 注册
```xml
<bean id="conversionService" class="org.springframework.context.support.ConversionServiceFactoryBean">
	<property name="converters">
		<list>
			<bean class="String2DateConverter"/>
		</list>
	</property>
</bean>
```
3. 测试
这样便可以使用Converter 为我们提供的功能。
```java
public void testStringToPhoneNumberConvert(){
	DefaultConversionService conversionService = new DefaultConversionService();
	String phoneNumberStr = "010-12345678";
	PhoneNumberNodel phoneNumber = conversionService.convert(phoneNumberStr,PhoneNumberModel.class);
	Assert.assertEquals("010",phoneNumber.getAreaCode());
}
```
通过以上的功能我们看到了Convert 以及 ConversionService 提供的遍历功能，其中的配置就是在当前函数中被初始化的。

###### 冻结配置
冻结所有的bean定义，说明注册bean定义将不被修改或进行任何进一步的处理。
```java
public void freezeConfiguration(){
	this.configurationFrozen = true;
	synchronized(this.beanDefinitionMap){
		this.frozenBeanDefinitionNames = StringUtils.toStringArray(this.beanDefinitionNames);
	}
}
```
###### 初始化非延时加载
ApplicationContext  实现的默认行为就是 __在启动时将所有单例bean提前进行实例化。__ 提前实例化意味着作为初始化的一部分，ApplicationContext 实例会创建并配置所有的单例bean。通常情况下这是一件好事，因为在配置中的任何错误就会立刻被发现，而这个实例化的过程是在 finitionBeamFactoryInitialization中完成的。
```java
//DefaultListableBeanFactory
public void preInstantiateSingletons() throws BeansException {
		if (logger.isTraceEnabled()) {
			logger.trace("Pre-instantiating singletons in " + this);
		}

		// Iterate over a copy to allow for init methods which in turn register new bean definitions.
		// While this may not be part of the regular factory bootstrap, it does otherwise work fine.
		List<String> beanNames = new ArrayList<>(this.beanDefinitionNames);

		// Trigger initialization of all non-lazy singleton beans...
		for (String beanName : beanNames) {
			RootBeanDefinition bd = getMergedLocalBeanDefinition(beanName);
			if (!bd.isAbstract() && bd.isSingleton() && !bd.isLazyInit()) {
				if (isFactoryBean(beanName)) {
					Object bean = getBean(FACTORY_BEAN_PREFIX + beanName);
					if (bean instanceof FactoryBean) {
						final FactoryBean<?> factory = (FactoryBean<?>) bean;
						boolean isEagerInit;
						if (System.getSecurityManager() != null && factory instanceof SmartFactoryBean) {
							isEagerInit = AccessController.doPrivileged((PrivilegedAction<Boolean>)
											((SmartFactoryBean<?>) factory)::isEagerInit,
									getAccessControlContext());
						}
						else {
							isEagerInit = (factory instanceof SmartFactoryBean &&
									((SmartFactoryBean<?>) factory).isEagerInit());
						}
						if (isEagerInit) {
							getBean(beanName);
						}
					}
				}
				else {
					getBean(beanName);
				}
			}
		}

		// Trigger post-initialization callback for all applicable beans...
		for (String beanName : beanNames) {
			Object singletonInstance = getSingleton(beanName);
			if (singletonInstance instanceof SmartInitializingSingleton) {
				final SmartInitializingSingleton smartSingleton = (SmartInitializingSingleton) singletonInstance;
				if (System.getSecurityManager() != null) {
					AccessController.doPrivileged((PrivilegedAction<Object>) () -> {
						smartSingleton.afterSingletonsInstantiated();
						return null;
					}, getAccessControlContext());
				}
				else {
					smartSingleton.afterSingletonsInstantiated();
				}
			}
		}
	}
```
#### finitionRefish
在Spring 中还提供了Lifecycle 接口，Lifecycle 中包含start/stop 方法，实现此接口后Spring会保证在启动的时候调用其start方法开始生命周期，并在spring关闭的时候调用stop方法来结束生命周期。通常用配置后台程序，在启动后一直运行（如对MQ进行轮询等）。而ApplicatioinContext 的初始化最后正是保证了这一功能。
```java
protected void finishRefresh() {
		// Clear context-level resource caches (such as ASM metadata from scanning).
		clearResourceCaches();

		// Initialize lifecycle processor for this context.
		initLifecycleProcessor();

		// Propagate refresh to lifecycle processor first.
		getLifecycleProcessor().onRefresh();

		// Publish the final event.
		publishEvent(new ContextRefreshedEvent(this));

		// Participate in LiveBeansView MBean, if active.
		LiveBeansView.registerApplicationContext(this);
	}
```
##### initLifecycleProcessor
当ApplicationContext 启动或者停止时，他会通过LifecycleProcessor 来与所有声明的bean的周期做状态更新，而在LifiecycleProcessor 的使用前首先需要初始化。
```java
protected void initLifecycleProcessor() {
		ConfigurableListableBeanFactory beanFactory = getBeanFactory();
		if (beanFactory.containsLocalBean(LIFECYCLE_PROCESSOR_BEAN_NAME)) {
			this.lifecycleProcessor =
					beanFactory.getBean(LIFECYCLE_PROCESSOR_BEAN_NAME, LifecycleProcessor.class);
			if (logger.isTraceEnabled()) {
				logger.trace("Using LifecycleProcessor [" + this.lifecycleProcessor + "]");
			}
		}
		else {
			DefaultLifecycleProcessor defaultProcessor = new DefaultLifecycleProcessor();
			defaultProcessor.setBeanFactory(beanFactory);
			this.lifecycleProcessor = defaultProcessor;
			beanFactory.registerSingleton(LIFECYCLE_PROCESSOR_BEAN_NAME, this.lifecycleProcessor);
			if (logger.isTraceEnabled()) {
				logger.trace("No '" + LIFECYCLE_PROCESSOR_BEAN_NAME + "' bean, using " +
						"[" + this.lifecycleProcessor.getClass().getSimpleName() + "]");
			}
		}
	}
```
2. onRefresh
启动所有实现了Lifecycle 接口的bean
```java
//DefaultLifecycleProcessor
	@Override
	public void onRefresh() {
		startBeans(true);
		this.running = true;
	}
	private void startBeans(boolean autoStartupOnly) {
		Map<String, Lifecycle> lifecycleBeans = getLifecycleBeans();
		Map<Integer, LifecycleGroup> phases = new HashMap<>();
		lifecycleBeans.forEach((beanName, bean) -> {
			if (!autoStartupOnly || (bean instanceof SmartLifecycle && ((SmartLifecycle) bean).isAutoStartup())) {
				int phase = getPhase(bean);
				LifecycleGroup group = phases.get(phase);
				if (group == null) {
					group = new LifecycleGroup(phase, this.timeoutPerShutdownPhase, lifecycleBeans, autoStartupOnly);
					phases.put(phase, group);
				}
				group.add(beanName, bean);
			}
		});
		if (!phases.isEmpty()) {
			List<Integer> keys = new ArrayList<>(phases.keySet());
			Collections.sort(keys);
			for (Integer key : keys) {
				phases.get(key).start();
			}
		}
	}
```
3. publishEvent
当完成ApplicationContext 初始化的时候，要通过Spring中的事件发布机制来发出ContextRefreshedEvent事件，以保证对应的监听器可以做进一步的逻辑处理。
```java
public void publishEvent(ApplicationEvent event) {
		publishEvent(event, null);
	}
protected void publishEvent(Object event, @Nullable ResolvableType eventType) {
		Assert.notNull(event, "Event must not be null");

		// Decorate event as an ApplicationEvent if necessary
		ApplicationEvent applicationEvent;
		if (event instanceof ApplicationEvent) {
			applicationEvent = (ApplicationEvent) event;
		}
		else {
			applicationEvent = new PayloadApplicationEvent<>(this, event);
			if (eventType == null) {
				eventType = ((PayloadApplicationEvent<?>) applicationEvent).getResolvableType();
			}
		}

		// Multicast right now if possible - or lazily once the multicaster is initialized
		if (this.earlyApplicationEvents != null) {
			this.earlyApplicationEvents.add(applicationEvent);
		}
		else {
			getApplicationEventMulticaster().multicastEvent(applicationEvent, eventType);
		}

		// Publish event via parent context as well...
		if (this.parent != null) {
			if (this.parent instanceof AbstractApplicationContext) {
				((AbstractApplicationContext) this.parent).publishEvent(event, eventType);
			}
			else {
				this.parent.publishEvent(event);
			}
		}
	}
```