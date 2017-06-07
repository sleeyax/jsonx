# JSON Parsing Benchmarks
Comparing: 
  * JSONX.parse
  * !JSONX (from AST)
  * JSON.decode

## Running Test: `hello_world`
 **JSONX.parse**: 107.43us average over 100 trial(s)

 **!JSONX (from AST)**: 51.77us average over 100 trial(s)

 **JSON.decode**: 110.45us average over 100 trial(s)

## Running Test: `junk`
 **JSONX.parse**: 20.43us average over 100 trial(s)

 **!JSONX (from AST)**: 3.12us average over 100 trial(s)

 **JSON.decode**: 19.60us average over 100 trial(s)


# Conclusion
  * JSONX.parse: 63.93us average
  * !JSONX (from AST): 27.45us average
  * JSON.decode: 65.03us average

Winner: **JSONX.parse** (0.06ms average)
