---
title: Spring_07 spring AOP
date: 2020-05-11 13:33:36
tags:
  - spring
categories:
  - spring
#top: 1
topdeclare: false
reward: true
---
# spring AOP
面向对象编程（OOP），有个局限，当需要为多个不具有继承关系的对象引入一个公共的行为时，例如log，安全检测等，我们只有在每个对象列引入公共行为，这样程序里就产生了大量的公共代码。所以，面向切面编程（AOP）技术就运用而生。AOP关注的是横向的，不同于oop的纵向。

<!--more-->

- @AspectJ 注解对pojo进行注解。从而定义一个包含切点的信息和增强横切逻辑的切面。
- @AspectJ 使用AspectJ切点语法表达式语法进行切点定义，可以通过切点函数，运算符，通配符等高级功能进行切点定义，拥有前端打的链接点描述能力。

## 实例(略)

## 动态AOP 自定义标签
```xml
<!--@AspectJ-->
<aop:aspectj-autoproxy/>
```
spring 中使用了自定义注解,那么在程序的某个地方,一定注册了对应的解析器. 我们尝试搜索整个代码.发现 `AopNamespaceHandler` 中对应着这样一段代码:
```java
public class AopNamespaceHandler extends NamespaceHandlerSupport {

	/**
	 * Register the {@link BeanDefinitionParser BeanDefinitionParsers} for the
	 * '{@code config}', '{@code spring-configured}', '{@code aspectj-autoproxy}'
	 * and '{@code scoped-proxy}' tags.
	 */
	@Override
	public void init() {
		// In 2.0 XSD as well as in 2.1 XSD.
		registerBeanDefinitionParser("config", new ConfigBeanDefinitionParser());
        //关键点: 一旦遇到 aspectj-autoproxy 注解时,就会使用AspectJAutoProxyBeanDefinitionParser解析
		registerBeanDefinitionParser("aspectj-autoproxy", new AspectJAutoProxyBeanDefinitionParser());
		registerBeanDefinitionDecorator("scoped-proxy", new ScopedProxyBeanDefinitionDecorator());

		// Only in 2.0 XSD: moved to context namespace as of 2.1
		registerBeanDefinitionParser("spring-configured", new SpringConfiguredBeanDefinitionParser());
	}
}
```
## 注册 AnnotationAwareAspectJAutoProxyCreator
所有的解析器,因为对 beanDefinitionParser 接口统一实现,入口都是从Parser 函数开始的,AspectJAutoProxyBeanDefinitionParser 的paser函数如下:
```java
class AspectJAutoProxyBeanDefinitionParser implements BeanDefinitionParser {

	@Override
	public BeanDefinition parse(Element element, ParserContext parserContext) {
        //注册 AnnotationAwareAspectJAutoProxyCreator
		AopNamespaceUtils.registerAspectJAnnotationAutoProxyCreatorIfNecessary(parserContext, element);
        //拓展功能
		extendBeanDefinition(element, parserContext);
		return null;
	}
}
```

### AopNamespaceUtils.registerAspectJAnnotationAutoProxyCreatorIfNecessary函数是关键逻辑
```java
//AopNamespaceUtils
public static void registerAspectJAnnotationAutoProxyCreatorIfNecessary(
			ParserContext parserContext, Element sourceElement) {
        // 注册或者升级 AutoProxyCreator 定义为Org.springframework.aop.config.internalAutoProxyCreator 的beanDefinition
		BeanDefinition beanDefinition = AopConfigUtils.registerAspectJAnnotationAutoProxyCreatorIfNecessary(
				parserContext.getRegistry(), parserContext.extractSource(sourceElement));
        //对于 proxy-target-class 以及 expose-proxy属性的处理
		useClassProxyingIfNecessary(parserContext.getRegistry(), sourceElement);
        //注册组件并通知,一不安与监听器进一步处理
        //其中 beanDefintion 的 className 为 AnnotationAwareAspectJAutoProxyCreator
		registerComponentIfNecessary(beanDefinition, parserContext);
	}
```

#### 注册或者 升级 AnnotationAwareAspectJAutoProxyCreator
对于aop 的实现,基本上是基于 AnnotationAwareAspectJAutoProxyCreator 去完成的,他可以根据 @Point 注解定义的切点来自动代理相匹配的bean. 但是为了简便,spring使用自定义配置来帮助我们自动注册AnnotationAwareAspectJAutoProxyCreator,其注册过程如下:
```java
//AopNamespaceUtils
public static BeanDefinition registerAspectJAnnotationAutoProxyCreatorIfNecessary(BeanDefinitionRegistry registry, Object source) {
		return registerOrEscalateApcAsRequired(AnnotationAwareAspectJAutoProxyCreator.class, registry, source);
	}
private static BeanDefinition registerOrEscalateApcAsRequired(Class<?> cls, BeanDefinitionRegistry registry, Object source) {
		Assert.notNull(registry, "BeanDefinitionRegistry must not be null");
        //如果已经存在了自动代理创建器且自动代理创建器与现在的不一致,那么需要根据优先级来判断到底使用哪个
		if (registry.containsBeanDefinition(AUTO_PROXY_CREATOR_BEAN_NAME)) {
			BeanDefinition apcDefinition = registry.getBeanDefinition(AUTO_PROXY_CREATOR_BEAN_NAME);
			if (!cls.getName().equals(apcDefinition.getBeanClassName())) {
				int currentPriority = findPriorityForClass(apcDefinition.getBeanClassName());
				int requiredPriority = findPriorityForClass(cls);
				if (currentPriority < requiredPriority) {
                    //改变bean 最重要的是改变bean 对应的className属性
					apcDefinition.setBeanClassName(cls.getName());
				}
			}
            //如果已经存在自动代理创建器和将要创建的一致,则无需再次创建
			return null;
		}
		RootBeanDefinition beanDefinition = new RootBeanDefinition(cls);
		beanDefinition.setSource(source);
		beanDefinition.getPropertyValues().add("order", Ordered.HIGHEST_PRECEDENCE);
		beanDefinition.setRole(BeanDefinition.ROLE_INFRASTRUCTURE);
		registry.registerBeanDefinition(AUTO_PROXY_CREATOR_BEAN_NAME, beanDefinition);
		return beanDefinition;
	}
```

#### 处理proxy-target-class 和expose-proxy 属性
useClassProxyingIfNecessary 实现了 proxy-target-class 和 expose-proxy 的处理
```java
private static void useClassProxyingIfNecessary(BeanDefinitionRegistry registry, Element sourceElement) {
		if (sourceElement != null) {
            //proxy-class-class 的处理
			boolean proxyTargetClass = Boolean.valueOf(sourceElement.getAttribute(PROXY_TARGET_CLASS_ATTRIBUTE));
			if (proxyTargetClass) {
				AopConfigUtils.forceAutoProxyCreatorToUseClassProxying(registry);
			}
            //expose-proxy 属性的处理
			boolean exposeProxy = Boolean.valueOf(sourceElement.getAttribute(EXPOSE_PROXY_ATTRIBUTE));
			if (exposeProxy) {
				AopConfigUtils.forceAutoProxyCreatorToExposeProxy(registry);
			}
		}
	}
```

- AopConfigUtils.forceAutoProxyCreatorToUseClassProxying

```java
//强制使用也是一个设置属性的过程
public static void forceAutoProxyCreatorToUseClassProxying(BeanDefinitionRegistry registry) {
		if (registry.containsBeanDefinition(AUTO_PROXY_CREATOR_BEAN_NAME)) {
			BeanDefinition definition = registry.getBeanDefinition(AUTO_PROXY_CREATOR_BEAN_NAME);
			definition.getPropertyValues().add("proxyTargetClass", Boolean.TRUE);
		}
	}
```
- AopConfigUtils.forceAutoProxyCreatorToExposeProxy
```java
static void forceAutoProxyCreatorToExposeProxy(BeanDefinitionRegistry registry) {
		if (registry.containsBeanDefinition(AUTO_PROXY_CREATOR_BEAN_NAME)) {
			BeanDefinition definition = registry.getBeanDefinition(AUTO_PROXY_CREATOR_BEAN_NAME);
			definition.getPropertyValues().add("exposeProxy", Boolean.TRUE);
		}
	}
```

