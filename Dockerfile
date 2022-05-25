# Build Stage
FROM rustlang/rust:nightly as builder

## Install build dependencies.
RUN cargo install -f cargo-fuzz

## Add source code to the build stage.
ADD . /src
WORKDIR /src
RUN cd fuzz && cargo +nightly fuzz build

# Package Stage
FROM rustlang/rust:nightly

COPY --from=builder /src/fuzz/target/x86_64-unknown-linux-gnu/release/deterministic /
COPY --from=builder /src/fuzz/target/x86_64-unknown-linux-gnu/release/equivalence_universal /
COPY --from=builder /src/fuzz/target/x86_64-unknown-linux-gnu/release/universal_cranelift /
COPY --from=builder /src/fuzz/target/x86_64-unknown-linux-gnu/release/universal_singlepass /
COPY --from=builder /src/fuzz/target/x86_64-unknown-linux-gnu/release/dylib_cranelift /
COPY --from=builder /src/fuzz/target/x86_64-unknown-linux-gnu/release/metering /
COPY --from=builder /src/fuzz/target/x86_64-unknown-linux-gnu/release/universal_llvm /
