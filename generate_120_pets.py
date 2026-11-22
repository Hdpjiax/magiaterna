import bpy
import math
import random

def generate_120_pets_fast():
    random.seed(999)

    # 1. Helper para suavizado ultra-rápido sin bpy.ops (O(1) directo a datos)
    def set_smooth(obj, smooth=True):
        if obj and obj.type == 'MESH' and obj.data:
            obj.data.polygons.foreach_set('use_smooth', [smooth] * len(obj.data.polygons))

    # 2. Materiales PBR para Mascotas
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

    # Materiales
    m_eye_black = get_or_make_mat("Pet_Ojo_Negro", (0.02, 0.02, 0.03, 1.0), roughness=0.1)
    m_eye_white = get_or_make_mat("Pet_Ojo_Blanco", (0.95, 0.95, 0.95, 1.0), roughness=0.2)
    m_snout_pink = get_or_make_mat("Pet_Hocico_Rosa", (0.95, 0.65, 0.70, 1.0), roughness=0.4)

    m_wood_rustic = get_or_make_mat("Pet_Madera_Rustica", (0.35, 0.22, 0.12, 1.0), roughness=0.85)
    m_rope = get_or_make_mat("Pet_Cuerda", (0.38, 0.30, 0.20, 1.0), roughness=0.95)
    m_fur_dog = get_or_make_mat("Pet_Pelaje_Perro", (0.82, 0.58, 0.35, 1.0), roughness=0.6)
    m_fur_cat = get_or_make_mat("Pet_Pelaje_Gato", (0.92, 0.52, 0.15, 1.0), roughness=0.6)
    m_fur_bunny = get_or_make_mat("Pet_Pelaje_Conejo", (0.92, 0.90, 0.88, 1.0), roughness=0.6)
    m_fur_bear = get_or_make_mat("Pet_Pelaje_Oso", (0.35, 0.22, 0.12, 1.0), roughness=0.7)
    m_fur_panda = get_or_make_mat("Pet_Pelaje_Panda", (0.05, 0.05, 0.06, 1.0), roughness=0.7)

    m_fur_fox = get_or_make_mat("Pet_Pelaje_Zorro", (0.90, 0.40, 0.10, 1.0), roughness=0.55)
    m_fur_wolf = get_or_make_mat("Pet_Pelaje_Lobo", (0.45, 0.48, 0.52, 1.0), roughness=0.6)
    m_fur_deer = get_or_make_mat("Pet_Pelaje_Ciervo", (0.65, 0.42, 0.22, 1.0), roughness=0.6)
    m_bronze = get_or_make_mat("Pet_Metal_Bronce", (0.78, 0.48, 0.18, 1.0), metallic=0.92, roughness=0.25)
    m_glow_green = get_or_make_mat("Pet_Glow_Verde", (0.15, 1.0, 0.35, 1.0), roughness=0.1, emission=(0.15, 1.0, 0.35, 1.0), emission_val=5.0)

    m_fur_ice = get_or_make_mat("Pet_Cuerpo_Hielo", (0.45, 0.80, 0.95, 1.0), roughness=0.2)
    m_fur_frost_wolf = get_or_make_mat("Pet_Cuerpo_LoboEscarcha", (0.70, 0.85, 0.98, 1.0), roughness=0.4)
    m_silver = get_or_make_mat("Pet_Metal_Plata", (0.88, 0.90, 0.95, 1.0), metallic=0.96, roughness=0.18)
    m_glow_cyan = get_or_make_mat("Pet_Glow_Cian", (0.1, 0.85, 1.0, 1.0), roughness=0.08, emission=(0.1, 0.85, 1.0, 1.0), emission_val=8.0)

    m_fur_shadow = get_or_make_mat("Pet_Cuerpo_Sombra", (0.08, 0.06, 0.12, 1.0), roughness=0.35)
    m_fur_magma = get_or_make_mat("Pet_Cuerpo_Magma", (0.75, 0.12, 0.05, 1.0), roughness=0.4)
    m_glow_purple = get_or_make_mat("Pet_Glow_Purpura", (0.95, 0.15, 1.0, 1.0), roughness=0.05, emission=(0.95, 0.15, 1.0, 1.0), emission_val=12.0)

    m_fur_solar = get_or_make_mat("Pet_Cuerpo_Solar", (1.0, 0.88, 0.40, 1.0), roughness=0.25)
    m_fur_pegasus = get_or_make_mat("Pet_Cuerpo_Pegaso", (0.96, 0.95, 0.92, 1.0), roughness=0.3)
    m_gold = get_or_make_mat("Pet_Metal_Oro", (1.0, 0.82, 0.22, 1.0), metallic=0.98, roughness=0.15)
    m_glow_solar = get_or_make_mat("Pet_Glow_Solar", (1.0, 0.82, 0.15, 1.0), roughness=0.02, emission=(1.0, 0.85, 0.2, 1.0), emission_val=16.0)

    m_fur_cosmic = get_or_make_mat("Pet_Cuerpo_Cosmico", (0.04, 0.06, 0.15, 1.0), metallic=0.3, roughness=0.15)
    m_divine_gold = get_or_make_mat("Pet_Metal_OroCosmico", (1.0, 0.95, 0.50, 1.0), metallic=1.0, roughness=0.08, emission=(1.0, 0.90, 0.40, 1.0), emission_val=3.5)
    m_glow_cosmic = get_or_make_mat("Pet_Glow_Cosmico", (0.1, 1.0, 0.95, 1.0), roughness=0.0, emission=(0.15, 1.0, 0.98, 1.0), emission_val=26.0)
    m_plasma_core = get_or_make_mat("Pet_Plasma_Core", (1.0, 0.35, 0.95, 1.0), roughness=0.0, emission=(1.0, 0.35, 0.95, 1.0), emission_val=32.0)

    pet_tiers = [
        {"tier": 1, "name": "1_Comun", "y": -11.0, "fur_list": [m_fur_dog, m_fur_cat, m_fur_bunny, m_fur_bear, m_fur_panda], "metal": m_wood_rustic, "glow": m_eye_black, "has_glow": False},
        {"tier": 2, "name": "2_PocoComun", "y": -13.5, "fur_list": [m_fur_fox, m_fur_wolf, m_fur_deer, m_fur_bear, m_fur_dog], "metal": m_bronze, "glow": m_glow_green, "has_glow": True},
        {"tier": 3, "name": "3_Raro", "y": -16.0, "fur_list": [m_fur_ice, m_fur_frost_wolf, m_fur_cat, m_fur_wolf, m_fur_bunny], "metal": m_silver, "glow": m_glow_cyan, "has_glow": True},
        {"tier": 4, "name": "4_Epico", "y": -18.5, "fur_list": [m_fur_shadow, m_fur_magma, m_fur_shadow, m_fur_fox, m_fur_wolf], "metal": m_silver, "glow": m_glow_purple, "has_glow": True},
        {"tier": 5, "name": "5_Legendario", "y": -21.0, "fur_list": [m_fur_solar, m_fur_pegasus, m_fur_cat, m_fur_dog, m_fur_fox], "metal": m_gold, "glow": m_glow_solar, "has_glow": True},
        {"tier": 6, "name": "6_Mitico", "y": -23.5, "fur_list": [m_fur_cosmic, m_fur_solar, m_fur_shadow, m_fur_pegasus, m_fur_ice], "metal": m_divine_gold, "glow": m_glow_cosmic, "has_glow": True},
    ]

    # Limpiar colecciones de mascotas si existían
    for pt in pet_tiers:
        cname = f"Mascotas_{pt['name']}"
        if cname in bpy.data.collections:
            c = bpy.data.collections[cname]
            for obj in list(c.objects):
                bpy.data.objects.remove(obj, do_unlink=True)
            bpy.data.collections.remove(c)

    x_step = 1.25
    x_start = - (19 * x_step) / 2 # -11.875

    for pt in pet_tiers:
        tier = pt["tier"]
        cname = f"Mascotas_{pt['name']}"
        col = bpy.data.collections.new(cname)
        bpy.context.scene.collection.children.link(col)
        
        y_pos = pt["y"]
        metal_m = pt["metal"]
        glow_m = pt["glow"]
        fur_choices = pt["fur_list"]

        for i in range(20):
            bpy.ops.object.select_all(action='DESELECT')
            x_pos = x_start + i * x_step
            pet_id = f"Mascota_T{tier}_{i+1:02d}"

            # Empty contenedor padre para la mascota
            empty = bpy.data.objects.new(pet_id, None)
            empty.location = (x_pos, y_pos, 0)
            col.objects.link(empty)

            def add_p(obj):
                for c in list(obj.users_collection):
                    c.objects.unlink(obj)
                col.objects.link(obj)
                obj.parent = empty

            body_mat = fur_choices[i % len(fur_choices)]
            
            # 1. Pedestal individual de exhibición
            bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.30, depth=0.04, location=(x_pos, y_pos, 0.02))
            ped = bpy.context.active_object
            ped.name = f"{pet_id}_Pedestal"
            add_p(ped)
            ped.data.materials.append(body_mat if tier <= 2 else metal_m)
            set_smooth(ped, False)

            # 2. CUERPO CHIBI ROBLOX (Cubo Redondeado estilizado)
            body_z = 0.40 + 0.02 * tier
            body_size = 0.42 + 0.015 * tier
            
            if tier == 6:
                # Núcleo interior de plasma cósmico
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=body_size * 0.35, location=(x_pos, y_pos, body_z))
                core_p = bpy.context.active_object
                core_p.name = f"{pet_id}_PlasmaCore"
                add_p(core_p)
                core_p.data.materials.append(m_plasma_core)
                set_smooth(core_p, True)

                # Caparazón cósmico facetado exterior
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=body_size * 0.52, location=(x_pos, y_pos, body_z))
                body = bpy.context.active_object
                body.name = f"{pet_id}_Cuerpo"
                body.scale = (1.0, 0.95, 0.95)
                add_p(body)
                body.data.materials.append(body_mat)
                set_smooth(body, False)
            else:
                # Cubo redondeado Chibi típico de Roblox Pets (Pet Sim style)
                bpy.ops.mesh.primitive_cube_add(size=body_size, location=(x_pos, y_pos, body_z))
                body = bpy.context.active_object
                body.name = f"{pet_id}_Cuerpo"
                body.scale = (1.05, 0.95, 0.95)
                add_p(body)
                body.data.materials.append(body_mat)
                set_smooth(body, True)

            # 3. CARA EXPRESIVA CHIBI: Ojos y Pupilas
            for side in [-1, 1]:
                eye_x = x_pos + side * (body_size * 0.28)
                eye_y = y_pos - (body_size * 0.48)
                eye_z = body_z + (body_size * 0.08)
                
                # Base blanca del ojo
                bpy.ops.mesh.primitive_cylinder_add(radius=body_size * 0.12, depth=0.015, location=(eye_x, eye_y, eye_z), vertices=12)
                eye_w = bpy.context.active_object
                eye_w.name = f"{pet_id}_OjoBlanco_{'L' if side<0 else 'R'}"
                eye_w.rotation_euler[0] = math.pi / 2
                add_p(eye_w)
                eye_w.data.materials.append(m_eye_white)
                set_smooth(eye_w, True)

                # Pupila (Glow o Negro)
                bpy.ops.mesh.primitive_cylinder_add(radius=body_size * 0.075, depth=0.018, location=(eye_x, eye_y - 0.005, eye_z), vertices=12)
                pupil = bpy.context.active_object
                pupil.name = f"{pet_id}_Pupila_{'L' if side<0 else 'R'}"
                pupil.rotation_euler[0] = math.pi / 2
                add_p(pupil)
                pupil.data.materials.append(glow_m if tier >= 3 else m_eye_black)
                set_smooth(pupil, True)

            # Hocico / Naricita
            bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=body_size * 0.06, radius2=0, depth=0.02, location=(x_pos, y_pos - (body_size * 0.485), body_z - body_size * 0.06))
            snout = bpy.context.active_object
            snout.name = f"{pet_id}_Hocico"
            snout.rotation_euler[0] = -math.pi / 2
            add_p(snout)
            snout.data.materials.append(m_snout_pink if tier <= 3 else metal_m)
            set_smooth(snout, False)

            # 4. TIPO DE ANIMAL / OREJAS (5 arquetipos rotativos por fila: i % 5)
            animal_type = i % 5
            
            # Arquetipo 0: Perro / Lobo
            if animal_type == 0:
                for side in [-1, 1]:
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.065, radius2=0.01, depth=0.16, location=(x_pos + side * (body_size * 0.42), y_pos, body_z + body_size * 0.48))
                    ear = bpy.context.active_object
                    ear.name = f"{pet_id}_Oreja_{'L' if side<0 else 'R'}"
                    ear.rotation_euler = (0.2, side * 0.35, 0)
                    add_p(ear)
                    ear.data.materials.append(body_mat)
                    set_smooth(ear, False)

            # Arquetipo 1: Gato / Zorro
            elif animal_type == 1:
                for side in [-1, 1]:
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.07, radius2=0.005, depth=0.18, location=(x_pos + side * (body_size * 0.38), y_pos, body_z + body_size * 0.52))
                    ear = bpy.context.active_object
                    ear.name = f"{pet_id}_OrejaGato_{'L' if side<0 else 'R'}"
                    ear.rotation_euler = (-0.1, side * 0.25, 0)
                    add_p(ear)
                    ear.data.materials.append(body_mat)
                    set_smooth(ear, False)

            # Arquetipo 2: Conejo
            elif animal_type == 2:
                for side in [-1, 1]:
                    bpy.ops.mesh.primitive_cylinder_add(radius=0.035, depth=0.28, location=(x_pos + side * (body_size * 0.25), y_pos, body_z + body_size * 0.58), vertices=8)
                    ear = bpy.context.active_object
                    ear.name = f"{pet_id}_OrejaConejo_{'L' if side<0 else 'R'}"
                    ear.rotation_euler = (0.15, side * 0.2, 0)
                    add_p(ear)
                    ear.data.materials.append(body_mat)
                    set_smooth(ear, True)

            # Arquetipo 3: Oso / Panda
            elif animal_type == 3:
                for side in [-1, 1]:
                    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.065, location=(x_pos + side * (body_size * 0.45), y_pos, body_z + body_size * 0.45), segments=10, ring_count=8)
                    ear = bpy.context.active_object
                    ear.name = f"{pet_id}_OrejaOso_{'L' if side<0 else 'R'}"
                    add_p(ear)
                    ear.data.materials.append(m_eye_black if 'Panda' in body_mat.name else body_mat)
                    set_smooth(ear, True)

            # Arquetipo 4: Dragón / Bestia Mágica (Cuernos esculpidos)
            else:
                for side in [-1, 1]:
                    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.05, radius2=0.005, depth=0.22, location=(x_pos + side * (body_size * 0.35), y_pos, body_z + body_size * 0.52))
                    horn = bpy.context.active_object
                    horn.name = f"{pet_id}_Cuerno_{'L' if side<0 else 'R'}"
                    horn.rotation_euler = (0.35, side * 0.45, 0)
                    add_p(horn)
                    horn.data.materials.append(glow_m if tier >= 3 else metal_m)
                    set_smooth(horn, True)

            # 5. PATITAS CHIBI Y COLITA
            for f_x in [-1, 1]:
                for f_y in [-1, 1]:
                    px = x_pos + f_x * (body_size * 0.35)
                    py = y_pos + f_y * (body_size * 0.25)
                    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.06, location=(px, py, body_z - body_size * 0.38), segments=8, ring_count=6)
                    paw = bpy.context.active_object
                    paw.name = f"{pet_id}_Pata_{f_x}_{f_y}"
                    add_p(paw)
                    paw.data.materials.append(body_mat)
                    set_smooth(paw, True)

            # Colita trasera
            bpy.ops.mesh.primitive_uv_sphere_add(radius=0.065, location=(x_pos, y_pos + body_size * 0.48, body_z - body_size * 0.1), segments=8, ring_count=6)
            tail = bpy.context.active_object
            tail.name = f"{pet_id}_Cola"
            add_p(tail)
            tail.data.materials.append(body_mat)
            set_smooth(tail, True)

            # 6. ACCESORIOS Y MAGIA ESCALADA POR RAREZA
            # TIER 1: COMÚN - Collarín rústico con placa
            if tier == 1:
                bpy.ops.mesh.primitive_torus_add(major_radius=body_size * 0.48, minor_radius=0.012, location=(x_pos, y_pos, body_z - body_size * 0.15), major_segments=16, minor_segments=6)
                colr = bpy.context.active_object
                colr.name = f"{pet_id}_Collar"
                add_p(colr)
                colr.data.materials.append(m_rope)
                set_smooth(colr, True)

                bpy.ops.mesh.primitive_cylinder_add(radius=0.035, depth=0.01, location=(x_pos, y_pos - body_size * 0.49, body_z - body_size * 0.22), vertices=8)
                tag = bpy.context.active_object
                tag.name = f"{pet_id}_Placa"
                tag.rotation_euler[0] = math.pi / 2
                add_p(tag)
                tag.data.materials.append(m_wood_rustic)
                set_smooth(tag, False)

            # TIER 2: POCO COMÚN - Collar bronce con campana y gema verde
            elif tier == 2:
                bpy.ops.mesh.primitive_torus_add(major_radius=body_size * 0.48, minor_radius=0.015, location=(x_pos, y_pos, body_z - body_size * 0.15), major_segments=16, minor_segments=6)
                colr = bpy.context.active_object
                colr.name = f"{pet_id}_CollarBronce"
                add_p(colr)
                colr.data.materials.append(metal_m)
                set_smooth(colr, True)

                bpy.ops.mesh.primitive_uv_sphere_add(radius=0.045, location=(x_pos, y_pos - body_size * 0.50, body_z - body_size * 0.24), segments=10, ring_count=8)
                bell = bpy.context.active_object
                bell.name = f"{pet_id}_Campana"
                add_p(bell)
                bell.data.materials.append(metal_m)
                set_smooth(bell, True)

                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.025, location=(x_pos, y_pos - body_size * 0.54, body_z - body_size * 0.24))
                b_gem = bpy.context.active_object
                b_gem.name = f"{pet_id}_GemaCampana"
                add_p(b_gem)
                b_gem.data.materials.append(glow_m)
                set_smooth(b_gem, False)

            # TIER 3: RARO - Alas de hielo + Anillo orbital + Cristales flotantes
            elif tier == 3:
                for side in [-1, 1]:
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.04, radius2=0.005, depth=0.28, location=(x_pos + side * (body_size * 0.52), y_pos + 0.05, body_z + 0.05))
                    wing = bpy.context.active_object
                    wing.name = f"{pet_id}_AlaHielo_{'L' if side<0 else 'R'}"
                    wing.rotation_euler = (0.2, side * 0.65, 0)
                    add_p(wing)
                    wing.data.materials.append(m_fur_ice)
                    set_smooth(wing, False)

                bpy.ops.mesh.primitive_torus_add(major_radius=body_size * 0.65, minor_radius=0.010, location=(x_pos, y_pos, body_z), major_segments=20, minor_segments=6)
                o_ring = bpy.context.active_object
                o_ring.name = f"{pet_id}_AnilloOrbital"
                o_ring.rotation_euler = (0.35, 0.25, i * 0.4)
                add_p(o_ring)
                o_ring.data.materials.append(metal_m)
                set_smooth(o_ring, True)

                for s_i, s_ang in enumerate([0.0, math.pi]):
                    sx = x_pos + math.cos(s_ang + i) * (body_size * 0.75)
                    sy = y_pos + math.sin(s_ang + i) * (body_size * 0.75)
                    sz = body_z + 0.1 * math.sin(s_ang)
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.025, radius2=0, depth=0.065, location=(sx, sy, sz))
                    ic = bpy.context.active_object
                    ic.name = f"{pet_id}_CristalHielo_{s_i+1}"
                    add_p(ic)
                    ic.data.materials.append(glow_m)
                    set_smooth(ic, False)

            # TIER 4: ÉPICO - Alas de Murciélago/Gárgola + Doble Anillo + Cristales de Vacío
            elif tier == 4:
                for side in [-1, 1]:
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.055, radius2=0.008, depth=0.38, location=(x_pos + side * (body_size * 0.55), y_pos + 0.08, body_z + 0.10))
                    wing = bpy.context.active_object
                    wing.name = f"{pet_id}_AlaGárgola_{'L' if side<0 else 'R'}"
                    wing.rotation_euler = (0.3, side * 0.75, 0)
                    add_p(wing)
                    wing.data.materials.append(m_fur_shadow)
                    set_smooth(wing, False)

                for r_i, r_rot in enumerate([0.5, -0.5]):
                    bpy.ops.mesh.primitive_torus_add(major_radius=body_size * 0.70, minor_radius=0.010, location=(x_pos, y_pos, body_z), major_segments=20, minor_segments=6)
                    r = bpy.context.active_object
                    r.name = f"{pet_id}_AnilloDoble_{r_i+1}"
                    r.rotation_euler = (r_rot, 0.4, r_rot * 2 + i * 0.3)
                    add_p(r)
                    r.data.materials.append(metal_m)
                    set_smooth(r, True)

                for s_i in range(3):
                    s_ang = s_i * (2 * math.pi / 3) + i * 0.4
                    sx = x_pos + math.cos(s_ang) * (body_size * 0.85)
                    sy = y_pos + math.sin(s_ang) * (body_size * 0.85)
                    sz = body_z + 0.08 * math.sin(s_ang * 2)
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.03, radius2=0, depth=0.075, location=(sx, sy, sz))
                    vc = bpy.context.active_object
                    vc.name = f"{pet_id}_CristalVacio_{s_i+1}"
                    add_p(vc)
                    vc.data.materials.append(glow_m)
                    set_smooth(vc, False)

            # TIER 5: LEGENDARIO - Alas Serafín Doradas + Aureola Flotante + 4 Estrellas
            elif tier == 5:
                for side in [-1, 1]:
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.065, radius2=0.010, depth=0.48, location=(x_pos + side * (body_size * 0.58), y_pos + 0.10, body_z + 0.15))
                    wing = bpy.context.active_object
                    wing.name = f"{pet_id}_AlaSerafin_{'L' if side<0 else 'R'}"
                    wing.rotation_euler = (0.25, side * 0.80, 0)
                    add_p(wing)
                    wing.data.materials.append(metal_m)
                    set_smooth(wing, True)

                bpy.ops.mesh.primitive_torus_add(major_radius=body_size * 0.32, minor_radius=0.014, location=(x_pos, y_pos, body_z + body_size * 0.75), major_segments=20, minor_segments=6)
                halo = bpy.context.active_object
                halo.name = f"{pet_id}_Aureola"
                halo.rotation_euler = (0.15, 0, 0)
                add_p(halo)
                halo.data.materials.append(metal_m)
                set_smooth(halo, True)

                for s_i in range(4):
                    s_ang = s_i * (math.pi / 2) + i * 0.5
                    sx = x_pos + math.cos(s_ang) * (body_size * 0.90)
                    sy = y_pos + math.sin(s_ang) * (body_size * 0.90)
                    sz = body_z + 0.12 * math.sin(s_ang * 2)
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.035, radius2=0, depth=0.08, location=(sx, sy, sz))
                    st = bpy.context.active_object
                    st.name = f"{pet_id}_EstrellaSolar_{s_i+1}"
                    add_p(st)
                    st.data.materials.append(glow_m)
                    set_smooth(st, False)

            # TIER 6: MÍTICO - Alas Astrales de Luz + 3 Anillos Saturno + 5 Supernovas + Luz Propia
            elif tier == 6:
                for side in [-1, 1]:
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.075, radius2=0.012, depth=0.55, location=(x_pos + side * (body_size * 0.62), y_pos + 0.10, body_z + 0.18))
                    wing = bpy.context.active_object
                    wing.name = f"{pet_id}_AlaCosmica_{'L' if side<0 else 'R'}"
                    wing.rotation_euler = (0.2, side * 0.85, 0)
                    add_p(wing)
                    wing.data.materials.append(glow_m)
                    set_smooth(wing, False)

                for r_idx in range(3):
                    r_rad = body_size * (0.80 + r_idx * 0.18)
                    bpy.ops.mesh.primitive_torus_add(major_radius=r_rad, minor_radius=0.012, location=(x_pos, y_pos, body_z), major_segments=22, minor_segments=6)
                    g_ring = bpy.context.active_object
                    g_ring.name = f"{pet_id}_AnilloSaturno_{r_idx+1}"
                    g_ring.rotation_euler = (0.6 * r_idx, 0.4 * (r_idx + 1), i * 0.3 + r_idx * 0.8)
                    add_p(g_ring)
                    g_ring.data.materials.append(metal_m)
                    set_smooth(g_ring, True)

                for s_i in range(5):
                    s_ang = s_i * (2 * math.pi / 5) + i * 0.4
                    sx = x_pos + math.cos(s_ang) * (body_size * 1.15)
                    sy = y_pos + math.sin(s_ang) * (body_size * 1.15)
                    sz = body_z + 0.15 * math.sin(s_ang * 2)
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.04, radius2=0, depth=0.09, location=(sx, sy, sz))
                    st = bpy.context.active_object
                    st.name = f"{pet_id}_Supernova_{s_i+1}"
                    add_p(st)
                    st.data.materials.append(m_plasma_core if s_i % 2 == 0 else glow_m)
                    set_smooth(st, False)

                l_data = bpy.data.lights.new(name=f"{pet_id}_LuzData", type='POINT')
                l_data.color = (0.15, 1.0, 0.95)
                l_data.energy = 35.0
                l_obj = bpy.data.objects.new(f"{pet_id}_LuzCosmica", l_data)
                l_obj.location = (x_pos, y_pos, body_z + 0.2)
                add_p(l_obj)

    # Encuadre y Guardado
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
    print(">>> ARCHIVO .BLEND GUARDADO CON ÉXITO <<<")

    # Exportar FBX para Roblox
    fbx_path = r"c:\Users\Antonio Garcia\Downloads\blender\Mascotas_120_Roblox.fbx"
    bpy.ops.export_scene.fbx(
        filepath=fbx_path,
        use_selection=False,
        global_scale=1.0,
        apply_unit_scale=True,
        apply_scale_options='FBX_SCALE_ALL',
        mesh_smooth_type='FACE'
    )
    print(">>> FBX EXPORTADO: " + fbx_path + " <<<")
    print(">>> 120 MASCOTAS ROBLOX CHIBI COMPLETADAS Y EXPORTADAS! <<<")

generate_120_pets_fast()
