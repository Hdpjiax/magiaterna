"""
model_epic_dungeon_universe.py
Generador maestro de assets 3D de Mazmorra para Magia Eterna en Blender 5.3:
- Puerta Rúnica de Mazmorra (Arcos de piedra tallada, batientes de roble con herrajes y runas)
- Cofre del Tesoro Deluxe (Caja con refuerzos dorados, tapa abovedada articulada, botín interior brillante)
- Slime Verde Épico (Gota orgánica, núcleo flotante, ojos expresivos)
- Duende Mágico (Goblin hechicero con orejas largas, capucha púrpura, túnica y báculo arcano)
- Lobo Mágico (Hocico lupino, melena espinosa, patas musculosas, cola y runas tribales)
- Guardián de Raíces Mini-Jefe (Gólem colosal con hombreras de roca, pecho de raíces y núcleo esmeralda)
- Treant Ancestral Jefe Final (Titán arbóreo ancestral con fisura ardiente, cornamenta de ramas y follaje)

Exporta cada uno a .blend y .fbx con jerarquías limpias (parented a Root Empty).
Genera un render cinematográfico panorámico: render_dungeon_epic_assets.png
"""

import bpy
import math

def clear_all():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def make_material(name, color, roughness=0.5, metallic=0.0, emission=None, emission_str=0.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = color
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
        if emission and emission_str > 0:
            if 'Emission Color' in bsdf.inputs:
                bsdf.inputs['Emission Color'].default_value = emission
                bsdf.inputs['Emission Strength'].default_value = emission_str
            elif 'Emission' in bsdf.inputs:
                bsdf.inputs['Emission'].default_value = emission
    return mat

def create_puerta_asset():
    clear_all()
    root = bpy.data.objects.new("Puerta_Mazmorra_Root", None)
    bpy.context.scene.collection.objects.link(root)

    mat_stone = make_material("Stone_Runic", (0.25, 0.26, 0.3, 1.0), roughness=0.85)
    mat_wood = make_material("Timber_Dark", (0.22, 0.13, 0.07, 1.0), roughness=0.7)
    mat_iron = make_material("Forged_Iron", (0.08, 0.08, 0.1, 1.0), roughness=0.35, metallic=0.85)
    mat_gold = make_material("Runic_Gold", (0.9, 0.75, 0.2, 1.0), roughness=0.3, metallic=0.8)
    mat_rune = make_material("Cyan_Energy", (0.1, 0.9, 1.0, 1.0), roughness=0.1, emission=(0.1, 0.95, 1.0, 1.0), emission_str=5.0)

    # Pilares de piedra laterales
    for sign, name in [(-1, "Left"), (1, "Right")]:
        # Base pilar
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sign * 3.8, 0, 0.6))
        pb = bpy.context.active_object
        pb.scale = (1.8, 2.0, 1.2)
        pb.data.materials.append(mat_stone)
        pb.parent = root

        # Fuste pilar
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sign * 3.8, 0, 4.4))
        pf = bpy.context.active_object
        pf.scale = (1.4, 1.6, 6.4)
        pf.data.materials.append(mat_stone)
        pf.parent = root

        # Runa tallada en el pilar
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sign * 3.8, -0.85, 4.4))
        pr = bpy.context.active_object
        pr.scale = (0.3, 0.1, 3.2)
        pr.data.materials.append(mat_rune)
        pr.parent = root

        # Capitel superior
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sign * 3.8, 0, 7.8))
        pc = bpy.context.active_object
        pc.scale = (1.8, 2.0, 0.8)
        pc.data.materials.append(mat_stone)
        pc.parent = root

    # Dintel / Arco superior
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 8.5))
    arch = bpy.context.active_object
    arch.scale = (9.4, 2.2, 1.6)
    arch.data.materials.append(mat_stone)
    arch.parent = root

    # Medallón central rúnico
    bpy.ops.mesh.primitive_cylinder_add(radius=1.1, depth=0.5, location=(0, -1.15, 8.5), rotation=(math.radians(90), 0, 0))
    emblem = bpy.context.active_object
    emblem.data.materials.append(mat_gold)
    emblem.parent = root

    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.6, location=(0, -1.35, 8.5))
    gem = bpy.context.active_object
    gem.data.materials.append(mat_rune)
    gem.parent = root

    # Puertas de Madera con Bisagras de Hierro
    # Hoja Izquierda
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-1.5, 0, 3.8))
    door_l = bpy.context.active_object
    door_l.name = "Door_Leaf_Left"
    door_l.scale = (2.9, 0.45, 7.4)
    door_l.data.materials.append(mat_wood)
    door_l.parent = root

    # Bandas de hierro en la puerta izquierda
    for z_pos in [1.5, 3.8, 6.2]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-1.5, -0.26, z_pos))
        strap = bpy.context.active_object
        strap.scale = (2.85, 0.12, 0.4)
        strap.data.materials.append(mat_iron)
        strap.parent = root

    # Hoja Derecha
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(1.5, 0, 3.8))
    door_r = bpy.context.active_object
    door_r.name = "Door_Leaf_Right"
    door_r.scale = (2.9, 0.45, 7.4)
    door_r.data.materials.append(mat_wood)
    door_r.parent = root

    # Bandas de hierro en la puerta derecha
    for z_pos in [1.5, 3.8, 6.2]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(1.5, -0.26, z_pos))
        strap = bpy.context.active_object
        strap.scale = (2.85, 0.12, 0.4)
        strap.data.materials.append(mat_iron)
        strap.parent = root

    # Barrera mágica rúnica central
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 3.8))
    barrier = bpy.context.active_object
    barrier.name = "Runic_Barrier_Field"
    barrier.scale = (6.0, 0.1, 7.4)
    barrier.data.materials.append(mat_rune)
    barrier.parent = root

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Puerta_Mazmorra_Runic.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Puerta_Mazmorra_Runic.fbx")
    print("Puerta Mazmorra exportada.")

