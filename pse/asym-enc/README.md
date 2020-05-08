# PSE: Asymmetric encryption

The four scripts show-case a very basic asymmetric encryption example.


## Usage

Use high verbosity to see how the data gets transformed.

### Server
```bash
pwncat -vvvv -l localhost 4444 \
  --script-send pse/asym-enc/pse-asym_enc-server_send.py \
  --script-recv pse/asym-enc/pse-asym_enc-server_recv.py
```

### Client
```bash
pwncat -vvvv localhost 4444 \
  --script-send pse/asym-enc/pse-asym_enc-client_send.py \
  --script-recv pse/asym-enc/pse-asym_enc-client_recv.py
```
