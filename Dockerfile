# Build Stage
FROM ubuntu:20.04 as builder

## Install build dependencies.
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y llvm-12-dev libclang-common-12-dev cmake clang curl
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN ${HOME}/.cargo/bin/rustup default nightly
RUN ${HOME}/.cargo/bin/cargo install -f cargo-fuzz

## Add source code to the build stage.
ADD . /src
WORKDIR /src
RUN apt install -y zlib1g-dev
RUN cd fuzz && ${HOME}/.cargo/bin/cargo +nightly fuzz build --all-features

# Package Stage
FROM ubuntu:20.04

COPY --from=builder /src/target/x86_64-unknown-linux-gnu/release/deterministic /
COPY --from=builder /src/target/x86_64-unknown-linux-gnu/release/equivalence_universal /
COPY --from=builder /src/target/x86_64-unknown-linux-gnu/release/universal_cranelift /
COPY --from=builder /src/target/x86_64-unknown-linux-gnu/release/universal_singlepass /
COPY --from=builder /src/target/x86_64-unknown-linux-gnu/release/dylib_cranelift /
COPY --from=builder /src/target/x86_64-unknown-linux-gnu/release/metering /
COPY --from=builder /src/target/x86_64-unknown-linux-gnu/release/universal_llvm /
