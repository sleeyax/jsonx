# JSON Parsing Benchmarks
Comparing: 
  * JSONX
  * JSONX (profiled)
  * JSON.decode

## Running Test: `hello_world`
 **JSONX**: 4723us

 **JSONX (profiled)**: 336us

 **JSON.decode**: 5107us

## Running Test: `schema`
 **JSONX**: 775us

 **JSONX (profiled)**: 235us

 **JSON.decode**: 289us

## Running Test: `servlet`
 **JSONX**: 2633us

 **JSONX (profiled)**: 1817us

 **JSON.decode**: 2887us

## Running Test: `twitter_credentials`
 **JSONX**: 4372us

 **JSONX (profiled)**: 1448us

 **JSON.decode**: 926us


# Conclusion
  * JSONX: 3125.75us average
  * JSONX (profiled): 959.00us average
  * JSON.decode: 2302.25us average

Winner: **JSONX (profiled)** (0.96ms average)
