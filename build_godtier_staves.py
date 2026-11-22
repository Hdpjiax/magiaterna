import bpy
import math
import random

def build_godtier_staves():
    random.seed(777)

    # =================================================================
    # 1. SHADERS PBR MAESTROS Y EMISIVOS DE ALTA INTENSIDAD
    # =================================================================
    def get_or_make_mat(name, color, metallic=0.0, roughness=0.5, emission=None, emission_val=0.0):
        mat = bpy.data.materials.get(name)
        if not mat:
            mat = bpy.data.materials.new(name=name)
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes.get("Principled BSDF")
        if bsdf:
            if "Base Color" in bsdf.inputs:
                bsdf.inputs["Base Color"].default_value = color
            if "Metallic" in bsdf.inputs:
                bsdf.inputs["Metallic"].default_value = metallic
            if "Roughness" in bsdf.inputs:
                bsdf.inputs["Roughness"].default_value = roughness
            if emission and "Emission Color" in bsdf.inputs:
                bsdf.inputs["Emission Color"].default_value = emission
                if "Emission Strength" in bsdf.inputs:
                    bsdf.inputs["Emission Strength"].default_value = emission_val
            elif emission and "Emission" in bsdf.inputs:
                bsdf.inputs["Emission"].default_value = emission
                if "Emission Strength" in bsdf.inputs:
                    bsdf.inputs["Emission Strength"].default_value = emission_val
        return mat

    # Maderas de alta gama
    m_wood_rustic = get_or_make_mat("GT_Madera_Rustica", (0.32, 0.19, 0.10, 1.0), roughness=0.85)
    m_wood_polished = get_or_make_mat("GT_Madera_Pulida", (0.44, 0.22, 0.08, 1.0), roughness=0.40)
    m_wood_ebony = get_or_make_mat("GT_Madera_Ebano", (0.08, 0.04, 0.02, 1.0), roughness=0.45)
    m_obsidian = get_or_make_mat("GT_Obsidiana_Pura", (0.02, 0.02, 0.04, 1.0), metallic=0.45, roughness=0.08)
    m_wood_divine = get_or_make_mat("GT_Madera_Divina", (0.92, 0.90, 0.85, 1.0), roughness=0.25)
    m_vine = get_or_make_mat("GT_Enredadera_Viva", (0.12, 0.28, 0.07, 1.0), roughness=0.45)

    # Telas, cueros y vendajes
    m_bandage = get_or_make_mat("GT_Vendaje_Tela", (0.75, 0.70, 0.58, 1.0), roughness=0.9)
    m_rope = get_or_make_mat("GT_Cuerda_Cañamo", (0.35, 0.27, 0.17, 1.0), roughness=0.95)
    m_leather_black = get_or_make_mat("GT_Cuero_Negro", (0.05, 0.05, 0.06, 1.0), roughness=0.75)
    m_leather_blue = get_or_make_mat("GT_Cuero_Azul_Real", (0.04, 0.08, 0.24, 1.0), roughness=0.60)
    m_ribbon_gold = get_or_make_mat("GT_Cinta_Dorada", (0.95, 0.75, 0.15, 1.0), roughness=0.45)
    m_ribbon_red = get_or_make_mat("GT_Cinta_Carmesi", (0.80, 0.05, 0.10, 1.0), roughness=0.65)
    m_feather = get_or_make_mat("GT_Pluma_Amuleto", (0.15, 0.60, 0.80, 1.0), roughness=0.55)

    # Metales
    m_bronze = get_or_make_mat("GT_Bronce_Forjado", (0.78, 0.46, 0.18, 1.0), metallic=0.92, roughness=0.26)
    m_silver = get_or_make_mat("GT_Plata_Estelar", (0.88, 0.90, 0.95, 1.0), metallic=0.97, roughness=0.15)
    m_gold = get_or_make_mat("GT_Oro_Celestial", (1.0, 0.82, 0.22, 1.0), metallic=0.98, roughness=0.14)
    m_divine_gold = get_or_make_mat("GT_Oro_Cosmico", (1.0, 0.95, 0.50, 1.0), metallic=1.0, roughness=0.08, emission=(1.0, 0.90, 0.40, 1.0), emission_val=4.0)

    # Gemas con brillo radiante e iluminación de alta intensidad
    m_gem_t1 = get_or_make_mat("GT_Gem_T1_Fosforo", (0.2, 0.95, 0.75, 1.0), roughness=0.2, emission=(0.25, 1.0, 0.80, 1.0), emission_val=4.0)
    m_gem_t2 = get_or_make_mat("GT_Gem_T2_Esmeralda", (0.1, 1.0, 0.40, 1.0), roughness=0.12, emission=(0.15, 1.0, 0.45, 1.0), emission_val=7.0)
    m_gem_t3 = get_or_make_mat("GT_Gem_T3_Zafiro", (0.05, 0.70, 1.0, 1.0), roughness=0.06, emission=(0.10, 0.80, 1.0, 1.0), emission_val=10.0)
    m_gem_t4 = get_or_make_mat("GT_Gem_T4_Amatista", (0.95, 0.15, 1.0, 1.0), roughness=0.04, emission=(1.0, 0.20, 1.0, 1.0), emission_val=14.0)
    m_gem_t5 = get_or_make_mat("GT_Gem_T5_Solar", (1.0, 0.80, 0.10, 1.0), roughness=0.02, emission=(1.0, 0.85, 0.15, 1.0), emission_val=18.0)
    m_gem_t6 = get_or_make_mat("GT_Gem_T6_Cosmico", (0.05, 1.0, 0.95, 1.0), roughness=0.0, emission=(0.15, 1.0, 0.98, 1.0), emission_val=28.0)
    m_plasma_core = get_or_make_mat("GT_Plasma_Core", (1.0, 0.3, 0.9, 1.0), roughness=0.0, emission=(1.0, 0.35, 0.95, 1.0), emission_val=35.0)

    # =================================================================
    # 2. EL BASTÓN COMÚN PRINCIPAL (Obra Maestra de Aprendiz)
    # =================================================================
    col_comun_p = bpy.data.collections.get("Baston_Comun_Principal")
    if col_comun_p:
        for o in list(col_comun_p.objects):
            bpy.data.objects.remove(o, do_unlink=True)
    else:
        col_comun_p = bpy.data.collections.new("Baston_Comun_Principal")
        bpy.context.scene.collection.children.link(col_comun_p)

    def link_cp(obj):
        for c in list(obj.users_collection):
            c.objects.unlink(obj)
        col_comun_p.objects.link(obj)

    cx, cy = -2.2, 0.0
    # Pedestal de piedra rúnica
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.38, depth=0.06, location=(cx, cy, 0.03))
    b_ped = bpy.context.active_object
    b_ped.name = "Baston_Comun_Pedestal"
    link_cp(b_ped)
    b_ped.data.materials.append(m_wood_rustic)
    bpy.ops.object.shade_flat()

    # Mástil curvado esculpido
    s_crv = bpy.data.curves.new(name="Baston_Comun_Mástil_Curvo", type='CURVE')
    s_crv.dimensions = '3D'
    s_crv.bevel_depth = 0.034
    s_crv.bevel_resolution = 4
    spl = s_crv.splines.new(type='BEZIER')
    spl.bezier_points.add(4)
    pts_c = [(cx, cy, 0.05), (cx + 0.025, cy, 0.50), (cx - 0.02, cy, 1.05), (cx + 0.015, cy, 1.50), (cx, cy, 1.72)]
    for idx, pt in enumerate(pts_c):
        bp = spl.bezier_points[idx]
        bp.co = pt
        bp.handle_left_type = 'AUTO'
        bp.handle_right_type = 'AUTO'
    sh_o = bpy.data.objects.new("Baston_Comun_Mástil", s_crv)
    link_cp(sh_o)
    sh_o.data.materials.append(m_wood_rustic)

    # Doble enredadera espiral viva
    v_crv = bpy.data.curves.new(name="Baston_Comun_Enredadera", type='CURVE')
    v_crv.dimensions = '3D'
    v_crv.bevel_depth = 0.010
    v_crv.bevel_resolution = 3
    v_spl = v_crv.splines.new(type='BEZIER')
    v_spl.bezier_points.add(14)
    for p in range(15):
        frac = p / 14.0
        z = 0.15 + frac * 1.50
        ang = frac * 4.0 * 2 * math.pi
        px = cx + math.cos(ang) * 0.042
        py = cy + math.sin(ang) * 0.042
        bp = v_spl.bezier_points[p]
        bp.co = (px, py, z)
        bp.handle_left_type = 'AUTO'
        bp.handle_right_type = 'AUTO'
    v_o = bpy.data.objects.new("Baston_Comun_Enredadera", v_crv)
    link_cp(v_o)
    v_o.data.materials.append(m_vine)

    # Empuñadura de vendajes y cuerdas
    for vi in range(6):
        bpy.ops.mesh.primitive_cylinder_add(radius=0.040, depth=0.038, location=(cx, cy, 0.70 + vi * 0.042), vertices=10)
        v = bpy.context.active_object
        v.name = f"Baston_Comun_Vendaje_{vi+1}"
        link_cp(v)
        v.data.materials.append(m_bandage)
        bpy.ops.object.shade_smooth()

    # Cintas colgantes ceremoniales de aprendiz (twin ribbons)
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.004, depth=0.18, location=(cx + side * 0.035, cy, 1.52), vertices=6)
        rib = bpy.context.active_object
        rib.name = f"Baston_Comun_Cinta_{'L' if side<0 else 'R'}"
        rib.rotation_euler[1] = side * 0.15
        link_cp(rib)
        rib.data.materials.append(m_feather)
        bpy.ops.object.shade_flat()

    # Corona: 3 Ramas curvadas envolviendo la gema
    for p_i in range(3):
        ang = p_i * (2 * math.pi / 3)
        rx = cx + math.cos(ang) * 0.048
        ry = cy + math.sin(ang) * 0.048
        bpy.ops.mesh.primitive_cone_add(radius1=0.018, radius2=0.005, depth=0.24, location=(rx, ry, 1.80), vertices=8)
        pr = bpy.context.active_object
        pr.name = f"Baston_Comun_Rama_{p_i+1}"
        pr.rotation_euler = (math.sin(ang) * 0.26, -math.cos(ang) * 0.26, ang)
        link_cp(pr)
        pr.data.materials.append(m_wood_rustic)
        bpy.ops.object.shade_smooth()

    # Cristal de fósforo radiante en el centro
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.070, location=(cx, cy, 1.86))
    gem_c = bpy.context.active_object
    gem_c.name = "Baston_Comun_Cristal"
    gem_c.scale = (0.85, 0.85, 1.45)
    link_cp(gem_c)
    gem_c.data.materials.append(m_gem_t1)
    bpy.ops.object.shade_flat()

    # Anillo orbital de madera
    bpy.ops.mesh.primitive_torus_add(major_radius=0.12, minor_radius=0.008, location=(cx, cy, 1.86), major_segments=24, minor_segments=6)
    c_ring = bpy.context.active_object
    c_ring.name = "Baston_Comun_Anillo_Orbital"
    c_ring.rotation_euler = (0.45, 0.3, 0)
    link_cp(c_ring)
    c_ring.data.materials.append(m_wood_rustic)
    bpy.ops.object.shade_smooth()

    # 3 Runas flotantes de cuarzo
    for s_i in range(3):
        s_ang = s_i * (2 * math.pi / 3)
        sx = cx + math.cos(s_ang) * 0.16
        sy = cy + math.sin(s_ang) * 0.16
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.020, radius2=0, depth=0.05, location=(sx, sy, 1.86))
        rn = bpy.context.active_object
        rn.name = f"Baston_Comun_Runa_{s_i+1}"
        link_cp(rn)
        rn.data.materials.append(m_gem_t1)
        bpy.ops.object.shade_flat()


    # =================================================================
    # 3. GENERADOR DE LOS 120 BASTONES (CON MÍTICOS EXCEPCIONALES)
    # =================================================================
    rarity_configs = [
        {"tier": 1, "name": "1_Comun", "y": 4.0, "wood": m_wood_rustic, "metal": m_wood_rustic, "grip": m_bandage, "gem": m_gem_t1, "ring_mat": m_wood_rustic, "ribbon": m_feather},
        {"tier": 2, "name": "2_PocoComun", "y": 6.4, "wood": m_wood_polished, "metal": m_bronze, "grip": m_leather_black, "gem": m_gem_t2, "ring_mat": m_bronze, "ribbon": m_ribbon_gold},
        {"tier": 3, "name": "3_Raro", "y": 8.8, "wood": m_wood_ebony, "metal": m_silver, "grip": m_leather_blue, "gem": m_gem_t3, "ring_mat": m_silver, "ribbon": m_leather_blue},
        {"tier": 4, "name": "4_Epico", "y": 11.2, "wood": m_obsidian, "metal": m_silver, "grip": m_ribbon_red, "gem": m_gem_t4, "ring_mat": m_silver, "ribbon": m_ribbon_red},
        {"tier": 5, "name": "5_Legendario", "y": 13.6, "wood": m_wood_ebony, "metal": m_gold, "grip": m_leather_blue, "gem": m_gem_t5, "ring_mat": m_gold, "ribbon": m_ribbon_gold},
        {"tier": 6, "name": "6_Mitico", "y": 16.0, "wood": m_wood_divine, "metal": m_divine_gold, "grip": m_ribbon_red, "gem": m_gem_t6, "ring_mat": m_divine_gold, "ribbon": m_ribbon_gold},
    ]

    for rc in rarity_configs:
        cname = f"Rareza_{rc['name']}"
        if cname in bpy.data.collections:
            c = bpy.data.collections[cname]
            for obj in list(c.objects):
                bpy.data.objects.remove(obj, do_unlink=True)
            bpy.data.collections.remove(c)

    x_step = 1.25
    x_start = - (19 * x_step) / 2 # -11.875

    for rc in rarity_configs:
        tier = rc["tier"]
        cname = f"Rareza_{rc['name']}"
        col = bpy.data.collections.new(cname)
        bpy.context.scene.collection.children.link(col)
        
        y_pos = rc["y"]
        wood_m = rc["wood"]
        metal_m = rc["metal"]
        grip_m = rc["grip"]
        gem_m = rc["gem"]
        ring_m = rc["ring_mat"]
        ribbon_m = rc["ribbon"]

        for i in range(20):
            x_pos = x_start + i * x_step
            stave_id = f"Baston_T{tier}_{i+1:02d}"

            empty = bpy.data.objects.new(stave_id, None)
            empty.location = (x_pos, y_pos, 0)
            col.objects.link(empty)

            def add_p(obj):
                for c in list(obj.users_collection):
                    c.objects.unlink(obj)
                col.objects.link(obj)
                obj.parent = empty

            # Pedestal con anillo metálico
            bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.28, depth=0.04, location=(x_pos, y_pos, 0.02))
            ped = bpy.context.active_object
            ped.name = f"{stave_id}_Ped"
            add_p(ped)
            ped.data.materials.append(wood_m if tier <= 2 else metal_m)
            bpy.ops.object.shade_flat()

            shaft_h = 1.64 + 0.05 * tier
            shaft_rad = 0.026 + 0.002 * tier
            head_z = shaft_h
            gem_z = head_z + 0.15 + 0.025 * tier
            gem_rad = 0.050 + 0.012 * tier
            curve_sway = 0.028 * math.sin(i * 1.35)

            # -------------------------------------------------------------
            # ESPECIAL TIER 6: MÍTICO (ARQUITECTURA LEVITANTE FRACTURADA)
            # -------------------------------------------------------------
            if tier == 6:
                # El Mítico está fragmentado en 3 secciones que levitan entre sí:
                # 1. Base inferior (0 a 0.50m)
                # 2. Mango central (0.65m a 1.25m)
                # 3. Corona celestial flotante (1.45m en adelante, levitando en el aire!)
                
                # Núcleo / Haz de Energía Cósmica que une las partes flotantes
                bpy.ops.mesh.primitive_cylinder_add(radius=0.015, depth=shaft_h + 0.25, location=(x_pos, y_pos, (shaft_h + 0.25) / 2), vertices=10)
                beam_core = bpy.context.active_object
                beam_core.name = f"{stave_id}_HazCosmicoCore"
                add_p(beam_core)
                beam_core.data.materials.append(m_gem_t6)
                bpy.ops.object.shade_smooth()

                # Sección 1: Base divina
                bpy.ops.mesh.primitive_cylinder_add(radius=shaft_rad * 1.1, depth=0.45, location=(x_pos, y_pos, 0.26), vertices=12)
                sec1 = bpy.context.active_object
                sec1.name = f"{stave_id}_MástilBase"
                add_p(sec1)
                sec1.data.materials.append(wood_m)
                bpy.ops.object.shade_smooth()

                # Sección 2: Empuñadura divina levitante
                bpy.ops.mesh.primitive_cylinder_add(radius=shaft_rad * 1.25, depth=0.55, location=(x_pos, y_pos, 0.95), vertices=12)
                sec2 = bpy.context.active_object
                sec2.name = f"{stave_id}_MástilEmpunadura"
                add_p(sec2)
                sec2.data.materials.append(wood_m)
                bpy.ops.object.shade_smooth()

                # Anillos de oro cósmico delimitando las secciones levitantes
                for rz in [0.49, 0.67, 1.23, 1.45]:
                    bpy.ops.mesh.primitive_torus_add(major_radius=shaft_rad * 1.35, minor_radius=0.009, location=(x_pos, y_pos, rz), major_segments=20, minor_segments=8)
                    rng = bpy.context.active_object
                    rng.name = f"{stave_id}_AnilloLevitacion"
                    add_p(rng)
                    rng.data.materials.append(metal_m)
                    bpy.ops.object.shade_smooth()

                # Corona Divina Mítica:
                # 1. Gran Luna Creciente Celestial Doble
                for side in [-1, 1]:
                    moon_c = bpy.data.curves.new(name=f"{stave_id}_HaloMitico_{'L' if side<0 else 'R'}", type='CURVE')
                    moon_c.dimensions = '3D'
                    moon_c.bevel_depth = 0.016
                    moon_c.bevel_resolution = 4
                    m_spl = moon_c.splines.new(type='BEZIER')
                    m_spl.bezier_points.add(4)
                    m_pts = [
                        (x_pos, y_pos, head_z + 0.12),
                        (x_pos + side * 0.10, y_pos, gem_z - 0.05),
                        (x_pos + side * 0.22, y_pos, gem_z + 0.10),
                        (x_pos + side * 0.18, y_pos, gem_z + 0.28),
                        (x_pos + side * 0.05, y_pos, gem_z + 0.35)
                    ]
                    for idx, pt in enumerate(m_pts):
                        bp = m_spl.bezier_points[idx]
                        bp.co = pt
                        bp.handle_left_type = 'AUTO'
                        bp.handle_right_type = 'AUTO'
                    moon_o = bpy.data.objects.new(f"{stave_id}_HaloMitico_{'L' if side<0 else 'R'}", moon_c)
                    add_p(moon_o)
                    moon_o.data.materials.append(metal_m)

                # 2. NÚCLEO DUAL ANIDADO (Nested Dual Gem):
                # Esfera exterior de cristal cósmico facetado
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=gem_rad * 1.3, location=(x_pos, y_pos, gem_z))
                outer_gem = bpy.context.active_object
                outer_gem.name = f"{stave_id}_GemaExterior"
                outer_gem.scale = (0.9, 0.9, 1.3)
                add_p(outer_gem)
                outer_gem.data.materials.append(gem_m)
                bpy.ops.object.shade_flat()

                # Núcleo interior de plasma puro brillante
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=gem_rad * 0.65, location=(x_pos, y_pos, gem_z))
                inner_plasma = bpy.context.active_object
                inner_plasma.name = f"{stave_id}_PlasmaCore"
                add_p(inner_plasma)
                inner_plasma.data.materials.append(m_plasma_core)
                bpy.ops.object.shade_smooth()

                # 3. GIROSCOPIO DE 4 ANILLOS ORBITALES EN ESFERA ARMILAR
                for r_idx in range(4):
                    r_rad = 0.15 + r_idx * 0.04
                    bpy.ops.mesh.primitive_torus_add(major_radius=r_rad, minor_radius=0.008, location=(x_pos, y_pos, gem_z), major_segments=28, minor_segments=8)
                    arm_ring = bpy.context.active_object
                    arm_ring.name = f"{stave_id}_Armilar_{r_idx+1}"
                    arm_ring.rotation_euler = (0.7 * r_idx, 0.5 * (r_idx + 1), i * 0.3 + r_idx * 0.9)
                    add_p(arm_ring)
                    arm_ring.data.materials.append(metal_m)
                    bpy.ops.object.shade_smooth()

                # 4. CONSTELACIÓN DE 6 FRAGMENTOS DE ESTRELLA ORBITANDO A DISTINTAS ALTURAS
                for s_i in range(6):
                    s_ang = s_i * (math.pi / 3) + i * 0.3
                    sx = x_pos + math.cos(s_ang) * 0.28
                    sy = y_pos + math.sin(s_ang) * 0.28
                    sz = gem_z + 0.10 * math.sin(s_ang * 2)
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.028, radius2=0, depth=0.07, location=(sx, sy, sz))
                    star = bpy.context.active_object
                    star.name = f"{stave_id}_EstrellaCosmica_{s_i+1}"
                    add_p(star)
                    star.data.materials.append(m_plasma_core if s_i % 2 == 0 else metal_m)
                    bpy.ops.object.shade_flat()

                # 5. Contera inferior levitante con su propio anillo
                bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.035, radius2=0, depth=0.22, location=(x_pos, y_pos, -0.06))
                bot_f = bpy.context.active_object
                bot_f.name = f"{stave_id}_ConteraLevitante"
                bot_f.rotation_euler[0] = math.pi
                add_p(bot_f)
                bot_f.data.materials.append(gem_m)
                bpy.ops.object.shade_flat()

                bpy.ops.mesh.primitive_torus_add(major_radius=0.05, minor_radius=0.007, location=(x_pos, y_pos, -0.06), major_segments=16, minor_segments=6)
                bot_rng = bpy.context.active_object
                bot_rng.name = f"{stave_id}_AnilloContera"
                add_p(bot_rng)
                bot_rng.data.materials.append(metal_m)
                bpy.ops.object.shade_smooth()

                # 6. Fuente de luz puntual cósmica de alta potencia (75W)
                l_data = bpy.data.lights.new(name=f"{stave_id}_LightData", type='POINT')
                l_data.color = (0.1, 0.95, 1.0)
                l_data.energy = 75.0
                l_obj = bpy.data.objects.new(f"{stave_id}_LuzCosmica", l_data)
                l_obj.location = (x_pos, y_pos, gem_z)
                add_p(l_obj)

            # -------------------------------------------------------------
            # TIERS 1 A 5: COMÚN, POCO COMÚN, RARO, ÉPICO, LEGENDARIO
            # -------------------------------------------------------------
            else:
                # Mástil curvado esculpido
                s_curve = bpy.data.curves.new(name=f"{stave_id}_CurvaVara", type='CURVE')
                s_curve.dimensions = '3D'
                s_curve.bevel_depth = shaft_rad
                s_curve.bevel_resolution = 4
                s_spline = s_curve.splines.new(type='BEZIER')
                s_spline.bezier_points.add(3)
                pts_s = [
                    (x_pos, y_pos, 0.04),
                    (x_pos + curve_sway, y_pos, 0.50),
                    (x_pos - curve_sway * 0.7, y_pos, 1.05),
                    (x_pos, y_pos, shaft_h)
                ]
                for s_idx, s_pt in enumerate(pts_s):
                    bp = s_spline.bezier_points[s_idx]
                    bp.co = s_pt
                    bp.handle_left_type = 'AUTO'
                    bp.handle_right_type = 'AUTO'

                shaft_obj = bpy.data.objects.new(f"{stave_id}_Vara", s_curve)
                add_p(shaft_obj)
                shaft_obj.data.materials.append(wood_m)

                # Doble enredadera espiral viva
                v_turns = 2.5 + tier * 0.5
                v_curve = bpy.data.curves.new(name=f"{stave_id}_EspiralVara", type='CURVE')
                v_curve.dimensions = '3D'
                v_curve.bevel_depth = 0.007 + 0.001 * tier
                v_curve.bevel_resolution = 3
                v_spl = v_curve.splines.new(type='BEZIER')
                v_num = 12
                v_spl.bezier_points.add(v_num - 1)
                for v_i in range(v_num):
                    frac = v_i / (v_num - 1)
                    vz = 0.20 + frac * (shaft_h - 0.25)
                    vang = frac * v_turns * 2 * math.pi + (i * 0.5)
                    vr = shaft_rad * 1.25
                    vx = x_pos + math.cos(vang) * vr
                    vy = y_pos + math.sin(vang) * vr
                    bp = v_spl.bezier_points[v_i]
                    bp.co = (vx, vy, vz)
                    bp.handle_left_type = 'AUTO'
                    bp.handle_right_type = 'AUTO'

                vine_o = bpy.data.objects.new(f"{stave_id}_Espiral", v_curve)
                add_p(vine_o)
                vine_o.data.materials.append(m_vine if tier <= 3 else metal_m)

                # Brotes de cristal para tiers >= 4
                if tier >= 4:
                    for b_i in range(3):
                        b_frac = 0.3 + b_i * 0.25
                        b_z = 0.20 + b_frac * (shaft_h - 0.25)
                        b_ang = b_frac * v_turns * 2 * math.pi + (i * 0.5)
                        bx = x_pos + math.cos(b_ang) * (shaft_rad * 1.35)
                        by = y_pos + math.sin(b_ang) * (shaft_rad * 1.35)
                        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.013, location=(bx, by, b_z))
                        bud = bpy.context.active_object
                        bud.name = f"{stave_id}_Brote_{b_i+1}"
                        add_p(bud)
                        bud.data.materials.append(gem_m)
                        bpy.ops.object.shade_flat()

                # Contera inferior elaborada
                ferrule_h = 0.12 + 0.02 * tier
                bpy.ops.mesh.primitive_cone_add(vertices=6 if tier <= 3 else 8, radius1=shaft_rad * 1.35, radius2=0.004, depth=ferrule_h, location=(x_pos, y_pos, 0.04 + ferrule_h / 2))
                ferrule = bpy.context.active_object
                ferrule.name = f"{stave_id}_Contera"
                ferrule.rotation_euler[0] = math.pi
                add_p(ferrule)
                ferrule.data.materials.append(wood_m if tier == 1 else metal_m)
                bpy.ops.object.shade_flat()

                if tier >= 3:
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.016, radius2=0, depth=0.045, location=(x_pos, y_pos, -0.01))
                    bot_gem = bpy.context.active_object
                    bot_gem.name = f"{stave_id}_GemaInferior"
                    bot_gem.rotation_euler[0] = math.pi
                    add_p(bot_gem)
                    bot_gem.data.materials.append(gem_m)
                    bpy.ops.object.shade_flat()

                # Empuñadura con anillos delimitadores
                grip_z = 0.72 + 0.015 * tier
                bpy.ops.mesh.primitive_cylinder_add(radius=shaft_rad * 1.18, depth=0.24, location=(x_pos, y_pos, grip_z), vertices=12)
                grip = bpy.context.active_object
                grip.name = f"{stave_id}_Grip"
                add_p(grip)
                grip.data.materials.append(grip_m)
                bpy.ops.object.shade_smooth()

                for off in [-0.12, 0.12]:
                    bpy.ops.mesh.primitive_torus_add(major_radius=shaft_rad * 1.22, minor_radius=0.007, location=(x_pos, y_pos, grip_z + off), major_segments=16, minor_segments=6)
                    r = bpy.context.active_object
                    r.name = f"{stave_id}_AnilloGrip"
                    add_p(r)
                    r.data.materials.append(wood_m if tier == 1 else metal_m)
                    bpy.ops.object.shade_smooth()

                # Cintas ceremoniales colgantes en el cuello
                for side in [-1, 1]:
                    bpy.ops.mesh.primitive_cylinder_add(radius=0.003 + 0.001 * tier, depth=0.15 + 0.02 * tier, location=(x_pos + side * 0.035, y_pos, head_z - 0.06), vertices=6)
                    rib = bpy.context.active_object
                    rib.name = f"{stave_id}_Cinta_{'L' if side<0 else 'R'}"
                    rib.rotation_euler[1] = side * 0.18
                    add_p(rib)
                    rib.data.materials.append(ribbon_m)
                    bpy.ops.object.shade_flat()

                # Silueta de Corona (Luna Creciente, Alas Dobles, Garras, Aureola)
                arch_type = i % 4

                if arch_type == 0:
                    moon_c = bpy.data.curves.new(name=f"{stave_id}_Luna", type='CURVE')
                    moon_c.dimensions = '3D'
                    moon_c.bevel_depth = 0.014 + 0.002 * tier
                    moon_c.bevel_resolution = 4
                    m_spl = moon_c.splines.new(type='BEZIER')
                    m_pts_cnt = 11
                    m_spl.bezier_points.add(m_pts_cnt - 1)
                    moon_r = 0.15 + 0.02 * tier
                    for m_i in range(m_pts_cnt):
                        t = (m_i / (m_pts_cnt - 1)) * 2 - 1
                        theta = t * (math.pi * 0.85)
                        mx = x_pos + math.cos(theta) * moon_r
                        mz = gem_z + math.sin(theta) * moon_r * 1.15
                        bp = m_spl.bezier_points[m_i]
                        bp.co = (mx, y_pos, mz)
                        bp.radius = 0.4 + 1.0 * (1.0 - abs(t)**2)
                        bp.handle_left_type = 'AUTO'
                        bp.handle_right_type = 'AUTO'
                    moon_o = bpy.data.objects.new(f"{stave_id}_CoronaLuna", moon_c)
                    add_p(moon_o)
                    moon_o.data.materials.append(wood_m if tier == 1 else metal_m)

                elif arch_type == 1:
                    for side in [-1, 1]:
                        wing_c = bpy.data.curves.new(name=f"{stave_id}_Ala_{'L' if side<0 else 'R'}", type='CURVE')
                        wing_c.dimensions = '3D'
                        wing_c.bevel_depth = 0.014 + 0.002 * tier
                        wing_c.bevel_resolution = 4
                        w_spl = wing_c.splines.new(type='BEZIER')
                        w_spl.bezier_points.add(4)
                        w_pts = [
                            (x_pos, y_pos, head_z + 0.02),
                            (x_pos + side * 0.08, y_pos, head_z + 0.08),
                            (x_pos + side * 0.16, y_pos, gem_z + 0.05),
                            (x_pos + side * 0.13, y_pos, gem_z + 0.18),
                            (x_pos + side * 0.06, y_pos, gem_z + 0.22)
                        ]
                        for w_idx, w_pt in enumerate(w_pts):
                            bp = w_spl.bezier_points[w_idx]
                            bp.co = w_pt
                            bp.handle_left_type = 'AUTO'
                            bp.handle_right_type = 'AUTO'
                        wing_o = bpy.data.objects.new(f"{stave_id}_Ala_{'L' if side<0 else 'R'}", wing_c)
                        add_p(wing_o)
                        wing_o.data.materials.append(wood_m if tier == 1 else metal_m)

                elif arch_type == 2:
                    num_pr = 3 if tier <= 3 else 4
                    for p_idx in range(num_pr):
                        p_ang = p_idx * (2 * math.pi / num_pr)
                        px = x_pos + math.cos(p_ang) * 0.055
                        py = y_pos + math.sin(p_ang) * 0.055
                        bpy.ops.mesh.primitive_cone_add(radius1=0.016, radius2=0.004, depth=0.24 + 0.02 * tier, location=(px, py, head_z + 0.10), vertices=8)
                        claw = bpy.context.active_object
                        claw.name = f"{stave_id}_Garra_{p_idx+1}"
                        claw.rotation_euler = (math.sin(p_ang) * 0.28, -math.cos(p_ang) * 0.28, p_ang)
                        add_p(claw)
                        claw.data.materials.append(wood_m if tier == 1 else metal_m)
                        bpy.ops.object.shade_smooth()

                else:
                    bpy.ops.mesh.primitive_torus_add(major_radius=0.15 + 0.015 * tier, minor_radius=0.012, location=(x_pos, y_pos, gem_z), major_segments=24, minor_segments=8)
                    halo = bpy.context.active_object
                    halo.name = f"{stave_id}_Aureola"
                    halo.scale = (1.0, 0.3, 1.2)
                    add_p(halo)
                    halo.data.materials.append(wood_m if tier == 1 else metal_m)
                    bpy.ops.object.shade_smooth()

                # Gema Facetada Imperial
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=gem_rad, location=(x_pos, y_pos, gem_z))
                gem_obj = bpy.context.active_object
                gem_obj.name = f"{stave_id}_GemaCentral"
                gem_obj.scale = (0.85, 0.85, 1.45)
                add_p(gem_obj)
                gem_obj.data.materials.append(gem_m)
                bpy.ops.object.shade_flat()

                # Anillos orbitales flotantes
                num_rings = 1 if tier <= 2 else (2 if tier <= 4 else 3)
                for r_i in range(num_rings):
                    r_rad = 0.12 + 0.03 * r_i + 0.01 * tier
                    bpy.ops.mesh.primitive_torus_add(major_radius=r_rad, minor_radius=0.007, location=(x_pos, y_pos, gem_z), major_segments=24, minor_segments=6)
                    orb_ring = bpy.context.active_object
                    orb_ring.name = f"{stave_id}_AnilloOrbital_{r_i+1}"
                    orb_ring.rotation_euler = (0.45 * (r_i + 1), 0.35 * r_i, i * 0.3 + r_i * 0.8)
                    add_p(orb_ring)
                    orb_ring.data.materials.append(ring_m)
                    bpy.ops.object.shade_smooth()

                # Runas flotantes satélite
                num_sat = 2 if tier == 1 else (3 if tier <= 3 else (4 if tier <= 4 else 5))
                for s_i in range(num_sat):
                    s_ang = s_i * (2 * math.pi / num_sat) + i * 0.4
                    s_dist = 0.15 + 0.02 * tier
                    sx = x_pos + math.cos(s_ang) * s_dist
                    sy = y_pos + math.sin(s_ang) * s_dist
                    sz = gem_z + 0.04 * math.sin(s_ang * 2)
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.022 + 0.002 * tier, radius2=0, depth=0.05 + 0.005 * tier, location=(sx, sy, sz))
                    sat_obj = bpy.context.active_object
                    sat_obj.name = f"{stave_id}_RunaFlotante_{s_i+1}"
                    sat_obj.rotation_euler = (0.2 * math.cos(s_ang), 0.2 * math.sin(s_ang), s_ang)
                    add_p(sat_obj)
                    sat_obj.data.materials.append(gem_m)
                    bpy.ops.object.shade_flat()

    # 4. Encuadre y Guardado
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
    bpy.ops.wm.save_as_mainfile(filepath=r"c:\Users\Antonio Garcia\Downloads\blender\Baston_Magico.blend")
    print(">>> 120 BASTONES NIVEL DIOS GENERADOS CON ÉXITO! MÍTICOS Y COMUNES EXCEPCIONALES! <<<")

build_godtier_staves()
