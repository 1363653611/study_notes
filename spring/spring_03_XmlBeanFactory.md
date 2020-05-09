---
title: Spring_03 XmlBeanFactory
date: 20220-05-08 13:33:36
tags:
  - spring
categories:
  - spring
#top: 1
topdeclare: false
reward: true
---
## XmlBeanFactory
- xmlBeanFactory被表明为Deprecated. 推荐使用DefaultListableBeanFactory和XmlBeanDefinitionReader替换。
- XmlBeanFactory继承自DefaultListableBeanFactory，扩展了从xml文档中读取bean definition的能力。XmlBeanFactory是硬编码（hard coded）的方式，不利与扩展。从本质上讲，XmlBeanFactory等同于DefaultListableBeanFactory+XmlBeanDefinitionReader ，如果有更好的需求，可以考虑使用DefaultListableBeanFactory+XmlBeanDefinitionReader方案，因为该方案可以从多个xml文件读取资源，并且在解析xml上具有更灵活的可配置性。

<!--more-->

```java
public void testXmlBeanFactory(){
		Resource resource = new ClassPathResource("com.zbcn.test/BeanFactoryTest.xml");
		BeanFactory beanFactory = new XmlBeanFactory(resource);
		TestBean testBean = beanFactory.getBean("test", TestBean.class);
		Assert.notNull(testBean);
	}
```

### Resource 配置文件
spring 的配置文件是通过ClassPathResource 进行封装的。ClasspathResource 完成的共 能：
1. 将不同的资源抽象成不同的url，通过注册不同的handler(UrlStreamHandler) 来处理不同来源的资源的读取逻辑。
  - handler 的类型使用不同的前缀（协议，protocol）来识别。如：“file：”；“http：”；“jar：” 等。
2. url 没有默认定义相对 classpath 或者ServletContext 等资源的handler，虽然可以注册自己的URLStreamHandler 来解析特定的url 前缀。比如：“classpath：”，然而，这要了解URL 的实现机制。而且URL也没有提供一些基本的方法。如：检查资源是否存在，检查资源是否可读等。因此，spring对其内部使用到的资源，实现了自己的抽象结构：__Resource__ 接口，开封装底层的资源。

```java
public interface Resource extends InputStreamSource {
	// 存在性
	boolean exists();
	//可读性
	default boolean isReadable() {
		return exists();
	}
	// 是否处于打开状态
	default boolean isOpen() {
		return false;
	}
	default boolean isFile() {
		return false;
	}

	URL getURL() throws IOException;

	URI getURI() throws IOException;

	File getFile() throws IOException;

	default ReadableByteChannel readableChannel() throws IOException {
		return Channels.newChannel(getInputStream());
	}
	long contentLength() throws IOException;
	// 最后修改时间
	long lastModified() throws IOException;
	//创建相对资源
	Resource createRelative(String relativePath) throws IOException;
	// 不带路径的文件名
	@Nullable
	String getFilename();
	// 在错误处理中的打印信息
	String getDescription();

}
```
![Resource继承图.jpg](./imgs/Resource继承图.jpg)
在日常开发中如果想加载资源文件,可以用：
```java
Resource resource = new ClassPathResource("BeanFactoryTest.xml");
InputStream inputStream = resource.getInputStream();
```
得到 `inputstream` 后，正常操作即可。

实现原理：
1. ClassPathResource 是通过class 或者classLoader 提供的底层方法来实现的
```java
//ClassPathResource
@Override
	public InputStream getInputStream() throws IOException {
		InputStream is;
		if (this.clazz != null) {
			is = this.clazz.getResourceAsStream(this.path);
		}
		else if (this.classLoader != null) {
			is = this.classLoader.getResourceAsStream(this.path);
		}
		else {
			is = ClassLoader.getSystemResourceAsStream(this.path);
		}
		if (is == null) {
			throw new FileNotFoundException(getDescription() + " cannot be opened because it does not exist");
		}
		return is;
	}
```
2. FileSystemResource 是通过 调用FileInputStream 来实现的。
```java
@Override
	public InputStream getInputStream() throws IOException {
		try {
			return Files.newInputStream(this.filePath);
		}
		catch (NoSuchFileException ex) {
			throw new FileNotFoundException(ex.getMessage());
		}
	}
```

