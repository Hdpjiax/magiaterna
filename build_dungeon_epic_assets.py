"""
build_dungeon_epic_assets.py
Generador completo de modelos 3D en Blender 5.3 para Magia Eterna:
1. Puerta de Mazmorra Rúnica (Stone Arch + Puertas de madera reforzada y runas + Animación de apertura)
2. Cofre del Tesoro Ancestral Deluxe (Caja con herrajes + Tapa curvada + Candado + Animación de apertura)
3. Slime Verde Épico (Cúpula orgánica suave, núcleo mágico flotante, ojos estilizados + Animación bote/squash)
4. Duende Mágico (Cabeza estilizada con orejas largas puntiagudas, capucha/túnica de mago, bastón mágico con cristal)
5. Lobo Mágico (Cuerpo cuadrúpedo, hocico lupino, orejas alertas, melena espinosa, cola y marcas de runas)
6. Guardián de Raíces Mini-Jefe (Gólem con hombreras de roca, torso de raíces retorcidas, núcleo rúnico y puños pesados)
7. Treant Ancestral Jefe Final (Tronco monumental, fisura de corazón brillante, cornamenta de ramas y follaje otoñal)

Renderiza una imagen panorámica HD: render_dungeon_epic_assets.png
Exporta FBX y BLEND para cada uno y un pack consolidado.
"""

import bpy
import math

def clean_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def create_mat(name, color, roughness=0.5, metallic=0.0, emission_color=None, emission_strength=0.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
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

def create_puerta_runica():
    clean_scene()
    
    mat_stone = create_mat("Stone_Ancient", (0.28, 0.28, 0.32, 1.0), roughness=0.85)
    mat_wood = create_mat("Heavy_Timber", (0.22, 0.14, 0.08, 1.0), roughness=0.7)
    mat_iron = create_mat("Black_Iron", (0.1, 0.1, 0.12, 1.0), roughness=0.4, metallic=0.8)
    mat_rune = create_mat("Rune_Cyan", (0.1, 0.8, 1.0, 1.0), roughness=0.2, emission_color=(0.1, 0.9, 1.0, 1.0), emission_strength=4.0)

    # 1. Marco de Piedra
    # Columna Izquierda
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-3.2, 0, 4.0))
    col_l = bpy.context.active_object
    col_l.scale = (1.4, 1.6, 8.0)
    col_l.data.materials.append(mat_stone)

    # Columna Derecha
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(3.2, 0, 4.0))
    col_r = bpy.context.active_object
    col_r.scale = (1.4, 1.6, 8.0)
    col_r.data.materials.append(mat_stone)

    # Dintel / Arco superior
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 8.2))
    arch = bpy.context.active_object
    arch.scale = (8.0, 2.0, 1.4)
    arch.data.materials.append(mat_stone)

    # Emblema Rúnico Central en el dintel
    bpy.ops.mesh.primitive_cylinder_add(radius=0.8, depth=0.4, location=(0, -1.05, 8.2), rotation=(math.radians(90), 0, 0))
    emblem = bpy.context.active_object
    emblem.data.materials.append(mat_rune)

    # 2. Hoja Izquierda de la Puerta (Pivote en X = -2.5)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-1.25, 0, 3.8))
    door_l = bpy.context.active_object
    door_l.name = "Door_Left"
    door_l.scale = (2.4, 0.4, 7.2)
    door_l.data.materials.append(mat_wood)
    
    # Bisagras de hierro izquierda
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-1.25, -0.25, 6.0))
    hinge_l1 = bpy.context.active_object
    hinge_l1.scale = (2.2, 0.15, 0.3)
    hinge_l1.data.materials.append(mat_iron)

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-1.25, -0.25, 1.6))
    hinge_l2 = bpy.context.active_object
    hinge_l2.scale = (2.2, 0.15, 0.3)
    hinge_l2.data.materials.append(mat_iron)

    # 3. Hoja Derecha de la Puerta (Pivote en X = 2.5)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(1.25, 0, 3.8))
    door_r = bpy.context.active_object
    door_r.name = "Door_Right"
    door_r.scale = (2.4, 0.4, 7.2)
    door_r.data.materials.append(mat_wood)

    # Bisagras de hierro derecha
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(1.25, -0.25, 6.0))
    hinge_r1 = bpy.context.active_object
    hinge_r1.scale = (2.2, 0.15, 0.3)
    hinge_r1.data.materials.append(mat_iron)

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(1.25, -0.25, 1.6))
    hinge_r2 = bpy.context.active_object
    hinge_r2.scale = (2.2, 0.15, 0.3)
    hinge_r2.data.materials.append(mat_iron)

    # Animación de apertura (keyframes)
    # Puerta izquierda gira sobre Z
    door_l.rotation_mode = 'XYZ'
    door_l.keyframe_insert(data_path="rotation_euler", frame=1)
    door_l.rotation_euler = (0, 0, math.radians(-85))
    door_l.keyframe_insert(data_path="rotation_euler", frame=35)

    door_r.rotation_mode = 'XYZ'
    door_r.keyframe_insert(data_path="rotation_euler", frame=1)
    door_r.rotation_euler = (0, 0, math.radians(85))
    door_r.keyframe_insert(data_path="rotation_euler", frame=35)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Puerta_Mazmorra_Runic.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Puerta_Mazmorra_Runic.fbx")
    print("Puerta Mazmorra Rúnica guardada y exportada.")

