# MAGIA ETERNA — Estructura y Especificación de Assets

## 1. Catálogo Modular de 120 Bastones
Para optimizar memoria y tiempo de renderizado en Roblox sin perder identidad visual:
- Los 120 bastones se basan en una estructura modular compuesta por:
  1. **Handle (Empuñadura)**: 12 geometrías base según región/nivel.
  2. **Headpiece (Cabezal/Foco)**: 24 variantes ornamentales estilizadas.
  3. **Core Crystal (Cristal Central)**: Gemas facetadas con emisión de brillo (Neon y ParticleEmitter).
  4. **Runes/Vines (Detalles de acabado)**: Hojas, cadenas, grabados o anillos flotantes.
- En el archivo `Armeria_Bastones_120_Roblox.fbx` y scripts de generación en Blender ya se cuenta con la base técnica completa para importar y registrar cada bastón en `ReplicatedStorage.Assets.Staffs`.

### Convención de Nomenclatura de Bastones:
`Staff_<RegionID>_<Number3Digits>_<InternalName>`
Ejemplos:
- `Staff_R1_001_RamaAprendiz`
- `Staff_R1_020_BastonCorazonVerde`
- `Staff_R2_035_VaraDragonRojo`
- `Staff_R6_120_BastonMagiaEterna`

---

## 2. Mascotas y Modelado Estilizado
- **Estilo**: Low-poly estilizado con paletas de color pasteles y saturadas, ojos cartoon expresivos y siluetas reconocibles a la distancia.
- **Jerarquía en Roblox**:
  - `Model`: Nombre de la mascota (e.g. `Pet_SlimeVerde`).
  - `PrimaryPart`: Parte central invisible (`Hitbox` o `RootPart`) anclada a la física de seguimiento con `AlignPosition` y `AlignOrientation` para movimientos suaves a 60 FPS sin sobrecargar físicas de Roblox.
  - `BodyMesh`: MeshPart con texturas optimizadas y materiales Plastic / SmoothPlastic.
  - `Effects`: Partículas sutiles de estela según rareza (estrellas, fuego fatuo, nieve, brillos dorados).

---

## 3. Mazmorras y Entorno
- 6 Kits de piezas modulares para salas de mazmorra:
  - Muros rectos, esquinas, arcos, columnas, puertas de portal y baldosas de suelo.
  - Trampas con indicadores visuales claros (marcas rojas translúcidas en suelo antes del impacto para permitir esquiva).

---

## 4. Efectos Visuales (VFX) y Rendimiento Móvil
- Máximo 3 `ParticleEmitter` activos por bastón o mascota.
- `LightEmission` moderado para evitar sobreexposición visual.
- Los proyectiles de hechizos usan partes neon optimizadas con interpolación (`TweenService` en cliente) o partículas locales para evitar tráfico excesivo en red.