def create_cofre_asset():
    clear_all()
    root = bpy.data.objects.new("Cofre_Deluxe_Root", None)
    bpy.context.scene.collection.objects.link(root)

    mat_wood = make_material("Chest_Mahogany", (0.3, 0.16, 0.08, 1.0), roughness=0.65)
    mat_gold = make_material("Chest_Gold_Trim", (0.95, 0.78, 0.2, 1.0), roughness=0.25, metallic=0.9)
    mat_iron = make_material("Chest_Iron_Trim", (0.1, 0.1, 0.12, 1.0), roughness=0.4, metallic=0.85)
    mat_ruby = make_material("Chest_Ruby_Gem", (0.9, 0.05, 0.15, 1.0), roughness=0.1, emission=(1.0, 0.1, 0.2, 1.0), emission_str=4.0)
    mat_loot = make_material("Loot_Gold_Glow", (1.0, 0.9, 0.3, 1.0), roughness=0.2, emission=(1.0, 0.85, 0.2, 1.0), emission_str=6.0)

    # Base del cofre
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.75))
    base = bpy.context.active_object
    base.name = "Chest_Box"
    base.scale = (2.6, 1.7, 1.3)
    base.data.materials.append(mat_wood)
    base.parent = root

    # Bandas y esquinas doradas
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.75))
    trim = bpy.context.active_object
    trim.scale = (2.66, 1.76, 0.3)
    trim.data.materials.append(mat_gold)
    trim.parent = root

    # Pies de garra del cofre
    for cx in [-1.15, 1.15]:
        for cy in [-0.7, 0.7]:
            bpy.ops.mesh.primitive_cylinder_add(radius=0.22, depth=0.25, location=(cx, cy, 0.1))
            foot = bpy.context.active_object
            foot.data.materials.append(mat_iron)
            foot.parent = root

    # Cerradura dorada con gema
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.9, 1.2))
    lock = bpy.context.active_object
    lock.scale = (0.5, 0.12, 0.5)
    lock.data.materials.append(mat_gold)
    lock.parent = root

    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.14, location=(0, -0.98, 1.2))
    gem = bpy.context.active_object
    gem.data.materials.append(mat_ruby)
    gem.parent = root

    # Botín interior resplandeciente
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.25))
    loot = bpy.context.active_object
    loot.scale = (2.2, 1.3, 0.4)
    loot.data.materials.append(mat_loot)
    loot.parent = root

    # Tapa Abombada
    bpy.ops.mesh.primitive_cylinder_add(radius=0.88, depth=2.64, location=(0, 0, 1.45), rotation=(0, math.radians(90), 0))
    lid = bpy.context.active_object
    lid.name = "Chest_Lid"
    lid.scale = (1.0, 1.0, 0.65)
    lid.data.materials.append(mat_wood)
    lid.parent = root

    # Costillas doradas de la tapa
    for rx in [-1.2, 0, 1.2]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.91, depth=0.2, location=(rx, 0, 1.45), rotation=(0, math.radians(90), 0))
        rib = bpy.context.active_object
        rib.scale = (1.0, 1.0, 0.67)
        rib.data.materials.append(mat_gold)
        rib.parent = root

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Cofre_Ancestral_Deluxe.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Cofre_Ancestral_Deluxe.fbx")
    print("Cofre Deluxe exportado.")

