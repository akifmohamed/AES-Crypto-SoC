import serial, time
PORT = "COM7"
s = serial.Serial(PORT, 115200, timeout=3)
time.sleep(0.5)
s.reset_input_buffer()
s.write(bytes([0x55]))
r = s.read(1)
print("alive:", "OK" if r == bytes([0xAA]) else "FAIL")
s.reset_input_buffer()
s.write(bytes([0xAE]) + bytes.fromhex("2B7E151628AED2A6ABF7158809CF4F3C") + bytes.fromhex("6BC1BEE22E409F96E93D7E117393172A"))
out = s.read(17)
status = out[:1]
cipher = out[1:]
print("status:", status.hex().upper())
print("cipher:", cipher.hex().upper())
print("expect: 3AD77BB40D7A3660A89ECAF32466EF97")
print("RESULT:", "PASS" if cipher == bytes.fromhex("3AD77BB40D7A3660A89ECAF32466EF97") else "FAIL")