def create_cofre_deluxe():
    clean_scene()
    
    mat_wood = create_mat("Chest_Oak", (0.35, 0.22, 0.12, 1.0), roughness=0.6)
    mat_gold = create_mat("Chest_Gold", (0.95, 0.78, 0.2, 1.0), roughness=0.3, metallic=0.9)
    mat_iron = create_mat("Chest_Iron", (0.15, 0.15, 0.18, 1.0), roughness=0.5, metallic=0.7)
    mat_glow = create_mat("Loot_Glow", (1.0, 0.9, 0.3, 1.0), roughness=0.1, emission_color=(1.0, 0.85, 0.2, 1.0), emission_strength=5.0)

    # Base del cofre
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.7))
    base = bpy.context.active_object
    base.name = "Chest_Base"
    base.scale = (2.4, 1.6, 1.4)
    base.data.materials.append(mat_wood)

    # Refuerzos de esquina dorados
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.7))
    trim = bpy.context.active_object
    trim.name = "Chest_Trim"
    trim.scale = (2.45, 1.65, 0.2)
    trim.data.materials.append(mat_gold)

    # Interior dorado brillante
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.1))
    gold_treasure = bpy.context.active_object
    gold_treasure.scale = (2.0, 1.3, 0.5)
    gold_treasure.data.materials.append(mat_glow)

    # Tapa Abombada (Lid) - Pivote en Y = 0.8, Z = 1.4
    bpy.ops.mesh.primitive_cylinder_add(radius=0.8, depth=2.45, location=(0, 0, 1.4), rotation=(0, math.radians(90), 0))
    lid = bpy.context.active_object
    lid.name = "Chest_Lid"
    lid.scale = (1.0, 1.0, 0.6)
    lid.data.materials.append(mat_wood)

    # Candado frontal
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.85, 1.35))
    lock = bpy.context.active_object
    lock.scale = (0.35, 0.15, 0.45)
    lock.data.materials.append(mat_gold)

    # Animación de Apertura
    lid.rotation_mode = 'XYZ'
    lid.keyframe_insert(data_path="rotation_euler", frame=1)
    lid.rotation_euler = (math.radians(-75), 0, 0)
    lid.keyframe_insert(data_path="rotation_euler", frame=25)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Cofre_Ancestral_Deluxe.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Cofre_Ancestral_Deluxe.fbx")
    print("Cofre Deluxe guardado y exportado.")

