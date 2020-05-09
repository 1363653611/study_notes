---
title: Spring_05 Bean 的加载
date: 20220-05-10 13:33:36
tags:
  - spring
categories:
  - spring
#top: 1
topdeclare: false
reward: true
---
### Bean 的加载
- bean 的加载远比bean 的解析复杂的多。
- 从`TestBean testBean = beanFactory.getBean("test", TestBean.class);` 分析。

<!--more-->
```java
//AbstractBeanFactory
@Override
    public <T> T getBean(String name, @Nullable Class<T> requiredType) throws BeansException {
        return doGetBean(name, requiredType, null, false);
    }

    @SuppressWarnings("unchecked")
    protected <T> T doGetBean(final String name, @Nullable final Class<T> requiredType,
            @Nullable final Object[] args, boolean typeCheckOnly) throws BeansException {
        //提取对应的bean 名称
        final String beanName = transformedBeanName(name);
        Object bean;
        /**
         * 检查缓存中或者实例工厂中是否有对应的实例
         * 首先使用这段代码的原因：
         * 在创建bean 的时候会存在依赖注入的情况，而在创建依赖的时候为了避免循环依赖，Spring创建bean的原则是不等bean创建完成
         * 就会创建bean的ObjectFactory 提早曝光，即将ObjectFactory 加入到缓存中，一旦下个bean创建的时候，需要依赖上一个bean的时候，则直接使用beanFactory
         */
        // 直接从缓存或者singletonFactories中的ObjectFactory中获取
        // Eagerly check singleton cache for manually registered singletons.
        Object sharedInstance = getSingleton(beanName);
        if (sharedInstance != null && args == null) {
            if (logger.isDebugEnabled()) {
                if (isSingletonCurrentlyInCreation(beanName)) {
                    logger.debug("Returning eagerly cached instance of singleton bean '" + beanName +
                            "' that is not fully initialized yet - a consequence of a circular reference");
                }
                else {
                    logger.debug("Returning cached instance of singleton bean '" + beanName + "'");
                }
            }
            // 返回需要创建的实例。有时候诸如BeanFactory的情况返回的实例不是实例本身，而是工厂方法创建的实例
            bean = getObjectForBeanInstance(sharedInstance, name, beanName, null);
        }

        else {
            //只有在单例情况才会尝试解决循环依赖，
            //原型模式情况下，才会存在 A中有B的属性,B中有A的属性，那么当依赖注入的时候，就会因为A还没有创建完的时候因为因为对于B的创建再次返回创建A，
            //造成循环依赖，也就是下面的情况
            // Fail if we're already creating this bean instance:
            // We're assumably within a circular reference.
            if (isPrototypeCurrentlyInCreation(beanName)) {
                throw new BeanCurrentlyInCreationException(beanName);
            }
            // Check if bean definition exists in this factory.
            BeanFactory parentBeanFactory = getParentBeanFactory();
             //如果beanDefinintionMap(已经加载的类中)中不包括beanName则尝试从parentBeanFactory中检测
            if (parentBeanFactory != null && !containsBeanDefinition(beanName)) {
                // Not found -> check parent.
                String nameToLookup = originalBeanName(name);
                if (parentBeanFactory instanceof AbstractBeanFactory) {
                    return ((AbstractBeanFactory) parentBeanFactory).doGetBean(
                            nameToLookup, requiredType, args, typeCheckOnly);
                }
                //递归到BeanFactory中寻找
                else if (args != null) {
                    // Delegation to parent with explicit args.
                    return (T) parentBeanFactory.getBean(nameToLookup, args);
                }
                else {
                    // No args -> delegate to standard getBean method.
                    return parentBeanFactory.getBean(nameToLookup, requiredType);
                }
            }
            //如果不是做类型检查，而是创建bean，则需要记录，将该bean标记为已创建
            if (!typeCheckOnly) {
                markBeanAsCreated(beanName);
            }
            try {
                //将存储xml配置文件的GernericBeanDefiniton转换为RootBeanDefinition，如果指定BeanDefinition是子bean的话同时会合并父类的相关属性
                final RootBeanDefinition mbd = getMergedLocalBeanDefinition(beanName);
                checkMergedBeanDefinition(mbd, beanName, args);
                //若存在依赖则需要递归实例化依赖的bean
                // Guarantee initialization of beans that the current bean depends on.
                String[] dependsOn = mbd.getDependsOn();
                if (dependsOn != null) {
                    for (String dep : dependsOn) {
                        if (isDependent(beanName, dep)) {
                            throw new BeanCreationException(mbd.getResourceDescription(), beanName,
                                    "Circular depends-on relationship between '" + beanName + "' and '" + dep + "'");
                        }
                        //缓存依赖调用
                        registerDependentBean(dep, beanName);
                        try {
                            getBean(dep);
                        }
                        catch (NoSuchBeanDefinitionException ex) {
                            throw new BeanCreationException(mbd.getResourceDescription(), beanName,
                                    "'" + beanName + "' depends on missing bean '" + dep + "'", ex);
                        }
                    }
                }
                //实例化完依赖的bean后变可以实例化mbd 本身了
                //singleton 实例化
                // Create bean instance.
                if (mbd.isSingleton()) {
                    sharedInstance = getSingleton(beanName, () -> {
                        try {
                            return createBean(beanName, mbd, args);
                        }
                        catch (BeansException ex) {
                            // Explicitly remove instance from singleton cache: It might have been put there
                            // eagerly by the creation process, to allow for circular reference resolution.
                            // Also remove any beans that received a temporary reference to the bean.
                            destroySingleton(beanName);
                            throw ex;
                        }
                    });
                    bean = getObjectForBeanInstance(sharedInstance, name, beanName, mbd);
                }
                //原型模式
                else if (mbd.isPrototype()) {
                    // It's a prototype -> create a new instance.
                    Object prototypeInstance = null;
                    try {
                        beforePrototypeCreation(beanName);
                        prototypeInstance = createBean(beanName, mbd, args);
                    }
                    finally {
                        afterPrototypeCreation(beanName);
                    }
                    bean = getObjectForBeanInstance(prototypeInstance, name, beanName, mbd);
                }
                // 指定scope上实例化
                else {
                    String scopeName = mbd.getScope();
                    final Scope scope = this.scopes.get(scopeName);
                    if (scope == null) {
                        throw new IllegalStateException("No Scope registered for scope name '" + scopeName + "'");
                    }
                    try {
                        Object scopedInstance = scope.get(beanName, () -> {
                            beforePrototypeCreation(beanName);
                            try {
                                return createBean(beanName, mbd, args);
                            }
                            finally {
                                afterPrototypeCreation(beanName);
                            }
                        });
                        bean = getObjectForBeanInstance(scopedInstance, name, beanName, mbd);
                    }
                    catch (IllegalStateException ex) {
                        throw new BeanCreationException(beanName,
                                "Scope '" + scopeName + "' is not active for the current thread; consider " +
                                "defining a scoped proxy for this bean if you intend to refer to it from a singleton",
                                ex);
                    }
                }
            }
            catch (BeansException ex) {
                cleanupAfterBeanCreationFailure(beanName);
                throw ex;
            }
        }
        //检查需要的类型是否符合bean的实际类型
        // Check if required type matches the type of the actual bean instance.
        if (requiredType != null && !requiredType.isInstance(bean)) {
            try {
                T convertedBean = getTypeConverter().convertIfNecessary(bean, requiredType);
                if (convertedBean == null) {
                    throw new BeanNotOfRequiredTypeException(name, requiredType, bean.getClass());
                }
                return convertedBean;
            }
            catch (TypeMismatchException ex) {
                if (logger.isDebugEnabled()) {
                    logger.debug("Failed to convert bean '" + name + "' to required type '" +
                            ClassUtils.getQualifiedName(requiredType) + "'", ex);
                }
                throw new BeanNotOfRequiredTypeException(name, requiredType, bean.getClass());
            }
        }
        return (T) bean;
    }
```

### bean 的加载过程：
1. 转换对应的beanName
    参数中传入的beanName 可能是别名，也可能是FactoryBean，所以需要一系列的解析和转换：
        1. 除去FactoryBean 的修饰符，及 name="&aa"，则首先会出去 & 而使 name = "aa";
        2. 取指定alias 所表示的最终beanName，eg：别名A 指向名称为B的bean则返回B;若A指向别名B，B指向别名为C的bean，则返回C;
2. 尝试从缓存中加载单例
    > 在spring 的容器中，单例bean 只会被创建一次，后续获取bean，就直接从单例缓存中获取。当然，这只是尝试加载。因为在spring创建bean的时候会存在依赖注入的情况，而在创建依赖的时候，为了避免循环依赖，在spring 中创建bean 的原则是不等bean创建完成将bean的ObjectFactory提早曝光加入到缓存中。一点下一个bean创建的时候要依赖上一个bean则直接使用ObjectFactory

3. bean 的实例化
    > 从缓存中获取到的bean是原始状态，还需要对bean进行实例化。eg：我们要对工厂bean进行处理，那么缓存中获取到的是工厂bean的初始状态，但我们真正需要的是工厂bean中定义的factory-method 方法中返回的bean，而getObjectForBeanInstance就是完成这个工作的。

4. 原型模式的依赖检查
    > 只有单利模式会处理循环依赖问题
5. 检查parentBeanFactory
    - 缓存中没有数据的话就从父类工长去加载了。
6. 将存储xml 配置文件的GerenicBeanDefinition 转换为 RootBeanDefinition
    > 将的GerenicBeanDefinition转换为RootBeanDefinition，同时，如果父类bean不为空的话，则合并父类的属性。
7. 寻找依赖
    > spring 在加载bean的时候，会优先加载该bean 所依赖的bean
8. 针对不同的scope进行bean的创建
    - 如果不指定，则默认 scope 是singleton
    - 如果配置则按照配置来创建
9. 类型转换

