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

      - name: Display Python version
        shell: bash
        run: python -c "import sys; print(sys.version)"

      # ------------------------------------------------------------
      # Tests: Behaviour
      # ------------------------------------------------------------

      - name: "[BEHAVIOUR] Client quits correctly"
        shell: bash
        run: |
          retry() {
            for n in $(seq ${RETRIES}); do
              echo "[${n}/${RETRIES}] ${*}";
              if eval "${*}"; then
                return 0;
              fi;
              sleep 10;
            done;
            return 1;
          }
          retry make _test-behaviour-quit--client
        env:
          RETRIES: 5

      - name: "[BEHAVIOUR] Server quits correctly"
        shell: bash
        run: |
          retry() {
            for n in $(seq ${RETRIES}); do
              echo "[${n}/${RETRIES}] ${*}";
              if eval "${*}"; then
                return 0;
              fi;
              sleep 10;
            done;
            return 1;
          }
          retry make _test-behaviour-quit--server
        env:
          RETRIES: 5

      # ------------------------------------------------------------
      # Tests: Modes
      # ------------------------------------------------------------

      - name: "[MODES] Local port forwarding"
        shell: bash
        run: |
          retry() {
            for n in $(seq ${RETRIES}); do
              echo "[${n}/${RETRIES}] ${*}";
              if eval "${*}"; then
                return 0;
              fi;
              sleep 10;
            done;
            return 1;
          }
          retry make _test-mode--local_forward
        env:
          RETRIES: 5

      - name: "[MODES] Remote port forwarding"
        shell: bash
        run: |
          retry() {
            for n in $(seq ${RETRIES}); do
              echo "[${n}/${RETRIES}] ${*}";
              if eval "${*}"; then
                return 0;
              fi;
              sleep 10;
            done;
            return 1;
          }
          retry make _test-mode--remote_forward
        env:
          RETRIES: 5

      # ------------------------------------------------------------
      # Tests: Options
      # ------------------------------------------------------------

      - name: "[OPTIONS] -n/--nodns"
        shell: bash
        run: |
          retry() {
            for n in $(seq ${RETRIES}); do
              echo "[${n}/${RETRIES}] ${*}";
              if eval "${*}"; then
                return 0;
              fi;
              sleep 10;
            done;
            return 1;
          }
          retry make _test-options--nodns
        env:
          RETRIES: 5

      __DISABLE_CRLF__- name: "[OPTIONS] -C/--crlf"
      __DISABLE_CRLF__  shell: bash
      __DISABLE_CRLF__  run: |
      __DISABLE_CRLF__    retry() {
      __DISABLE_CRLF__      for n in $(seq ${RETRIES}); do
      __DISABLE_CRLF__        echo "[${n}/${RETRIES}] ${*}";
      __DISABLE_CRLF__        if eval "${*}"; then
      __DISABLE_CRLF__          return 0;
      __DISABLE_CRLF__        fi;
      __DISABLE_CRLF__        sleep 10;
      __DISABLE_CRLF__      done;
      __DISABLE_CRLF__      return 1;
      __DISABLE_CRLF__    }
      __DISABLE_CRLF__    retry make _test-options--crlf
      __DISABLE_CRLF__  env:
      __DISABLE_CRLF__    RETRIES: 5

      - name: "[OPTIONS] --keep-open"
        shell: bash
        run: |
          retry() {
            for n in $(seq ${RETRIES}); do
              echo "[${n}/${RETRIES}] ${*}";
              if eval "${*}"; then
                return 0;
              fi;
              sleep 10;
            done;
            return 1;
          }
          retry make _test-options--keep_open
        env:
          RETRIES: 5

      - name: "[OPTIONS] --reconn"
        shell: bash
        run: |
          retry() {
            for n in $(seq ${RETRIES}); do
              echo "[${n}/${RETRIES}] ${*}";
              if eval "${*}"; then
                return 0;
              fi;
              sleep 10;
            done;
            return 1;
          }
          retry make _test-options--reconn
        env:
          RETRIES: 5

      - name: "[OPTIONS] --ping-intvl"
        shell: bash
        run: |
          retry() {
            for n in $(seq ${RETRIES}); do
              echo "[${n}/${RETRIES}] ${*}";
              if eval "${*}"; then
                return 0;
              fi;
              sleep 10;
            done;
            return 1;
          }
          retry make _test-options--ping_intvl
        env:
          RETRIES: 5

      - name: "[OPTIONS] --ping-word"
        shell: bash
        run: |
          retry() {
            for n in $(seq ${RETRIES}); do
              echo "[${n}/${RETRIES}] ${*}";
              if eval "${*}"; then
                return 0;
              fi;
              sleep 10;
            done;
            return 1;
          }
          retry make _test-options--ping_word
        env:
          RETRIES: 5