- proxy-target-class: Spring-AOP 部分,使用JDK动态代理或者 CJLIB来为目标对象创建代理.(建议尽量使用JDK动态代理),如果被代理的目标对象至少实现了一个接口,则会使用JDK动态代理.所有该目标类型实现的接口都将会被代理.

- 若该目标类没有实现任何接口,则创建一个CJLIB动态代理.如果希望强制使用CJLIB来对目标对象创建代理(代理目标对象的所有方法,而不是实现自接口的方法),也可以.需要考虑如下两个问题:
    1. 无法通知(advise) final 方法,因为他们不能被覆盖
    2. 我们需要引入CGLIB字节码包

- JDK 本身提供了动态代理,强制使用 CGLIB 动态代理,需要将 `<aop:config>` 的proxy-target-class 属性设置为true
```xml
<aop:config proxy-target-class="true">...</aop:config>
```
- 需要CGLIB 代理和@AspectJ 自动代理支持,可以按照以下方式设置<aop:aspectj-autoproxy> 的proxy-target-class 属性 `<aop:aspectj-autoproxy proxy-target-class = "true">`

- JDK动态代理:其代理对象必须是某个接口的实现,它是通过在运行期间创建一个接口的实现类来完成对目标对象的代理
- CGLIB 代理:在运行期间生成的代理对象是目标类扩展的子类.CJLB 是高效的代码生成包.底层是靠ASM(开源的java字节码编辑类库)操作字节码实现的,性能比jdk强.
- expose-proxy: 有时候目标对象内部的自我调用无妨实施切面中增强,如下:
```java
public interface AService{
    public void a();

    public void b();
}

@Service
public class AServiceImpl implements AService{

    @Transactional(propagation=Propagation.REQUIRED)
    public void a(){
        this.b();
    }
    @Transactional(propagation=Propagation.REQUIRES_NEW)
    public void b(){

    }
}
```
此处的 this指向目标对象,因此调用this.b() 将不会执行b 事务(不会执行事务增强).因此b方法的事务定义 `@Transactional(propagation=Propagation.REQUIRES_NEW)`将不会生效.为了解决这个问题,我们可以配置:
`<aop:aspectj-autoproxy expose-proxy="true">`,然后修改以上代码为:
```java
 @Transactional(propagation=Propagation.REQUIRED)
    public void a(){
        //this.b();
        (AService)AopContext.currentProxy().b();
    }
```
可以完成 b() 方法的增强.

# 创建 AOP 代理
 AnnotationAwareAspectJAutoProxyCreator 类型的自动注册,那么这个类到底做了什么工作来完成 AOP 的操作呢? 首先我们看看 AnnotationAwareAspectJAutoProxyCreator类的层次结构:
![annotationAwareAspectJAutoProxyCreator.jpg](./imgs/annotationAwareAspectJAutoProxyCreator.jpg) 
我们从 类结构图中,AnnationAwareAspectJAutoProxyCreator 我实现了BeanPostProcessor接口,当Spring 加载这个Bean时,会在实例化前后调用其 postProcessorAfterInitization方法,而我们对于AOP 逻辑的分析也由此开始.
在父类 AbstractAutoProxyCreator 的postProcessAfterInitialization中代码如下:
```java
//AbstractAutoProxyCreator 
    @Override
	public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
		if (bean != null) {
            //依据给定的bean 的class 和 name构建出一个key,格式: beanClassName_beanName
			Object cacheKey = getCacheKey(bean.getClass(), beanName);
			if (!this.earlyProxyReferences.contains(cacheKey)) {
                //如果他适合做代理,则需要封装指定的bean
				return wrapIfNecessary(bean, beanName, cacheKey);
			}
		}
		return bean;
	}

    protected Object wrapIfNecessary(Object bean, String beanName, Object cacheKey) {
        //如果已经处理过
		if (beanName != null && this.targetSourcedBeans.contains(beanName)) {
			return bean;
		}
        //无需增强
		if (Boolean.FALSE.equals(this.advisedBeans.get(cacheKey))) {
			return bean;
		}
        //给定的bean 类是否代表一个基础设施类,基础设施类不应该代理,或者配置了指定bean 不需要被代理
		if (isInfrastructureClass(bean.getClass()) || shouldSkip(bean.getClass(), beanName)) {
			this.advisedBeans.put(cacheKey, Boolean.FALSE);
			return bean;
		}
        //如果存在增强方法则创建代理
		// Create proxy if we have advice.
		Object[] specificInterceptors = getAdvicesAndAdvisorsForBean(bean.getClass(), beanName, null);
        //如果获取到了增强,则需要针对增强创建代理
		//DO_NOT_PROXY 其实为 null
		if (specificInterceptors != DO_NOT_PROXY) {
			this.advisedBeans.put(cacheKey, Boolean.TRUE);
			Object proxy = createProxy(bean.getClass(), beanName, specificInterceptors, new SingletonTargetSource(bean));
			this.proxyTypes.put(cacheKey, proxy.getClass());
			return proxy;
		}

		this.advisedBeans.put(cacheKey, Boolean.FALSE);
		return bean;
	}
```

以上为代理创建的雏形,当然真正创建还需要一些分析和判断.比如是否已经处理过或者需要跳过的bean,而真正创建代码是从 `getAdvicesAndAdvisorsForBean` 开始的.

创建的步骤为:
>1. 获取增强方法或者增强器.
>2. 依据获取到的增强进行代理.

postProcessorAfterInitialization 方法执行示意图:
![postProcessorAfterInitialization](./imgs/postProcessorAfterInitazation.jpg)

- getAdvicesAndAdvisorsForBean 方法
```java
//AbstractAdvisorAutoProxyCreator
@Override
	protected Object[] getAdvicesAndAdvisorsForBean(Class<?> beanClass, String beanName, TargetSource targetSource) {
		List<Advisor> advisors = findEligibleAdvisors(beanClass, beanName);
		if (advisors.isEmpty()) {
			return DO_NOT_PROXY;
		}
		return advisors.toArray();
	}
	//增强器的解析处理入口
	protected List<Advisor> findEligibleAdvisors(Class<?> beanClass, String beanName) {
		//获取所有的增强(没有初始化的需要解析初始化初始化)
		List<Advisor> candidateAdvisors = findCandidateAdvisors();
		//寻找所有增强中适用于bean 的增强应用.
		List<Advisor> eligibleAdvisors = findAdvisorsThatCanApply(candidateAdvisors, beanClass, beanName);
		extendAdvisors(eligibleAdvisors);
		if (!eligibleAdvisors.isEmpty()) {
			eligibleAdvisors = sortAdvisors(eligibleAdvisors);
		}
		return eligibleAdvisors;
	}
```
以上代码功能: 获取所有增强，寻找所有增强中适用于bean 的增强应用

## 获取增强器
- 获取所有增强器:findCandidateAdvisors
```java
//AnnotationAwareAspectJAutoProxyCreator
@Override
	protected List<Advisor> findCandidateAdvisors() {
		//当使用注解方式配置AOP 的时候,并不是抛弃了所有的xml 配置的支持
		//super.findCandidateAdvisors() 调用父类加载配置文件中的AOP申明
		// Add all the Spring advisors found according to superclass rules.
		List<Advisor> advisors = super.findCandidateAdvisors();
		// Build Advisors for all AspectJ aspects in the bean factory.
		advisors.addAll(this.aspectJAdvisorsBuilder.buildAspectJAdvisors());
		return advisors;
	}
```
### AnnotationAwareAspectJAutoProxyCreator 间接继承了 AbstractAdvisorAutoProxyCreator, 在实现获取增强的方法中,除了父类获取配置文件中的增强外,同时增加了获取Bean 的注解增强功能,其实现是由 `this.aspectJAdvisorsBuilder.buildAspectJAdvisors()` 来实现的 .

思路:  
1. 获取所有的beanName,这一步骤,所有在SpringBeanFactory 中注册的bean都会被提取出来.
2. 遍历所有的beanName,并找出@AspectJ注解的类, 进行进一步处理.
3. 对标记 @AspectJ 注解的类,进行增强器的处理.
4. 将提取结果加入缓存.

