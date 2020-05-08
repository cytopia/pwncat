"""PSE module to shift the ASCII number by -13."""


def transform(data, pse):
    """The transformer function."""
    __PSE_ASYM_ENC_SERVER_SEND_SHIFT = 13

    output = []
    for c in data:
        num = ord(c) - __PSE_ASYM_ENC_SERVER_SEND_SHIFT
        while num < 0:
            num += 127
        output.append(chr(num))
    return "".join(output)