def create_slime_asset():
    clear_all()
    root = bpy.data.objects.new("Slime_Verde_Root", None)
    bpy.context.scene.collection.objects.link(root)

    mat_slime = make_material("Slime_Goo", (0.1, 0.88, 0.28, 0.85), roughness=0.15, metallic=0.05)
    mat_core = make_material("Slime_Core_Glow", (0.4, 1.0, 0.5, 1.0), roughness=0.1, emission=(0.4, 1.0, 0.5, 1.0), emission_str=5.0)
    mat_eye = make_material("Slime_Eye_Pupil", (0.05, 0.05, 0.08, 1.0), roughness=0.1)
    mat_white = make_material("Slime_Eye_White", (1.0, 1.0, 1.0, 1.0), roughness=0.1)

    # Cuerpo orgánico redondeado en gota
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1.3, location=(0, 0, 1.0))
    body = bpy.context.active_object
    body.name = "Slime_Body"
    body.scale = (1.3, 1.3, 0.95)
    bpy.ops.object.shade_smooth()
    body.data.materials.append(mat_slime)
    body.parent = root

    # Pico superior de gelatina
    bpy.ops.mesh.primitive_cone_add(radius1=0.7, radius2=0.05, depth=0.9, location=(0, 0, 2.1))
    tip = bpy.context.active_object
    tip.scale = (0.9, 0.9, 1.0)
    bpy.ops.object.shade_smooth()
    tip.data.materials.append(mat_slime)
    tip.parent = root

    # Núcleo interior palpitante
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=0.5, location=(0, 0, 1.0))
    core = bpy.context.active_object
    core.data.materials.append(mat_core)
    core.parent = root

    # Ojos grandes expresivos
    for sign in [-1, 1]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.22, location=(sign * 0.45, -1.15, 1.15))
        eye = bpy.context.active_object
        eye.scale = (1.0, 0.5, 1.25)
        eye.data.materials.append(mat_eye)
        eye.parent = root

        # Reflejo especular
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.07, location=(sign * 0.52, -1.25, 1.3))
        shine = bpy.context.active_object
        shine.data.materials.append(mat_white)
        shine.parent = root

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Slime_Verde_Epico.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Slime_Verde_Epico.fbx")
    print("Slime Verde exportado.")