```java
//BeanFactoryAspectJAdvisorsBuilder
public List<Advisor> buildAspectJAdvisors() {
		List<String> aspectNames = null;

		synchronized (this) {
			aspectNames = this.aspectBeanNames;
			if (aspectNames == null) {
				List<Advisor> advisors = new LinkedList<Advisor>();
				aspectNames = new LinkedList<String>();
				//获取所有的bean 名称
				String[] beanNames =
						BeanFactoryUtils.beanNamesForTypeIncludingAncestors(this.beanFactory, Object.class, true, false);
				//循环所有的bean 名称,找出增强方法
				for (String beanName : beanNames) {
					//不合法的bean 则略过,默认为true ,由子类定义规则
					if (!isEligibleBean(beanName)) {
						continue;
					}
					//获取bean 的类型
					// We must be careful not to instantiate beans eagerly as in this
					// case they would be cached by the Spring container but would not
					// have been weaved
					Class<?> beanType = this.beanFactory.getType(beanName);
					if (beanType == null) {
						continue;
					}
					//如果存在Aspectj注解
					if (this.advisorFactory.isAspect(beanType)) {
						aspectNames.add(beanName);
						AspectMetadata amd = new AspectMetadata(beanType, beanName);
						if (amd.getAjType().getPerClause().getKind() == PerClauseKind.SINGLETON) {
							MetadataAwareAspectInstanceFactory factory =
									new BeanFactoryAspectInstanceFactory(this.beanFactory, beanName);
							//解析Aspectj注解中增强的方法
							List<Advisor> classAdvisors = this.advisorFactory.getAdvisors(factory);
							if (this.beanFactory.isSingleton(beanName)) {
								this.advisorsCache.put(beanName, classAdvisors);
							}
							else {
								this.aspectFactoryCache.put(beanName, factory);
							}
							advisors.addAll(classAdvisors);
						}
						else {
							// Per target or per this.
							if (this.beanFactory.isSingleton(beanName)) {
								throw new IllegalArgumentException("Bean with name '" + beanName +
										"' is a singleton, but aspect instantiation model is not singleton");
							}
							MetadataAwareAspectInstanceFactory factory =
									new PrototypeAspectInstanceFactory(this.beanFactory, beanName);
							this.aspectFactoryCache.put(beanName, factory);
							advisors.addAll(this.advisorFactory.getAdvisors(factory));
						}
					}
				}
				this.aspectBeanNames = aspectNames;
				return advisors;
			}
		}

		if (aspectNames.isEmpty()) {
			return Collections.emptyList();
		}
		//记录在缓存中
		List<Advisor> advisors = new LinkedList<Advisor>();
		for (String aspectName : aspectNames) {
			List<Advisor> cachedAdvisors = this.advisorsCache.get(aspectName);
			if (cachedAdvisors != null) {
				advisors.addAll(cachedAdvisors);
			}
			else {
				MetadataAwareAspectInstanceFactory factory = this.aspectFactoryCache.get(aspectName);
				advisors.addAll(this.advisorFactory.getAdvisors(factory));
			}
		}
		return advisors;
	}
```

#### 增强器的获取 `advisorFactory.getAdvisors()`
```java
//ReflectiveAspectJAdvisorFactory
@Override
	public List<Advisor> getAdvisors(MetadataAwareAspectInstanceFactory maaif) {
		//获取标记为 Aspectj 的类
		final Class<?> aspectClass = maaif.getAspectMetadata().getAspectClass();
		// 获取标记为Aspectj 类的名称
		final String aspectName = maaif.getAspectMetadata().getAspectName();
		//验证
		validate(aspectClass);

		// We need to wrap the MetadataAwareAspectInstanceFactory with a decorator
		// so that it will only instantiate once.
		final MetadataAwareAspectInstanceFactory lazySingletonAspectInstanceFactory =
				new LazySingletonAspectInstanceFactoryDecorator(maaif);

		final List<Advisor> advisors = new LinkedList<Advisor>();
		for (Method method : getAdvisorMethods(aspectClass)) {
			Advisor advisor = getAdvisor(method, lazySingletonAspectInstanceFactory, advisors.size(), aspectName);
			if (advisor != null) {
				advisors.add(advisor);
			}
		}
		//如果增强器不为空,而且配置了延迟增强初始化,那么需要在首位加入同步实例化增强器
		// If it's a per target aspect, emit the dummy instantiating aspect.
		if (!advisors.isEmpty() && lazySingletonAspectInstanceFactory.getAspectMetadata().isLazilyInstantiated()) {
			Advisor instantiationAdvisor = new SyntheticInstantiationAdvisor(lazySingletonAspectInstanceFactory);
			advisors.add(0, instantiationAdvisor);
		}
		//获取 DeclareParents 注解 
		// Find introduction fields.
		for (Field field : aspectClass.getDeclaredFields()) {
			Advisor advisor = getDeclareParentsAdvisor(field);
			if (advisor != null) {
				advisors.add(advisor);
			}
		}

		return advisors;
	}

	private List<Method> getAdvisorMethods(Class<?> aspectClass) {
		final List<Method> methods = new LinkedList<Method>();
		ReflectionUtils.doWithMethods(aspectClass, new ReflectionUtils.MethodCallback() {
			@Override
			public void doWith(Method method) throws IllegalArgumentException {
				//申明为pointcout 的方法不处理
				// Exclude pointcuts
				if (AnnotationUtils.getAnnotation(method, Pointcut.class) == null) {
					methods.add(method);
				}
			}
		});
		Collections.sort(methods, METHOD_COMPARATOR);
		return methods;
	}
```
以上方法中完成了对增强器的获取:
>- 包括注解以及根据注解生成增强器的步骤,
>- 然后考虑到在配置中可能会将增强器配置成延时初始化,那么需要在首位加入同步实例化增强器以保证增强器使用之前被实例化,
>- 最后是对DeclareParents 注解的获取

##### 普通增强器 的获取 

