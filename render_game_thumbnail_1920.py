"""
render_game_thumbnail_1920.py
Renders the official Roblox Cinematic Thumbnail (1920x1080) for MAGIA ETERNA in Blender 5.3.
Composition:
- Epic Widescreen Cinematic Confrontation (16:9).
- Left Foreground: Archmage Hero unleashing a massive beam of arcane energy from the Godtier Staff.
- Center / Right Background: The Colossal Treant Ancestral (towering wooden colossus with glowing runes)
  and the Eldritch Void God emerging from a dimensional rupture.
- Ancient mystical colosseum floor with glowing runic cracks and fractured monoliths.
- Dramatic rim lighting, volcanic and celestial particles, high-contrast action lighting.
"""

import bpy
import math
import os
import shutil

def clean_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def create_pbr_mat(name, base_color, metallic=0.0, roughness=0.4, emission=None, emission_val=0.0):
    mat = bpy.data.materials.get(name)
    if not mat:
        mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        if "Base Color" in bsdf.inputs:
            bsdf.inputs["Base Color"].default_value = base_color
        if "Metallic" in bsdf.inputs:
            bsdf.inputs["Metallic"].default_value = metallic
        if "Roughness" in bsdf.inputs:
            bsdf.inputs["Roughness"].default_value = roughness
        if emission:
            if "Emission Color" in bsdf.inputs:
                bsdf.inputs["Emission Color"].default_value = emission
                if "Emission Strength" in bsdf.inputs:
                    bsdf.inputs["Emission Strength"].default_value = emission_val
            elif "Emission" in bsdf.inputs:
                bsdf.inputs["Emission"].default_value = emission
                if "Emission Strength" in bsdf.inputs:
                    bsdf.inputs["Emission Strength"].default_value = emission_val
    return mat

def add_smooth_and_bevel(obj, bevel_width=0.04):
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.shade_smooth()
    mod = obj.modifiers.new(name="Bevel", type='BEVEL')
    mod.width = bevel_width
    mod.segments = 2