def create_duende_asset():
    clear_all()
    root = bpy.data.objects.new("Duende_Magico_Root", None)
    bpy.context.scene.collection.objects.link(root)

    mat_skin = make_material("Goblin_Skin", (0.35, 0.72, 0.28, 1.0), roughness=0.6)
    mat_robe = make_material("Mage_Robe", (0.35, 0.12, 0.45, 1.0), roughness=0.8)
    mat_gold = make_material("Gold_Trim", (0.9, 0.75, 0.2, 1.0), roughness=0.3, metallic=0.8)
    mat_wood = make_material("Staff_Bark", (0.28, 0.16, 0.08, 1.0), roughness=0.8)
    mat_gem = make_material("Mana_Gem", (0.1, 0.9, 1.0, 1.0), roughness=0.1, emission=(0.1, 0.9, 1.0, 1.0), emission_str=6.0)

    # Túnica acampanada
    bpy.ops.mesh.primitive_cone_add(radius1=0.95, radius2=0.35, depth=1.8, location=(0, 0, 0.9))
    robe = bpy.context.active_object
    robe.data.materials.append(mat_robe)
    robe.parent = root

    # Cinturón con hebilla dorada
    bpy.ops.mesh.primitive_torus_add(major_radius=0.6, minor_radius=0.08, location=(0, 0, 0.9))
    belt = bpy.context.active_object
    belt.data.materials.append(mat_gold)
    belt.parent = root

    # Cabeza de Duende
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.55, location=(0, 0, 2.05))
    head = bpy.context.active_object
    head.scale = (1.0, 0.9, 1.0)
    head.data.materials.append(mat_skin)
    head.parent = root

    # Nariz aguileña característica
    bpy.ops.mesh.primitive_cone_add(radius1=0.15, radius2=0.02, depth=0.45, location=(0, -0.65, 2.05), rotation=(math.radians(90), 0, 0))
    nose = bpy.context.active_object
    nose.data.materials.append(mat_skin)
    nose.parent = root

    # Orejas largas puntiagudas goblin
    for sign in [-1, 1]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.18, radius2=0.01, depth=0.85, location=(sign * 0.75, 0, 2.15), rotation=(0, math.radians(sign * 70), math.radians(-15)))
        ear = bpy.context.active_object
        ear.data.materials.append(mat_skin)
        ear.parent = root

        # Ojos amarillos malévolos
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.1, location=(sign * 0.22, -0.5, 2.18))
        eye = bpy.context.active_object
        mat_yellow = make_material("Goblin_Eye", (1.0, 0.85, 0.1, 1.0), emission=(1.0, 0.8, 0.1, 1.0), emission_str=2.0)
        eye.data.materials.append(mat_yellow)
        eye.parent = root

    # Sombrero cónico de mago
    bpy.ops.mesh.primitive_cone_add(radius1=0.75, radius2=0.05, depth=1.1, location=(0, 0.12, 2.75), rotation=(math.radians(-22), 0, 0))
    hat = bpy.context.active_object
    hat.data.materials.append(mat_robe)
    hat.parent = root

    # Báculo Mágico de Madera
    bpy.ops.mesh.primitive_cylinder_add(radius=0.07, depth=2.8, location=(0.85, -0.4, 1.4))
    staff = bpy.context.active_object
    staff.data.materials.append(mat_wood)
    staff.parent = root

    # Garra que sujeta el cristal
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.35, location=(0.85, -0.4, 2.9))
    gem = bpy.context.active_object
    gem.data.materials.append(mat_gem)
    gem.parent = root

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Duende_Magico_Epico.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Duende_Magico_Epico.fbx")
    print("Duende Mágico exportado.")

