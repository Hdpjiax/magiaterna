import bpy
import math
import random

def generate_sculpted_staves():
    random.seed(2026)

    # 1. Paleta Maestra de Materiales con Shaders PBR
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

    # Maderas
    m_wood_rustic = get_or_make_mat("M_Madera_Rustica", (0.32, 0.20, 0.11, 1.0), roughness=0.85)
    m_wood_polished = get_or_make_mat("M_Madera_Pulida", (0.46, 0.24, 0.10, 1.0), roughness=0.42)
    m_wood_ebony = get_or_make_mat("M_Madera_Ebano", (0.09, 0.05, 0.03, 1.0), roughness=0.45)
    m_obsidian = get_or_make_mat("M_Obsidiana_Pura", (0.03, 0.03, 0.05, 1.0), metallic=0.35, roughness=0.1)
    m_wood_divine = get_or_make_mat("M_Madera_Divina", (0.88, 0.85, 0.80, 1.0), roughness=0.3)
    m_vine = get_or_make_mat("M_Enredadera_Viva", (0.12, 0.25, 0.08, 1.0), roughness=0.5)

    # Cueros y vendas
    m_bandage = get_or_make_mat("M_Vendaje_Tela", (0.72, 0.67, 0.54, 1.0), roughness=0.9)
    m_rope = get_or_make_mat("M_Cuerda_Cañamo", (0.36, 0.28, 0.18, 1.0), roughness=0.95)
    m_leather_black = get_or_make_mat("M_Cuero_Negro", (0.06, 0.06, 0.07, 1.0), roughness=0.75)
    m_leather_blue = get_or_make_mat("M_Cuero_Azul_Real", (0.04, 0.08, 0.22, 1.0), roughness=0.65)
    m_cloth_red = get_or_make_mat("M_Cinta_Carmesi", (0.75, 0.08, 0.12, 1.0), roughness=0.7)

    # Metales
    m_bronze = get_or_make_mat("M_Bronce_Forjado", (0.75, 0.45, 0.18, 1.0), metallic=0.92, roughness=0.28)
    m_silver = get_or_make_mat("M_Plata_Estelar", (0.86, 0.89, 0.94, 1.0), metallic=0.96, roughness=0.18)
    m_gold = get_or_make_mat("M_Oro_Celestial", (1.0, 0.80, 0.20, 1.0), metallic=0.98, roughness=0.16)
    m_divine_gold = get_or_make_mat("M_Oro_Cosmico", (1.0, 0.92, 0.45, 1.0), metallic=1.0, roughness=0.10, emission=(1.0, 0.88, 0.35, 1.0), emission_val=3.0)

    # Gemas con brillo radiante escalado
    m_gem_t1 = get_or_make_mat("Gem_T1_Fosforo", (0.2, 0.9, 0.7, 1.0), roughness=0.25, emission=(0.25, 0.95, 0.75, 1.0), emission_val=3.0)
    m_gem_t2 = get_or_make_mat("Gem_T2_Esmeralda", (0.15, 0.95, 0.35, 1.0), roughness=0.15, emission=(0.2, 1.0, 0.4, 1.0), emission_val=5.5)
    m_gem_t3 = get_or_make_mat("Gem_T3_Zafiro", (0.1, 0.65, 1.0, 1.0), roughness=0.08, emission=(0.15, 0.75, 1.0, 1.0), emission_val=8.0)
    m_gem_t4 = get_or_make_mat("Gem_T4_Amatista", (0.9, 0.15, 1.0, 1.0), roughness=0.05, emission=(0.95, 0.2, 1.0, 1.0), emission_val=11.0)
    m_gem_t5 = get_or_make_mat("Gem_T5_Solar", (1.0, 0.75, 0.1, 1.0), roughness=0.03, emission=(1.0, 0.82, 0.15, 1.0), emission_val=15.0)
    m_gem_t6 = get_or_make_mat("Gem_T6_Cosmico", (0.1, 1.0, 0.95, 1.0), roughness=0.0, emission=(0.2, 1.0, 0.95, 1.0), emission_val=22.0)
    m_emerald_bud = get_or_make_mat("M_Brote_Esmeralda", (0.1, 1.0, 0.4, 1.0), roughness=0.1, emission=(0.1, 1.0, 0.4, 1.0), emission_val=7.0)

    # -----------------------------------------------------------------
    # 2. BASTÓN COMÚN PRINCIPAL (Esculpido Artesanal de Aprendiz)
    # -----------------------------------------------------------------
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
    # Pedestal
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.36, depth=0.06, location=(cx, cy, 0.03))
    b_ped = bpy.context.active_object
    b_ped.name = "Baston_Comun_Pedestal"
    link_cp(b_ped)
    b_ped.data.materials.append(m_wood_rustic)
    bpy.ops.object.shade_flat()

    # Mástil en curva orgánica de sauce
    shaft_curve = bpy.data.curves.new(name="Baston_Comun_Curva", type='CURVE')
    shaft_curve.dimensions = '3D'
    shaft_curve.bevel_depth = 0.032
    shaft_curve.bevel_resolution = 4
    spline = shaft_curve.splines.new(type='BEZIER')
    spline.bezier_points.add(4)
    # Puntos con ligera curvatura elegante
    pts = [
        (cx, cy, 0.06),
        (cx + 0.02, cy, 0.50),
        (cx - 0.015, cy, 1.00),
        (cx + 0.01, cy, 1.45),
        (cx, cy, 1.70)
    ]
    for idx, pt in enumerate(pts):
        bp = spline.bezier_points[idx]
        bp.co = pt
        bp.handle_left_type = 'AUTO'
        bp.handle_right_type = 'AUTO'
    sh_obj = bpy.data.objects.new("Baston_Comun_Vara_Curva", shaft_curve)
    link_cp(sh_obj)
    sh_obj.data.materials.append(m_wood_rustic)

    # Enredadera espiral enrollando la vara común
    vine_c = bpy.data.curves.new(name="Baston_Comun_Enredadera", type='CURVE')
    vine_c.dimensions = '3D'
    vine_c.bevel_depth = 0.009
    vine_c.bevel_resolution = 3
    v_spline = vine_c.splines.new(type='BEZIER')
    v_pts_count = 14
    v_spline.bezier_points.add(v_pts_count - 1)
    for p in range(v_pts_count):
        frac = p / (v_pts_count - 1)
        z = 0.20 + frac * 1.45
        ang = frac * 3.5 * 2 * math.pi
        px = cx + math.cos(ang) * 0.038
        py = cy + math.sin(ang) * 0.038
        bp = v_spline.bezier_points[p]
        bp.co = (px, py, z)
        bp.handle_left_type = 'AUTO'
        bp.handle_right_type = 'AUTO'
    v_obj = bpy.data.objects.new("Baston_Comun_Enredadera_Obj", vine_c)
    link_cp(v_obj)
    v_obj.data.materials.append(m_vine)

    # Empuñadura vendada con cuerdas
    for vi in range(5):
        bpy.ops.mesh.primitive_cylinder_add(radius=0.038, depth=0.035, location=(cx, cy, 0.72 + vi * 0.04), vertices=10)
        v = bpy.context.active_object
        v.name = f"Baston_Comun_Vendaje_{vi+1}"
        link_cp(v)
        v.data.materials.append(m_bandage)
        bpy.ops.object.shade_smooth()

    # Corona: 3 Ramas curvadas envolviendo la gema
    for p_i in range(3):
        ang = p_i * (2 * math.pi / 3)
        rx = cx + math.cos(ang) * 0.045
        ry = cy + math.sin(ang) * 0.045
        bpy.ops.mesh.primitive_cone_add(radius1=0.016, radius2=0.005, depth=0.22, location=(rx, ry, 1.78), vertices=8)
        pr = bpy.context.active_object
        pr.name = f"Baston_Comun_Rama_{p_i+1}"
        pr.rotation_euler = (math.sin(ang) * 0.25, -math.cos(ang) * 0.25, ang)
        link_cp(pr)
        pr.data.materials.append(m_wood_rustic)
        bpy.ops.object.shade_smooth()

    # Gema de fósforo tallada en el centro
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.065, location=(cx, cy, 1.84))
    gem_c = bpy.context.active_object
    gem_c.name = "Baston_Comun_Cristal"
    gem_c.scale = (0.85, 0.9, 1.35)
    link_cp(gem_c)
    gem_c.data.materials.append(m_gem_t1)
    bpy.ops.object.shade_flat()

    # Anillo rúnico orbital de madera flotando alrededor de la gema común
    bpy.ops.mesh.primitive_torus_add(major_radius=0.11, minor_radius=0.007, location=(cx, cy, 1.84), major_segments=20, minor_segments=6)
    c_ring = bpy.context.active_object
    c_ring.name = "Baston_Comun_Anillo_Orbital"
    c_ring.rotation_euler = (0.4, 0.25, 0)
    link_cp(c_ring)
    c_ring.data.materials.append(m_wood_rustic)
    bpy.ops.object.shade_smooth()

    # 2 Runas de cuarzo flotantes satélite
    for s_i, s_ang in enumerate([0.0, math.pi]):
        sx = cx + math.cos(s_ang) * 0.14
        sy = cy + math.sin(s_ang) * 0.14
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.018, radius2=0, depth=0.045, location=(sx, sy, 1.84))
        rn = bpy.context.active_object
        rn.name = f"Baston_Comun_Runa_{s_i+1}"
        link_cp(rn)
        rn.data.materials.append(m_gem_t1)
        bpy.ops.object.shade_flat()

    # -----------------------------------------------------------------
    # 3. GENERADOR DE LOS 120 BASTONES CON FORMAS Y DETALLES ESCULPIDOS
    # -----------------------------------------------------------------
    rarity_configs = [
        {"tier": 1, "name": "1_Comun", "y": 4.0, "wood": m_wood_rustic, "metal": m_wood_rustic, "grip": m_bandage, "gem": m_gem_t1, "ring_mat": m_wood_rustic},
        {"tier": 2, "name": "2_PocoComun", "y": 6.3, "wood": m_wood_polished, "metal": m_bronze, "grip": m_leather_black, "gem": m_gem_t2, "ring_mat": m_bronze},
        {"tier": 3, "name": "3_Raro", "y": 8.6, "wood": m_wood_ebony, "metal": m_silver, "grip": m_leather_blue, "gem": m_gem_t3, "ring_mat": m_silver},
        {"tier": 4, "name": "4_Epico", "y": 10.9, "wood": m_obsidian, "metal": m_silver, "grip": m_cloth_red, "gem": m_gem_t4, "ring_mat": m_silver},
        {"tier": 5, "name": "5_Legendario", "y": 13.2, "wood": m_wood_ebony, "metal": m_gold, "grip": m_leather_blue, "gem": m_gem_t5, "ring_mat": m_gold},
        {"tier": 6, "name": "6_Mitico", "y": 15.5, "wood": m_wood_divine, "metal": m_divine_gold, "grip": m_cloth_red, "gem": m_gem_t6, "ring_mat": m_divine_gold},
    ]

    for rc in rarity_configs:
        cname = f"Rareza_{rc['name']}"
        if cname in bpy.data.collections:
            c = bpy.data.collections[cname]
            for obj in list(c.objects):
                bpy.data.objects.remove(obj, do_unlink=True)
            bpy.data.collections.remove(c)

    x_step = 1.2
    x_start = - (19 * x_step) / 2 # -11.4

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

            # 1. Pedestal con anillo
            bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.26, depth=0.04, location=(x_pos, y_pos, 0.02))
            ped = bpy.context.active_object
            ped.name = f"{stave_id}_Ped"
            add_p(ped)
            ped.data.materials.append(wood_m if tier <= 2 else metal_m)
            bpy.ops.object.shade_flat()

            # 2. Silueta del Mástil: Curva Esculpida (No un palo recto)
            # Cada bastón tiene una sutil curvatura y personalidad
            shaft_h = 1.62 + 0.04 * tier
            shaft_rad = 0.026 + 0.002 * tier
            
            s_curve = bpy.data.curves.new(name=f"{stave_id}_CurvaVara", type='CURVE')
            s_curve.dimensions = '3D'
            s_curve.bevel_depth = shaft_rad
            s_curve.bevel_resolution = 4
            s_spline = s_curve.splines.new(type='BEZIER')
            s_spline.bezier_points.add(3) # 4 puntos
            
            # Ligera oscilación en X o Y para silueta estilizada
            curve_sway = 0.025 * math.sin(i * 1.3)
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

            # 3. Enredadera / Espiral esculpida enrollando la vara
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

            # Brotes de cristal a lo largo del mástil para tiers altos (>= 4)
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
                    bud.data.materials.append(m_emerald_bud if tier == 5 else gem_m)
                    bpy.ops.object.shade_flat()

            # 4. Contera / Punta inferior elaborada
            ferrule_h = 0.12 + 0.02 * tier
            bpy.ops.mesh.primitive_cone_add(vertices=6 if tier <= 3 else 8, radius1=shaft_rad * 1.35, radius2=0.004, depth=ferrule_h, location=(x_pos, y_pos, 0.04 + ferrule_h / 2))
            ferrule = bpy.context.active_object
            ferrule.name = f"{stave_id}_Contera"
            ferrule.rotation_euler[0] = math.pi
            add_p(ferrule)
            ferrule.data.materials.append(wood_m if tier == 1 else metal_m)
            bpy.ops.object.shade_flat()

            # Mini cristal de remate inferior (tiers >= 3)
            if tier >= 3:
                bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.016, radius2=0, depth=0.045, location=(x_pos, y_pos, -0.01))
                bot_gem = bpy.context.active_object
                bot_gem.name = f"{stave_id}_GemaInferior"
                bot_gem.rotation_euler[0] = math.pi
                add_p(bot_gem)
                bot_gem.data.materials.append(gem_m)
                bpy.ops.object.shade_flat()

            # 5. Empuñadura de alta definición
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

            # 6. CABEZA, CORONA Y GEMA
            head_z = shaft_h
            gem_z = head_z + 0.14 + 0.02 * tier
            gem_rad = 0.048 + 0.010 * tier

            # Variación de silueta por arquetipo (4 arquetipos rotativos: Luna Creciente, Alas, Garras, Aureola)
            arch_type = i % 4

            # Arquetipo 0: Corona de Luna Creciente Esculpida (Curva Bezier 3D)
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

            # Arquetipo 1: Alas Esculpidas Dobles (Curvas de Ala)
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

            # Arquetipo 2: Garras / Horquilla Curvada Envolvente
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

            # Arquetipo 3: Aureola / Corona Circular Radiante
            else:
                bpy.ops.mesh.primitive_torus_add(major_radius=0.15 + 0.015 * tier, minor_radius=0.012, location=(x_pos, y_pos, gem_z), major_segments=24, minor_segments=8)
                halo = bpy.context.active_object
                halo.name = f"{stave_id}_Aureola"
                halo.scale = (1.0, 0.3, 1.2)
                add_p(halo)
                halo.data.materials.append(wood_m if tier == 1 else metal_m)
                bpy.ops.object.shade_smooth()

            # 7. GRAN GEMA FACETADA EN EL CENTRO DE LA CORONA
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=gem_rad, location=(x_pos, y_pos, gem_z))
            gem_obj = bpy.context.active_object
            gem_obj.name = f"{stave_id}_GemaCentral"
            gem_obj.scale = (0.85, 0.85, 1.45) # Facetado alargado como diamante de poder
            add_p(gem_obj)
            gem_obj.data.materials.append(gem_m)
            bpy.ops.object.shade_flat()

            # 8. ANILLOS ORBITALES FLOTANTES ALREDEDOR DE LA GEMA
            # Tier 1 y 2: 1 anillo
            # Tier 3 y 4: 2 anillos cruzados
            # Tier 5 y 6: 3 anillos en giroscopio cósmico
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

            # 9. RUNAS Y SATÉLITES FLOTANTES ORBITANDO LA GEMA
            # Tier 1: 2 runas
            # Tier 2: 3 runas
            # Tier 3: 3 runas
            # Tier 4: 4 runas
            # Tier 5: 4 runas
            # Tier 6: 5 fragmentos estelares
            num_sat = 2 if tier == 1 else (3 if tier <= 3 else (4 if tier <= 5 else 5))
            for s_i in range(num_sat):
                s_ang = s_i * (2 * math.pi / num_sat) + i * 0.4
                s_dist = 0.15 + 0.02 * tier
                sx = x_pos + math.cos(s_ang) * s_dist
                sy = y_pos + math.sin(s_ang) * s_dist
                sz = gem_z + 0.04 * math.sin(s_ang * 2)
                
                # Forma de diamante rúnico (bipirámide de 4 caras)
                bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.022 + 0.002 * tier, radius2=0, depth=0.05 + 0.005 * tier, location=(sx, sy, sz))
                sat_obj = bpy.context.active_object
                sat_obj.name = f"{stave_id}_RunaFlotante_{s_i+1}"
                sat_obj.rotation_euler = (0.2 * math.cos(s_ang), 0.2 * math.sin(s_ang), s_ang)
                add_p(sat_obj)
                sat_obj.data.materials.append(gem_m)
                bpy.ops.object.shade_flat()

    # 4. Encuadre de Vista 3D y Guardado
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
    print(">>> 120 BASTONES ESCULPIDOS EN ALTA DEFINICIÓN GENERADOS EXITOSAMENTE! <<<")

generate_sculpted_staves()
