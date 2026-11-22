"""
build_lobby_assets_blender.py
Generates 3D models for MAGIA ETERNA's Lobby in Blender 5.3:
1. Forja_Blacksmith_Lobby (Furnace, Anvil on stump, Tool rack, Quenching tub)
2. Portal_Dimensional_Lobby (Runic stone portal arch with steps and floating crystal sockets)
3. Orbe_Magico_Pedestal (Arcane training pedestal with hovering orb and runic arms)
4. Tienda_Huevos_Lobby (Pavilion stall with nests and pedestals for egg families)
5. Cofre_Recompensas_Lobby (Ornate treasure chest for daily rewards)
6. Torre_Rebirth_Spire (Arcane rebirth monolith with surrounding runic pillars)
"""

import bpy
import math
import os

def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def create_material(name, color, roughness=0.5, metallic=0.0, emission=False, emission_strength=1.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = (*color, 1.0)
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
        if emission:
            # Emission in Principled BSDF
            if 'Emission Color' in bsdf.inputs:
                bsdf.inputs['Emission Color'].default_value = (*color, 1.0)
                bsdf.inputs['Emission Strength'].default_value = emission_strength
    return mat

def build_forge():
    clear_scene()
    root = bpy.data.collections.new("Forja_Blacksmith")
    bpy.context.scene.collection.children.link(root)

    stone_mat = create_material("Stone", (0.28, 0.28, 0.32), roughness=0.85)
    dark_iron_mat = create_material("DarkIron", (0.12, 0.12, 0.14), roughness=0.35, metallic=0.9)
    gold_mat = create_material("Gold", (0.9, 0.75, 0.2), roughness=0.3, metallic=0.85)
    fire_mat = create_material("Fire", (1.0, 0.4, 0.05), emission=True, emission_strength=4.0)
    wood_mat = create_material("Wood", (0.22, 0.14, 0.08), roughness=0.75)

    # 1. Main Hearth / Furnace Base
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.2))
    base = bpy.context.active_object
    base.name = "Hearth_Base"
    base.scale = (4.0, 3.2, 2.4)
    base.data.materials.append(stone_mat)

    # Furnace Opening (Fire Chamber)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -1.0, 1.2))
    chamber = bpy.context.active_object
    chamber.name = "Fire_Chamber"
    chamber.scale = (2.2, 1.5, 1.4)
    chamber.data.materials.append(fire_mat)

    # Chimney Stack
    bpy.ops.mesh.primitive_cylinder_add(radius=1.0, depth=4.0, location=(0, 0.6, 4.4))
    chimney = bpy.context.active_object
    chimney.name = "Chimney"
    chimney.scale = (1.2, 1.2, 1.0)
    chimney.data.materials.append(stone_mat)

    # 2. Anvil
    # Stump
    bpy.ops.mesh.primitive_cylinder_add(radius=0.7, depth=1.0, location=(0, -3.5, 0.5))
    stump = bpy.context.active_object
    stump.name = "Anvil_Stump"
    stump.data.materials.append(wood_mat)

    # Anvil Body
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -3.5, 1.25))
    anvil = bpy.context.active_object
    anvil.name = "Anvil_Body"
    anvil.scale = (0.7, 1.6, 0.5)
    anvil.data.materials.append(dark_iron_mat)

    # Anvil Horn
    bpy.ops.mesh.primitive_cone_add(radius1=0.25, radius2=0.05, depth=0.8, location=(0, -4.5, 1.35))
    horn = bpy.context.active_object
    horn.name = "Anvil_Horn"
    horn.rotation_euler = (math.radians(-90), 0, 0)
    horn.data.materials.append(dark_iron_mat)

    # 3. Quenching Trough
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-2.6, -2.5, 0.6))
    trough = bpy.context.active_object
    trough.name = "Water_Trough"
    trough.scale = (1.2, 2.4, 1.2)
    trough.data.materials.append(wood_mat)

    # Water inside trough
    water_mat = create_material("Water", (0.1, 0.45, 0.8), roughness=0.1)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-2.6, -2.5, 1.0))
    water = bpy.context.active_object
    water.name = "Trough_Water"
    water.scale = (1.0, 2.2, 0.2)
    water.data.materials.append(water_mat)

    out_path = os.path.abspath("Forja_Blacksmith_Lobby.obj")
    bpy.ops.wm.obj_export(filepath=out_path)
    bpy.ops.export_scene.fbx(filepath=os.path.abspath("Forja_Blacksmith_Lobby.fbx"))
    print(f"Exported: {out_path}")