def create_lobo_asset():
    clear_all()
    root = bpy.data.objects.new("Lobo_Magico_Root", None)
    bpy.context.scene.collection.objects.link(root)

    mat_fur = make_material("Wolf_Pelt", (0.16, 0.2, 0.28, 1.0), roughness=0.8)
    mat_mane = make_material("Wolf_Mane_Spikes", (0.08, 0.1, 0.16, 1.0), roughness=0.9)
    mat_rune = make_material("Wolf_Cyan_Runes", (0.2, 0.9, 1.0, 1.0), roughness=0.1, emission=(0.2, 0.9, 1.0, 1.0), emission_str=5.0)

    # Torso lupino musculoso
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.35))
    torso = bpy.context.active_object
    torso.scale = (0.9, 2.4, 1.0)
    bpy.ops.object.shade_smooth()
    torso.data.materials.append(mat_fur)
    torso.parent = root

    # Melena espinosa en cuello y pecho
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.8, location=(0, -1.1, 1.75))
    mane = bpy.context.active_object
    mane.scale = (1.2, 1.3, 1.4)
    bpy.ops.object.shade_smooth()
    mane.data.materials.append(mat_mane)
    mane.parent = root

    # Cabeza
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -1.8, 2.0))
    head = bpy.context.active_object
    head.scale = (0.7, 0.8, 0.7)
    head.data.materials.append(mat_fur)
    head.parent = root

    # Hocico alargado
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -2.4, 1.85))
    snout = bpy.context.active_object
    snout.scale = (0.42, 0.7, 0.42)
    snout.data.materials.append(mat_fur)
    snout.parent = root

    # Orejas puntiagudas
    for sign in [-1, 1]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.18, radius2=0.02, depth=0.5, location=(sign * 0.32, -1.8, 2.5), rotation=(0, math.radians(sign * 18), 0))
        ear = bpy.context.active_object
        ear.data.materials.append(mat_mane)
        ear.parent = root

        # Ojos brillantes
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.1, location=(sign * 0.28, -2.15, 2.05))
        eye = bpy.context.active_object
        eye.data.materials.append(mat_rune)
        eye.parent = root

    # 4 Patas musculosas
    for lx, ly in [(-0.4, -0.9), (0.4, -0.9), (-0.4, 0.9), (0.4, 0.9)]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.16, depth=1.4, location=(lx, ly, 0.7))
        leg = bpy.context.active_object
        leg.data.materials.append(mat_fur)
        leg.parent = root

        # Garras/pezuñas
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(lx, ly - 0.1, 0.15))
        paw = bpy.context.active_object
        paw.scale = (0.35, 0.45, 0.25)
        paw.data.materials.append(mat_mane)
        paw.parent = root

    # Cola lupina arqueada
    bpy.ops.mesh.primitive_cylinder_add(radius=0.14, depth=1.6, location=(0, 1.5, 1.5), rotation=(math.radians(50), 0, 0))
    tail = bpy.context.active_object
    tail.data.materials.append(mat_mane)
    tail.parent = root

    # Runas que brillan a lo largo del lomo
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.9))
    rune = bpy.context.active_object
    rune.scale = (0.55, 1.8, 0.05)
    rune.data.materials.append(mat_rune)
    rune.parent = root

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Lobo_Magico_Epico.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Lobo_Magico_Epico.fbx")
    print("Lobo Mágico exportado.")

def create_guardian_asset():
    clear_all()
    root = bpy.data.objects.new("Guardian_Raices_Root", None)
    bpy.context.scene.collection.objects.link(root)

    mat_wood = make_material("Root_Wood", (0.26, 0.16, 0.09, 1.0), roughness=0.85)
    mat_stone = make_material("Ancient_Rock", (0.4, 0.42, 0.45, 1.0), roughness=0.9)
    mat_moss = make_material("Moss_Green", (0.15, 0.38, 0.12, 1.0), roughness=0.95)
    mat_core = make_material("Guardian_Core", (0.2, 1.0, 0.45, 1.0), roughness=0.1, emission=(0.2, 1.0, 0.5, 1.0), emission_str=6.0)

    # Torso de raíces
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 3.2))
    torso = bpy.context.active_object
    torso.scale = (2.4, 1.8, 2.6)
    bpy.ops.object.shade_smooth()
    torso.data.materials.append(mat_wood)
    torso.parent = root

    # Placa pectoral de roca
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.95, 3.4))
    chest = bpy.context.active_object
    chest.scale = (1.8, 0.3, 2.0)
    chest.data.materials.append(mat_stone)
    chest.parent = root

    # Núcleo de maná esmeralda en el pecho
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=0.55, location=(0, -1.15, 3.4))
    core = bpy.context.active_object
    core.data.materials.append(mat_core)
    core.parent = root

    # Hombreras colosales de roca con musgo
    for sign in [-1, 1]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=1.1, location=(sign * 2.1, 0, 4.3))
        pauldron = bpy.context.active_object
        pauldron.scale = (1.2, 1.1, 0.9)
        pauldron.data.materials.append(mat_stone)
        pauldron.parent = root

        # Musgo en hombro
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sign * 2.1, 0, 5.0))
        moss = bpy.context.active_object
        moss.scale = (1.1, 1.0, 0.2)
        moss.data.materials.append(mat_moss)
        moss.parent = root

        # Brazo pesado
        bpy.ops.mesh.primitive_cylinder_add(radius=0.5, depth=2.8, location=(sign * 2.1, 0, 2.3))
        arm = bpy.context.active_object
        arm.data.materials.append(mat_wood)
        arm.parent = root

        # Puño de roca
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sign * 2.1, -0.3, 0.8))
        fist = bpy.context.active_object
        fist.scale = (1.2, 1.3, 1.2)
        fist.data.materials.append(mat_stone)
        fist.parent = root

    # Cabeza monolítica esculpida
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.2, 4.8))
    head = bpy.context.active_object
    head.scale = (1.4, 1.3, 1.1)
    head.data.materials.append(mat_stone)
    head.parent = root

    # Visor de ojos rúnico horizontal
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.9, 4.8))
    eye = bpy.context.active_object
    eye.scale = (1.0, 0.1, 0.22)
    eye.data.materials.append(mat_core)
    eye.parent = root

    # Piernas de tronco ancestral
    for sign in [-1, 1]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.6, depth=2.0, location=(sign * 0.85, 0, 1.0))
        leg = bpy.context.active_object
        leg.data.materials.append(mat_wood)
        leg.parent = root

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Guardian_Raices_Epico.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Guardian_Raices_Epico.fbx")
    print("Guardián de Raíces exportado.")