### FacoryBean 的使用
- spring 通过反射机制利用bean的class属性指定实现类来实例化bean。用户可以通过实现FactoryBean 自定义实例化bean的逻辑。
- FactoryBean 在spring中占有很重要的地位，spring自身就有70多个FactoryBean的实现.
```java
public interface FactoryBean<T> {
    //返回由BeanFactory 创建的bean实例。如果isSingleton 是true，则该实例会放到spring容器的单实例缓存中
    @Nullable
    T getObject() throws Exception;
    // 返回工厂bean创建的bean 的类型
    @Nullable
    Class<?> getObjectType();
    //判断该工厂创建实例bean的作用域
    default boolean isSingleton() {
        return true;
    }
}
```

### 缓存中获取单例bean
```java
//DefaultSingletonBeanRegistry
    @Override
    @Nullable
    public Object getSingleton(String beanName) {
        //参数true设置表示允许早期依赖
        return getSingleton(beanName, true);
    }
    @Nullable
    protected Object getSingleton(String beanName, boolean allowEarlyReference) {
        //检查缓存中是否存在实例
        Object singletonObject = this.singletonObjects.get(beanName);
        if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
            // 如果不存在，而且当前的bean在创建中，锁定全局变量进行处理
            synchronized (this.singletonObjects) {
                singletonObject = this.earlySingletonObjects.get(beanName);
                if (singletonObject == null && allowEarlyReference) {
                    //当某些方法需要提前初始化的时候，则会调用addSingletonFactory方法将对应的ObjectFactory初始化策略存储在earlySingletonFactories，所以此处可以取singletonFactory
                    ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
                    if (singletonFactory != null) {
                        //earlySingletonObjects 和 singletonFactories 两个不能同时存在
                        singletonObject = singletonFactory.getObject();
                        this.earlySingletonObjects.put(beanName, singletonObject);
                        this.singletonFactories.remove(beanName);
                    }
                }
            }
        }
        return singletonObject;
    }
```
上面方法中四个map，解释如下：
- singletonObjects 用于保存beanName 和创建bean 实例之间的关系。 bean name -> bean instance
- singletonFactories 用于保存beanName 和创建 bean的工厂之间的关系。 bean name -> ObjectFactory
- earlySingletonObjects 保存beanName 和创建bean 实例之间的关系，于singletonObjects的不同之处是，earlySingletonObjects中的bean 对象还在创建过程中，就可以通过getBean 方法获取到了，目的是用来检测循环依赖。
- registedSingletons： 用来保存当前所有已经注册的bean

### 从bean 的实例中获取对象
`AbstractBeanFactory#getObjectForBeanInstance` 用来检查bean 的正确性：检查当前的bean 是否是FactoryBean 类型的bean，如果是，则需要调用 `FactoryBean#getObject作为返回值`
```java
//AbstractBeanFactory
protected Object getObjectForBeanInstance(
            Object beanInstance, String name, String beanName, @Nullable RootBeanDefinition mbd) {
        //如果指定的bean是工厂相关（以&为前缀）
        // Don't let calling code try to dereference the factory if the bean isn't a factory.
        if (BeanFactoryUtils.isFactoryDereference(name)) {
            if (beanInstance instanceof NullBean) {
                return beanInstance;
            }
            // beanInstance 不是FacoryBean 类型的，则抛出指定异常
            if (!(beanInstance instanceof FactoryBean)) {
                throw new BeanIsNotAFactoryException(transformedBeanName(name), beanInstance.getClass());
            }
        }

        // Now we have the bean instance, which may be a normal bean or a FactoryBean.
        // If it's a FactoryBean, we use it to create a bean instance, unless the
        // caller actually wants a reference to the factory.
        // 如果不是FacotryBean 类型的 或者调用这想返回FactoryBean类型的bean（name 以&符号开头，如：&aa）则直接返回instance
        if (!(beanInstance instanceof FactoryBean) || BeanFactoryUtils.isFactoryDereference(name)) {
            return beanInstance;
        }
        // 加载FactoryBean
        Object object = null;
        if (mbd == null) {
            //尝试从缓存中获取
            object = getCachedObjectForFactoryBean(beanName);
        }
        if (object == null) {
            //此处确定beanInstance一定为FactoryBean类型的
            // Return bean instance from factory.
            FactoryBean<?> factory = (FactoryBean<?>) beanInstance;
            //containsBeanDefinition方法检查BeanDefinitionMap中是否存在指定beanName 的bean
            // Caches object obtained from FactoryBean if it is a singleton.
            if (mbd == null && containsBeanDefinition(beanName)) {
                // 如果存在将 GerenicBeanDefinition 转换为RootBeanDefinition，如果该bean是子类的话，会合并父类的属性
                mbd = getMergedLocalBeanDefinition(beanName);
            }
            //是否是用户定义的而不是应用程序本身的
            boolean synthetic = (mbd != null && mbd.isSynthetic());
            object = getObjectFromFactoryBean(factory, beanName, !synthetic);
        }
        return object;
    }
```

以上代码的工作：
1. 对FactoryBean 正确性的验证
2. 对非FactoryBean 不做任何处理，直接返回
3. 对bean进行转换
4. 将从Factory中解析bean的工作委托给getObjectFromFactoryBean

#### `AbstractBeanFactory#getObjectFromFactoryBean` 方法分析
AbstractBeanFactory#getObjectFromFactoryBean 最终调用的是FactoryBeanRegistrySupport
```java
//FactoryBeanRegistrySupport
protected Object getObjectFromFactoryBean(FactoryBean<?> factory, String beanName, boolean shouldPostProcess) {
        if (factory.isSingleton() && containsSingleton(beanName)) {
            synchronized (getSingletonMutex()) {
                Object object = this.factoryBeanObjectCache.get(beanName);
                if (object == null) {
                    object = doGetObjectFromFactoryBean(factory, beanName);
                    // Only post-process and store if not put there already during getObject() call above
                    // (e.g. because of circular reference processing triggered by custom getBean calls)
                    Object alreadyThere = this.factoryBeanObjectCache.get(beanName);
                    if (alreadyThere != null) {
                        object = alreadyThere;
                    }
                    else {
                        if (shouldPostProcess) {
                            if (isSingletonCurrentlyInCreation(beanName)) {
                                // Temporarily return non-post-processed object, not storing it yet..
                                return object;
                            }
                            //回调函数，在bean 创建前标记为正在创建（Callback before singleton creation.）
                            beforeSingletonCreation(beanName);
                            try {
                                //调用objectFactory的后处理器
                                object = postProcessObjectFromFactoryBean(object, beanName);
                            }
                            catch (Throwable ex) {
                                throw new BeanCreationException(beanName,
                                        "Post-processing of FactoryBean's singleton object failed", ex);
                            }
                            finally {
                                afterSingletonCreation(beanName);
                            }
                        }
                        if (containsSingleton(beanName)) {
                            this.factoryBeanObjectCache.put(beanName, object);
                        }
                    }
                }
                return object;
            }
        }
        else {
            Object object = doGetObjectFromFactoryBean(factory, beanName);
            if (shouldPostProcess) {
                try {
                    object = postProcessObjectFromFactoryBean(object, beanName);
                }
                catch (Throwable ex) {
                    throw new BeanCreationException(beanName, "Post-processing of FactoryBean's object failed", ex);
                }
            }
            return object;
        }
    }
    // 从FactoryBean 获取bean 的实际方法
    private Object doGetObjectFromFactoryBean(final FactoryBean<?> factory, final String beanName)
            throws BeanCreationException {
        Object object;
        try {
            if (System.getSecurityManager() != null) {
                AccessControlContext acc = getAccessControlContext();
                try {
                    object = AccessController.doPrivileged((PrivilegedExceptionAction<Object>) factory::getObject, acc);
                }
                catch (PrivilegedActionException pae) {
                    throw pae.getException();
                }
            }
            else {
                object = factory.getObject();
            }
        }
        catch (FactoryBeanNotInitializedException ex) {
            throw new BeanCurrentlyInCreationException(beanName, ex.toString());
        }
        catch (Throwable ex) {
            throw new BeanCreationException(beanName, "FactoryBean threw exception on object creation", ex);
        }
        // Do not accept a null value for a FactoryBean that's not fully
        // initialized yet: Many FactoryBeans just return null then.
        if (object == null) {
            if (isSingletonCurrentlyInCreation(beanName)) {
                throw new BeanCurrentlyInCreationException(
                        beanName, "FactoryBean which is currently in creation returned null from getObject");
            }
            object = new NullBean();
        }
        return object;
    }
```

#### AbstractAutowireCapableBeanFactory#postProcessObjectFromFactoryBean 方法的作用
```java
    @Override
    protected Object postProcessObjectFromFactoryBean(Object object, String beanName) {
        return applyBeanPostProcessorsAfterInitialization(object, beanName);
    }

    @Override
    public Object applyBeanPostProcessorsAfterInitialization(Object existingBean, String beanName)
            throws BeansException {

        Object result = existingBean;
        for (BeanPostProcessor beanProcessor : getBeanPostProcessors()) {
            Object current = beanProcessor.postProcessAfterInitialization(result, beanName);
            if (current == null) {
                return result;
            }
            result = current;
        }
        return result;
    }
```
在bean 创建完成前可以对bean做特殊的处理。例如增加自己特有的业务逻辑。 主要是BeanPostProcessor 的应用，后期分析。

