# 接口路径
- 一个接口的可读性，对于调用者和维护者是非常重要的，当我们规划好怎么定义url 后，也就决定了项目中我们controller分类。
- http 接口通常的结构：协议：//域名/应用content path/自定义路径？查询参数 （http://api.zbcn.com/zbcn-notication/users?pageSize=10&pageNo=1）

## 域名的利用
若域名无法区分是接口还是页面功能的时候，对于api 接口统一添加/api 以区分这是接口服务  
eg: 
 - https://back.zbcn.com/api/login
 - https://api-back.zbcn.com/login

说明：
- back 代表是后台管理的意思。所以想要进入后台管理应该访问： `https://back.zbcn.com`, 前台为：`https://www.zhuma.com`
- 在域名使用中我们可以利用三级域名对我们整体系统大的功能或应用进行很好的划分

## 词性的使用
定义自定义路径部分时，使用名词的复数形式定义一个资源，如若有动词词性在url中考虑以下划线区分。

### 基本操作
- GET /users                    # 获取用户列表
- GET /users/{userId}       # 查看某个具体的用户信息
- POST /users                 # 新建一个用户
- PUT /users/{userId}       # 全量更新某一个用户信息
- PATCH /users/{userId}   # 选择性更新某一个用户信息
- DELETE /users/{userId} # 删除某一个用户

### 批量操作
- POST /users/_mget         # 批量获取多个用户
- POST /users/_mcreate    # 批量创建多个用户
- POST /users/_mupdate   # 批量更新多个用户
- POST /users/_mdelete    # 批量删除多个用户
- POST /users/_bulk          # 批量功能组装（后面会讲到）
### 动词词性加入url（原则上此种情况是不被推荐的）
- GET /users/_search        # 搜索用户
- POST /users/_init         # 初化所有用户

## 说明
1. __批量操作__ 时，统一使用POST作为HTTP METHOD，原因是 批量操作参数的数据大小不可控，使用request param可能超过某些浏览器对参数的长度限制，实际上，URL不存在参数长度上限的问题，HTTP协议规范没有对URL长度进行限制，这个限制是特定的浏览器及服务器对它的限制
2. URL路径是对大小写敏感的，例如：/users 和 /Users 是两个接口哦，但是我们规定URL全部小写。

##　URL区分功能　(管理 我的功能)
- 上面我们提到的 关于/users 用户功能的举例，通常情况下，这其实是一个管理用户资源的功能的接口，用于表示对用户这个资源的增删改查等管理功能。
- 我的功能 是对于前端用户下的某某资源的说明，我们通常定义为my-开头。
eg:
    - GET /my-orders 我的订单列表
    - GET /users/{userId}/orders 管理查看某一个用户下的订单列表

## 一些约定
1.  路径中多个单词时，使用中划线 `-` 来连接
2. 不允许在路径中出现大写字母（查询参数名称除外）
3. 接口后省略xxx.do（很多人愿意加上.do这种形式，注意我们的每一个url代表的是一个资源哦）



# 参数定义
- 一次请求传递参数的方式主要有 URL路径中、请求头中、请求体中还有通过cookie等

## MediaType 的选择
- MediaType即是Internet Media Type，互联网媒体类型；也叫做MIME类型，在Http协议消息头中，使用Content-Type来表示具体请求中的媒体类型信息。
- 对于POST、PUT、PATCH这种HTTP方法，统一使用 application/json，将参数放在请求体中以JSON格式传递至服务器
- 对于GET、DELETE的HTTP方法，使用默认类型（application/x-www-form-urlencoded

- 特殊情况特殊考虑，例如进行文件上传时，使用 multipart/form-data类型等

## 路径参数
- 对应spring mvc框架中@PathVariable注解
- 当路径参数值中有带点"."的情况时，spring mvc框架中有对点做特殊处理，这导致在程序中只能接收到点之前的内容，例如你的请求是：GET https://api.zhuma.com/users/hehe.haha，后端在接收userId='hehe.haha'时，只会接收到hehe字符串，后面的部分（.hah）被舍弃掉了。
解决方式:
```java
@Configuration
public class MvcConfig extends WebMvcConfigurerAdapter {
    @Override
    public void configurePathMatch(PathMatchConfigurer configurer) {
        configurer.setUseSuffixPatternMatch(false);//可以让URL路径中带小数点 '.' 后面的值不被忽略 
    }
 
}
```

## 请求头参数
- 对应spring mvc框架中@RequestHeader注解
- 对于提供给APP（android、ios、pc） 的接口我们可能需要关注一些调用信息，例如 用户登录信息、调用来源、app版本号、api的版本号、安全验证信息 等等，我们将这些信息放入头信息（HTTP HEAD中），下面给出在参数命名的例子：
    - X-Token          用户的登录token（用于兑换用户登录信息）
    - Api-Version     api的版本号
    - App-Version    app版本号
    - Call-Source    调用来源	(IOS、ANDROID、PC、WECHAT、WEB)
    - Authorization   安全校验参数（后面会有文章详细介绍该如何做安全校验）