包括对注解切点的获取 和依据注解信息进行增强
```java
//ReflectiveAspectJAdvisorFactory
public Advisor getAdvisor(Method candidateAdviceMethod, MetadataAwareAspectInstanceFactory aif,
			int declarationOrderInAspect, String aspectName) {

		validate(aif.getAspectMetadata().getAspectClass());
		//切点信息的获取
		AspectJExpressionPointcut ajexp =
				getPointcut(candidateAdviceMethod, aif.getAspectMetadata().getAspectClass());
		if (ajexp == null) {
			return null;
		}
		//依据切点信息生成增强器
		return new InstantiationModelAwarePointcutAdvisorImpl(
				this, ajexp, aif, candidateAdviceMethod, declarationOrderInAspect, aspectName);
	}

```
- 切点信息获取
```java
////ReflectiveAspectJAdvisorFactory
	//切点信息获取
	private AspectJExpressionPointcut getPointcut(Method candidateAdviceMethod, Class<?> candidateAspectClass) {
		//获取方法上的注解
		AspectJAnnotation<?> aspectJAnnotation =
				AbstractAspectJAdvisorFactory.findAspectJAnnotationOnMethod(candidateAdviceMethod);
		if (aspectJAnnotation == null) {
			return null;
		}
		// 使用 AspectJExpressionPointcut 封装获取到的切点信息
		AspectJExpressionPointcut ajexp =
				new AspectJExpressionPointcut(candidateAspectClass, new String[0], new Class<?>[0]);
		//提取注解中的表达式:@pointcout("execution(* *.*test*(..))")  中的 execution(* *.*test*(..))
		ajexp.setExpression(aspectJAnnotation.getPointcutExpression());
		return ajexp;
	}

	//AbstractAspectJAdvisorFactory
	protected static AspectJAnnotation<?> findAspectJAnnotationOnMethod(Method method) {
		Class<?>[] classesToLookFor = new Class<?>[] {
				Before.class, Around.class, After.class, AfterReturning.class, AfterThrowing.class, Pointcut.class};
		for (Class<?> c : classesToLookFor) {
			AspectJAnnotation<?> foundAnnotation = findAnnotation(method, (Class<Annotation>) c);
			if (foundAnnotation != null) {
				return foundAnnotation;
			}
		}
		return null;
	}
	// 获取指定方法上注解并使用的AspectJAnnotation封装
	private static <A extends Annotation> AspectJAnnotation<A> findAnnotation(Method method, Class<A> toLookFor) {
		A result = AnnotationUtils.findAnnotation(method, toLookFor);
		if (result != null) {
			return new AspectJAnnotation<A>(result);
		}
		else {
			return null;
		}
	}
```
- 依据切点信息生成增强
所有的增强都由Advisor 的实现类 `InstantiationModelAwarePointcutAdvisorImpl` 统一封装
```java
//InstantiationModelAwarePointcutAdvisorImpl
public InstantiationModelAwarePointcutAdvisorImpl(AspectJAdvisorFactory af, AspectJExpressionPointcut ajexp,
			MetadataAwareAspectInstanceFactory aif, Method method, int declarationOrderInAspect, String aspectName) {

		this.declaredPointcut = ajexp;
		this.method = method;
		this.atAspectJAdvisorFactory = af;
		this.aspectInstanceFactory = aif;
		this.declarationOrder = declarationOrderInAspect;
		this.aspectName = aspectName;

		if (aif.getAspectMetadata().isLazilyInstantiated()) {
			// Static part of the pointcut is a lazy type.
			Pointcut preInstantiationPointcut =
					Pointcuts.union(aif.getAspectMetadata().getPerClausePointcut(), this.declaredPointcut);

			// Make it dynamic: must mutate from pre-instantiation to post-instantiation state.
			// If it's not a dynamic pointcut, it may be optimized out
			// by the Spring AOP infrastructure after the first evaluation.
			this.pointcut = new PerTargetInstantiationModelPointcut(this.declaredPointcut, preInstantiationPointcut, aif);
			this.lazy = true;
		}
		else {
			//增强器的初始化
			// A singleton aspect.
			this.instantiatedAdvice = instantiateAdvice(this.declaredPointcut);
			this.pointcut = declaredPointcut;
			this.lazy = false;
		}
	}
```
在封装过程中还是简单的将信息封装到实例中,所有的信息单纯的赋值,在实例初始化的过程中还完成了增强器的初始化,因为不同的增强所体现的逻辑是不同的,如:`@before("test()")` 和 `@after("test()")` 标签的不同就是增强位置不同. 所以需要不同的增强其来完成不同的逻辑,依据注解中的信息初始化对应的对应的增强器的逻辑就是在 `instantiateAdvice` 中完成.
```java
//InstantiationModelAwarePointcutAdvisorImpl
private Advice instantiateAdvice(AspectJExpressionPointcut pcut) {
		return this.atAspectJAdvisorFactory.getAdvice(
				this.method, pcut, this.aspectInstanceFactory, this.declarationOrder, this.aspectName);
	}

//ReflectiveAspectJAdvisorFactory
@Override
	public Advice getAdvice(Method candidateAdviceMethod, AspectJExpressionPointcut ajexp,
			MetadataAwareAspectInstanceFactory aif, int declarationOrderInAspect, String aspectName) {

		Class<?> candidateAspectClass = aif.getAspectMetadata().getAspectClass();
		validate(candidateAspectClass);

		AspectJAnnotation<?> aspectJAnnotation =
				AbstractAspectJAdvisorFactory.findAspectJAnnotationOnMethod(candidateAdviceMethod);
		if (aspectJAnnotation == null) {
			return null;
		}
		// 判断 该类上是否有 @AspectJ 注解
		// If we get here, we know we have an AspectJ method.
		// Check that it's an AspectJ-annotated class
		if (!isAspect(candidateAspectClass)) {
			throw new AopConfigException("Advice must be declared inside an aspect type: " +
					"Offending method '" + candidateAdviceMethod + "' in class [" +
					candidateAspectClass.getName() + "]");
		}

		AbstractAspectJAdvice springAdvice;
		//依据不同的注解类型封装不同的增强器
		switch (aspectJAnnotation.getAnnotationType()) {
			case AtBefore:
				springAdvice = new AspectJMethodBeforeAdvice(candidateAdviceMethod, ajexp, aif);
				break;
			case AtAfter:
				springAdvice = new AspectJAfterAdvice(candidateAdviceMethod, ajexp, aif);
				break;
			case AtAfterReturning:
				springAdvice = new AspectJAfterReturningAdvice(candidateAdviceMethod, ajexp, aif);
				AfterReturning afterReturningAnnotation = (AfterReturning) aspectJAnnotation.getAnnotation();
				if (StringUtils.hasText(afterReturningAnnotation.returning())) {
					springAdvice.setReturningName(afterReturningAnnotation.returning());
				}
				break;
			case AtAfterThrowing:
				springAdvice = new AspectJAfterThrowingAdvice(candidateAdviceMethod, ajexp, aif);
				AfterThrowing afterThrowingAnnotation = (AfterThrowing) aspectJAnnotation.getAnnotation();
				if (StringUtils.hasText(afterThrowingAnnotation.throwing())) {
					springAdvice.setThrowingName(afterThrowingAnnotation.throwing());
				}
				break;
			case AtAround:
				springAdvice = new AspectJAroundAdvice(candidateAdviceMethod, ajexp, aif);
				break;
			case AtPointcut:
				if (logger.isDebugEnabled()) {
					logger.debug("Processing pointcut '" + candidateAdviceMethod.getName() + "'");
				}
				return null;
			default:
				throw new UnsupportedOperationException(
						"Unsupported advice type on method " + candidateAdviceMethod);
		}

		// Now to configure the advice...
		springAdvice.setAspectName(aspectName);
		springAdvice.setDeclarationOrder(declarationOrderInAspect);
		String[] argNames = this.parameterNameDiscoverer.getParameterNames(candidateAdviceMethod);
		if (argNames != null) {
			springAdvice.setArgumentNamesFromStringArray(argNames);
		}
		springAdvice.calculateArgumentBindings();
		return springAdvice;
	}
```

__分析几个常用增强器的实现__

- MethodBeforeAdviceInterceptor

```java
public class MethodBeforeAdviceInterceptor implements MethodInterceptor, Serializable {

	private MethodBeforeAdvice advice;


	/**
	 * Create a new MethodBeforeAdviceInterceptor for the given advice.
	 * @param advice the MethodBeforeAdvice to wrap
	 */
	public MethodBeforeAdviceInterceptor(MethodBeforeAdvice advice) {
		Assert.notNull(advice, "Advice must not be null");
		this.advice = advice;
	}
	@Override
	public Object invoke(MethodInvocation mi) throws Throwable {
		this.advice.before(mi.getMethod(), mi.getArguments(), mi.getThis() );
		return mi.proceed();
	}
}
```
MethodBeforeAdvice 代表  AspectJMethodBeforeAdvice，查看before方法
```java
//AspectJMethodBeforeAdvice
public void before(Method method, Object[] args, Object target) throws Throwable {
		invokeAdviceMethod(getJoinPointMatch(), null, null);
	}

//AbstractAspectJAdvice
protected Object invokeAdviceMethod(JoinPointMatch jpMatch, Object returnValue, Throwable ex) throws Throwable {
		return invokeAdviceMethodWithGivenArgs(argBinding(getJoinPoint(), jpMatch, returnValue, ex));
	}
protected Object invokeAdviceMethodWithGivenArgs(Object[] args) throws Throwable {
		Object[] actualArgs = args;
		if (this.aspectJAdviceMethod.getParameterTypes().length == 0) {
			actualArgs = null;
		}
		try {
			ReflectionUtils.makeAccessible(this.aspectJAdviceMethod);
			// TODO AopUtils.invokeJoinpointUsingReflection
			//激活增强方法
			return this.aspectJAdviceMethod.invoke(this.aspectInstanceFactory.getAspectInstance(), actualArgs);
		}
		catch (IllegalArgumentException ex) {
			throw new AopInvocationException("Mismatch on arguments to advice method [" +
					this.aspectJAdviceMethod + "]; pointcut expression [" +
					this.pointcut.getPointcutExpression() + "]", ex);
		}
		catch (InvocationTargetException ex) {
			throw ex.getTargetException();
		}
	}
```
invokeAdviceMethodWithGivenArgs 中的 `aspectJAdviceMethod` 正是对于前置增强的方法，在这里实现了调用。  
大致的逻辑是在拦截器中放置MethodBeforeAdviceInterceptor，而在 MethodBeforeAdviceInterceptor中又放置了AspectJMethodBeforeAdvice,并在调用invoke 时首先串联调用。

