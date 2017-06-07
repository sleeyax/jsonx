# JSON Parsing Benchmarks
Comparing: 
  * JSONX
  * JSON.decode

## Running Test: `hello_world`
 **JSONX**: 5388us

 **JSON.decode**: 7595us

## Running Test: `schema`
 **JSONX**: 688us

 **JSON.decode**: 314us

## Running Test: `servlet`
**JSONX**: **FAILED** within 1809us

```JSON syntax error: expected ',', found TokenType.NUMBER```

 **JSON.decode**: 2117us


# Conclusion
  * JSONX: 3038.00us average
  * JSON.decode: 3342.00us average

Winner: **JSONX** (3.04ms average)
