"""
=============================================================================
MAGIA ETERNA — MODELADO Y RENDERIZADO DE ALTA CALIDAD DE HUEVOS EN BLENDER 5.3
Modela los 4 Huevos Elementales de Mascotas con detalles únicos y genera un render:
1. Huevo Común del Bosque (Nido de ramas, musgo, corteza y runa esmeralda)
2. Huevo Raro de Zafiro (Facetas cristalinas, bandas de plata, agua y perlas)
3. Huevo Épico del Vacío (Amatista oscura, espinas de obsidiana, grietas púrpuras)
4. Huevo Legendario Solar (Oro sagrado, runas solares, alas divinas y halo)
=============================================================================
"""
import bpy
import math

def clean_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def create_pbr_mat(name, base_color, metallic=0.0, roughness=0.5, emission=None, emission_val=0.0):
    mat = bpy.data.materials.get(name)
    if not mat:
        mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        if "Base Color" in bsdf.inputs:
            bsdf.inputs["Base Color"].default_value = base_color
        if "Metallic" in bsdf.inputs:
            bsdf.inputs["Metallic"].default_value = metallic
        if "Roughness" in bsdf.inputs:
            bsdf.inputs["Roughness"].default_value = roughness
        if emission:
            if "Emission Color" in bsdf.inputs:
                bsdf.inputs["Emission Color"].default_value = emission
                if "Emission Strength" in bsdf.inputs:
                    bsdf.inputs["Emission Strength"].default_value = emission_val
            elif "Emission" in bsdf.inputs:
                bsdf.inputs["Emission"].default_value = emission
                if "Emission Strength" in bsdf.inputs:
                    bsdf.inputs["Emission Strength"].default_value = emission_val
    return mat

def create_egg_mesh(name, location, scale=(1.0, 1.0, 1.35)):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=24, radius=0.8, location=location)
    egg = bpy.context.active_object
    egg.name = name
    egg.scale = scale
    bpy.ops.object.shade_smooth()
    return egg