-  AspectJAfterAdvice
后置增强与前置增强稍有不同的地方。后置增强器没有提供中间类，而是直接在拦截器链中使用了中间的  `AspectJAfterAdvice`。
```java
public class AspectJAfterAdvice extends AbstractAspectJAdvice implements MethodInterceptor, AfterAdvice {
	public AspectJAfterAdvice(
			Method aspectJBeforeAdviceMethod, AspectJExpressionPointcut pointcut, AspectInstanceFactory aif) {

		super(aspectJBeforeAdviceMethod, pointcut, aif);
	}
	@Override
	public Object invoke(MethodInvocation mi) throws Throwable {
		try {
			return mi.proceed();
		}
		finally {
			// 激活增强方法
			invokeAdviceMethod(getJoinPointMatch(), null, null);
		}
	}
	@Override
	public boolean isBeforeAdvice() {
		return false;
	}
	@Override
	public boolean isAfterAdvice() {
		return true;
	}

}
```
#####  增加同步实例化增强器

如果寻找的增强器部位空，且又配置了增强延迟初始化，那么就需要在首位加入同步实例化增强器。同步实例化增强器`SyntheticInstantiationAdvisor` 如下：
```java
protected static class SyntheticInstantiationAdvisor extends DefaultPointcutAdvisor {

		public SyntheticInstantiationAdvisor(final MetadataAwareAspectInstanceFactory aif) {
			super(aif.getAspectMetadata().getPerClausePointcut(), new MethodBeforeAdvice() {
				// 目标方法调用前调用，类似与 @Before
				@Override
				public void before(Method method, Object[] args, Object target) {
					// 简单初始化 aspectj
					// Simply instantiate the aspect
					aif.getAspectInstance();
				}
			});
		}
	}
```
##### 获取 DeclareParent 注解
主要用于引进增强注解形式的实现，实现与普通的实现很类似，只不过是使用DeclareParentsAdvisor对功能进行封装
```java
private Advisor getDeclareParentsAdvisor(Field introductionField) {
		DeclareParents declareParents = introductionField.getAnnotation(DeclareParents.class);
		if (declareParents == null) {
			// Not an introduction field
			return null;
		}

		if (DeclareParents.class.equals(declareParents.defaultImpl())) {
			// This is what comes back if it wasn't set. This seems bizarre...
			// TODO this restriction possibly should be relaxed
			throw new IllegalStateException("defaultImpl must be set on DeclareParents");
		}

		return new DeclareParentsAdvisor(
				introductionField.getType(), declareParents.value(), declareParents.defaultImpl());
	}
```
##  寻找匹配的增强器
前面完成了 所有增强器的解析,但是对于增强器来说,一定要适用于当前的bean,还要挑出适合的增强器,即满足通配符的增强器,具体实现在 findAdvisorsThatCanApply 中
```java
//AbstractAdvisorAutoProxyCreator
	protected List<Advisor> findAdvisorsThatCanApply(
			List<Advisor> candidateAdvisors, Class<?> beanClass, String beanName) {

		ProxyCreationContext.setCurrentProxiedBeanName(beanName);
		try {
			// 过滤已经得到的增强器
			return AopUtils.findAdvisorsThatCanApply(candidateAdvisors, beanClass);
		}
		finally {
			ProxyCreationContext.setCurrentProxiedBeanName(null);
		}
	}
```
- AopUtils.findAdvisorsThatCanApply
```java
//AopUtils
public static List<Advisor> findAdvisorsThatCanApply(List<Advisor> candidateAdvisors, Class<?> clazz) {
		if (candidateAdvisors.isEmpty()) {
			return candidateAdvisors;
		}
		List<Advisor> eligibleAdvisors = new LinkedList<Advisor>();
		//首先处理引介增强
		for (Advisor candidate : candidateAdvisors) {
			if (candidate instanceof IntroductionAdvisor && canApply(candidate, clazz)) {
				eligibleAdvisors.add(candidate);
			}
		}
		boolean hasIntroductions = !eligibleAdvisors.isEmpty();
		for (Advisor candidate : candidateAdvisors) {
			//引介增强已经处理
			if (candidate instanceof IntroductionAdvisor) {
				// already processed
				continue;
			}
			//对普通bean 的处理
			if (canApply(candidate, clazz, hasIntroductions)) {
				eligibleAdvisors.add(candidate);
			}
		}
		return eligibleAdvisors;
	}
```
主要功能是找出所有增强器中适合当前class的增强器,引介增强和普通的增强不一样的,所以分开处理.而真正的处理在 canApply 中
```java
public static boolean canApply(Advisor advisor, Class<?> targetClass, boolean hasIntroductions) {
		if (advisor instanceof IntroductionAdvisor) {
			return ((IntroductionAdvisor) advisor).getClassFilter().matches(targetClass);
		}
		else if (advisor instanceof PointcutAdvisor) {
			PointcutAdvisor pca = (PointcutAdvisor) advisor;
			return canApply(pca.getPointcut(), targetClass, hasIntroductions);
		}
		else {
			// It doesn't have a pointcut so we assume it applies.
			return true;
		}
	}

	public static boolean canApply(Pointcut pc, Class<?> targetClass, boolean hasIntroductions) {
		Assert.notNull(pc, "Pointcut must not be null");
		if (!pc.getClassFilter().matches(targetClass)) {
			return false;
		}

		MethodMatcher methodMatcher = pc.getMethodMatcher();
		IntroductionAwareMethodMatcher introductionAwareMethodMatcher = null;
		if (methodMatcher instanceof IntroductionAwareMethodMatcher) {
			introductionAwareMethodMatcher = (IntroductionAwareMethodMatcher) methodMatcher;
		}

		Set<Class<?>> classes = new LinkedHashSet<Class<?>>(ClassUtils.getAllInterfacesForClassAsSet(targetClass));
		classes.add(targetClass);
		for (Class<?> clazz : classes) {
			Method[] methods = clazz.getMethods();
			for (Method method : methods) {
				if ((introductionAwareMethodMatcher != null &&
						introductionAwareMethodMatcher.matches(method, targetClass, hasIntroductions)) ||
						methodMatcher.matches(method, targetClass)) {
					return true;
				}
			}
		}

		return false;
	}
```

