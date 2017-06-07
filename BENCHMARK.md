# JSON Parsing Benchmarks
Comparing: 
  * JSONX
  * JSON.decode

## Running Test: `hello_world`
 JSONX: 4879us
 JSON.decode: 7061us
## Running Test: `schema`
 JSONX: 487us
 JSON.decode: 291us
## Running Test: `servlet`
JSONX: **FAILED** within 1360us

```JSON syntax error: expected ',', found TokenType.NUMBER```
 JSON.decode: 2125us

# Conclusion
  * JSONX: 2683.00us average
  * JSON.decode: 3159.00us average

Winner: **JSONX** (2.68ms average)
