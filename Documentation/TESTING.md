# MAGIA ETERNA — Matriz de Pruebas y Control de Calidad (QA)

## 1. Protocolo de Pruebas Obligatorio
Ningún sistema o fase se declara terminado sin ejecutar y pasar las pruebas correspondientes:

### Categorías de Pruebas:
1. **Pruebas Unitarias de Lógica y Fórmulas**:
   - Cálculos matemáticos de poder de clic y multiplicadores.
   - Algoritmo de probabilidad ponderada en apertura de huevos (distribución estadística tras 10,000 tiradas simuladas).
   - Fórmulas de coste de renacimiento y escalado de dificultad de mazmorras.
2. **Pruebas de Seguridad y Red (Server Validation)**:
   - Envío de llamadas malformadas a RemoteEvents para verificar rechazo por `RemoteGuard`.
   - Simulación de peticiones de forja sin materiales suficientes (debe rechazar y no deducir).
   - Intento de duplicación mediante solicitudes simultáneas concurrentes.
   - Verificación de Session Locking al iniciar sesión secundaria en servidor simulado.
3. **Pruebas de Persistencia de Datos**:
   - Guardado, desconexión forzada y recarga de perfil de datos con DataStore mock / real.
   - Validación de esquema de datos con migraciones hacia adelante (Backward Compatibility).
4. **Pruebas de Rendimiento y Compatibilidad Multiplataforma**:
   - Comportamiento en pantalla pequeña táctil (Mobile Emulation).
   - Control con teclado/ratón vs mando/gamepad.
   - Monitoreo de memoria en Workspace y ReplicatedStorage (evitar memory leaks por conexiones no desconectadas de eventos `Maid` / `Janitor`).

---

## 2. Matriz de Casos de Prueba (Fase 1: Core de Datos y Red)

| ID | Módulo | Caso de Prueba | Resultado Esperado | Estado |
| :--- | :--- | :--- | :--- | :--- |
| `TC-DATA-01` | `PlayerDataService` | Jugador nuevo se une al juego | Se inicializa un perfil con valores por defecto (Oro 0, Magia 0, Rebirth 0, Bastón 001). | Pendiente F1 |
| `TC-DATA-02` | `PlayerDataService` | Jugador modifica datos y sale del juego | Los datos se persisten en DataStore de forma segura sin excepciones. | Pendiente F1 |
| `TC-DATA-03` | `PlayerDataService` | Desconexión abrupta o caída de servidor | `BindToClose` procesa el guardado de todos los jugadores activos. | Pendiente F1 |
| `TC-NET-01` | `RemoteGuard` | Cliente envía argumentos de tipo incorrecto | El servidor descarta la petición silenciosamente sin arrojar error fatal. | Pendiente F1 |
| `TC-NET-02` | `RemoteGuard` | Cliente spamea clics por encima del rate limit | Las peticiones que exceden la frecuencia máxima permitida son ignoradas. | Pendiente F1 |
