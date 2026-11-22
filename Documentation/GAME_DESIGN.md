# MAGIA ETERNA — Documento de Diseño de Juego (GDD)

## 1. Visión General del Proyecto
- **Título**: MAGIA ETERNA
- **Plataformas**: PC, Dispositivos Móviles (iOS/Android), Consolas (Xbox/PlayStation).
- **Género**: Magic Simulator + Dungeon Crawler RPG + Pet Collector + Blacksmith Tycoon.
- **Público Objetivo**: Todas las edades (E for Everyone), diseñado con bucles adictivos, accesibles y con profundidad estratégica para retención a largo plazo.

---

## 2. Pilares de Diseño
1. **Magic Simulator**: Progresión continua de poder mágico mediante clics, entrenamiento pasivo, estaciones mágicas y renacimientos estratégicos.
2. **Dungeon RPG**: Seis regiones de mazmorras no repetitivas con enemigos únicos, trampas, eventos, mini-jefes y jefes en 3 fases de combate telegrafiado (skill-based).
3. **Pet Simulator**: Huevos por región con rarezas ponderadas (Común a Mítico), bonificaciones pasivas de magia, oro, suerte y materiales, con opciones de fusión y evolución.
4. **Blacksmith Simulator**: Sistema de forja en el yunque central donde se fabrican y mejoran 120 bastones únicos y 6 sets completos de armadura de 6 piezas utilizando minerales y esencias de mazmorras.
5. **Progresión por Renacimientos (Rebirth)**: Reseteo controlado de poder a cambio de multiplicadores permanentes, acceso a nuevas zonas, auras y transformaciones.

---

## 3. Bucle Principal de Juego (Core Gameplay Loop)
```
[ ENTRENAMIENTO ]
(Clic / Estaciones / Pasivo)
        │
        ▼ Genera Poder Mágico
[ EXPLORACIÓN DE MAZMORRAS ]
(6 Regiones, 5 Dificultades, Jefes)
        │
        ▼ Consigue Oro, Esencias y Materiales de Forja
[ FORJA Y COLECCIÓN ]
(Forjar Bastones 1-120, Armaduras, Abrir Huevos de Mascota)
        │
        ▼ Incrementa Estadísticas, Resistencia y Multiplicadores
[ RENACIMIENTO (REBIRTH) ]
(Multiplicador Permanente, Hitos Visuales, Auras)
        │
        └───────► Reinicia con Mayor Potencial (Loop Infinito)
```

---

## 4. Las 6 Regiones de Mazmorras
Cada región cuenta con 5 dificultades (I a V), duración de partida de 5 a 12 minutos, con 3-4 salas de combate, 1 sala de exploración con trampas, 1 mini-jefe y 1 jefe final en 3 fases:

| Región | Nivel Recom. | Enemigos Normales | Mini-Jefe | Jefe Final (3 Fases) | Material Exclusivo |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Bosque de los Susurros** | 1 - 10 | Slime Verde, Duende, Lobo Mágico, Hada Corrupta | Guardián de Raíces | **Treant Ancestral** | Madera Antigua, Hoja Mágica, Núcleo del Treant |
| **2. Minas del Fuego Eterno** | 10 - 20 | Murciélago de Lava, Gólem Ígneo, Minero Maldito | Coloso Ígneo | **Dragón de Magma** | Carbón Arcano, Hierro Volcánico, Corazón de Magma |
| **3. Cumbres Heladas** | 20 - 30 | Lobo Ártico, Espectro de Hielo, Yeti Menor | Reina de Escarcha | **Titán Glacial** | Hielo Eterno, Zafiro Glacial, Alma Congelada |
| **4. Cripta de las Almas** | 30 - 50 | Esqueleto Maldito, Vampiro, Nigromante | Caballero Sin Alma | **Rey de las Almas** | Hueso Espectral, Polvo de Alma, Corazón Necrótico |
| **5. Templo de los Cielos** | 50 - 70 | Centinela Divino, Grifo, Elemental de Luz | Guardián Solar | **Arcángel del Caos** | Pluma Celestial, Oro Sagrado, Núcleo del Arcángel |
| **6. Abismo del Infinito** | 70 - 100 | Devorador, Sombra Cósmica, Mago del Vacío | Destructor Dimensional | **Dios del Vacío** | Fragmento del Vacío, Materia Oscura, Corazón del Infinito |