def create_slime_epico():
    clean_scene()
    mat_slime = create_mat("Slime_Gel", (0.1, 0.85, 0.25, 0.8), roughness=0.2, metallic=0.1)
    mat_core = create_mat("Slime_Core", (0.3, 1.0, 0.4, 1.0), roughness=0.1, emission_color=(0.4, 1.0, 0.5, 1.0), emission_strength=4.0)
    mat_eye = create_mat("Eye_Black", (0.05, 0.05, 0.05, 1.0), roughness=0.1)
    mat_pupil = create_mat("Eye_White", (1.0, 1.0, 1.0, 1.0), roughness=0.1)

    # Cuerpo principal de Slime (Gota orgánica suavizada)
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1.2, location=(0, 0, 1.0))
    body = bpy.context.active_object
    body.name = "Slime_Body"
    body.scale = (1.2, 1.2, 0.9)
    bpy.ops.object.shade_smooth()
    body.data.materials.append(mat_slime)

    # Núcleo mágico interior flotante
    bpy.ops.mesh.primitive_ico_sphere_add(radius=0.45, subdivisions=3, location=(0, 0, 0.9))
    core = bpy.context.active_object
    core.name = "Slime_Mana_Core"
    core.data.materials.append(mat_core)

    # Ojos estilizados kawaii/menacing
    for side, sign in [("L", -1), ("R", 1)]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(sign * 0.4, -1.05, 1.1))
        eye = bpy.context.active_object
        eye.scale = (1.0, 0.6, 1.3)
        eye.data.materials.append(mat_eye)

        # Brillo del ojo
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.06, location=(sign * 0.45, -1.18, 1.22))
        pupil = bpy.context.active_object
        pupil.data.materials.append(mat_pupil)

    # Animación de rebote (Squash & Stretch)
    body.keyframe_insert(data_path="scale", frame=1)
    body.keyframe_insert(data_path="location", frame=1)

    body.scale = (1.4, 1.4, 0.65)
    body.location = (0, 0, 0.75)
    body.keyframe_insert(data_path="scale", frame=15)
    body.keyframe_insert(data_path="location", frame=15)

    body.scale = (0.95, 0.95, 1.3)
    body.location = (0, 0, 1.4)
    body.keyframe_insert(data_path="scale", frame=30)
    body.keyframe_insert(data_path="location", frame=30)

    body.scale = (1.2, 1.2, 0.9)
    body.location = (0, 0, 1.0)
    body.keyframe_insert(data_path="scale", frame=45)
    body.keyframe_insert(data_path="location", frame=45)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Slime_Verde_Epico.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Slime_Verde_Epico.fbx")
    print("Slime Verde Épico guardado y exportado.")

def create_duende_magico():
    clean_scene()
    mat_skin = create_mat("Goblin_Skin", (0.35, 0.65, 0.25, 1.0), roughness=0.6)
    mat_cowl = create_mat("Wizard_Cowl", (0.45, 0.15, 0.55, 1.0), roughness=0.8)
    mat_gold = create_mat("Belt_Gold", (0.85, 0.7, 0.15, 1.0), roughness=0.3, metallic=0.8)
    mat_wood = create_mat("Staff_Wood", (0.3, 0.2, 0.1, 1.0), roughness=0.7)
    mat_crystal = create_mat("Crystal_Glow", (0.2, 0.8, 1.0, 1.0), roughness=0.1, emission_color=(0.2, 0.8, 1.0, 1.0), emission_strength=5.0)

    # Túnica cónica
    bpy.ops.mesh.primitive_cone_add(radius1=0.8, radius2=0.3, depth=1.6, location=(0, 0, 0.8))
    robe = bpy.context.active_object
    robe.data.materials.append(mat_cowl)

    # Cinturón
    bpy.ops.mesh.primitive_torus_add(major_radius=0.55, minor_radius=0.08, location=(0, 0, 0.8))
    belt = bpy.context.active_object
    belt.data.materials.append(mat_gold)

    # Cabeza goblin
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.45, location=(0, 0, 1.85))
    head = bpy.context.active_object
    head.scale = (1.0, 0.9, 1.0)
    head.data.materials.append(mat_skin)

    # Orejas puntiagudas largas características
    for side, sign in [("L", -1), ("R", 1)]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.15, radius2=0.01, depth=0.7, location=(sign * 0.65, 0, 1.95), rotation=(0, math.radians(sign * 65), math.radians(-15)))
        ear = bpy.context.active_object
        ear.data.materials.append(mat_skin)

    # Capucha de mago con pico doblado
    bpy.ops.mesh.primitive_cone_add(radius1=0.6, radius2=0.05, depth=0.9, location=(0, 0.1, 2.4), rotation=(math.radians(-20), 0, 0))
    hat = bpy.context.active_object
    hat.data.materials.append(mat_cowl)

    # Bastón de Mago con Cristal Flotante
    bpy.ops.mesh.primitive_cylinder_add(radius=0.06, depth=2.4, location=(0.75, -0.4, 1.2))
    staff = bpy.context.active_object
    staff.data.materials.append(mat_wood)

    # Cristal de maná brillante en la punta del bastón
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.25, location=(0.75, -0.4, 2.5))
    crystal = bpy.context.active_object
    crystal.scale = (0.7, 0.7, 1.4)
    crystal.data.materials.append(mat_crystal)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Duende_Magico_Epico.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Duende_Magico_Epico.fbx")
    print("Duende Mágico Épico guardado y exportado.")

