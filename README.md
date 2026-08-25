# CognoDB Cloud Graph Database Benchmark (Java)

A reproducible benchmark comparing **CognoDB Cloud** against four other graph
databases on identical data, identical queries, and matched resource limits.
Implemented in Java 17 / Maven.

> **Status:** scaffold + harness complete. Numbers below are placeholders —
> run the steps in "Reproduce" to fill them in with real measurements before
> submitting.

## 1. Platforms compared

| Platform | Deployment | Query language | Specs |
|---|---|---|---|
| CognoDB Cloud | Managed free tier (c0) | Cypher (Bolt) | 0.5 vCPU / 256 MB RAM / 1 GB disk |
| Neo4j Community 5 | Self-hosted, Docker-capped | Cypher (Bolt) | 0.5 vCPU / 256 MB RAM |
| Memgraph Community | Self-hosted, Docker-capped | Cypher (Bolt) | 0.5 vCPU / 256 MB RAM |
| FalkorDB | Self-hosted, Docker-capped | Cypher (Redis protocol) | 0.5 vCPU / 256 MB RAM |
| ArangoDB Community | Self-hosted, Docker-capped | AQL | 0.5 vCPU / 256 MB RAM |

**Why self-hosted instead of 4 more cloud signups:** the assignment allows
"self-hosted deployments capped to the same resources." Docker resource
limits let every comparison platform match CognoDB's advertised free-tier
spec exactly, on the same physical client machine, removing cross-provider
network/region variance as a confound. CognoDB itself is still tested as a
genuine managed cloud call.

**Why these four:** Neo4j is the closest apples-to-apples comparison to
CognoDB (same Bolt/Cypher protocol). Memgraph and FalkorDB are also
Cypher-compatible but use very different execution engines (in-memory
process vs. Redis-module sparse-matrix). ArangoDB is deliberately AQL-based,
covering a genuine query-language difference — flagged as a caveat per
section 5.3.

## 2. Dataset

- **Source:** [SNAP soc-Pokec](https://snap.stanford.edu/data/soc-Pokec.html), directed friendship edges.
- **Sampling:** induced subgraph on the highest-degree nodes, trimmed to
  ~150,000 edges, IDs relabelled to a dense integer range
  (`PrepareDataset.java`).
- **Final size:** `<FILL IN from data/dataset_stats.txt>`.
- **Load method:** batched `UNWIND ... MERGE` transactions of 1,000 rows for
  every Cypher-speaking platform (`LoadCypher.java`, `LoadFalkorDB.java`);
  `insertDocuments` batches of 1,000 for ArangoDB (`LoadArangoDB.java`).

## 3. Methodology

- **Resource parity:** every self-hosted platform capped to 0.5 vCPU /
  256 MB RAM via Docker (`docker-compose.yml`); CognoDB's free tier matches
  by provider default.
- **Warm-up:** first 20 iterations of every read workload are discarded;
  100 measured iterations follow (`ITERATIONS=120, WARMUP=20` in
  `RunBenchmark.java`).
- **Same queries everywhere:** every logical query is defined once, in
  Cypher and AQL, in `Queries.java`.
- **Client:** all runs executed from the same machine and process (except
  the mixed workload, which explicitly varies concurrency via a
  `ThreadPoolExecutor`-equivalent `ExecutorService`).
- **Randomized start nodes:** each iteration picks a random node ID rather
  than reusing one hot node.

### Known caveats (recorded honestly, not hidden)
- FalkorDB is queried via Jedis's raw `sendCommand`, not a first-class
  FalkorDB client — parameters are inlined via FalkorDB's `CYPHER key=val`
  prefix syntax rather than true bound parameters, since the raw Redis path
  doesn't support parameter binding the way the Bolt driver does.
- ArangoDB's AQL traversal semantics differ subtly from Cypher pattern
  matching (edge direction / distinct-handling defaults); queries were
  matched as closely as the language allows, not byte-identical.
- CognoDB free-tier network latency includes real internet RTT to the
  provider's region; the self-hosted platforms do not.
- `<Add any additional caveats you hit while actually running this.>`

## 4. Results

> Fill in after running the pipeline for every target — or just run
> `./run_all.sh`, which does this automatically and writes
> `results/RESULTS.md` with these tables pre-filled.

### 4.1 Data loading

| Platform | Nodes/s | Rels/s | Total wall-clock |
|---|---|---|---|
| CognoDB | | | |
| Neo4j | | | |
| Memgraph | | | |
| FalkorDB | | | |
| ArangoDB | | | |

*(see `results/RESULTS.md` for sections 4.2–4.5, auto-generated)*

### 4.6 Footprint

| Platform | Stored data size | Memory usage | Notes |
|---|---|---|---|
| CognoDB | not observable via free tier | not observable | provider doesn't expose this on c0 |
| Neo4j | `du -sh` on Docker volume | `docker stats` | |
| Memgraph | | | |
| FalkorDB | | | |
| ArangoDB | | | |

## 5. Analysis

`<Write 3–5 paragraphs here once you have real numbers.>`

## 6. Reproduce this benchmark

Prerequisites: **JDK 17+**, **Maven**, **Docker**.

```bash
git clone <this repo>
cd cognodb-benchmark-java

# 1. Sign up for CognoDB Cloud free tier: https://console.cognodb.com/signup
#    Create a c0 instance, copy the bolt+s:// URI and password.
cp .env.example .env
# edit .env: fill in COGNODB_URI / COGNODB_PASSWORD

# 2. Run everything
chmod +x run_all.sh
./run_all.sh
```

Or step by step:

```bash
mvn clean package
docker compose --compatibility up -d

java -cp target/benchmark.jar com.wexa.benchmark.PrepareDataset --target-edges 150000

java -cp target/benchmark.jar com.wexa.benchmark.LoadCypher --target cognodb
java -cp target/benchmark.jar com.wexa.benchmark.LoadCypher --target neo4j
java -cp target/benchmark.jar com.wexa.benchmark.LoadCypher --target memgraph
java -cp target/benchmark.jar com.wexa.benchmark.LoadFalkorDB
java -cp target/benchmark.jar com.wexa.benchmark.LoadArangoDB

java -cp target/benchmark.jar com.wexa.benchmark.RunBenchmark --target cognodb
java -cp target/benchmark.jar com.wexa.benchmark.RunBenchmark --target neo4j
java -cp target/benchmark.jar com.wexa.benchmark.RunBenchmark --target memgraph
java -cp target/benchmark.jar com.wexa.benchmark.RunBenchmark --target falkordb
java -cp target/benchmark.jar com.wexa.benchmark.RunBenchmark --target arangodb

java -cp target/benchmark.jar com.wexa.benchmark.GenerateReport
```

## 7. Repo layout

```
pom.xml
docker-compose.yml
.env.example
run_all.sh
src/main/java/com/wexa/benchmark/
  Env.java             # .env loader
  Queries.java          # single source of truth for every query, both dialects
  PrepareDataset.java   # SNAP soc-Pokec download + sampling
  LoadCypher.java        # CognoDB, Neo4j, Memgraph (shared Bolt/Cypher path)
  LoadFalkorDB.java
  LoadArangoDB.java
  RunBenchmark.java      # reads + mixed workload, writes results/<target>.json
  GenerateReport.java    # results/*.json -> results/RESULTS.md
results/                 # JSON + generated report (created at runtime)
```

## 8. Security note

No credentials are committed to this repo. All connection details are read
from environment variables via `.env` (gitignored) — see `.env.example`.
