import socket
import json

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(10)
try:
    s.connect(('127.0.0.1', 9876))
    code = 'print("PING_SUCCESS")'
    data = code.encode('utf-8')
    s.sendall(len(data).to_bytes(4, 'big'))
    s.sendall(data)
    resp_len = int.from_bytes(s.recv(4), 'big')
    raw_resp = bytearray()
    while len(raw_resp) < resp_len:
        p = s.recv(resp_len - len(raw_resp))
        if not p: break
        raw_resp.extend(p)
    resp = json.loads(raw_resp.decode('utf-8'))
    print('RESULT:', resp.get('stdout', '').strip())
except Exception as e:
    print('WAITING:', e)
finally:
    s.close()