### Fases de los Jefes:
- **Fase 1 (100% - 60% HP)**: Ataques base telegrafiados con indicadores en suelo (AoE circular y conos).
- **Fase 2 (60% - 25% HP - Furia)**: Velocidad aumentada, ataques combinados y convocación de esbirros.
- **Fase 3 (25% - 0% HP - Definitiva)**: Habilidad suprema que altera el entorno (caída de meteoritos, suelos congelados, zonas de gravedad cero).

---

## 5. Índice de Colección: 120 Bastones Mágicos
Distribuido en 6 familias de 20 bastones cada una:
- **Bosque (001 - 020)**: Desde *Rama de Aprendiz* (Común) hasta *Bastón del Corazón Verde* (Mítico).
- **Fuego (021 - 040)**: Desde *Vara de Carbón* (Común) hasta *Bastón del Dragón Carmesí* (Mítico).
- **Hielo (041 - 060)**: Desde *Vara de Hielo Menor* (Común) hasta *Bastón del Invierno Eterno* (Mítico).
- **Cripta (061 - 080)**: Desde *Vara de Hueso* (Común) hasta *Bastón del Rey Eterno* (Mítico).
- **Cielos (081 - 100)**: Desde *Vara de Pluma* (Común) hasta *Bastón de la Divinidad* (Mítico).
- **Abismo (101 - 120)**: Desde *Vara de Vacío* (Común) hasta *Bastón de la Magia Eterna* (Mítico Supremo).

Cada bastón provee: Poder Mágico Base, Multiplicador Elemental, Efectos Visuales (VFX) de proyectil y Pasiva de Combate en rarezas Épicas o superiores.

---

## 6. Sistema de Mascotas y Huevos
- **6 Familias de Huevos**: Huevo del Bosque, Huevo Volcánico, Huevo Glacial, Huevo Espectral, Huevo Celestial, Huevo Cósmico.
- **Rarezas**: Común (50%), Poco Común (27%), Rara (14%), Épica (6%), Legendaria (2.5%), Mítica (0.5%).
- **Límite de Mascotas Equipadas**: 3 de base, ampliable jugando hasta 5 sin pagos forzados.
- **Estadísticas de Mascota**:
  - `MagicBonusPercent`: Multiplicador de ganancia mágica.
  - `CoinsBonusPercent`: Multiplicador de oro obtenido.
  - `LuckBonusPercent`: Incremento de probabilidad para forja y drops.
  - `MaterialsBonusPercent`: Probabilidad de doble material en mazmorras.
- **Mecánicas**: Bloqueo de favoritos, eliminación masiva, sistema de fusión (3 duplicados = versión Dorada con x1.5 estadísticas; 3 dorados = versión Arcoíris con x2.5 estadísticas).

---

## 7. Sistema de Forja y Armaduras
- **Forja**: El jugador combina materiales recolectados en mazmorras para crear bastones y piezas de armadura.
- **Validación**: 100% en servidor para prevenir duplicación o creación sin recursos.
- **Sets de Armadura (6 piezas por región)**: Casco, Pechera, Guantes, Pantalones, Botas, Capa.
  - Bonus de set completo (+15% a +20% a estadísticas defensivas y elementales de la región).

---

## 8. Sistema de Renacimiento (Rebirth)
Fórmula de progresión de coste de renacimiento:
$$Cost(R) = BaseCost \times 10^{R \times 0.65}$$
- Otorga multiplicador permanente: $M = 1 + (R \times 0.25)$ (o superior con hitos).
- Conserva: Bastones, Armaduras, Mascotas, Mejoras permanentes, Recetas desbloqueadas.
- Reinicia: Poder mágico acumulado actual.
- Otorga: Fragmentos de Renacimiento para el árbol de habilidades pasivas permanentes.
