# Sigint (<kbd>Ctrl</kbd>+<kbd>c</kbd>)

This tests the correct shutdown behaviour, simulating a user hitting <kbd>Ctrl</kbd>+<kbd>c</kbd>.


**Note:** Currently the only way I was able to emulate <kbd>Ctrl</kbd>+<kbd>c</kbd> via `kill -2` for background processes was to run Docker and send the kill signal. When using `bash` on my host system and start it up via `pwncat ...&`, it is send into the background, but the job control catches `SIGINT` (`kill -2`) signals and doesn't let it through to the background process. So yeah, Docker it will be :-)


## Goal

As `pwncat` makes heavy use of a lot of non-daemon threads, proper shutdown can sometimes be problematic.
Some threads might end up in a blocking state and then the whole program can only be forcibly terminated with hitting <kbd>Ctrl</kbd>+<kbd>c</kbd> twice. This however is not desired as `pwncat` should always close properly.

As I've fixed every shutdown bug already too many times and implemented it again, this CI smoke test will ensure I don't accidentally add new bugs to the shutdown behaviour and will also be able to discover any remaining bugs present.


## IMPORTANT

Use the `Makefile` in the root directory to run the tests:
```bash
make smoke
```


## Checklist

What is implemented?


### (1/4) TCP Checks

Fresh start server and client for each checkbox below:
```
pwncat -vvvv -l 4444
pwncat -vvvv localhost 4444
```

1. [ ] (TCP) Ctrl+c on server (before sending any data)
2. [ ] (TCP) Ctrl+c on server (after sending data from server to client)
3. [ ] (TCP) Ctrl+c on server (after sending data from client to server)
4. [ ] (TCP) Ctrl+c on client (before sending any data)
5. [ ] (TCP) Ctrl+c on client (after sending data from server to client)
6. [ ] (TCP) Ctrl+c on client (after sending data from client to server)


### (2/4) UDP Checks

Fresh start server and client for each checkbox below:
```
pwncat -u -vvvv -l 4444
pwncat -u -vvvv localhost 4444
```

1. [ ] (UDP) Ctrl+c on server (before sending any data)
2. [ ] (UDP) Ctrl+c on server (after sending data from server to client)
3. [ ] (UDP) Ctrl+c on server (after sending data from client to server)
4. [ ] (UDP) Ctrl+c on client (before sending any data)
5. [ ] (UDP) Ctrl+c on client (after sending data from server to client)
6. [ ] (UDP) Ctrl+c on client (after sending data from client to server)


### (3/4) --keep-open checks

Fresh start server and client for each checkbox below:
```
pwncat -vvvv -l 4444 --keep-open
pwncat -vvvv localhost 4444
```

1. [X] (TCP) Ctrl+c on server (before sending any data)
2. [X] (TCP) Ctrl+c on server (after sending data from server to client)
3. [ ] (TCP) Ctrl+c on server (after sending data from client to server)
4. [ ] (TCP) Ctrl+c on client (before sending any data)
5. [ ] (TCP) Ctrl+c on client (after sending data from server to client)
6. [ ] (TCP) Ctrl+c on client (after sending data from client to server)

### (4/4) --reconn checks

Fresh start server and client for each checkbox below:
```
pwncat -vvvv -l 4444
pwncat -vvvv localhost 4444 --reconn
```

1. [ ] (TCP) Ctrl+c on server (before sending any data)
2. [ ] (TCP) Ctrl+c on server (after sending data from server to client)
3. [ ] (TCP) Ctrl+c on server (after sending data from client to server)
4. [ ] (TCP) Ctrl+c on client (before sending any data)
5. [ ] (TCP) Ctrl+c on client (after sending data from server to client)
6. [ ] (TCP) Ctrl+c on client (after sending data from client to server)
