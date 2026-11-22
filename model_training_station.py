import bpy
import math

def build_training_station():
    # 1. Mover el Bastón Mágico a un lado para que sea parte del set
    col_staff = bpy.data.collections.get("Baston_Magico")
    if col_staff:
        # Si el bastón está en el origen (0,0,0), lo desplazamos suavemente a x = -1.2, y = -0.5
        for obj in col_staff.objects:
            obj.location.x -= 1.2
            obj.location.y -= 0.4
    
    # 2. Crear Colección Puesto_Entrenamiento_Magico
    col_name = "Puesto_Entrenamiento_Magico"
    if col_name in bpy.data.collections:
        col = bpy.data.collections[col_name]
        for obj in list(col.objects):
            bpy.data.objects.remove(obj, do_unlink=True)
    else:
        col = bpy.data.collections.new(col_name)
        bpy.context.scene.collection.children.link(col)
        
    def link_obj(obj):
        for c in list(obj.users_collection):
            c.objects.unlink(obj)
        col.objects.link(obj)

    # 3. Materiales Estilizados estilo Roblox RPG
    def make_mat(name, base_color, metallic=0.0, roughness=0.4, emission_col=None, emission_val=0.0):
        mat = bpy.data.materials.get(name)
        if not mat:
            mat = bpy.data.materials.new(name=name)
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes.get("Principled BSDF")
        if bsdf:
            if "Base Color" in bsdf.inputs:
                bsdf.inputs["Base Color"].default_value = base_color
            if "Metallic" in bsdf.inputs:
                bsdf.inputs["Metallic"].default_value = metallic
            if "Roughness" in bsdf.inputs:
                bsdf.inputs["Roughness"].default_value = roughness
            if emission_col and "Emission Color" in bsdf.inputs:
                bsdf.inputs["Emission Color"].default_value = emission_col
                if "Emission Strength" in bsdf.inputs:
                    bsdf.inputs["Emission Strength"].default_value = emission_val
            elif emission_col and "Emission" in bsdf.inputs:
                bsdf.inputs["Emission"].default_value = emission_col
                if "Emission Strength" in bsdf.inputs:
                    bsdf.inputs["Emission Strength"].default_value = emission_val
        return mat

    mat_piedra_base = make_mat("Roblox_Piedra_Dais", (0.22, 0.23, 0.26, 1.0), roughness=0.7)
    mat_madera_dummy = make_mat("Roblox_Madera_Clara", (0.55, 0.35, 0.18, 1.0), roughness=0.6)
    mat_tela_burlap = make_mat("Roblox_Saco_Entrenamiento", (0.68, 0.58, 0.42, 1.0), roughness=0.85)
    mat_cuerda = make_mat("Roblox_Cuerda", (0.42, 0.35, 0.25, 1.0), roughness=0.9)
    mat_sombrero = make_mat("Roblox_Gorro_Mago", (0.15, 0.08, 0.28, 1.0), roughness=0.5)
    mat_diana_magica = make_mat("Roblox_Diana_Fuego", (1.0, 0.2, 0.1, 1.0), emission_col=(1.0, 0.3, 0.05, 1.0), emission_val=9.0)
    mat_circulo_runas = make_mat("Roblox_Runas_Suelo", (0.1, 0.85, 1.0, 1.0), emission_col=(0.1, 0.85, 1.0, 1.0), emission_val=8.0)
    mat_mana_pocion = make_mat("Roblox_Pocion_Mana", (0.05, 0.4, 1.0, 1.0), roughness=0.1, emission_col=(0.1, 0.5, 1.0, 1.0), emission_val=6.0)
    mat_vidrio = make_mat("Roblox_Vidrio_Pocion", (0.8, 0.9, 1.0, 1.0), roughness=0.15)
    mat_hierro = make_mat("Roblox_Hierro_Forjado", (0.15, 0.15, 0.17, 1.0), metallic=0.85, roughness=0.35)
    mat_oro = make_mat("Roblox_Oro", (1.0, 0.78, 0.2, 1.0), metallic=0.95, roughness=0.2)

    # 4. Plataforma Octagonal de Entrenamiento (Dais de Piedra)
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.2, depth=0.16, location=(0, 0, 0.08))
    dais = bpy.context.active_object
    dais.name = "Plataforma_Entrenamiento"
    link_obj(dais)
    dais.data.materials.append(mat_piedra_base)
    bpy.ops.object.shade_flat()

    # Borde escalonado exterior
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.35, depth=0.08, location=(0, 0, 0.04))
    step = bpy.context.active_object
    step.name = "Escalon_Plataforma"
    link_obj(step)
    step.data.materials.append(mat_hierro)
    bpy.ops.object.shade_flat()

    # Círculo Mágico de Runas en el suelo (Rune Circle)
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.6, depth=0.005, location=(0, 0, 0.165))
    rune_floor = bpy.context.active_object
    rune_floor.name = "Circulo_Runico_Suelo"
    link_obj(rune_floor)
    rune_floor.data.materials.append(mat_circulo_runas)

    # Anillo exterior del círculo rúnico
    bpy.ops.mesh.primitive_torus_add(major_radius=1.65, minor_radius=0.02, location=(0, 0, 0.17), major_segments=32, minor_segments=8)
    rune_ring = bpy.context.active_object
    rune_ring.name = "Anillo_Runico_Borde"
    link_obj(rune_ring)
    rune_ring.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # 4 Pilares de Piedra y Cristal en los puntos cardinales de la plataforma
    for i in range(4):
        ang = i * (math.pi / 2) + math.pi / 4
        px = math.cos(ang) * 1.95
        py = math.sin(ang) * 1.95
        
        # Pilar de piedra
        bpy.ops.mesh.primitive_cube_add(size=0.25, location=(px, py, 0.35))
        pillar = bpy.context.active_object
        pillar.name = f"Pilar_Piedra_{i+1}"
        pillar.scale = (1, 1, 2.2)
        link_obj(pillar)
        pillar.data.materials.append(mat_piedra_base)
        bpy.ops.object.shade_flat()

        # Cristal flotante en la cima del pilar
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.07, radius2=0, depth=0.18, location=(px, py, 0.72))
        p_cryst = bpy.context.active_object
        p_cryst.name = f"Cristal_Pilar_{i+1}"
        link_obj(p_cryst)
        p_cryst.data.materials.append(mat_circulo_runas)
        bpy.ops.object.shade_flat()

    # -------------------------------------------------------------
    # 5. EL MUÑECO DE ENTRENAMIENTO MÁGICO (Magic Training Dummy)
    # -------------------------------------------------------------
    # Posición central del muñeco en la plataforma
    dx, dy, dz = 0.6, 0.0, 0.16
    
    # Poste de madera vertical principal
    bpy.ops.mesh.primitive_cylinder_add(radius=0.09, depth=1.9, location=(dx, dy, dz + 0.95), vertices=12)
    dummy_pole = bpy.context.active_object
    dummy_pole.name = "Dummy_Poste_Madera"
    link_obj(dummy_pole)
    dummy_pole.data.materials.append(mat_madera_dummy)
    bpy.ops.object.shade_smooth()

    # Base de soporte en cruz en el suelo (Trípode/Cruz de madera)
    for rot in [0, math.pi / 2]:
        bpy.ops.mesh.primitive_cube_add(size=0.16, location=(dx, dy, dz + 0.08))
        c_beam = bpy.context.active_object
        c_beam.name = "Dummy_Base_Cruz"
        c_beam.scale = (4.0, 0.8, 0.8)
        c_beam.rotation_euler[2] = rot
        link_obj(c_beam)
        c_beam.data.materials.append(mat_madera_dummy)
        bpy.ops.object.shade_flat()

    # Torso de paja / saco de entrenamiento
    bpy.ops.mesh.primitive_cylinder_add(radius=0.24, depth=0.75, location=(dx, dy, dz + 1.15), vertices=14)
    dummy_torso = bpy.context.active_object
    dummy_torso.name = "Dummy_Torso_Saco"
    dummy_torso.scale = (1.1, 0.85, 1.0)
    link_obj(dummy_torso)
    dummy_torso.data.materials.append(mat_tela_burlap)
    bpy.ops.object.shade_smooth()

    # Cuerdas atadas alrededor del torso
    for rope_z in [dz + 0.9, dz + 1.25, dz + 1.45]:
        bpy.ops.mesh.primitive_torus_add(major_radius=0.23, minor_radius=0.02, location=(dx, dy, rope_z), major_segments=16, minor_segments=8)
        rope = bpy.context.active_object
        rope.name = "Dummy_Cuerda_Torso"
        link_obj(rope)
        rope.data.materials.append(mat_cuerda)
        bpy.ops.object.shade_smooth()

    # Diana / Núcleo Mágico de Impacto en el pecho (Target Arcane Sigil)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.14, depth=0.02, location=(dx, dy - 0.21, dz + 1.18), vertices=16)
    target_disk = bpy.context.active_object
    target_disk.name = "Dummy_Diana_Magica"
    target_disk.rotation_euler[0] = math.pi / 2
    link_obj(target_disk)
    target_disk.data.materials.append(mat_diana_magica)
    bpy.ops.object.shade_smooth()

    # Anillo exterior de la diana
    bpy.ops.mesh.primitive_torus_add(major_radius=0.15, minor_radius=0.015, location=(dx, dy - 0.21, dz + 1.18), major_segments=16, minor_segments=8)
    t_ring = bpy.context.active_object
    t_ring.name = "Dummy_Diana_Borde"
    t_ring.rotation_euler[0] = math.pi / 2
    link_obj(t_ring)
    t_ring.data.materials.append(mat_hierro)
    bpy.ops.object.shade_smooth()

    # Brazos de entrenamiento de madera en cruz
    bpy.ops.mesh.primitive_cylinder_add(radius=0.065, depth=1.1, location=(dx, dy, dz + 1.35), vertices=10)
    dummy_arms = bpy.context.active_object
    dummy_arms.name = "Dummy_Brazos_Madera"
    dummy_arms.rotation_euler[1] = math.pi / 2
    link_obj(dummy_arms)
    dummy_arms.data.materials.append(mat_madera_dummy)
    bpy.ops.object.shade_smooth()

    # Protectores / Guantes de paja en las puntas de los brazos
    for arm_sign in [-1, 1]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.10, location=(dx + arm_sign * 0.55, dy, dz + 1.35), segments=12, ring_count=8)
        glove = bpy.context.active_object
        glove.name = f"Dummy_Guante_{'L' if arm_sign < 0 else 'R'}"
        link_obj(glove)
        glove.data.materials.append(mat_tela_burlap)
        bpy.ops.object.shade_smooth()

    # Cabeza del Dummy: Saco esférico
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(dx, dy, dz + 1.70), segments=14, ring_count=10)
    dummy_head = bpy.context.active_object
    dummy_head.name = "Dummy_Cabeza"
    link_obj(dummy_head)
    dummy_head.data.materials.append(mat_tela_burlap)
    bpy.ops.object.shade_smooth()

    # Ojos mágicos brillantes pintados / tallados
    for eye_sign in [-1, 1]:
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.025, radius2=0, depth=0.04, location=(dx + eye_sign * 0.065, dy - 0.16, dz + 1.72))
        eye = bpy.context.active_object
        eye.name = f"Dummy_Ojo_{'L' if eye_sign < 0 else 'R'}"
        eye.rotation_euler = (math.pi / 2, 0, 0)
        link_obj(eye)
        eye.data.materials.append(mat_diana_magica)
        bpy.ops.object.shade_flat()

    # Gorro de Mago estilizado Roblox en la cabeza del dummy
    # Ala del sombrero
    bpy.ops.mesh.primitive_cylinder_add(radius=0.30, depth=0.03, location=(dx, dy, dz + 1.83), vertices=16)
    hat_brim = bpy.context.active_object
    hat_brim.name = "Gorro_Mago_Ala"
    link_obj(hat_brim)
    hat_brim.data.materials.append(mat_sombrero)
    bpy.ops.object.shade_smooth()

    # Cono curvado del sombrero
    bpy.ops.mesh.primitive_cone_add(radius1=0.20, radius2=0.02, depth=0.38, location=(dx, dy - 0.02, dz + 2.01), vertices=14)
    hat_cone = bpy.context.active_object
    hat_cone.name = "Gorro_Mago_Cono"
    hat_cone.rotation_euler[0] = 0.22 # Inclinación simpática
    link_obj(hat_cone)
    hat_cone.data.materials.append(mat_sombrero)
    bpy.ops.object.shade_smooth()

    # Cinta dorada en el gorro
    bpy.ops.mesh.primitive_torus_add(major_radius=0.19, minor_radius=0.015, location=(dx, dy, dz + 1.86), major_segments=16, minor_segments=8)
    hat_band = bpy.context.active_object
    hat_band.name = "Gorro_Mago_Cinta"
    link_obj(hat_band)
    hat_band.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # -------------------------------------------------------------
    # 6. ATRIL DE GRIMORIO MÁGICO (Spellbook Lectern)
    # -------------------------------------------------------------
    lx, ly, lz = -0.5, 0.9, 0.16
    # Pedestal de piedra
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.18, depth=0.95, location=(lx, ly, lz + 0.47))
    lectern_base = bpy.context.active_object
    lectern_base.name = "Atril_Pedestal"
    link_obj(lectern_base)
    lectern_base.data.materials.append(mat_piedra_base)
    bpy.ops.object.shade_flat()

    # Tabla inclinada del atril
    bpy.ops.mesh.primitive_cube_add(size=0.35, location=(lx, ly, lz + 0.98))
    lectern_top = bpy.context.active_object
    lectern_top.name = "Atril_Tabla"
    lectern_top.scale = (1.2, 0.9, 0.08)
    lectern_top.rotation_euler[0] = 0.45
    link_obj(lectern_top)
    lectern_top.data.materials.append(mat_madera_dummy)
    bpy.ops.object.shade_flat()

    # Libro abierto / Grimorio mágico
    bpy.ops.mesh.primitive_cube_add(size=0.30, location=(lx, ly - 0.02, lz + 1.02))
    book = bpy.context.active_object
    book.name = "Grimorio_Magico"
    book.scale = (1.1, 0.7, 0.05)
    book.rotation_euler[0] = 0.45
    link_obj(book)
    book.data.materials.append(mat_sombrero)
    bpy.ops.object.shade_flat()

    # Páginas luminosas de runas en el grimorio
    bpy.ops.mesh.primitive_cube_add(size=0.26, location=(lx, ly - 0.02, lz + 1.035))
    pages = bpy.context.active_object
    pages.name = "Grimorio_Paginas_Runicas"
    pages.scale = (1.0, 0.62, 0.03)
    pages.rotation_euler[0] = 0.45
    link_obj(pages)
    pages.data.materials.append(mat_circulo_runas)
    bpy.ops.object.shade_flat()

    # -------------------------------------------------------------
    # 7. ESTACIÓN DE POCIONES Y MANÁ (Mana Flasks & Barrel)
    # -------------------------------------------------------------
    bx, by, bz = -1.2, 0.6, 0.16
    # Barril de madera
    bpy.ops.mesh.primitive_cylinder_add(radius=0.26, depth=0.65, location=(bx, by, bz + 0.32), vertices=12)
    barrel = bpy.context.active_object
    barrel.name = "Barril_Suministros"
    link_obj(barrel)
    barrel.data.materials.append(mat_madera_dummy)
    bpy.ops.object.shade_smooth()

    # Aros de hierro del barril
    for b_ring_z in [bz + 0.12, bz + 0.52]:
        bpy.ops.mesh.primitive_torus_add(major_radius=0.265, minor_radius=0.015, location=(bx, by, b_ring_z), major_segments=16, minor_segments=8)
        bring = bpy.context.active_object
        bring.name = "Barril_Aro_Hierro"
        link_obj(bring)
        bring.data.materials.append(mat_hierro)
        bpy.ops.object.shade_smooth()

    # Frascos de pociones de maná brillante sobre el barril
    for p_i, p_col in enumerate([mat_mana_pocion, mat_diana_magica]):
        p_off = (p_i - 0.5) * 0.16
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.065, location=(bx + p_off, by, bz + 0.70), segments=10, ring_count=8)
        flask = bpy.context.active_object
        flask.name = f"Pocion_Frasco_{p_i+1}"
        link_obj(flask)
        flask.data.materials.append(p_col)
        bpy.ops.object.shade_smooth()

        # Cuello del frasco con tapón de corcho
        bpy.ops.mesh.primitive_cylinder_add(radius=0.02, depth=0.05, location=(bx + p_off, by, bz + 0.76), vertices=8)
        cork = bpy.context.active_object
        cork.name = f"Pocion_Cuello_{p_i+1}"
        link_obj(cork)
        cork.data.materials.append(mat_cuerda)
        bpy.ops.object.shade_flat()

    # -------------------------------------------------------------
    # 8. ILUMINACIÓN Y ENFOQUE GENERAL
    # -------------------------------------------------------------
    # Luz cálida de impacto en la diana
    light_target = bpy.data.lights.new(name="Luz_Diana_Target", type='POINT')
    light_target.color = (1.0, 0.4, 0.1)
    light_target.energy = 55.0
    l_t_obj = bpy.data.objects.new("Luz_Diana_Target_Obj", light_target)
    l_t_obj.location = (dx, dy - 0.35, dz + 1.25)
    link_obj(l_t_obj)

    # Seleccionar todo y encuadrar toda la escena en el visor 3D
    bpy.ops.object.select_all(action='SELECT')
    for area in bpy.context.screen.areas:
        if area.type == 'VIEW_3D':
            for region in area.regions:
                if region.type == 'WINDOW':
                    override = {'area': area, 'region': region}
                    with bpy.context.temp_override(**override):
                        bpy.ops.view3d.view_selected()
                        for space in area.spaces:
                            if space.type == 'VIEW_3D':
                                space.shading.type = 'MATERIAL'

    # Guardar archivo .blend actualizado
    bpy.ops.wm.save_as_mainfile(filepath=r"c:\Users\Antonio Garcia\Downloads\blender\Baston_Magico.blend")

    print(">>> Puesto de Entrenamiento Mágico estilo Roblox modelado y guardado con éxito! <<<")

build_training_station()