### 获取单例
如果从缓存中获取不到bean，则需要从头开始加载singleton，spring是利用重载的方式实现bean的加载过程
```java
//DefaultSingletonBeanRegistry
public Object getSingleton(String beanName, ObjectFactory<?> singletonFactory) {
        Assert.notNull(beanName, "Bean name must not be null");
        //操作全局变量，所以需要同步
        synchronized (this.singletonObjects) {
            //首先检查bean 是否已经创建过。
            Object singletonObject = this.singletonObjects.get(beanName);
            //singletonObject 为空，说明没有创建过，则开始创建
            if (singletonObject == null) {
                if (this.singletonsCurrentlyInDestruction) {
                    throw new BeanCreationNotAllowedException(beanName,
                            "Singleton bean creation not allowed while singletons of this factory are in destruction " +
                            "(Do not request a bean from a BeanFactory in a destroy method implementation!)");
                }
                if (logger.isDebugEnabled()) {
                    logger.debug("Creating shared instance of singleton bean '" + beanName + "'");
                }
                beforeSingletonCreation(beanName);
                boolean newSingleton = false;
                boolean recordSuppressedExceptions = (this.suppressedExceptions == null);
                if (recordSuppressedExceptions) {
                    this.suppressedExceptions = new LinkedHashSet<>();
                }
                try {
                    singletonObject = singletonFactory.getObject();
                    newSingleton = true;
                }
                catch (IllegalStateException ex) {
                    // Has the singleton object implicitly appeared in the meantime ->
                    // if yes, proceed with it since the exception indicates that state.
                    singletonObject = this.singletonObjects.get(beanName);
                    if (singletonObject == null) {
                        throw ex;
                    }
                }
                catch (BeanCreationException ex) {
                    if (recordSuppressedExceptions) {
                        for (Exception suppressedException : this.suppressedExceptions) {
                            ex.addRelatedCause(suppressedException);
                        }
                    }
                    throw ex;
                }
                finally {
                    if (recordSuppressedExceptions) {
                        this.suppressedExceptions = null;
                    }
                    afterSingletonCreation(beanName);
                }
                if (newSingleton) {
                    //加入到混存
                    addSingleton(beanName, singletonObject);
                }
            }
            return singletonObject;
        }
    }
```
以上方法的作用：
1. 检查缓存是否加载过
2. 若没有加载，则修改beanName 的加载状态
3. 加载单利前记录加载状态
4. 通过调用参数传入的ObjectFactory 的个体object方法实例化bean。
5. 加载代理方法的处理方法调用
6. 将结果加入缓存，并删除bean加载过程中记录的各种辅助状态。
7. 返回处理结果。

### 准备创建bean
通过反spring 源码，我们总结出了一个经验：真正干活的函数其实是以 do 开头的方法。
```java
//AbstractBeanFactory#doGetBean(final String name, @Nullable final Class<T> requiredType, @Nullable final Object[] args, boolean typeCheckOnly)
if (mbd.isSingleton()) {
                    sharedInstance = getSingleton(beanName, () -> {
                        try {
                            return createBean(beanName, mbd, args);
                        }
                        catch (BeansException ex) {
                            // Explicitly remove instance from singleton cache: It might have been put there
                            // eagerly by the creation process, to allow for circular reference resolution.
                            // Also remove any beans that received a temporary reference to the bean.
                            destroySingleton(beanName);
                            throw ex;
                        }
                    });
                    bean = getObjectForBeanInstance(sharedInstance, name, beanName, mbd);
                }
```
```java
//AbstractAutowireCapableBeanFactory
    @Override
    protected Object createBean(String beanName, RootBeanDefinition mbd, @Nullable Object[] args)
            throws BeanCreationException {
        if (logger.isDebugEnabled()) {
            logger.debug("Creating instance of bean '" + beanName + "'");
        }
        RootBeanDefinition mbdToUse = mbd;
        //锁定class，根据设置的class属性或者根据className来解析Class
        // Make sure bean class is actually resolved at this point, and
        // clone the bean definition in case of a dynamically resolved Class
        // which cannot be stored in the shared merged bean definition.
        Class<?> resolvedClass = resolveBeanClass(mbd, beanName);
        if (resolvedClass != null && !mbd.hasBeanClass() && mbd.getBeanClassName() != null) {
            mbdToUse = new RootBeanDefinition(mbd);
            mbdToUse.setBeanClass(resolvedClass);
        }
        //验证及准备覆盖的方法
        // Prepare method overrides.
        try {
            mbdToUse.prepareMethodOverrides();
        }
        catch (BeanDefinitionValidationException ex) {
            throw new BeanDefinitionStoreException(mbdToUse.getResourceDescription(),
                    beanName, "Validation of method overrides failed", ex);
        }

        try {
            //给BeanPostProcessors 一个机会来返回代理来代替真正的实例
            // Give BeanPostProcessors a chance to return a proxy instead of the target bean instance.
            Object bean = resolveBeforeInstantiation(beanName, mbdToUse);
            if (bean != null) {
                return bean;
            }
        }
        catch (Throwable ex) {
            throw new BeanCreationException(mbdToUse.getResourceDescription(), beanName,
                    "BeanPostProcessor before instantiation of bean failed", ex);
        }

        try {
            Object beanInstance = doCreateBean(beanName, mbdToUse, args);
            if (logger.isDebugEnabled()) {
                logger.debug("Finished creating instance of bean '" + beanName + "'");
            }
            return beanInstance;
        }
        catch (BeanCreationException | ImplicitlyAppearedSingletonException ex) {
            // A previously detected exception with proper bean creation context already,
            // or illegal singleton state to be communicated up to DefaultSingletonBeanRegistry.
            throw ex;
        }
        catch (Throwable ex) {
            throw new BeanCreationException(
                    mbdToUse.getResourceDescription(), beanName, "Unexpected exception during bean creation", ex);
        }
    }
```
以上方法的作用：
1. 根据设置的class属性及className来解析class
2. 对override属性进行标记及验证
    处理spring中的lookup-method 和replaced-method的。这两个配置的加载其实就是将配置统一存在BeanDefinition中的methodOverrides属性里。此处的处理，就是对methodOverrides的处理。
3. 应用初始化前的后处理器，解析指定bean是否存在初始化前的短路操作。
4. 创建bean


#### Ovveride属性处理
AbstractBeanDefinition 类的prepareMethodOverrides方法：
```java
public void prepareMethodOverrides() throws BeanDefinitionValidationException {
        // Check that lookup methods exists.
        if (hasMethodOverrides()) {
            Set<MethodOverride> overrides = getMethodOverrides().getOverrides();
            synchronized (overrides) {
                for (MethodOverride mo : overrides) {
                    prepareMethodOverride(mo);
                }
            }
        }
    }
    protected void prepareMethodOverride(MethodOverride mo) throws BeanDefinitionValidationException {
        //获取对应类中对应方法名的个数
        int count = ClassUtils.getMethodCountForName(getBeanClass(), mo.getMethodName());
        if (count == 0) {
            throw new BeanDefinitionValidationException(
                    "Invalid method override: no method with name '" + mo.getMethodName() +
                    "' on class [" + getBeanClassName() + "]");
        }
        else if (count == 1) {
            //标记MethodOverride 暂未覆盖，避免参数类型检查的开销
            // Mark override as not overloaded, to avoid the overhead of arg type checking.
            mo.setOverloaded(false);
        }
    }
```

#### 实例化前置处理
AOP 的功能在此处处理。
```java
//AbstractAutowireCapableBeanFactory
@Nullable
    protected Object resolveBeforeInstantiation(String beanName, RootBeanDefinition mbd) {
        Object bean = null;
        //如果bean 尚未被解析
        if (!Boolean.FALSE.equals(mbd.beforeInstantiationResolved)) {
            // Make sure bean class is actually resolved at this point.
            if (!mbd.isSynthetic() && hasInstantiationAwareBeanPostProcessors()) {
                Class<?> targetType = determineTargetType(beanName, mbd);
                if (targetType != null) {
                    //实例化前的后处理器
                    bean = applyBeanPostProcessorsBeforeInstantiation(targetType, beanName);
                    if (bean != null) {
                        //实例化后的后处理器
                        bean = applyBeanPostProcessorsAfterInitialization(bean, beanName);
                    }
                }
            }
            mbd.beforeInstantiationResolved = (bean != null);
        }
        return bean;
    }
```

1. 实例化前的后处理器应用
```java
//AbstractAutowireCapableBeanFactory
protected Object applyBeanPostProcessorsBeforeInstantiation(Class<?> beanClass, String beanName) {
        for (BeanPostProcessor bp : getBeanPostProcessors()) {
            if (bp instanceof InstantiationAwareBeanPostProcessor) {
                InstantiationAwareBeanPostProcessor ibp = (InstantiationAwareBeanPostProcessor) bp;
                Object result = ibp.postProcessBeforeInstantiation(beanClass, beanName);
                if (result != null) {
                    return result;
                }
            }
        }
        return null;
    }
```
作用：  
  给子类修改beanDefinition的机会，经过此处后，bean可能就不是我们认为的bean了，而是或许成为了一个经过处理的代理bean，也可能是cjlib生成的。也可能是其他技术生成的。

 2. 实例化后的后处理器的应用
 ```java
 @Override
    public Object applyBeanPostProcessorsAfterInitialization(Object existingBean, String beanName)
            throws BeansException {
        Object result = existingBean;
        for (BeanPostProcessor beanProcessor : getBeanPostProcessors()) {
            Object current = beanProcessor.postProcessAfterInitialization(result, beanName);
            if (current == null) {
                return result;
            }
            result = current;
        }
        return result;
    }
 ```

### 循环依赖问题
 ![循环依赖.jpg](./imgs/循环依赖.jpg)
 循环依赖是无法解决的，除非有最终方案，否则就是死循环，最终导致内存溢出的错误。

#### Spring 如何解决循环依赖问题
spring 的注入方式分为两类：构造注入，setter注入。分别说明。

1. 构造循环依赖 （无法解决）
 表示通过构造器注入构成的循环依赖是无法解决的。只能抛出BeanCurrentlyIncreationException。

