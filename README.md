# Codespaces Images

![License](https://img.shields.io/badge/license-MIT-green.svg)

- `make all` will build the following docker images for use in Codespaces
  - ghcr.io/cse-labs/jumpbox:beta
  - ghcr.io/cse-labs/dind:beta
  - ghcr.io/cse-labs/k3d:beta
  - ghcr.io/cse-labs/k3d-rust:beta
  - ghcr.io/cse-labs/k3d-wasm:beta

> CI-CD builds and publishes `:latest` automatically and weekly

## jumpbox

- Jumpbox image based on Alpine

## dind

- Docker-in-Docker image

## k3d

- k3d image based on dind
  - k3d is a lightweight wrapper to run k3s (Rancher Lab’s minimal Kubernetes distribution) in Docker

## k3d-rust

- Rust image based on k3d

## k3d-wasm

- WebAssembly image based on k3d-rust
