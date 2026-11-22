import bpy
import math

def upgrade_magic_staff():
    col_name = "Baston_Magico"
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

    # 1. Paleta de Materiales Vibrantes y Contrastados
    def make_mat(name, base_color, metallic=0.0, roughness=0.3, emission_col=None, emission_val=0.0):
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

    # Madera noble caoba oscura
    mat_madera = make_mat("Madera_Ancestral", (0.10, 0.04, 0.02, 1.0), metallic=0.05, roughness=0.55)
    # Enredadera viva (madera con tinte verdoso sutil)
    mat_enredadera = make_mat("Enredadera_Magica", (0.12, 0.18, 0.06, 1.0), metallic=0.0, roughness=0.45)
    # Oro estelar brillante
    mat_oro = make_mat("Oro_Celestial", (1.0, 0.78, 0.22, 1.0), metallic=0.98, roughness=0.18)
    # Cuero teñido azul medianoche
    mat_cuero = make_mat("Cuero_Arcano", (0.04, 0.06, 0.15, 1.0), metallic=0.1, roughness=0.7)
    # Gran Cristal - Magenta/Púrpura Arcano Radiante
    mat_cristal_arcano = make_mat("Cristal_Arcano", (0.85, 0.1, 0.95, 1.0), metallic=0.1, roughness=0.05, 
                                  emission_col=(0.95, 0.15, 1.0, 1.0), emission_val=7.0)
    # Runas Flotantes - Azul Celeste / Cian Eléctrico
    mat_runa_cian = make_mat("Runa_Luz_Cian", (0.1, 0.95, 1.0, 1.0), metallic=0.0, roughness=0.1,
                             emission_col=(0.1, 0.95, 1.0, 1.0), emission_val=12.0)
    # Cristales de enredadera - Esmeralda mística
    mat_brote_esmeralda = make_mat("Brote_Esmeralda", (0.1, 1.0, 0.4, 1.0), metallic=0.0, roughness=0.2,
                                   emission_col=(0.1, 1.0, 0.4, 1.0), emission_val=6.0)

    # 2. Vara Principal (Shaft)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.038, depth=1.85, location=(0, 0, 0.925), vertices=20)
    shaft = bpy.context.active_object
    shaft.name = "Vara_Principal"
    link_obj(shaft)
    shaft.data.materials.append(mat_madera)
    bpy.ops.object.shade_smooth()

    # 3. Base / Regatón con cristal inferior
    bpy.ops.mesh.primitive_cone_add(radius1=0.045, radius2=0.02, depth=0.16, location=(0, 0, 0.08), vertices=16)
    ferrule = bpy.context.active_object
    ferrule.name = "Regaton_Oro"
    ferrule.rotation_euler[0] = math.pi
    link_obj(ferrule)
    ferrule.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # Mini cristal de remate inferior
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.025, location=(0, 0, -0.02))
    base_gem = bpy.context.active_object
    base_gem.name = "Cristal_Base"
    base_gem.scale = (0.7, 0.7, 1.8)
    link_obj(base_gem)
    base_gem.data.materials.append(mat_cristal_arcano)
    bpy.ops.object.shade_flat()

    # 4. Empuñadura de cuero azul arcano con filigranas de oro
    for i in range(8):
        z_pos = 0.72 + i * 0.042
        bpy.ops.mesh.primitive_cylinder_add(radius=0.045, depth=0.035, location=(0, 0, z_pos), vertices=16)
        c = bpy.context.active_object
        c.name = f"Empunadura_Cuero_{i+1}"
        link_obj(c)
        c.data.materials.append(mat_cuero)
        bpy.ops.object.shade_smooth()

    for z_pos in [0.69, 1.08]:
        bpy.ops.mesh.primitive_torus_add(major_radius=0.047, minor_radius=0.009, location=(0, 0, z_pos), major_segments=24, minor_segments=10)
        r = bpy.context.active_object
        r.name = "Anillo_Oro_Empunadura"
        link_obj(r)
        r.data.materials.append(mat_oro)
        bpy.ops.object.shade_smooth()

    # 5. Enredaderas Retorcidas (Twisted Vines) en espiral
    # Generar 2 enredaderas entrelazadas alrededor del tronco
    for vine_idx, phase_offset in enumerate([0.0, math.pi]):
        curve_data = bpy.data.curves.new(name=f"Curva_Enredadera_{vine_idx+1}", type='CURVE')
        curve_data.dimensions = '3D'
        curve_data.bevel_depth = 0.012
        curve_data.bevel_resolution = 4
        spline = curve_data.splines.new(type='BEZIER')
        
        num_points = 26
        spline.bezier_points.add(num_points - 1)
        
        total_height = 1.70
        start_z = 0.20
        turns = 4.2
        
        for p_idx in range(num_points):
            frac = p_idx / (num_points - 1)
            cur_z = start_z + frac * total_height
            angle = frac * turns * 2 * math.pi + phase_offset
            # Radio ligeramente variable para toque orgánico
            r_dist = 0.043 + 0.007 * math.sin(frac * 12)
            px = math.cos(angle) * r_dist
            py = math.sin(angle) * r_dist
            
            bp = spline.bezier_points[p_idx]
            bp.co = (px, py, cur_z)
            bp.handle_left_type = 'AUTO'
            bp.handle_right_type = 'AUTO'

        vine_obj = bpy.data.objects.new(f"Enredadera_{vine_idx+1}", curve_data)
        link_obj(vine_obj)
        vine_obj.data.materials.append(mat_enredadera)

        # Pequeños brotes de cristal en puntos clave de la enredadera
        for bud_idx in range(5):
            frac = 0.15 + bud_idx * 0.17
            cur_z = start_z + frac * total_height
            angle = frac * turns * 2 * math.pi + phase_offset
            bx = math.cos(angle) * (0.047 + 0.01)
            by = math.sin(angle) * (0.047 + 0.01)
            
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.012, location=(bx, by, cur_z))
            bud = bpy.context.active_object
            bud.name = f"Brote_Cristal_{vine_idx+1}_{bud_idx+1}"
            link_obj(bud)
            bud.data.materials.append(mat_brote_esmeralda)
            bpy.ops.object.shade_flat()

    # 6. Cabeza Mística: Corona de Luna Creciente (Crescent Moon)
    # Creamos un arco celestial dorado majestuoso
    moon_curve = bpy.data.curves.new(name="Curva_Luna_Creciente", type='CURVE')
    moon_curve.dimensions = '3D'
    moon_curve.bevel_depth = 0.02
    moon_curve.bevel_resolution = 6
    moon_spline = moon_curve.splines.new(type='BEZIER')
    
    num_moon_pts = 19
    moon_spline.bezier_points.add(num_moon_pts - 1)
    
    # Forma de luna creciente: arco amplio de casi 270 grados
    center_z = 2.15
    moon_radius = 0.22
    for m_idx in range(num_moon_pts):
        t = (m_idx / (num_moon_pts - 1)) * 2 - 1 # De -1 a 1
        theta = t * (math.pi * 0.88) # Ángulo del arco
        # Radio que se afina hacia las puntas
        taper = (1.0 - abs(t) ** 2)
        r = moon_radius + 0.03 * taper
        mx = math.cos(theta) * r
        mz = center_z + math.sin(theta) * r * 1.15
        
        bp = moon_spline.bezier_points[m_idx]
        bp.co = (mx, 0, mz)
        bp.radius = 0.3 + 1.2 * taper # Puntas afiladas, centro grueso
        bp.handle_left_type = 'AUTO'
        bp.handle_right_type = 'AUTO'
        
    moon_obj = bpy.data.objects.new("Corona_Luna_Creciente", moon_curve)
    link_obj(moon_obj)
    moon_obj.data.materials.append(mat_oro)

    # Base de montaje para la luna en la punta de la vara
    bpy.ops.mesh.primitive_cone_add(radius1=0.042, radius2=0.08, depth=0.14, location=(0, 0, 1.90), vertices=20)
    neck = bpy.context.active_object
    neck.name = "Soporte_Luna_Oro"
    link_obj(neck)
    neck.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # Alas / Cuernos astrales de soporte secundario
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.02, radius2=0.004, depth=0.22, location=(side * 0.08, 0, 1.98), vertices=12)
        wing_horn = bpy.context.active_object
        wing_horn.name = f"Ala_Soporte_{'L' if side < 0 else 'R'}"
        wing_horn.rotation_euler = (0, side * 0.5, 0)
        link_obj(wing_horn)
        wing_horn.data.materials.append(mat_oro)
        bpy.ops.object.shade_smooth()

    # 7. Gran Gema / Corazón del Bastón (Levitando en el centro de la Luna)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.085, location=(0, 0, center_z))
    heart_gem = bpy.context.active_object
    heart_gem.name = "Corazon_Arcano_Púrpura"
    heart_gem.scale = (0.85, 0.85, 1.45) # Alargado como diamante imperial
    link_obj(heart_gem)
    heart_gem.data.materials.append(mat_cristal_arcano)
    bpy.ops.object.shade_flat()

    # 8. Anillo rúnico orbital inclinado
    bpy.ops.mesh.primitive_torus_add(major_radius=0.155, minor_radius=0.007, location=(0, 0, center_z), major_segments=32, minor_segments=8)
    orbit1 = bpy.context.active_object
    orbit1.name = "Anillo_Orbital_Oro"
    orbit1.rotation_euler = (0.5, 0.4, 0.0)
    link_obj(orbit1)
    orbit1.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # 9. Runas Mágicas Flotantes (Gemas rúnicas de cian eléctrico orbitando alrededor)
    num_runes = 5
    for r_idx in range(num_runes):
        angle = (r_idx / num_runes) * 2 * math.pi
        rune_dist = 0.17
        rx = math.cos(angle) * rune_dist
        ry = math.sin(angle) * rune_dist
        rz = center_z + 0.04 * math.sin(angle * 2) # Ondulación vertical
        
        # Rombo rúnico (Bipirámide / Octaedro de 4 lados)
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.022, radius2=0.0, depth=0.045, location=(rx, ry, rz))
        rune_top = bpy.context.active_object
        rune_top.name = f"Runa_Flotante_{r_idx+1}"
        rune_top.rotation_euler = (0.2 * math.cos(angle), 0.2 * math.sin(angle), angle)
        link_obj(rune_top)
        rune_top.data.materials.append(mat_runa_cian)
        bpy.ops.object.shade_flat()

    # 10. Luces del Núcleo Mágico (Doble luz: púrpura interna + cian ambiental)
    light_p_data = bpy.data.lights.new(name="Luz_Purpura", type='POINT')
    light_p_data.color = (0.9, 0.2, 1.0) # Púrpura profundo
    light_p_data.energy = 80.0
    light_p_obj = bpy.data.objects.new("Luz_Purpura_Obj", light_p_data)
    light_p_obj.location = (0, 0, center_z)
    link_obj(light_p_obj)

    light_c_data = bpy.data.lights.new(name="Luz_Cian", type='POINT')
    light_c_data.color = (0.1, 0.9, 1.0) # Cian de contraste
    light_c_data.energy = 40.0
    light_c_obj = bpy.data.objects.new("Luz_Cian_Obj", light_c_data)
    light_c_obj.location = (0, 0.12, center_z + 0.05)
    link_obj(light_c_obj)

    # 11. Ajustar Vista y Sombreado
    bpy.ops.object.select_all(action='DESELECT')
    for obj in col.objects:
        obj.select_set(True)
        
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

    print(">>> Bastón Mágico Actualizado: Corona de Luna, Enredaderas, Runas Cian y Colores Vibrantes! <<<")

upgrade_magic_staff()