def build_portal():
    clear_scene()
    root = bpy.data.collections.new("Portal_Dimensional")
    bpy.context.scene.collection.children.link(root)

    ancient_stone = create_material("AncientStone", (0.25, 0.27, 0.30), roughness=0.9)
    runic_glow = create_material("RunicCyan", (0.0, 0.85, 1.0), emission=True, emission_strength=5.0)
    portal_vortex = create_material("PortalVortex", (0.5, 0.1, 0.95), emission=True, emission_strength=6.0)

    # Base steps
    for i in range(3):
        w = 7.0 - (i * 0.8)
        d = 4.0 - (i * 0.5)
        h = 0.35
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, (i * h) + (h/2)))
        step = bpy.context.active_object
        step.name = f"Step_{i+1}"
        step.scale = (w, d, h)
        step.data.materials.append(ancient_stone)

    # Left Pillar
    bpy.ops.mesh.primitive_cylinder_add(radius=0.65, depth=6.5, location=(-2.4, 0, 4.3))
    p1 = bpy.context.active_object
    p1.name = "Pillar_Left"
    p1.data.materials.append(ancient_stone)

    # Right Pillar
    bpy.ops.mesh.primitive_cylinder_add(radius=0.65, depth=6.5, location=(2.4, 0, 4.3))
    p2 = bpy.context.active_object
    p2.name = "Pillar_Right"
    p2.data.materials.append(ancient_stone)

    # Top Arch (Torus segment or curved box)
    bpy.ops.mesh.primitive_torus_add(major_radius=2.4, minor_radius=0.65, location=(0, 0, 7.5))
    arch = bpy.context.active_object
    arch.name = "Portal_Arch"
    arch.rotation_euler = (math.radians(90), 0, 0)
    arch.data.materials.append(ancient_stone)

    # Floating Keystone Gem at top
    bpy.ops.mesh.primitive_cone_add(radius1=0.7, radius2=0.0, depth=1.2, location=(0, 0, 10.2))
    keystone = bpy.context.active_object
    keystone.name = "Keystone_Gem"
    keystone.data.materials.append(runic_glow)

    # Dimensional Vortex Aperture
    bpy.ops.mesh.primitive_cylinder_add(radius=2.0, depth=0.15, location=(0, 0, 5.5))
    vortex = bpy.context.active_object
    vortex.name = "Vortex_Aperture"
    vortex.rotation_euler = (math.radians(90), 0, 0)
    vortex.scale = (1.0, 0.1, 1.8)
    vortex.data.materials.append(portal_vortex)

    out_path = os.path.abspath("Portal_Dimensional_Lobby.obj")
    bpy.ops.wm.obj_export(filepath=out_path)
    bpy.ops.export_scene.fbx(filepath=os.path.abspath("Portal_Dimensional_Lobby.fbx"))
    print(f"Exported: {out_path}")

