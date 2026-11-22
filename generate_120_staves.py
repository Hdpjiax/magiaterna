import bpy
import math
import random

def generate_120_staves():
    # Semilla fija para reproducibilidad estética impecable
    random.seed(42)

    # 1. Crear Materiales Maestros por Rareza
    def get_or_create_mat(name, color, metallic=0.0, roughness=0.5, emission=None, emission_val=0.0):
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

    # Materiales de Estructura
    m_wood_rustic = get_or_create_mat("M_Madera_Rustica", (0.35, 0.24, 0.14, 1.0), roughness=0.85)
    m_wood_polished = get_or_create_mat("M_Madera_Pulida", (0.48, 0.28, 0.12, 1.0), roughness=0.45)
    m_wood_dark = get_or_create_mat("M_Madera_Oscura", (0.12, 0.06, 0.03, 1.0), roughness=0.5)
    m_wood_white = get_or_create_mat("M_Madera_Ceniza", (0.75, 0.72, 0.68, 1.0), roughness=0.6)
    m_obsidian = get_or_create_mat("M_Obsidiana", (0.04, 0.04, 0.06, 1.0), metallic=0.3, roughness=0.1)

    m_cloth = get_or_create_mat("M_Tela_Vendaje", (0.68, 0.64, 0.52, 1.0), roughness=0.9)
    m_leather = get_or_create_mat("M_Cuero_Negro", (0.08, 0.08, 0.09, 1.0), roughness=0.7)
    m_leather_blue = get_or_create_mat("M_Cuero_Azul", (0.05, 0.09, 0.20, 1.0), roughness=0.7)

    m_iron = get_or_create_mat("M_Hierro", (0.18, 0.18, 0.20, 1.0), metallic=0.85, roughness=0.4)
    m_bronze = get_or_create_mat("M_Bronce", (0.75, 0.45, 0.18, 1.0), metallic=0.9, roughness=0.3)
    m_silver = get_or_create_mat("M_Plata", (0.85, 0.88, 0.92, 1.0), metallic=0.95, roughness=0.2)
    m_gold = get_or_create_mat("M_Oro", (1.0, 0.80, 0.20, 1.0), metallic=0.98, roughness=0.18)
    m_divine_gold = get_or_create_mat("M_Oro_Divino", (1.0, 0.90, 0.40, 1.0), metallic=1.0, roughness=0.12, emission=(1.0, 0.85, 0.3, 1.0), emission_val=2.0)

    # Gemas por Rareza
    # 1. Común: piedras opacas
    m_stone_dull = get_or_create_mat("Gem_Piedra_Opaca", (0.6, 0.6, 0.62, 1.0), roughness=0.7)
    # 2. Poco Común: brillo sutil (verde / ámbar / topacio)
    m_gem_uncommon = get_or_create_mat("Gem_PocoComun_Verde", (0.2, 0.85, 0.3, 1.0), roughness=0.2, emission=(0.2, 0.85, 0.3, 1.0), emission_val=2.5)
    # 3. Raro: zafiro azul / cian luminoso
    m_gem_rare = get_or_create_mat("Gem_Raro_Zafiro", (0.1, 0.6, 1.0, 1.0), roughness=0.1, emission=(0.1, 0.6, 1.0, 1.0), emission_val=5.5)
    # 4. Épico: púrpura amatista / carmesí
    m_gem_epic = get_or_create_mat("Gem_Epico_Amatista", (0.85, 0.15, 0.95, 1.0), roughness=0.08, emission=(0.9, 0.15, 1.0, 1.0), emission_val=8.5)
    # 5. Legendario: sol / oro astral / esmeralda divina
    m_gem_legend = get_or_create_mat("Gem_Legendario_Solar", (1.0, 0.75, 0.1, 1.0), roughness=0.05, emission=(1.0, 0.8, 0.15, 1.0), emission_val=12.0)
    # 6. Mítico: fuego cósmico / plasma divino
    m_gem_mythic = get_or_create_mat("Gem_Mitico_Cosmico", (0.1, 1.0, 0.9, 1.0), roughness=0.0, emission=(0.2, 1.0, 0.95, 1.0), emission_val=18.0)

    # Definición de las 6 Rarezas
    rarities = [
        {"tier": 1, "name": "1_Comun", "y": 4.0, "color": "Gris", "wood": m_wood_rustic, "metal": m_wood_rustic, "grip": m_cloth, "gem": m_stone_dull},
        {"tier": 2, "name": "2_PocoComun", "y": 6.0, "color": "Verde", "wood": m_wood_polished, "metal": m_bronze, "grip": m_cloth, "gem": m_gem_uncommon},
        {"tier": 3, "name": "3_Raro", "y": 8.0, "color": "Azul", "wood": m_wood_dark, "metal": m_silver, "grip": m_leather, "gem": m_gem_rare},
        {"tier": 4, "name": "4_Epico", "y": 10.0, "color": "Purpura", "wood": m_obsidian, "metal": m_iron, "grip": m_leather_blue, "gem": m_gem_epic},
        {"tier": 5, "name": "5_Legendario", "y": 12.0, "color": "Dorado", "wood": m_wood_dark, "metal": m_gold, "grip": m_leather_blue, "gem": m_gem_legend},
        {"tier": 6, "name": "6_Mitico", "y": 14.0, "color": "Cosmico", "wood": m_wood_white, "metal": m_divine_gold, "grip": m_leather, "gem": m_gem_mythic},
    ]

    # Limpiar colecciones anteriores de rarezas si existían
    for r in rarities:
        cname = f"Rareza_{r['name']}"
        if cname in bpy.data.collections:
            c = bpy.data.collections[cname]
            for obj in list(c.objects):
                bpy.data.objects.remove(obj, do_unlink=True)
            bpy.data.collections.remove(c)

    # 2. Generador de Bastones
    total_created = 0
    # Espaciado X: 20 bastones centrados desde X = -11.4 hasta X = +11.4 (paso de 1.2 m)
    x_step = 1.2
    x_start = - (19 * x_step) / 2 # ~ -11.4

    for r_data in rarities:
        tier = r_data["tier"]
        tier_name = f"Rareza_{r_data['name']}"
        col = bpy.data.collections.new(tier_name)
        bpy.context.scene.collection.children.link(col)
        
        y_pos = r_data["y"]
        wood_mat = r_data["wood"]
        metal_mat = r_data["metal"]
        grip_mat = r_data["grip"]
        gem_mat = r_data["gem"]

        for i in range(20):
            x_pos = x_start + i * x_step
            stave_id = f"Baston_T{tier}_{i+1:02d}"

            # Contenedor / Padre de cada bastón (Empty) para fácil manipulación
            empty = bpy.data.objects.new(stave_id, None)
            empty.location = (x_pos, y_pos, 0)
            col.objects.link(empty)

            def add_child(obj):
                for c in list(obj.users_collection):
                    c.objects.unlink(obj)
                col.objects.link(obj)
                obj.parent = empty

            # A) Pedestal individual de exhibición
            bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.25, depth=0.04, location=(x_pos, y_pos, 0.02))
            ped = bpy.context.active_object
            ped.name = f"{stave_id}_Pedestal"
            add_child(ped)
            ped.data.materials.append(wood_mat if tier <= 2 else metal_mat)
            bpy.ops.object.shade_flat()

            # B) Vara principal (Altura ~1.6m a 1.85m)
            shaft_h = 1.60 + 0.05 * (tier - 1)
            shaft_rad = 0.028 + 0.002 * (tier - 1)
            bpy.ops.mesh.primitive_cylinder_add(radius=shaft_rad, depth=shaft_h, location=(x_pos, y_pos, shaft_h / 2 + 0.04), vertices=10 + tier * 2)
            shaft = bpy.context.active_object
            shaft.name = f"{stave_id}_Vara"
            add_child(shaft)
            shaft.data.materials.append(wood_mat)
            bpy.ops.object.shade_smooth()

            # C) Base / Contera
            if tier >= 2:
                bpy.ops.mesh.primitive_cone_add(radius1=shaft_rad * 1.3, radius2=0.008, depth=0.12, location=(x_pos, y_pos, 0.08), vertices=10)
                ferrule = bpy.context.active_object
                ferrule.name = f"{stave_id}_Regaton"
                ferrule.rotation_euler[0] = math.pi
                add_child(ferrule)
                ferrule.data.materials.append(metal_mat)
                bpy.ops.object.shade_flat()

            # D) Empuñadura (Grip)
            grip_z = 0.70 + 0.02 * (tier - 1)
            grip_len = 0.22 + 0.02 * (i % 3)
            bpy.ops.mesh.primitive_cylinder_add(radius=shaft_rad * 1.15, depth=grip_len, location=(x_pos, y_pos, grip_z), vertices=10)
            grip = bpy.context.active_object
            grip.name = f"{stave_id}_Grip"
            add_child(grip)
            grip.data.materials.append(grip_mat)
            bpy.ops.object.shade_smooth()

            # Anillos de agarre si tier >= 2
            if tier >= 2:
                for off in [-grip_len/2, grip_len/2]:
                    bpy.ops.mesh.primitive_torus_add(major_radius=shaft_rad * 1.18, minor_radius=0.006, location=(x_pos, y_pos, grip_z + off), major_segments=16, minor_segments=6)
                    r = bpy.context.active_object
                    r.name = f"{stave_id}_AnilloGrip"
                    add_child(r)
                    r.data.materials.append(metal_mat)
                    bpy.ops.object.shade_smooth()

            # E) CABEZA Y GEMA (Varía progresivamente por rareza)
            head_z = shaft_h + 0.04
            
            # Collarín superior
            if tier >= 2:
                bpy.ops.mesh.primitive_cone_add(radius1=shaft_rad, radius2=shaft_rad * (1.5 + tier * 0.2), depth=0.08, location=(x_pos, y_pos, head_z), vertices=12)
                collar = bpy.context.active_object
                collar.name = f"{stave_id}_Collarin"
                add_child(collar)
                collar.data.materials.append(metal_mat)
                bpy.ops.object.shade_smooth()

            # Tipologías de Corona / Sujeción según rareza y variación:
            gem_z = head_z + 0.12 + 0.02 * tier
            gem_rad = 0.045 + 0.010 * tier

            # TIER 1: COMÚN (Ramas y piedras atadas)
            if tier == 1:
                prongs = 2 + (i % 2)
                for p in range(prongs):
                    pang = p * (2 * math.pi / prongs)
                    px = x_pos + math.cos(pang) * 0.035
                    py = y_pos + math.sin(pang) * 0.035
                    bpy.ops.mesh.primitive_cone_add(radius1=0.015, radius2=0.005, depth=0.15, location=(px, py, head_z + 0.07), vertices=6)
                    br = bpy.context.active_object
                    br.name = f"{stave_id}_Rama_{p+1}"
                    br.rotation_euler = (math.sin(pang) * 0.2, -math.cos(pang) * 0.2, pang)
                    add_child(br)
                    br.data.materials.append(wood_mat)
                    bpy.ops.object.shade_flat()
                # Piedra común
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=gem_rad, location=(x_pos, y_pos, gem_z))
                gem = bpy.context.active_object
                gem.name = f"{stave_id}_Piedra"
                gem.scale = (0.8, 0.9, 1.1)
                add_child(gem)
                gem.data.materials.append(gem_mat)
                bpy.ops.object.shade_flat()

            # TIER 2: POCO COMÚN (Herrajes de bronce y gemas pulidas)
            elif tier == 2:
                prongs = 3
                for p in range(prongs):
                    pang = p * (2 * math.pi / prongs)
                    px = x_pos + math.cos(pang) * 0.045
                    py = y_pos + math.sin(pang) * 0.045
                    bpy.ops.mesh.primitive_cone_add(radius1=0.014, radius2=0.004, depth=0.18, location=(px, py, head_z + 0.09), vertices=8)
                    pr = bpy.context.active_object
                    pr.name = f"{stave_id}_Garra_{p+1}"
                    pr.rotation_euler = (math.sin(pang) * 0.25, -math.cos(pang) * 0.25, pang)
                    add_child(pr)
                    pr.data.materials.append(metal_mat)
                    bpy.ops.object.shade_smooth()
                # Gema poco común
                bpy.ops.mesh.primitive_uv_sphere_add(radius=gem_rad, location=(x_pos, y_pos, gem_z), segments=10, ring_count=8)
                gem = bpy.context.active_object
                gem.name = f"{stave_id}_Gema"
                add_child(gem)
                gem.data.materials.append(gem_mat)
                bpy.ops.object.shade_smooth()

            # TIER 3: RARO (Zafiro facetado + 1 anillo orbital o lanza)
            elif tier == 3:
                # Horquilla doble o triple de plata
                bpy.ops.mesh.primitive_torus_add(major_radius=0.09, minor_radius=0.008, location=(x_pos, y_pos, gem_z), major_segments=20, minor_segments=6)
                ring = bpy.context.active_object
                ring.name = f"{stave_id}_AroPlata"
                ring.rotation_euler = (0.4 + (i * 0.2), 0.3, 0)
                add_child(ring)
                ring.data.materials.append(metal_mat)
                bpy.ops.object.shade_smooth()
                # Cristal facetado
                bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=gem_rad, radius2=0, depth=gem_rad * 2.2, location=(x_pos, y_pos, gem_z))
                gem = bpy.context.active_object
                gem.name = f"{stave_id}_CristalRaro"
                add_child(gem)
                gem.data.materials.append(gem_mat)
                bpy.ops.object.shade_flat()

            # TIER 4: ÉPICO (Obsidiana / Cristal Arcano + alas dobles o anillos cruzados)
            elif tier == 4:
                for a_i, a_rot in enumerate([0.5, -0.5]):
                    bpy.ops.mesh.primitive_torus_add(major_radius=0.12, minor_radius=0.007, location=(x_pos, y_pos, gem_z), major_segments=24, minor_segments=6)
                    r = bpy.context.active_object
                    r.name = f"{stave_id}_Orbital_{a_i+1}"
                    r.rotation_euler = (a_rot, 0.4, a_rot * 2)
                    add_child(r)
                    r.data.materials.append(metal_mat)
                    bpy.ops.object.shade_smooth()
                # Gran Cristal Arcano Biterminado
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=gem_rad, location=(x_pos, y_pos, gem_z))
                gem = bpy.context.active_object
                gem.name = f"{stave_id}_GemaEpica"
                gem.scale = (0.8, 0.8, 1.4)
                add_child(gem)
                gem.data.materials.append(gem_mat)
                bpy.ops.object.shade_flat()

            # TIER 5: LEGENDARIO (Coronas de luna/sol, alas sagradas y runas flotantes)
            elif tier == 5:
                # Corona de Luna / Arco celestial
                bpy.ops.mesh.primitive_torus_add(major_radius=0.18, minor_radius=0.014, location=(x_pos, y_pos, gem_z), major_segments=24, minor_segments=8)
                arc = bpy.context.active_object
                arc.name = f"{stave_id}_CoronaCelestial"
                arc.scale = (1.0, 0.25, 1.1)
                arc.rotation_euler = (0, 0, (i * 0.3))
                add_child(arc)
                arc.data.materials.append(metal_mat)
                bpy.ops.object.shade_smooth()
                # Corazón Solar
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=gem_rad * 1.1, location=(x_pos, y_pos, gem_z))
                gem = bpy.context.active_object
                gem.name = f"{stave_id}_CorazonLegendario"
                gem.scale = (0.8, 0.8, 1.5)
                add_child(gem)
                gem.data.materials.append(gem_mat)
                bpy.ops.object.shade_flat()
                # Runas flotantes (3 satélites)
                for s_i in range(3):
                    sang = s_i * (2 * math.pi / 3) + i
                    sx = x_pos + math.cos(sang) * 0.16
                    sy = y_pos + math.sin(sang) * 0.16
                    sz = gem_z + 0.05 * math.sin(sang * 2)
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.022, radius2=0, depth=0.045, location=(sx, sy, sz))
                    rn = bpy.context.active_object
                    rn.name = f"{stave_id}_Runa_{s_i+1}"
                    add_child(rn)
                    rn.data.materials.append(gem_mat)
                    bpy.ops.object.shade_flat()

            # TIER 6: MÍTICO (Estructuras fracturadas divinas, orbes cósmicos de agujero de gusano, alas astrales)
            elif tier == 6:
                # Giroscopio Cósmico Triple (3 anillos concéntricos)
                for g_idx in range(3):
                    g_rad = 0.14 + g_idx * 0.05
                    bpy.ops.mesh.primitive_torus_add(major_radius=g_rad, minor_radius=0.007, location=(x_pos, y_pos, gem_z), major_segments=28, minor_segments=6)
                    ring = bpy.context.active_object
                    ring.name = f"{stave_id}_HaloCosmico_{g_idx+1}"
                    ring.rotation_euler = (0.6 * g_idx, 0.5 * (g_idx + 1), 0.7 * g_idx + (i * 0.2))
                    add_child(ring)
                    ring.data.materials.append(metal_mat)
                    bpy.ops.object.shade_smooth()
                # Gran Núcleo Cósmico de Plasma Divino
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=gem_rad * 1.25, location=(x_pos, y_pos, gem_z))
                gem = bpy.context.active_object
                gem.name = f"{stave_id}_NucleoCosmico"
                add_child(gem)
                gem.data.materials.append(gem_mat)
                bpy.ops.object.shade_flat()
                # Fragmentos estelares flotantes (4 satélites)
                for s_i in range(4):
                    sang = s_i * (math.pi / 2) + i * 0.4
                    sx = x_pos + math.cos(sang) * 0.24
                    sy = y_pos + math.sin(sang) * 0.24
                    sz = gem_z + 0.08 * math.sin(sang * 3)
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.025, radius2=0, depth=0.06, location=(sx, sy, sz))
                    st = bpy.context.active_object
                    st.name = f"{stave_id}_Estrella_{s_i+1}"
                    add_child(st)
                    st.data.materials.append(m_gem_legend)
                    bpy.ops.object.shade_flat()

            total_created += 1

    # 3. Guardar el archivo .blend y centrar la vista
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

    print(f">>> ÉXITO TOTAL: {total_created} Bastones generados ordenadamente en 6 filas por rareza! <<<")

generate_120_staves()
