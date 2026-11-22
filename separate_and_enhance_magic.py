import bpy
import math

def separate_and_enhance_magic():
    col_staff = bpy.data.collections.get("Baston_Magico")
    col_post = bpy.data.collections.get("Puesto_Entrenamiento_Magico")
    
    # -------------------------------------------------------------
    # 1. Función para mover grupos de objetos
    # -------------------------------------------------------------
    def move_objects(obj_names, delta_x, delta_y, delta_z):
        for name in obj_names:
            obj = bpy.data.objects.get(name)
            if obj:
                obj.location.x += delta_x
                obj.location.y += delta_y
                obj.location.z += delta_z

    # Separar Módulo 1: Bastón Mágico -> X = -4.5
    # Actualmente está en ~ -1.2, -0.4 -> mover -3.3 en X, +0.4 en Y
    if col_staff:
        for obj in col_staff.objects:
            obj.location.x -= 3.3
            obj.location.y += 0.4

    # Separar Módulo 2: Muñeco de Entrenamiento -> X = -1.8
    # Actualmente en dx=0.6, dy=0.0 -> mover -2.4 en X
    dummy_objects = [
        'Dummy_Poste_Madera', 'Dummy_Base_Cruz', 'Dummy_Base_Cruz.001', 
        'Dummy_Torso_Saco', 'Dummy_Cuerda_Torso', 'Dummy_Cuerda_Torso.001', 
        'Dummy_Cuerda_Torso.002', 'Dummy_Diana_Magica', 'Dummy_Diana_Borde', 
        'Dummy_Brazos_Madera', 'Dummy_Guante_L', 'Dummy_Guante_R', 
        'Dummy_Cabeza', 'Dummy_Ojo_L', 'Dummy_Ojo_R', 
        'Gorro_Mago_Ala', 'Gorro_Mago_Cono', 'Gorro_Mago_Cinta',
        'Luz_Diana_Target_Obj'
    ]
    move_objects(dummy_objects, -2.4, 0.0, 0.0)

    # Separar Módulo 3: Atril con Grimorio -> X = 0.5
    # Actualmente en lx=-0.5, ly=0.9 -> mover +1.0 en X, -0.9 en Y
    lectern_objects = [
        'Atril_Pedestal', 'Atril_Tabla', 'Grimorio_Magico', 'Grimorio_Paginas_Runicas'
    ]
    move_objects(lectern_objects, 1.0, -0.9, 0.0)

    # Separar Módulo 4: Barril de Pociones de Maná -> X = 2.4
    # Actualmente en bx=-1.2, by=0.6 -> mover +3.6 en X, -0.6 en Y
    barrel_objects = [
        'Barril_Suministros', 'Barril_Aro_Hierro', 'Barril_Aro_Hierro.001',
        'Pocion_Frasco_1', 'Pocion_Cuello_1', 'Pocion_Frasco_2', 'Pocion_Cuello_2'
    ]
    move_objects(barrel_objects, 3.6, -0.6, 0.0)

    # Separar Módulo 5: Plataforma Octagonal y Pilares -> X = 6.0
    # Actualmente en X=0, Y=0 -> mover +6.0 en X
    platform_objects = [
        'Plataforma_Entrenamiento', 'Escalon_Plataforma', 'Circulo_Runico_Suelo', 
        'Anillo_Runico_Borde', 'Pilar_Piedra_1', 'Cristal_Pilar_1', 
        'Pilar_Piedra_2', 'Cristal_Pilar_2', 'Pilar_Piedra_3', 'Cristal_Pilar_3', 
        'Pilar_Piedra_4', 'Cristal_Pilar_4'
    ]
    move_objects(platform_objects, 6.0, 0.0, 0.0)

    # -------------------------------------------------------------
    # 2. Materiales Mágicos con Alta Emisión y Color
    # -------------------------------------------------------------
    def get_or_make_mat(name, base_color, metallic=0.0, roughness=0.2, emission_col=None, emission_val=0.0):
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

    mat_fuego_azul = get_or_make_mat("Fuego_Espiritual_Azul", (0.1, 0.8, 1.0, 1.0), roughness=0.0, 
                                     emission_col=(0.1, 0.8, 1.0, 1.0), emission_val=14.0)
    mat_escudo_arcano = get_or_make_mat("Escudo_Arcano_Energia", (0.85, 0.2, 1.0, 0.7), roughness=0.1, 
                                        emission_col=(0.9, 0.2, 1.0, 1.0), emission_val=10.0)
    mat_runa_dorada = get_or_make_mat("Runa_Holograma_Oro", (1.0, 0.85, 0.2, 1.0), roughness=0.1,
                                      emission_col=(1.0, 0.85, 0.2, 1.0), emission_val=12.0)
    mat_cristal_mana = get_or_make_mat("Cristal_Mana_Puro", (0.2, 0.95, 1.0, 1.0), roughness=0.05,
                                       emission_col=(0.2, 0.95, 1.0, 1.0), emission_val=15.0)
    mat_oro = bpy.data.materials.get("Roblox_Oro") or get_or_make_mat("Roblox_Oro", (1.0, 0.78, 0.2, 1.0), metallic=0.95, roughness=0.2)
    mat_piedra = bpy.data.materials.get("Roblox_Piedra_Dais") or get_or_make_mat("Roblox_Piedra_Dais", (0.22, 0.23, 0.26, 1.0))

    def link_to_post(obj):
        for c in list(obj.users_collection):
            c.objects.unlink(obj)
        col_post.objects.link(obj)

    # -------------------------------------------------------------
    # 3. MÁS MAGIA 1: Escudo Rúnico Flotante junto al Muñeco (Target Barrier)
    # -------------------------------------------------------------
    # Disco de energía hexagonal flotante
    sh_x, sh_y, sh_z = -1.2, -0.45, 1.25
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.32, depth=0.015, location=(sh_x, sh_y, sh_z))
    shield_core = bpy.context.active_object
    shield_core.name = "Escudo_Magico_Hexagono"
    shield_core.rotation_euler = (0.2, -0.2, 0.4)
    link_to_post(shield_core)
    shield_core.data.materials.append(mat_escudo_arcano)
    bpy.ops.object.shade_flat()

    # Borde dorado del escudo
    bpy.ops.mesh.primitive_torus_add(major_radius=0.33, minor_radius=0.018, location=(sh_x, sh_y, sh_z), major_segments=6, minor_segments=6)
    shield_rim = bpy.context.active_object
    shield_rim.name = "Escudo_Magico_Borde"
    shield_rim.rotation_euler = (0.2, -0.2, 0.4)
    link_to_post(shield_rim)
    shield_rim.data.materials.append(mat_oro)
    bpy.ops.object.shade_flat()

    # Luz de energía proyectada por el escudo
    light_sh_data = bpy.data.lights.new(name="Luz_Escudo_Data", type='POINT')
    light_sh_data.color = (0.85, 0.2, 1.0)
    light_sh_data.energy = 35.0
    light_sh = bpy.data.objects.new("Luz_Escudo_Obj", light_sh_data)
    light_sh.location = (sh_x, sh_y - 0.15, sh_z)
    link_to_post(light_sh)

    # -------------------------------------------------------------
    # 4. MÁS MAGIA 2: Círculo de Invocación Holográfico flotando sobre el Grimorio
    # -------------------------------------------------------------
    gx, gy, gz = 0.5, 0.0, 1.35
    # Anillo rúnico concéntrico flotando sobre el libro
    bpy.ops.mesh.primitive_torus_add(major_radius=0.22, minor_radius=0.008, location=(gx, gy, gz), major_segments=24, minor_segments=8)
    holo_ring1 = bpy.context.active_object
    holo_ring1.name = "Holograma_Circulo_Libro_1"
    holo_ring1.rotation_euler = (0.45, 0, 0)
    link_to_post(holo_ring1)
    holo_ring1.data.materials.append(mat_runa_dorada)
    bpy.ops.object.shade_smooth()

    bpy.ops.mesh.primitive_torus_add(major_radius=0.14, minor_radius=0.006, location=(gx, gy, gz + 0.04), major_segments=24, minor_segments=8)
    holo_ring2 = bpy.context.active_object
    holo_ring2.name = "Holograma_Circulo_Libro_2"
    holo_ring2.rotation_euler = (0.45, 0, 0)
    link_to_post(holo_ring2)
    holo_ring2.data.materials.append(mat_cristal_mana)
    bpy.ops.object.shade_smooth()

    # Glifo flotante central sobre el grimorio
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.04, radius2=0, depth=0.08, location=(gx, gy, gz + 0.06))
    glyph = bpy.context.active_object
    glyph.name = "Glifo_Flotante_Grimorio"
    glyph.rotation_euler = (0.45, 0, 0)
    link_to_post(glyph)
    glyph.data.materials.append(mat_runa_dorada)
    bpy.ops.object.shade_flat()

    # Luz de lectura mística sobre el libro
    light_bk_data = bpy.data.lights.new(name="Luz_Libro_Data", type='POINT')
    light_bk_data.color = (1.0, 0.85, 0.3)
    light_bk_data.energy = 40.0
    light_bk = bpy.data.objects.new("Luz_Libro_Obj", light_bk_data)
    light_bk.location = (gx, gy, gz + 0.1)
    link_to_post(light_bk)

    # -------------------------------------------------------------
    # 5. MÁS MAGIA 3: Orbes de Fuego Espiritual Flotante sobre los 4 Pilares
    # -------------------------------------------------------------
    # Los pilares ahora están centrados alrededor de X = 6.0, Y = 0.0
    for i in range(4):
        ang = i * (math.pi / 2) + math.pi / 4
        px = 6.0 + math.cos(ang) * 1.95
        py = math.sin(ang) * 1.95
        
        # Fuego fatuo / Llama esférica de maná sobre cada pilar
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.09, location=(px, py, 1.02))
        flame = bpy.context.active_object
        flame.name = f"Fuego_Fatuo_Pilar_{i+1}"
        flame.scale = (0.8, 0.8, 1.4) # Alargado hacia arriba como llama
        link_to_post(flame)
        flame.data.materials.append(mat_fuego_azul)
        bpy.ops.object.shade_smooth()

        # Pequeño anillo de runas orbitando cada llama
        bpy.ops.mesh.primitive_torus_add(major_radius=0.13, minor_radius=0.007, location=(px, py, 1.02), major_segments=16, minor_segments=6)
        f_ring = bpy.context.active_object
        f_ring.name = f"Anillo_Llama_{i+1}"
        f_ring.rotation_euler = (0.3, 0.3 * i, 0.5)
        link_to_post(f_ring)
        f_ring.data.materials.append(mat_runa_dorada)
        bpy.ops.object.shade_smooth()

    # -------------------------------------------------------------
    # 6. MÁS MAGIA 4: Gran Cristal de Maná Monolítico Flotando en la Plataforma
    # -------------------------------------------------------------
    cx, cy, cz = 6.0, 0.0, 1.6
    # Gran cristal central
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.28, radius2=0.0, depth=0.85, location=(cx, cy, cz + 0.1))
    cryst_top = bpy.context.active_object
    cryst_top.name = "Monolito_Mana_Superior"
    link_to_post(cryst_top)
    cryst_top.data.materials.append(mat_cristal_mana)
    bpy.ops.object.shade_flat()

    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.28, radius2=0.0, depth=0.55, location=(cx, cy, cz - 0.25))
    cryst_bot = bpy.context.active_object
    cryst_bot.name = "Monolito_Mana_Inferior"
    cryst_bot.rotation_euler[0] = math.pi
    link_to_post(cryst_bot)
    cryst_bot.data.materials.append(mat_cristal_mana)
    bpy.ops.object.shade_flat()

    # 3 Cristales satélite pequeños orbitando el gran cristal
    for s_idx in range(3):
        s_ang = s_idx * (2 * math.pi / 3)
        sx = cx + math.cos(s_ang) * 0.55
        sy = cy + math.sin(s_ang) * 0.55
        sz = cz + 0.1 * math.sin(s_ang * 2)
        
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.065, radius2=0.0, depth=0.22, location=(sx, sy, sz))
        sat = bpy.context.active_object
        sat.name = f"Cristal_Satelite_{s_idx+1}"
        sat.rotation_euler = (0.2, 0.3 * s_idx, s_ang)
        link_to_post(sat)
        sat.data.materials.append(mat_escudo_arcano)
        bpy.ops.object.shade_flat()

    # Gran luz central del maná
    light_core_data = bpy.data.lights.new(name="Luz_Mana_Core_Data", type='POINT')
    light_core_data.color = (0.2, 0.95, 1.0)
    light_core_data.energy = 150.0
    light_core = bpy.data.objects.new("Luz_Mana_Core_Obj", light_core_data)
    light_core.location = (cx, cy, cz)
    link_to_post(light_core)

    # -------------------------------------------------------------
    # 7. MÁS MAGIA 5: Pedestal de Exhibición para el Bastón Mágico
    # -------------------------------------------------------------
    bx_pos, by_pos = -4.5, 0.0
    # Pequeño pedestal circular rúnico para exhibir el bastón
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.45, depth=0.08, location=(bx_pos, by_pos, 0.04))
    staff_pedestal = bpy.context.active_object
    staff_pedestal.name = "Bastón_Pedestal_Piedra"
    link_to_post(staff_pedestal)
    staff_pedestal.data.materials.append(mat_piedra)
    bpy.ops.object.shade_flat()

    bpy.ops.mesh.primitive_torus_add(major_radius=0.46, minor_radius=0.015, location=(bx_pos, by_pos, 0.08), major_segments=24, minor_segments=8)
    st_ring = bpy.context.active_object
    st_ring.name = "Bastón_Pedestal_Anillo_Oro"
    link_to_post(st_ring)
    st_ring.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # -------------------------------------------------------------
    # 8. Encuadrar toda la escena separada y Guardar
    # -------------------------------------------------------------
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

    # Guardar .blend
    bpy.ops.wm.save_as_mainfile(filepath=r"c:\Users\Antonio Garcia\Downloads\blender\Baston_Magico.blend")
    
    # Exportar FBX actualizado con todas las piezas separadas
    bpy.ops.export_scene.fbx(
        filepath=r"c:\Users\Antonio Garcia\Downloads\blender\Puesto_Entrenamiento_Roblox.fbx",
        use_selection=False,
        global_scale=1.0,
        apply_scale_options='FBX_SCALE_ALL'
    )

    print(">>> Piezas separadas en fila de exhibición y MÁS MAGIA añadida exitosamente! <<<")

separate_and_enhance_magic()
