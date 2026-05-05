# Snyk Remediation Notes

The Snyk Open Source scan is intentionally report-only for this project. The
default broad scan uses `--all-projects`, which includes Android Gradle build
and instrumentation tooling in addition to app dependencies.

## Current Finding Profile

The high and critical findings seen in CI are mostly introduced through Android
Gradle, Android Test Platform, or UTP dependency paths. Examples include:

- `io.netty:*` through Android/Google test platform tooling
- `com.google.protobuf:protobuf-java` through Android driver instrumentation
- `org.bouncycastle:*` through Gradle or Android plugin dependency graphs

These libraries can be serious when they are packaged in a shipped runtime. In
the current scan output, they are primarily build/test tooling dependencies, so
they are tracked as report-only findings.

## Practical Policy

- Keep the broad Snyk scan report-only so tooling-only findings do not block CI.
- Run a second Android release-runtime scan against `prodReleaseRuntimeClasspath`
  so shipped Android runtime dependency risk is visible separately.
- Prefer normal Flutter, Android Gradle Plugin, Gradle, and plugin upgrades over
  forcing transitive dependency versions manually.
- Revisit remaining tooling-only findings during the next dedicated Flutter or
  Android tooling upgrade.
