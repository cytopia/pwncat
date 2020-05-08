"""Greet Bot."""

PSE_BOT_QUESTIONS = [
    "How is the weather?",
    "How old are you?",
    "What do you do today?",
    "Do you like Python?",
    "Have you had dinner?",
    "Can you guess my name?",
    "Are you bored?",
    "Why are you chatting to a bot?",
    "Do you expect me to answer properly?",
]


def transform(data, pse):
    """Transform."""
    global PSE_BOT_QUESTIONS

    # Setup custom data structure
    if pse.store is None:
        pse.store = {}
    if "bot" not in pse.store:
        pse.store["bot"] = {}

    from random import randrange

    if "greet" not in pse.store["bot"]:
        if any(x in data for x in ["hi", "helo", "halo", "hallo", "hello"]):
            pse.store["bot"]["greet"] = True
            return "Nice to meet you, what is your name?\n"
        return "Be polite and greet first.\n"

    if "name" not in pse.store["bot"]:
        pse.store["bot"]["name"] = data.rstrip()
        return "OK, I call you: {}".format(data)

    index = randrange(0, len(PSE_BOT_QUESTIONS)-1)
    return "Hi {}, {}\n".format(pse.store["bot"]["name"], PSE_BOT_QUESTIONS[index])