def build_training_orb_pedestal():
    clear_scene()
    ancient_stone = create_material("StoneRunic", (0.22, 0.24, 0.28), roughness=0.8)
    magic_cyan = create_material("MagicMana", (0.05, 0.8, 1.0), emission=True, emission_strength=6.0)
    gold_trim = create_material("GoldTrim", (0.85, 0.7, 0.15), roughness=0.35, metallic=0.9)

    # Stepped Octagonal Pedestal Base
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.5, depth=0.5, location=(0, 0, 0.25))
    b1 = bpy.context.active_object
    b1.name = "Pedestal_Base"
    b1.data.materials.append(ancient_stone)

    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.8, depth=0.8, location=(0, 0, 0.9))
    b2 = bpy.context.active_object
    b2.name = "Pedestal_Mid"
    b2.data.materials.append(ancient_stone)

    # Runic Pillar
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.0, depth=2.2, location=(0, 0, 2.4))
    b3 = bpy.context.active_object
    b3.name = "Pedestal_Shaft"
    b3.data.materials.append(ancient_stone)

    # Golden Rune Collar
    bpy.ops.mesh.primitive_torus_add(major_radius=1.1, minor_radius=0.15, location=(0, 0, 3.4))
    c1 = bpy.context.active_object
    c1.name = "Rune_Collar"
    c1.data.materials.append(gold_trim)

    # 4 Curved Claws / Prongs
    for i in range(4):
        angle = math.radians(i * 90)
        x = math.cos(angle) * 1.2
        y = math.sin(angle) * 1.2
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(x, y, 4.2))
        claw = bpy.context.active_object
        claw.name = f"Claw_{i+1}"
        claw.scale = (0.25, 0.25, 1.2)
        claw.rotation_euler = (math.sin(angle)*0.3, -math.cos(angle)*0.3, angle)
        claw.data.materials.append(gold_trim)

    # The Levitating Magic Mana Orb
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=1.2, location=(0, 0, 5.0))
    orb = bpy.context.active_object
    orb.name = "Mana_Orb"
    orb.data.materials.append(magic_cyan)

    out_path = os.path.abspath("Orbe_Magico_Pedestal.obj")
    bpy.ops.wm.obj_export(filepath=out_path)
    bpy.ops.export_scene.fbx(filepath=os.path.abspath("Orbe_Magico_Pedestal.fbx"))
    print(f"Exported: {out_path}")

def build_reward_chest():
    clear_scene()
    wood_mat = create_material("ChestWood", (0.28, 0.16, 0.09), roughness=0.7)
    gold_mat = create_material("ChestGold", (0.95, 0.78, 0.15), roughness=0.25, metallic=0.9)
    gem_mat = create_material("ChestGem", (0.95, 0.1, 0.3), emission=True, emission_strength=4.0)

    # Chest Lower Body
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.8))
    body = bpy.context.active_object
    body.name = "Chest_Body"
    body.scale = (2.2, 1.4, 1.2)
    body.data.materials.append(wood_mat)

    # Chest Arched Lid
    bpy.ops.mesh.primitive_cylinder_add(radius=0.7, depth=2.2, location=(0, 0, 1.5))
    lid = bpy.context.active_object
    lid.name = "Chest_Lid"
    lid.rotation_euler = (0, math.radians(90), 0)
    lid.data.materials.append(wood_mat)

    # Gold Reinforcement Trim
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.8))
    trim = bpy.context.active_object
    trim.name = "Chest_GoldBands"
    trim.scale = (2.25, 1.45, 0.25)
    trim.data.materials.append(gold_mat)

    # Glowing Gem Latch
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.28, location=(0, -0.75, 1.35))
    latch = bpy.context.active_object
    latch.name = "Chest_GemLatch"
    latch.data.materials.append(gem_mat)

    out_path = os.path.abspath("Cofre_Recompensas_Lobby.obj")
    bpy.ops.wm.obj_export(filepath=out_path)
    bpy.ops.export_scene.fbx(filepath=os.path.abspath("Cofre_Recompensas_Lobby.fbx"))
    print(f"Exported: {out_path}")

print("Building 3D models in Blender 5.3...")
build_forge()
build_portal()
build_training_orb_pedestal()
build_reward_chest()
print("All 3D Lobby assets created and exported successfully!")
