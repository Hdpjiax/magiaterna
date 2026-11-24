import bpy
import math
import os
import shutil

def setup_render():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'

    scene.render.engine = 'BLENDER_EEVEE_NEXT' if hasattr(bpy.types, 'RenderSettings') and 'BLENDER_EEVEE_NEXT' in [e.identifier for e in bpy.types.RenderSettings.bl_rna.properties['engine'].enum_items] else 'CYCLES'
    if scene.render.engine == 'CYCLES':
        scene.cycles.samples = 64
        scene.cycles.use_denoising = True

def get_or_make_mat(name, color, metallic=0.0, roughness=0.5, emission=None, emission_val=0.0, transmission=0.0):
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
        if transmission > 0 and "Transmission Weight" in bsdf.inputs:
            bsdf.inputs["Transmission Weight"].default_value = transmission
        elif transmission > 0 and "Transmission" in bsdf.inputs:
            bsdf.inputs["Transmission"].default_value = transmission
        if emission and "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = emission
            if "Emission Strength" in bsdf.inputs:
                bsdf.inputs["Emission Strength"].default_value = emission_val
        elif emission and "Emission" in bsdf.inputs:
            bsdf.inputs["Emission"].default_value = emission
            if "Emission Strength" in bsdf.inputs:
                bsdf.inputs["Emission Strength"].default_value = emission_val
    return mat

