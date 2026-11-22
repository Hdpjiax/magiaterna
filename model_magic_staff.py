import bpy
import math

def build_magic_staff():
    # 1. Eliminar el cubo por defecto si existe
    if "Cube" in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects["Cube"], do_unlink=True)
    
    # 2. Crear o limpiar coleccion Baston_Magico
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

    # 3. Crear Materiales
    def get_or_create_material(name, base_color, metallic=0.0, roughness=0.5, emission_color=None, emission_strength=0.0):
        mat = bpy.data.materials.get(name)
        if not mat:
            mat = bpy.data.materials.new(name=name)
            mat.use_nodes = True
        nodes = mat.node_tree.nodes
        bsdf = nodes.get("Principled BSDF")
        if bsdf:
            # Color base
            if "Base Color" in bsdf.inputs:
                bsdf.inputs["Base Color"].default_value = base_color
            if "Metallic" in bsdf.inputs:
                bsdf.inputs["Metallic"].default_value = metallic
            if "Roughness" in bsdf.inputs:
                bsdf.inputs["Roughness"].default_value = roughness
            if emission_color and "Emission Color" in bsdf.inputs:
                bsdf.inputs["Emission Color"].default_value = emission_color
                if "Emission Strength" in bsdf.inputs:
                    bsdf.inputs["Emission Strength"].default_value = emission_strength
            elif emission_color and "Emission" in bsdf.inputs:
                bsdf.inputs["Emission"].default_value = emission_color
                if "Emission Strength" in bsdf.inputs:
                    bsdf.inputs["Emission Strength"].default_value = emission_strength
        return mat

    mat_madera = get_or_create_material("Madera_Baston", (0.18, 0.09, 0.04, 1.0), metallic=0.0, roughness=0.65)
    mat_oro = get_or_create_material("Oro_Baston", (0.95, 0.72, 0.20, 1.0), metallic=0.95, roughness=0.22)
    mat_cuero = get_or_create_material("Cuero_Baston", (0.07, 0.04, 0.03, 1.0), metallic=0.0, roughness=0.8)
    mat_cristal = get_or_create_material("Cristal_Magico", (0.1, 0.85, 1.0, 1.0), metallic=0.1, roughness=0.1, emission_color=(0.15, 0.85, 1.0, 1.0), emission_strength=5.0)

    # 4. Cuerpo de la vara (Shaft)
    # Cilindro con ligera conicidad
    bpy.ops.mesh.primitive_cylinder_add(radius=0.04, depth=1.8, location=(0, 0, 0.9), vertices=16)
    shaft = bpy.context.active_object
    shaft.name = "Vara_Principal"
    link_obj(shaft)
    shaft.data.materials.append(mat_madera)
    
    # Suavizado de normales
    bpy.ops.object.shade_smooth()

    # 5. Contera inferior (Regatón metálico de la base)
    bpy.ops.mesh.primitive_cone_add(radius1=0.048, radius2=0.01, depth=0.18, location=(0, 0, 0.06), vertices=16)
    ferrule = bpy.context.active_object
    ferrule.name = "Regaton_Base"
    ferrule.rotation_euler[0] = math.pi
    link_obj(ferrule)
    ferrule.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # Anillo inferior decorativo
    bpy.ops.mesh.primitive_torus_add(major_radius=0.05, minor_radius=0.012, location=(0, 0, 0.16), major_segments=24, minor_segments=12)
    ring_bottom = bpy.context.active_object
    ring_bottom.name = "Anillo_Inferior"
    link_obj(ring_bottom)
    ring_bottom.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # 6. Empuñadura central (Grip)
    # Varios anillos de agarre de cuero
    for i in range(7):
        z_pos = 0.75 + i * 0.04
        bpy.ops.mesh.primitive_cylinder_add(radius=0.046, depth=0.032, location=(0, 0, z_pos), vertices=16)
        wrap = bpy.context.active_object
        wrap.name = f"Cuero_Agarre_{i+1}"
        link_obj(wrap)
        wrap.data.materials.append(mat_cuero)
        bpy.ops.object.shade_smooth()

    # Anillos dorados delimitando la empuñadura
    for z_pos in [0.72, 1.04]:
        bpy.ops.mesh.primitive_torus_add(major_radius=0.048, minor_radius=0.009, location=(0, 0, z_pos), major_segments=24, minor_segments=12)
        r = bpy.context.active_object
        r.name = "Anillo_Agarre_Oro"
        link_obj(r)
        r.data.materials.append(mat_oro)
        bpy.ops.object.shade_smooth()

    # 7. Collarín superior (Base de la corona)
    bpy.ops.mesh.primitive_cone_add(radius1=0.042, radius2=0.08, depth=0.12, location=(0, 0, 1.84), vertices=20)
    neck = bpy.context.active_object
    neck.name = "Collarin_Superior"
    link_obj(neck)
    neck.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    bpy.ops.mesh.primitive_torus_add(major_radius=0.082, minor_radius=0.014, location=(0, 0, 1.9), major_segments=24, minor_segments=12)
    neck_ring = bpy.context.active_object
    neck_ring.name = "Anillo_Collarin"
    link_obj(neck_ring)
    neck_ring.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # 8. Garras / Ramas de la corona que sostienen el orbe (4 garras simétricas)
    num_claws = 4
    for idx in range(num_claws):
        angle = (idx / num_claws) * 2 * math.pi
        
        # Segmento inferior de la garra
        rad_out = 0.12
        z_mid = 2.02
        x1 = math.cos(angle) * rad_out
        y1 = math.sin(angle) * rad_out
        
        bpy.ops.mesh.primitive_cylinder_add(radius=0.016, depth=0.22, location=(x1 * 0.7, y1 * 0.7, 1.98), vertices=12)
        claw_base = bpy.context.active_object
        claw_base.name = f"Garra_Base_{idx+1}"
        # Inclinar hacia afuera
        claw_base.rotation_euler[0] = -math.sin(angle) * 0.35
        claw_base.rotation_euler[1] = math.cos(angle) * 0.35
        link_obj(claw_base)
        claw_base.data.materials.append(mat_oro)
        bpy.ops.object.shade_smooth()
        
        # Punta curvada hacia adentro envolviendo el cristal
        x2 = math.cos(angle) * 0.09
        y2 = math.sin(angle) * 0.09
        bpy.ops.mesh.primitive_cone_add(radius1=0.016, radius2=0.003, depth=0.18, location=(x2, y2, 2.16), vertices=12)
        claw_tip = bpy.context.active_object
        claw_tip.name = f"Garra_Punta_{idx+1}"
        claw_tip.rotation_euler[0] = math.sin(angle) * 0.4
        claw_tip.rotation_euler[1] = -math.cos(angle) * 0.4
        link_obj(claw_tip)
        claw_tip.data.materials.append(mat_oro)
        bpy.ops.object.shade_smooth()

    # 9. Gema / Cristal Mágico Flotante en el centro de la corona
    # Cristales facetados (bipirámide o icosaedro alargado)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.09, location=(0, 0, 2.06))
    gem = bpy.context.active_object
    gem.name = "Gema_Cristal_Magico"
    gem.scale = (0.75, 0.75, 1.6) # Alargado estilizado
    link_obj(gem)
    gem.data.materials.append(mat_cristal)
    # Sombreado plano (flat) para que luzca facetado como diamante mágico
    bpy.ops.object.shade_flat()

    # 10. Anillo rúnico flotante / orbital
    bpy.ops.mesh.primitive_torus_add(major_radius=0.15, minor_radius=0.007, location=(0, 0, 2.06), major_segments=32, minor_segments=8)
    orbit_ring = bpy.context.active_object
    orbit_ring.name = "Anillo_Runa_Orbital"
    orbit_ring.rotation_euler = (0.45, 0.35, 0.0) # Inclinado flotante
    link_obj(orbit_ring)
    orbit_ring.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # Segundo anillo orbital en ángulo opuesto
    bpy.ops.mesh.primitive_torus_add(major_radius=0.17, minor_radius=0.006, location=(0, 0, 2.06), major_segments=32, minor_segments=8)
    orbit_ring2 = bpy.context.active_object
    orbit_ring2.name = "Anillo_Runa_Orbital_2"
    orbit_ring2.rotation_euler = (-0.4, 0.5, 0.7)
    link_obj(orbit_ring2)
    orbit_ring2.data.materials.append(mat_oro)
    bpy.ops.object.shade_smooth()

    # 11. Luz mágica puntual dentro del cristal para efecto radiante
    light_data = bpy.data.lights.new(name="Luz_Cristal", type='POINT')
    light_data.color = (0.1, 0.8, 1.0)
    light_data.energy = 50.0 # Watts
    light_obj = bpy.data.objects.new(name="Luz_Cristal_Obj", object_data=light_data)
    light_obj.location = (0, 0, 2.06)
    link_obj(light_obj)

    # 12. Enfocar la vista 3D en el bastón
    for area in bpy.context.screen.areas:
        if area.type == 'VIEW_3D':
            for space in area.spaces:
                if space.type == 'VIEW_3D':
                    space.shading.type = 'MATERIAL' # Activar vista con materiales/colores

    print(">>> Bastón Mágico modelado exitosamente con materiales, gema y corona! <<<")

build_magic_staff()
