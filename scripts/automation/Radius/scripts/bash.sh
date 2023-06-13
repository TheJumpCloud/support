#!/bin/bash
echo $(dirname -- "${BASH_SOURCE[0]}")
ls "$(dirname -- "${BASH_SOURCE[0]}")/../Cert"
echo "hello world"
exit 4