def create_treant_asset():
    clear_all()
    root = bpy.data.objects.new("Treant_Ancestral_Root", None)
    bpy.context.scene.collection.objects.link(root)

    mat_bark = make_material("Ancient_Bark", (0.2, 0.12, 0.07, 1.0), roughness=0.92)
    mat_leaves = make_material("Treant_Leaves", (0.85, 0.42, 0.1, 1.0), roughness=0.75)
    mat_glow = make_material("Treant_Lava_Core", (1.0, 0.15, 0.05, 1.0), roughness=0.1, emission=(1.0, 0.2, 0.05, 1.0), emission_str=6.0)

    # Tronco Titánico
    bpy.ops.mesh.primitive_cylinder_add(radius=2.5, depth=7.5, location=(0, 0, 3.75))
    trunk = bpy.context.active_object
    trunk.scale = (1.2, 1.0, 1.0)
    bpy.ops.object.shade_smooth()
    trunk.data.materials.append(mat_bark)
    trunk.parent = root

    # Raíces masivas de anclaje al suelo
    for ang in [30, 90, 150, 210, 270, 330]:
        rad = math.radians(ang)
        rx = math.cos(rad) * 2.8
        ry = math.sin(rad) * 2.8
        bpy.ops.mesh.primitive_cylinder_add(radius=0.6, depth=3.0, location=(rx, ry, 0.8), rotation=(math.radians(25), 0, rad))
        r_part = bpy.context.active_object
        r_part.data.materials.append(mat_bark)
        r_part.parent = root

    # Fisura del corazón de magma/corrupción en el pecho
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -1.2, 4.2))
    fissure = bpy.context.active_object
    fissure.scale = (1.0, 0.35, 2.2)
    fissure.data.materials.append(mat_glow)
    fissure.parent = root

    # Cabeza ancestral de ceño temible
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.4, 8.0))
    head = bpy.context.active_object
    head.scale = (2.2, 2.0, 1.8)
    head.data.materials.append(mat_bark)
    head.parent = root

    # Ojos ígneos
    for sign in [-1, 1]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sign * 0.7, -1.45, 8.2))
        eye = bpy.context.active_object
        eye.scale = (0.45, 0.15, 0.25)
        eye.data.materials.append(mat_glow)
        eye.parent = root

    # Cornamenta de ramas gigantescas
    for sign in [-1, 1]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.55, depth=5.0, location=(sign * 2.6, 0, 10.2), rotation=(0, math.radians(sign * 38), math.radians(sign * -15)))
        branch = bpy.context.active_object
        branch.data.materials.append(mat_bark)
        branch.parent = root

        # Copa de hojas otoñales brillantes
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=2.2, location=(sign * 4.2, 0, 12.0))
        crown = bpy.context.active_object
        crown.data.materials.append(mat_leaves)
        crown.parent = root

    # Brazos colosales
    for sign in [-1, 1]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.8, depth=6.0, location=(sign * 3.2, -0.6, 3.8), rotation=(math.radians(25), math.radians(sign * 18), 0))
        arm = bpy.context.active_object
        arm.data.materials.append(mat_bark)
        arm.parent = root

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Treant_Ancestral_Epico.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Treant_Ancestral_Epico.fbx")
    print("Treant Ancestral exportado.")

