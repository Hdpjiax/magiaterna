import bpy
import socket
import threading
import queue
import json
import sys
import io
import traceback

PORT = 9876
HOST = "127.0.0.1"

# Limpiar servidor anterior si existía
if "BRIDGE_SERVER" in globals() and globals()["BRIDGE_SERVER"]:
    try:
        globals()["BRIDGE_RUNNING"] = False
        globals()["BRIDGE_SERVER"].close()
    except Exception:
        pass

command_queue = queue.Queue()

def run_code_on_main_thread():
    while not command_queue.empty():
        item = command_queue.get()
        code_str, client_socket = item
        
        old_stdout = sys.stdout
        old_stderr = sys.stderr
        sys.stdout = buffer_out = io.StringIO()
        sys.stderr = buffer_err = io.StringIO()
        
        success = True
        error_msg = ""
        try:
            exec(code_str, globals())
            # Forzar actualización de viewport para ver los cambios de inmediato
            for window in bpy.context.window_manager.windows:
                for area in window.screen.areas:
                    area.tag_redraw()
        except Exception as e:
            success = False
            error_msg = traceback.format_exc()
        finally:
            sys.stdout = old_stdout
            sys.stderr = old_stderr
        
        response = {
            "success": success,
            "stdout": buffer_out.getvalue(),
            "stderr": buffer_err.getvalue(),
            "error": error_msg
        }
        
        try:
            resp_data = json.dumps(response).encode("utf-8")
            client_socket.sendall(len(resp_data).to_bytes(4, byteorder="big"))
            client_socket.sendall(resp_data)
            client_socket.close()
        except Exception:
            pass
            
    return 0.05 # Revisar la cola cada 50ms

def socket_listener():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        server.bind((HOST, PORT))
        server.listen(5)
        globals()["BRIDGE_SERVER"] = server
        print(f"\n==========================================")
        print(f"*** BLENDER LIVE BRIDGE ACTIVO ({HOST}:{PORT}) ***")
        print(f"==========================================\n")
        
        while globals().get("BRIDGE_RUNNING", True):
            try:
                client, addr = server.accept()
                raw_len = client.recv(4)
                if not raw_len:
                    client.close()
                    continue
                msg_len = int.from_bytes(raw_len, byteorder="big")
                data = bytearray()
                while len(data) < msg_len:
                    packet = client.recv(msg_len - len(data))
                    if not packet:
                        break
                    data.extend(packet)
                code_str = data.decode("utf-8")
                command_queue.put((code_str, client))
            except Exception:
                break
    except Exception as e:
        print(f"Error en servidor socket: {e}")
    finally:
        try:
            server.close()
        except Exception:
            pass

globals()["BRIDGE_RUNNING"] = True
listener_thread = threading.Thread(target=socket_listener, daemon=True)
listener_thread.start()

if not bpy.app.timers.is_registered(run_code_on_main_thread):
    bpy.app.timers.register(run_code_on_main_thread)

print(">> Blender Live Bridge cargado y listo para recibir comandos.")