2. setter 循环依赖（只能解决单例模式 `scope =singleton`）
 对于setter 注入造成的依赖是通过spring 容器提前暴露刚完成构造器注入但未完成其他步骤（如setter注入）的bean来完成的。且只能解决单例作用域的循环依赖问题。通过提前暴露一个单例工厂方法，从而使得其他bean能应用到该bean。
 ```java
 addSingletonFactory(beanName, new ObjecttFactory(){
   public Object getObject()throws BeansException{
     return getEarlyBeanReference(beanName,mbd,bean);
   }
 })
 ```
 具体步骤：（无法解决）
  1. spring 创建单例“testA” bean,首先依据无参构造构造器创建bean，并暴露一个“ObjectFactory”用于返回一个提前暴露 一个创建中的bean，并将 “testA” 标识放到当前创建bean池。然后进行setter 注入 "testB"
  2. spring 首先依据无参构造器创建bean “testB”，并暴露一个“ObjectFactory”，用于提前暴露一个创建中的bean，并将并“testB” 放到当前创建bean池，然后进行setter注入“testC”
  3. spring 依据无参构造器创建 bean “testC”，并暴露一个“ObjectFactory”用于提前暴露一个创建中的bean "testC", 并将“testC” 放到当前创建bean池，然后setter 注入 "testA".注入“TestA” 时，由于提前暴露了"ObjectFactory" 工厂，从而使得他返回提前暴露一个创建中的bean。
  4. 最后依次完成 “testB” 和"testA" 的setter注入。

3. propertype 范围的依赖处理
  对于 “propertype” 作用域bean，spring 容器无法完成依赖注入。因为spring容器不进行缓存 "propertype" 作用域的bean，因此无法提前暴露一个创建中的bean。

#### 总结
1. spring中，只有 `scope=singleton`（单例模式），通过setter 注入的方式解决循环依赖问题。
2. 对于单例模式“singleton”作用域的bean，可以通过 “setterAllowCirclularReferences(false)” 来禁用循环引用。

### 创建bean
当经历过resolveBeforeInstantiation 方法后，程序有两个选择，如果创建了代理或者重写了InstatiationAwareBeanPostProcessor 的postProcessBeforeInstatiation方法并且在 postProcessBeforeInstatiation中改变了bean，则直接返回就可以了，否则则需要常规的bean 创建过程。
```java
//AbstractAutowireCapableBeanFactory
protected Object doCreateBean(final String beanName, final RootBeanDefinition mbd, final @Nullable Object[] args)
			throws BeanCreationException {
		// Instantiate the bean.
		BeanWrapper instanceWrapper = null;
        // 1. 如果是单例，首先清除缓存
		if (mbd.isSingleton()) {
			instanceWrapper = this.factoryBeanInstanceCache.remove(beanName);
		}
        //2. 实例化bean，将BeanDefinition转换为 BeanWrapper
		if (instanceWrapper == null) {
      //根据指定bean使用对应的策略创建新的实例,如：工厂方法、构造参数注入，简单初始化
			instanceWrapper = createBeanInstance(beanName, mbd, args);
		}
		final Object bean = instanceWrapper.getWrappedInstance();
		Class<?> beanType = instanceWrapper.getWrappedClass();
		if (beanType != NullBean.class) {
			mbd.resolvedTargetType = beanType;
		}
		// Allow post-processors to modify the merged bean definition.
		synchronized (mbd.postProcessingLock) {
			if (!mbd.postProcessed) {
				try {
                    //3. MergedBeanDefinitionPostProcessor 的应用。bean合并后的处理，Autowired注解正式通过此方法实现诸如类型的预先解析
					applyMergedBeanDefinitionPostProcessors(mbd, beanType, beanName);
				}
				catch (Throwable ex) {
					throw new BeanCreationException(mbd.getResourceDescription(), beanName,
							"Post-processing of merged bean definition failed", ex);
				}
				mbd.postProcessed = true;
			}
		}
        //4. 依赖处理
    //单例模式允许循环依赖。
    //提早曝光条件：单例&允许循环依赖&当前bean正在创建中，检查循环依赖
		// Eagerly cache singletons to be able to resolve circular references
		// even when triggered by lifecycle interfaces like BeanFactoryAware.
		boolean earlySingletonExposure = (mbd.isSingleton() && this.allowCircularReferences &&
				isSingletonCurrentlyInCreation(beanName));
		if (earlySingletonExposure) {
			if (logger.isDebugEnabled()) {
				logger.debug("Eagerly caching bean '" + beanName +
						"' to allow for resolving potential circular references");
			}
      // 为了避免循环依赖，可以在bean初始化完成前将创建
			addSingletonFactory(beanName, () ->
      //对bean再一次依赖引用，主要是smartInstatiationAware beanPostProcessor,
      //其中我们熟知的aop就是在这里将 advice 动态的织入bean中。如果没有，则不做任何处理，直接返回，不做任何处理
       getEarlyBeanReference(beanName, mbd, bean));
		}
		// Initialize the bean instance.
		Object exposedObject = bean;
		try {
            //5. 属性处理
            //对bean进行填充，将各个属性注入。其中可能存在依赖其他bean的属性，会递归初始化依赖bean
			populateBean(beanName, mbd, instanceWrapper);
            // 调用初始化方法,如：init-method
			exposedObject = initializeBean(beanName, exposedObject, mbd);
		}
		catch (Throwable ex) {
			if (ex instanceof BeanCreationException && beanName.equals(((BeanCreationException) ex).getBeanName())) {
				throw (BeanCreationException) ex;
			}
			else {
				throw new BeanCreationException(
						mbd.getResourceDescription(), beanName, "Initialization of bean failed", ex);
			}
		}
        //6. 循环依赖的检查
		if (earlySingletonExposure) {
			Object earlySingletonReference = getSingleton(beanName, false);
            //只有循环依赖的情况下，earlySingletonReference才不会为空
			if (earlySingletonReference != null) {
                //exposedObject没有在初始化方法中改变，即没有被增强
				if (exposedObject == bean) {
					exposedObject = earlySingletonReference;
				}
				else if (!this.allowRawInjectionDespiteWrapping && hasDependentBean(beanName)) {
					String[] dependentBeans = getDependentBeans(beanName);
					Set<String> actualDependentBeans = new LinkedHashSet<>(dependentBeans.length);
                    //检查依赖
					for (String dependentBean : dependentBeans) {
						if (!removeSingletonIfCreatedForTypeCheckOnly(dependentBean)) {
							actualDependentBeans.add(dependentBean);
						}
					}
                    // bean 创建后，其依赖是一定创建了的，
                    // bean 创建后，actualDependentBeans没有为空，则说明bean创建后，其依赖的bean没有完全创建，说明依赖bean之间存在虚幻依赖。
					if (!actualDependentBeans.isEmpty()) {
						throw new BeanCurrentlyInCreationException(beanName,
								"Bean with name '" + beanName + "' has been injected into other beans [" +
								StringUtils.collectionToCommaDelimitedString(actualDependentBeans) +
								"] in its raw version as part of a circular reference, but has eventually been " +
								"wrapped. This means that said other beans do not use the final version of the " +
								"bean. This is often the result of over-eager type matching - consider using " +
								"'getBeanNamesOfType' with the 'allowEagerInit' flag turned off, for example.");
					}
				}
			}
		}
        //7. 注册 disposableBean
        //如果配置了destroy-method 方法，这里会注册，在bean销毁时会调用
		// Register bean as disposable.
		try {
            //依据scope 注册bean
			registerDisposableBeanIfNecessary(beanName, bean, mbd);
		}
		catch (BeanDefinitionValidationException ex) {
			throw new BeanCreationException(
					mbd.getResourceDescription(), beanName, "Invalid destruction signature", ex);
		}
        // 8. 返回
		return exposedObject;
	}
```

一下对bean的创建过程详细分析：

#### 创建bean的实例
```java
//ConstructorResolver
protected BeanWrapper createBeanInstance(String beanName, RootBeanDefinition mbd, @Nullable Object[] args) {
        // Make sure bean class is actually resolved at this point.
        // 解析class
        Class<?> beanClass = resolveBeanClass(mbd, beanName);
        if (beanClass != null && !Modifier.isPublic(beanClass.getModifiers()) && !mbd.isNonPublicAccessAllowed()) {
            throw new BeanCreationException(mbd.getResourceDescription(), beanName,
                    "Bean class isn't public, and non-public access not allowed: " + beanClass.getName());
        }
        // 如果 模板中 supplier不为空，则从 supplier中获取
        Supplier<?> instanceSupplier = mbd.getInstanceSupplier();
        if (instanceSupplier != null) {
            return obtainFromSupplier(instanceSupplier, beanName);
        }
        // 如果工厂方法不为空，则使用工厂方法创建
        if (mbd.getFactoryMethodName() != null) {
            return instantiateUsingFactoryMethod(beanName, mbd, args);
        }
        // Shortcut when re-creating the same bean...
        boolean resolved = false;
        boolean autowireNecessary = false;
        if (args == null) {
            // 一个类有多个构造函数，每个构造函数有不同的参数，所以调用前需要根据参数锁定构造参数或者对应的工厂方法
            synchronized (mbd.constructorArgumentLock) {
                if (mbd.resolvedConstructorOrFactoryMethod != null) {
                    resolved = true;
                    autowireNecessary = mbd.constructorArgumentsResolved;
                }
            }
        }
        //如果已经解析过,则使用解析好的构造函数方法,不需要再次锁定
        if (resolved) {
            if (autowireNecessary) {
                //构造参数自动注入
                return autowireConstructor(beanName, mbd, null, null);
            }
            else {
                //默认构造函数构造
                return instantiateBean(beanName, mbd);
            }
        }
        //根据参数解析构造函数
        // Candidate constructors for autowiring?
        Constructor<?>[] ctors = determineConstructorsFromBeanPostProcessors(beanClass, beanName);
        if (ctors != null || mbd.getResolvedAutowireMode() == AUTOWIRE_CONSTRUCTOR ||
                mbd.hasConstructorArgumentValues() || !ObjectUtils.isEmpty(args)) {
            //构造函数自动注入
            return autowireConstructor(beanName, mbd, ctors, args);
        }
        //使用指定的默认构造函数解析.
        // Preferred constructors for default construction?
        ctors = mbd.getPreferredConstructors();
        if (ctors != null) {
            return autowireConstructor(beanName, mbd, ctors, null);
        }
        //使用默认构造函数
        // No special handling: simply use no-arg constructor.
        return instantiateBean(beanName, mbd);
    }
```