### 创建代理
获取所有bean 的增强器后,可以创建代理了
```java
//AbstractAutoProxyCreator
protected Object createProxy(
			Class<?> beanClass, String beanName, Object[] specificInterceptors, TargetSource targetSource) {

		ProxyFactory proxyFactory = new ProxyFactory();
		//获取当前类中的相关属性
		proxyFactory.copyFrom(this);
		//决定于给定的bean 是否应该使用targetClass而不是他的接口代理
		//检查proxyTargetClass设置以及preserveTargetClass属性
		if (!proxyFactory.isProxyTargetClass()) {
			//判断代理类是否代理目标类
			if (shouldProxyTargetClass(beanClass, beanName)) {
				proxyFactory.setProxyTargetClass(true);
			}
			else {
				//代理类代理接口时
				evaluateProxyInterfaces(beanClass, proxyFactory);
			}
		}

		Advisor[] advisors = buildAdvisors(beanName, specificInterceptors);
		for (Advisor advisor : advisors) {
			//添加增强器
			proxyFactory.addAdvisor(advisor);
		}
		//设置要代理的类
		proxyFactory.setTargetSource(targetSource);
		//定制代理
		customizeProxyFactory(proxyFactory);
		//控制代理工厂被配置后,是否允许修改通知
		//缺省值为false, 即代理被配置后,不允许修改代理的配置
		proxyFactory.setFrozen(this.freezeProxy);
		if (advisorsPreFiltered()) {
			proxyFactory.setPreFiltered(true);
		}
		// 对于代理的创建和处理,都交给 proxyFactory.getProxy 去处理.
		return proxyFactory.getProxy(getProxyClassLoader());
	}
```
代理类的创建即处理,spring 都交给了 ProxyFactory.以上代码的主要功能是:
 > 1. 获取当前类中的属性
 > 2. 添加代理接口
 > 3. 封装 Advisor 并加入到ProxyFactory 中
 > 4. 设置要代理的类
 > 5. spring 为子类提供了定制函数 `customizeProxyFactory`, 子类可以在 该函数中对 ProxyFactory 进行进一步封装
 > 6. 获取代理操作

 封装 Advisor 并加入到ProxyFactory是一个比较繁琐的过程,可以通过 ProxyFactory 提供的 addAdvisor方法直接将增强器置入代理创建工厂中,但是将拦截器封装为增强器还要一定的逻辑.
 ```java
 //AbstractAutoProxyCreator
 protected Advisor[] buildAdvisors(String beanName, Object[] specificInterceptors) {
	 	// 解析所有注册的拦截器
		// Handle prototypes correctly...
		Advisor[] commonInterceptors = resolveInterceptorNames();

		List<Object> allInterceptors = new ArrayList<Object>();
		if (specificInterceptors != null) {
			//加入拦截器
			allInterceptors.addAll(Arrays.asList(specificInterceptors));
			if (commonInterceptors != null) {
				if (this.applyCommonInterceptorsFirst) {
					allInterceptors.addAll(0, Arrays.asList(commonInterceptors));
				}
				else {
					allInterceptors.addAll(Arrays.asList(commonInterceptors));
				}
			}
		}
		if (logger.isDebugEnabled()) {
			int nrOfCommonInterceptors = (commonInterceptors != null ? commonInterceptors.length : 0);
			int nrOfSpecificInterceptors = (specificInterceptors != null ? specificInterceptors.length : 0);
			logger.debug("Creating implicit proxy for bean '" + beanName + "' with " + nrOfCommonInterceptors +
					" common interceptors and " + nrOfSpecificInterceptors + " specific interceptors");
		}

		Advisor[] advisors = new Advisor[allInterceptors.size()];
		for (int i = 0; i < allInterceptors.size(); i++) {
			//将拦截器转化为 advisor
			advisors[i] = this.advisorAdapterRegistry.wrap(allInterceptors.get(i));
		}
		return advisors;
	}

	//DefaultAdvisorAdapterRegistry
	@Override
	public Advisor wrap(Object adviceObject) throws UnknownAdviceTypeException {
		//如果要封装的对象本身是 Advisor类型的,则无需做过多的处理
		if (adviceObject instanceof Advisor) {
			return (Advisor) adviceObject;
		}
		//因为此封装方法只支持 Advisor 和 Advisor 两种类型
		if (!(adviceObject instanceof Advice)) {
			throw new UnknownAdviceTypeException(adviceObject);
		}
		Advice advice = (Advice) adviceObject;
		// 如果是 MethodInterceptor类型, 则使用  DefaultPointcutAdvisor 封装
		if (advice instanceof MethodInterceptor) {
			// So well-known it doesn't even need an adapter.
			return new DefaultPointcutAdvisor(advice);
		}
		//如果存在 Advisor 的适配器,也需要进行封装
		for (AdvisorAdapter adapter : this.adapters) {
			// Check that it is supported.
			if (adapter.supportsAdvice(advice)) {
				return new DefaultPointcutAdvisor(advice);
			}
		}
		throw new UnknownAdviceTypeException(advice);
	}
 ```
 在spring 中使用了大量的拦截器,增强器,增强方法等方式来对逻辑进行增强,所以非常由必要封装成统一的 advisor 来进行代理的创建,完成了增强的过程,解析最终要的一步就是代理的创建于获取.

 ```java
 //ProxyFactory
 public Object getProxy(ClassLoader classLoader) {
		return createAopProxy().getProxy(classLoader);
	}
 ```
 #### 创建代理
 ```java
  //ProxyFactory
 protected final synchronized AopProxy createAopProxy() {
		if (!this.active) {
			activate();
		}
		// 创建代理
		return getAopProxyFactory().createAopProxy(this);
	}
//DefaultAopProxyFactory
public AopProxy createAopProxy(AdvisedSupport config) throws AopConfigException {
		if (config.isOptimize() || config.isProxyTargetClass() || hasNoUserSuppliedProxyInterfaces(config)) {
			Class<?> targetClass = config.getTargetClass();
			if (targetClass == null) {
				throw new AopConfigException("TargetSource cannot determine target class: " +
						"Either an interface or a target is required for proxy creation.");
			}
			if (targetClass.isInterface()) {
				return new JdkDynamicAopProxy(config);
			}
			return new ObjenesisCglibAopProxy(config);
		}
		else {
			return new JdkDynamicAopProxy(config);
		}
	}
 ```
上段代码完成了 代理的创建，spring 是如何选择 代理方式的呢？

从以上代码的if 判断中，我们发现三个方面引响这是平日那个的判断：
- optimize 用来控制通过 CJLIB 创建的代理是否使用激进的优化策略，除非完全了解AOP 代理如何处理优化，否则不推荐用户使用这个设置。 目前这个属性仅用于CJLIB 代理，对于 JDK(默认代理) 无效。
- proxyTargetClass： 这个属性为true时，目标类本身被代理而不是接口。如果proxyTargetClass = true，CGLIB 代理将被创建，设置方式为：`<aop:aspectj-autoproxy proxy-target-class= "true"/>` 
- hasNoUserSuppliedProxyInterfaces: 是否存在接口代理

__JDK 和 CGLIB 方式总结__

- 如果目标对象实现了接口，默认是采用JDK 动态代理来实现AOP
- 目标对象实现了接口，也可以强制使用 CGLIB 动态代理来实现 AOP
- 如果目标对象没有实现接口，则默认使用CGLIB 动态代理来实现 AOP
- 默认情况下，spring 会在 CGLIB 和 JDK 动态代理之间自动转换

__如何强制使用CGLIB 动态代理__

- 添加 CGLIB 库。
- 在spring 配置文件中 使用 `<aop:aspectj_autoproxy  proxy-target-class== "true">`

__JDK动态代理和 CGLIB动态代理的区别__

- jdk 动态代理能对实现接口的类生成代理，而不能对未实现接口的类生成代理
- CGLIB 是针对实现代理，主要是对指定的类生成一个子类，子类覆盖其中的方法。 而目标类类中的方法不能被申明为final的。

### 获取代理
```java
//ProxyFactory
public Object getProxy(ClassLoader classLoader) {
		return createAopProxy().getProxy(classLoader);
	}
```
getproxy 获取的是 AopProxy 接口，而AopProxy 接口的实现关系如下图
![./imgs/AopProxy.jpg](./imgs/AopProxy.jpg)

