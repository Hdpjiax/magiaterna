"""
render_game_icon_512.py
Deluxe AAA Official Game Icon (512x512) for MAGIA ETERNA in Blender 5.3.
Composition:
- Epic Archmage (Roblox blocky proportions, wizard hat with golden star buckle, silver hair, glowing cyan arcane eyes).
- Right hand wielding the Godtier Celestial Staff with glowing radiant crystal orb & golden winged crown, perfectly framed.
- Left hand channeling an arcane runic circle with swirling golden-cyan magic runes.
- Floating elemental orbs (Fire, Frost, Void, Celestial).
- Atmospheric background with glowing celestial runes and deep vignette.
- 3-point lighting + intense golden rim light.
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

def add_smooth_and_bevel(obj, bevel_width=0.03):
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.shade_smooth()
    mod = obj.modifiers.new(name="Bevel", type='BEVEL')
    mod.width = bevel_width
    mod.segments = 2

def build_icon_scene():
    clean_scene()

    # 1. Palette
    m_robe_dark = create_pbr_mat("M_Robe_Dark", (0.07, 0.09, 0.22, 1.0), roughness=0.55)
    m_robe_royal = create_pbr_mat("M_Robe_Royal", (0.12, 0.25, 0.65, 1.0), roughness=0.4)
    m_gold_shiny = create_pbr_mat("M_Gold_Shiny", (1.0, 0.82, 0.22, 1.0), metallic=0.92, roughness=0.18)
    m_silver_hair = create_pbr_mat("M_Silver_Hair", (0.92, 0.94, 0.98, 1.0), roughness=0.35)
    m_skin = create_pbr_mat("M_Skin", (0.95, 0.82, 0.74, 1.0), roughness=0.5)
    m_cyan_glow = create_pbr_mat("M_Cyan_Glow", (0.15, 0.9, 1.0, 1.0), roughness=0.1, emission=(0.15, 0.9, 1.0, 1.0), emission_val=16.0)
    m_gold_glow = create_pbr_mat("M_Gold_Glow", (1.0, 0.85, 0.3, 1.0), roughness=0.1, emission=(1.0, 0.85, 0.3, 1.0), emission_val=12.0)
    m_fire_glow = create_pbr_mat("M_Fire_Glow", (1.0, 0.45, 0.08, 1.0), roughness=0.1, emission=(1.0, 0.45, 0.08, 1.0), emission_val=14.0)
    m_purple_glow = create_pbr_mat("M_Purple_Glow", (0.75, 0.2, 1.0, 1.0), roughness=0.1, emission=(0.75, 0.2, 1.0, 1.0), emission_val=12.0)
    m_bg = create_pbr_mat("M_Background", (0.02, 0.03, 0.09, 1.0), roughness=0.8)

    # 2. Archmage Character (Classic Roblox Proportions with high polish)
    # Torso (Dark royal robe with golden center trim)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.8))
    torso = bpy.context.active_object
    torso.scale = (1.4, 0.8, 1.4)
    torso.data.materials.append(m_robe_royal)
    add_smooth_and_bevel(torso, 0.05)

    # Golden Chest Emblem / Trim
    bpy.ops.mesh.primitive_cylinder_add(radius=0.25, depth=0.08, location=(0, -0.42, 1.0))
    emblem = bpy.context.active_object
    emblem.rotation_euler = (math.radians(90), 0, 0)
    emblem.data.materials.append(m_gold_shiny)

    # Head (Roblox Classic Head)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.52, depth=0.85, location=(0, 0, 1.85))
    head = bpy.context.active_object
    head.data.materials.append(m_skin)
    add_smooth_and_bevel(head, 0.12)

    # Flowing White/Silver Mage Hair
    for hair_x, hair_rot in [(-0.48, 12), (0.48, -12), (-0.3, 5), (0.3, -5)]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(hair_x, 0.05, 1.8))
        lock = bpy.context.active_object
        lock.scale = (0.22, 0.45, 0.85)
        lock.rotation_euler = (0, 0, math.radians(hair_rot))
        lock.data.materials.append(m_silver_hair)
        add_smooth_and_bevel(lock, 0.04)

    # Glowing Cyan Arcane Eyes
    for eye_x in [-0.2, 0.2]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.09, location=(eye_x, -0.48, 1.9))
        eye = bpy.context.active_object
        eye.scale = (1.2, 0.5, 0.8)
        eye.data.materials.append(m_cyan_glow)

    # Wizard Hat
    # 1. Hat Brim (Curved wide brim)
    bpy.ops.mesh.primitive_cylinder_add(radius=1.2, depth=0.08, location=(0, -0.05, 2.3))
    brim = bpy.context.active_object
    brim.rotation_euler = (math.radians(-8), math.radians(4), 0)
    brim.data.materials.append(m_robe_dark)
    add_smooth_and_bevel(brim, 0.03)

    # 2. Hat Band (Golden buckle)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.72, depth=0.2, location=(0, -0.04, 2.45))
    band = bpy.context.active_object
    band.rotation_euler = (math.radians(-8), math.radians(4), 0)
    band.data.materials.append(m_gold_shiny)

    # 3. Hat Cone (Pointed with stylish crook)
    bpy.ops.mesh.primitive_cone_add(radius1=0.7, radius2=0.08, depth=1.4, location=(0, 0.05, 3.1))
    cone = bpy.context.active_object
    cone.rotation_euler = (math.radians(-16), math.radians(8), 0)
    cone.data.materials.append(m_robe_dark)
    add_smooth_and_bevel(cone, 0.04)

    # 4. Golden Star at Tip of Hat
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.15, location=(0.15, 0.35, 3.75))
    star = bpy.context.active_object
    star.data.materials.append(m_gold_glow)

    # Right Arm & Hand holding Godtier Staff
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.95, -0.15, 0.95))
    r_arm = bpy.context.active_object
    r_arm.scale = (0.55, 0.6, 1.25)
    r_arm.rotation_euler = (math.radians(-25), math.radians(-12), math.radians(15))
    r_arm.data.materials.append(m_robe_royal)
    add_smooth_and_bevel(r_arm, 0.05)

    # 3. The Godtier Staff (Prominently Framed in Upper-Right)
    # Shaft
    bpy.ops.mesh.primitive_cylinder_add(radius=0.06, depth=3.0, location=(0.75, -0.55, 1.5))
    staff = bpy.context.active_object
    staff.rotation_euler = (math.radians(15), math.radians(-18), math.radians(8))
    staff.data.materials.append(m_gold_shiny)

    # Crown Wings (Angelic curved wings holding the crystal)
    for wing_side, ang in [(-0.25, -25), (0.25, 25)]:
        bpy.ops.mesh.primitive_torus_add(major_radius=0.28, minor_radius=0.05, location=(0.95 + wing_side, -0.68, 2.7))
        w = bpy.context.active_object
        w.rotation_euler = (0, math.radians(ang), 0)
        w.data.materials.append(m_gold_shiny)

    # Glowing Prismatic Celestial Crystal (Top of Staff)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.32, location=(0.95, -0.68, 2.75))
    crystal = bpy.context.active_object
    crystal.data.materials.append(m_cyan_glow)

    # Point light inside crystal
    l_cryst_data = bpy.data.lights.new(name="CrystalLight", type='POINT')
    l_cryst_data.energy = 90.0
    l_cryst_data.color = (0.2, 0.9, 1.0)
    l_cryst = bpy.data.objects.new("CrystalLight", l_cryst_data)
    l_cryst.location = (0.95, -0.68, 2.75)
    bpy.context.collection.objects.link(l_cryst)

    # 4. Left Hand Channeling Arcane Spell Rune
    # Left Arm
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-0.95, -0.2, 0.9))
    l_arm = bpy.context.active_object
    l_arm.scale = (0.55, 0.6, 1.25)
    l_arm.rotation_euler = (math.radians(-35), math.radians(20), math.radians(-10))
    l_arm.data.materials.append(m_robe_royal)
    add_smooth_and_bevel(l_arm, 0.05)

    # Concentric Magic Rings (Spell Casting Glyph)
    bpy.ops.mesh.primitive_torus_add(major_radius=0.55, minor_radius=0.03, location=(-0.85, -0.7, 1.35))
    ring_outer = bpy.context.active_object
    ring_outer.rotation_euler = (math.radians(70), math.radians(-15), math.radians(10))
    ring_outer.data.materials.append(m_gold_glow)

    bpy.ops.mesh.primitive_torus_add(major_radius=0.35, minor_radius=0.025, location=(-0.85, -0.7, 1.35))
    ring_inner = bpy.context.active_object
    ring_inner.rotation_euler = (math.radians(70), math.radians(-15), math.radians(10))
    ring_inner.data.materials.append(m_cyan_glow)

    # Magic Spell Light from hand
    l_spell_data = bpy.data.lights.new(name="SpellLight", type='POINT')
    l_spell_data.energy = 60.0
    l_spell_data.color = (1.0, 0.85, 0.3)
    l_spell = bpy.data.objects.new("SpellLight", l_spell_data)
    l_spell.location = (-0.85, -0.7, 1.35)
    bpy.context.collection.objects.link(l_spell)

    # 5. Floating Elemental Orbs
    elemental_orbs = [
        ((-1.1, -0.1, 2.4), m_fire_glow, (1.0, 0.45, 0.08)),
        ((-0.6, 0.3, 3.2), m_purple_glow, (0.8, 0.2, 1.0)),
        ((1.1, 0.1, 1.9), m_cyan_glow, (0.15, 0.9, 1.0)),
    ]
    for pos, mat, col in elemental_orbs:
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.14, location=pos)
        orb = bpy.context.active_object
        orb.data.materials.append(mat)
        
        o_light_data = bpy.data.lights.new(name="OrbL", type='POINT')
        o_light_data.energy = 25.0
        o_light_data.color = col
        o_light = bpy.data.objects.new("OrbL", o_light_data)
        o_light.location = pos
        bpy.context.collection.objects.link(o_light)

    # 6. Mystic Background Portal Arch
    bpy.ops.mesh.primitive_plane_add(size=10.0, location=(0, 2.5, 2.0))
    bg_plane = bpy.context.active_object
    bg_plane.rotation_euler = (math.radians(90), 0, 0)
    bg_plane.data.materials.append(m_bg)

    # Big Halo Arch behind wizard
    bpy.ops.mesh.primitive_torus_add(major_radius=2.2, minor_radius=0.08, location=(0, 1.2, 2.2))
    bg_arch = bpy.context.active_object
    bg_arch.rotation_euler = (math.radians(90), 0, 0)
    bg_arch.data.materials.append(m_gold_glow)

    # 7. Cinematic 3-Point Lighting
    # Key Light (Warm Sunlight)
    key_data = bpy.data.lights.new(name="Key_Light", type='AREA')
    key_data.energy = 400.0
    key_data.size = 2.5
    key_data.color = (1.0, 0.94, 0.85)
    key_obj = bpy.data.objects.new("Key_Light", key_data)
    key_obj.location = (-2.0, -3.2, 3.2)
    key_obj.rotation_euler = (math.radians(45), math.radians(-20), math.radians(-30))
    bpy.context.collection.objects.link(key_obj)

    # Fill Light (Cool Sky Blue)
    fill_data = bpy.data.lights.new(name="Fill_Light", type='AREA')
    fill_data.energy = 160.0
    fill_data.size = 3.5
    fill_data.color = (0.55, 0.75, 1.0)
    fill_obj = bpy.data.objects.new("Fill_Light", fill_data)
    fill_obj.location = (2.8, -2.5, 1.8)
    fill_obj.rotation_euler = (math.radians(30), math.radians(35), math.radians(15))
    bpy.context.collection.objects.link(fill_obj)

    # Intense Gold Rim Light (Creates razor-sharp silhouette contrast)
    rim_data = bpy.data.lights.new(name="Rim_Light", type='SPOT')
    rim_data.energy = 750.0
    rim_data.spot_size = math.radians(65)
    rim_data.color = (1.0, 0.88, 0.45)
    rim_obj = bpy.data.objects.new("Rim_Light", rim_data)
    rim_obj.location = (0, 1.8, 4.2)
    rim_obj.rotation_euler = (math.radians(-145), 0, 0)
    bpy.context.collection.objects.link(rim_obj)

    # 8. Camera (Framing Hero, Hat and Staff perfectly)
    cam_data = bpy.data.cameras.new("IconCamera")
    cam_data.lens = 40.0
    cam_obj = bpy.data.objects.new("IconCamera", cam_data)
    cam_obj.location = (0.0, -4.4, 2.05)
    cam_obj.rotation_euler = (math.radians(88), 0, 0)
    bpy.context.collection.objects.link(cam_obj)
    bpy.context.scene.camera = cam_obj

    # 9. Render Config
    scene = bpy.context.scene
    scene.render.resolution_x = 512
    scene.render.resolution_y = 512
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'

    out_path = r"C:\Users\Antonio Garcia\Downloads\blender\game_icon_512.png"
    scene.render.filepath = out_path

    print("Rendering Deluxe Game Icon 512x512...")
    bpy.ops.render.render(write_still=True)
    print(f"Deluxe Game Icon rendered to {out_path}")

    # Copy to artifacts directory
    artifact_path = r"C:\Users\Antonio Garcia\.gemini\antigravity\brain\a18e1f12-e22f-4dc5-9ee8-acefef11731e\game_icon_512.png"
    shutil.copyfile(out_path, artifact_path)
    print(f"Copied to artifact: {artifact_path}")

if __name__ == "__main__":
    build_icon_scene()
