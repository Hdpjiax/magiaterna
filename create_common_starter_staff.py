import bpy
import math

def create_common_starter_staff():
    col_name = "Baston_Comun_Principal"
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

    # 1. Materiales Básicos Comunes (Rústicos, sin magia avanzada)
    def make_mat(name, base_color, roughness=0.7):
        mat = bpy.data.materials.get(name)
        if not mat:
            mat = bpy.data.materials.new(name=name)
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes.get("Principled BSDF")
        if bsdf:
            if "Base Color" in bsdf.inputs:
                bsdf.inputs["Base Color"].default_value = base_color
            if "Roughness" in bsdf.inputs:
                bsdf.inputs["Roughness"].default_value = roughness
            if "Metallic" in bsdf.inputs:
                bsdf.inputs["Metallic"].default_value = 0.0
        return mat

    mat_madera_comun = make_mat("Comun_Madera_Roble", (0.38, 0.26, 0.16, 1.0), roughness=0.8)
    mat_tela_vendaje = make_mat("Comun_Vendaje_Tela", (0.75, 0.70, 0.58, 1.0), roughness=0.9)
    mat_piedra_cuarzo = make_mat("Comun_Piedra_Opaca", (0.65, 0.68, 0.70, 1.0), roughness=0.5)
    mat_cuerda_rustica = make_mat("Comun_Cuerda_Rustica", (0.35, 0.28, 0.20, 1.0), roughness=0.95)

    # Posición del Bastón Común Principal: X = -2.2, Y = 0.0 (al lado del puesto y del legendario)
    cx_pos = -2.2
    cy_pos = 0.0

    # 2. Base / Pedestal de madera humilde de entrenamiento
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.35, depth=0.06, location=(cx_pos, cy_pos, 0.03))
    base_pad = bpy.context.active_object
    base_pad.name = "Común_Base_Madera"
    link_obj(base_pad)
    base_pad.data.materials.append(mat_madera_comun)
    bpy.ops.object.shade_flat()

    # 3. Vara de madera rústica ligeramente irregular
    # Hecha con un cilindro de 10 vértices para estilo Roblox bajo-medio polígono
    bpy.ops.mesh.primitive_cylinder_add(radius=0.032, depth=1.65, location=(cx_pos, cy_pos, 0.855), vertices=10)
    shaft = bpy.context.active_object
    shaft.name = "Común_Vara_Madera"
    link_obj(shaft)
    shaft.data.materials.append(mat_madera_comun)
    bpy.ops.object.shade_smooth()

    # Base cónica de madera desgastada
    bpy.ops.mesh.primitive_cone_add(radius1=0.034, radius2=0.015, depth=0.10, location=(cx_pos, cy_pos, 0.08), vertices=10)
    tip_bot = bpy.context.active_object
    tip_bot.name = "Común_Punta_Inferior"
    tip_bot.rotation_euler[0] = math.pi
    link_obj(tip_bot)
    tip_bot.data.materials.append(mat_madera_comun)
    bpy.ops.object.shade_flat()

    # 4. Empuñadura con vendajes de tela improvisada
    for i in range(5):
        z_pos = 0.70 + i * 0.045
        bpy.ops.mesh.primitive_cylinder_add(radius=0.038, depth=0.038, location=(cx_pos, cy_pos, z_pos), vertices=10)
        wrap = bpy.context.active_object
        wrap.name = f"Común_Vendaje_{i+1}"
        link_obj(wrap)
        wrap.data.materials.append(mat_tela_vendaje)
        bpy.ops.object.shade_smooth()

    # Amarres de cuerda en los extremos del vendaje
    for z_pos in [0.67, 0.93]:
        bpy.ops.mesh.primitive_torus_add(major_radius=0.038, minor_radius=0.007, location=(cx_pos, cy_pos, z_pos), major_segments=16, minor_segments=6)
        r = bpy.context.active_object
        r.name = "Común_Cuerda_Amarre"
        link_obj(r)
        r.data.materials.append(mat_cuerda_rustica)
        bpy.ops.object.shade_smooth()

    # 5. Cabeza rústica: Horquilla natural de 3 ramas simples de madera
    num_prongs = 3
    for p_idx in range(num_prongs):
        ang = (p_idx / num_prongs) * 2 * math.pi
        px = cx_pos + math.cos(ang) * 0.045
        py = cy_pos + math.sin(ang) * 0.045
        
        bpy.ops.mesh.primitive_cone_add(radius1=0.018, radius2=0.008, depth=0.20, location=(px, py, 1.74), vertices=8)
        prong = bpy.context.active_object
        prong.name = f"Común_Rama_Sujecion_{p_idx+1}"
        prong.rotation_euler = (math.sin(ang) * 0.25, -math.cos(ang) * 0.25, ang)
        link_obj(prong)
        prong.data.materials.append(mat_madera_comun)
        bpy.ops.object.shade_smooth()

    # Cuerda amarrando la base de las ramas
    bpy.ops.mesh.primitive_torus_add(major_radius=0.042, minor_radius=0.010, location=(cx_pos, cy_pos, 1.66), major_segments=16, minor_segments=6)
    prong_rope = bpy.context.active_object
    prong_rope.name = "Común_Cuerda_Cabeza"
    link_obj(prong_rope)
    prong_rope.data.materials.append(mat_cuerda_rustica)
    bpy.ops.object.shade_smooth()

    # 6. Gema / Piedra de Aprendiz (Piedra de río / Cuarzo opaco sin brillo mágico deslumbrante)
    # Una piedra tallada rústica que apenas empieza a canalizar magia básica
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.055, location=(cx_pos, cy_pos, 1.78))
    stone = bpy.context.active_object
    stone.name = "Común_Piedra_Aprendiz"
    stone.scale = (0.9, 0.85, 1.2)
    link_obj(stone)
    stone.data.materials.append(mat_piedra_cuarzo)
    bpy.ops.object.shade_flat()

    # 7. Enfocar la vista para comparar el Común y el Legendario juntos
    bpy.ops.object.select_all(action='DESELECT')
    col_staff = bpy.data.collections.get("Baston_Magico")
    if col_staff:
        for o in col_staff.objects:
            o.select_set(True)
    for o in col.objects:
        o.select_set(True)

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
    print(">>> Bastón Común Principal (Inicial de Aprendiz) modelado con éxito! <<<")

create_common_starter_staff()