####  spring 的jdk 动态代理
```java
//JdkDynamicAopProxy
@Override
	public Object getProxy(ClassLoader classLoader) {
		if (logger.isDebugEnabled()) {
			logger.debug("Creating JDK dynamic proxy: target source is " + this.advised.getTargetSource());
		}
		Class<?>[] proxiedInterfaces = AopProxyUtils.completeProxiedInterfaces(this.advised);
		findDefinedEqualsAndHashCodeMethods(proxiedInterfaces);
		return Proxy.newProxyInstance(classLoader, proxiedInterfaces, this);
	}
```
JDKproxy 的关键是创建自定义的InvocationHandler,而InvocationHandler中包含了虚哟覆盖的 getProxy，而当前的方法正是完成了这个操作，同时，我们发现JdkDynamicAopProxy 也实现了 InvocationHandler 接口，那么，我们推断出，在 getProxy，而当前的方法正是完成了这个操作，同时，我们发现JdkDynamicAopProxy中一定有invoke 方法，getProxy，而当前的方法正是完成了这个操作，同时，我们发现JdkDynamicAopProxy的核心逻辑应该就在其中。
```java
//JdkDynamicAopProxy
@Override
	public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
		MethodInvocation invocation;
		Object oldProxy = null;
		boolean setProxyContext = false;

		TargetSource targetSource = this.advised.targetSource;
		Class<?> targetClass = null;
		Object target = null;

		try {
			if (!this.equalsDefined && AopUtils.isEqualsMethod(method)) {
				// The target does not implement the equals(Object) method itself.
				return equals(args[0]);
			}
			if (!this.hashCodeDefined && AopUtils.isHashCodeMethod(method)) {
				// The target does not implement the hashCode() method itself.
				return hashCode();
			}
			//Class 类的isAssignableFrom方法：
			//如果调用这个方法的接口或者类与参数 cls表示的类或者接口相同，或者是参数 cls 表示的父类或者接口 这返回true
			//A.class.isAssignableFrom(A.class); 返回true
			// Arraylist.class.isAssignableFrom(Object.class); 返回false
			// Object.class.isAssignableFrom(ArrayList.class); 返回true
			if (!this.advised.opaque && method.getDeclaringClass().isInterface() &&
					method.getDeclaringClass().isAssignableFrom(Advised.class)) {
				// Service invocations on ProxyConfig with the proxy config...
				return AopUtils.invokeJoinpointUsingReflection(this.advised, method, args);
			}

			Object retVal;
			//目标对象内部的自我调用，将无法实施切面中的增强，则需要通过此属性来暴露代理
			if (this.advised.exposeProxy) {
				// Make invocation available if necessary.
				oldProxy = AopContext.setCurrentProxy(proxy);
				setProxyContext = true;
			}

			// May be null. Get as late as possible to minimize the time we "own" the target,
			// in case it comes from a pool.
			target = targetSource.getTarget();
			if (target != null) {
				targetClass = target.getClass();
			}
			// 获取当前方法的拦截器链
			// Get the interception chain for this method.
			List<Object> chain = this.advised.getInterceptorsAndDynamicInterceptionAdvice(method, targetClass);
			// 如果没有获取到任何拦截器，那么直接调用切点方法
			// Check whether we have any advice. If we don't, we can fallback on direct
			// reflective invocation of the target, and avoid creating a MethodInvocation.
			if (chain.isEmpty()) {
				// We can skip creating a MethodInvocation: just invoke the target directly
				// Note that the final invoker must be an InvokerInterceptor so we know it does
				// nothing but a reflective operation on the target, and no hot swapping or fancy proxying.
				retVal = AopUtils.invokeJoinpointUsingReflection(target, method, args);
			}
			else {
				// 将拦截器封装在 ReflectiveMethodInvocation中
				//以便于使用 其proceed进行链接表用拦截器
				// We need to create a method invocation...
				invocation = new ReflectiveMethodInvocation(proxy, target, method, args, targetClass, chain);
				// Proceed to the joinpoint through the interceptor chain.
				// 执行拦截器链
				retVal = invocation.proceed();
			}
			// 返回结果
			// Massage return value if necessary.
			Class<?> returnType = method.getReturnType();
			if (retVal != null && retVal == target && returnType.isInstance(proxy) &&
					!RawTargetAccess.class.isAssignableFrom(method.getDeclaringClass())) {
				// Special case: it returned "this" and the return type of the method
				// is type-compatible. Note that we can't help if the target sets
				// a reference to itself in another returned object.
				retVal = proxy;
			}
			else if (retVal == null && returnType != Void.TYPE && returnType.isPrimitive()) {
				throw new AopInvocationException(
						"Null return value from advice does not match primitive return type for: " + method);
			}
			return retVal;
		}
		finally {
			if (target != null && !targetSource.isStatic()) {
				// Must have come from TargetSource.
				targetSource.releaseTarget(target);
			}
			if (setProxyContext) {
				// Restore old proxy.
				AopContext.setCurrentProxy(oldProxy);
			}
		}
	}
```

以上函数的主要工作是创建一个拦截器链，并使用 `ReflectiveMethodInvocation` 对拦截器链封装，而在 `ReflectiveMethodInvocation`类的 proceed 方法中是怎么实现前置增强是在目标方法调用之前，后置增强是在目标方法调用之后呢？
```java
//ReflectiveMethodInvocation
@Override
	public Object proceed() throws Throwable {
		//执行完所有增强后执行切点方法
		//	We start with an index of -1 and increment early.
		if (this.currentInterceptorIndex == this.interceptorsAndDynamicMethodMatchers.size() - 1) {
			return invokeJoinpoint();
		}
		// 获取下一个要执行的拦截器
		Object interceptorOrInterceptionAdvice =
				this.interceptorsAndDynamicMethodMatchers.get(++this.currentInterceptorIndex);
		if (interceptorOrInterceptionAdvice instanceof InterceptorAndDynamicMethodMatcher) {
			// 动态匹配
			// Evaluate dynamic method matcher here: static part will already have
			// been evaluated and found to match.
			InterceptorAndDynamicMethodMatcher dm =
					(InterceptorAndDynamicMethodMatcher) interceptorOrInterceptionAdvice;
			if (dm.methodMatcher.matches(this.method, this.targetClass, this.arguments)) {
				return dm.interceptor.invoke(this);
			}
			else {
				// 不匹配则步执行，执行下一个拦截器
				// Dynamic matching failed.
				// Skip this interceptor and invoke the next in the chain.
				return proceed();
			}
		}
		else {
			// 普通拦截器，则直接调用拦截器：
			// Exposeinvocationinterceptor
			// DelegatePerTargetObjectIntroductionInteceptor
			// MethodBeforeAdviceInteceptor
			// AspectJAroundAdvice
			// AspectJAfterAdvice
			// It's an interceptor, so we just invoke it: The pointcut will have
			// been evaluated statically before this object was constructed.
			return ((MethodInterceptor) interceptorOrInterceptionAdvice).invoke(this);
		}
	}
```
proceed 方法逻辑是： 在 `ReflectiveMethodInvocation` 中链接调用的计数器，记录着当前调用链的位置，以便于可以有序的进行下去，在 proceed 方法中并没有维护各种增强的顺序的逻辑，而是将此工作委托给了各个增强器，使得各个增强器在内部进行逻辑实现。

