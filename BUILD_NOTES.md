# Build notes

I don't have a JDK compiler or Maven in the sandbox I wrote this in (only a
bare JRE, no internet), so unlike the Python version, none of this Java code
has actually been compiled or run. It's written carefully against the
libraries' documented APIs, but please run `mvn clean package` early and
expect to fix a few small things. Likely spots, in rough order of risk:

1. **`LoadFalkorDB.java` — Jedis raw command path.** `ProtocolCommand` and
   `SafeEncoder` moved packages once across Jedis 3.x → 4.x/5.x. If the
   import `redis.clients.jedis.commands.ProtocolCommand` doesn't resolve,
   check `redis.clients.jedis.util.SafeEncoder` and the `Jedis.sendCommand`
   overload available in whatever Jedis version Maven actually pulls down
   — this is the single piece I'd verify first against a live FalkorDB
   container before trusting any FalkorDB numbers.

2. **`LoadArangoDB.java` / `RunBenchmark.java` — ArangoDB Java driver
   method signatures.** `ArangoDB.Builder().host(...)`,
   `ArangoCollection.ensurePersistentIndex(...)`,
   `CollectionCreateOptions().type(CollectionType.EDGES)`, and
   `ArangoDatabase.query(query, Class, bindVars, AqlQueryOptions)` are all
   written from the 7.x driver's documented shape, but the driver has
   changed signatures across major versions before. If `mvn package` flags
   a mismatch, the ArangoDB Java driver's own README/javadoc for whatever
   version resolves is the fastest fix.

3. **`Queries.java` text blocks** use Java 17's `"""` syntax — the
   `pom.xml` targets `<maven.compiler.source>17</maven.compiler.source>`,
   so make sure your local JDK is 17+ (`java -version` — the sandbox here
   reports 21, so that's a reasonable assumption for your machine too, but
   worth checking).

4. **`org.json` API** — `optJSONObject(key, default)` needs a fairly recent
   `org.json:json` release; the pom pins `20240303` which has it.

None of this changes the methodology, the metrics, or what goes in the
README — it's purely "does this specific Java syntax match the library
version Maven resolves." Budget 30–60 minutes for a compile-fix loop before
you start trusting real timing numbers out of it.
