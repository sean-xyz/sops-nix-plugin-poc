{
	config,
	hostPlatform,
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

		networking.hostName = "poc";

		nixpkgs.hostPlatform = hostPlatform;

		security = {
			sudo.wheelNeedsPassword = false;
		};

		services = {
			getty.autologinUser = "nixos";
			userborn.enable = true;
		};

		system = {
			stateVersion = "25.11";
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

				sean = {
					isNormalUser = true;
					extraGroups = [
						"wheel"
					];
					hashedPasswordFile = config.sops.secrets."passphrases/sean".path;
				};
			};
		};
	};
}
