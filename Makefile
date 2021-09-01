.PHONY: help all scripts dind k3d k3d-rust k3d-wasm jumpbox

help :
	@echo "Usage:"
	@echo "   make all        - build images images"
	@echo "   make dind       - build Docker-in-Docker image (dind)"
	@echo "   make jumpbox    - build jumpbox k8s image"
	@echo "   make k3d        - build k3d image"
	@echo "   make k3d-rust   - build k3d Rust image"
	@echo "   make k3d-wasm   - build k3d WebAssembly image"
	@echo "   make scripts    - update scripts from vscode repo"

all : jumpbox k3d-rust k3d-wasm k3d dind

scripts :
	@docker pull mcr.microsoft.com/vscode/devcontainers/dotnet
	@docker pull alpine

	# Download scripts from vscode-dev-containers repo
	@curl -o library-scripts/common-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-debian.sh
	@curl -o library-scripts/docker-in-docker-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/docker-in-docker-debian.sh
	@curl -o library-scripts/kubectl-helm-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/kubectl-helm-debian.sh
	@curl -o library-scripts/azcli-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/azcli-debian.sh
	@curl -o library-scripts/git-lfs-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/git-lfs-debian.sh
	@curl -o library-scripts/github-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/github-debian.sh
	@curl -o library-scripts/go-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/go-debian.sh
	@curl -o library-scripts/gradle-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/gradle-debian.sh
	@curl -o library-scripts/java-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/java-debian.sh
	@curl -o library-scripts/maven-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/maven-debian.sh
	@curl -o library-scripts/node-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/node-debian.sh
	@curl -o library-scripts/powershell-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/powershell-debian.sh
	@curl -o library-scripts/python-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/python-debian.sh
	@curl -o library-scripts/ruby-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/ruby-debian.sh
	@curl -o library-scripts/rust-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/rust-debian.sh
	@curl -o library-scripts/sshd-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/sshd-debian.sh
	@curl -o library-scripts/terraform-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/terraform-debian.sh
	@curl -o library-scripts/dapr-debian.sh -fsSL https://raw.githubusercontent.com/dapr/cli/master/install/install.sh

dind : scripts
	@docker build . --target dind -t ghcr.io/cse-labs/dind:beta

k3d : scripts
	@docker build . --target k3d -t ghcr.io/cse-labs/k3d:beta

k3d-rust : scripts
	@docker build . --target k3d-rust -t ghcr.io/cse-labs/k3d-rust:beta

k3d-wasm : scripts
	@docker build . --target k3d-wasm -t ghcr.io/cse-labs/k3d-wasm:beta

jumpbox :
	@docker build . --target jumpbox -t ghcr.io/cse-labs/jumpbox:latest