def build_scene():
    setup_render()

    # Materials
    m_floor = get_or_make_mat("M_Colosseum_Floor", (0.08, 0.08, 0.11, 1.0), roughness=0.6)
    m_gold = get_or_make_mat("M_Divine_Gold", (1.0, 0.82, 0.28, 1.0), metallic=0.98, roughness=0.15)
    m_basalt = get_or_make_mat("M_Volcanic_Basalt", (0.05, 0.04, 0.04, 1.0), roughness=0.8)
    m_lava = get_or_make_mat("M_Molten_Lava", (1.0, 0.35, 0.05, 1.0), emission=(1.0, 0.35, 0.05, 1.0), emission_val=6.0)
    m_slime_gel = get_or_make_mat("M_Slime_Gel", (0.2, 0.85, 0.35, 0.8), roughness=0.1, transmission=0.45)
    m_slime_core = get_or_make_mat("M_Slime_Core", (0.4, 1.0, 0.5, 1.0), emission=(0.4, 1.0, 0.5, 1.0), emission_val=8.0)
    m_obsidian = get_or_make_mat("M_Obsidian_Plate", (0.03, 0.02, 0.04, 1.0), metallic=0.6, roughness=0.15)
    m_spectral = get_or_make_mat("M_Spectral_Flame", (0.75, 0.2, 1.0, 1.0), emission=(0.75, 0.2, 1.0, 1.0), emission_val=7.0)
    m_void = get_or_make_mat("M_Dark_Matter", (0.02, 0.01, 0.03, 1.0), roughness=0.2)
    m_void_glow = get_or_make_mat("M_Void_Glow", (1.0, 0.1, 0.55, 1.0), emission=(1.0, 0.1, 0.55, 1.0), emission_val=8.0)

    # 1. Colosseum Floor Dais
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=16.0, depth=0.8, location=(0, 0, -0.4))
    floor = bpy.context.active_object
    floor.data.materials.append(m_floor)
    bpy.ops.object.shade_smooth()

    # Outer Gold Runic Ring
    bpy.ops.mesh.primitive_torus_add(major_radius=15.8, minor_radius=0.12, location=(0, 0, 0.04), major_segments=48, minor_segments=8)
    ring = bpy.context.active_object
    ring.data.materials.append(m_gold)
    bpy.ops.object.shade_smooth()

    # =========================================================================
    # ENEMY 1: SLIME VERDE ÉPICO (X: -6.5, Y: -1.0)
    # =========================================================================
    sx, sy = -6.5, -1.0
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16, radius=1.35, location=(sx, sy, 1.1))
    slime = bpy.context.active_object
    slime.scale = (1.1, 1.1, 0.85)
    slime.data.materials.append(m_slime_gel)
    bpy.ops.object.shade_smooth()

    # Glowing inner core
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.45, location=(sx, sy, 0.9))
    score = bpy.context.active_object
    score.data.materials.append(m_slime_core)
    bpy.ops.object.shade_flat()

    # Cute cartoon eyes
    for e_side in [-0.35, 0.35]:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=0.18, location=(sx + e_side, sy - 1.15, 1.25))
        eye = bpy.context.active_object
        eye.scale = (1.0, 0.5, 1.4)
        eye.data.materials.append(m_basalt)
        bpy.ops.object.shade_smooth()

    # Sprout leaf on top
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.2, radius2=0, depth=0.6, location=(sx, sy, 2.3))
    sprout = bpy.context.active_object
    sprout.rotation_euler = (0, 0.4, 0.3)
    sprout.data.materials.append(m_slime_core)
    bpy.ops.object.shade_flat()

    # =========================================================================
    # ENEMY 2: GÓLEM ÍGNEO DE MAGMA (X: -3.4, Y: 0.5)
    # =========================================================================
    gx, gy = -3.4, 0.5
    # Massive volcanic torso
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(gx, gy, 2.2))
    gtorso = bpy.context.active_object
    gtorso.scale = (2.2, 1.6, 2.0)
    gtorso.data.materials.append(m_basalt)
    bpy.ops.object.shade_smooth()

    # Glowing magma core chest crack
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.55, depth=0.3, location=(gx, gy - 0.75, 2.4))
    gcore = bpy.context.active_object
    gcore.rotation_euler = (math.radians(90), 0, 0)
    gcore.data.materials.append(m_lava)
    bpy.ops.object.shade_flat()

    # Massive boulder shoulders
    for b_side in [-1.5, 1.5]:
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.9, location=(gx + b_side, gy, 3.0))
        sh = bpy.context.active_object
        sh.data.materials.append(m_basalt)
        bpy.ops.object.shade_flat()

        # Heavy fists
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(gx + b_side * 1.25, gy - 0.6, 1.2))
        fist = bpy.context.active_object
        fist.scale = (0.9, 1.1, 0.9)
        fist.data.materials.append(m_basalt)
        bpy.ops.object.shade_flat()

    # Head with blazing eyes
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(gx, gy - 0.3, 3.4))
    ghead = bpy.context.active_object
    ghead.scale = (1.1, 1.0, 0.8)
    ghead.data.materials.append(m_basalt)
    bpy.ops.object.shade_flat()

    # Magma visor slit
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(gx, gy - 0.82, 3.4))
    gslit = bpy.context.active_object
    gslit.scale = (0.7, 0.1, 0.15)
    gslit.data.materials.append(m_lava)
    bpy.ops.object.shade_flat()

    # =========================================================================
    # ENEMY 3 (BOSS SUPREMO): ARCÁNGEL DEL CAOS (X: 0.0, Y: 1.2) - CENTERPIECE
    # =========================================================================
    ax, ay = 0.0, 1.2
    # Majestic Body
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(ax, ay, 2.8))
    atorso = bpy.context.active_object
    atorso.scale = (1.8, 1.2, 2.4)
    atorso.data.materials.append(m_gold)
    bpy.ops.object.shade_smooth()

    # Head
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=0.65, location=(ax, ay, 4.4))
    ahead = bpy.context.active_object
    ahead.data.materials.append(m_gold)
    bpy.ops.object.shade_smooth()

    # Radiant Solar Halo
    bpy.ops.mesh.primitive_torus_add(major_radius=1.2, minor_radius=0.08, location=(ax, ay, 5.3), major_segments=32, minor_segments=8)
    ahalo = bpy.context.active_object
    ahalo.data.materials.append(m_gold)
    bpy.ops.object.shade_smooth()

    # 4 Colossal Divine Wings
    for w_idx, (w_x, w_z, w_ang, w_len) in enumerate([
        (-2.6, 4.0, 35, 4.2),
        (2.6, 4.0, -35, 4.2),
        (-2.2, 2.2, 15, 3.2),
        (2.2, 2.2, -15, 3.2),
    ]):
        bpy.ops.mesh.primitive_cylinder_add(radius=0.25, depth=w_len, location=(ax + w_x, ay + 0.4, w_z), vertices=8)
        wing = bpy.context.active_object
        wing.scale = (0.2, 1.2, 0.8)
        wing.rotation_euler = (0, 0, math.radians(w_ang))
        wing.data.materials.append(m_gold)
        bpy.ops.object.shade_smooth()

    # Solar Sword of Chaos (held in right hand)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(ax + 1.8, ay - 0.4, 2.8))
    sword = bpy.context.active_object
    sword.scale = (0.12, 0.35, 4.6)
    sword.rotation_euler = (math.radians(-15), 0, math.radians(-10))
    sword_mat = get_or_make_mat("M_SunBlade", (1.0, 0.95, 0.4, 1.0), emission=(1.0, 0.92, 0.45, 1.0), emission_val=12.0)
    sword.data.materials.append(sword_mat)
    bpy.ops.object.shade_flat()

    # =========================================================================
    # ENEMY 4: REY DE LAS ALMAS (X: 3.4, Y: 0.2)
    # =========================================================================
    kx, ky = 3.4, 0.2
    # Obsidian Robed Torso
    bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=1.4, radius2=0.6, depth=2.8, location=(kx, ky, 1.8))
    ktors = bpy.context.active_object
    ktors.data.materials.append(m_obsidian)
    bpy.ops.object.shade_smooth()

    # Hooded Lich Head
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=0.65, location=(kx, ky, 3.6))
    khead = bpy.context.active_object
    khead.data.materials.append(m_obsidian)
    bpy.ops.object.shade_smooth()

    # Crown of Spectral Horns / Spikes
    for s_i in range(5):
        s_ang = (s_i - 2) * 0.45
        sx_c = kx + math.sin(s_ang) * 0.65
        sy_c = ky - 0.1
        sz_c = 4.2 + math.cos(s_ang) * 0.2
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.12, radius2=0, depth=0.7, location=(sx_c, sy_c, sz_c))
        spk = bpy.context.active_object
        spk.rotation_euler = (0, -s_ang * 0.8, 0)
        spk.data.materials.append(m_spectral)
        bpy.ops.object.shade_flat()

    # Glowing Soul Eye Slits
    for eye_s in [-0.22, 0.22]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(kx + eye_s, ky - 0.62, 3.65))
        seye = bpy.context.active_object
        seye.scale = (0.16, 0.08, 0.1)
        seye.data.materials.append(m_spectral)
        bpy.ops.object.shade_flat()

    # Death Scythe / Staff
    bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=4.2, location=(kx + 1.4, ky, 2.4), vertices=8)
    scy = bpy.context.active_object
    scy.data.materials.append(m_obsidian)
    bpy.ops.object.shade_smooth()

    # Scythe Crescent Blade
    bpy.ops.mesh.primitive_torus_add(major_radius=0.9, minor_radius=0.08, location=(kx + 1.9, ky, 4.2), major_segments=16, minor_segments=6)
    scy_b = bpy.context.active_object
    scy_b.scale = (1.0, 0.3, 1.2)
    scy_b.data.materials.append(m_spectral)
    bpy.ops.object.shade_flat()

    # =========================================================================
    # ENEMY 5: DIOS DEL VACÍO / DEVORADOR CÓSMICO (X: 6.8, Y: -0.8)
    # =========================================================================
    vx, vy = 6.8, -0.8
    # Dark Matter Core
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.6, location=(vx, vy, 2.2))
    vbody = bpy.context.active_object
    vbody.scale = (1.1, 0.9, 1.4)
    vbody.data.materials.append(m_void)
    bpy.ops.object.shade_flat()

    # Giant Cosmic Singularity Eye (Center of Body)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=12, radius=0.65, location=(vx, vy - 0.9, 2.3))
    veye = bpy.context.active_object
    veye.scale = (1.0, 0.4, 1.2)
    veye.data.materials.append(m_void_glow)
    bpy.ops.object.shade_smooth()

    # Cosmic Horns
    for h_side in [-1.0, 1.0]:
        bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.25, radius2=0.02, depth=2.0, location=(vx + h_side * 1.1, vy, 3.8))
        vhorn = bpy.context.active_object
        vhorn.rotation_euler = (0, h_side * 0.45, 0)
        vhorn.data.materials.append(m_void_glow)
        bpy.ops.object.shade_flat()

    # 4 Void Tentacles / Rifts
    for t_i in range(4):
        t_ang = t_i * (math.pi / 2) + 0.4
        tx = vx + math.cos(t_ang) * 1.8
        ty = vy + math.sin(t_ang) * 1.8
        bpy.ops.mesh.primitive_cylinder_add(radius=0.18, depth=2.2, location=(tx, ty, 1.2), vertices=8)
        tent = bpy.context.active_object
        tent.rotation_euler = (math.sin(t_ang) * 0.6, -math.cos(t_ang) * 0.6, t_ang)
        tent.data.materials.append(m_void_glow)
        bpy.ops.object.shade_smooth()

    # Studio Lighting Setup
    # Key Area Light (Warm Gold from high front-left)
    k_data = bpy.data.lights.new(name="Key_Light", type='AREA')
    k_data.energy = 1100.0
    k_data.size = 14.0
    k_data.color = (1.0, 0.96, 0.88)
    k_obj = bpy.data.objects.new(name="Key_Light_Obj", object_data=k_data)
    bpy.context.collection.objects.link(k_obj)
    k_obj.location = (-4.0, -9.0, 8.0)
    k_obj.rotation_euler = (math.radians(48), math.radians(-15), 0)

    # Fill Area Light (Ethereal Cyan/Violet from right)
    f_data = bpy.data.lights.new(name="Fill_Light", type='AREA')
    f_data.energy = 550.0
    f_data.size = 16.0
    f_data.color = (0.5, 0.75, 1.0)
    f_obj = bpy.data.objects.new(name="Fill_Light_Obj", object_data=f_data)
    bpy.context.collection.objects.link(f_obj)
    f_obj.location = (5.0, -8.0, 6.0)
    f_obj.rotation_euler = (math.radians(45), math.radians(20), 0)

    # Golden Rim Backlight (Intense silhouette separation)
    r_data = bpy.data.lights.new(name="Rim_Light", type='AREA')
    r_data.energy = 1600.0
    r_data.size = 20.0
    r_data.color = (1.0, 0.85, 0.5)
    r_obj = bpy.data.objects.new(name="Rim_Light_Obj", object_data=r_data)
    bpy.context.collection.objects.link(r_obj)
    r_obj.location = (0, 7.5, 6.5)
    r_obj.rotation_euler = (math.radians(-45), 0, math.radians(180))

    # Camera
    cam_data = bpy.data.cameras.new("MainCamera")
    cam_data.lens = 45
    cam_obj = bpy.data.objects.new("MainCameraObj", cam_data)
    bpy.context.collection.objects.link(cam_obj)
    cam_obj.location = (0, -12.5, 3.8)
    cam_obj.rotation_euler = (math.radians(80), 0, 0)
    bpy.context.scene.camera = cam_obj

    # Save .blend
    bpy.ops.wm.save_as_mainfile(filepath=r"c:\Users\Antonio Garcia\Downloads\blender\Enemigos_Epicos_Showcase_3D.blend")

    # Render Image
    output_path = r"c:\Users\Antonio Garcia\Downloads\blender\render_enemigos_epicos_3d.png"
    bpy.context.scene.render.filepath = output_path
    print(f"Rendering to: {output_path}")
    bpy.ops.render.render(write_still=True)
    print("Render complete!")

    # Copy to artifacts directory
    artifact_dir = r"C:\Users\Antonio Garcia\.gemini\antigravity\brain\a18e1f12-e22f-4dc5-9ee8-acefef11731e"
    if os.path.exists(artifact_dir):
        dest = os.path.join(artifact_dir, "render_enemigos_epicos_3d.png")
        shutil.copyfile(output_path, dest)
        print(f"Copied to artifact: {dest}")

if __name__ == '__main__':
    build_scene()
