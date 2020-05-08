"""PSE module pack data into a HTTP POST request."""


def transform(data):
    """The transformer function."""
    param = "payload"
    body = param + "=" + data
    headers = []
    headers.append("POST / HTTP/1.1")
    headers.append("Host: localhost")
    headers.append("User-Agent: pwncat")
    headers.append("Accept: */*")
    headers.append("Content-Length: {}".format(len(body)))
    headers.append("Content-Type: application/x-www-form-urlencoded")
    headers.append("")
    headers.append("")
    return "\n".join(headers) + body + "\n\n"