### 我们应该考虑一下几个问题:
1. 为什么需要收集 api版本号、app版本号、调用来源这些信息呢？

主要有几个原因：
  - 方便线上环境定位问题，这也是一个重要的原因（我们后面会讲通过切面全局打印非GET请求的接口调用日志）。
  - 我们可以通过这些参数信息处理我们的业务逻辑，而没有必要在用到的时候我们才想起来让调用者将信息传递过来，导致同一功能性的参数，参数名和参数值不统一的情况发生。

2. 是每个接口都要这些参数么？
    - 建议将所有的接口都传递上述参数信息
3. 怎么做这些参数的校验呢？
    - 你可以写个拦截器（类似HeaderParamsCheckInterceptor），统一校验你的接口中全局的header参数。
4. Header参数大小写不敏感，所以参数X-Token和X-TOEKN是一个参数

## 参数请求体 
- 参数传递分为了大体两种 URL请求查询参数、请求体参数，对于请求体参数我们选择以JSON格式传递过来
- URL请求查询参数、请求体参数这两种方式分别对应了spring mvc框架中的 @RequestParam、@RequestBody两个注解进行修饰。

# 返回值封装

## 数据交换格式
交换格式目前主流的应该只有XML、JSON两种. 这里我们不做对比，我们使用JSON作为接口的返回格式。
## 数据返回格式
- 数据的返回格式其实是个比较纠结的问题，在restful风格中很多文章都讲解使用的是http状态码控制请求的结果状态
- http状态码为200~300的时候，为正常状态，response响应体即为所需要返回的数据，404时代表没有查询到数据，响应体即为空，500为系统错误，响应体也为空等等。
- 但是这种方式也是存在很大问题的，一是http状态码是有限的，而且每个状态码都已经被赋予特殊的含义，在企业开发中当接口遇到错误的时候，我们可能更希望将结果状态码标记的更为详细，更利于前端开发者使用，毕竟写接口的目的也是方便前端使用，这样也可以降低前后端开发人员沟通成本

## 统一数据格式封装类
```java
public class Result implements Serializable {
 
    private static final long serialVersionUID = -3948389268046368059L;
 
    private Integer code;
 
    private String msg;
 
    private Object data;
 
    public Result() {}
 
    public Result(Integer code, String msg) {
        this.code = code;
        this.msg = msg;
    }
 
    public static Result success() {
        Result result = new Result();
        result.setResultCode(ResultCode.SUCCESS);
        return result;
    }
 
    public static Result success(Object data) {
        Result result = new Result();
        result.setResultCode(ResultCode.SUCCESS);
        result.setData(data);
        return result;
    }
 
    public static Result failure(ResultCode resultCode) {
        Result result = new Result();
        result.setResultCode(resultCode);
        return result;
    }
 
    public static Result failure(ResultCode resultCode, Object data) {
        Result result = new Result();
        result.setResultCode(resultCode);
        result.setData(data);
        return result;
    }
 
    public void setResultCode(ResultCode code) {
        this.code = code.code();
        this.msg = code.message();
    }
}
```
**备注**:

- 上面代码我们注意到其中引入了一个ResultCode枚举类，该类也是我们后面紧接着要说的，全局统一返回状态码。
- 这里说明下字段data不是在code=1为成功的时候才会有值哦，比如当code为参数无效错误时，data可以放入更详细的错误描述，用于指明具体是哪个参数为什么导致的无效的。

