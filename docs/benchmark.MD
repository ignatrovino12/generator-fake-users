# User Generation Benchmark

## Case 1

**Batch size:** 1,000 · **Batches:** 100 · **Total users:** 100,000

| Run | Time (s) | Speed (users/s) |
|---:|---:|---:|
| 1 | 60.69 | 1,647.84 |
| 2 | 60.45 | 1,654.13 |
| 3 | 60.80 | 1,644.69 |

## Case 2

**Batch size:** 100 · **Batches:** 1,000 · **Total users:** 100,000

| Run | Time (s) | Speed (users/s) |
|---:|---:|---:|
| 1 | 99.31 | 1,006.99 |
| 2 | 94.04 | 1,063.39 |
| 3 | 93.19 | 1,073.06 |

## Case 3

**Batch size:** 100 · **Batches:** 100 · **Total users:** 10,000

| Run | Time (s) | Speed (users/s) |
|---:|---:|---:|
| 1 | 9.97 | 1,002.52 |
| 2 | 9.73 | 1,027.51 |
| 3 | 10.13 | 987.38 |

## Case 4

**Batch size:** 1,000 · **Batches:** 1,000 · **Total users:** 1,000,000

| Run | Time (s) | Speed (users/s) |
|---:|---:|---:|
| 1 | 604.85 | 1,653.30 |

## Conclusion

For Batch Size 1,000 the average speed is around 1,650 users per second. Meanwhile for a batch size of 100 it is about 1,000.
