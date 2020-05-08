# PSE: HTTP POST

The two scripts show-case how to pack and unpack data into HTTP POST requests.


## Usage

Use high verbosity to see how the data gets transformed.

### Server
```bash
pwncat -vvvv -l localhost 4444 \
  --script-send pse/http-post/pse-http_post-pack.py \
  --script-recv pse/http-post/pse-http_post-unpack.py
```

### Client
```bash
pwncat -vvvv localhost 4444 \
  --script-send pse/http-post/pse-http_post-pack.py \
  --script-recv pse/http-post/pse-http_post-unpack.py
```
