"""PSE module to shift the ASCII number by 14."""


def transform(data):
    """The transformer function."""
    __PSE_ASYM_ENC_CLIENT_SEND_SHIFT = 14

    output = []
    for c in data:
        num = ord(c) + __PSE_ASYM_ENC_CLIENT_SEND_SHIFT
        while num > 127:
            num -= 127
        output.append(chr(num))
    return "".join(output)