def create_lobo_magico():
    clean_scene()
    mat_fur = create_mat("Wolf_Fur", (0.18, 0.22, 0.3, 1.0), roughness=0.8)
    mat_mane = create_mat("Wolf_Mane", (0.1, 0.12, 0.18, 1.0), roughness=0.9)
    mat_rune = create_mat("Wolf_Rune", (0.3, 0.8, 1.0, 1.0), roughness=0.2, emission_color=(0.2, 0.8, 1.0, 1.0), emission_strength=4.0)
    mat_eye = create_mat("Wolf_Eye", (1.0, 0.3, 0.1, 1.0), roughness=0.1, emission_color=(1.0, 0.4, 0.1, 1.0), emission_strength=3.0)

    # Torso y lomo musculoso
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.2))
    body = bpy.context.active_object
    body.scale = (0.8, 2.0, 0.9)
    bpy.ops.object.shade_smooth()
    body.data.materials.append(mat_fur)

    # Cuello y melena espinosa
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.65, location=(0, -1.0, 1.6))
    mane = bpy.context.active_object
    mane.scale = (1.1, 1.2, 1.3)
    mane.data.materials.append(mat_mane)

    # Cabeza y hocico lupino
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -1.5, 1.8))
    head = bpy.context.active_object
    head.scale = (0.6, 0.7, 0.6)
    head.data.materials.append(mat_fur)

    # Hocico
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -2.0, 1.7))
    snout = bpy.context.active_object
    snout.scale = (0.35, 0.6, 0.35)
    snout.data.materials.append(mat_fur)

    # Orejas alertas
    for side, sign in [("L", -1), ("R", 1)]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.15, radius2=0.02, depth=0.4, location=(sign * 0.25, -1.5, 2.25), rotation=(0, math.radians(sign * 15), 0))
        ear = bpy.context.active_object
        ear.data.materials.append(mat_fur)

        # Ojos brillantes
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.08, location=(sign * 0.25, -1.8, 1.85))
        eye = bpy.context.active_object
        eye.data.materials.append(mat_eye)

    # Patas (4)
    legs_data = [
        ("FL", -0.35, -0.8), ("FR", 0.35, -0.8),
        ("BL", -0.35, 0.8), ("BR", 0.35, 0.8)
    ]
    for name, lx, ly in legs_data:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.14, depth=1.2, location=(lx, ly, 0.6))
        leg = bpy.context.active_object
        leg.data.materials.append(mat_fur)

    # Cola erguida
    bpy.ops.mesh.primitive_cylinder_add(radius=0.12, depth=1.2, location=(0, 1.2, 1.4), rotation=(math.radians(45), 0, 0))
    tail = bpy.context.active_object
    tail.data.materials.append(mat_mane)

    # Runas mágicas en el lomo
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.7))
    rune = bpy.context.active_object
    rune.scale = (0.5, 1.4, 0.05)
    rune.data.materials.append(mat_rune)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Lobo_Magico_Epico.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Lobo_Magico_Epico.fbx")
    print("Lobo Mágico Épico guardado y exportado.")