具体逻辑:
    1. 如果 `RootbeanDefinition` 中存在 factoryMethodName 属性,或者说在配置文件中配置了factory-method, 那么spring 会尝试使用instantiateUsingFactoryMethod 方法根据RootBeanDefinition 中的配置生成bean的实例.
    2. 解析构造函数并根据构造函数实例化. 一个bean中可能有多个构造函数,而每个构造函数的参数不同,spring 在解析的过程中需要判断最终会使用哪个构造函数. 但是,判断过程中比较耗性能,所以spring 采用了缓存机制,如果已经解析过,则不需要重复解析而是使用RootBeanDefinition 中的属性  
resolvedConstructorOrFactoryMethod 缓存直接去创建.否则,需要再次解析.并将结果添加到 resolvedConstructorOrFactoryMethod 中.
        
##### autowireConstructor

对于实例的创建spring中分成了两种情况,一种是通用实例化,另一种是带有参数的实例化. 带有参数的实例化过程相当 复杂,因为存在着不确定性,所以在判断对应参数上做了大量工作.
```java
public BeanWrapper autowireConstructor(String beanName, RootBeanDefinition mbd,
            @Nullable Constructor<?>[] chosenCtors, @Nullable Object[] explicitArgs) {

        BeanWrapperImpl bw = new BeanWrapperImpl();
        this.beanFactory.initBeanWrapper(bw);

        Constructor<?> constructorToUse = null;
        ArgumentsHolder argsHolderToUse = null;
        Object[] argsToUse = null;
        //explicitArgs 通过getBean方法传入
        //如果getBean 方法调用的时候指定方法参数那么直接使用.
        if (explicitArgs != null) {
            argsToUse = explicitArgs;
        }
        else {
            //如果在调用getBean 的时候没有指定,则尝试从配置文件中解析获取.
            Object[] argsToResolve = null;
            //尝试从缓存中获取
            synchronized (mbd.constructorArgumentLock) {
                constructorToUse = (Constructor<?>) mbd.resolvedConstructorOrFactoryMethod;
                if (constructorToUse != null && mbd.constructorArgumentsResolved) {
                    // Found a cached constructor...
                    // 在缓存中获取
                    argsToUse = mbd.resolvedConstructorArguments;
                    if (argsToUse == null) {
                        //配置的构造参数
                        argsToResolve = mbd.preparedConstructorArguments;
                    }
                }
            }
            //如果缓存中存在
            if (argsToResolve != null) {
                //解析参数类型,如给定方法的构造参数A(int,int), 则通过此方法后就会把配置文件中 的("1","1")转换为(1,1)
                //缓存中的值可能是原始值,也可能是最终值
                argsToUse = resolvePreparedArguments(beanName, mbd, bw, constructorToUse, argsToResolve, true);
            }
        }
        //如果没有缓存
        if (constructorToUse == null || argsToUse == null) {
            // Take specified constructors, if any.
            // 使用可用的候选构造方法集合
            Constructor<?>[] candidates = chosenCtors;
            if (candidates == null) {
                Class<?> beanClass = mbd.getBeanClass();
                try {
                    candidates = (mbd.isNonPublicAccessAllowed() ?
                            beanClass.getDeclaredConstructors() : beanClass.getConstructors());
                }
                catch (Throwable ex) {
                    throw new BeanCreationException(mbd.getResourceDescription(), beanName,
                            "Resolution of declared constructors on bean Class [" + beanClass.getName() +
                            "] from ClassLoader [" + beanClass.getClassLoader() + "] failed", ex);
                }
            }
            //如果只有一个候选构造方法,同时显性参数为空,配置文件中也没有构造参数,则说明为为无参构造函数.
            if (candidates.length == 1 && explicitArgs == null && !mbd.hasConstructorArgumentValues()) {
                Constructor<?> uniqueCandidate = candidates[0];
                if (uniqueCandidate.getParameterCount() == 0) {
                    synchronized (mbd.constructorArgumentLock) {
                        mbd.resolvedConstructorOrFactoryMethod = uniqueCandidate;
                        mbd.constructorArgumentsResolved = true;
                        mbd.resolvedConstructorArguments = EMPTY_ARGS;
                    }
                    //构建无参的实例,并加入到beanWapper 中
                    bw.setBeanInstance(instantiate(beanName, mbd, uniqueCandidate, EMPTY_ARGS));
                    return bw;
                }
            }
            //需要解析构造函数
            // Need to resolve the constructor.
            boolean autowiring = (chosenCtors != null ||
                    mbd.getResolvedAutowireMode() == AutowireCapableBeanFactory.AUTOWIRE_CONSTRUCTOR);
            ConstructorArgumentValues resolvedValues = null;
            //设置能解析到的构造参数的数量
            int minNrOfArgs;
            //显性指定的不为空,使用显性指定的,否则使用xml文件中的
            if (explicitArgs != null) {
                minNrOfArgs = explicitArgs.length;
            }
            else {
                ConstructorArgumentValues cargs = mbd.getConstructorArgumentValues();
                resolvedValues = new ConstructorArgumentValues();
                //处理构造函数,此处可能会查找其他bean
                minNrOfArgs = resolveConstructorArguments(beanName, mbd, bw, cargs, resolvedValues);
            }
            //排序给定的构造函数,public 的函数优先参数数量降序,非public的构造函数参数数量降序
            AutowireUtils.sortConstructors(candidates);
            int minTypeDiffWeight = Integer.MAX_VALUE;
            Set<Constructor<?>> ambiguousConstructors = null;
            LinkedList<UnsatisfiedDependencyException> causes = null;
            //选择构造函数
            for (Constructor<?> candidate : candidates) {
                int parameterCount = candidate.getParameterCount();
                //如果已经找到选用的构造函数或者需要的构造参数小于当前的构造个数则终止,应为已经按照构造参数排序了
                if (constructorToUse != null && argsToUse != null && argsToUse.length > parameterCount) {
                    // Already found greedy constructor that can be satisfied ->
                    // do not look any further, there are only less greedy constructors left.
                    break;
                }
                //参数个数不相等
                if (parameterCount < minNrOfArgs) {
                    continue;
                }
                ArgumentsHolder argsHolder;
                Class<?>[] paramTypes = candidate.getParameterTypes();
                //如果有参数则根据值构造对应参数的类型
                if (resolvedValues != null) {
                    try {
                        //解析注解的构造参数信息(jdk1.6 以后可以在构造函数中使用注解)
                        String[] paramNames = ConstructorPropertiesChecker.evaluate(candidate, parameterCount);
                        if (paramNames == null) {
                            //获取参数名称搜索器
                            ParameterNameDiscoverer pnd = this.beanFactory.getParameterNameDiscoverer();
                            if (pnd != null) {
                                //获取指定构造参数名称
                                paramNames = pnd.getParameterNames(candidate);
                            }
                        }
                        //根据参数名称和数据类型创建持有者
                        argsHolder = createArgumentArray(beanName, mbd, resolvedValues, bw, paramTypes, paramNames,
                                getUserDeclaredConstructor(candidate), autowiring, candidates.length == 1);
                    }
                    catch (UnsatisfiedDependencyException ex) {
                        if (logger.isTraceEnabled()) {
                            logger.trace("Ignoring constructor [" + candidate + "] of bean '" + beanName + "': " + ex);
                        }
                        // Swallow and try next constructor.
                        if (causes == null) {
                            causes = new LinkedList<>();
                        }
                        causes.add(ex);
                        continue;
                    }
                }
                else {
                    //构造函数和getBean 方法传输的参数不相等
                    // Explicit arguments given -> arguments length must match exactly.
                    if (parameterCount != explicitArgs.length) {
                        continue;
                    }
                    //依据传入的构造参数(没有构造参数)
                    argsHolder = new ArgumentsHolder(explicitArgs);
                }
                //探测是否有不确定性的构造函数存在,例如不同构造函数的参数为父子关系
                int typeDiffWeight = (mbd.isLenientConstructorResolution() ?
                        argsHolder.getTypeDifferenceWeight(paramTypes) : argsHolder.getAssignabilityWeight(paramTypes));
                // Choose this constructor if it represents the closest match.
                if (typeDiffWeight < minTypeDiffWeight) {
                    constructorToUse = candidate;
                    argsHolderToUse = argsHolder;
                    argsToUse = argsHolder.arguments;
                    minTypeDiffWeight = typeDiffWeight;
                    ambiguousConstructors = null;
                }
                else if (constructorToUse != null && typeDiffWeight == minTypeDiffWeight) {
                    if (ambiguousConstructors == null) {
                        ambiguousConstructors = new LinkedHashSet<>();
                        ambiguousConstructors.add(constructorToUse);
                    }
                    ambiguousConstructors.add(candidate);
                }
            }
            if (constructorToUse == null) {
                if (causes != null) {
                    UnsatisfiedDependencyException ex = causes.removeLast();
                    for (Exception cause : causes) {
                        this.beanFactory.onSuppressedException(cause);
                    }
                    throw ex;
                }
                throw new BeanCreationException(mbd.getResourceDescription(), beanName,
                        "Could not resolve matching constructor " +
                        "(hint: specify index/type/name arguments for simple parameters to avoid type ambiguities)");
            }
            else if (ambiguousConstructors != null && !mbd.isLenientConstructorResolution()) {
                throw new BeanCreationException(mbd.getResourceDescription(), beanName,
                        "Ambiguous constructor matches found in bean '" + beanName + "' " +
                        "(hint: specify index/type/name arguments for simple parameters to avoid type ambiguities): " +
                        ambiguousConstructors);
            }
            if (explicitArgs == null && argsHolderToUse != null) {
                //将解析到的构造函数加入缓存
                argsHolderToUse.storeCache(mbd, constructorToUse);
            }
        }
        Assert.state(argsToUse != null, "Unresolved constructor arguments");
        //将构造的实例加入beanWapper
        bw.setBeanInstance(instantiate(beanName, mbd, constructorToUse, argsToUse));
        return bw;
    }
```

