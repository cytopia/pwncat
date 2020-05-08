# Pwncat Scripting Engine (PSE)

The Pwncat Scripting Engine is a flexible way to apply your own transformations to incoming and
outgoing traffic (or generally speaking to all sorts of I/O).



## Available PSE's

This directory contains a few example scripts, which can be used with pwncat's scripting engine.
These scripts currently only serve as a way to give you an idea about how this can be used.

<table>
 <thead>
  <tr>
   <th width="100">PSE</th>
   <th>Description</th>
   <th width="95">Python 2</th>
   <th width="95">Python 3</th>
  </tr>
 </thead>
 <tbody>
  <tr>
   <td><a href="asym-enc">asym-enc</a></td>
   <td>Basic <i>dummy</i> asymmetric encryption for server/client communication.</td>
   <td>✔</td>
   <td>✔</td>
  </tr>
  <tr>
   <td><a href="http-post">http-post</a></td>
   <td>Basic <i>dummy</i> HTTP POST packer and unpacker (hide your traffic in HTTP POST requests).</td>
   <td>✔</td>
   <td>✔</td>
  </tr>
 </tbody>
</table>


## Usage

The two command line arguments available are:

1. `--script-send`: which will apply the specified file prior sending data
2. `--script-recv`: which will apply the specified file after receiving data

As an example to have the server apply some sort of transformation upon receive, you would start it like so:
```bash
pwncat -l 4444 --script-recv /path/to/script.py
```


## API


General API documentation is available here: https://cytopia.github.io/pwncat/pwncat.api.html

### Entrypoint

**Requirements:** The entrypoint function name must be `transform`, which takes two arguments (`data` which is a `str` containing the current input or output and `pse` which is a `PSEStore` instance) and return a string as its output.

All you need to do is to create a Python file with the following function:

```python
def transform(data, pse):
    # type: (str, PSEStore) -> str

    # ... here goes all the logic
    return data
```

### data

This is simply a string variable with the current input or output (depending on if the script was used by `--script-recv` or `--script-send`).


### pse

This is an instance of `PSEStore` which gives you the possibility to persist data, exchange data between recv and send scripts, access the logger, the raw network and the signal handler.


| Attribute | Type | Description |
|-----------|------|-------------|
| messages  | `Dict[str, List[str]]` | Stores sent and received messages by its thread name. |
| store     | `Any`                  | Use this attribute to store your persistent data. |
| ssig      | `StopSignal`           | StopSignal instance that allows you to call terminate on all threads. |
| net       | `List[IONetwork]`      | List of all used network instances. Can be used to manipulate the active socket. |
| log       | `Logging.logger`       | Logging instance to write your own log messages. |
