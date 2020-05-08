"""PSE module unpack data from a HTTP POST request."""


def transform(data, pse):
    """The transformer function."""
    param = "payload"
    pos = data.find(param + "=")
    pos += len(param + "=")

    body = data[pos:]
    if body.endswith("\r\n"):
        body = body.rstrip("\r\n")
    elif body.endswith("\n"):
        body = body.rstrip("\n")
    elif body.endswith("\r"):
        body = body.rstrip("\r")
    return body + "\n"