主要逻辑:
- 构造函数参数的确定:

    1. 根据传入的参数 explicitArgs 判断(getBean 方法传入)
    2. 缓存中获取
    3. 构造方法的注解中获取(jdk 1.6 新增)
    4. 配置文件获取

- 构造函数的确定
    根据参数个数匹配,在匹配之前,要对找到的构造方法集合进行排序(先依据public 构造方法优先参数数量降序排序,然后非public构造方法 参数降序排序),这样可以提高构造方法的查找速率.

- 根据构造参数转换对应的参数类型
- 构造参数不正确性验证
- 根据实例化策略以及得到的构造参数以及构造函数实例化bean.

##### instantiateBean
```java
//AbstractAutowireCapableBeanFactory
//使用默认构造参数初始化bean
protected BeanWrapper instantiateBean(final String beanName, final RootBeanDefinition mbd) {
        try {
            Object beanInstance;
            final BeanFactory parent = this;
            if (System.getSecurityManager() != null) {
                beanInstance = AccessController.doPrivileged((PrivilegedAction<Object>) () ->
                        //实例化策略
                        getInstantiationStrategy().instantiate(mbd, beanName, parent),
                        getAccessControlContext());
            }
            else {
                beanInstance = getInstantiationStrategy().instantiate(mbd, beanName, parent);
            }
            BeanWrapper bw = new BeanWrapperImpl(beanInstance);
            initBeanWrapper(bw);
            return bw;
        }
        catch (Throwable ex) {
            throw new BeanCreationException(
                    mbd.getResourceDescription(), beanName, "Instantiation of bean failed", ex);
        }
    }
```

### 实例化策略 SimpleInstantiationStrategy

在实例化过程中反复用到了实例化策略 ，具体是什么呢？ 通过前面的分析，我们完全可以通过反射来构造实例对象。但是是spring并没有采取反射的方式。而是采用了另外一种方式
```java
public class SimpleInstantiationStrategy{
    @Override
    public Object instantiate(RootBeanDefinition bd, @Nullable String beanName, BeanFactory owner) {
        //如果有需要覆盖或者动态替换的方法，则需要使用CGLB进行动态代理。因为可以在创建的过程中，将动态方法织入类中。
        //但是，如果没有动态改变的方法，则直接使用反射就可以了
        // Don't override the class with CGLIB if no overrides.
        if (!bd.hasMethodOverrides()) {
            Constructor<?> constructorToUse;
            synchronized (bd.constructorArgumentLock) {
                constructorToUse = (Constructor<?>) bd.resolvedConstructorOrFactoryMethod;
                if (constructorToUse == null) {
                    final Class<?> clazz = bd.getBeanClass();
                    if (clazz.isInterface()) {
                        throw new BeanInstantiationException(clazz, "Specified class is an interface");
                    }
                    try {
                        if (System.getSecurityManager() != null) {
                            constructorToUse = AccessController.doPrivileged(
                                    (PrivilegedExceptionAction<Constructor<?>>) clazz::getDeclaredConstructor);
                        }
                        else {
                            constructorToUse = clazz.getDeclaredConstructor();
                        }
                        bd.resolvedConstructorOrFactoryMethod = constructorToUse;
                    }
                    catch (Throwable ex) {
                        throw new BeanInstantiationException(clazz, "No default constructor found", ex);
                    }
                }
            }
            return BeanUtils.instantiateClass(constructorToUse);
        }
        else {
            // Must generate CGLIB subclass.
            return instantiateWithMethodInjection(bd, beanName, owner);
        }
    }
}
// 使用CGLB
public class CglibSubclassingInstantiationStrategy extends SimpleInstantiationStrategy {
    @Override
    protected Object instantiateWithMethodInjection(RootBeanDefinition bd, @Nullable String beanName, BeanFactory owner) {
        return instantiateWithMethodInjection(bd, beanName, owner, null);
    }
    @Override
    protected Object instantiateWithMethodInjection(RootBeanDefinition bd, @Nullable String beanName, BeanFactory owner,
            @Nullable Constructor<?> ctor, Object... args) {
        // Must generate CGLIB subclass...
        return new CglibSubclassCreator(bd, owner).instantiate(ctor, args);
    }
}
````

#### 记录创建bean 的ObjectFactory
在doCreateBean 方法中有如下代码片段：
```java
protected Object doCreateBean(final String beanName, final RootBeanDefinition mbd, final @Nullable Object[] args)
            throws BeanCreationException {
        ...
        ...
        //earlySingletonExposure 字面意思是提早暴露单例
        boolean earlySingletonExposure = (mbd.isSingleton() && this.allowCircularReferences &&
        isSingletonCurrentlyInCreation(beanName));
        if (earlySingletonExposure) {
            if (logger.isTraceEnabled()) {
                logger.trace("Eagerly caching bean '" + beanName +
                        "' to allow for resolving potential circular references");
            }
            //为避免后期循环依赖，可以在bean初始化完前，将创建实例的ObjectFactory加入工厂
            addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean));
        }
        // Initialize the bean instance.
        Object exposedObject = bean;
        try {
            //填充bean属性
            populateBean(beanName, mbd, instanceWrapper);
            exposedObject = initializeBean(beanName, exposedObject, mbd);
        }
}
//AbstractAutowireCapableBeanFactory.getEarlyBeanReference
//对bean的再次依赖引用，主要是引用 SmartInstantiationAwareBeanPostProcessor
//其中我们熟知的AOP就是在这里将advice动态织入bean中。
protected Object getEarlyBeanReference(String beanName, RootBeanDefinition mbd, Object bean) {
        Object exposedObject = bean;
        if (!mbd.isSynthetic() && hasInstantiationAwareBeanPostProcessors()) {
            for (BeanPostProcessor bp : getBeanPostProcessors()) {
                if (bp instanceof SmartInstantiationAwareBeanPostProcessor) {
                    SmartInstantiationAwareBeanPostProcessor ibp = (SmartInstantiationAwareBeanPostProcessor) bp;
                    exposedObject = ibp.getEarlyBeanReference(exposedObject, beanName);
                }
            }
        }
        return exposedObject;
    }
```

- earlySingletonExposure 字面意思是提早暴露单例
- mbd.isSingleton() RootBeanDefinition是否代表的是单例
- this.allowCircularReferences 是否允许循环依赖
- isSingletonCurrentlyInCreation(beanName)  该bean是否在创建中

##### 以简单的AB 循环依赖为例， 类A 中含有属性类B ，而类B 中又会含有属性类A,那么初始化beanA 的过程
![循环依赖](./imgs/spring_循环依赖.png)
spring处理循环依赖的办法。在B中创建依赖A时通过ObjectFactory提供的实例化方法来中断A中属性填充。使B中持有的A仅仅是刚刚初始化并没有填充任何属性的A，而真正初始化A的步骤还是在最开始创建A的的时候进行的，但是因为A与B中的A所表示属性地址是一样的，所以在A中创建好的属性自然可以通过B中的A获取，这样就解决了循环依赖的问题。

#### 属性注入（populateBean）
```java
protected void populateBean(String beanName, RootBeanDefinition mbd, @Nullable BeanWrapper bw) {
        if (bw == null) {
            if (mbd.hasPropertyValues()) {
                throw new BeanCreationException(
                        mbd.getResourceDescription(), beanName, "Cannot apply property values to null instance");
            }
            else {
                // Skip property population phase for null instance.
                return;
            }
        }
        // Give any InstantiationAwareBeanPostProcessors the opportunity to modify the
        // state of the bean before properties are set. This can be used, for example,
        // to support styles of field injection.
        if (!mbd.isSynthetic() && hasInstantiationAwareBeanPostProcessors()) {
            for (BeanPostProcessor bp : getBeanPostProcessors()) {
                if (bp instanceof InstantiationAwareBeanPostProcessor) {
                    InstantiationAwareBeanPostProcessor ibp = (InstantiationAwareBeanPostProcessor) bp;
                    // 返回值是否填充bean
                    if (!ibp.postProcessAfterInstantiation(bw.getWrappedInstance(), beanName)) {
                        return;
                    }
                }
            }
        }
        //获取属性值
        PropertyValues pvs = (mbd.hasPropertyValues() ? mbd.getPropertyValues() : null);
        int resolvedAutowireMode = mbd.getResolvedAutowireMode();
        if (resolvedAutowireMode == AUTOWIRE_BY_NAME || resolvedAutowireMode == AUTOWIRE_BY_TYPE) {
            MutablePropertyValues newPvs = new MutablePropertyValues(pvs);
            // Add property values based on autowire by name if applicable.
            if (resolvedAutowireMode == AUTOWIRE_BY_NAME) {
                // 依据名称注入
                autowireByName(beanName, mbd, bw, newPvs);
            }
            // Add property values based on autowire by type if applicable.
            if (resolvedAutowireMode == AUTOWIRE_BY_TYPE) {
                // 依据类型注入
                autowireByType(beanName, mbd, bw, newPvs);
            }
            pvs = newPvs;
        }
        //判断后处理器是否已经初始化完成
        boolean hasInstAwareBpps = hasInstantiationAwareBeanPostProcessors();
        //是否对依赖进行检查
        boolean needsDepCheck = (mbd.getDependencyCheck() != AbstractBeanDefinition.DEPENDENCY_CHECK_NONE);
        PropertyDescriptor[] filteredPds = null;
        if (hasInstAwareBpps) {
            if (pvs == null) {
                pvs = mbd.getPropertyValues();
            }
            for (BeanPostProcessor bp : getBeanPostProcessors()) {
                if (bp instanceof InstantiationAwareBeanPostProcessor) {
                    InstantiationAwareBeanPostProcessor ibp = (InstantiationAwareBeanPostProcessor) bp;
                    PropertyValues pvsToUse = ibp.postProcessProperties(pvs, bw.getWrappedInstance(), beanName);
                    if (pvsToUse == null) {
                        if (filteredPds == null) {
                            filteredPds = filterPropertyDescriptorsForDependencyCheck(bw, mbd.allowCaching);
                        }
                        pvsToUse = ibp.postProcessPropertyValues(pvs, filteredPds, bw.getWrappedInstance(), beanName);
                        if (pvsToUse == null) {
                            return;
                        }
                    }
                    pvs = pvsToUse;
                }
            }
        }
        if (needsDepCheck) {
            if (filteredPds == null) {
                filteredPds = filterPropertyDescriptorsForDependencyCheck(bw, mbd.allowCaching);
            }
            checkDependencies(beanName, mbd, filteredPds, pvs);
        }

        if (pvs != null) {
            applyPropertyValues(beanName, mbd, bw, pvs);
        }
    }

