# NSCC ASPIRE 2A Quickstart

## One-Time Setup

Run the setup script:

```bash
bash scripts/setup_nscc_aspire2a_ssh.sh
```

When prompted:

1. Enter your NSCC username, for example `e1538xxx`.
2. Paste your private SSH key, including the `BEGIN` and `END` lines.
3. Wait for the script to install the key and SSH config.

After setup, connect from any folder:

```bash
ssh aspire2a
```

Upload files:

```bash
scp train.py aspire2a:~/CoLLM/
rsync -av --exclude .git --exclude __pycache__ ./ aspire2a:~/openonerec/
```

## NUS VPN Check

If outside campus, connect NUS VPN first. Then check:

```bash
route -n get aspire2a.nus.edu.sg
nc -vz -G 5 aspire2a.nus.edu.sg 22
```

Expected signs:

- `route` shows an interface like `utun...` on macOS.
- `nc` says port 22 succeeded.

## Request GPU Node

After logging into ASPIRE 2A:

```bash
qsub -I \
  -P personal-e1538xxx \
  -q normal \
  -l select=1:ngpus=2:ncpus=32:mem=110gb \
  -l walltime=01:00:00
```

Replace `personal-e1538xxx` with your own project/account string if NSCC assigned a different one.

## Common Commands

```bash
source ~/collmenv/bin/activate
cd ~/CoLLM
qstat -u "$USER"
tail -100 stage1_dpo_v2.out
```

## Troubleshooting

- `Could not resolve hostname`: check VPN and DNS.
- `Connection timed out`: check NUS VPN or network path.
- `Permission denied`: key is not registered, wrong username, or account/project access is not active.
- `Connection closed immediately`: account may be disabled, NSCC login may be under maintenance, or the project/group is not authorized.

Never share private keys in chat or email. If a private key is exposed, generate a new key in the NSCC portal and rerun the setup script.