####  CGLIB 动态代理
Spring 的 CGLIB 动态代理是委托给 Spring 的CglibAopProxy
```java
//CglibAopProxy
@Override
	public Object getProxy() {
		return getProxy(null);
	}

	@Override
	public Object getProxy(ClassLoader classLoader) {
		if (logger.isDebugEnabled()) {
			logger.debug("Creating CGLIB proxy: target source is " + this.advised.getTargetSource());
		}

		try {
			Class<?> rootClass = this.advised.getTargetClass();
			Assert.state(rootClass != null, "Target class must be available for creating a CGLIB proxy");

			Class<?> proxySuperClass = rootClass;
			if (ClassUtils.isCglibProxyClass(rootClass)) {
				proxySuperClass = rootClass.getSuperclass();
				Class<?>[] additionalInterfaces = rootClass.getInterfaces();
				for (Class<?> additionalInterface : additionalInterfaces) {
					this.advised.addInterface(additionalInterface);
				}
			}

			// Validate the class, writing log messages as necessary.
			validateClassIfNecessary(proxySuperClass, classLoader);
			// 创建Ebhancer
			// Configure CGLIB Enhancer...
			Enhancer enhancer = createEnhancer();
			if (classLoader != null) {
				enhancer.setClassLoader(classLoader);
				if (classLoader instanceof SmartClassLoader &&
						((SmartClassLoader) classLoader).isClassReloadable(proxySuperClass)) {
					enhancer.setUseCache(false);
				}
			}
			enhancer.setSuperclass(proxySuperClass);
			enhancer.setInterfaces(AopProxyUtils.completeProxiedInterfaces(this.advised));
			enhancer.setNamingPolicy(SpringNamingPolicy.INSTANCE);
			enhancer.setStrategy(new UndeclaredThrowableStrategy(UndeclaredThrowableException.class));
			//设置拦截器
			Callback[] callbacks = getCallbacks(rootClass);
			Class<?>[] types = new Class<?>[callbacks.length];
			for (int x = 0; x < types.length; x++) {
				types[x] = callbacks[x].getClass();
			}
			// fixedInterceptorMap only populated at this point, after getCallbacks call above
			enhancer.setCallbackFilter(new ProxyCallbackFilter(
					this.advised.getConfigurationOnlyCopy(), this.fixedInterceptorMap, this.fixedInterceptorOffset));
			enhancer.setCallbackTypes(types);
			// 生成代理类以及创建代理
			// Generate the proxy class and create a proxy instance.
			return createProxyClassAndInstance(enhancer, callbacks);
		}
		catch (CodeGenerationException ex) {
			throw new AopConfigException("Could not generate CGLIB subclass of class [" +
					this.advised.getTargetClass() + "]: " +
					"Common causes of this problem include using a final class or a non-visible class",
					ex);
		}
		catch (IllegalArgumentException ex) {
			throw new AopConfigException("Could not generate CGLIB subclass of class [" +
					this.advised.getTargetClass() + "]: " +
					"Common causes of this problem include using a final class or a non-visible class",
					ex);
		}
		catch (Exception ex) {
			// TargetSource.getTarget() failed
			throw new AopConfigException("Unexpected AOP exception", ex);
		}
	}
```
Spring 中 Enhancer 的生成过程，我们可以通过 Enhancer的相关只是了解每个步骤的作用，这里有一步最重要的方法是 getCallbacks 方法设置拦截器：
```java
private Callback[] getCallbacks(Class<?> rootClass) throws Exception {
		// 对于expose-proxy 的处理
		// Parameters used for optimisation choices...
		boolean exposeProxy = this.advised.isExposeProxy();
		boolean isFrozen = this.advised.isFrozen();
		boolean isStatic = this.advised.getTargetSource().isStatic();

		// 将拦截器封装在 DynamicAdvisedInterceptor中
		// Choose an "aop" interceptor (used for AOP calls).
		Callback aopInterceptor = new DynamicAdvisedInterceptor(this.advised);

		// Choose a "straight to target" interceptor. (used for calls that are
		// unadvised but can return this). May be required to expose the proxy.
		Callback targetInterceptor;
		if (exposeProxy) {
			targetInterceptor = isStatic ?
					new StaticUnadvisedExposedInterceptor(this.advised.getTargetSource().getTarget()) :
					new DynamicUnadvisedExposedInterceptor(this.advised.getTargetSource());
		}
		else {
			targetInterceptor = isStatic ?
					new StaticUnadvisedInterceptor(this.advised.getTargetSource().getTarget()) :
					new DynamicUnadvisedInterceptor(this.advised.getTargetSource());
		}

		// Choose a "direct to target" dispatcher (used for
		// unadvised calls to static targets that cannot return this).
		Callback targetDispatcher = isStatic ?
				new StaticDispatcher(this.advised.getTargetSource().getTarget()) : new SerializableNoOp();

		Callback[] mainCallbacks = new Callback[]{
			// 将拦截器加入到 Callback中
			aopInterceptor, // for normal advice
			targetInterceptor, // invoke target without considering advice, if optimized
			new SerializableNoOp(), // no override for methods mapped to this
			targetDispatcher, this.advisedDispatcher,
			new EqualsInterceptor(this.advised),
			new HashCodeInterceptor(this.advised)
		};

		Callback[] callbacks;

		// If the target is a static one and the advice chain is frozen,
		// then we can make some optimisations by sending the AOP calls
		// direct to the target using the fixed chain for that method.
		if (isStatic && isFrozen) {
			Method[] methods = rootClass.getMethods();
			Callback[] fixedCallbacks = new Callback[methods.length];
			this.fixedInterceptorMap = new HashMap<String, Integer>(methods.length);

			// TODO: small memory optimisation here (can skip creation for methods with no advice)
			for (int x = 0; x < methods.length; x++) {
				List<Object> chain = this.advised.getInterceptorsAndDynamicInterceptionAdvice(methods[x], rootClass);
				fixedCallbacks[x] = new FixedChainStaticTargetInterceptor(
						chain, this.advised.getTargetSource().getTarget(), this.advised.getTargetClass());
				this.fixedInterceptorMap.put(methods[x].toString(), x);
			}

			// Now copy both the callbacks from mainCallbacks
			// and fixedCallbacks into the callbacks array.
			callbacks = new Callback[mainCallbacks.length + fixedCallbacks.length];
			System.arraycopy(mainCallbacks, 0, callbacks, 0, mainCallbacks.length);
			System.arraycopy(fixedCallbacks, 0, callbacks, mainCallbacks.length, fixedCallbacks.length);
			this.fixedInterceptorOffset = mainCallbacks.length;
		}
		else {
			callbacks = mainCallbacks;
		}
		return callbacks;
	}
```
spring 在callBack 中考虑了很多情况，但是对于我们而言，只需要了解最长用的就可以了。比如将advised 属性封装在 DynamicAdvisedInterceptor中，并加入到callbacks中。

我们了解到CGLIB 对与方法中的拦截器是通过将自定义的拦截器（实现MethodInterceptor接口）加入 Callback中并且在调用代理的时候直接激活拦截器中的intercept方法来实现的，那么在getCallback中正是实现了这样一个目的。 DynamicAdvisedInterceptor 继承自MethodInterceptor， 加入 Callback后，再次调用地理时，会直接调用DynamicAdvisedInterceptor 中的 intercept方法， 由此判断，对于CGLIB 方式实现的代理，其核心逻辑是必然在 DynamicAdvisedInterceptor#intercept中
```java
//DynamicAdvisedInterceptor
@Override
		public Object intercept(Object proxy, Method method, Object[] args, MethodProxy methodProxy) throws Throwable {
			Object oldProxy = null;
			boolean setProxyContext = false;
			Class<?> targetClass = null;
			Object target = null;
			try {
				if (this.advised.exposeProxy) {
					// Make invocation available if necessary.
					oldProxy = AopContext.setCurrentProxy(proxy);
					setProxyContext = true;
				}
				// May be null. Get as late as possible to minimize the time we
				// "own" the target, in case it comes from a pool...
				target = getTarget();
				if (target != null) {
					targetClass = target.getClass();
				}
				//获取拦截器
				List<Object> chain = this.advised.getInterceptorsAndDynamicInterceptionAdvice(method, targetClass);
				Object retVal;
				// Check whether we only have one InvokerInterceptor: that is,
				// no real advice, but just reflective invocation of the target.
				if (chain.isEmpty() && Modifier.isPublic(method.getModifiers())) {
					// We can skip creating a MethodInvocation: just invoke the target directly.
					// Note that the final invoker must be an InvokerInterceptor, so we know
					// it does nothing but a reflective operation on the target, and no hot
					// swapping or fancy proxying.
					// 如果拦截器链为空，则直接激活方法
					retVal = methodProxy.invoke(target, args);
				}
				else {
					// 进入链后，再激活方法
					// We need to create a method invocation...
					retVal = new CglibMethodInvocation(proxy, target, method, args, targetClass, chain, methodProxy).proceed();
				}
				retVal = processReturnType(proxy, target, method, retVal);
				return retVal;
			}
			finally {
				if (target != null) {
					releaseTarget(target);
				}
				if (setProxyContext) {
					// Restore old proxy.
					AopContext.setCurrentProxy(oldProxy);
				}
			}
		}
```
与JDK 代理的实现方式大同小异，都是先构造链，然后封装此链进行串联调用。 稍有不同是：JDK 动态代理中直接构造ReflectMethodInvocation，而在 CGLIB 动态代理中，使用 CglibMethodInvocation。 CglibMethodInvocation 继承自ReflectMethodInvocation，但是proceed方法并没有重写。

# Spring静态代理
静态代理主要是在虚拟机启动时，通过改变目标对象字节码的方式来完成目标对象的增强，它与动态代理相比，有更高的效率。因为在动态代理的过程中，还需要一个创建动态代理并且代理目标对象的步骤，而静态代理，则在启动时，完成了字节码的增强，当系统再次目标类时，与正常的类并无差别，所以在使用效率上会相对高些。

## instrumentation
java 在1.5 版本时引入java.lang.instrument,你可以由此生成一个java agent，通过此agent 来修改类的字节码，即改变一个类。

我们通过 java instrument 来实现一个简单的java profiler。当然 instrument并不仅限于 profiler， instrument 还可以做很多事情，它类似于一种更低级，更松耦合的aop，可以从底层来改变一个类的行为。 

__具体细节略__
