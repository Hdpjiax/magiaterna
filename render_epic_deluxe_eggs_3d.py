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

    # Use EEVEE_NEXT or CYCLES
    scene.render.engine = 'BLENDER_EEVEE_NEXT' if hasattr(bpy.types, 'RenderSettings') and 'BLENDER_EEVEE_NEXT' in [e.identifier for e in bpy.types.RenderSettings.bl_rna.properties['engine'].enum_items] else 'CYCLES'
    if scene.render.engine == 'CYCLES':
        scene.cycles.samples = 64
        scene.cycles.use_denoising = True

def get_or_make_mat(name, color, metallic=0.0, roughness=0.5, emission=None, emission_val=0.0, alpha=1.0):
    mat = bpy.data.materials.get(name)
    if not mat:
        mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
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

def create_ovoid_egg(name, x, y, z, base_mat, shell_color, emission_color, emission_strength=4.0):
    # Base Bulb (wide lower sphere)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16, radius=0.9, location=(x, y, z + 0.8))
    base = bpy.context.active_object
    base.name = f"{name}_Base"
    base.scale = (1.0, 1.0, 1.15)
    base.data.materials.append(base_mat)
    bpy.ops.object.shade_smooth()

    # Top Apex (tapered upper sphere)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16, radius=0.75, location=(x, y, z + 1.45))
    top = bpy.context.active_object
    top.name = f"{name}_Top"
    top.scale = (0.9, 0.9, 1.35)
    top.data.materials.append(base_mat)
    bpy.ops.object.shade_smooth()

    # Glowing Core Gem / Egg Crack
    gem_mat = get_or_make_mat(f"{name}_CoreMat", shell_color, metallic=0.2, roughness=0.1, emission=emission_color, emission_val=emission_strength)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.45, location=(x, y - 0.45, z + 1.15))
    gem = bpy.context.active_object
    gem.name = f"{name}_CoreGem"
    gem.data.materials.append(gem_mat)
    bpy.ops.object.shade_flat()

    return base, top, gem