def create_guardian_raices():
    clean_scene()
    mat_wood = create_mat("Golem_Bark", (0.28, 0.18, 0.1, 1.0), roughness=0.8)
    mat_stone = create_mat("Golem_Armor", (0.45, 0.45, 0.48, 1.0), roughness=0.9)
    mat_rune = create_mat("Golem_Rune", (0.2, 0.9, 0.5, 1.0), roughness=0.1, emission_color=(0.2, 1.0, 0.5, 1.0), emission_strength=5.0)

    # Torso de raíces retorcidas
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 3.2))
    torso = bpy.context.active_object
    torso.scale = (2.2, 1.6, 2.4)
    bpy.ops.object.shade_smooth()
    torso.data.materials.append(mat_wood)

    # Coraza de piedra rúnica frontal
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.85, 3.2))
    chestplate = bpy.context.active_object
    chestplate.scale = (1.6, 0.2, 1.8)
    chestplate.data.materials.append(mat_stone)

    # Núcleo del guardián
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.45, location=(0, -0.98, 3.2))
    core = bpy.context.active_object
    core.data.materials.append(mat_rune)

    # Hombreras colosales de roca (Pauldrons)
    for side, sign in [("L", -1), ("R", 1)]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.9, location=(sign * 1.8, 0, 4.0))
        pauldron = bpy.context.active_object
        pauldron.scale = (1.2, 1.1, 0.9)
        pauldron.data.materials.append(mat_stone)

        # Brazos con puños pesados
        bpy.ops.mesh.primitive_cylinder_add(radius=0.45, depth=2.8, location=(sign * 1.8, 0, 2.2))
        arm = bpy.context.active_object
        arm.data.materials.append(mat_wood)

        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sign * 1.8, -0.2, 0.8))
        fist = bpy.context.active_object
        fist.scale = (1.1, 1.1, 1.1)
        fist.data.materials.append(mat_stone)

    # Cabeza esculpida en piedra
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.2, 4.6))
    head = bpy.context.active_object
    head.scale = (1.2, 1.2, 1.0)
    head.data.materials.append(mat_stone)

    # Ojos / Visor rúnico
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.85, 4.6))
    eyes = bpy.context.active_object
    eyes.scale = (0.8, 0.1, 0.2)
    eyes.data.materials.append(mat_rune)

    # Piernas de pilares de raíz
    for side, sign in [("L", -1), ("R", 1)]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.55, depth=2.0, location=(sign * 0.75, 0, 1.0))
        leg = bpy.context.active_object
        leg.data.materials.append(mat_wood)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Guardian_Raices_Epico.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Guardian_Raices_Epico.fbx")
    print("Guardián de Raíces Épico guardado y exportado.")

def create_treant_ancestral():
    clean_scene()
    mat_bark = create_mat("Ancient_Bark", (0.22, 0.14, 0.08, 1.0), roughness=0.9)
    mat_leaves = create_mat("Autumn_Crown", (0.85, 0.45, 0.1, 1.0), roughness=0.7)
    mat_glow = create_mat("Heart_Fissure", (1.0, 0.15, 0.05, 1.0), roughness=0.1, emission_color=(1.0, 0.2, 0.05, 1.0), emission_strength=6.0)

    # Tronco Colosal retorcido
    bpy.ops.mesh.primitive_cylinder_add(radius=2.2, depth=7.0, location=(0, 0, 3.5))
    trunk = bpy.context.active_object
    trunk.scale = (1.2, 1.0, 1.0)
    bpy.ops.object.shade_smooth()
    trunk.data.materials.append(mat_bark)

    # Fisura del corazón ardiente
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -1.05, 3.8))
    fissure = bpy.context.active_object
    fissure.scale = (0.8, 0.3, 1.8)
    fissure.data.materials.append(mat_glow)

    # Cabeza y ceño imponente
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.4, 7.5))
    head = bpy.context.active_object
    head.scale = (2.0, 1.8, 1.6)
    head.data.materials.append(mat_bark)

    # Ojos furiosos
    for side, sign in [("L", -1), ("R", 1)]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sign * 0.6, -1.35, 7.6))
        eye = bpy.context.active_object
        eye.scale = (0.35, 0.15, 0.2)
        eye.data.materials.append(mat_glow)

    # Cornamenta de ramas gigantescas
    for side, sign in [("L", -1), ("R", 1)]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.45, depth=4.5, location=(sign * 2.2, 0, 9.5), rotation=(0, math.radians(sign * 35), math.radians(sign * -15)))
        branch = bpy.context.active_object
        branch.data.materials.append(mat_bark)

        # Follaje místico en las ramas
        bpy.ops.mesh.primitive_ico_sphere_add(radius=1.8, subdivisions=2, location=(sign * 3.4, 0, 11.0))
        crown = bpy.context.active_object
        crown.data.materials.append(mat_leaves)

    # Brazos colosales con dedos de raíz
    for side, sign in [("L", -1), ("R", 1)]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.7, depth=5.5, location=(sign * 2.8, -0.5, 3.5), rotation=(math.radians(25), math.radians(sign * 15), 0))
        arm = bpy.context.active_object
        arm.data.materials.append(mat_bark)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Treant_Ancestral_Epico.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Treant_Ancestral_Epico.fbx")
    print("Treant Ancestral Épico guardado y exportado.")

