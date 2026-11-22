import bpy
import math
import random

def build_epic_staves():
    random.seed(1337)

    # 1. Materiales Maestros con Progresión de Color y Emisión
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

    # Estructuras
    m_wood_rustic = get_or_make_mat("M_Madera_Rustica", (0.34, 0.22, 0.12, 1.0), roughness=0.85)
    m_wood_birch = get_or_make_mat("M_Madera_Abedul", (0.65, 0.60, 0.50, 1.0), roughness=0.7)
    m_wood_polished = get_or_make_mat("M_Madera_Pulida", (0.45, 0.25, 0.10, 1.0), roughness=0.4)
    m_wood_dark = get_or_make_mat("M_Madera_Ebano", (0.10, 0.05, 0.03, 1.0), roughness=0.45)
    m_wood_divine = get_or_make_mat("M_Madera_Divina", (0.85, 0.82, 0.78, 1.0), roughness=0.35)
    m_obsidian = get_or_make_mat("M_Obsidiana_Pura", (0.03, 0.03, 0.05, 1.0), metallic=0.4, roughness=0.1)

    # Telas, cueros y vendajes
    m_bandage = get_or_make_mat("M_Vendaje_Tela", (0.70, 0.65, 0.52, 1.0), roughness=0.9)
    m_rope = get_or_make_mat("M_Cuerda_Cañamo", (0.38, 0.30, 0.20, 1.0), roughness=0.95)
    m_feather = get_or_make_mat("M_Pluma_Amuleto", (0.15, 0.55, 0.75, 1.0), roughness=0.6)
    m_leather_black = get_or_make_mat("M_Cuero_Negro", (0.07, 0.07, 0.08, 1.0), roughness=0.75)
    m_leather_blue = get_or_make_mat("M_Cuero_Azul_Real", (0.04, 0.08, 0.22, 1.0), roughness=0.65)
    m_cloth_red = get_or_make_mat("M_Cinta_Carmesi", (0.75, 0.08, 0.12, 1.0), roughness=0.7)

    # Metales
    m_bronze = get_or_make_mat("M_Bronce_Forjado", (0.75, 0.45, 0.18, 1.0), metallic=0.92, roughness=0.28)
    m_silver = get_or_make_mat("M_Plata_Estelar", (0.86, 0.89, 0.94, 1.0), metallic=0.96, roughness=0.18)
    m_gold = get_or_make_mat("M_Oro_Celestial", (1.0, 0.80, 0.20, 1.0), metallic=0.98, roughness=0.16)
    m_divine_gold = get_or_make_mat("M_Oro_Cosmico", (1.0, 0.92, 0.45, 1.0), metallic=1.0, roughness=0.10, emission=(1.0, 0.88, 0.35, 1.0), emission_val=2.5)

    # Gemas con brillo mágico escalado
    # Tier 1 (Común): Fosforescencia mágica naciente
    m_gem_t1 = get_or_make_mat("Gem_T1_Fosforo", (0.3, 0.8, 0.7, 1.0), roughness=0.3, emission=(0.3, 0.85, 0.75, 1.0), emission_val=2.2)
    # Tier 2 (Poco Común): Esmeralda / Ámbar vivo
    m_gem_t2 = get_or_make_mat("Gem_T2_Esmeralda", (0.15, 0.95, 0.35, 1.0), roughness=0.15, emission=(0.2, 1.0, 0.4, 1.0), emission_val=4.5)
    # Tier 3 (Raro): Zafiro / Cian eléctrico puro
    m_gem_t3 = get_or_make_mat("Gem_T3_Zafiro", (0.1, 0.65, 1.0, 1.0), roughness=0.08, emission=(0.15, 0.75, 1.0, 1.0), emission_val=7.5)
    # Tier 4 (Épico): Amatista / Plasma violeta
    m_gem_t4 = get_or_make_mat("Gem_T4_Amatista", (0.9, 0.15, 1.0, 1.0), roughness=0.05, emission=(0.95, 0.2, 1.0, 1.0), emission_val=10.5)
    # Tier 5 (Legendario): Corazón Solar / Fénix
    m_gem_t5 = get_or_make_mat("Gem_T5_Solar", (1.0, 0.75, 0.1, 1.0), roughness=0.03, emission=(1.0, 0.82, 0.15, 1.0), emission_val=14.0)
    # Tier 6 (Mítico): Hiper-Núcleo Cósmico Divino
    m_gem_t6 = get_or_make_mat("Gem_T6_Cosmico", (0.1, 1.0, 0.95, 1.0), roughness=0.0, emission=(0.2, 1.0, 0.95, 1.0), emission_val=20.0)

    # 2. Reconstruir el Bastón Común Principal (Inicial) con detalles mágicos auténticos
    col_comun_p = bpy.data.collections.get("Baston_Comun_Principal")
    if col_comun_p:
        for o in list(col_comun_p.objects):
            bpy.data.objects.remove(o, do_unlink=True)
    else:
        col_comun_p = bpy.data.collections.new("Baston_Comun_Principal")
        bpy.context.scene.collection.children.link(col_comun_p)

    def link_comun_p(obj):
        for c in list(obj.users_collection):
            c.objects.unlink(obj)
        col_comun_p.objects.link(obj)

    cx, cy = -2.2, 0.0
    # Pedestal
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.36, depth=0.06, location=(cx, cy, 0.03))
    b_ped = bpy.context.active_object
    b_ped.name = "Baston_Comun_Pedestal"
    link_comun_p(b_ped)
    b_ped.data.materials.append(m_wood_rustic)
    bpy.ops.object.shade_flat()

    # Vara con corte de druida
    bpy.ops.mesh.primitive_cylinder_add(radius=0.033, depth=1.65, location=(cx, cy, 0.855), vertices=10)
    b_shaft = bpy.context.active_object
    b_shaft.name = "Baston_Comun_Vara"
    link_comun_p(b_shaft)
    b_shaft.data.materials.append(m_wood_rustic)
    bpy.ops.object.shade_smooth()

    # Vendajes y cuerdas de sujeción
    for vi in range(6):
        bpy.ops.mesh.primitive_cylinder_add(radius=0.039, depth=0.035, location=(cx, cy, 0.68 + vi * 0.04), vertices=10)
        v = bpy.context.active_object
        v.name = f"Baston_Comun_Vendaje_{vi+1}"
        link_comun_p(v)
        v.data.materials.append(m_bandage)
        bpy.ops.object.shade_smooth()

    for rz in [0.65, 0.94]:
        bpy.ops.mesh.primitive_torus_add(major_radius=0.040, minor_radius=0.007, location=(cx, cy, rz), major_segments=16, minor_segments=6)
        cr = bpy.context.active_object
        cr.name = "Baston_Comun_Cuerda"
        link_comun_p(cr)
        cr.data.materials.append(m_rope)
        bpy.ops.object.shade_smooth()

    # Amuleto colgante del cuello: Tira de cuero con pluma mágica
    bpy.ops.mesh.primitive_cylinder_add(radius=0.004, depth=0.14, location=(cx + 0.05, cy, 1.58), vertices=6)
    strap = bpy.context.active_object
    strap.name = "Baston_Comun_TiraCuero"
    link_comun_p(strap)
    strap.data.materials.append(m_rope)
    bpy.ops.object.shade_flat()

    # Pluma de tótem de aprendiz
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.022, radius2=0.0, depth=0.12, location=(cx + 0.05, cy, 1.48))
    feather = bpy.context.active_object
    feather.name = "Baston_Comun_PlumaAmuleto"
    feather.scale = (0.3, 1.0, 1.0)
    feather.rotation_euler[0] = 0.2
    link_comun_p(feather)
    feather.data.materials.append(m_feather)
    bpy.ops.object.shade_flat()

    # Cabeza: Horquilla de 3 ramas orgánicas sujetando el cristal
    for p_i in range(3):
        ang = p_i * (2 * math.pi / 3)
        rx = cx + math.cos(ang) * 0.046
        ry = cy + math.sin(ang) * 0.046
        bpy.ops.mesh.primitive_cone_add(radius1=0.016, radius2=0.005, depth=0.22, location=(rx, ry, 1.76), vertices=8)
        pr = bpy.context.active_object
        pr.name = f"Baston_Comun_Rama_{p_i+1}"
        pr.rotation_euler = (math.sin(ang) * 0.22, -math.cos(ang) * 0.22, ang)
        link_comun_p(pr)
        pr.data.materials.append(m_wood_rustic)
        bpy.ops.object.shade_smooth()

    # Cristal Mágico de Aprendiz (Piedra de río fosforescente)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.058, location=(cx, cy, 1.80))
    c_stone = bpy.context.active_object
    c_stone.name = "Baston_Comun_Cristal_Fosforo"
    c_stone.scale = (0.85, 0.9, 1.3)
    link_comun_p(c_stone)
    c_stone.data.materials.append(m_gem_t1)
    bpy.ops.object.shade_flat()

    # 3. Limpiar y Reconstruir las 6 Colecciones de Rareza de los 120 Bastones
    rarity_configs = [
        {"tier": 1, "name": "1_Comun", "y": 4.0, "wood": m_wood_rustic, "metal": m_wood_rustic, "grip": m_bandage, "gem": m_gem_t1},
        {"tier": 2, "name": "2_PocoComun", "y": 6.2, "wood": m_wood_polished, "metal": m_bronze, "grip": m_leather_black, "gem": m_gem_t2},
        {"tier": 3, "name": "3_Raro", "y": 8.4, "wood": m_wood_dark, "metal": m_silver, "grip": m_leather_blue, "gem": m_gem_t3},
        {"tier": 4, "name": "4_Epico", "y": 10.6, "wood": m_obsidian, "metal": m_silver, "grip": m_cloth_red, "gem": m_gem_t4},
        {"tier": 5, "name": "5_Legendario", "y": 12.8, "wood": m_wood_dark, "metal": m_gold, "grip": m_leather_blue, "gem": m_gem_t5},
        {"tier": 6, "name": "6_Mitico", "y": 15.0, "wood": m_wood_divine, "metal": m_divine_gold, "grip": m_cloth_red, "gem": m_gem_t6},
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

        for i in range(20):
            x_pos = x_start + i * x_step
            stave_id = f"Baston_T{tier}_{i+1:02d}"

            empty = bpy.data.objects.new(stave_id, None)
            empty.location = (x_pos, y_pos, 0)
            col.objects.link(empty)

            def add_part(obj):
                for c in list(obj.users_collection):
                    c.objects.unlink(obj)
                col.objects.link(obj)
                obj.parent = empty

            # Pedestal
            bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.25, depth=0.04, location=(x_pos, y_pos, 0.02))
            ped = bpy.context.active_object
            ped.name = f"{stave_id}_Ped"
            add_part(ped)
            ped.data.materials.append(wood_m if tier <= 2 else metal_m)
            bpy.ops.object.shade_flat()

            # Vara principal
            shaft_h = 1.60 + 0.04 * tier
            shaft_rad = 0.026 + 0.002 * tier
            bpy.ops.mesh.primitive_cylinder_add(radius=shaft_rad, depth=shaft_h, location=(x_pos, y_pos, shaft_h / 2 + 0.04), vertices=10 + tier)
            shaft = bpy.context.active_object
            shaft.name = f"{stave_id}_Vara"
            add_part(shaft)
            shaft.data.materials.append(wood_m)
            bpy.ops.object.shade_smooth()

            # Contera inferior (Punta metálica en la base si tier >= 2)
            if tier >= 2:
                ferrule_h = 0.10 + 0.02 * tier
                bpy.ops.mesh.primitive_cone_add(radius1=shaft_rad * 1.3, radius2=0.005, depth=ferrule_h, location=(x_pos, y_pos, 0.04 + ferrule_h / 2), vertices=8 + tier)
                ferrule = bpy.context.active_object
                ferrule.name = f"{stave_id}_Contera"
                ferrule.rotation_euler[0] = math.pi
                add_part(ferrule)
                ferrule.data.materials.append(metal_m)
                bpy.ops.object.shade_flat()

            # Empuñadura (Grip)
            grip_z = 0.70 + 0.015 * tier
            grip_len = 0.22
            bpy.ops.mesh.primitive_cylinder_add(radius=shaft_rad * 1.18, depth=grip_len, location=(x_pos, y_pos, grip_z), vertices=10)
            grip = bpy.context.active_object
            grip.name = f"{stave_id}_Grip"
            add_part(grip)
            grip.data.materials.append(grip_m)
            bpy.ops.object.shade_smooth()

            # Anillos de sujeción de empuñadura
            if tier >= 2:
                for off in [-grip_len / 2, grip_len / 2]:
                    bpy.ops.mesh.primitive_torus_add(major_radius=shaft_rad * 1.20, minor_radius=0.006, location=(x_pos, y_pos, grip_z + off), major_segments=16, minor_segments=6)
                    r = bpy.context.active_object
                    r.name = f"{stave_id}_AnilloGrip"
                    add_part(r)
                    r.data.materials.append(metal_m)
                    bpy.ops.object.shade_smooth()

            # DETALLES MÁGICOS SEGÚN TIER:
            head_z = shaft_h + 0.04
            gem_z = head_z + 0.12 + 0.02 * tier
            gem_rad = 0.045 + 0.010 * tier

            # Archetype de silueta (5 variantes ricas por tier: i % 5)
            arch = i % 5

            # ---------------------------------------------------------
            # TIER 1: COMÚN
            # ---------------------------------------------------------
            if tier == 1:
                # 1. Cinta / Tira de amuleto colgando del mástil
                bpy.ops.mesh.primitive_cylinder_add(radius=0.003, depth=0.12, location=(x_pos + 0.035, y_pos, head_z - 0.06), vertices=6)
                strap = bpy.context.active_object
                strap.name = f"{stave_id}_Tira"
                add_part(strap)
                strap.data.materials.append(m_rope)
                bpy.ops.object.shade_flat()

                # Dije de colmillo / pluma
                bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.016, radius2=0, depth=0.08, location=(x_pos + 0.035, y_pos, head_z - 0.14))
                charm = bpy.context.active_object
                charm.name = f"{stave_id}_Amuleto"
                add_part(charm)
                charm.data.materials.append(m_feather if i % 2 == 0 else m_wood_rustic)
                bpy.ops.object.shade_flat()

                # Cabeza: Horquilla de ramas talladas con nudo
                prongs = 2 + (i % 2)
                for p in range(prongs):
                    pang = p * (2 * math.pi / prongs)
                    px = x_pos + math.cos(pang) * 0.038
                    py = y_pos + math.sin(pang) * 0.038
                    bpy.ops.mesh.primitive_cone_add(radius1=0.014, radius2=0.005, depth=0.16, location=(px, py, head_z + 0.06), vertices=6)
                    branch = bpy.context.active_object
                    branch.name = f"{stave_id}_Rama_{p+1}"
                    branch.rotation_euler = (math.sin(pang) * 0.22, -math.cos(pang) * 0.22, pang)
                    add_part(branch)
                    branch.data.materials.append(wood_m)
                    bpy.ops.object.shade_flat()

                # Piedra fosforescente de aprendiz
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=gem_rad, location=(x_pos, y_pos, gem_z))
                gem = bpy.context.active_object
                gem.name = f"{stave_id}_PiedraFosforo"
                gem.scale = (0.8, 0.9, 1.2)
                add_part(gem)
                gem.data.materials.append(gem_m)
                bpy.ops.object.shade_flat()

            # ---------------------------------------------------------
            # TIER 2: POCO COMÚN
            # ---------------------------------------------------------
            elif tier == 2:
                # Espiral de alambre de bronce decorativo en el cuello
                for sp in range(3):
                    bpy.ops.mesh.primitive_torus_add(major_radius=shaft_rad * 1.15, minor_radius=0.004, location=(x_pos, y_pos, head_z - 0.08 + sp * 0.025), major_segments=16, minor_segments=6)
                    coil = bpy.context.active_object
                    coil.name = f"{stave_id}_EspiralBronce_{sp+1}"
                    add_part(coil)
                    coil.data.materials.append(metal_m)
                    bpy.ops.object.shade_smooth()

                # Collarín forjado
                bpy.ops.mesh.primitive_cone_add(radius1=shaft_rad, radius2=shaft_rad * 1.7, depth=0.08, location=(x_pos, y_pos, head_z), vertices=10)
                colr = bpy.context.active_object
                colr.name = f"{stave_id}_Collar"
                add_part(colr)
                colr.data.materials.append(metal_m)
                bpy.ops.object.shade_smooth()

                # Garras estilizadas de bronce (3 o 4 garras)
                num_g = 3 if arch % 2 == 0 else 4
                for g in range(num_g):
                    gang = g * (2 * math.pi / num_g)
                    gx = x_pos + math.cos(gang) * 0.048
                    gy = y_pos + math.sin(gang) * 0.048
                    bpy.ops.mesh.primitive_cone_add(radius1=0.015, radius2=0.004, depth=0.18, location=(gx, gy, head_z + 0.09), vertices=8)
                    claw = bpy.context.active_object
                    claw.name = f"{stave_id}_Garra_{g+1}"
                    claw.rotation_euler = (math.sin(gang) * 0.25, -math.cos(gang) * 0.25, gang)
                    add_part(claw)
                    claw.data.materials.append(metal_m)
                    bpy.ops.object.shade_smooth()

                # Gema de esmeralda / ámbar pulida
                bpy.ops.mesh.primitive_uv_sphere_add(radius=gem_rad, location=(x_pos, y_pos, gem_z), segments=12, ring_count=8)
                gem = bpy.context.active_object
                gem.name = f"{stave_id}_GemaPulida"
                add_part(gem)
                gem.data.materials.append(gem_m)
                bpy.ops.object.shade_smooth()

            # ---------------------------------------------------------
            # TIER 3: RARO
            # ---------------------------------------------------------
            elif tier == 3:
                # Contera de Lanza de Combate en la punta inferior
                bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.025, radius2=0, depth=0.20, location=(x_pos, y_pos, -0.05))
                blade_bot = bpy.context.active_object
                blade_bot.name = f"{stave_id}_PuntaLanza"
                blade_bot.rotation_euler[0] = math.pi
                add_part(blade_bot)
                blade_bot.data.materials.append(metal_m)
                bpy.ops.object.shade_flat()

                # Collarín de plata labrada con grabado rúnico
                bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=shaft_rad * 1.8, depth=0.10, location=(x_pos, y_pos, head_z))
                colr = bpy.context.active_object
                colr.name = f"{stave_id}_CollarPlata"
                add_part(colr)
                colr.data.materials.append(metal_m)
                bpy.ops.object.shade_flat()

                # 1 Anillo Orbital Flotante inclinado alrededor del cristal
                bpy.ops.mesh.primitive_torus_add(major_radius=0.10, minor_radius=0.008, location=(x_pos, y_pos, gem_z), major_segments=20, minor_segments=6)
                orb_ring = bpy.context.active_object
                orb_ring.name = f"{stave_id}_AnilloOrbital"
                orb_ring.rotation_euler = (0.45, 0.3, i * 0.3)
                add_part(orb_ring)
                orb_ring.data.materials.append(metal_m)
                bpy.ops.object.shade_smooth()

                # Cristal de Zafiro Biterminado Facetado
                bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=gem_rad, radius2=0, depth=gem_rad * 1.4, location=(x_pos, y_pos, gem_z + gem_rad * 0.6))
                c_top = bpy.context.active_object
                c_top.name = f"{stave_id}_CristalTop"
                add_part(c_top)
                c_top.data.materials.append(gem_m)
                bpy.ops.object.shade_flat()

                bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=gem_rad, radius2=0, depth=gem_rad * 1.2, location=(x_pos, y_pos, gem_z - gem_rad * 0.5))
                c_bot = bpy.context.active_object
                c_bot.name = f"{stave_id}_CristalBot"
                c_bot.rotation_euler[0] = math.pi
                add_part(c_bot)
                c_bot.data.materials.append(gem_m)
                bpy.ops.object.shade_flat()

            # ---------------------------------------------------------
            # TIER 4: ÉPICO
            # ---------------------------------------------------------
            elif tier == 4:
                # Alas de obsidiana / gárgola en el collarín
                for side in [-1, 1]:
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.035, radius2=0.005, depth=0.28, location=(x_pos + side * 0.09, y_pos, head_z + 0.08))
                    wing = bpy.context.active_object
                    wing.name = f"{stave_id}_Ala_{'L' if side < 0 else 'R'}"
                    wing.rotation_euler = (0, side * 0.45, 0)
                    add_part(wing)
                    wing.data.materials.append(wood_m) # Obsidiana
                    bpy.ops.object.shade_flat()

                # 2 Anillos orbitales concéntricos cruzados
                for a_i, a_rot in enumerate([0.55, -0.55]):
                    bpy.ops.mesh.primitive_torus_add(major_radius=0.13, minor_radius=0.008, location=(x_pos, y_pos, gem_z), major_segments=24, minor_segments=6)
                    r = bpy.context.active_object
                    r.name = f"{stave_id}_AnilloDoble_{a_i+1}"
                    r.rotation_euler = (a_rot, 0.4, a_rot * 2 + i * 0.2)
                    add_part(r)
                    r.data.materials.append(metal_m)
                    bpy.ops.object.shade_smooth()

                # Gran Cristal de Amatista Radiante
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=gem_rad, location=(x_pos, y_pos, gem_z))
                gem = bpy.context.active_object
                gem.name = f"{stave_id}_GemaAmatista"
                gem.scale = (0.8, 0.8, 1.45)
                add_part(gem)
                gem.data.materials.append(gem_m)
                bpy.ops.object.shade_flat()

                # 2 Esquirlas flotantes satélite
                for s_i, s_ang in enumerate([0.0, math.pi]):
                    sx = x_pos + math.cos(s_ang + i * 0.3) * 0.16
                    sy = y_pos + math.sin(s_ang + i * 0.3) * 0.16
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.02, radius2=0, depth=0.06, location=(sx, sy, gem_z))
                    shard = bpy.context.active_object
                    shard.name = f"{stave_id}_Esquirla_{s_i+1}"
                    add_part(shard)
                    shard.data.materials.append(gem_m)
                    bpy.ops.object.shade_flat()

            # ---------------------------------------------------------
            # TIER 5: LEGENDARIO
            # ---------------------------------------------------------
            elif tier == 5:
                # Corona de Luna Creciente / Sol de Oro Celestial
                bpy.ops.mesh.primitive_torus_add(major_radius=0.19, minor_radius=0.015, location=(x_pos, y_pos, gem_z), major_segments=24, minor_segments=8)
                crown = bpy.context.active_object
                crown.name = f"{stave_id}_CoronaOro"
                crown.scale = (1.0, 0.25, 1.15)
                crown.rotation_euler = (0, 0, i * 0.35)
                add_part(crown)
                crown.data.materials.append(metal_m)
                bpy.ops.object.shade_smooth()

                # Alas astrales dobles en la base de la corona
                for side in [-1, 1]:
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.028, radius2=0.005, depth=0.26, location=(x_pos + side * 0.08, y_pos, head_z + 0.06))
                    wing = bpy.context.active_object
                    wing.name = f"{stave_id}_AlaAstral_{'L' if side < 0 else 'R'}"
                    wing.rotation_euler = (0, side * 0.5, 0)
                    add_part(wing)
                    wing.data.materials.append(metal_m)
                    bpy.ops.object.shade_smooth()

                # Corazón Solar / Diamante Imperial Gigante
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=gem_rad * 1.1, location=(x_pos, y_pos, gem_z))
                gem = bpy.context.active_object
                gem.name = f"{stave_id}_CorazonSolar"
                gem.scale = (0.85, 0.85, 1.55)
                add_part(gem)
                gem.data.materials.append(gem_m)
                bpy.ops.object.shade_flat()

                # 3 a 4 Runas flotantes de luz dorada en formación orbital
                for s_i in range(3):
                    sang = s_i * (2 * math.pi / 3) + i * 0.5
                    sx = x_pos + math.cos(sang) * 0.17
                    sy = y_pos + math.sin(sang) * 0.17
                    sz = gem_z + 0.05 * math.sin(sang * 2)
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.024, radius2=0, depth=0.05, location=(sx, sy, sz))
                    rn = bpy.context.active_object
                    rn.name = f"{stave_id}_RunaFlotante_{s_i+1}"
                    add_part(rn)
                    rn.data.materials.append(m_gem_t3)
                    bpy.ops.object.shade_flat()

            # ---------------------------------------------------------
            # TIER 6: MÍTICO (God-Tier Artifact)
            # ---------------------------------------------------------
            elif tier == 6:
                # CABEZA FRACTURADA LEVITANTE:
                # El collarín y la cabeza flotan en el aire suspendidos a 6 cm de la vara
                float_gap = 0.07
                float_head_z = head_z + float_gap
                float_gem_z = gem_z + float_gap

                # Columna de energía pura conectando el mango con la cabeza flotante
                bpy.ops.mesh.primitive_cylinder_add(radius=shaft_rad * 0.8, depth=float_gap * 1.2, location=(x_pos, y_pos, head_z + float_gap / 2), vertices=8)
                beam = bpy.context.active_object
                beam.name = f"{stave_id}_RayoLevitacion"
                add_part(beam)
                beam.data.materials.append(gem_m)
                bpy.ops.object.shade_smooth()

                # Anillo de fijación cósmica en el extremo del mástil
                bpy.ops.mesh.primitive_torus_add(major_radius=shaft_rad * 1.3, minor_radius=0.008, location=(x_pos, y_pos, head_z), major_segments=16, minor_segments=6)
                c_ring = bpy.context.active_object
                c_ring.name = f"{stave_id}_AnilloMástil"
                add_part(c_ring)
                c_ring.data.materials.append(metal_m)
                bpy.ops.object.shade_smooth()

                # Giroscopio Cósmico Triple (3 halos rúnicos en ángulos ortogonales)
                for g_idx in range(3):
                    g_rad = 0.15 + g_idx * 0.05
                    bpy.ops.mesh.primitive_torus_add(major_radius=g_rad, minor_radius=0.008, location=(x_pos, y_pos, float_gem_z), major_segments=28, minor_segments=6)
                    halo = bpy.context.active_object
                    halo.name = f"{stave_id}_Giroscopio_{g_idx+1}"
                    halo.rotation_euler = (0.7 * g_idx, 0.5 * (g_idx + 1), 0.8 * g_idx + i * 0.25)
                    add_part(halo)
                    halo.data.materials.append(metal_m)
                    bpy.ops.object.shade_smooth()

                # Núcleo Cósmico de Plasma Divino (Hiper-Esfera de Energía)
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=gem_rad * 1.25, location=(x_pos, y_pos, float_gem_z))
                core = bpy.context.active_object
                core.name = f"{stave_id}_NucleoCosmico"
                add_part(core)
                core.data.materials.append(gem_m)
                bpy.ops.object.shade_flat()

                # 4 Fragmentos Estelares en órbita
                for st_i in range(4):
                    st_ang = st_i * (math.pi / 2) + i * 0.4
                    sx = x_pos + math.cos(st_ang) * 0.25
                    sy = y_pos + math.sin(st_ang) * 0.25
                    sz = float_gem_z + 0.07 * math.sin(st_ang * 3)
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.026, radius2=0, depth=0.065, location=(sx, sy, sz))
                    star = bpy.context.active_object
                    star.name = f"{stave_id}_Estrella_{st_i+1}"
                    add_part(star)
                    star.data.materials.append(m_divine_gold)
                    bpy.ops.object.shade_flat()

                # Contera levitante inferior en la base
                bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.03, radius2=0, depth=0.18, location=(x_pos, y_pos, -0.06))
                bot_float = bpy.context.active_object
                bot_float.name = f"{stave_id}_PuntaFlotanteBase"
                bot_float.rotation_euler[0] = math.pi
                add_part(bot_float)
                bot_float.data.materials.append(gem_m)
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
    print(">>> 120 BASTONES MÁGICOS ÉPICOS ACTUALIZADOS CON DETALLES ESPECTACULARES! <<<")

build_epic_staves()
