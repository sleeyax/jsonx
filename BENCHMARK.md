# JSON Parsing Benchmarks
Comparing: 
  * JSONX
  * JSON.decode

## Running Test: `hello_world`
 JSONX: 4725us

 JSON.decode: 7032us

## Running Test: `schema`
 JSONX: 540us

 JSON.decode: 332us

## Running Test: `servlet`
JSONX: **FAILED** within 1396us

```JSON syntax error: expected ',', found TokenType.NUMBER```

 JSON.decode: 2214us


# Conclusion
  * JSONX: 2632.50us average
  * JSON.decode: 3192.67us average

Winner: **JSONX** (2.63ms average)
