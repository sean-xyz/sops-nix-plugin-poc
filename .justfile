defaultVirtualArch := arch()
defaultVirtualOs := if os() == "macos" {"darwin"} else {os()}
defaultTpmDir := "./tpm-state"

@_default:
	just --list

reset-state:
	-rm poc.qcow2

build arch=defaultVirtualArch os=defaultVirtualOs:
	nixos-rebuild build-vm --flake .#{{arch}}-{{os}}

run arch=defaultVirtualArch os=defaultVirtualOs tpmDir=defaultTpmDir: reset-state (build arch os)
	#!/usr/bin/env bash
	set -euox pipefail
	export NIX_SWTPM_DIR="./{{tpmDir}}"
	mkdir -p ${NIX_SWTPM_DIR}
	QEMU_KERNEL_PARAMS=console=ttyS0 ./result/bin/run-poc-vm -nographic

run-with-different-tpm-dir tpmDir arch=defaultVirtualArch os=defaultVirtualOs: (run arch os tpmDir)

kill:
	sudo pkill qemu
