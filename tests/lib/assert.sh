#!/usr/bin/env bash

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_eq() {
  expected=$1
  actual=$2
  [ "$expected" = "$actual" ] || fail "expected '$expected', got '$actual'"
}

assert_contains() {
  haystack=$1
  needle=$2
  printf '%s\n' "$haystack" | grep -Fq "$needle" || fail "expected output to contain '$needle'"
}

assert_not_contains() {
  haystack=$1
  needle=$2
  if printf '%s\n' "$haystack" | grep -Fq "$needle"; then
    fail "expected output not to contain '$needle'"
  fi
}

assert_file_exists() {
  [ -f "$1" ] || fail "expected file to exist: $1"
}

assert_dir_exists() {
  [ -d "$1" ] || fail "expected directory to exist: $1"
}

assert_success() {
  "$@" || fail "command failed: $*"
}

assert_failure() {
  if "$@"; then
    fail "command unexpectedly succeeded: $*"
  fi
}
