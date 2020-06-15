---
# https://help.github.com/en/actions/language-and-framework-guides/using-python-with-github-actions
# https://github.com/actions/python-versions/blob/master/versions-manifest.json
name: __WORKFLOW_NAME__
on:
  pull_request:
  push:
    branches:
      - master
    tags:

jobs:
  test:
    runs-on: __OS__
    strategy:
      fail-fast: False

    name: "__JOB_NAME__"
    steps:
      # ------------------------------------------------------------
      # Setup
      # ------------------------------------------------------------
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: __PYTHON_VERSION__
          architecture: __ARCHITECTURE__

      - name: "Setup /etc/hosts for Linux"
        shell: bash
        run: |
          if [ `uname` = "Linux" ]; then
            echo "\$ cat /etc/hosts"
            cat /etc/hosts
            echo
            (
              echo "127.0.0.1       localhost";
              echo "::1     localhost ip6-localhost ip6-loopback";
            ) | sudo tee /etc/hosts
            echo
            echo "\$ cat /etc/hosts"
            cat /etc/hosts
          fi

__WINDOWS_JOBS__
__LINUX_JOBS__
__MACOS_JOBS__

      - name: Display Bash version
        shell: bash
        run: bash --version

      - name: Display Python version
        shell: bash
        run: python -c "import sys; print(sys.version)"

      - name: Resolve localhost
        shell: bash
        run: |
          echo
          echo "\$ host localost"
          host localhost || true
          echo
          echo "\$ python -c 'import socket;print(socket.gethostbyname(\"localhost\"))'"
          python -c 'import socket;print(socket.gethostbyname("localhost"))' || true
          echo
          echo "\$ python -c 'import socket;print(socket.getaddrinfo(\"localhost\", None))'"
          python -c 'import socket;print(socket.getaddrinfo("localhost", None))' || true
          echo
          echo "\$ python -c 'import socket;print(socket.getaddrinfo(\"localhost\", None, socket.AF_INET))'"
          python -c 'import socket;print(socket.getaddrinfo("localhost", None, socket.AF_INET))' || true
          echo
          echo "\$ python -c 'import socket;print(socket.getaddrinfo(\"localhost\", None, socket.AF_INET6))'"
          python -c 'import socket;print(socket.getaddrinfo("localhost", None, socket.AF_INET6))' || true


      # ------------------------------------------------------------
      # Tests: Behaviour (Client)
      # ------------------------------------------------------------

      - name: "[CNC] Inject shell"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make _test-cnc--inject_shell
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Client quits correctly 000"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--client-000
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Client quits correctly 001"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--client-001
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Client quits correctly 002"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--client-002
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Client quits correctly 003"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--client-003
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Client quits correctly 004"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--client-004
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Client quits correctly 100"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--client-100
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Client quits correctly 101"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--client-101
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Client quits correctly 102"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--client-102
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Client quits correctly 103"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--client-103
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Client quits correctly 200"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--client-200
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Client quits correctly 201"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--client-201
        env:
          RETRIES: 5

      # ------------------------------------------------------------
      # Tests: Behaviour (Server)
      # ------------------------------------------------------------

      - name: "[BEHAVIOUR] Server quits correctly 000"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--server-000
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Server quits correctly 001"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--server-001
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Server quits correctly 002"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--server-002
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Server quits correctly 003"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--server-003
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Server quits correctly 004"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--server-004
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Server quits correctly 100"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--server-100
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Server quits correctly 101"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--server-101
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Server quits correctly 103"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--server-103
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Server quits correctly 104"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--server-104
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Server quits correctly 200"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--server-200
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Server quits correctly 201"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-behaviour-quit--server-201
        env:
          RETRIES: 5

      # ------------------------------------------------------------
      # Tests: Behaviour (File Transfer)
      # ------------------------------------------------------------

      - name: "[BEHAVIOUR] File Transfer"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make _test-behaviour-base--file_transfer
        env:
          RETRIES: 5

      # ------------------------------------------------------------
      # Tests: Modes
      # ------------------------------------------------------------

      - name: "[MODES] Local port forwarding"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make _test-mode--local_forward
        env:
          RETRIES: 5

      - name: "[MODES] Remote port forwarding"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make _test-mode--remote_forward
        env:
          RETRIES: 5

      # ------------------------------------------------------------
      # Tests: Options
      # ------------------------------------------------------------

      - name: "[OPTIONS] -n/--nodns"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make _test-options--nodns
        env:
          RETRIES: 5

__DISABLE_CRLF__      - name: "[OPTIONS] -C/--crlf"
__DISABLE_CRLF__        shell: bash
__DISABLE_CRLF__        run: |
__DISABLE_CRLF____RETRY_FUNCTION_CRLF__
__DISABLE_CRLF__          retry make _test-options--crlf
__DISABLE_CRLF__        env:
__DISABLE_CRLF__          RETRIES: 5

      # ------------------------------------------------------------
      # Tests: Options (keep open)
      # ------------------------------------------------------------

      - name: "[OPTIONS] --keep-open 000"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-options--keep_open-000
        env:
          RETRIES: 5

      - name: "[OPTIONS] --keep-open 001"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-options--keep_open-001
        env:
          RETRIES: 5

      - name: "[OPTIONS] --keep-open 002"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-options--keep_open-002
        env:
          RETRIES: 5

      - name: "[OPTIONS] --keep-open 100"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-options--keep_open-100
        env:
          RETRIES: 5

      - name: "[OPTIONS] --keep-open 101"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-options--keep_open-101
        env:
          RETRIES: 5

      - name: "[OPTIONS] --keep-open 200"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-options--keep_open-200
        env:
          RETRIES: 5

      - name: "[OPTIONS] --keep-open 201"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-options--keep_open-201
        env:
          RETRIES: 5

      - name: "[OPTIONS] --keep-open 202"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-options--keep_open-202
        env:
          RETRIES: 5

      # ------------------------------------------------------------
      # Tests: Options (reconn)
      # ------------------------------------------------------------

      - name: "[OPTIONS] --reconn 000"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-options--reconn-000
        env:
          RETRIES: 5

      - name: "[OPTIONS] --reconn 001"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-options--reconn-001
        env:
          RETRIES: 5

      - name: "[OPTIONS] --reconn 002"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make __test-options--reconn-002
        env:
          RETRIES: 5

      # ------------------------------------------------------------
      # Tests: Options
      # ------------------------------------------------------------

      - name: "[OPTIONS] --ping-intvl"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make _test-options--ping_intvl
        env:
          RETRIES: 5

      - name: "[OPTIONS] --ping-word"
        shell: bash
        run: |
__RETRY_FUNCTION__
          retry make _test-options--ping_word
        env:
          RETRIES: 5
