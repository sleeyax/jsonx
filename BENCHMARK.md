# JSON Parsing Benchmarks
Comparing: 
  * JSONX.parse
  * JSONX.parseDartValue
  * JSONX.astToDart
  * JSON.decode
  * !JSONX(profiled)
  * !JSONX (parse-only)

## Running Test: `hello_world`
 **JSONX.parse**: 4.34us average over 100 trial(s)

 **JSONX.parseDartValue**: 3.68us average over 100 trial(s)

 **JSONX.astToDart**: 9.56us average over 100 trial(s)

 **JSON.decode**: 4.40us average over 100 trial(s)

 **!JSONX(profiled)**: 25.76us average over 100 trial(s)

 **!JSONX (parse-only)**: 3.81us average over 100 trial(s)

## Running Test: `schema`
 **JSONX.parse**: 28.99us average over 100 trial(s)

 **JSONX.parseDartValue**: 28.94us average over 100 trial(s)

 **JSONX.astToDart**: 77.32us average over 100 trial(s)

 **JSON.decode**: 68.95us average over 100 trial(s)

 **!JSONX(profiled)**: 256.12us average over 100 trial(s)

 **!JSONX (parse-only)**: 60.18us average over 100 trial(s)

## Running Test: `servlet`
 **JSONX.parse**: 417.63us average over 100 trial(s)

 **JSONX.parseDartValue**: 160.58us average over 100 trial(s)

 **JSONX.astToDart**: 171.50us average over 100 trial(s)

 **JSON.decode**: 99.87us average over 100 trial(s)

 **!JSONX(profiled)**: 404.60us average over 100 trial(s)

 **!JSONX (parse-only)**: 111.49us average over 100 trial(s)

## Running Test: `twitter_credentials`
 **JSONX.parse**: 178.01us average over 100 trial(s)

 **JSONX.parseDartValue**: 101.25us average over 100 trial(s)

 **JSONX.astToDart**: 143.26us average over 100 trial(s)

 **JSON.decode**: 61.14us average over 100 trial(s)

 **!JSONX(profiled)**: 285.96us average over 100 trial(s)

 **!JSONX (parse-only)**: 97.62us average over 100 trial(s)

## Running Test: `five_kb`
**JSONX.parse**: **FAILED** within 405us

```JSON syntax error at offset 808: unexpected character 'n' - " magna.\\r\\n"```


**JSONX.parseDartValue**: **FAILED** within 56us

```JSON syntax error at offset 808: unexpected character 'n' - " magna.\\r\\n"```


**JSONX.astToDart**: **FAILED** within 35us

```JSON syntax error at offset 808: unexpected character 'n' - " magna.\\r\\n"```


 **JSON.decode**: 95.51us average over 100 trial(s)

**!JSONX(profiled)**: **FAILED** within 18us

```JSON syntax error at offset 808: unexpected character 'n' - " magna.\\r\\n"```


**!JSONX (parse-only)**: **FAILED** within 27us

```JSON syntax error at offset 808: unexpected character 'n' - " magna.\\r\\n"```



# Conclusion
  * JSONX.parse: 157.24us average
  * JSONX.parseDartValue: 73.61us average
  * JSONX.astToDart: 100.41us average
  * JSON.decode: 65.97us average
  * !JSONX(profiled): 243.11us average
  * !JSONX (parse-only): 68.28us average

Winner: **JSON.decode** (0.07ms average)
