#!/usr/bin/env python3
"""
Basys3 UART test for AES-128 SoC (v2 - measures on-FPGA encryption cycles).
Sends NIST TV1; reads 19 bytes = 0xAA status + 16 ciphertext + 2-byte cycle count.
Usage: python uart_test_v2.py   (adjust PORT to your COM port)
"""
import serial, time

PORT = "COM7"   # <- change to your BASYS3 COM port (Device Manager)
BAUD = 115200
KEY   = bytes.fromhex("2B7E151628AED2A6ABF7158809CF4F3C")
PLAIN = bytes.fromhex("6BC1BEE22E409F96E93D7E117393172A")
WANT  = bytes.fromhex("3AD77BB40D7A3660A89ECAF32466EF97")

s = serial.Serial(PORT, BAUD, timeout=3)
time.sleep(0.5)
s.reset_input_buffer()

s.write(bytes([0xAE]) + KEY + PLAIN)
out = s.read(19)                    # status(1) + cipher(16) + cycles(2, LSB first)

status = out[0:1]
cipher = out[1:17]
cycles = out[17] | (out[18] << 8)   # little-endian 16-bit count
ns     = cycles * 20                # 20 ns per cycle @ 50 MHz

print("status:", status.hex().upper())
print("cipher:", cipher.hex().upper())
print("expect: 3AD77BB40D7A3660A89ECAF32466EF97")
print("RESULT:", "PASS" if cipher == WANT else "FAIL")
print("cycles:", cycles, f"({ns} ns @ 50 MHz) — measured on FPGA")
