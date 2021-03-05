## RestTemplate 调用exchange 请求 发送 和返回 json 数据，报错

- 报错信息

```json
org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unexpected character '{' (code 123) in prolog; expected '<'
 at [row,col {unknown-source}]: [1,1]; nested exception is com.fasterxml.jackson.core.JsonParseException: Unexpected character '{' (code 123) in prolog; expected '<'
 at [row,col {unknown-source}]: [1,1]
	at org.springframework.http.converter.json.AbstractJackson2HttpMessageConverter.readJavaType(AbstractJackson2HttpMessageConverter.java:238) ~[spring-web-4.3.18.RELEASE.jar:4.3.18.RELEASE]
	at org.springframework.http.converter.json.AbstractJackson2HttpMessageConverter.read(AbstractJackson2HttpMessageConverter.java:223) ~[spring-web-4.3.18.RELEASE.jar:4.3.18.RELEASE]
	at org.springframework.web.client.HttpMessageConverterExtractor.extractData(HttpMessageConverterExtractor.java:96) ~[spring-web-4.3.18.RELEASE.jar:4.3.18.RELEASE]
	at org.springframework.web.client.RestTemplate$ResponseEntityResponseExtractor.extractData(RestTemplate.java:932) ~[spring-web-4.3.18.RELEASE.jar:4.3.18.RELEASE]
	at org.springframework.web.client.RestTemplate$ResponseEntityResponseExtractor.extractData(RestTemplate.java:916) ~[spring-web-4.3.18.RELEASE.jar:4.3.18.RELEASE]
	at org.springframework.web.client.RestTemplate.doExecute(RestTemplate.java:663) ~[spring-web-4.3.18.RELEASE.jar:4.3.18.RELEASE]
	at org.springframework.web.client.RestTemplate.execute(RestTemplate.java:621) ~[spring-web-4.3.18.RELEASE.jar:4.3.18.RELEASE]
	at org.springframework.web.client.RestTemplate.exchange(RestTemplate.java:539) ~[spring-web-4.3.18.RELEASE.jar:4.3.18.RELEASE]
```

- 报错原因

是由于默认返回值解析 的事 xml 格式。需要加请求头

```java
HttpHeaders headers = new HttpHeaders();
headers.setContentType(MediaType.APPLICATION_JSON_UTF8);
headers.add("Accept", MediaType.APPLICATION_JSON.toString());
HttpEntity<Object> entity = new HttpEntity<>(body,headers);
```

完整代码如下：

```java
public ResponseRst postMessage(String getUrl, Map<String, Object> body) {
        RestTemplate restTemplate = getRestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON_UTF8);
        headers.add("Accept", MediaType.APPLICATION_JSON.toString());
        HttpEntity<Object> entity = new HttpEntity<>(body,headers);
        ResponseEntity<ResponseRst> exchange = restTemplate.exchange(getUrl, HttpMethod.POST, entity, ResponseRst.class);
        boolean xxSuccessful = exchange.getStatusCode().is2xxSuccessful();
        if(xxSuccessful){
            return exchange.getBody();
        }else{
            log.error("请求接口失败。code:{}",exchange.getStatusCode().value());
            throw SfpubRunException.newInstance("请求接口失败。url:" + getUrl);
        }
    }
```

