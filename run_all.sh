#!/usr/bin/env bash
# Runs the full benchmark pipeline end to end.
# Prereqs: JDK 17+, Maven, Docker running, .env filled in with CognoDB creds.
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p results data

echo "== 0. Building the project =="
mvn -q clean package

JAR="target/benchmark.jar"

echo "== 1. Bringing up self-hosted comparison platforms =="
docker compose --compatibility up -d
echo "Waiting 20s for containers to finish initializing..."
sleep 20

echo "== 2. Preparing dataset =="
java -cp "$JAR" com.wexa.benchmark.PrepareDataset --target-edges 150000

echo "== 3. Loading data into every platform =="
java -cp "$JAR" com.wexa.benchmark.LoadCypher --target cognodb  | tee results/load_cognodb.log
java -cp "$JAR" com.wexa.benchmark.LoadCypher --target neo4j    | tee results/load_neo4j.log
java -cp "$JAR" com.wexa.benchmark.LoadCypher --target memgraph | tee results/load_memgraph.log
java -cp "$JAR" com.wexa.benchmark.LoadFalkorDB                 | tee results/load_falkordb.log
java -cp "$JAR" com.wexa.benchmark.LoadArangoDB                 | tee results/load_arangodb.log

echo "== 4. Running read + mixed(concurrency=10) workloads =="
for target in cognodb neo4j memgraph falkordb arangodb; do
  java -cp "$JAR" com.wexa.benchmark.RunBenchmark --target "$target" --concurrency 10
done

echo "== 5. Concurrency sweep (1 / 40 clients), reusing read numbers =="
for target in cognodb neo4j memgraph falkordb arangodb; do
  java -cp "$JAR" com.wexa.benchmark.RunBenchmark --target "$target" --concurrency 1  --skip-reads
  java -cp "$JAR" com.wexa.benchmark.RunBenchmark --target "$target" --concurrency 40 --skip-reads
done

echo "== 6. Generating report =="
java -cp "$JAR" com.wexa.benchmark.GenerateReport

echo
echo "Done. Results:"
echo "  results/*.json      raw per-platform data"
echo "  results/RESULTS.md  auto-generated markdown tables -> paste into README section 4"
echo "  results/load_*.log  ingest throughput -> fill README section 4.1 by hand"