def render_showcase():
    clean_scene()
    
    # Suelo de exposición de estudio
    bpy.ops.mesh.primitive_cylinder_add(radius=25.0, depth=0.5, location=(0, 0, -0.25))
    floor = bpy.context.active_object
    mat_floor = create_mat("Studio_Dark", (0.05, 0.06, 0.08, 1.0), roughness=0.6)
    floor.data.materials.append(mat_floor)

    # Iluminación de 3 Puntos de Estudio
    bpy.ops.object.light_add(type='AREA', location=(0.0, -12.0, 10.0))
    key = bpy.context.active_object
    key.data.energy = 2200
    key.data.size = 12.0
    key.rotation_euler = (math.radians(50), 0, 0)

    bpy.ops.object.light_add(type='AREA', location=(-12.0, -8.0, 8.0))
    fill = bpy.context.active_object
    fill.data.energy = 900
    fill.data.size = 8.0
    fill.data.color = (0.6, 0.8, 1.0)

    bpy.ops.object.light_add(type='POINT', location=(0.0, 12.0, 12.0))
    rim = bpy.context.active_object
    rim.data.energy = 1500
    rim.data.color = (1.0, 0.9, 0.8)

    # Configuración de Cámara
    bpy.ops.object.camera_add(location=(0.0, -22.0, 7.5), rotation=(math.radians(78), 0, 0))
    cam = bpy.context.active_object
    cam.data.lens = 38
    bpy.context.scene.camera = cam

    # Configuración de Render
    bpy.context.scene.render.resolution_x = 1280
    bpy.context.scene.render.resolution_y = 720
    bpy.context.scene.render.filepath = "c:/Users/Antonio Garcia/Downloads/blender/render_dungeon_epic_assets.png"

    # Importar los modelos exportados en la escena para el render conjunto
    models = [
        ("Puerta_Mazmorra_Runic.fbx", (-8.0, 0, 0), (0.7, 0.7, 0.7)),
        ("Slime_Verde_Epico.fbx", (-4.0, -3.0, 0), (1.2, 1.2, 1.2)),
        ("Duende_Magico_Epico.fbx", (-1.5, -2.5, 0), (1.3, 1.3, 1.3)),
        ("Cofre_Ancestral_Deluxe.fbx", (0.0, -3.5, 0), (1.0, 1.0, 1.0)),
        ("Lobo_Magico_Epico.fbx", (2.0, -2.5, 0), (1.2, 1.2, 1.2)),
        ("Guardian_Raices_Epico.fbx", (5.5, -1.0, 0), (0.85, 0.85, 0.85)),
        ("Treant_Ancestral_Epico.fbx", (8.5, 2.0, 0), (0.75, 0.75, 0.75)),
    ]

    for fname, pos, scl in models:
        path = f"c:/Users/Antonio Garcia/Downloads/blender/{fname}"
        bpy.ops.import_scene.fbx(filepath=path)
        # Escalar y mover los objetos importados
        imported = bpy.context.selected_objects
        for obj in imported:
            if obj.parent is None:
                obj.location = pos
                obj.scale = scl

    print("Iniciando renderizado de la escena completa...")
    bpy.ops.render.render(write_still=True)
    print("¡Render completado en render_dungeon_epic_assets.png!")

if __name__ == "__main__":
    create_puerta_runica()
    create_cofre_deluxe()
    create_slime_epico()
    create_duende_magico()
    create_lobo_magico()
    create_guardian_raices()
    create_treant_ancestral()
    render_showcase()
