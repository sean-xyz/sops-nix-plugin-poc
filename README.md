# sops-nix with age-plugin-tpm

This is a proof of concept on how to use the TPM to decrypt secrets at startup with sops-nix.

It uses sops-nix [pull request 781](https://github.com/Mic92/sops-nix/pull/781)

## environment setup

1. have flakes enabled
2. run `nix develop`, or if you have direnv `direnv allow`

## test TPM decryption

1. run `just run`
2. run the instructions that appear in the linux MOTD upon boot, e.g.
	```
	# test sops-nix tpm decryption
	sudo cat /run/secrets/hello

	# test sops-nix tpm decryption neededForUsers
	sudo cat /run/secrets-for-users/passphrases/sean
	```

This runs a virtual machine with a virtual TPM. The TPM state is persisted in ./tpm-state so that the age key generated from it works.

## test TPM decryption without the TPM

Decryption should fail if the TPM that sealed the secret isn't available. One way to test this is by trying to decrypt it on your machine, rather than the virtual machine:

```
SOPS_AGE_KEY=$(cat ./config/keys.txt | grep AGE-PLUGIN-TPM) sops decrypt ./secrets/secrets.yaml
```

and it hangs. I haven't looked into why it doesn't immediately fail, other than finding that it happens with sops (i.e., independent of sops-nix).

You can also try it in a virtual machine by deleting `./tpm-state/`, or by giving it a different TPM. This also hangs during decryption:

```
just run-with-different-tpm-dir ./blah
```
