# MAGIA ETERNA — Especificación Económica y Balance

## 1. Sistema Multimoneda
El juego opera con tres monedas principales con propósitos estrictamente delimitados:

| Moneda | Fuente Principal | Uso Principal |
| :--- | :--- | :--- |
| **Oro (Coins)** | Derrotar enemigos, cofres, venta de equipo y recompensas de misiones. | Compra de huevos, pociones y mejoras básicas. |
| **Esencias Mágicas (Essences)** | Mazmorras (según región), jefes y eventos mágicos. | Forja avanzada, encantamientos y mejora de armaduras. |
| **Fragmentos de Renacimiento (Rebirth Shards)** | Conseguidos exclusivamente al realizar un Renacimiento o superar mazmorras en dificultad V. | Árbol de talentos permanentes y cosméticos legendarios. |

---

## 2. Fórmulas Matemáticas de Progresión

### 2.1. Poder Mágico por Clic
$$P_{\text{clic}} = \left( BasePower + StaffPower \right) \times \left( 1 + 0.15 \times RebirthLevel \right) \times \prod M_{\text{pets}} \times M_{\text{passives}}$$

Donde:
- $BasePower = 1$
- $StaffPower$: Proporcionado por el bastón equipado (de 1 en Bastón 001 hasta 500,000 en Bastón 120).
- $RebirthLevel$: Nivel actual de renacimiento del usuario.
- $\prod M_{\text{pets}}$: Producto acumulado de los multiplicadores porcentuales de las mascotas equipadas.

### 2.2. Coste de Renacimientos
$$MagicCost(R) = 10,000 \times 10^{R \times 0.60}$$

| Renacimiento | Magia Requerida | Multiplicador Permanente | Recompensa Especial |
| :---: | :---: | :---: | :--- |
| **0** | 0 | x1.00 | - |
| **1** | 10,000 | x1.25 | Título: Aprendiz |
| **2** | 40,000 | x1.50 | Acceso a Estación de Fuego |
| **3** | 160,000 | x1.85 | Aura Espectral Menor |
| **5** | 1,000,000 | x2.75 | Slot +1 de Mascota |
| **10** | 50,000,000 | x6.00 | Bastón Exclusivo de Renacimiento |
| **25** | 5,000,000,000 | x25.00 | Mascota Fénix de Renacimiento |
| **50** | 500,000,000,000 | x100.00 | Transformación Visual Legendaria |

---

## 3. Precios y Probabilidades de Huevos de Mascota

| Huevo | Región | Coste (Oro) | Común | Poco Común | Rara | Épica | Legendaria | Mítica |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Huevo del Bosque** | Bosque | 1,000 | 50.0% | 27.0% | 14.0% | 6.0% | 2.5% | 0.5% |
| **Huevo Volcánico** | Minas | 15,000 | 48.0% | 28.0% | 14.5% | 6.5% | 2.5% | 0.5% |
| **Huevo Glacial** | Hielo | 100,000 | 46.0% | 29.0% | 15.0% | 6.8% | 2.7% | 0.5% |
| **Huevo Espectral** | Cripta | 750,000 | 45.0% | 29.5% | 15.2% | 7.0% | 2.8% | 0.5% |
| **Huevo Celestial** | Cielos | 5,000,000 | 44.0% | 30.0% | 15.5% | 7.2% | 2.8% | 0.5% |
| **Huevo Cósmico** | Abismo | 35,000,000 | 43.0% | 30.5% | 15.8% | 7.4% | 2.8% | 0.5% |

---

## 4. Prevención de Duplicación y Explotación (Anti-Dupe Policy)
1. **Sin Comercio Inseguro Entre Jugadores**: No existen intercambios directos peer-to-peer sin validación bifásica (Two-Phase Commit).
2. **Validación Atómica de Inventario**: Al abrir un huevo o forjar un bastón, el servidor verifica la existencia y cantidad de recursos, los descuenta y añade el nuevo objeto en una sola transacción en memoria.
3. **Session Locking**: Previene que un jugador abra sesiones simultáneas en dos servidores para duplicar objetos o monedas. Si la sesión está bloqueada por otro servidor, la solicitud se rechaza de forma segura.