### XmlBeanDefinitionReader
从Resource 完成了配置文件的封装和获取后，文件的读取工作就完全交给 XmlBeanDefinitionReader了。

- XmlBeanFactory 方法分析：
```java
public class XmlBeanFactory extends DefaultListableBeanFactory {

	private final XmlBeanDefinitionReader reader = new XmlBeanDefinitionReader(this);
	/**
	 * Create a new XmlBeanFactory with the given resource,
	 * which must be parsable using DOM.
	 * @param resource the XML resource to load bean definitions from
	 * @throws BeansException in case of loading or parsing errors
	 */
	public XmlBeanFactory(Resource resource) throws BeansException {
		this(resource, null);
	}
	/**
	 * Create a new XmlBeanFactory with the given input stream,
	 * which must be parsable using DOM.
	 * @param resource the XML resource to load bean definitions from
	 * @param parentBeanFactory parent bean factory 用于父类合并，可以为空
	 * @throws BeansException in case of loading or parsing errors
	 */
	public XmlBeanFactory(Resource resource, BeanFactory parentBeanFactory) throws BeansException {
		super(parentBeanFactory);
		this.reader.loadBeanDefinitions(resource);
	}
}
```
- `	super(parentBeanFactory);`  
以上代码调用如下
```java
class AbstractAutowireCapableBeanFactory{
  public AbstractAutowireCapableBeanFactory(@Nullable BeanFactory parentBeanFactory) {
		this();
		setParentBeanFactory(parentBeanFactory);
	}
  public AbstractAutowireCapableBeanFactory() {
		super();
    // 忽略给定接口的自动装配功能
		ignoreDependencyInterface(BeanNameAware.class);
		ignoreDependencyInterface(BeanFactoryAware.class);
		ignoreDependencyInterface(BeanClassLoaderAware.class);
	}
}
```
- `ignoreDependencyInterface` 方法的作用是： 忽略给定接口的自动装配功能。
目的： 自动装配时，忽略给定的依赖接口，典型的应用是通过其他方式解析Application上下文注册依赖。类似与BeanFactory 通过BeanFactoryAware 进行注入或者ApplicationContext 通过 ApplicatonContextAware 进行注入。

eg：当A 中有属性B,当Spring 在获取A 的bean 时，如果B还没有初始化，则先初始化B，但是在某些情况下B也是不会被初始化的。其中一种情况是B实现了BeanNameAware 接口。

- `this.reader.loadBeanDefinitions(resource);`资源加载的真正实现

### 加载Bean
- 对`this.reader.loadBeanDefinitions(resource)` 分析
资源加载及准备
![loadBeanDefiniton时序图.jpg](./imgs/loadBeanDefiniton时序图.jpg)
解析document，regisitBeanDefinition
![regisitBeanDefinition.jpg](./imgs/regisitBeanDefinition.jpg)

- 以上是XmlBeanDefinitionReader解析.xml 文件之前啊的准备工作。
  1. 封装资源： 使用EncodeResource
  2. 从Resource 获取输入流InputStream，并获取对应的InputResource。
  3. 通过Resource 实例和InputResource实例来调用doLoadDefinition 方法。

  __数据准备阶段__：
  1. 对传入的resource 资源进行封装（EncodedResource），目的是考虑到Resource可能存在编码要求的情况。
  2. 通过SAX读取XML文件的方式来准备InputResource对象
  3. 将钟被的数据通过参数传入真正的核心处理部分 doLoadBeanDefinitions(inputResource,EncodedResource.getResource())