```

##### autowireByName

依据注入类型（byName/byType）提取依赖的bean，并统一存入PropertyValues中，首先看一下byName 注入：
```java
protected void autowireByName(
            String beanName, AbstractBeanDefinition mbd, BeanWrapper bw, MutablePropertyValues pvs) {
        // 寻找需要依赖注入的非简单属性
        String[] propertyNames = unsatisfiedNonSimpleProperties(mbd, bw);
        for (String propertyName : propertyNames) {
            if (containsBean(propertyName)) {
                //初始化相关的bean
                Object bean = getBean(propertyName);
                pvs.add(propertyName, bean);
                //注册依赖关系
                registerDependentBean(propertyName, beanName);
                if (logger.isTraceEnabled()) {
                    logger.trace("Added autowiring by name from bean name '" + beanName +
                            "' via property '" + propertyName + "' to bean named '" + propertyName + "'");
                }
            }
            else {
                if (logger.isTraceEnabled()) {
                    logger.trace("Not autowiring property '" + propertyName + "' of bean '" + beanName +
                            "' by name: no matching bean found");
                }
            }
        }
    }
```

##### autowireBypeType
```java
protected void autowireByType(
            String beanName, AbstractBeanDefinition mbd, BeanWrapper bw, MutablePropertyValues pvs) {
        TypeConverter converter = getCustomTypeConverter();
        if (converter == null) {
            converter = bw;
        }
        Set<String> autowiredBeanNames = new LinkedHashSet<>(4);
        //寻找bw 中需要依赖注入的属性
        String[] propertyNames = unsatisfiedNonSimpleProperties(mbd, bw);
        for (String propertyName : propertyNames) {
            try {
                PropertyDescriptor pd = bw.getPropertyDescriptor(propertyName);
                // Don't try autowiring by type for type Object: never makes sense,
                // even if it technically is a unsatisfied, non-simple property.
                if (Object.class != pd.getPropertyType()) {
                    //寻找指定属性的set 方法
                    MethodParameter methodParam = BeanUtils.getWriteMethodParameter(pd);
                    // Do not allow eager init for type matching in case of a prioritized post-processor.
                    boolean eager = !(bw.getWrappedInstance() instanceof PriorityOrdered);
                    DependencyDescriptor desc = new AutowireByTypeDependencyDescriptor(methodParam, eager);
                    //解析指定beanName 属性匹配的值，并把解析到的属性名称存储到autowiredBeanNames 中，当属性存在多个封装bean时，如： 
                    //@Autowired private List<A> aList； 将会将找到所有匹配A类型的bean 并将其注入
                    Object autowiredArgument = resolveDependency(desc, beanName, autowiredBeanNames, converter);
                    if (autowiredArgument != null) {
                        pvs.add(propertyName, autowiredArgument);
                    }
                    for (String autowiredBeanName : autowiredBeanNames) {
                        //注册依赖
                        registerDependentBean(autowiredBeanName, beanName);
                        if (logger.isTraceEnabled()) {
                            logger.trace("Autowiring by type from bean name '" + beanName + "' via property '" +
                                    propertyName + "' to bean named '" + autowiredBeanName + "'");
                        }
                    }
                    autowiredBeanNames.clear();
                }
            }
            catch (BeansException ex) {
                throw new UnsatisfiedDependencyException(mbd.getResourceDescription(), beanName, propertyName, ex);
            }
        }
    }
```

###### resolveDependency 寻找匹配的类型
```java
//DefaultListableBeanFactory
public Object resolveDependency(DependencyDescriptor descriptor, @Nullable String requestingBeanName,
            @Nullable Set<String> autowiredBeanNames, @Nullable TypeConverter typeConverter) throws BeansException {
        descriptor.initParameterNameDiscovery(getParameterNameDiscoverer());
        if (Optional.class == descriptor.getDependencyType()) {
            //optional 函数类型的解析（描述符类型）
            return createOptionalDependency(descriptor, requestingBeanName);
        }
        else if (ObjectFactory.class == descriptor.getDependencyType() ||
                ObjectProvider.class == descriptor.getDependencyType()) {
                    // ObjectFactory 或者ObjectFactory 提供者类型的
            return new DependencyObjectProvider(descriptor, requestingBeanName);
        }
        else if (javaxInjectProviderClass == descriptor.getDependencyType()) {
            //javaxInjectProviderClass 类型的注解
            return new Jsr330Factory().createDependencyProvider(descriptor, requestingBeanName);
        }
        else {
            //通用逻辑处理
            Object result = getAutowireCandidateResolver().getLazyResolutionProxyIfNecessary(
                    descriptor, requestingBeanName);
            if (result == null) {
                result = doResolveDependency(descriptor, requestingBeanName, autowiredBeanNames, typeConverter);
            }
            return result;
        }
    }
    @Nullable
    public Object doResolveDependency(DependencyDescriptor descriptor, @Nullable String beanName,
            @Nullable Set<String> autowiredBeanNames, @Nullable TypeConverter typeConverter) throws BeansException {
        //封装注入点
        InjectionPoint previousInjectionPoint = ConstructorResolver.setCurrentInjectionPoint(descriptor);
        try {
            //空方法，提供给子类实现，提供了在解析dependceny 之前利用FactoryBean预处理的一个入口，
            Object shortcut = descriptor.resolveShortcut(this);
            if (shortcut != null) {
                return shortcut;
            }
            Class<?> type = descriptor.getDependencyType();
            //spring 支持@value类型的注解
            Object value = getAutowireCandidateResolver().getSuggestedValue(descriptor);
            if (value != null) {
                if (value instanceof String) {
                    String strVal = resolveEmbeddedValue((String) value);
                    BeanDefinition bd = (beanName != null && containsBean(beanName) ?
                            getMergedBeanDefinition(beanName) : null);
                    value = evaluateBeanDefinitionString(strVal, bd);
                }
                TypeConverter converter = (typeConverter != null ? typeConverter : getTypeConverter());
                try {
                    return converter.convertIfNecessary(value, type, descriptor.getTypeDescriptor());
                }
                catch (UnsupportedOperationException ex) {
                    // A custom TypeConverter which does not support TypeDescriptor resolution...
                    return (descriptor.getField() != null ?
                            converter.convertIfNecessary(value, type, descriptor.getField()) :
                            converter.convertIfNecessary(value, type, descriptor.getMethodParameter()));
                }
            }
            //解析其他各种类型的情况：
            //descriptor 是StreamDependencyDescriptor类型
            //list
            //collection
            //Map 类型
            Object multipleBeans = resolveMultipleBeans(descriptor, beanName, autowiredBeanNames, typeConverter);
            if (multipleBeans != null) {
                return multipleBeans;
            }
            // 获取指定到的候选bean
            Map<String, Object> matchingBeans = findAutowireCandidates(beanName, type, descriptor);
            if (matchingBeans.isEmpty()) {
                if (isRequired(descriptor)) {
                    raiseNoMatchingBeanFound(type, descriptor.getResolvableType(), descriptor);
                }
                return null;
            }

            String autowiredBeanName;
            Object instanceCandidate;
            if (matchingBeans.size() > 1) {
                //确定多个候选bean中的一个
                autowiredBeanName = determineAutowireCandidate(matchingBeans, descriptor);
                if (autowiredBeanName == null) {
                    if (isRequired(descriptor) || !indicatesMultipleBeans(type)) {
                        return descriptor.resolveNotUnique(descriptor.getResolvableType(), matchingBeans);
                    }
                    else {
                        // In case of an optional Collection/Map, silently ignore a non-unique case:
                        // possibly it was meant to be an empty collection of multiple regular beans
                        // (before 4.3 in particular when we didn't even look for collection beans).
                        return null;
                    }
                }
                instanceCandidate = matchingBeans.get(autowiredBeanName);
            }
            else {
                // We have exactly one match.
                Map.Entry<String, Object> entry = matchingBeans.entrySet().iterator().next();
                autowiredBeanName = entry.getKey();
                instanceCandidate = entry.getValue();
            }

            if (autowiredBeanNames != null) {
                autowiredBeanNames.add(autowiredBeanName);
            }
            if (instanceCandidate instanceof Class) {
                instanceCandidate = descriptor.resolveCandidate(autowiredBeanName, type, this);
            }
            Object result = instanceCandidate;
            if (result instanceof NullBean) {
                if (isRequired(descriptor)) {
                    raiseNoMatchingBeanFound(type, descriptor.getResolvableType(), descriptor);
                }
                result = null;
            }
            if (!ClassUtils.isAssignableValue(type, result)) {
                throw new BeanNotOfRequiredTypeException(autowiredBeanName, type, instanceCandidate.getClass());
            }
            return result;
        }
        finally {
            ConstructorResolver.setCurrentInjectionPoint(previousInjectionPoint);
        }
    }
