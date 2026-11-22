"""
model_deluxe_shop.py
Modelado 3D de la Tienda / Pabellón de Mascotas y Monedas en Blender 5.3:
- Puesto de comerciante de fantasía estilizado (madera, piedra, telas, vitrina)
- Toldo arqueado con cenefa
- Estantería con frascos de pociones luminiscentes (Salud, Maná, Esencia)
- Nido de exposición de Huevo Mágico
- Cofrecillo con monedas de oro en el mostrador
- Farol colgante de hierro con luz cálida
Renderiza en alta definición (1280x720): render_tienda_deluxe.png
Exporta FBX y BLEND: Tienda_Pabellon_Deluxe.blend / .fbx
"""

import bpy
import math

def clean_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def create_mat(name, color, roughness=0.5, metallic=0.0, emission_color=None, emission_strength=0.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = color
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
        if emission_color and emission_strength > 0:
            if 'Emission Color' in bsdf.inputs:
                bsdf.inputs['Emission Color'].default_value = emission_color
                bsdf.inputs['Emission Strength'].default_value = emission_strength
            elif 'Emission' in bsdf.inputs:
                bsdf.inputs['Emission'].default_value = emission_color
    return mat

def build_shop():
    clean_scene()
    root = bpy.data.objects.new("Shop_Deluxe_Root", None)
    bpy.context.scene.collection.objects.link(root)

    mat_stone = create_mat("Shop_Cobblestone", (0.3, 0.32, 0.35, 1.0), roughness=0.9)
    mat_wood = create_mat("Shop_Oak", (0.32, 0.18, 0.09, 1.0), roughness=0.7)
    mat_darkwood = create_mat("Shop_DarkWood", (0.18, 0.1, 0.05, 1.0), roughness=0.8)
    mat_gold = create_mat("Shop_Gold", (0.95, 0.78, 0.2, 1.0), roughness=0.25, metallic=0.9)
    mat_cloth_red = create_mat("Shop_Cloth_Crimson", (0.8, 0.15, 0.2, 1.0), roughness=0.85)
    mat_cloth_gold = create_mat("Shop_Cloth_Gold", (0.95, 0.82, 0.25, 1.0), roughness=0.8)
    mat_potion_blue = create_mat("Potion_Mana", (0.1, 0.8, 1.0, 1.0), roughness=0.1, emission_color=(0.1, 0.9, 1.0, 1.0), emission_strength=4.0)
    mat_potion_red = create_mat("Potion_Health", (1.0, 0.1, 0.2, 1.0), roughness=0.1, emission_color=(1.0, 0.15, 0.2, 1.0), emission_strength=4.0)
    mat_egg_green = create_mat("Display_Egg", (0.2, 0.9, 0.4, 1.0), roughness=0.2)
    mat_lantern = create_mat("Lantern_Glass", (1.0, 0.9, 0.4, 1.0), roughness=0.1, emission_color=(1.0, 0.85, 0.3, 1.0), emission_strength=6.0)

    # 1. Base / Plataforma de Piedra
    bpy.ops.mesh.primitive_cylinder_add(radius=5.5, depth=0.4, location=(0, 0, 0.2))
    base = bpy.context.active_object
    base.data.materials.append(mat_stone)
    base.parent = root

    # 2. Mostrador Principal de Madera
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -1.2, 1.1))
    counter = bpy.context.active_object
    counter.scale = (5.2, 1.4, 1.6)
    counter.data.materials.append(mat_wood)
    counter.parent = root

    # Encimera de madera pulida
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -1.2, 1.95))
    counter_top = bpy.context.active_object
    counter_top.scale = (5.6, 1.7, 0.15)
    counter_top.data.materials.append(mat_darkwood)
    counter_top.parent = root

    # 3. Cuatro Columnas de Soporte
    post_coords = [(-2.4, -1.8), (2.4, -1.8), (-2.4, 1.8), (2.4, 1.8)]
    for px, py in post_coords:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.18, depth=4.2, location=(px, py, 2.3))
        post = bpy.context.active_object
        post.data.materials.append(mat_wood)
        post.parent = root

    # 4. Pared trasera y Estantería de Pociones
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 1.8, 2.2))
    backwall = bpy.context.active_object
    backwall.scale = (5.0, 0.3, 3.6)
    backwall.data.materials.append(mat_wood)
    backwall.parent = root

    # Balda de estantería
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 1.5, 2.4))
    shelf = bpy.context.active_object
    shelf.scale = (4.4, 0.5, 0.1)
    shelf.data.materials.append(mat_darkwood)
    shelf.parent = root

    # Pociones en la balda
    # Poción roja
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.25, location=(-1.2, 1.5, 2.7))
    pot1 = bpy.context.active_object
    pot1.data.materials.append(mat_potion_red)
    pot1.parent = root

    # Poción azul
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.25, location=(-0.5, 1.5, 2.7))
    pot2 = bpy.context.active_object
    pot2.data.materials.append(mat_potion_blue)
    pot2.parent = root

    # Nido con Huevo de Exposición en la estantería
    bpy.ops.mesh.primitive_torus_add(major_radius=0.35, minor_radius=0.08, location=(1.0, 1.5, 2.5))
    nest = bpy.context.active_object
    nest.data.materials.append(mat_wood)
    nest.parent = root

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.3, location=(1.0, 1.5, 2.75))
    egg = bpy.context.active_object
    egg.scale = (0.85, 0.85, 1.2)
    egg.data.materials.append(mat_egg_green)
    egg.parent = root

    # 5. Cofrecillo de Monedas en el mostrador
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-1.6, -1.2, 2.25))
    mini_chest = bpy.context.active_object
    mini_chest.scale = (0.7, 0.5, 0.4)
    mini_chest.data.materials.append(mat_wood)
    mini_chest.parent = root

    # Monedas de oro rebosando
    bpy.ops.mesh.primitive_cylinder_add(radius=0.25, depth=0.1, location=(-1.6, -1.2, 2.45))
    coins = bpy.context.active_object
    coins.data.materials.append(mat_gold)
    coins.parent = root

    # Letrero de Madera "TIENDA / SHOP"
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -2.1, 4.2))
    sign = bpy.context.active_object
    sign.scale = (2.8, 0.15, 0.7)
    sign.data.materials.append(mat_darkwood)
    sign.parent = root

    # 6. Techo / Toldo Arqueado a Rayas
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 4.6))
    roof = bpy.context.active_object
    roof.scale = (5.8, 4.4, 0.4)
    roof.data.materials.append(mat_cloth_red)
    roof.parent = root

    # Cenefa frontal del toldo (Festón dorado)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -2.2, 4.2))
    valance = bpy.context.active_object
    valance.scale = (5.8, 0.1, 0.5)
    valance.data.materials.append(mat_cloth_gold)
    valance.parent = root

    # 7. Farol Colgante Iluminado
    bpy.ops.mesh.primitive_cylinder_add(radius=0.03, depth=0.8, location=(2.6, -1.9, 3.8))
    hanger = bpy.context.active_object
    hanger.data.materials.append(mat_darkwood)
    hanger.parent = root

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.22, location=(2.6, -1.9, 3.3))
    lantern = bpy.context.active_object
    lantern.data.materials.append(mat_lantern)
    lantern.parent = root

    # Guardar .blend y exportar .fbx
    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Tienda_Pabellon_Deluxe.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Tienda_Pabellon_Deluxe.fbx")
    print("Tienda Pabellón Deluxe guardada en Blend y FBX.")

    # 8. ILUMINACIÓN Y CÁMARA PARA RENDER HD
    # Luz del farol (punto cálido)
    bpy.ops.object.light_add(type='POINT', location=(2.6, -1.9, 3.3))
    lamp_light = bpy.context.active_object
    lamp_light.data.energy = 450
    lamp_light.data.color = (1.0, 0.85, 0.4)

    # Key Light (frontal cálida)
    bpy.ops.object.light_add(type='AREA', location=(0.0, -8.0, 5.0))
    key = bpy.context.active_object
    key.data.energy = 1400
    key.data.size = 6.0
    key.rotation_euler = (math.radians(50), 0, 0)

    # Fill Light (lateral fría)
    bpy.ops.object.light_add(type='AREA', location=(-6.0, -5.0, 4.0))
    fill = bpy.context.active_object
    fill.data.energy = 600
    fill.data.size = 5.0
    fill.data.color = (0.7, 0.85, 1.0)

    # Rim Light (posterior)
    bpy.ops.object.light_add(type='POINT', location=(0.0, 6.0, 6.0))
    rim = bpy.context.active_object
    rim.data.energy = 800
    rim.data.color = (1.0, 0.95, 0.85)

    # Suelo oscuro de estudio
    bpy.ops.mesh.primitive_cylinder_add(radius=20.0, depth=0.2, location=(0, 0, -0.1))
    floor = bpy.context.active_object
    mat_floor = create_mat("Dark_Studio_Floor", (0.05, 0.06, 0.08, 1.0), roughness=0.4)
    floor.data.materials.append(mat_floor)

    # Cámara en perspectiva isométrica 3/4 panorámica
    bpy.ops.object.camera_add(location=(-6.5, -16.5, 6.8), rotation=(math.radians(70), 0, math.radians(-22)))
    cam = bpy.context.active_object
    cam.data.lens = 38
    bpy.context.scene.camera = cam

    # Configuración de Render HD
    bpy.context.scene.render.resolution_x = 1280
    bpy.context.scene.render.resolution_y = 720
    bpy.context.scene.render.filepath = "c:/Users/Antonio Garcia/Downloads/blender/render_tienda_deluxe.png"

    print("Renderizando Tienda Deluxe...")
    bpy.ops.render.render(write_still=True)
    print("¡Render completado en render_tienda_deluxe.png!")

if __name__ == "__main__":
    build_shop()
