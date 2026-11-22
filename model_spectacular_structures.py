"""
=============================================================================
MAGIA ETERNA — ESTRUCTURAS PRINCIPALES DEL LOBBY EN BLENDER 5.3
1. Monumento Central de Maná (Fuente sagrada y núcleo celestial)
2. Forja Real Medieval (Taller con mampostería, vigas de roble, chimenea y yunque)
3. Árbol Sagrado de Sakura y Tablón de Misiones
=============================================================================
"""
import bpy
import math

def clean_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def create_pbr_material(name, base_color, metallic=0.0, roughness=0.5, emission=None, emission_val=0.0):
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

def build_monumento_central():
    clean_scene()
    col = bpy.data.collections.new("Monumento_Central_Mana")
    bpy.context.scene.collection.children.link(col)
    
    mat_marble = create_pbr_material("M_Marmol_Blanco", (0.92, 0.92, 0.95, 1.0), roughness=0.25)
    mat_gold = create_pbr_material("M_Oro_Runico", (1.0, 0.82, 0.22, 1.0), metallic=0.95, roughness=0.15)
    mat_water = create_pbr_material("M_Agua_Mana", (0.1, 0.7, 0.9, 1.0), roughness=0.05, emission=(0.1, 0.6, 0.9, 1.0), emission_val=4.0)
    mat_core = create_pbr_material("M_Nucleo_Celeste", (0.2, 0.9, 1.0, 1.0), roughness=0.0, emission=(0.2, 0.9, 1.0, 1.0), emission_val=25.0)

    # Estanque de la fuente (radio 8m)
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=8.0, depth=0.8, location=(0, 0, 0.4))
    basin = bpy.context.active_object; basin.name = "Fuente_Pared_Exterior"; basin.data.materials.append(mat_marble); col.objects.link(basin)
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=7.4, depth=0.2, location=(0, 0, 0.7))
    water = bpy.context.active_object; water.name = "Fuente_Agua_Superficie"; water.data.materials.append(mat_water); col.objects.link(water)
    
    # Cuenca superior escalonada
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=4.5, depth=0.8, location=(0, 0, 1.8))
    basin_mid = bpy.context.active_object; basin_mid.name = "Fuente_Cuenca_Media"; basin_mid.data.materials.append(mat_marble); col.objects.link(basin_mid)
    
    # Pedestal central de la aguja
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=2.2, depth=3.5, location=(0, 0, 3.5))
    pedestal = bpy.context.active_object; pedestal.name = "Pedestal_Aguja"; pedestal.data.materials.append(mat_marble); col.objects.link(pedestal)
    
    # Aguja / Monolito central de cristal
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=1.4, depth=6.0, location=(0, 0, 8.0))
    spire = bpy.context.active_object; spire.name = "Aguja_Mana_Top"; spire.data.materials.append(mat_gold); col.objects.link(spire)
    
    # Núcleo celeste flotante
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=1.6, location=(0, 0, 11.5))
    core = bpy.context.active_object; core.name = "Nucleo_Mana_Celeste"; core.data.materials.append(mat_core); col.objects.link(core)

    # 4 Anillos orbitales giratorios
    for ri in range(3):
        bpy.ops.mesh.primitive_torus_add(major_radius=2.6 + ri*0.6, minor_radius=0.08, location=(0, 0, 11.5), rotation=(0.4 * ri, 0.6 * ri, 0))
        ring = bpy.context.active_object; ring.name = f"Anillo_Orbital_{ri}"; ring.data.materials.append(mat_gold); col.objects.link(ring)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Monumento_Central_Mana.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Monumento_Central_Mana.fbx")
    print("Monumento Central de Mana exportado con exito.")

def build_forja_real():
    clean_scene()
    col = bpy.data.collections.new("Forja_Real_Guildhouse")
    bpy.context.scene.collection.children.link(col)
    
    mat_stone = create_pbr_material("F_Piedra_Mamposteria", (0.35, 0.35, 0.38, 1.0), roughness=0.8)
    mat_timber = create_pbr_material("F_Madera_Roble", (0.42, 0.28, 0.16, 1.0), roughness=0.6)
    mat_slate = create_pbr_material("F_Pizarra_Tejado", (0.18, 0.20, 0.24, 1.0), roughness=0.5)
    mat_iron = create_pbr_material("F_Hierro_Yunque", (0.12, 0.12, 0.14, 1.0), metallic=0.9, roughness=0.3)
    mat_fire = create_pbr_material("F_Fuego_Forja", (1.0, 0.4, 0.05, 1.0), roughness=0.1, emission=(1.0, 0.45, 0.05, 1.0), emission_val=20.0)

    # Base de piedra del taller (12 x 8 x 4m)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 2.0))
    walls = bpy.context.active_object; walls.name = "Forja_Paredes_Piedra"; walls.scale = (12.0, 8.0, 4.0); walls.data.materials.append(mat_stone); col.objects.link(walls)

    # Vigas de roble esquineras
    for sx in (-6.0, 6.0):
        for sy in (-4.0, 4.0):
            bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx, sy, 2.0))
            post = bpy.context.active_object; post.name = f"Viga_Esquina_{sx}_{sy}"; post.scale = (0.6, 0.6, 4.2); post.data.materials.append(mat_timber); col.objects.link(post)

    # Tejado a dos aguas de pizarra con buhardilla
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 5.5), rotation=(0, 0.3, 0))
    roof = bpy.context.active_object; roof.name = "Forja_Techo_Pizarra"; roof.scale = (13.5, 9.5, 0.5); roof.data.materials.append(mat_slate); col.objects.link(roof)

    # Gran Chimenea de piedra (trasera derecha)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(4.5, 3.5, 4.5))
    chimney = bpy.context.active_object; chimney.name = "Forja_Chimenea"; chimney.scale = (2.2, 2.2, 7.0); chimney.data.materials.append(mat_stone); col.objects.link(chimney)

    # Hogar de la forja con ascuas ardientes
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(3.8, 1.5, 1.2))
    hearth = bpy.context.active_object; hearth.name = "Hogar_Forja"; hearth.scale = (2.0, 1.5, 1.2); hearth.data.materials.append(mat_stone); col.objects.link(hearth)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(3.8, 1.5, 1.6))
    fire = bpy.context.active_object; fire.name = "Ascuas_Fuego"; fire.scale = (1.4, 1.0, 0.3); fire.data.materials.append(mat_fire); col.objects.link(fire)

    # Yunque de forja sobre tocón
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.6, depth=0.8, location=(0, 0, 0.4))
    stump = bpy.context.active_object; stump.name = "Tocon_Yunque"; stump.data.materials.append(mat_timber); col.objects.link(stump)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.1))
    anvil = bpy.context.active_object; anvil.name = "Yunque_Acero"; anvil.scale = (1.4, 0.6, 0.5); anvil.data.materials.append(mat_iron); col.objects.link(anvil)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Forja_Real_Guildhouse.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Forja_Real_Guildhouse.fbx")
    print("Forja Real Guildhouse exportada con exito.")

if __name__ == "__main__":
    build_monumento_central()
    build_forja_real()