### 全局状态码
- 当你发现你的系统中错误码随意定义，没有任何规范的时候，你应该考虑下使用一个枚举全局管理下你的状态码，这对线上环境定位错误问题和后续接口文档的维护都是很有帮助的。
eg:
```java
public enum ResultCode {
 
    /* 成功状态码 */
    SUCCESS(1, "成功"),
 
    /* 参数错误：10001-19999 */
    PARAM_IS_INVALID(10001, "参数无效"),
    PARAM_IS_BLANK(10002, "参数为空"),
    PARAM_TYPE_BIND_ERROR(10003, "参数类型错误"),
    PARAM_NOT_COMPLETE(10004, "参数缺失"),
 
    /* 用户错误：20001-29999*/
    USER_NOT_LOGGED_IN(20001, "用户未登录"),
    USER_LOGIN_ERROR(20002, "账号不存在或密码错误"),
    USER_ACCOUNT_FORBIDDEN(20003, "账号已被禁用"),
    USER_NOT_EXIST(20004, "用户不存在"),
    USER_HAS_EXISTED(20005, "用户已存在"),
 
    /* 业务错误：30001-39999 */
    SPECIFIED_QUESTIONED_USER_NOT_EXIST(30001, "某业务出现问题"),
 
    /* 系统错误：40001-49999 */
    SYSTEM_INNER_ERROR(40001, "系统繁忙，请稍后重试"),
 
    /* 数据错误：50001-599999 */
    RESULE_DATA_NONE(50001, "数据未找到"),
    DATA_IS_WRONG(50002, "数据有误"),
    DATA_ALREADY_EXISTED(50003, "数据已存在"),
 
    /* 接口错误：60001-69999 */
    INTERFACE_INNER_INVOKE_ERROR(60001, "内部系统接口调用异常"),
    INTERFACE_OUTTER_INVOKE_ERROR(60002, "外部系统接口调用异常"),
    INTERFACE_FORBID_VISIT(60003, "该接口禁止访问"),
    INTERFACE_ADDRESS_INVALID(60004, "接口地址无效"),
    INTERFACE_REQUEST_TIMEOUT(60005, "接口请求超时"),
    INTERFACE_EXCEED_LOAD(60006, "接口负载过高"),
 
    /* 权限错误：70001-79999 */
    PERMISSION_NO_ACCESS(70001, "无访问权限");
 
    private Integer code;
 
    private String message;
 
    ResultCode(Integer code, String message) {
        this.code = code;
        this.message = message;
    }
 
    public Integer code() {
        return this.code;
    }
 
    public String message() {
        return this.message;
    }
 
    public static String getMessage(String name) {
        for (ResultCode item : ResultCode.values()) {
            if (item.name().equals(name)) {
                return item.message;
            }
        }
        return name;
    }
 
    public static Integer getCode(String name) {
        for (ResultCode item : ResultCode.values()) {
            if (item.name().equals(name)) {
                return item.code;
            }
        }
        return null;
    }
 
    @Override
    public String toString() {
        return this.name();
    }
 
    //校验重复的code值
    public static void main(String[] args) {
        ResultCode[] ApiResultCodes = ResultCode.values();
        List<Integer> codeList = new ArrayList<Integer>();
        for (ResultCode ApiResultCode : ApiResultCodes) {
            if (codeList.contains(ApiResultCode.code)) {
                System.out.println(ApiResultCode.code);
            } else {
                codeList.add(ApiResultCode.code());
            }
        }
    }
}
```

- 上述例子中我们对状态码做了一个大的类型上的划分，在实际开发中你可以在后面写你更加详细的错误状态


## 完整Controller实例
- 那我们以查询、更新用户为例，看看现在我们写一个完整的controller都需要做什么呢？
```java
@RestController
@RequestMapping("/users")
public class UserController {
 
    private static final Logger LOGGER = LoggerFactory.getLogger(UserController.class);
 
    private final UserService userService;
 
    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }
 
    @GetMapping("/{userId}")
    Result getUser(@PathVariable("userId") Long userId) {
        User user = userService.getUserById(userId);
        return Result.success(user);
    }
 
    @PutMapping
    public Result updateUser(@RequestBody User user) {
        LOGGER.info("Call updateUser start, params:{}", JsonUtil.object2Json(user));//注意此处打印日志有不合理的地方，user里可能带有pwd密码等明文敏感信息，需要做过滤打印。
 
        Result result = new Result();
 
        //参数校验
        if (user.getId() == null) {
            result.setResultCode(ResultCode.PARAM_IS_INVALID);
            LOGGER.info("Call updateUser end, result:{}", JsonUtil.object2Json(result));
            return result;
        }
 
        try {
            //更新数据
            User dbUser = userService.getUserById(user.getId());
            if (dbUser == null) {
                result.setResultCode(ResultCode.USER_NOT_EXIST);
            } else {
                User updatedUser = userService.updateDbAndCache(user);
                result.setData(updatedUser);
                result.setResultCode(ResultCode.SUCCESS);
            }
        } catch (Exception e) {
            LOGGER.info("Call updateUser occurs exception, caused by: ", e);
            result.setResultCode(ResultCode.SYSTEM_INNER_ERROR);
        }
 
        LOGGER.info("Call updateUser end, result:{}", JsonUtil.object2Json(result));
        return result;
    }
 
}
```
__更新操作逻辑:__  
① 请求参数、响应结果日志打印   
② 基础参数的校验   
③更新用户业务主逻辑   
④ 全局异常的捕获   
⑤ 对Result结果的封装。   

*以上代码可以优化*:

① 请求参数、响应结果日志打印 -> 使用在controller方法外对做切面统一打印日志（非GET方法都会打印）  
② 基础参数的校验 -> 使用hibernate validate做操作校验  
④ 全局异常的捕获 -> 使用@ControllerAdvice写全局异常处理类控制异常展现方式  
⑤ 对Result结果的封装 -> 实现ResponseBodyAdvice接口，对接口响应体统一处理

## 无效数据清理，必要数据返回
- 无效数据清理：对于json响应接口，我们需要遵守对所有值为null的字段不做返回，对前端不关心的数据不做返回（合理的定义VO是很有必要的）。 对于spring boot 我们可以用下配置，实现字段值为null时不做返回。
```properties
spring.jackson.date-format=yyyy-MM-dd HH:mm:sss
pring.jackson.time-zone=Asia/Shanghai
spring.jackson.default-property-inclusion= non_null
```
- 必要数据返回：对于添加（POST）、修改（PUT | PATCH）这类方法我们需要立即返回添加或更新后的数据以备前端使用（这是一个约定需要遵守）。

