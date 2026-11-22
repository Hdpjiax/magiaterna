import socket
import sys
import json

HOST = "127.0.0.1"
PORT = 9876

def send_code(code_str):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(180)
        s.connect((HOST, PORT))
        data = code_str.encode("utf-8")
        s.sendall(len(data).to_bytes(4, byteorder="big"))
        s.sendall(data)
        
        raw_len = s.recv(4)
        if not raw_len:
            print("Error: Sin respuesta del servidor de Blender.")
            return False
        resp_len = int.from_bytes(raw_len, byteorder="big")
        resp_data = bytearray()
        while len(resp_data) < resp_len:
            packet = s.recv(resp_len - len(resp_data))
            if not packet:
                break
            resp_data.extend(packet)
        s.close()
        
        result = json.loads(resp_data.decode("utf-8"))
        if result.get("success"):
            if result.get("stdout"):
                print(result["stdout"], end="")
            print("[OK] Ejecutado exitosamente en Blender.")
            return True
        else:
            print("[ERROR en Blender]:")
            print(result.get("error"))
            return False
    except ConnectionRefusedError:
        print(f"[ERROR]: No se pudo conectar a Blender en {HOST}:{PORT}. ¿Está Blender abierto con el script ejecutándose?")
        return False
    except Exception as e:
        print(f"[ERROR]: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) > 1:
        # Si se pasa un archivo o texto directo
        arg = sys.argv[1]
        try:
            with open(arg, "r", encoding="utf-8") as f:
                code = f.read()
        except Exception:
            code = " ".join(sys.argv[1:])
        send_code(code)
    else:
        print("Uso: python send_to_blender.py <archivo.py o 'codigo'>")
