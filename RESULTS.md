## 4. Results

### 4.2 Traversals (p50 / p95 ms)

| Platform | 1-hop | 2-hop | 3-hop |
|---|---|---|---|
| CognoDB | 307.27 / 348.49 | 307.61 / 614.67 | 306.37 / 544.87 |
| Neo4j | 97.18 / 191.92 | 85.85 / 108.59 | 89.31 / 103.48 |
| Memgraph | 5.06 / 29.58 | 5.01 / 32.39 | 3.38 / 13.16 |
| FalkorDB | 1.48 / 2.03 | 1.37 / 2.15 | 1.44 / 2.43 |
| ArangoDB | 4.46 / 7.12 | 4.54 / 12.21 | 4.45 / 9.03 |

### 4.3 Lookups (p50 / p95 ms)

| Platform | Point lookup | Indexed/filtered lookup |
|---|---|---|
| CognoDB | 307.0 / 362.59 | 309.05 / 645.34 |
| Neo4j | 84.18 / 100.58 | 79.48 / 101.52 |
| Memgraph | 4.04 / 35.69 | 3.67 / 26.01 |
| FalkorDB | 1.54 / 5.23 | 1.28 / 2.53 |
| ArangoDB | 3.93 / 9.01 | 4.3 / 9.07 |

### 4.4 Aggregation (p50 / p95 ms)

| Platform | COUNT(*) over KNOWS |
|---|---|
| CognoDB | 1022.89 / 1229.05 |
| Neo4j | 378.77 / 903.41 |
| Memgraph | 115.62 / 210.79 |
| FalkorDB | 299.52 / 391.78 |
| ArangoDB | 5.1 / 10.54 |

### 4.5 Mixed workload (concurrent read/write, QPS)

| Platform | 10 clients |
|---|---|
| CognoDB | 26.3 |
| Neo4j | 18.6 |
| Memgraph | 176.7 |
| FalkorDB | 201.6 |
| ArangoDB | 291.7 |