def build_thumbnail_scene():
    clean_scene()

    # 1. Palette
    m_stone = create_pbr_mat("M_Stone", (0.15, 0.16, 0.20, 1.0), roughness=0.85)
    m_lava_crack = create_pbr_mat("M_Lava_Crack", (1.0, 0.35, 0.05, 1.0), roughness=0.2, emission=(1.0, 0.35, 0.05, 1.0), emission_val=15.0)
    m_cyan_beam = create_pbr_mat("M_Cyan_Beam", (0.1, 0.85, 1.0, 1.0), roughness=0.1, emission=(0.1, 0.85, 1.0, 1.0), emission_val=25.0)
    m_gold = create_pbr_mat("M_Gold", (1.0, 0.82, 0.22, 1.0), metallic=0.9, roughness=0.2)
    m_hero_robe = create_pbr_mat("M_Hero_Robe", (0.10, 0.22, 0.60, 1.0), roughness=0.5)
    m_wood = create_pbr_mat("M_Wood_Boss", (0.28, 0.18, 0.10, 1.0), roughness=0.9)
    m_boss_leaf = create_pbr_mat("M_Boss_Leaf", (0.15, 0.55, 0.20, 1.0), roughness=0.6)
    m_boss_glow = create_pbr_mat("M_Boss_Glow", (0.2, 1.0, 0.4, 1.0), emission=(0.2, 1.0, 0.4, 1.0), emission_val=18.0)
    m_void_black = create_pbr_mat("M_Void_Black", (0.05, 0.03, 0.10, 1.0), roughness=0.7)
    m_void_purple = create_pbr_mat("M_Void_Purple", (0.75, 0.15, 1.0, 1.0), emission=(0.75, 0.15, 1.0, 1.0), emission_val=18.0)

    # 2. Arena Colosseum Floor (Widescreen 40x25)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 5, -0.5))
    floor = bpy.context.active_object
    floor.scale = (40.0, 30.0, 1.0)
    floor.data.materials.append(m_stone)

    # Glowing runic cracks on the arena floor
    for crack_x in [-8.0, -2.0, 4.0, 10.0]:
        bpy.ops.mesh.primitive_plane_add(size=1.0, location=(crack_x, 4.0, 0.02))
        crack = bpy.context.active_object
        crack.scale = (0.2, 18.0, 1.0)
        crack.rotation_euler = (0, 0, math.radians(15))
        crack.data.materials.append(m_lava_crack)

    # Colosseum Ruined Pillars in Background
    for pil_x, pil_y, pil_h in [(-14, 15, 14), (-7, 18, 16), (7, 18, 18), (14, 15, 13)]:
        bpy.ops.mesh.primitive_cylinder_add(radius=1.4, depth=pil_h, location=(pil_x, pil_y, pil_h / 2))
        p = bpy.context.active_object
        p.data.materials.append(m_stone)
        add_smooth_and_bevel(p, 0.08)

    # 3. Foreground Left: Hero Archmage in Dynamic Spellcasting Pose
    hero_pos = (-5.5, -2.0, 0.0)
    
    # Hero Torso
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(hero_pos[0], hero_pos[1], 1.2))
    h_torso = bpy.context.active_object
    h_torso.scale = (1.4, 0.8, 1.5)
    h_torso.rotation_euler = (math.radians(-10), math.radians(20), math.radians(-35))
    h_torso.data.materials.append(m_hero_robe)
    add_smooth_and_bevel(h_torso, 0.05)

    # Hero Head & Face
    bpy.ops.mesh.primitive_cylinder_add(radius=0.5, depth=0.8, location=(hero_pos[0] + 0.1, hero_pos[1] - 0.1, 2.3))
    h_head = bpy.context.active_object
    h_head.data.materials.append(create_pbr_mat("M_Hero_Skin", (0.95, 0.85, 0.75, 1.0)))

    # Glowing Cyan Arcane Eyes on Hero
    for eye_off in [-0.18, 0.18]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.08, location=(hero_pos[0] + 0.1 + eye_off, hero_pos[1] - 0.1 - 0.45, 2.35))
        eye = bpy.context.active_object
        eye.data.materials.append(m_cyan_beam)

    # Hero Hat with Wide Brim & Golden Trim
    bpy.ops.mesh.primitive_cylinder_add(radius=1.2, depth=0.08, location=(hero_pos[0] + 0.1, hero_pos[1] - 0.1, 2.7))
    h_brim = bpy.context.active_object
    h_brim.rotation_euler = (math.radians(-18), math.radians(15), math.radians(-30))
    h_brim.data.materials.append(m_hero_robe)

    bpy.ops.mesh.primitive_cone_add(radius1=0.75, radius2=0.08, depth=1.6, location=(hero_pos[0] + 0.1, hero_pos[1] - 0.1, 3.5))
    h_hat = bpy.context.active_object
    h_hat.rotation_euler = (math.radians(-18), math.radians(15), math.radians(-30))
    h_hat.data.materials.append(m_hero_robe)

    # Hero Staff thrust forward
    staff_pos = (hero_pos[0] + 1.2, hero_pos[1] + 1.2, 2.2)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=3.8, location=staff_pos)
    h_staff = bpy.context.active_object
    h_staff.rotation_euler = (math.radians(65), math.radians(-30), math.radians(45))
    h_staff.data.materials.append(m_gold)

    # Glowing Crystal at Staff Tip
    crystal_pos = (hero_pos[0] + 2.4, hero_pos[1] + 2.6, 2.9)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.45, location=crystal_pos)
    h_cryst = bpy.context.active_object
    h_cryst.data.materials.append(m_cyan_beam)

    # Beam targeted at the Treant boss
    beam_target = (3.5, 12.0, 6.5)
    dx = beam_target[0] - crystal_pos[0]
    dy = beam_target[1] - crystal_pos[1]
    dz = beam_target[2] - crystal_pos[2]
    dist = math.sqrt(dx*dx + dy*dy + dz*dz)
    mid_pos = ((crystal_pos[0] + beam_target[0])/2, (crystal_pos[1] + beam_target[1])/2, (crystal_pos[2] + beam_target[2])/2)

    rot_y = math.atan2(dx, dz)
    rot_x = math.atan2(dy, math.sqrt(dx*dx + dz*dz))

    bpy.ops.mesh.primitive_cylinder_add(radius=0.45, depth=dist, location=mid_pos)
    beam = bpy.context.active_object
    beam.rotation_euler = (math.radians(90) - rot_x, rot_y, 0)
    beam.data.materials.append(m_cyan_beam)

    # Spell Impact Explosion at Boss Torso
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.6, location=beam_target)
    impact = bpy.context.active_object
    impact.data.materials.append(m_cyan_beam)

    l_impact = bpy.data.lights.new(name="ImpactLight", type='POINT')
    l_impact.energy = 800.0
    l_impact.color = (0.2, 0.9, 1.0)
    l_impact_obj = bpy.data.objects.new("ImpactLight", l_impact)
    l_impact_obj.location = beam_target
    bpy.context.collection.objects.link(l_impact_obj)

    # Beam Point Light
    l_beam = bpy.data.lights.new(name="BeamLight", type='POINT')
    l_beam.energy = 500.0
    l_beam.color = (0.2, 0.9, 1.0)
    l_beam_obj = bpy.data.objects.new("BeamLight", l_beam)
    l_beam_obj.location = (crystal_pos[0] + 3.0, crystal_pos[1] + 3.5, 3.5)
    bpy.context.collection.objects.link(l_beam_obj)

    # 4. Background Center/Right: Colossal Bosses
    # Boss 1: Treant Ancestral (Center right, Y=12)
    treant_pos = (3.5, 12.0, 0.0)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(treant_pos[0], treant_pos[1], 5.5))
    treant_torso = bpy.context.active_object
    treant_torso.scale = (5.5, 4.0, 9.0)
    treant_torso.data.materials.append(m_wood)
    add_smooth_and_bevel(treant_torso, 0.2)

    # Treant Head
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(treant_pos[0], treant_pos[1] - 1.2, 11.0))
    treant_head = bpy.context.active_object
    treant_head.scale = (4.0, 3.5, 4.0)
    treant_head.data.materials.append(m_wood)

    # Glowing Emerald Boss Eyes
    for eye_x in [-1.0, 1.0]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.45, location=(treant_pos[0] + eye_x, treant_pos[1] - 2.8, 11.2))
        t_eye = bpy.context.active_object
        t_eye.data.materials.append(m_boss_glow)

    # Treant Antlers / Foliage Canopy
    for foliage_x in [-2.5, 0.0, 2.5]:
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=2.2, location=(treant_pos[0] + foliage_x, treant_pos[1], 14.0))
        t_leaf = bpy.context.active_object
        t_leaf.data.materials.append(m_boss_leaf)

    # Boss 2: Void God Rupture (Far right upper, towering cosmic silhouette)
    void_pos = (11.0, 14.0, 0.0)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=4.5, location=(void_pos[0], void_pos[1], 9.0))
    v_sphere = bpy.context.active_object
    v_sphere.scale = (1.0, 0.8, 1.6)
    v_sphere.data.materials.append(m_void_black)

    # Void God Cosmic Glowing Eye
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1.2, location=(void_pos[0] - 1.5, void_pos[1] - 3.5, 11.0))
    v_eye = bpy.context.active_object
    v_eye.data.materials.append(m_void_purple)

    # Cosmic Tentacles
    for tent_ang in [-40, 20, 60]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.6, depth=14.0, location=(void_pos[0] + math.sin(math.radians(tent_ang))*4, void_pos[1], 9.0))
        tent = bpy.context.active_object
        tent.rotation_euler = (0, math.radians(tent_ang), math.radians(15))
        tent.data.materials.append(m_void_purple)

    # 5. Volumetric & Action Lighting
    # Hero Rim & Action Light
    l_hero = bpy.data.lights.new(name="HeroSpot", type='SPOT')
    l_hero.energy = 800.0
    l_hero.spot_size = math.radians(60)
    l_hero.color = (1.0, 0.9, 0.7)
    l_hero_obj = bpy.data.objects.new("HeroSpot", l_hero)
    l_hero_obj.location = (-10.0, -8.0, 6.0)
    l_hero_obj.rotation_euler = (math.radians(50), math.radians(-35), math.radians(-40))
    bpy.context.collection.objects.link(l_hero_obj)

    # Boss Green/Purple Rim Light (Backlight for monstrous scale)
    l_boss = bpy.data.lights.new(name="BossBacklight", type='AREA')
    l_boss.energy = 1200.0
    l_boss.size = 12.0
    l_boss.color = (0.2, 1.0, 0.5)
    l_boss_obj = bpy.data.objects.new("BossBacklight", l_boss)
    l_boss_obj.location = (4.0, 22.0, 12.0)
    l_boss_obj.rotation_euler = (math.radians(-130), 0, 0)
    bpy.context.collection.objects.link(l_boss_obj)

    # Void Cosmic Light
    l_void = bpy.data.lights.new(name="VoidLight", type='POINT')
    l_void.energy = 800.0
    l_void.color = (0.8, 0.2, 1.0)
    l_void_obj = bpy.data.objects.new("VoidLight", l_void)
    l_void_obj.location = (11.0, 10.0, 11.0)
    bpy.context.collection.objects.link(l_void_obj)

    # 6. Camera (Epic 16:9 Cinematic Widescreen Framing)
    cam_data = bpy.data.cameras.new("ThumbCamera")
    cam_data.lens = 32.0  # Cinematic lens
    cam_obj = bpy.data.objects.new("ThumbCamera", cam_data)
    cam_obj.location = (-6.5, -11.5, 4.8)
    cam_obj.rotation_euler = (math.radians(76), 0, math.radians(-26))
    bpy.context.collection.objects.link(cam_obj)
    bpy.context.scene.camera = cam_obj

    # Main Atmospheric Sun / World Light
    l_sun = bpy.data.lights.new(name="SunAction", type='SUN')
    l_sun.energy = 4.5
    l_sun.color = (1.0, 0.92, 0.82)
    l_sun_obj = bpy.data.objects.new("SunAction", l_sun)
    l_sun_obj.rotation_euler = (math.radians(45), math.radians(25), math.radians(-40))
    bpy.context.collection.objects.link(l_sun_obj)

    # Key Boss Front Illumination
    l_boss_front = bpy.data.lights.new(name="BossFrontLight", type='POINT')
    l_boss_front.energy = 1800.0
    l_boss_front.color = (0.3, 1.0, 0.6)
    l_boss_front_obj = bpy.data.objects.new("BossFrontLight", l_boss_front)
    l_boss_front_obj.location = (3.5, 4.0, 9.0)
    bpy.context.collection.objects.link(l_boss_front_obj)

    # 7. Render Settings (1920x1080 Full HD)
    scene = bpy.context.scene
    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'

    out_path = r"C:\Users\Antonio Garcia\Downloads\blender\game_thumbnail_1920x1080.png"
    scene.render.filepath = out_path

    print("Rendering Official Widescreen Cinematic Thumbnail 1920x1080...")
    bpy.ops.render.render(write_still=True)
    print(f"Thumbnail rendered successfully to {out_path}")

    # Copy to artifacts directory
    artifact_path = r"C:\Users\Antonio Garcia\.gemini\antigravity\brain\a18e1f12-e22f-4dc5-9ee8-acefef11731e\game_thumbnail_1920x1080.png"
    shutil.copyfile(out_path, artifact_path)
    print(f"Copied to artifact directory: {artifact_path}")

if __name__ == "__main__":
    build_thumbnail_scene()
