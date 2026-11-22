import bpy
import math

def rebuild_all():
    # 1. Limpiar completamente la escena (excepto cámara y luz por defecto si se quieren, pero limpiamos mallas)
    bpy.ops.object.select_all(action='SELECT')
    for obj in bpy.context.selected_objects:
        if obj.type in ['MESH', 'CURVE', 'LIGHT']:
            bpy.data.objects.remove(obj, do_unlink=True)

    # Limpiar colecciones anteriores
    for c_name in ["Baston_Magico", "Puesto_Entrenamiento_Magico"]:
        if c_name in bpy.data.collections:
            bpy.data.collections.remove(bpy.data.collections[c_name])

    # Crear Colección Principal
    col_main = bpy.data.collections.new("Set_Entrenamiento_Magico_Roblox")
    bpy.context.scene.collection.children.link(col_main)

    def link_obj(obj):
        for c in list(obj.users_collection):
            c.objects.unlink(obj)
        col_main.objects.link(obj)

    # 2. Paleta Maestra de Materiales
    def make_mat(name, base_color, metallic=0.0, roughness=0.35, emission_col=None, emission_val=0.0):
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

    mat_madera_oscura = make_mat("Madera_Caoba", (0.12, 0.05, 0.02, 1.0), roughness=0.6)
    mat_madera_clara = make_mat("Madera_Clara", (0.58, 0.38, 0.20, 1.0), roughness=0.6)
    mat_enredadera = make_mat("Enredadera_Viva", (0.12, 0.22, 0.07, 1.0), roughness=0.5)
    mat_oro = make_mat("Oro_Celestial", (1.0, 0.80, 0.22, 1.0), metallic=0.98, roughness=0.18)
    mat_hierro = make_mat("Hierro_Forjado", (0.15, 0.15, 0.18, 1.0), metallic=0.85, roughness=0.35)
    mat_piedra = make_mat("Piedra_Dais", (0.24, 0.25, 0.28, 1.0), roughness=0.7)
    mat_tela_burlap = make_mat("Tela_Saco", (0.70, 0.60, 0.44, 1.0), roughness=0.85)
    mat_cuerda = make_mat("Cuerda_Cañamo", (0.44, 0.36, 0.26, 1.0), roughness=0.9)
    mat_sombrero = make_mat("Gorro_Mago_Violeta", (0.18, 0.08, 0.32, 1.0), roughness=0.5)
    mat_cuero_azul = make_mat("Cuero_Azul_Arcano", (0.05, 0.08, 0.18, 1.0), roughness=0.7)
    
    # Materiales Mágicos con Alta Emisión
    mat_cristal_arcano = make_mat("Cristal_Arcano_Purpura", (0.9, 0.15, 1.0, 1.0), roughness=0.05, emission_col=(0.95, 0.2, 1.0, 1.0), emission_val=8.0)
    mat_runa_cian = make_mat("Runa_Luz_Cian", (0.1, 0.95, 1.0, 1.0), roughness=0.08, emission_col=(0.1, 0.95, 1.0, 1.0), emission_val=12.0)
    mat_diana_fuego = make_mat("Diana_Fuego_Impacto", (1.0, 0.25, 0.05, 1.0), roughness=0.1, emission_col=(1.0, 0.3, 0.05, 1.0), emission_val=10.0)
    mat_escudo_energia = make_mat("Escudo_Energia", (0.85, 0.2, 1.0, 0.7), roughness=0.1, emission_col=(0.9, 0.2, 1.0, 1.0), emission_val=10.0)
    mat_brote_esmeralda = make_mat("Brote_Esmeralda", (0.1, 1.0, 0.4, 1.0), roughness=0.1, emission_col=(0.1, 1.0, 0.4, 1.0), emission_val=7.0)
    mat_mana_pocion = make_mat("Pocion_Mana_Azul", (0.05, 0.45, 1.0, 1.0), roughness=0.1, emission_col=(0.1, 0.55, 1.0, 1.0), emission_val=8.0)
    mat_fuego_azul = make_mat("Fuego_Espiritual", (0.1, 0.85, 1.0, 1.0), roughness=0.0, emission_col=(0.1, 0.85, 1.0, 1.0), emission_val=14.0)

    # =============================================================
    # MÓDULO 1: BASTÓN MÁGICO + PEDESTAL (X = -4.5)
    # =============================================================
    bx_pos = -4.5
    # Pedestal de piedra con anillo de oro
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.45, depth=0.08, location=(bx_pos, 0, 0.04))
    ped = bpy.context.active_object
    ped.name = "Bastón_Pedestal_Piedra"
    link_obj(ped)
    ped.data.materials.append(mat_piedra)
    bpy.ops.object.shade_flat()

    bpy.ops.mesh.primitive_torus_add(major_radius=0.46, minor_radius=0.015, location=(bx_pos, 0, 0.08), major_segments=24, minor_segments=8)
    ped_ring = bpy.context.active_object
    ped_ring.name = "Bastón_Pedestal_Anillo_Oro"
    link_obj(ped_ring)
    ped_ring.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # Vara de madera caoba
    bpy.ops.mesh.primitive_cylinder_add(radius=0.038, depth=1.85, location=(bx_pos, 0, 0.965), vertices=20)
    staff_shaft = bpy.context.active_object
    staff_shaft.name = "Bastón_Vara_Madera"
    link_obj(staff_shaft)
    staff_shaft.data.materials.append(mat_madera_oscura)
    bpy.ops.object.shade_smooth()

    # Regatón inferior de oro
    bpy.ops.mesh.primitive_cone_add(radius1=0.045, radius2=0.02, depth=0.16, location=(bx_pos, 0, 0.12), vertices=16)
    ferrule = bpy.context.active_object
    ferrule.name = "Bastón_Regaton_Oro"
    ferrule.rotation_euler[0] = math.pi
    link_obj(ferrule)
    ferrule.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # Mini cristal de remate inferior
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.025, location=(bx_pos, 0, 0.03))
    base_gem = bpy.context.active_object
    base_gem.name = "Bastón_Cristal_Base"
    base_gem.scale = (0.7, 0.7, 1.8)
    link_obj(base_gem)
    base_gem.data.materials.append(mat_cristal_arcano)
    bpy.ops.object.shade_flat()

    # Empuñadura de cuero azul arcano con anillos de oro
    for i in range(8):
        z_pos = 0.76 + i * 0.042
        bpy.ops.mesh.primitive_cylinder_add(radius=0.045, depth=0.035, location=(bx_pos, 0, z_pos), vertices=16)
        c = bpy.context.active_object
        c.name = f"Bastón_Cuero_Agarre_{i+1}"
        link_obj(c)
        c.data.materials.append(mat_cuero_azul)
        bpy.ops.object.shade_smooth()

    for z_pos in [0.73, 1.12]:
        bpy.ops.mesh.primitive_torus_add(major_radius=0.047, minor_radius=0.009, location=(bx_pos, 0, z_pos), major_segments=24, minor_segments=10)
        r = bpy.context.active_object
        r.name = "Bastón_Anillo_Oro_Empunadura"
        link_obj(r)
        r.data.materials.append(mat_oro)
        bpy.ops.object.shade_smooth()

    # Doble enredadera viva en espiral con brotes de esmeralda
    for vine_idx, phase_offset in enumerate([0.0, math.pi]):
        curve_data = bpy.data.curves.new(name=f"Curva_Enredadera_{vine_idx+1}", type='CURVE')
        curve_data.dimensions = '3D'
        curve_data.bevel_depth = 0.012
        curve_data.bevel_resolution = 4
        spline = curve_data.splines.new(type='BEZIER')
        
        num_points = 26
        spline.bezier_points.add(num_points - 1)
        total_height = 1.70
        start_z = 0.24
        turns = 4.2
        for p_idx in range(num_points):
            frac = p_idx / (num_points - 1)
            cur_z = start_z + frac * total_height
            angle = frac * turns * 2 * math.pi + phase_offset
            r_dist = 0.043 + 0.007 * math.sin(frac * 12)
            px = bx_pos + math.cos(angle) * r_dist
            py = math.sin(angle) * r_dist
            bp = spline.bezier_points[p_idx]
            bp.co = (px, py, cur_z)
            bp.handle_left_type = 'AUTO'
            bp.handle_right_type = 'AUTO'

        vine_obj = bpy.data.objects.new(f"Bastón_Enredadera_{vine_idx+1}", curve_data)
        link_obj(vine_obj)
        vine_obj.data.materials.append(mat_enredadera)

        for bud_idx in range(5):
            frac = 0.15 + bud_idx * 0.17
            cur_z = start_z + frac * total_height
            angle = frac * turns * 2 * math.pi + phase_offset
            bx = bx_pos + math.cos(angle) * 0.057
            by = math.sin(angle) * 0.057
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.012, location=(bx, by, cur_z))
            bud = bpy.context.active_object
            bud.name = f"Bastón_Brote_Cristal_{vine_idx+1}_{bud_idx+1}"
            link_obj(bud)
            bud.data.materials.append(mat_brote_esmeralda)
            bpy.ops.object.shade_flat()

    # Corona de Luna Creciente
    moon_curve = bpy.data.curves.new(name="Curva_Luna_Creciente", type='CURVE')
    moon_curve.dimensions = '3D'
    moon_curve.bevel_depth = 0.02
    moon_curve.bevel_resolution = 6
    moon_spline = moon_curve.splines.new(type='BEZIER')
    num_moon_pts = 19
    moon_spline.bezier_points.add(num_moon_pts - 1)
    center_z = 2.19
    moon_radius = 0.22
    for m_idx in range(num_moon_pts):
        t = (m_idx / (num_moon_pts - 1)) * 2 - 1
        theta = t * (math.pi * 0.88)
        taper = (1.0 - abs(t) ** 2)
        r = moon_radius + 0.03 * taper
        mx = bx_pos + math.cos(theta) * r
        mz = center_z + math.sin(theta) * r * 1.15
        bp = moon_spline.bezier_points[m_idx]
        bp.co = (mx, 0, mz)
        bp.radius = 0.3 + 1.2 * taper
        bp.handle_left_type = 'AUTO'
        bp.handle_right_type = 'AUTO'
        
    moon_obj = bpy.data.objects.new("Bastón_Corona_Luna", moon_curve)
    link_obj(moon_obj)
    moon_obj.data.materials.append(mat_oro)

    # Base de la luna y alas de soporte
    bpy.ops.mesh.primitive_cone_add(radius1=0.042, radius2=0.08, depth=0.14, location=(bx_pos, 0, 1.94), vertices=20)
    neck = bpy.context.active_object
    neck.name = "Bastón_Soporte_Luna_Oro"
    link_obj(neck)
    neck.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    for side in [-1, 1]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.02, radius2=0.004, depth=0.22, location=(bx_pos + side * 0.08, 0, 2.02), vertices=12)
        wing_horn = bpy.context.active_object
        wing_horn.name = f"Bastón_Ala_{'L' if side < 0 else 'R'}"
        wing_horn.rotation_euler = (0, side * 0.5, 0)
        link_obj(wing_horn)
        wing_horn.data.materials.append(mat_oro)
        bpy.ops.object.shade_smooth()

    # Corazón del Bastón (Gema Púrpura Imperial)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.085, location=(bx_pos, 0, center_z))
    heart_gem = bpy.context.active_object
    heart_gem.name = "Bastón_Corazon_Arcano"
    heart_gem.scale = (0.85, 0.85, 1.45)
    link_obj(heart_gem)
    heart_gem.data.materials.append(mat_cristal_arcano)
    bpy.ops.object.shade_flat()

    # Anillo orbital dorado
    bpy.ops.mesh.primitive_torus_add(major_radius=0.155, minor_radius=0.007, location=(bx_pos, 0, center_z), major_segments=32, minor_segments=8)
    orbit1 = bpy.context.active_object
    orbit1.name = "Bastón_Anillo_Orbital"
    orbit1.rotation_euler = (0.5, 0.4, 0.0)
    link_obj(orbit1)
    orbit1.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # 5 Runas flotantes cian orbitando el corazón
    for r_idx in range(5):
        angle = (r_idx / 5) * 2 * math.pi
        rx = bx_pos + math.cos(angle) * 0.17
        ry = math.sin(angle) * 0.17
        rz = center_z + 0.04 * math.sin(angle * 2)
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.022, radius2=0.0, depth=0.045, location=(rx, ry, rz))
        rune_top = bpy.context.active_object
        rune_top.name = f"Bastón_Runa_Flotante_{r_idx+1}"
        rune_top.rotation_euler = (0.2 * math.cos(angle), 0.2 * math.sin(angle), angle)
        link_obj(rune_top)
        rune_top.data.materials.append(mat_runa_cian)
        bpy.ops.object.shade_flat()

    # Luz del corazón
    light_staff_data = bpy.data.lights.new(name="Luz_Baston_Data", type='POINT')
    light_staff_data.color = (0.9, 0.2, 1.0)
    light_staff_data.energy = 60.0
    light_staff = bpy.data.objects.new("Bastón_Luz_Obj", light_staff_data)
    light_staff.location = (bx_pos, 0, center_z)
    link_obj(light_staff)

    # =============================================================
    # MÓDULO 2: MUÑECO DE ENTRENAMIENTO + ESCUDO ARCANO (X = -1.8)
    # =============================================================
    dx = -1.8
    # Poste vertical
    bpy.ops.mesh.primitive_cylinder_add(radius=0.09, depth=1.9, location=(dx, 0, 0.95), vertices=12)
    dummy_pole = bpy.context.active_object
    dummy_pole.name = "Dummy_Poste_Madera"
    link_obj(dummy_pole)
    dummy_pole.data.materials.append(mat_madera_clara)
    bpy.ops.object.shade_smooth()

    # Base en cruz
    for rot in [0, math.pi / 2]:
        bpy.ops.mesh.primitive_cube_add(size=0.16, location=(dx, 0, 0.08))
        c_beam = bpy.context.active_object
        c_beam.name = "Dummy_Base_Cruz"
        c_beam.scale = (4.0, 0.8, 0.8)
        c_beam.rotation_euler[2] = rot
        link_obj(c_beam)
        c_beam.data.materials.append(mat_madera_clara)
        bpy.ops.object.shade_flat()

    # Torso de arpillera
    bpy.ops.mesh.primitive_cylinder_add(radius=0.24, depth=0.75, location=(dx, 0, 1.15), vertices=14)
    dummy_torso = bpy.context.active_object
    dummy_torso.name = "Dummy_Torso_Saco"
    dummy_torso.scale = (1.1, 0.85, 1.0)
    link_obj(dummy_torso)
    dummy_torso.data.materials.append(mat_tela_burlap)
    bpy.ops.object.shade_smooth()

    # Cuerdas del torso
    for rz in [0.9, 1.25, 1.45]:
        bpy.ops.mesh.primitive_torus_add(major_radius=0.23, minor_radius=0.02, location=(dx, 0, rz), major_segments=16, minor_segments=8)
        rope = bpy.context.active_object
        rope.name = "Dummy_Cuerda"
        link_obj(rope)
        rope.data.materials.append(mat_cuerda)
        bpy.ops.object.shade_smooth()

    # Diana de impacto incandescente
    bpy.ops.mesh.primitive_cylinder_add(radius=0.14, depth=0.02, location=(dx, -0.21, 1.18), vertices=16)
    target_disk = bpy.context.active_object
    target_disk.name = "Dummy_Diana_Magica"
    target_disk.rotation_euler[0] = math.pi / 2
    link_obj(target_disk)
    target_disk.data.materials.append(mat_diana_fuego)
    bpy.ops.object.shade_smooth()

    bpy.ops.mesh.primitive_torus_add(major_radius=0.15, minor_radius=0.015, location=(dx, -0.21, 1.18), major_segments=16, minor_segments=8)
    t_ring = bpy.context.active_object
    t_ring.name = "Dummy_Diana_Borde"
    t_ring.rotation_euler[0] = math.pi / 2
    link_obj(t_ring)
    t_ring.data.materials.append(mat_hierro)
    bpy.ops.object.shade_smooth()

    # Brazos con guantes
    bpy.ops.mesh.primitive_cylinder_add(radius=0.065, depth=1.1, location=(dx, 0, 1.35), vertices=10)
    dummy_arms = bpy.context.active_object
    dummy_arms.name = "Dummy_Brazos"
    dummy_arms.rotation_euler[1] = math.pi / 2
    link_obj(dummy_arms)
    dummy_arms.data.materials.append(mat_madera_clara)
    bpy.ops.object.shade_smooth()

    for arm_sign in [-1, 1]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.10, location=(dx + arm_sign * 0.55, 0, 1.35), segments=12, ring_count=8)
        glove = bpy.context.active_object
        glove.name = f"Dummy_Guante_{'L' if arm_sign < 0 else 'R'}"
        link_obj(glove)
        glove.data.materials.append(mat_tela_burlap)
        bpy.ops.object.shade_smooth()

    # Cabeza y gorro de mago
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(dx, 0, 1.70), segments=14, ring_count=10)
    dummy_head = bpy.context.active_object
    dummy_head.name = "Dummy_Cabeza"
    link_obj(dummy_head)
    dummy_head.data.materials.append(mat_tela_burlap)
    bpy.ops.object.shade_smooth()

    for eye_sign in [-1, 1]:
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.025, radius2=0, depth=0.04, location=(dx + eye_sign * 0.065, -0.16, 1.72))
        eye = bpy.context.active_object
        eye.name = f"Dummy_Ojo_{'L' if eye_sign < 0 else 'R'}"
        eye.rotation_euler = (math.pi / 2, 0, 0)
        link_obj(eye)
        eye.data.materials.append(mat_diana_fuego)
        bpy.ops.object.shade_flat()

    bpy.ops.mesh.primitive_cylinder_add(radius=0.30, depth=0.03, location=(dx, 0, 1.83), vertices=16)
    hat_brim = bpy.context.active_object
    hat_brim.name = "Dummy_Gorro_Ala"
    link_obj(hat_brim)
    hat_brim.data.materials.append(mat_sombrero)
    bpy.ops.object.shade_smooth()

    bpy.ops.mesh.primitive_cone_add(radius1=0.20, radius2=0.02, depth=0.38, location=(dx, -0.02, 2.01), vertices=14)
    hat_cone = bpy.context.active_object
    hat_cone.name = "Dummy_Gorro_Cono"
    hat_cone.rotation_euler[0] = 0.22
    link_obj(hat_cone)
    hat_cone.data.materials.append(mat_sombrero)
    bpy.ops.object.shade_smooth()

    bpy.ops.mesh.primitive_torus_add(major_radius=0.19, minor_radius=0.015, location=(dx, 0, 1.86), major_segments=16, minor_segments=8)
    hat_band = bpy.context.active_object
    hat_band.name = "Dummy_Gorro_Cinta"
    link_obj(hat_band)
    hat_band.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # Escudo Arcano de Energía Flotante junto al dummy
    sh_x, sh_y, sh_z = dx + 0.6, -0.45, 1.25
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.32, depth=0.015, location=(sh_x, sh_y, sh_z))
    shield_core = bpy.context.active_object
    shield_core.name = "Dummy_Escudo_Hexagonal"
    shield_core.rotation_euler = (0.2, -0.2, 0.4)
    link_obj(shield_core)
    shield_core.data.materials.append(mat_escudo_energia)
    bpy.ops.object.shade_flat()

    bpy.ops.mesh.primitive_torus_add(major_radius=0.33, minor_radius=0.018, location=(sh_x, sh_y, sh_z), major_segments=6, minor_segments=6)
    shield_rim = bpy.context.active_object
    shield_rim.name = "Dummy_Escudo_Borde"
    shield_rim.rotation_euler = (0.2, -0.2, 0.4)
    link_obj(shield_rim)
    shield_rim.data.materials.append(mat_oro)
    bpy.ops.object.shade_flat()

    light_sh_data = bpy.data.lights.new(name="Luz_Escudo_Data", type='POINT')
    light_sh_data.color = (0.85, 0.2, 1.0)
    light_sh_data.energy = 40.0
    light_sh = bpy.data.objects.new("Dummy_Luz_Escudo", light_sh_data)
    light_sh.location = (sh_x, sh_y - 0.15, sh_z)
    link_obj(light_sh)

    # =============================================================
    # MÓDULO 3: ATRIL DE GRIMORIO + HOLOGRAMA RÚNICO (X = +0.5)
    # =============================================================
    lx = 0.5
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.18, depth=0.95, location=(lx, 0, 0.475))
    lectern_base = bpy.context.active_object
    lectern_base.name = "Atril_Pedestal_Piedra"
    link_obj(lectern_base)
    lectern_base.data.materials.append(mat_piedra)
    bpy.ops.object.shade_flat()

    bpy.ops.mesh.primitive_cube_add(size=0.35, location=(lx, 0, 0.98))
    lectern_top = bpy.context.active_object
    lectern_top.name = "Atril_Tabla_Madera"
    lectern_top.scale = (1.2, 0.9, 0.08)
    lectern_top.rotation_euler[0] = 0.45
    link_obj(lectern_top)
    lectern_top.data.materials.append(mat_madera_clara)
    bpy.ops.object.shade_flat()

    bpy.ops.mesh.primitive_cube_add(size=0.30, location=(lx, -0.02, 1.02))
    book = bpy.context.active_object
    book.name = "Grimorio_Tapas"
    book.scale = (1.1, 0.7, 0.05)
    book.rotation_euler[0] = 0.45
    link_obj(book)
    book.data.materials.append(mat_sombrero)
    bpy.ops.object.shade_flat()

    bpy.ops.mesh.primitive_cube_add(size=0.26, location=(lx, -0.02, 1.035))
    pages = bpy.context.active_object
    pages.name = "Grimorio_Paginas_Luz"
    pages.scale = (1.0, 0.62, 0.03)
    pages.rotation_euler[0] = 0.45
    link_obj(pages)
    pages.data.materials.append(mat_runa_cian)
    bpy.ops.object.shade_flat()

    # Holograma rúnico flotante
    bpy.ops.mesh.primitive_torus_add(major_radius=0.22, minor_radius=0.008, location=(lx, 0, 1.32), major_segments=24, minor_segments=8)
    holo1 = bpy.context.active_object
    holo1.name = "Grimorio_Holo_Anillo_1"
    holo1.rotation_euler = (0.45, 0, 0)
    link_obj(holo1)
    holo1.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    bpy.ops.mesh.primitive_torus_add(major_radius=0.14, minor_radius=0.006, location=(lx, 0, 1.36), major_segments=24, minor_segments=8)
    holo2 = bpy.context.active_object
    holo2.name = "Grimorio_Holo_Anillo_2"
    holo2.rotation_euler = (0.45, 0, 0)
    link_obj(holo2)
    holo2.data.materials.append(mat_runa_cian)
    bpy.ops.object.shade_smooth()

    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.04, radius2=0, depth=0.08, location=(lx, 0, 1.38))
    glyph = bpy.context.active_object
    glyph.name = "Grimorio_Glifo_Flotante"
    glyph.rotation_euler = (0.45, 0, 0)
    link_obj(glyph)
    glyph.data.materials.append(mat_oro)
    bpy.ops.object.shade_flat()

    light_bk_data = bpy.data.lights.new(name="Luz_Grimorio_Data", type='POINT')
    light_bk_data.color = (1.0, 0.85, 0.3)
    light_bk_data.energy = 45.0
    light_bk = bpy.data.objects.new("Grimorio_Luz", light_bk_data)
    light_bk.location = (lx, 0, 1.40)
    link_obj(light_bk)

    # =============================================================
    # MÓDULO 4: ESTACIÓN DE MANÁ Y POCIONES (X = +2.4)
    # =============================================================
    bx = 2.4
    bpy.ops.mesh.primitive_cylinder_add(radius=0.26, depth=0.65, location=(bx, 0, 0.325), vertices=12)
    barrel = bpy.context.active_object
    barrel.name = "Barril_Madera"
    link_obj(barrel)
    barrel.data.materials.append(mat_madera_clara)
    bpy.ops.object.shade_smooth()

    for bz in [0.12, 0.52]:
        bpy.ops.mesh.primitive_torus_add(major_radius=0.265, minor_radius=0.015, location=(bx, 0, bz), major_segments=16, minor_segments=8)
        bring = bpy.context.active_object
        bring.name = "Barril_Aro_Hierro"
        link_obj(bring)
        bring.data.materials.append(mat_hierro)
        bpy.ops.object.shade_smooth()

    for p_i, p_col in enumerate([mat_mana_pocion, mat_diana_fuego]):
        p_off = (p_i - 0.5) * 0.18
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.065, location=(bx + p_off, 0, 0.70), segments=10, ring_count=8)
        flask = bpy.context.active_object
        flask.name = f"Pocion_Frasco_{p_i+1}"
        link_obj(flask)
        flask.data.materials.append(p_col)
        bpy.ops.object.shade_smooth()

        bpy.ops.mesh.primitive_cylinder_add(radius=0.02, depth=0.05, location=(bx + p_off, 0, 0.76), vertices=8)
        cork = bpy.context.active_object
        cork.name = f"Pocion_Cuello_{p_i+1}"
        link_obj(cork)
        cork.data.materials.append(mat_cuerda)
        bpy.ops.object.shade_flat()

    # =============================================================
    # MÓDULO 5: ARENA OCTAGONAL + MONOLITO DE MANÁ (X = +6.0)
    # =============================================================
    ax = 6.0
    # Plataforma octagonal
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.2, depth=0.16, location=(ax, 0, 0.08))
    dais = bpy.context.active_object
    dais.name = "Arena_Plataforma_Piedra"
    link_obj(dais)
    dais.data.materials.append(mat_piedra)
    bpy.ops.object.shade_flat()

    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.35, depth=0.08, location=(ax, 0, 0.04))
    step = bpy.context.active_object
    step.name = "Arena_Borde_Hierro"
    link_obj(step)
    step.data.materials.append(mat_hierro)
    bpy.ops.object.shade_flat()

    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.6, depth=0.005, location=(ax, 0, 0.165))
    rune_floor = bpy.context.active_object
    rune_floor.name = "Arena_Circulo_Runico"
    link_obj(rune_floor)
    rune_floor.data.materials.append(mat_runa_cian)

    bpy.ops.mesh.primitive_torus_add(major_radius=1.65, minor_radius=0.02, location=(ax, 0, 0.17), major_segments=32, minor_segments=8)
    rune_ring = bpy.context.active_object
    rune_ring.name = "Arena_Anillo_Borde_Oro"
    link_obj(rune_ring)
    rune_ring.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # 4 Pilares con Fuego Espiritual y anillos dorados
    for i in range(4):
        ang = i * (math.pi / 2) + math.pi / 4
        px = ax + math.cos(ang) * 1.95
        py = math.sin(ang) * 1.95
        
        bpy.ops.mesh.primitive_cube_add(size=0.25, location=(px, py, 0.35))
        pillar = bpy.context.active_object
        pillar.name = f"Arena_Pilar_{i+1}"
        pillar.scale = (1, 1, 2.2)
        link_obj(pillar)
        pillar.data.materials.append(mat_piedra)
        bpy.ops.object.shade_flat()

        # Fuego fatuo místico
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.09, location=(px, py, 0.85))
        flame = bpy.context.active_object
        flame.name = f"Arena_Llama_Fuego_{i+1}"
        flame.scale = (0.8, 0.8, 1.4)
        link_obj(flame)
        flame.data.materials.append(mat_fuego_azul)
        bpy.ops.object.shade_smooth()

        bpy.ops.mesh.primitive_torus_add(major_radius=0.13, minor_radius=0.007, location=(px, py, 0.85), major_segments=16, minor_segments=6)
        f_ring = bpy.context.active_object
        f_ring.name = f"Arena_Anillo_Llama_{i+1}"
        f_ring.rotation_euler = (0.3, 0.3 * i, 0.5)
        link_obj(f_ring)
        f_ring.data.materials.append(mat_oro)
        bpy.ops.object.shade_smooth()

    # Gran Monolito de Cristal de Maná Biterminado Flotante en el centro
    cz = 1.45
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.28, radius2=0.0, depth=0.85, location=(ax, 0, cz + 0.1))
    cryst_top = bpy.context.active_object
    cryst_top.name = "Arena_Monolito_Top"
    link_obj(cryst_top)
    cryst_top.data.materials.append(mat_runa_cian)
    bpy.ops.object.shade_flat()

    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.28, radius2=0.0, depth=0.55, location=(ax, 0, cz - 0.25))
    cryst_bot = bpy.context.active_object
    cryst_bot.name = "Arena_Monolito_Bottom"
    cryst_bot.rotation_euler[0] = math.pi
    link_obj(cryst_bot)
    cryst_bot.data.materials.append(mat_runa_cian)
    bpy.ops.object.shade_flat()

    for s_idx in range(3):
        s_ang = s_idx * (2 * math.pi / 3)
        sx = ax + math.cos(s_ang) * 0.55
        sy = math.sin(s_ang) * 0.55
        sz = cz + 0.1 * math.sin(s_ang * 2)
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.065, radius2=0.0, depth=0.22, location=(sx, sy, sz))
        sat = bpy.context.active_object
        sat.name = f"Arena_Cristal_Satelite_{s_idx+1}"
        sat.rotation_euler = (0.2, 0.3 * s_idx, s_ang)
        link_obj(sat)
        sat.data.materials.append(mat_cristal_arcano)
        bpy.ops.object.shade_flat()

    light_core_data = bpy.data.lights.new(name="Luz_Arena_Data", type='POINT')
    light_core_data.color = (0.1, 0.95, 1.0)
    light_core_data.energy = 160.0
    light_core = bpy.data.objects.new("Arena_Luz_Core", light_core_data)
    light_core.location = (ax, 0, cz)
    link_obj(light_core)

    # =============================================================
    # 3. ENCUADRE DE LA VISTA 3D Y GUARDADO
    # =============================================================
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

    bpy.ops.object.select_all(action='DESELECT')

    # Guardar archivo .blend
    bpy.ops.wm.save_as_mainfile(filepath=r"c:\Users\Antonio Garcia\Downloads\blender\Baston_Magico.blend")
    
    # Exportar archivo FBX
    bpy.ops.export_scene.fbx(
        filepath=r"c:\Users\Antonio Garcia\Downloads\blender\Puesto_Entrenamiento_Roblox.fbx",
        use_selection=False,
        global_scale=1.0,
        apply_scale_options='FBX_SCALE_ALL'
    )

    print(">>> Reconstrucción completa: todo el set de entrenamiento mágico recreado de forma impecable! <<<")

rebuild_all()
