import bpy
import math

def build_6_rebirth_stations():
    # 1. Limpiar puesto anterior si existía
    if "Puesto_Entrenamiento_Magico" in bpy.data.collections:
        c = bpy.data.collections["Puesto_Entrenamiento_Magico"]
        for o in list(c.objects):
            bpy.data.objects.remove(o, do_unlink=True)
        bpy.data.collections.remove(c)

    # 2. Materiales PBR Específicos para los 6 Puestos
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

    # Materiales de Estructura y Decoración
    m_soil = get_or_make_mat("RS_Tierra_Novato", (0.28, 0.18, 0.10, 1.0), roughness=0.95)
    m_wood_rustic = get_or_make_mat("RS_Madera_Rustica", (0.35, 0.22, 0.12, 1.0), roughness=0.85)
    m_wood_polished = get_or_make_mat("RS_Madera_Pulida", (0.46, 0.26, 0.12, 1.0), roughness=0.45)
    m_burlap = get_or_make_mat("RS_Tela_Arpillera", (0.72, 0.64, 0.48, 1.0), roughness=0.9)
    m_rope = get_or_make_mat("RS_Cuerda", (0.40, 0.32, 0.22, 1.0), roughness=0.95)
    m_straw = get_or_make_mat("RS_Paja_Sombrero", (0.80, 0.72, 0.42, 1.0), roughness=0.8)

    m_stone_grey = get_or_make_mat("RS_Piedra_Gris", (0.26, 0.27, 0.29, 1.0), roughness=0.7)
    m_bronze = get_or_make_mat("RS_Bronce_Forjado", (0.76, 0.46, 0.18, 1.0), metallic=0.92, roughness=0.28)
    m_stone_blue = get_or_make_mat("RS_Pizarra_Azul", (0.12, 0.16, 0.24, 1.0), roughness=0.6)
    m_leather_blue = get_or_make_mat("RS_Cuero_Azul", (0.05, 0.09, 0.22, 1.0), roughness=0.65)
    m_silver = get_or_make_mat("RS_Plata_Estelar", (0.86, 0.89, 0.94, 1.0), metallic=0.96, roughness=0.18)
    m_obsidian = get_or_make_mat("RS_Obsidiana_Gotica", (0.03, 0.03, 0.05, 1.0), metallic=0.4, roughness=0.1)
    m_marble_white = get_or_make_mat("RS_Marmol_Celestial", (0.92, 0.90, 0.86, 1.0), roughness=0.25)
    m_wood_divine = get_or_make_mat("RS_Madera_Divina", (0.92, 0.90, 0.85, 1.0), roughness=0.25)
    m_gold_celestial = get_or_make_mat("RS_Oro_Celestial", (1.0, 0.82, 0.22, 1.0), metallic=0.98, roughness=0.16)
    m_divine_gold = get_or_make_mat("RS_Oro_Cosmico", (1.0, 0.95, 0.45, 1.0), metallic=1.0, roughness=0.10, emission=(1.0, 0.90, 0.40, 1.0), emission_val=4.0)
    m_void_rock = get_or_make_mat("RS_Roca_Vacio", (0.06, 0.04, 0.09, 1.0), roughness=0.5)

    # Luces mágicas y emisivos progresivos
    m_glow_green = get_or_make_mat("RS_Glow_Verde", (0.15, 1.0, 0.35, 1.0), roughness=0.1, emission=(0.15, 1.0, 0.35, 1.0), emission_val=6.0)
    m_glow_cyan = get_or_make_mat("RS_Glow_Cian", (0.1, 0.85, 1.0, 1.0), roughness=0.1, emission=(0.1, 0.85, 1.0, 1.0), emission_val=9.0)
    m_glow_purple = get_or_make_mat("RS_Glow_Purpura", (0.95, 0.15, 1.0, 1.0), roughness=0.08, emission=(0.95, 0.15, 1.0, 1.0), emission_val=13.0)
    m_glow_solar = get_or_make_mat("RS_Glow_Solar", (1.0, 0.80, 0.15, 1.0), roughness=0.05, emission=(1.0, 0.82, 0.15, 1.0), emission_val=18.0)
    m_glow_cosmic = get_or_make_mat("RS_Glow_Cosmico", (0.1, 1.0, 0.95, 1.0), roughness=0.0, emission=(0.15, 1.0, 0.98, 1.0), emission_val=28.0)
    m_plasma_core = get_or_make_mat("RS_Plasma_Core", (1.0, 0.3, 0.9, 1.0), roughness=0.0, emission=(1.0, 0.35, 0.95, 1.0), emission_val=35.0)

    # 3. Datos de los 6 Puestos de Rebirth
    stations = [
        {
            "tier": 0, "name": "0_Rebirths_Novato", "label": "0 REBIRTHS", "x": -15.0,
            "dais_mat": m_soil, "border_mat": m_wood_rustic, "metal": m_wood_rustic, "glow": m_wood_rustic,
            "has_glow": False, "hat_mat": m_straw, "shield": False, "monolith": False, "light_color": None
        },
        {
            "tier": 1, "name": "1_Rebirth_Aprendiz", "label": "1 REBIRTH", "x": -9.0,
            "dais_mat": m_stone_grey, "border_mat": m_bronze, "metal": m_bronze, "glow": m_glow_green,
            "has_glow": True, "hat_mat": m_wood_polished, "shield": True, "monolith": False, "light_color": (0.2, 1.0, 0.4)
        },
        {
            "tier": 2, "name": "2_Rebirths_Hechicero", "label": "2 REBIRTHS", "x": -3.0,
            "dais_mat": m_stone_blue, "border_mat": m_silver, "metal": m_silver, "glow": m_glow_cyan,
            "has_glow": True, "hat_mat": m_leather_blue, "shield": True, "monolith": True, "light_color": (0.1, 0.85, 1.0)
        },
        {
            "tier": 3, "name": "3_Rebirths_Archimago", "label": "3 REBIRTHS", "x": 3.0,
            "dais_mat": m_obsidian, "border_mat": m_silver, "metal": m_silver, "glow": m_glow_purple,
            "has_glow": True, "hat_mat": m_obsidian, "shield": True, "monolith": True, "light_color": (0.9, 0.2, 1.0)
        },
        {
            "tier": 4, "name": "4_Rebirths_Celestial", "label": "4 REBIRTHS", "x": 9.0,
            "dais_mat": m_marble_white, "border_mat": m_gold_celestial, "metal": m_gold_celestial, "glow": m_glow_solar,
            "has_glow": True, "hat_mat": m_gold_celestial, "shield": True, "monolith": True, "light_color": (1.0, 0.85, 0.2)
        },
        {
            "tier": 5, "name": "5_Rebirths_Cosmico", "label": "5+ REBIRTHS (GOD)", "x": 15.0,
            "dais_mat": m_wood_divine, "border_mat": m_divine_gold, "metal": m_divine_gold, "glow": m_glow_cosmic,
            "has_glow": True, "hat_mat": m_divine_gold, "shield": True, "monolith": True, "light_color": (0.15, 1.0, 0.95)
        }
    ]

    y_pos = -6.0

    # 4. Generación de cada Puesto
    for st in stations:
        t = st["tier"]
        cname = f"Puesto_Rebirth_{st['name']}"
        
        # Limpiar si ya existía
        if cname in bpy.data.collections:
            old_c = bpy.data.collections[cname]
            for o in list(old_c.objects):
                bpy.data.objects.remove(o, do_unlink=True)
            bpy.data.collections.remove(old_c)

        col = bpy.data.collections.new(cname)
        bpy.context.scene.collection.children.link(col)

        def add_obj(obj):
            for c in list(obj.users_collection):
                c.objects.unlink(obj)
            col.objects.link(obj)

        sx = st["x"]
        sy = y_pos

        # -------------------------------------------------------------
        # A) CARTEL / PLACA DE REBIRTH FLOTANTE FRENTE AL PUESTO
        # -------------------------------------------------------------
        sign_y = sy - 2.8
        bpy.ops.mesh.primitive_cube_add(size=0.15, location=(sx, sign_y, 0.45))
        sign_post = bpy.context.active_object
        sign_post.name = f"{cname}_Cartel_Poste"
        sign_post.scale = (0.5, 0.5, 3.0)
        add_obj(sign_post)
        sign_post.data.materials.append(st["border_mat"])
        bpy.ops.object.shade_flat()

        # Placa del cartel
        bpy.ops.mesh.primitive_cube_add(size=0.40, location=(sx, sign_y, 0.85))
        sign_board = bpy.context.active_object
        sign_board.name = f"{cname}_Cartel_Placa"
        sign_board.scale = (1.9, 0.25, 0.85)
        add_obj(sign_board)
        sign_board.data.materials.append(st["dais_mat"])
        bpy.ops.object.shade_flat()

        # Marco y gema indicadora en la placa
        bpy.ops.mesh.primitive_torus_add(major_radius=0.18, minor_radius=0.015, location=(sx, sign_y, 0.85), major_segments=16, minor_segments=6)
        sign_frame = bpy.context.active_object
        sign_frame.name = f"{cname}_Cartel_Marco"
        sign_frame.rotation_euler[0] = math.pi / 2
        add_obj(sign_frame)
        sign_frame.data.materials.append(st["border_mat"])
        bpy.ops.object.shade_smooth()

        if st["has_glow"]:
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.07, location=(sx, sign_y - 0.05, 0.85))
            sign_gem = bpy.context.active_object
            sign_gem.name = f"{cname}_Cartel_Gema"
            add_obj(sign_gem)
            sign_gem.data.materials.append(st["glow"])
            bpy.ops.object.shade_flat()

        # -------------------------------------------------------------
        # B) PLATAFORMA / BASE
        # -------------------------------------------------------------
        # Si es Tier 5 (Cósmico/Dios), la plataforma levita fracturada en islas separadas
        if t == 5:
            # Núcleo central flotante
            bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.3, depth=0.18, location=(sx, sy, 0.35))
            c_island = bpy.context.active_object
            c_island.name = f"{cname}_Isla_Central"
            add_obj(c_island)
            c_island.data.materials.append(m_wood_divine)
            bpy.ops.object.shade_flat()

            # 4 Islas satélite flotantes alrededor
            for isl_i in range(4):
                i_ang = isl_i * (math.pi / 2) + math.pi / 4
                ix = sx + math.cos(i_ang) * 1.95
                iy = sy + math.sin(i_ang) * 1.95
                iz = 0.30 + 0.08 * math.sin(isl_i * 2)
                bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.65, depth=0.16, location=(ix, iy, iz))
                isl = bpy.context.active_object
                isl.name = f"{cname}_Isla_Satelite_{isl_i+1}"
                add_obj(isl)
                isl.data.materials.append(m_marble_white)
                bpy.ops.object.shade_flat()

            # Vórtice de nebulosa cósmica en el suelo debajo de las islas
            bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.4, depth=0.01, location=(sx, sy, 0.02))
            vortex = bpy.context.active_object
            vortex.name = f"{cname}_Vortice_Suelo"
            add_obj(vortex)
            vortex.data.materials.append(m_glow_cosmic)
            bpy.ops.object.shade_flat()

        else:
            # Plataforma octagonal sólida en el suelo
            dais_rad = 2.1 + 0.08 * t
            bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=dais_rad, depth=0.16, location=(sx, sy, 0.08))
            dais = bpy.context.active_object
            dais.name = f"{cname}_Plataforma"
            add_obj(dais)
            dais.data.materials.append(st["dais_mat"])
            bpy.ops.object.shade_flat()

            # Borde perimetral
            bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=dais_rad + 0.15, depth=0.08, location=(sx, sy, 0.04))
            b_step = bpy.context.active_object
            b_step.name = f"{cname}_Borde"
            add_obj(b_step)
            b_step.data.materials.append(st["border_mat"])
            bpy.ops.object.shade_flat()

            # Círculo rúnico grabado en el suelo si tier >= 1
            if st["has_glow"]:
                bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.65, depth=0.005, location=(sx, sy, 0.165))
                r_floor = bpy.context.active_object
                r_floor.name = f"{cname}_CirculoRunas"
                add_obj(r_floor)
                r_floor.data.materials.append(st["glow"])

                bpy.ops.mesh.primitive_torus_add(major_radius=1.70, minor_radius=0.018, location=(sx, sy, 0.17), major_segments=32, minor_segments=8)
                r_ring = bpy.context.active_object
                r_ring.name = f"{cname}_AnilloRunas"
                add_obj(r_ring)
                r_ring.data.materials.append(st["metal"])
                bpy.ops.object.shade_smooth()

        # -------------------------------------------------------------
        # C) PILARES / ANTORCHAS EN LAS 4 ESQUINAS
        # -------------------------------------------------------------
        if t == 0:
            # Estacas de madera rústica en el perímetro
            for pi in range(6):
                pang = pi * (2 * math.pi / 6)
                px = sx + math.cos(pang) * 2.05
                py = sy + math.sin(pang) * 2.05
                bpy.ops.mesh.primitive_cylinder_add(radius=0.07, depth=0.65, location=(px, py, 0.325), vertices=8)
                stake = bpy.context.active_object
                stake.name = f"{cname}_Estaca_{pi+1}"
                add_obj(stake)
                stake.data.materials.append(m_wood_rustic)
                bpy.ops.object.shade_flat()
        else:
            for pi in range(4):
                pang = pi * (math.pi / 2) + math.pi / 4
                px = sx + math.cos(pang) * 1.95
                py = sy + math.sin(pang) * 1.95
                pz = 0.38 if t < 5 else 0.55
                
                bpy.ops.mesh.primitive_cube_add(size=0.25, location=(px, py, pz))
                pillar = bpy.context.active_object
                pillar.name = f"{cname}_Pilar_{pi+1}"
                pillar.scale = (1, 1, 2.4)
                add_obj(pillar)
                pillar.data.materials.append(st["dais_mat"])
                bpy.ops.object.shade_flat()

                # Llama o cristal en la cima
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.09, location=(px, py, pz + 0.55))
                flm = bpy.context.active_object
                flm.name = f"{cname}_LlamaPilar_{pi+1}"
                flm.scale = (0.8, 0.8, 1.4)
                add_obj(flm)
                flm.data.materials.append(st["glow"])
                bpy.ops.object.shade_smooth()

                # Anillo de pilar
                bpy.ops.mesh.primitive_torus_add(major_radius=0.12, minor_radius=0.007, location=(px, py, pz + 0.55), major_segments=16, minor_segments=6)
                pring = bpy.context.active_object
                pring.name = f"{cname}_AnilloPilar_{pi+1}"
                pring.rotation_euler = (0.3, 0.3 * pi, 0.5)
                add_obj(pring)
                pring.data.materials.append(st["metal"])
                bpy.ops.object.shade_smooth()

        # -------------------------------------------------------------
        # D) MUÑECO DE ENTRENAMIENTO (DUMMY ESCALADO POR REBIRTH)
        # -------------------------------------------------------------
        dx = sx
        dy = sy - 0.30
        dz = 0.16 if t < 5 else 0.45

        # Mástil del dummy
        bpy.ops.mesh.primitive_cylinder_add(radius=0.09, depth=1.85, location=(dx, dy, dz + 0.92), vertices=12)
        d_pole = bpy.context.active_object
        d_pole.name = f"{cname}_Dummy_Poste"
        add_obj(d_pole)
        d_pole.data.materials.append(m_wood_rustic if t == 0 else m_wood_polished)
        bpy.ops.object.shade_smooth()

        # Base en cruz
        for rot in [0, math.pi / 2]:
            bpy.ops.mesh.primitive_cube_add(size=0.16, location=(dx, dy, dz + 0.08))
            c_b = bpy.context.active_object
            c_b.name = f"{cname}_Dummy_Cruz"
            c_b.scale = (3.8, 0.8, 0.8)
            c_b.rotation_euler[2] = rot
            add_obj(c_b)
            c_b.data.materials.append(m_wood_rustic if t == 0 else st["border_mat"])
            bpy.ops.object.shade_flat()

        # Torso
        bpy.ops.mesh.primitive_cylinder_add(radius=0.23, depth=0.72, location=(dx, dy, dz + 1.12), vertices=14)
        d_torso = bpy.context.active_object
        d_torso.name = f"{cname}_Dummy_Torso"
        d_torso.scale = (1.1, 0.85, 1.0)
        add_obj(d_torso)
        d_torso.data.materials.append(m_burlap if t <= 2 else (m_obsidian if t == 3 else m_marble_white))
        bpy.ops.object.shade_smooth()

        # Diana de impacto en el pecho
        bpy.ops.mesh.primitive_cylinder_add(radius=0.14, depth=0.02, location=(dx, dy - 0.21, dz + 1.15), vertices=16)
        d_target = bpy.context.active_object
        d_target.name = f"{cname}_Dummy_Diana"
        d_target.rotation_euler[0] = math.pi / 2
        add_obj(d_target)
        d_target.data.materials.append(m_wood_rustic if t == 0 else st["glow"])
        bpy.ops.object.shade_smooth()

        bpy.ops.mesh.primitive_torus_add(major_radius=0.15, minor_radius=0.015, location=(dx, dy - 0.21, dz + 1.15), major_segments=16, minor_segments=8)
        t_ring = bpy.context.active_object
        t_ring.name = f"{cname}_Dummy_DianaBorde"
        t_ring.rotation_euler[0] = math.pi / 2
        add_obj(t_ring)
        t_ring.data.materials.append(st["metal"])
        bpy.ops.object.shade_smooth()

        # Brazos con guantes
        bpy.ops.mesh.primitive_cylinder_add(radius=0.065, depth=1.1, location=(dx, dy, dz + 1.32), vertices=10)
        d_arms = bpy.context.active_object
        d_arms.name = f"{cname}_Dummy_Brazos"
        d_arms.rotation_euler[1] = math.pi / 2
        add_obj(d_arms)
        d_arms.data.materials.append(m_wood_rustic if t == 0 else m_wood_polished)
        bpy.ops.object.shade_smooth()

        for arm_s in [-1, 1]:
            bpy.ops.mesh.primitive_uv_sphere_add(radius=0.10, location=(dx + arm_s * 0.55, dy, dz + 1.32), segments=12, ring_count=8)
            glo = bpy.context.active_object
            glo.name = f"{cname}_Dummy_Guante_{'L' if arm_s < 0 else 'R'}"
            add_obj(glo)
            glo.data.materials.append(m_burlap if t <= 2 else st["metal"])
            bpy.ops.object.shade_smooth()

        # Cabeza
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(dx, dy, dz + 1.66), segments=14, ring_count=10)
        d_head = bpy.context.active_object
        d_head.name = f"{cname}_Dummy_Cabeza"
        add_obj(d_head)
        d_head.data.materials.append(m_burlap if t <= 2 else m_marble_white)
        bpy.ops.object.shade_smooth()

        # Sombrero / Casco evolucionado por Rebirth
        if t == 0:
            # Gorro de paja campesino
            bpy.ops.mesh.primitive_cone_add(radius1=0.32, radius2=0.04, depth=0.14, location=(dx, dy, dz + 1.82), vertices=16)
            hat = bpy.context.active_object
            hat.name = f"{cname}_Dummy_SombreroPaja"
            add_obj(hat)
            hat.data.materials.append(m_straw)
            bpy.ops.object.shade_flat()
        else:
            # Gorro o corona mágica
            bpy.ops.mesh.primitive_cylinder_add(radius=0.28, depth=0.03, location=(dx, dy, dz + 1.78), vertices=16)
            h_brim = bpy.context.active_object
            h_brim.name = f"{cname}_Dummy_AlaSombrero"
            add_obj(h_brim)
            h_brim.data.materials.append(st["hat_mat"])
            bpy.ops.object.shade_smooth()

            bpy.ops.mesh.primitive_cone_add(radius1=0.19, radius2=0.02, depth=0.36, location=(dx, dy - 0.02, dz + 1.95), vertices=14)
            h_cone = bpy.context.active_object
            h_cone.name = f"{cname}_Dummy_ConoSombrero"
            h_cone.rotation_euler[0] = 0.20
            add_obj(h_cone)
            h_cone.data.materials.append(st["hat_mat"])
            bpy.ops.object.shade_smooth()

        # Alas especiales en el dummy para Rebirths altos (>= 3)
        if t >= 3:
            for w_side in [-1, 1]:
                bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.035, radius2=0.005, depth=0.45, location=(dx + w_side * 0.18, dy + 0.12, dz + 1.45))
                d_wing = bpy.context.active_object
                d_wing.name = f"{cname}_Dummy_Ala_{'L' if w_side<0 else 'R'}"
                d_wing.rotation_euler = (0.2, w_side * 0.55, 0)
                add_obj(d_wing)
                d_wing.data.materials.append(st["border_mat"])
                bpy.ops.object.shade_flat()

        # -------------------------------------------------------------
        # E) ESCUDO DE ENERGÍA FLOTANTE (Si tier >= 1)
        # -------------------------------------------------------------
        if st["shield"]:
            shx, shy, shz = dx + 0.70, dy - 0.15, dz + 1.15
            bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.32, depth=0.015, location=(shx, shy, shz))
            sh_core = bpy.context.active_object
            sh_core.name = f"{cname}_Escudo_Hexagonal"
            sh_core.rotation_euler = (0.2, -0.2, 0.4)
            add_obj(sh_core)
            sh_core.data.materials.append(st["glow"])
            bpy.ops.object.shade_flat()

            bpy.ops.mesh.primitive_torus_add(major_radius=0.33, minor_radius=0.018, location=(shx, shy, shz), major_segments=6, minor_segments=6)
            sh_rim = bpy.context.active_object
            sh_rim.name = f"{cname}_Escudo_Borde"
            sh_rim.rotation_euler = (0.2, -0.2, 0.4)
            add_obj(sh_rim)
            sh_rim.data.materials.append(st["metal"])
            bpy.ops.object.shade_flat()

        # -------------------------------------------------------------
        # F) ATRIL / LIBRO DE HECHIZOS (A la izquierda)
        # -------------------------------------------------------------
        lx, ly, lz = sx - 1.25, sy + 0.20, dz
        if t == 0:
            # Tocón de madera rústica de novato
            bpy.ops.mesh.primitive_cylinder_add(radius=0.22, depth=0.75, location=(lx, ly, lz + 0.375), vertices=10)
            stump = bpy.context.active_object
            stump.name = f"{cname}_Tocon_Madera"
            add_obj(stump)
            stump.data.materials.append(m_wood_rustic)
            bpy.ops.object.shade_flat()

            # Pergamino enrollado
            bpy.ops.mesh.primitive_cylinder_add(radius=0.03, depth=0.25, location=(lx, ly, lz + 0.78), vertices=8)
            scroll = bpy.context.active_object
            scroll.name = f"{cname}_Pergamino"
            scroll.rotation_euler = (0, math.pi / 2, 0.3)
            add_obj(scroll)
            scroll.data.materials.append(m_burlap)
            bpy.ops.object.shade_flat()
        else:
            # Pedestal de piedra
            bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.18, depth=0.95, location=(lx, ly, lz + 0.475))
            lec = bpy.context.active_object
            lec.name = f"{cname}_Atril_Pedestal"
            add_obj(lec)
            lec.data.materials.append(st["dais_mat"])
            bpy.ops.object.shade_flat()

            bpy.ops.mesh.primitive_cube_add(size=0.35, location=(lx, ly, lz + 0.98))
            lec_top = bpy.context.active_object
            lec_top.name = f"{cname}_Atril_Tabla"
            lec_top.scale = (1.2, 0.9, 0.08)
            lec_top.rotation_euler = (0.45, 0, -0.3)
            add_obj(lec_top)
            lec_top.data.materials.append(st["border_mat"])
            bpy.ops.object.shade_flat()

            # Grimorio
            bpy.ops.mesh.primitive_cube_add(size=0.30, location=(lx + 0.01, ly - 0.02, lz + 1.02))
            book = bpy.context.active_object
            book.name = f"{cname}_Grimorio"
            book.scale = (1.1, 0.7, 0.05)
            book.rotation_euler = (0.45, 0, -0.3)
            add_obj(book)
            book.data.materials.append(st["hat_mat"])
            bpy.ops.object.shade_flat()

            # Páginas de luz
            bpy.ops.mesh.primitive_cube_add(size=0.26, location=(lx + 0.01, ly - 0.02, lz + 1.035))
            pages = bpy.context.active_object
            pages.name = f"{cname}_Grimorio_Luz"
            pages.scale = (1.0, 0.62, 0.03)
            pages.rotation_euler = (0.45, 0, -0.3)
            add_obj(pages)
            pages.data.materials.append(st["glow"])
            bpy.ops.object.shade_flat()

            # Holograma rúnico flotante sobre el grimorio
            bpy.ops.mesh.primitive_torus_add(major_radius=0.18, minor_radius=0.007, location=(lx, ly, lz + 1.28), major_segments=20, minor_segments=6)
            holo = bpy.context.active_object
            holo.name = f"{cname}_Holo_Grimorio"
            holo.rotation_euler = (0.45, 0, -0.3)
            add_obj(holo)
            holo.data.materials.append(st["metal"])
            bpy.ops.object.shade_smooth()

        # -------------------------------------------------------------
        # G) SUMINISTROS / BARRIL DE POCIONES (A la derecha)
        # -------------------------------------------------------------
        bx, by, bz = sx + 1.25, sy + 0.20, dz
        if t == 0:
            # Cubo / Balde de madera con poción simple
            bpy.ops.mesh.primitive_cylinder_add(radius=0.22, depth=0.45, location=(bx, by, bz + 0.225), vertices=10)
            bucket = bpy.context.active_object
            bucket.name = f"{cname}_Balde_Madera"
            add_obj(bucket)
            bucket.data.materials.append(m_wood_rustic)
            bpy.ops.object.shade_flat()
        else:
            bpy.ops.mesh.primitive_cylinder_add(radius=0.25, depth=0.62, location=(bx, by, bz + 0.31), vertices=12)
            barrel = bpy.context.active_object
            barrel.name = f"{cname}_Barril"
            add_obj(barrel)
            barrel.data.materials.append(m_wood_polished if t <= 3 else st["dais_mat"])
            bpy.ops.object.shade_smooth()

            # Frascos de pociones brillantes
            for p_i in range(2):
                p_off = (p_i - 0.5) * 0.18
                bpy.ops.mesh.primitive_uv_sphere_add(radius=0.065, location=(bx + p_off, by, bz + 0.68), segments=10, ring_count=8)
                flask = bpy.context.active_object
                flask.name = f"{cname}_Pocion_{p_i+1}"
                add_obj(flask)
                flask.data.materials.append(st["glow"])
                bpy.ops.object.shade_smooth()

        # -------------------------------------------------------------
        # H) GRAN MONOLITO DE CRISTAL / VÓRTICE AL FONDO (Tiers >= 2)
        # -------------------------------------------------------------
        if st["monolith"]:
            mx, my, mz = sx, sy + 1.15, dz + 1.35
            
            # Si es el Mítico (Tier 5), es un Super-Monolito de Agujero de Gusano Cósmico
            if t == 5:
                # Esfera exterior de agujero de gusano
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.38, location=(mx, my, mz))
                m_core = bpy.context.active_object
                m_core.name = f"{cname}_SuperMonolito_Core"
                add_obj(m_core)
                m_core.data.materials.append(m_plasma_core)
                bpy.ops.object.shade_smooth()

                # 3 Anillos giroscópicos gigantes
                for g_i in range(3):
                    bpy.ops.mesh.primitive_torus_add(major_radius=0.50 + g_i * 0.12, minor_radius=0.014, location=(mx, my, mz), major_segments=28, minor_segments=8)
                    m_ring = bpy.context.active_object
                    m_ring.name = f"{cname}_Monolito_Halo_{g_i+1}"
                    m_ring.rotation_euler = (0.6 * g_i, 0.4 * (g_i + 1), g_i * 0.8)
                    add_obj(m_ring)
                    m_ring.data.materials.append(m_divine_gold)
                    bpy.ops.object.shade_smooth()

                # 4 Estrellas orbitando el super-monolito
                for st_i in range(4):
                    st_ang = st_i * (math.pi / 2)
                    stx = mx + math.cos(st_ang) * 0.65
                    sty = my + math.sin(st_ang) * 0.65
                    stz = mz + 0.15 * math.sin(st_ang * 2)
                    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.05, radius2=0, depth=0.12, location=(stx, sty, stz))
                    s_star = bpy.context.active_object
                    s_star.name = f"{cname}_Monolito_Estrella_{st_i+1}"
                    add_obj(s_star)
                    s_star.data.materials.append(m_glow_cosmic)
                    bpy.ops.object.shade_flat()
            else:
                # Monolito biterminado clásico escalado
                m_rad = 0.22 + 0.03 * t
                bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=m_rad, radius2=0, depth=0.70, location=(mx, my, mz + 0.10))
                c_top = bpy.context.active_object
                c_top.name = f"{cname}_Monolito_Top"
                add_obj(c_top)
                c_top.data.materials.append(st["glow"])
                bpy.ops.object.shade_flat()

                bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=m_rad, radius2=0, depth=0.45, location=(mx, my, mz - 0.20))
                c_bot = bpy.context.active_object
                c_bot.name = f"{cname}_Monolito_Bot"
                c_bot.rotation_euler[0] = math.pi
                add_obj(c_bot)
                c_bot.data.materials.append(st["glow"])
                bpy.ops.object.shade_flat()

                # Anillo orbital
                bpy.ops.mesh.primitive_torus_add(major_radius=m_rad * 1.5, minor_radius=0.012, location=(mx, my, mz), major_segments=24, minor_segments=8)
                m_ring = bpy.context.active_object
                m_ring.name = f"{cname}_Monolito_Anillo"
                m_ring.rotation_euler = (0.5, 0.3, 0)
                add_obj(m_ring)
                m_ring.data.materials.append(st["metal"])
                bpy.ops.object.shade_smooth()

        # -------------------------------------------------------------
        # I) ILUMINACIÓN PUNTUAL DINÁMICA
        # -------------------------------------------------------------
        if st["light_color"]:
            l_data = bpy.data.lights.new(name=f"{cname}_LightData", type='POINT')
            l_data.color = st["light_color"]
            l_data.energy = 50.0 + 35.0 * t
            l_obj = bpy.data.objects.new(f"{cname}_LuzEstacion", l_data)
            l_obj.location = (sx, sy, dz + 1.5)
            add_obj(l_obj)

    # 5. Encuadre y Guardado
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
    print(">>> 6 PUESTOS DE ENTRENAMIENTO MÁGICO POR REBIRTHS MODELADOS CON ÉXITO TOTAL! <<<")

build_6_rebirth_stations()
