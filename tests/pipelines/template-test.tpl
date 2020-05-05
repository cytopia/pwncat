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

      # ------------------------------------------------------------
      # Tests: Behaviour
      # ------------------------------------------------------------

      - name: "[BEHAVIOUR] Client quits correctly"
        shell: bash
        run: |
          make _test-behaviour-quit--client

      - name: "[BEHAVIOUR] Server quits correctly"
        shell: bash
        run: |
          make _test-behaviour-quit--server

      - name: "[MODES] Local port forwarding"
        shell: bash
        run: |
          make _test-mode--local_forward

      - name: "[MODES] Remote port forwarding"
        shell: bash
        run: |
          make _test-mode--remote_forward

      - name: "[OPTIONS] -n/--nodns"
        shell: bash
        run: |
          make _test-options--nodns

      - name: "[OPTIONS] -C/--crlf"
        shell: bash
        run: |
          make _test-options--crlf

      - name: "[OPTIONS] --keep-open"
        shell: bash
        run: |
          make _test-options--keep_open

      - name: "[OPTIONS] --reconn"
        shell: bash
        run: |
          make _test-options--reconn

      - name: "[OPTIONS] --ping-intvl"
        shell: bash
        run: |
          make _test-options--ping_intvl