- 对 doLoadBeanDefinitions 分析
```java
//XmlBeanDefinitionReader extends AbstractBeanDefinitionReader
  protected int doLoadBeanDefinitions(InputSource inputSource, Resource resource){
  			Document doc = doLoadDocument(inputSource, resource);
  			return registerBeanDefinitions(doc, resource);

  }
  protected Document doLoadDocument(InputSource inputSource, Resource resource) throws Exception {
  		return this.documentLoader.loadDocument(inputSource, getEntityResolver(), this.errorHandler,
  				getValidationModeForResource(resource), isNamespaceAware());
  	}
  // 通过指定的resource获取校验模型
  protected int getValidationModeForResource(Resource resource) {
		int validationModeToUse = getValidationMode();
		if (validationModeToUse != VALIDATION_AUTO) {
			return validationModeToUse;
		}
		int detectedMode = detectValidationMode(resource);
		if (detectedMode != VALIDATION_AUTO) {
			return detectedMode;
		}
		// Hmm, we didn't get a clear indication... Let's assume XSD,
		// since apparently no DTD declaration has been found up until
		// detection stopped (before finding the document's root tag).
		return VALIDATION_XSD;
	}
```
上面代码中均删除了异常，主要功能：
1. 获取对xml文件的验证模式
2. 加载xml文件，并得到对应的document
3. 根据document 注册bean信息（BeanDefinitions）

### xml的验证模式
xml 的验证模式可以保证xml文件的正确性。比较常用的验证模式有两种：DTD 和XSD.

#### DTD
- DTD (Document Type Definition) 文档类型定义。是一种XML约束模式语言，是xml文件的验证机制，属于xml文件组成的一部分。
- DTD 是一种保证XML文件格式正确性的有效办法，可以比较XML文档和DTD文件来看文档是否符合规范，元素和标签是否使用正确。
- DTD 文档包含：元素的定义规则，元素间关系的定义规则，元素的可使用属性，可使用的实体符合规则。
- 要使用DTD 验证模式的时候需要在XML 文件的头部声明。

spring 配置文件DTD头部声明：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE beans PUBLIC "-//SPRING//DTD BEAN 2.0//EN" "http://www.springframework.org/dtd/spring-beans-2.0.dtd">
<beans>
</beans>
```

#### XSD
（XML Schemas Definition）XML Schema 语言。XML Schema 描述了XML 文档的结构。可以用xml schema来验证某个xml文档，以检查某个xml文件是否符合要求。
- 文档设计者可以通过 xml schame 指定一个xml 文档所允许的结构和内容。并据此检查文档是否符合其要求。
- XML schema 本身十一个xml文档，它符合xml语法结构，可以通过xml解析器来解析它
- 使用xml schema对文档进行检查的要求：
  1.  `xmlns`:申明命名空间 `xmlns="http://www.springframework.org/schema/beans"`
    - 命名空间： 我们可以为元素定义一个命名空间， 将一个很长的， 可以保证全局唯一性的字符串与该元素关联起来。这样就可以避免命名冲突了
  2. `xmlns:xsi`: 在不同的 xml 文档中似乎都会出现。 这是因为 xsi 已经成为了一个业界默认的用于 __XSD(（XML Schema Definition) 文件的命名空间__。 而 XSD 文件（也常常称为 Schema 文件）是用来定义 xml 文档结构的。
  2. `xsi:schemaLocation`: 指定 命名空间所对应的xml schame文档的存储位置 ：
  ```
  xsi:schemaLocation="http://www.springframework.org/schema/beans
                http://www.springframework.org/schema/beans/spring-beans.2.5.xsd"
  ```
  包含两部分：
    1. 名称空间的uri
    2. 该名称空间所标识的xml Schema 文件标识的存储位置或者url地址

spring 配置文件XSD头部声明：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.springframework.org/schema/beans
                http://www.springframework.org/schema/beans/spring-beans-2.5.xsd">
</beans>
```

