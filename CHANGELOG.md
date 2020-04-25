# Changelog


## Unreleased


## Release 0.0.7-alpha

#### Fixed
- Fixed `-L`/`--local` mode to now persist multiple requests
- Fixed `-C`/`--crlf` Only replace `\n` with `\r\n` if `\n` exists and don't blindly add.

#### Added
- Integration tests for `L`/`--local` mode

#### Changed
- Plugin architecture has been heavily refactored to make it easier to add new plugins
- Improved logging


## Release 0.0.6-alpha

#### Fixed
- Fixed `-n`/`--nodns` to actually not resolve DNS
- Fixed various threading issues

#### Added
- Check for unimplemented options
- Feature: Made socket receive non-blocking
- Feature: Made stdin non-blocking (except for Windows)
- Documentation: man page
- Documentation: updated readme and contribution guidelines
- CI: lots of integration tests for Linux, MacOS and Windows

#### Changed
- Changed daemon threads to non-daemon threads
- Use Python's `logging` module instead of self-written one
- Usage options have changed drastically
- Changed `--reconnect` and `--reconnect-wait` to keep open (`-k`/`--keep`)

#### Removed
- Removed `builtins` import for cross-os base install compatibility


## Release 0.0.5-alpha

#### Added
- Feature: Local port forward (`-L`)


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
