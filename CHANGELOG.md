# Changelog


## Unreleased


## Release 0.0.4-alpha

#### Added
- Feature: UDP connect mode interval ping (`--udp-ping-intvl`) for unbreakable UDP reverse shells


## Release 0.0.3-alpha

#### Fixed
- Hardened Python 2/3 string compatibility
- Checking against mutually exclusive arguments
- Fix crash while checking for Mac newlines `\r`

#### Added
- Editorconfig
- Feature: Re-connect/Re-listen on connection abort (`--reconn`)
- Feature: Re-connect/Re-listen on connection abort (`--reconn-wait`)


## Release 0.0.2-alpha

#### Added
- Feature: Execute shell commands (`-e/--exec`)
- Feature: Skip DNS resolution (`-n/--nodns`)
- Documentation: API docs

#### Changed
- Renamed project from netcat to pwncat


## Release 0.0.1-alpha

#### Added
- Feature: Listen
- Feature: Connect
- Feature: UDP mode
- Feature: Change linefeeds (LF vs CRLF)
- Feature: Verbosity
