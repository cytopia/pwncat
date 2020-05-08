"""PSE module to shift the ASCII number by -14."""


def transform(data, pse):
    """The transformer function."""
    __PSE_ASYM_ENC_SERVER_RECV_SHIFT = 14

    output = []
    for c in data:
        num = ord(c) - __PSE_ASYM_ENC_SERVER_RECV_SHIFT
        while num < 0:
            num += 127
        output.append(chr(num))
    return "".join(output)