### 验证模式获取：
spring 通过 `getValidationModeForResource` 方法来获取验证模式
```java
//XmlBeanDefinitionReader extends AbstractBeanDefinitionReader
// 通过指定的resource获取校验模型
protected int getValidationModeForResource(Resource resource) {
  int validationModeToUse = getValidationMode();
  // 如果手动指定了验证模式，则使用手动指定
  if (validationModeToUse != VALIDATION_AUTO) {
    return validationModeToUse;
  }
  // 为指定则自动检测
  int detectedMode = detectValidationMode(resource);
  if (detectedMode != VALIDATION_AUTO) {
    return detectedMode;
  }
  // Hmm, we didn't get a clear indication... Let's assume XSD,
  // since apparently no DTD declaration has been found up until
  // detection stopped (before finding the document's root tag).
  return VALIDATION_XSD;
}
```

### 获取Document
最后一步准备工作是Document加载
```java
//XmlBeanDefinitionReader extends AbstractBeanDefinitionReader
protected int doLoadBeanDefinitions(InputSource inputSource, Resource resource){
  Document doc = doLoadDocument(inputSource, resource);
  return registerBeanDefinitions(doc, resource);
}
// DefaultDocumentLoader implements DocumentLoader
@Override
	public Document loadDocument(InputSource inputSource, EntityResolver entityResolver,
			ErrorHandler errorHandler, int validationMode, boolean namespaceAware) throws Exception {

		DocumentBuilderFactory factory = createDocumentBuilderFactory(validationMode, namespaceAware);
		if (logger.isDebugEnabled()) {
			logger.debug("Using JAXP provider [" + factory.getClass().getName() + "]");
		}
		DocumentBuilder builder = createDocumentBuilder(factory, entityResolver, errorHandler);
		return builder.parse(inputSource);
}
```
#### EntityResolver
- 如果SAX需要实现自定义外部实体，则必须实现此接口使用setEntityResolver 方法想SAX驱动器注册一个实例。
- 对解析一个xml，SAX 首先对取该xml文档上的声明，根据申明取寻找响应的DTD定义，以便于对文档进行验证。默认的规则是通过网络（实现上就是通过声明DTD的url地址）来下载一个DTD申明，并进行认证。当网络不通，这里会报错，原因是DTD申明没有被找到。
- EntityResolver 的作用就是项目本身就可以提供一个寻找DTD申明的方法，由程序来实现寻找DTD申明的过程，我们可以将dtd 文件本地的某个项目中，实现本地读取DTD文件直接返回给SAX。

```java
public interface EntityResolver {
  public abstract InputSource resolveEntity (String publicId,
                                              String systemId)
       throws SAXException, IOException;

}
```
1. 声明XSD 验证模式：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.springframework.org/schema/beans
                http://www.springframework.org/schema/beans/spring-beans-2.5.xsd">
</beans>
```
可以取到的参数：
- publicId：null
- systemId：http://www.springframework.org/schema/beans/spring-beans-2.5.xsd

2. 声明DTD 验证模式：
```java
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE beans PUBLIC "-//SPRING//DTD BEAN 2.0//EN" "http://www.springframework.org/dtd/spring-beans-2.0.dtd">
<beans>
</beans>
```
可以取到的参数：
- publicId：-//SPRING//DTD BEAN 2.0//EN
- systemId：http://www.springframework.org/dtd/spring-beans-2.0.dtd

3. spring 中的验证文件都是放置在自己的工程中的，具体的实现如下：
```java
//DelegatingEntityResolver
@Override
	@Nullable
	public InputSource resolveEntity(String publicId, @Nullable String systemId) throws SAXException, IOException {
		if (systemId != null) {
			if (systemId.endsWith(DTD_SUFFIX)) {
				return this.dtdResolver.resolveEntity(publicId, systemId);
			}
			else if (systemId.endsWith(XSD_SUFFIX)) {
				return this.schemaResolver.resolveEntity(publicId, systemId);
			}
		}
		return null;
	}