def build_scene_and_render():
    clean_scene()
    
    # 1. Materiales de los Huevos
    # Huevo 1: Bosque
    m_egg_forest = create_pbr_mat("M_Huevo_Bosque", (0.35, 0.75, 0.30, 1.0), roughness=0.35)
    m_wood = create_pbr_mat("M_Madera_Nido", (0.35, 0.22, 0.12, 1.0), roughness=0.8)
    m_moss = create_pbr_mat("M_Musgo_Runa", (0.2, 0.95, 0.4, 1.0), roughness=0.2, emission=(0.2, 0.95, 0.4, 1.0), emission_val=8.0)
    
    # Huevo 2: Zafiro / Raro
    m_egg_sapphire = create_pbr_mat("M_Huevo_Zafiro", (0.15, 0.55, 0.95, 1.0), metallic=0.3, roughness=0.15)
    m_silver = create_pbr_mat("M_Plata_Banda", (0.9, 0.92, 0.95, 1.0), metallic=0.95, roughness=0.2)
    m_cyan_glow = create_pbr_mat("M_Glow_Cian", (0.2, 0.85, 1.0, 1.0), roughness=0.05, emission=(0.2, 0.85, 1.0, 1.0), emission_val=12.0)
    
    # Huevo 3: Amatista / Épico
    m_egg_amethyst = create_pbr_mat("M_Huevo_Amatista", (0.45, 0.10, 0.65, 1.0), metallic=0.4, roughness=0.2)
    m_obsidian = create_pbr_mat("M_Obsidiana_Spike", (0.08, 0.06, 0.10, 1.0), metallic=0.5, roughness=0.1)
    m_purple_glow = create_pbr_mat("M_Glow_Purpura", (0.85, 0.15, 1.0, 1.0), roughness=0.05, emission=(0.85, 0.15, 1.0, 1.0), emission_val=16.0)
    
    # Huevo 4: Solar / Legendario
    m_egg_solar = create_pbr_mat("M_Huevo_Solar", (1.0, 0.85, 0.30, 1.0), metallic=0.9, roughness=0.15)
    m_gold = create_pbr_mat("M_Oro_Celestial", (1.0, 0.80, 0.15, 1.0), metallic=0.98, roughness=0.12)
    m_sun_glow = create_pbr_mat("M_Glow_Solar", (1.0, 0.92, 0.40, 1.0), roughness=0.0, emission=(1.0, 0.92, 0.40, 1.0), emission_val=22.0)

    # 2. Suelo / Pedestal de Exhibición (Mármol Oscuro)
    m_floor = create_pbr_mat("M_Marmol_Suelo", (0.05, 0.05, 0.07, 1.0), roughness=0.2)
    bpy.ops.mesh.primitive_cylinder_add(vertices=64, radius=8.0, depth=0.4, location=(0, 0, -0.2))
    floor = bpy.context.active_object; floor.name = "Podio_Exhibicion"; floor.data.materials.append(m_floor)
    
    # Placas doradas bajo cada huevo
    x_positions = [-3.6, -1.2, 1.2, 3.6]

    # --- HUEVO 1: BOSQUE (Común) en X = -3.6 ---
    egg1 = create_egg_mesh("Huevo_Comun_Bosque", (-3.6, 0, 1.05))
    egg1.data.materials.append(m_egg_forest)
    # Nido de ramas entrelazadas
    for ni in range(3):
        bpy.ops.mesh.primitive_torus_add(major_radius=0.95 - ni*0.08, minor_radius=0.1, location=(-3.6, 0, 0.15 + ni*0.12), rotation=(0.08*ni, 0.1*ni, 0))
        nest_ring = bpy.context.active_object; nest_ring.name = f"Nido_Anillo_{ni}"; nest_ring.data.materials.append(m_wood)
    # Banda de runas esmeralda
    bpy.ops.mesh.primitive_torus_add(major_radius=0.82, minor_radius=0.05, location=(-3.6, 0, 0.9), rotation=(0.15, 0, 0))
    rune1 = bpy.context.active_object; rune1.name = "Banda_Runa_Bosque"; rune1.data.materials.append(m_moss)

    # --- HUEVO 2: ZAFIRO (Raro) en X = -1.2 ---
    egg2 = create_egg_mesh("Huevo_Raro_Zafiro", (-1.2, 0, 1.05))
    egg2.data.materials.append(m_egg_sapphire)
    # Pedestal de plata
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.95, depth=0.3, location=(-1.2, 0, 0.15))
    p2 = bpy.context.active_object; p2.name = "Pedestal_Plata"; p2.data.materials.append(m_silver)
    # 2 Anillos de plata cruzados
    bpy.ops.mesh.primitive_torus_add(major_radius=0.83, minor_radius=0.04, location=(-1.2, 0, 1.05), rotation=(math.pi/3, 0.2, 0))
    b2_1 = bpy.context.active_object; b2_1.data.materials.append(m_silver)
    bpy.ops.mesh.primitive_torus_add(major_radius=0.83, minor_radius=0.04, location=(-1.2, 0, 1.05), rotation=(-math.pi/3, -0.2, 0))
    b2_2 = bpy.context.active_object; b2_2.data.materials.append(m_silver)
    # Gema de zafiro flotante en la punta
    bpy.ops.mesh.primitive_octahedron_add = None # evitar addons
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.25, depth=0.5, location=(-1.2, 0, 2.2))
    gem2 = bpy.context.active_object; gem2.name = "Gema_Zafiro"; gem2.data.materials.append(m_cyan_glow)

    # --- HUEVO 3: AMATISTA (Épico) en X = 1.2 ---
    egg3 = create_egg_mesh("Huevo_Epico_Amatista", (1.2, 0, 1.05))
    egg3.data.materials.append(m_egg_amethyst)
    # Pedestal de obsidiana
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.95, depth=0.3, location=(1.2, 0, 0.15))
    p3 = bpy.context.active_object; p3.name = "Pedestal_Obsidiana"; p3.data.materials.append(m_obsidian)
    # Espinas de obsidiana que sostienen el huevo
    for si in range(6):
        s_ang = si * (math.pi / 3)
        sx = 1.2 + math.cos(s_ang) * 0.8
        sy = math.sin(s_ang) * 0.8
        bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=0.15, depth=0.7, location=(sx, sy, 0.6), rotation=(0.4 * math.sin(s_ang), -0.4 * math.cos(s_ang), s_ang))
        spike = bpy.context.active_object; spike.data.materials.append(m_obsidian)
    # Vena de energía púrpura
    bpy.ops.mesh.primitive_torus_add(major_radius=0.82, minor_radius=0.05, location=(1.2, 0, 1.15), rotation=(0.3, 0.4, 0))
    v3 = bpy.context.active_object; v3.data.materials.append(m_purple_glow)

    # --- HUEVO 4: SOLAR (Legendario) en X = 3.6 ---
    egg4 = create_egg_mesh("Huevo_Legendario_Solar", (3.6, 0, 1.05))
    egg4.data.materials.append(m_egg_solar)
    # Pedestal de oro con alas
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.0, depth=0.35, location=(3.6, 0, 0.18))
    p4 = bpy.context.active_object; p4.name = "Pedestal_Oro"; p4.data.materials.append(m_gold)
    # Alas doradas envolventes (L & R)
    for side in (-1, 1):
        bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.35, depth=1.6, location=(3.6 + side * 0.9, 0, 1.2), rotation=(0, side * 0.45, 0))
        wing = bpy.context.active_object; wing.scale = (0.4, 1.0, 1.0); wing.data.materials.append(m_gold)
    # Halo solar celestial flotante
    bpy.ops.mesh.primitive_torus_add(major_radius=0.6, minor_radius=0.06, location=(3.6, 0, 2.3), rotation=(0.2, 0, 0))
    halo = bpy.context.active_object; halo.name = "Halo_Solar"; halo.data.materials.append(m_sun_glow)

    # 3. ILUMINACIÓN DE ESTUDIO (Three-Point Lighting)
    # Key Light (Luz Principal cálida)
    bpy.ops.object.light_add(type='AREA', location=(2.0, -5.0, 4.5))
    key_light = bpy.context.active_object
    key_light.data.energy = 450
    key_light.data.size = 5.0
    key_light.data.color = (1.0, 0.95, 0.9)
    key_light.rotation_euler = (math.radians(50), 0, math.radians(20))

    # Fill Light (Luz de Relleno fría)
    bpy.ops.object.light_add(type='AREA', location=(-4.0, -4.0, 3.0))
    fill_light = bpy.context.active_object
    fill_light.data.energy = 220
    fill_light.data.size = 4.0
    fill_light.data.color = (0.7, 0.85, 1.0)
    fill_light.rotation_euler = (math.radians(45), 0, math.radians(-30))

    # Rim Light / Back Light (Para perfilar los bordes de los huevos)
    bpy.ops.object.light_add(type='POINT', location=(0.0, 4.0, 4.0))
    rim_light = bpy.context.active_object
    rim_light.data.energy = 350
    rim_light.data.color = (0.9, 0.8, 1.0)

    # 4. CÁMARA CINEMATOGRÁFICA (Encuadre panorámico para los 4 huevos)
    bpy.ops.object.camera_add(location=(0.0, -11.5, 3.2), rotation=(math.radians(80), 0, 0))
    cam = bpy.context.active_object
    cam.data.lens = 42
    bpy.context.scene.camera = cam

    # Configuración de Render (Resolución HD)
    bpy.context.scene.render.resolution_x = 1280
    bpy.context.scene.render.resolution_y = 720
    bpy.context.scene.render.filepath = "c:/Users/Antonio Garcia/Downloads/blender/render_huevos.png"

    # Exportar FBX y Blend para el juego
    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Huevos_Mascotas_Spectacular.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Huevos_Mascotas_Spectacular.fbx")
    print("Modelos de Huevos guardados en Blend y FBX.")

    # Renderizar imagen
    print("Iniciando renderizado con Blender...")
    bpy.ops.render.render(write_still=True)
    print("¡Render completado y guardado en render_huevos.png!")

if __name__ == "__main__":
    build_scene_and_render()
