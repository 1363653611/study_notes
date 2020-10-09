# 前端下载文件变成了export.zip.

主要原因是文件头设置有问题：

1. 未设置有效的文件头
2. 设置文件头要在写入数据之前。

源码

```java
 /**
     * 设置 数据流写入成功的响应头信息(需要将请求头放在流写入的前面，下载文件会出现问题)
     * @param response
     * @param name
     * @throws IOException
     */
public static void setSuccessResponseHeader(HttpServletResponse response,String name) throws IOException {
    // 设置信息给客户端不解析
    String type = new MimetypesFileTypeMap().getContentType(name);
    // 设置contentType，即告诉客户端所发送的数据属于什么类型
    if (StringUtils.isEmpty(type)) {
        type = MediaType.APPLICATION_OCTET_STREAM_VALUE;
    }
    response.setHeader(HttpHeaders.CONTENT_TYPE, type);
    // 设置扩展头，当Content-Type 的类型为要下载的类型时 , 这个信息头会告诉浏览器这个文件的名字和类型。
    response.setHeader(HttpHeaders.CONTENT_DISPOSITION, "attachment;filename=" + URLEncoder.encode(name, "UTF-8"));
}

/**
     * 数据写入response
     * @param data
     * @param name
     * @throws IOException
     */
public static void successResponse(byte[] data, String name) throws IOException {
    HttpServletResponse response = getHttpResponse();
    try ( OutputStream outputStream  = response.getOutputStream()){
        setSuccessResponseHeader(response,name);
        outputStream.write(data);
        outputStream.flush();
    }
}

/**
     * 下载文件失败后 ，返回 json String 格式
     * @param data
     * @return
     */
public static String failResponse(Object data) {
    HttpServletResponse response = getHttpResponse();
    response.setHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_UTF8_VALUE);
    FailResponse failResponse = new FailResponse();
    failResponse.setData(data);
    failResponse.setMsg("请求失败。");
    failResponse.setData(data);
    return JSON.toJSONString(failResponse);
}

/**************以responsEntity 的形式返回***************/
public static ResponseEntity successEntity(byte[] data, String name) throws UnsupportedEncodingException {
        HttpHeaders headers = new HttpHeaders();
        name = URLEncoder.encode(name, "UTF-8");
        headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + name);
        headers.add(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_OCTET_STREAM_VALUE);
        HttpStatus statusCode = HttpStatus.OK;
        return new ResponseEntity<>(data, headers, statusCode);
    }

    public static ResponseEntity failEntity(Object data) {
        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_UTF8_VALUE);
        HttpStatus statusCode = HttpStatus.BAD_REQUEST;
        FailResponse failResponse = new FailResponse();
        failResponse.setData(data);
        failResponse.setMsg("请求失败。");
        return new ResponseEntity<>(failResponse, headers, statusCode);
    }
```