```
### 解析及注册BeanDefinitions
```java
// XmlBeanDefinitionReader
public int registerBeanDefinitions(Document doc, Resource resource) throws BeanDefinitionStoreException {
		//获取DefautBeanDefinitionDocumentReader
		BeanDefinitionDocumentReader documentReader = createBeanDefinitionDocumentReader();
		//统计之前注册的BeanDefinition的数量
		int countBefore = getRegistry().getBeanDefinitionCount();
		// 加载及注册BeanDefinition的核心方法
		documentReader.registerBeanDefinitions(doc, createReaderContext(resource));
		// 获取本次加载的BeanDefinition的数量
		return getRegistry().getBeanDefinitionCount() - countBefore;
	}
	//DefautBeanDefinitionDocumentReader
	@Override
		public void registerBeanDefinitions(Document doc, XmlReaderContext readerContext) {
			this.readerContext = readerContext;
			logger.debug("Loading bean definitions");
			Element root = doc.getDocumentElement();
			doRegisterBeanDefinitions(root);
		}
		/**
	 * Register each bean definition within the given root {@code <beans/>} element.
	 */
	@SuppressWarnings("deprecation")  // for Environment.acceptsProfiles(String...)
	protected void doRegisterBeanDefinitions(Element root) {
		// Any nested <beans> elements will cause recursion in this method. In
		// order to propagate and preserve <beans> default-* attributes correctly,
		// keep track of the current (parent) delegate, which may be null. Create
		// the new (child) delegate with a reference to the parent for fallback purposes,
		// then ultimately reset this.delegate back to its original (parent) reference.
		// this behavior emulates a stack of delegates without actually necessitating one.
		// 专门处理解析
		BeanDefinitionParserDelegate parent = this.delegate;
		this.delegate = createDelegate(getReaderContext(), root, parent);

		if (this.delegate.isDefaultNamespace(root)) {
			//处理profile属性
			String profileSpec = root.getAttribute(PROFILE_ATTRIBUTE);
			if (StringUtils.hasText(profileSpec)) {
				String[] specifiedProfiles = StringUtils.tokenizeToStringArray(
						profileSpec, BeanDefinitionParserDelegate.MULTI_VALUE_ATTRIBUTE_DELIMITERS);
				// We cannot use Profiles.of(...) since profile expressions are not supported
				// in XML config. See SPR-12458 for details.
				if (!getReaderContext().getEnvironment().acceptsProfiles(specifiedProfiles)) {
					if (logger.isInfoEnabled()) {
						logger.info("Skipped XML bean definition file due to specified profiles [" + profileSpec +
								"] not matching: " + getReaderContext().getResource());
					}
					return;
				}
			}
		}
		//空方法，解析xml前处理，面向继承设计。
		preProcessXml(root);
		parseBeanDefinitions(root, this.delegate);
		//空方法，解析xml后处理，面向继承设计。
		postProcessXml(root);
		this.delegate = parent;
	}
```

### 解析并注册 BeanDefinition
```java
//DefaultBeanDefinitionDocumentReader
	/**
	 * Parse the elements at the root level in the document:
	 * "import", "alias", "bean".
	 * @param root the DOM root element of the document
	 */
	protected void parseBeanDefinitions(Element root, BeanDefinitionParserDelegate delegate) {
		if (delegate.isDefaultNamespace(root)) {
			NodeList nl = root.getChildNodes();
			for (int i = 0; i < nl.getLength(); i++) {
				Node node = nl.item(i);
				if (node instanceof Element) {
					Element ele = (Element) node;
					if (delegate.isDefaultNamespace(ele)) {
						parseDefaultElement(ele, delegate);
					}
					else {
						delegate.parseCustomElement(ele);
					}
				}
			}
		}
		else {
			delegate.parseCustomElement(root);
		}
	}
```

- spring 对xml 的解析分为两类
	- spring默认的： `<bean id="test" class = "test.TestBean"\>` 
		- `parseDefaultElement(ele, delegate);`
	- 另一类就是自定义的， 如： `<tx：annotation-driver/>`
		- `delegate.parseCustomElement(ele);`
- 两种解析方式差别特别大。 如果是spirng默认配置，spirng 解析方式内置，如果是用户自定医的，就需要用户实现一些接口及配置了。

## 参考
- xml 文件头部含义：https://blog.csdn.net/lengxiao1993/article/details/77914155
