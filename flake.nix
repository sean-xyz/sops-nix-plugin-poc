{
	description = "test sops-nix with age plugin";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

		sops-nix = {
			# this is from pull request https://github.com/Mic92/sops-nix/pull/781
			url = "github:NovaViper/sops-nix/187cf1369866584cb33ee712de10e4a00c14e91a";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = {
		self,
		nixpkgs,
		sops-nix,
		...
	}: let
		systems = [
			"x86_64-linux"
			"x86_64-darwin"
			"aarch64-darwin"
			"aarch64-linux"
		];

		pkgsFor =
			nixpkgs.lib.genAttrs systems (
				system:
					import nixpkgs {
						inherit system;
					}
			);
	in {
		nixosConfigurations =
			builtins.listToAttrs (
				map (host: {
						name = host;
						value =
							nixpkgs.lib.nixosSystem {
								specialArgs = {
									hostPlatform = host;
								};

								modules = [
									sops-nix.nixosModules.sops
									"${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
									./config
								];
							};
					})
				systems
			);

		devShell =
			nixpkgs.lib.genAttrs systems (
				system:
					pkgsFor.${system}.mkShell {
						NIX_CONFIG = "extra-experimental-features = nix-command flakes";
						# here for convenience to decrypt ./secrets/secrets.yaml without tpm
						# this key's not available in the virtual machine, only the dev shell
						SOPS_AGE_KEY = "AGE-SECRET-KEY-1G7LCH3GKX7ZYNVQG23YX2GWADR7UQ250WSNLKWTVKHGSX5JFVF6QXRR28S";

						nativeBuildInputs =
							builtins.attrValues {
								inherit
									(pkgsFor.${system})
									age
									git
									just
									sops
									;
							};
					}
			);
	};
}
