"""Pip configuration."""
from setuptools import setup

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(
    name="pwncat",
    version="0.0.20-alpha",
    description="Netcat on steroids with Firewall, IDS/IPS evasion, bind and reverse shell and port forwarding magic - and its  fully scriptable with Python (PSE).",
    license="MIT",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="cytopia",
    author_email="cytopia@everythingcli.org",
    url="https://github.com/cytopia/pwncat",
    install_requires=[],
    scripts=[
        "bin/pwncat"
    ],
    classifiers=[
        # https://pypi.org/classifiers/
        #
        # How mature is this project
        "Development Status :: 3 - Alpha",
        # Indicate who your project is intended for
        "Intended Audience :: Developers",
        "Intended Audience :: Information Technology",
        "Intended Audience :: Science/Research",
        "Intended Audience :: System Administrators",
        # Project topics
        "Topic :: Communications :: Chat",
        "Topic :: Communications :: File Sharing",
        "Topic :: Internet",
        "Topic :: Security",
        "Topic :: System :: Shells",
        "Topic :: System :: Systems Administration",
        "Topic :: Utilities",
        # License
        "License :: OSI Approved :: MIT License",
        # Specify the Python versions you support here. In particular, ensure
        # that you indicate whether you support Python 2, Python 3 or both.
        "Programming Language :: Python",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 3",
        # How does it run
        "Environment :: Console",
        # Where does it rnu
        "Operating System :: OS Independent",
    ],
)