def render_master_showcase():
    clear_all()

    # Suelo reflectivo de estudio
    bpy.ops.mesh.primitive_cylinder_add(radius=30.0, depth=0.5, location=(0, 0, -0.25))
    floor = bpy.context.active_object
    mat_floor = make_material("Studio_Floor_Dark", (0.04, 0.05, 0.07, 1.0), roughness=0.3, metallic=0.2)
    floor.data.materials.append(mat_floor)

    # 3-Point Studio Lighting
    # Key Light principal
    bpy.ops.object.light_add(type='AREA', location=(0.0, -18.0, 12.0))
    key = bpy.context.active_object
    key.data.energy = 3500
    key.data.size = 18.0
    key.rotation_euler = (math.radians(55), 0, 0)

    # Fill Light lateral suave
    bpy.ops.object.light_add(type='AREA', location=(-16.0, -12.0, 9.0))
    fill = bpy.context.active_object
    fill.data.energy = 1200
    fill.data.size = 12.0
    fill.data.color = (0.7, 0.85, 1.0)

    # Rim / Backlight
    bpy.ops.object.light_add(type='POINT', location=(0.0, 16.0, 14.0))
    rim = bpy.context.active_object
    rim.data.energy = 2200
    rim.data.color = (1.0, 0.92, 0.8)

    # Cámara Panorámica
    bpy.ops.object.camera_add(location=(0.0, -26.0, 8.5), rotation=(math.radians(78), 0, 0))
    cam = bpy.context.active_object
    cam.data.lens = 32
    bpy.context.scene.camera = cam

    # Resolución HD
    bpy.context.scene.render.resolution_x = 1280
    bpy.context.scene.render.resolution_y = 720
    bpy.context.scene.render.filepath = "c:/Users/Antonio Garcia/Downloads/blender/render_dungeon_epic_assets.png"

    # Lista de modelos a cargar y su posición en la alineación
    # De izquierda a derecha:
    # 1. Puerta Rúnica (-11)
    # 2. Slime Verde (-6.5)
    # 3. Duende Mágico (-3.5)
    # 4. Cofre Deluxe (0)
    # 5. Lobo Mágico (3.5)
    # 6. Guardián de Raíces (7.0)
    # 7. Treant Ancestral (12.0)
    lineup = [
        ("Puerta_Mazmorra_Runic.fbx", (-11.0, 0, 0), (0.7, 0.7, 0.7)),
        ("Slime_Verde_Epico.fbx", (-6.5, -2.5, 0), (1.1, 1.1, 1.1)),
        ("Duende_Magico_Epico.fbx", (-3.5, -2.0, 0), (1.1, 1.1, 1.1)),
        ("Cofre_Ancestral_Deluxe.fbx", (0.0, -3.0, 0), (1.1, 1.1, 1.1)),
        ("Lobo_Magico_Epico.fbx", (3.5, -2.0, 0), (1.1, 1.1, 1.1)),
        ("Guardian_Raices_Epico.fbx", (7.0, -0.5, 0), (0.85, 0.85, 0.85)),
        ("Treant_Ancestral_Epico.fbx", (12.0, 2.0, 0), (0.7, 0.7, 0.7)),
    ]

    for fname, (px, py, pz), (sx, sy, sz) in lineup:
        path = f"c:/Users/Antonio Garcia/Downloads/blender/{fname}"
        # Crear un Empty para agrupar este FBX
        grp = bpy.data.objects.new(f"Group_{fname}", None)
        bpy.context.scene.collection.objects.link(grp)
        grp.location = (px, py, pz)
        grp.scale = (sx, sy, sz)

        # Seleccionar sólo los nuevos importados
        before = set(bpy.context.scene.objects)
        bpy.ops.import_scene.fbx(filepath=path)
        after = set(bpy.context.scene.objects)
        new_objs = after - before

        for obj in new_objs:
            if obj.parent is None:
                obj.parent = grp

    print("Renderizando showcase maestro...")
    bpy.ops.render.render(write_still=True)
    print("¡Showcase maestro guardado en render_dungeon_epic_assets.png!")

if __name__ == "__main__":
    create_puerta_asset()
    create_cofre_asset()
    create_slime_asset()
    create_duende_asset()
    create_lobo_asset()
    create_guardian_asset()
    create_treant_asset()
    render_master_showcase()
