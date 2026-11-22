# MAGIA ETERNA — Plan Técnico y Arquitectura de Sistemas

## 1. Filosofía Arquitectónica
El proyecto sigue una arquitectura **Server-Authoritative**, modular y desacoplada mediante patrones de Servicios y Controladores (Service-Controller Pattern), con tipado estricto en Luau y configuración 100% centralizada.

### Principios Fundamentales:
1. **Confianza Cero en el Cliente (Zero-Trust Client)**: El cliente únicamente solicita intenciones (`RequestTrain`, `RequestForge`, `RequestOpenEgg`). El servidor valida estado, recursos, inventario, permisos y cooldowns antes de aplicar cambios de estado.
2. **Modularidad Estricta**: Cada subsistema reside en su propio `ModuleScript` autocontenido. Ningún script monolítico supera las responsabilidades de su dominio.
3. **Seguridad y Anti-Dupe**: Operaciones atómicas sobre el perfil de datos del jugador en memoria (Session Locking y Cache Centralizado) antes de persistir en `DataStoreService`.
4. **Validación de Red (Remote Guard)**: Todo RemoteEvent y RemoteFunction cuenta con validación de tipos, límites de rango, verificación de cooldowns (Rate Limiter) y sanitización de argumentos.

---

## 2. Mapa de Dependencias y Flujo de Datos

```
[ CLIENTE ]
InputController ───► Remotes (Request) ───► RemoteGuard (Rate Limiter / Type Checker)
      ▲                                                         │
      │                                                         ▼
StateReplication ◄── PlayerDataService ◄─── Core Services (Forge, Pet, Dungeon, Magic)
                                                                │
                                                                ▼
                                                        Profile / DataStore
```

### Relación de Servicios en Servidor:
- `PlayerDataService`: Gestiona la sesión, bloqueo de sesión (Session Locking), carga inicial y guardado periódico seguro de cada jugador. Provee la API `GetData(player)`, `UpdateData(player, callback)`.
- `EconomyService`: Procesa adición/sustracción de Oro, Esencias y Fragmentos con transacciones seguras y eventos de cambio de saldo.
- `MagicService`: Calcula el poder mágico por clic y por segundo en base a bastón equipado, mascotas, nivel de renacimiento y multiplicadores pasivos.
- `PetService`: Maneja inventario de mascotas, equipamiento (máx 3-5), fusiones doradas/arcoíris y cálculo de multiplicadores consolidados.
- `EggService`: Procesa compra de huevos, probabilidades ponderadas de drop en servidor y concesión de mascotas al inventario.
- `ForgeService`: Valida recetas de bastones y armaduras, descuenta materiales y entrega el objeto forjado sin riesgo de duplicación.
- `DungeonService`: Gestiona instancias de mazmorras, emparejamiento, progresión de salas, spawneo de enemigos y entrega de cofres al finalizar.
- `CombatService`: Resuelve hitboxes en servidor (o validación server-side de proyectiles cliente con comprobación de línea de visión y velocidad máxima permitida).
- `EnemyService`: Máquina de estados para IA de enemigos y fases telegrafiadas de jefes.
- `RebirthService`: Valida requisitos de poder mágico, aplica el reset de poder y recompensa multiplicadores permanentes.
- `QuestService`: Registra progreso de misiones diarias, semanales y logros con concesión de recompensas.

---

## 3. Plan de Implementación por Fases

| Fase | Enfoque Principal | Entregables Clave | Criterio de Aprobación |
| :--- | :--- | :--- | :--- |
| **Fase 0** | Documentación y Arquitectura | GDD, Plan Técnico, Economía, Assets, Quests, Tests, estructura de carpetas | Documentación completa y aprobada por el usuario |
| **Fase 1** | Núcleo de Datos y Red (Core) | `PlayerDataService`, `RemoteGuard`, Esquemas de Datos, DataStore seguro, Leaderstats | Carga, guardado y bloqueo de sesión verificados sin pérdida de datos |
| **Fase 2** | Magic Simulator & Rebirth | `MagicService`, `RebirthService`, Estaciones de entrenamiento, clics y multiplicadores | Clics y entrenamiento pasivo funcionando con multiplicadores de rebirth |
| **Fase 3** | Mascotas y Huevos (Pet System)| `EggService`, `PetService`, apertura con probabilidad ponderada, inventario, seguimiento | Apertura de huevos, equipamiento de 3-5 mascotas y cálculo de bonus |
| **Fase 4** | Forja y Catálogo de Bastones | `ForgeService`, Catálogos de 120 Bastones, recetas, consumo de materiales, anti-dupe | Forjado exitoso de bastones con deducción atómica de materiales |
| **Fase 5** | Sistema de Mazmorras y Jefes | `DungeonService`, `EnemyService`, `CombatService`, IA de salas, 3 fases de jefes | Mazmorra funcional con salas, combate telegrafiado y entrega de botín |
| **Fase 6** | UI Adaptativa, Pulido & Audio | GameUI (HUD, Inventario, Forja, Huevos, Menús) optimizada para PC/Móvil/Consola | Interfaz fluida, 60 FPS en móvil, soporte táctil y gamepad probado |

---

## 4. Estructura de Directorios en Repositorio y Rojo

```
MAGIA_ETERNA/
├── default.project.json
├── Documentation/
│   ├── GAME_DESIGN.md
│   ├── TECHNICAL_PLAN.md
│   ├── ECONOMY.md
│   ├── ASSETS.md
│   ├── QUESTS.md
│   └── TESTING.md
├── src/
│   ├── shared/
│   │   ├── Config/
│   │   │   ├── GameConfig.luau
│   │   │   ├── StaffConfig.luau
│   │   │   ├── PetConfig.luau
│   │   │   ├── EggConfig.luau
│   │   │   ├── DungeonConfig.luau
│   │   │   ├── EnemyConfig.luau
│   │   │   ├── ArmorConfig.luau
│   │   │   └── RecipeConfig.luau
│   │   ├── Modules/
│   │   │   ├── NumberFormatter.luau
│   │   │   ├── RarityUtils.luau
│   │   │   ├── RateLimiter.luau
│   │   │   └── TypeValidators.luau
│   │   └── Network/
│   │       └── NetworkEndpoints.luau
│   ├── server/
│   │   ├── init.server.luau
│   │   └── Services/
│   │       ├── PlayerDataService.luau
│   │       ├── EconomyService.luau
│   │       ├── MagicService.luau
│   │       ├── PetService.luau
│   │       ├── EggService.luau
│   │       ├── ForgeService.luau
│   │       ├── DungeonService.luau
│   │       ├── CombatService.luau
│   │       ├── EnemyService.luau
│   │       ├── RebirthService.luau
│   │       └── QuestService.luau
│   └── client/
│       ├── init.client.luau
│       ├── Controllers/
│       │   ├── InputController.luau
│       │   ├── CombatController.luau
│       │   ├── PetFollowController.luau
│       │   └── UIController.luau
│       └── UI/
```