```

#### 初始化bean （initializeBean）

xml中的init-method属性，这个属性的作用是在bean实例化之前，调用 init-method指定的方法来根据用户业务进行相应的实例化。改方法的执行就是在属性填充完成后执行。
```java
protected Object initializeBean(final String beanName, final Object bean, @Nullable RootBeanDefinition mbd) {
        if (System.getSecurityManager() != null) {
            AccessController.doPrivileged((PrivilegedAction<Object>) () -> {
                invokeAwareMethods(beanName, bean);
                return null;
            }, getAccessControlContext());
        }
        else {
            //对特殊bean的处理：Aware，BeanClassLoaderAware,BeanFactoryAware
            invokeAwareMethods(beanName, bean);
        }
        Object wrappedBean = bean;
        if (mbd == null || !mbd.isSynthetic()) {
            //应用处理器
            wrappedBean = applyBeanPostProcessorsBeforeInitialization(wrappedBean, beanName);
        }
        try {
            //激活自定义的init方法
            invokeInitMethods(beanName, wrappedBean, mbd);
        }
        catch (Throwable ex) {
            throw new BeanCreationException(
                    (mbd != null ? mbd.getResourceDescription() : null),
                    beanName, "Invocation of init method failed", ex);
        }
        if (mbd == null || !mbd.isSynthetic()) {
            //后处理器
            wrappedBean = applyBeanPostProcessorsAfterInitialization(wrappedBean, beanName);
        }
        return wrappedBean;
    }
```

1. 激活 Aware 方法

Spring 中提供的一些 Aware 的接口：
    - BeanFactoryAware: 在bean 初始化之后，会注入BeanFactory 的实例。
    - ApplicationContextAware： 在bean 初始化之后，会注入ApplicationContext 的实例。
    - ResourceLoaderAware
    - ServletContextAware

2. 处理器的应用

BeanProcessor 相信大家都不陌生。这是spring开放架构中的一个必不可少的亮点。给用户充足的权限去更改或者拓展Spring。除了BeanPostProcessor外，还有其他的PostProcessor。当然大部分都是以次为基础的，继承自BeanPostProcessor。BeanPostProcessor的使用卫视是在客户自定义初始化方法前以及调用自定义初始化方法后，会分别调用BeanPostProcessor 的postProcessorBeforeInitialization 和postProcessorAfterInitialization方法，使用户可以根据自己的业务需求进行相应处理。
```java
    // before 方法
    @Override
    public Object applyBeanPostProcessorsBeforeInitialization(Object existingBean, String beanName)
            throws BeansException {

        Object result = existingBean;
        for (BeanPostProcessor processor : getBeanPostProcessors()) {
            Object current = processor.postProcessBeforeInitialization(result, beanName);
            if (current == null) {
                return result;
            }
            result = current;
        }
        return result;
    }
    // after 方法
    @Override
    public Object applyBeanPostProcessorsAfterInitialization(Object existingBean, String beanName)
            throws BeansException {

        Object result = existingBean;
        for (BeanPostProcessor processor : getBeanPostProcessors()) {
            Object current = processor.postProcessAfterInitialization(result, beanName);
            if (current == null) {
                return result;
            }
            result = current;
        }
        return result;
    }
```
3. 激活自定义的方法

> 客户定制的初始化方法除了我们熟知的使用 `init-method` 外，还有使自定义的bean实现 initializingBean 接口。并在 afterPropertiesSet 中实现自己定义的业务逻辑。
> init-method 与afterPropertiesSet 都是初始化bean时执行。执行顺序是 afterPropertiesSet 先执行，init-method 后执行。
```java
rotected void invokeInitMethods(String beanName, final Object bean, @Nullable RootBeanDefinition mbd)
            throws Throwable {
        // 检查是否是InitializingBean，是的话先执行 afterPropertiesSet 方法
        boolean isInitializingBean = (bean instanceof InitializingBean);
        if (isInitializingBean && (mbd == null || !mbd.isExternallyManagedInitMethod("afterPropertiesSet"))) {
            if (logger.isTraceEnabled()) {
                logger.trace("Invoking afterPropertiesSet() on bean with name '" + beanName + "'");
            }
            if (System.getSecurityManager() != null) {
                try {
                    AccessController.doPrivileged((PrivilegedExceptionAction<Object>) () -> {
                        ((InitializingBean) bean).afterPropertiesSet();
                        return null;
                    }, getAccessControlContext());
                }
                catch (PrivilegedActionException pae) {
                    throw pae.getException();
                }
            }
            else {
                ((InitializingBean) bean).afterPropertiesSet();
            }
        }
        // init-method 调用
        if (mbd != null && bean.getClass() != NullBean.class) {
            String initMethodName = mbd.getInitMethodName();
            if (StringUtils.hasLength(initMethodName) &&
                    !(isInitializingBean && "afterPropertiesSet".equals(initMethodName)) &&
                    !mbd.isExternallyManagedInitMethod(initMethodName)) {
                //用户自定义的init-meethod
                invokeCustomInitMethod(beanName, bean, mbd);
            }
        }
    }
```

#### 注册DisposableBean
spring 不但提供了对初始化方法的拓展入口，同样也提供了销毁方法的入口。对于销毁方法的拓展，除了我们熟知的destroy-method外，用户还可以注册后处理器 DestructionAwareBeanPostProcessors来统一bean 的销毁方法。
```java
protected void registerDisposableBeanIfNecessary(String beanName, Object bean, RootBeanDefinition mbd) {
        AccessControlContext acc = (System.getSecurityManager() != null ? getAccessControlContext() : null);
        if (!mbd.isPrototype() && requiresDestruction(bean, mbd)) {
            if (mbd.isSingleton()) {
                // Register a DisposableBean implementation that performs all destruction
                // work for the given bean: DestructionAwareBeanPostProcessors,
                // DisposableBean interface, custom destroy method.
                // 单例模式下注册要销毁的bean，此方法中会处理实现DisposableBean的bean，
                // 并且对所有的bean使用DestructionAwareBeanPostProcessors 处理
                registerDisposableBean(beanName,
                        new DisposableBeanAdapter(bean, beanName, mbd, getBeanPostProcessors(), acc));
            }
            else {
            	// 自定义scope 处理
                // A bean with a custom scope...
                Scope scope = this.scopes.get(mbd.getScope());
                if (scope == null) {
                    throw new IllegalStateException("No Scope registered for scope name '" + mbd.getScope() + "'");
                }
                scope.registerDestructionCallback(beanName,
                        new DisposableBeanAdapter(bean, beanName, mbd, getBeanPostProcessors(), acc));
            }
        }
    }
```

### 总结
- bean 的创建经历了三大步。第一步：bean 的加载； 第二步： 准备创建bean； 第三步： bean 的创建。

- bean 的加载：
	1. 转换对应的beanName  
	2. 尝试从缓存中加载单例
	3. bean 的实例化
	4. 原型模式的依赖检查
	5. 检查parentBeanFactory
	6. 将存储xml 配置文件的GerenicBeanDefinition 转换为 RootBeanDefinition 
	7. 寻找依赖 -> spring 在加载bean的时候，会优先加载该bean 所依赖的bean
	8. 针对不同的scope进行bean的创建
	9. 类型转换

- 准备创建bean
	1. 根据设置的class属性及className来解析class
	2. 对override属性进行标记及验证
	    处理spring中的lookup-method 和replaced-method的。这两个配置的加载其实就是将配置统一存在BeanDefinition中的methodOverrides属性里。此处的处理，就是对methodOverrides的处理。
	3. 应用初始化前的后处理器，解析指定bean是否存在初始化前的短路操作。
	
- 创建bean
	1. 如果是单例则需要首先清除缓存。
    2. 实例化bean ，将BeanDefinition 转换为BeanWrapper 。转换是一个复杂的过程，但是我们可以尝试概括大致的功能，如下所示。
		- 如果存在工厂方法则使用工厂方法进行初始化。
		- 一个类有多个构造函数，每个构造函数都有不同的参数，所以需要根据参数锁定构造函数并进行初始化。
		- 如果既不存在工厂方法也不存在带有参数的构造函数，则使用默认的构造函数进行bean 的实例f匕。
	3. MergedBeanDefinitionPostProcessor 的应用。
		- bean 合并后的处理， Autowired 注解正是通过此方法实现诸如类型的预解析。
	4. 依赖处理。
		- 在Spring 中会有循环依赖的情况，例如，当A 中含有B 的属性，而B 中又含有A 的属性时就会构成一个循环依赖，此时如果A 和B 都是单例，那么在Spring 中的处理方式就是当创建B 的时候，涉及自动注入A 的步骤时，并不是直接去再次创建A ，而是通过放入缓存中的ObjectFactory 来创建实例，这样就解决了循环依赖的问题。
	5. 属性填充。将所有属性填充至bean 的实例中。
	6. 循环依赖检查。
		- 之前有提到过，在Spring 中解决循环依赖只对单例有效，而对于prototype 的bean, Spring
没有好的解决办法，唯一要做的就是抛出异常。在这个步骤里面会检测已经加载的bean 是否已经出现了依赖循环，并判断是否需要抛出异常。
	7. 注册DisposableBean 。
		- 如果配置了destroy-method ，这里需要注册以便于在销毁时候调用。
	8. 完成创建井返回。
		- 可以看到上面的步骤非常的繁琐，每一步骤都使用了大量的代码来完成其功能，最复杂也是最难以理解的当属循环依赖的处理，在真正进入doCreateBean 前我们有必要先了解下循环依赖。