def build_scene():
    setup_render()

    # Materials
    m_gold = get_or_make_mat("M_Gold", (1.0, 0.82, 0.25, 1.0), metallic=0.95, roughness=0.18)
    m_dark_pedestal = get_or_make_mat("M_Pedestal", (0.05, 0.05, 0.08, 1.0), metallic=0.3, roughness=0.3)
    m_straw_nest = get_or_make_mat("M_StrawNest", (0.55, 0.38, 0.20, 1.0), roughness=0.85)

    # 1. Grand Curved Display Pedestal Table
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, -0.4))
    ped = bpy.context.active_object
    ped.scale = (16.0, 3.5, 0.8)
    ped.data.materials.append(m_dark_pedestal)
    bpy.ops.object.shade_smooth()

    # Golden runner trim
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.02))
    trim = bpy.context.active_object
    trim.scale = (16.2, 3.6, 0.08)
    trim.data.materials.append(m_gold)
    bpy.ops.object.shade_smooth()

    # The 6 Regional Eggs Data
    eggs_data = [
        {
            "name": "Egg_Bosque", "x": -5.5,
            "shell_col": (0.2, 0.75, 0.35, 1.0),
            "emiss_col": (0.3, 1.0, 0.45, 1.0),
            "accent": "LeafCrown"
        },
        {
            "name": "Egg_Volcanico", "x": -3.3,
            "shell_col": (0.15, 0.08, 0.08, 1.0),
            "emiss_col": (1.0, 0.35, 0.05, 1.0),
            "accent": "MagmaHorns"
        },
        {
            "name": "Egg_Glacial", "x": -1.1,
            "shell_col": (0.35, 0.85, 1.0, 1.0),
            "emiss_col": (0.4, 0.95, 1.0, 1.0),
            "accent": "IceSpikes"
        },
        {
            "name": "Egg_Espectral", "x": 1.1,
            "shell_col": (0.12, 0.08, 0.18, 1.0),
            "emiss_col": (0.75, 0.25, 1.0, 1.0),
            "accent": "SoulCrown"
        },
        {
            "name": "Egg_Celestial", "x": 3.3,
            "shell_col": (0.95, 0.92, 0.85, 1.0),
            "emiss_col": (1.0, 0.88, 0.3, 1.0),
            "accent": "AngelWings"
        },
        {
            "name": "Egg_Abismo", "x": 5.5,
            "shell_col": (0.05, 0.02, 0.08, 1.0),
            "emiss_col": (1.0, 0.15, 0.55, 1.0),
            "accent": "VoidRings"
        },
    ]

    for ed in eggs_data:
        x = ed["x"]
        shell_mat = get_or_make_mat(f"{ed['name']}_Shell", ed["shell_col"], metallic=0.15, roughness=0.25)

        # Woven nest under egg
        bpy.ops.mesh.primitive_torus_add(major_radius=1.1, minor_radius=0.22, location=(x, 0, 0.22), major_segments=24, minor_segments=8)
        nest = bpy.context.active_object
        nest.data.materials.append(m_straw_nest)
        bpy.ops.object.shade_smooth()

        # Filigree gold ring
        bpy.ops.mesh.primitive_torus_add(major_radius=0.96, minor_radius=0.04, location=(x, 0, 1.15), major_segments=24, minor_segments=6)
        gold_ring = bpy.context.active_object
        gold_ring.data.materials.append(m_gold)
        bpy.ops.object.shade_smooth()

        # Build Egg
        b, t, g = create_ovoid_egg(ed["name"], x, 0, 0, shell_mat, ed["shell_col"], ed["emiss_col"])

        # Accents
        if ed["accent"] == "AngelWings":
            # Golden Angelic Wings cradling the egg
            for side in [-1, 1]:
                bpy.ops.mesh.primitive_cylinder_add(radius=0.15, depth=1.6, location=(x + side * 0.95, 0.1, 1.3), vertices=8)
                w = bpy.context.active_object
                w.scale = (0.3, 1.2, 0.8)
                w.rotation_euler = (0, side * 0.45, 0)
                w.data.materials.append(m_gold)
                bpy.ops.object.shade_smooth()
        elif ed["accent"] == "VoidRings":
            # Orbiting cosmic rings
            bpy.ops.mesh.primitive_torus_add(major_radius=1.45, minor_radius=0.035, location=(x, 0, 1.3), major_segments=28, minor_segments=6)
            vr = bpy.context.active_object
            vr.rotation_euler = (0.5, 0.3, 0.8)
            emiss_mat = get_or_make_mat("M_VoidRingEmiss", ed["emiss_col"], emission=ed["emiss_col"], emission_val=6.0)
            vr.data.materials.append(emiss_mat)
            bpy.ops.object.shade_smooth()

        # Top Crystal Star
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.15, radius2=0, depth=0.45, location=(x, 0, 2.5))
        finial = bpy.context.active_object
        finial.data.materials.append(m_gold)
        bpy.ops.object.shade_flat()

        # Point Light on each egg
        light_data = bpy.data.lights.new(name=f"{ed['name']}_Light", type='POINT')
        light_data.energy = 180.0
        light_data.color = (ed["emiss_col"][0], ed["emiss_col"][1], ed["emiss_col"][2])
        light_obj = bpy.data.objects.new(name=f"{ed['name']}_LightObj", object_data=light_data)
        bpy.context.collection.objects.link(light_obj)
        light_obj.location = (x, -0.6, 1.4)

    # Studio Lighting Setup
    # Key Light (warm high front)
    key_data = bpy.data.lights.new(name="Key_Light", type='AREA')
    key_data.energy = 850.0
    key_data.size = 12.0
    key_data.color = (1.0, 0.95, 0.85)
    key_obj = bpy.data.objects.new(name="Key_Light_Obj", object_data=key_data)
    bpy.context.collection.objects.link(key_obj)
    key_obj.location = (0, -7.5, 6.0)
    key_obj.rotation_euler = (math.radians(50), 0, 0)

    # Fill Light (soft blue/violet from top)
    fill_data = bpy.data.lights.new(name="Fill_Light", type='AREA')
    fill_data.energy = 400.0
    fill_data.size = 14.0
    fill_data.color = (0.55, 0.7, 1.0)
    fill_obj = bpy.data.objects.new(name="Fill_Light_Obj", object_data=fill_data)
    bpy.context.collection.objects.link(fill_obj)
    fill_obj.location = (0, -4.0, 8.5)
    fill_obj.rotation_euler = (math.radians(30), 0, 0)

    # Rim / Backlight (intense golden rim for crisp silhouettes)
    rim_data = bpy.data.lights.new(name="Rim_Light", type='AREA')
    rim_data.energy = 1200.0
    rim_data.size = 18.0
    rim_data.color = (1.0, 0.88, 0.5)
    rim_obj = bpy.data.objects.new(name="Rim_Light_Obj", object_data=rim_data)
    bpy.context.collection.objects.link(rim_obj)
    rim_obj.location = (0, 6.0, 5.0)
    rim_obj.rotation_euler = (math.radians(-40), 0, math.radians(180))

    # Camera
    cam_data = bpy.data.cameras.new("MainCamera")
    cam_data.lens = 42
    cam_obj = bpy.data.objects.new("MainCameraObj", cam_data)
    bpy.context.collection.objects.link(cam_obj)
    cam_obj.location = (0, -9.6, 2.8)
    cam_obj.rotation_euler = (math.radians(82), 0, 0)
    bpy.context.scene.camera = cam_obj

    # Save .blend
    bpy.ops.wm.save_as_mainfile(filepath=r"c:\Users\Antonio Garcia\Downloads\blender\Huevos_Deluxe_3D.blend")

    # Render Image
    output_path = r"c:\Users\Antonio Garcia\Downloads\blender\render_huevos_deluxe_3d.png"
    bpy.context.scene.render.filepath = output_path
    print(f"Rendering to: {output_path}")
    bpy.ops.render.render(write_still=True)
    print("Render complete!")

    # Copy to artifacts directory
    artifact_dir = r"C:\Users\Antonio Garcia\.gemini\antigravity\brain\a18e1f12-e22f-4dc5-9ee8-acefef11731e"
    if os.path.exists(artifact_dir):
        dest = os.path.join(artifact_dir, "render_huevos_deluxe_3d.png")
        shutil.copyfile(output_path, dest)
        print(f"Copied to artifact: {dest}")

if __name__ == '__main__':
    build_scene()
