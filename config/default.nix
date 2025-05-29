{
	config,
	hostPlatform,
	pkgs,
	...
}: {
	imports = [
		./sops-stuff.nix
	];

	config = {
		boot.loader = {
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};

		networking.hostName = "sops-nix-plugin-poc";

		nixpkgs.hostPlatform = hostPlatform;

		security = {
			sudo.wheelNeedsPassword = false;
		};

		services.getty.autologinUser = "nixos";

		system = {
			stateVersion = "25.05";
		};

		users = {
			users = {
				nixos = {
					isNormalUser = true;
					extraGroups = [
						"wheel"
					];
					initialHashedPassword = "";
				};

				root = {
					initialHashedPassword = "";
				};
			};
		};
	};
}
