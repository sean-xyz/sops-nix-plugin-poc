{
	pkgs,
	rootPath,
	...
}: {
	config = {
		environment = {
			systemPackages = with pkgs; [
				age
				age-plugin-tpm
				sops
				swtpm # tpm emulator
				tpm2-tools
				tpm2-tss
			];

			etc = {
				"sops/age/keys.txt" = {
					source = ./keys.txt;
					mode = "0400";
				};

				"flake-secrets".source = rootPath + /secrets;
			};

			variables = {
				AGE_TPM_SWTPM = "1";
			};
		};

		security = {
			tpm2 = {
				enable = true;
			};
		};

		sops = {
			age = {
				keyFile = "/etc/sops/age/keys.txt";
				plugins = [
					pkgs.age-plugin-tpm
				];
			};

			defaultSopsFile = rootPath + /secrets/secrets.yaml;

			secrets = {
				"hello" = {};

				"passphrases/sean" = {
					neededForUsers = true;
				};
			};
		};

		users = {
			motd = ''
				# test sops-nix tpm decryption
				sudo cat /run/secrets/hello

				# test sops-nix tpm decryption neededForUsers
				# should decrypt to $y$jDT$u/W9mnAZu1FpTrZDsgI54/$Itt9/oMk6s.BfaRVn2wrz.YkrfbbURBvr43RY4Lmr0C,
				# which is a yescrypt hash of "sean"
				sudo cat /run/secrets-for-users/passphrases/sean
				su sean # enter password: sean

				# optional - some things you can do to troubleshoot
					# create a new tpm key
					age-plugin-tpm --generate -o age-identity.txt
					age-plugin-tpm -y age-identity.txt > age-recipient.txt

					# test (sw)tpm decryption with age
					echo 'decrypt this with age and the tpm. this does not use sops-nix' | age -R age-recipient.txt -o test-decrypt.txt
					age --decrypt -i age-identity.txt -o - test-decrypt.txt

					# test (sw)tpm decryption with sops
					sudo SOPS_AGE_KEY_FILE=/etc/sops/age/keys.txt sops decrypt /etc/flake-secrets/secrets.yaml

				# turn off the virtual machine
				sudo poweroff
			'';
			users = {
				nixos = {
					extraGroups = [
						"tss"
					];
				};
			};
		};

		virtualisation.tpm.enable = true;
	};
}
