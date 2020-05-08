# PSE: Chat bot

A simple script that makes the remote peer site behave like a bot replying to your questions.

## Usage

Use high verbosity to see how the data gets transformed.

### Server

**Note:** The server side is using `/bin/cat` as its command in order to echo the messages back to the client. Then we hook into the sending part and simply overwrite the replies based on the received input.
```bash
pwncat -vvvv -l localhost 4444 \
  --exec /bin/cat \
  --script-send pse/chat-bot/pse-chat_bot.py
```

### Client
```bash
pwncat localhost 4444
```

### In action

The following shows it in action. `>` represents sending data to the server and `<` are the replies.
```
> some data
< Be polite and greet first.
> hi
< Nice to meet you, what is your name?
> cytopia
< OK, I call you: cytopia
> that's right
< Hi cytopia, How is the weather?
> it's pretty good
< Hi cytopia, Why are you chatting to a bot?
> I don't know
< Hi cytopia, Are you bored?
> Maybe
< Hi cytopia, Have you had dinner?
```
