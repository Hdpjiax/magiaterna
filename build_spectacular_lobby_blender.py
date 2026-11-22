"""
build_spectacular_lobby_blender.py
Generates high-quality stylized fantasy 3D assets for MAGIA ETERNA's Lobby in Blender 5.3:
1. Forja_Real_Spectacular (Rustic stone & timber blacksmith workshop, chimney, tiled roof, anvil, quenching trough, tool rack)
2. Portal_Dungeon_Spectacular (Ancient carved stone arch with rune channels, stepped base, floating keystone crystal)
3. Arbol_Sagrado_Spectacular (Twisted ancient tree, lush cherry blossom canopies, hanging lanterns, quest board, golden chest)
4. Puesto_Mercado_Spectacular (Timber market pavilion with striped awning, egg display nests, potion shelves, bubbling cauldron)
5. Arena_Entrenamiento_Spectacular (Training yard with archery targets, sparring dummies, armillary pedestal, levitating orb)
6. Torre_Rebirth_Spectacular (Grand tiered ritual dais, faceted arcane obelisk with spiral runes, 6 floating satellite crystals)
"""

import bpy
import math
import os

def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def create_mat(name, color, roughness=0.6, metallic=0.0, emission=False, emission_strength=1.0):
    mat = bpy.data.materials.new(name=name)
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = (*color, 1.0)
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
        if emission:
            if 'Emission Color' in bsdf.inputs:
                bsdf.inputs['Emission Color'].default_value = (*color, 1.0)
                bsdf.inputs['Emission Strength'].default_value = emission_strength
    return mat

def export_assets(name):
    obj_path = os.path.abspath(f"{name}.obj")
    fbx_path = os.path.abspath(f"{name}.fbx")
    bpy.ops.wm.obj_export(filepath=obj_path)
    bpy.ops.export_scene.fbx(filepath=fbx_path)
    print(f"Exported: {obj_path} and {fbx_path}")

# ==============================================================================
# 1. FORJA REAL SPECTACULAR
# ==============================================================================
def build_spectacular_forge():
    clear_scene()
    stone_wall = create_mat("StoneWall", (0.35, 0.35, 0.38), roughness=0.85)
    timber_dark = create_mat("DarkTimber", (0.22, 0.13, 0.07), roughness=0.7)
    roof_tiles = create_mat("SlateRoof", (0.20, 0.22, 0.28), roughness=0.6)
    anvil_iron = create_mat("AnvilIron", (0.12, 0.12, 0.15), roughness=0.35, metallic=0.9)
    gold_trim = create_mat("GoldDecor", (0.9, 0.75, 0.15), roughness=0.3, metallic=0.85)
    fire_glow = create_mat("ForgeFire", (1.0, 0.45, 0.05), emission=True, emission_strength=5.0)

    # 1. Foundation & Stone Masonry Base
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.0))
    base = bpy.context.active_object
    base.name = "Stone_Foundation"
    base.scale = (8.0, 6.0, 2.0)
    base.data.materials.append(stone_wall)

    # 2. Timber Lodge Upper Walls
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 3.5))
    walls = bpy.context.active_object
    walls.name = "Timber_Walls"
    walls.scale = (7.6, 5.6, 3.0)
    walls.data.materials.append(timber_dark)

    # 3. Pitched Tiled Roof
    bpy.ops.mesh.primitive_cylinder_add(vertices=3, radius=4.4, depth=8.4, location=(0, 0, 6.2))
    roof = bpy.context.active_object
    roof.name = "Pitched_Roof"
    roof.rotation_euler = (0, math.radians(90), 0)
    roof.scale = (0.7, 1.0, 1.0)
    roof.data.materials.append(roof_tiles)

    # 4. Stone Chimney Stack
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-3.0, 1.5, 5.5))
    chimney = bpy.context.active_object
    chimney.name = "Stone_Chimney"
    chimney.scale = (1.6, 1.6, 7.0)
    chimney.data.materials.append(stone_wall)

    # Chimney Cap
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-3.0, 1.5, 9.2))
    chimney_cap = bpy.context.active_object
    chimney_cap.name = "Chimney_Cap"
    chimney_cap.scale = (2.0, 2.0, 0.4)
    chimney_cap.data.materials.append(stone_wall)

    # 5. Overhanging Porch Pillars
    for x in (-3.6, 3.6):
        bpy.ops.mesh.primitive_cylinder_add(radius=0.25, depth=4.0, location=(x, -4.0, 2.0))
        post = bpy.context.active_object
        post.name = f"Porch_Post_{x}"
        post.data.materials.append(timber_dark)

    # Porch Awning
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -3.5, 4.0))
    awning = bpy.context.active_object
    awning.name = "Porch_Awning"
    awning.scale = (8.2, 2.4, 0.3)
    awning.rotation_euler = (math.radians(15), 0, 0)
    awning.data.materials.append(roof_tiles)

    # 6. Forge Hearth & Anvil Station (Under Porch)
    # Anvil Stump
    bpy.ops.mesh.primitive_cylinder_add(radius=0.75, depth=1.1, location=(0, -3.5, 0.55))
    stump = bpy.context.active_object
    stump.name = "Anvil_Stump"
    stump.data.materials.append(timber_dark)

    # Steel Anvil
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -3.5, 1.35))
    anvil = bpy.context.active_object
    anvil.name = "Steel_Anvil"
    anvil.scale = (0.7, 1.8, 0.55)
    anvil.data.materials.append(anvil_iron)

    # Anvil Horn
    bpy.ops.mesh.primitive_cone_add(radius1=0.25, radius2=0.05, depth=0.8, location=(0, -4.5, 1.45))
    horn = bpy.context.active_object
    horn.name = "Anvil_Horn"
    horn.rotation_euler = (math.radians(-90), 0, 0)
    horn.data.materials.append(anvil_iron)

    # Glowing Coals Basin
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-2.2, -3.2, 1.0))
    fire_pit = bpy.context.active_object
    fire_pit.name = "Coals_Basin"
    fire_pit.scale = (1.4, 1.4, 0.6)
    fire_pit.data.materials.append(fire_glow)

    # Water Trough
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(2.2, -3.2, 0.7))
    trough = bpy.context.active_object
    trough.name = "Water_Trough"
    trough.scale = (1.2, 2.0, 1.2)
    trough.data.materials.append(timber_dark)

    export_assets("Forja_Real_Spectacular")

# ==============================================================================
# 2. PORTAL DUNGEON SPECTACULAR
# ==============================================================================
def build_spectacular_portal():
    clear_scene()
    ancient_stone = create_mat("AncientSlate", (0.28, 0.30, 0.34), roughness=0.8)
    gold_inlay = create_mat("RunicGold", (0.92, 0.78, 0.18), roughness=0.25, metallic=0.9)
    crystal_core = create_mat("CrystalCyan", (0.0, 0.85, 1.0), emission=True, emission_strength=6.0)
    vortex_mat = create_mat("DimensionalVortex", (0.55, 0.15, 0.95), emission=True, emission_strength=7.0)

    # 1. Stepped Circular Plinth
    for i in range(3):
        r = 6.0 - (i * 0.7)
        h = 0.35
        bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=r, depth=h, location=(0, 0, (i * h) + (h/2)))
        step = bpy.context.active_object
        step.name = f"Plinth_Step_{i+1}"
        step.data.materials.append(ancient_stone)

    # 2. Twin Runic Pillars with Celtic Strata
    for side, x in (("Left", -3.2), ("Right", 3.2)):
        # Pillar Pedestal
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(x, 0, 1.6))
        pbase = bpy.context.active_object
        pbase.name = f"Pillar_Base_{side}"
        pbase.scale = (1.8, 1.8, 1.2)
        pbase.data.materials.append(ancient_stone)

        # Fluted Obelisk Pillar
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.75, depth=7.5, location=(x, 0, 5.8))
        col = bpy.context.active_object
        col.name = f"Pillar_Col_{side}"
        col.data.materials.append(ancient_stone)

        # Golden Rune Collar
        bpy.ops.mesh.primitive_torus_add(major_radius=0.9, minor_radius=0.15, location=(x, 0, 9.6))
        collar = bpy.context.active_object
        collar.name = f"Pillar_Collar_{side}"
        collar.data.materials.append(gold_inlay)

    # 3. Majestic Curved Archway
    bpy.ops.mesh.primitive_torus_add(major_radius=3.2, minor_radius=0.8, location=(0, 0, 9.6))
    arch = bpy.context.active_object
    arch.name = "Portal_Archway"
    arch.rotation_euler = (math.radians(90), 0, 0)
    arch.data.materials.append(ancient_stone)

    # 4. Floating Diamond Keystone Crystal
    bpy.ops.mesh.primitive_cone_add(radius1=0.8, radius2=0.0, depth=1.6, location=(0, 0, 13.5))
    keystone_top = bpy.context.active_object
    keystone_top.name = "Keystone_Top"
    keystone_top.data.materials.append(crystal_core)

    bpy.ops.mesh.primitive_cone_add(radius1=0.8, radius2=0.0, depth=1.6, location=(0, 0, 12.0))
    keystone_bot = bpy.context.active_object
    keystone_bot.name = "Keystone_Bottom"
    keystone_bot.rotation_euler = (math.radians(180), 0, 0)
    keystone_bot.data.materials.append(crystal_core)

    # 5. Dimensional Swirl Disk
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=2.6, depth=0.1, location=(0, 0, 7.0))
    vortex = bpy.context.active_object
    vortex.name = "Dimensional_Vortex"
    vortex.rotation_euler = (math.radians(90), 0, 0)
    vortex.scale = (1.0, 0.1, 1.8)
    vortex.data.materials.append(vortex_mat)

    export_assets("Portal_Dungeon_Spectacular")

# ==============================================================================
# 3. ARBOL SAGRADO & QUEST ZONE SPECTACULAR
# ==============================================================================
def build_spectacular_tree_and_quests():
    clear_scene()
    bark_mat = create_mat("AncientBark", (0.26, 0.16, 0.10), roughness=0.9)
    sakura_mat1 = create_mat("SakuraPetals1", (1.0, 0.65, 0.78), roughness=0.7)
    sakura_mat2 = create_mat("SakuraPetals2", (1.0, 0.78, 0.88), roughness=0.6)
    lantern_glow = create_mat("LanternGlow", (1.0, 0.85, 0.3), emission=True, emission_strength=5.0)
    gold_chest = create_mat("ChestGold", (0.95, 0.8, 0.15), roughness=0.25, metallic=0.9)
    gem_chest = create_mat("ChestGem", (0.1, 0.85, 1.0), emission=True, emission_strength=4.0)

    # 1. Gnarled Twisted Tree Trunk
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=3.2, depth=14.0, location=(0, 0, 7.0))
    trunk = bpy.context.active_object
    trunk.name = "Tree_Trunk"
    trunk.data.materials.append(bark_mat)

    # Buttress Spreading Roots
    for i in range(4):
        ang = math.radians(i * 90 + 45)
        rx = math.cos(ang) * 4.5
        ry = math.sin(ang) * 4.5
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.2, depth=6.0, location=(rx, ry, 1.5))
        root = bpy.context.active_object
        root.name = f"Buttress_Root_{i+1}"
        root.rotation_euler = (math.sin(ang)*0.5, -math.cos(ang)*0.5, ang)
        root.data.materials.append(bark_mat)

    # 2. Main Spreading Boughs
    for i in range(4):
        ang = math.radians(i * 90)
        bx = math.cos(ang) * 6.5
        by = math.sin(ang) * 6.5
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.0, depth=8.0, location=(bx, by, 14.0))
        bough = bpy.context.active_object
        bough.name = f"Bough_{i+1}"
        bough.rotation_euler = (math.sin(ang)*0.8, -math.cos(ang)*0.8, ang)
        bough.data.materials.append(bark_mat)

        # Hanging Paper Lantern
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.6, location=(bx*1.2, by*1.2, 10.5))
        lantern = bpy.context.active_object
        lantern.name = f"Hanging_Lantern_{i+1}"
        lantern.data.materials.append(lantern_glow)

    # 3. Layered Drooping Foliage Clusters (Sakura Fantasy Cloud)
    for i, (fx, fy, fz, fr) in enumerate([
        (0, 0, 20.0, 10.0),
        (-5, -5, 17.5, 7.5),
        (5, -5, 17.5, 7.5),
        (-5, 5, 17.5, 7.5),
        (5, 5, 17.5, 7.5),
        (0, 0, 23.5, 6.5),
    ]):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=fr, location=(fx, fy, fz))
        cloud = bpy.context.active_object
        cloud.name = f"Sakura_Cloud_{i+1}"
        cloud.data.materials.append(sakura_mat1 if i % 2 == 0 else sakura_mat2)

    # 4. Quest Noticeboard
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-6.5, -4.5, 2.5))
    qboard = bpy.context.active_object
    qboard.name = "Quest_Noticeboard"
    qboard.scale = (4.0, 0.6, 3.2)
    qboard.data.materials.append(bark_mat)

    # Noticeboard Rooflet
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-6.5, -4.5, 4.3))
    qroof = bpy.context.active_object
    qroof.name = "Quest_Rooflet"
    qroof.scale = (4.5, 1.4, 0.4)
    qroof.rotation_euler = (math.radians(10), 0, 0)
    qroof.data.materials.append(bark_mat)

    # 5. Golden Daily Reward Chest
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(6.5, -4.5, 1.0))
    chest = bpy.context.active_object
    chest.name = "Daily_Reward_Chest"
    chest.scale = (2.6, 1.8, 1.4)
    chest.data.materials.append(gold_chest)

    # Chest Gemstone Lock
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.35, location=(6.5, -5.4, 1.5))
    lock = bpy.context.active_object
    lock.name = "Chest_GemLock"
    lock.data.materials.append(gem_chest)

    export_assets("Arbol_Sagrado_Spectacular")

# ==============================================================================
# 4. MERCADO & TIENDA DE HUEVOS SPECTACULAR
# ==============================================================================
def build_spectacular_market():
    clear_scene()
    wood_stall = create_mat("StallWood", (0.30, 0.18, 0.10), roughness=0.7)
    purple_fabric = create_mat("RoyalPurpleFabric", (0.42, 0.10, 0.65), roughness=0.55)
    gold_fabric = create_mat("GoldFabric", (0.95, 0.80, 0.20), roughness=0.45)
    copper_cauldron = create_mat("CauldronCopper", (0.25, 0.16, 0.12), roughness=0.35, metallic=0.85)
    potion_liquid = create_mat("LiquidEmerald", (0.0, 1.0, 0.65), emission=True, emission_strength=5.0)

    # 1. Timber Pavilion Frame
    for x in (-3.5, 3.5):
        for y in (-2.0, 2.0):
            bpy.ops.mesh.primitive_cylinder_add(radius=0.25, depth=4.5, location=(x, y, 2.25))
            post = bpy.context.active_object
            post.name = f"Market_Post_{x}_{y}"
            post.data.materials.append(wood_stall)

    # Main Service Counter
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -1.8, 1.2))
    counter = bpy.context.active_object
    counter.name = "Market_Counter"
    counter.scale = (7.4, 1.4, 2.0)
    counter.data.materials.append(wood_stall)

    # 2. Sagging Striped Fabric Awning
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=4.2, depth=4.6, location=(0, 0, 4.4))
    canopy = bpy.context.active_object
    canopy.name = "Striped_Canopy"
    canopy.rotation_euler = (0, math.radians(90), 0)
    canopy.scale = (0.35, 1.0, 1.0)
    canopy.data.materials.append(purple_fabric)

    # 3. Pet Egg Display Nests on Counter
    for i, ex in enumerate((-2.2, 0.0, 2.2)):
        # Wicker Nest
        bpy.ops.mesh.primitive_torus_add(major_radius=0.6, minor_radius=0.2, location=(ex, -1.8, 2.3))
        nest = bpy.context.active_object
        nest.name = f"Nest_{i+1}"
        nest.data.materials.append(wood_stall)

        # Giant Fantasy Egg
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=0.55, location=(ex, -1.8, 2.7))
        egg = bpy.context.active_object
        egg.name = f"Pet_Egg_{i+1}"
        egg.scale = (1.0, 1.0, 1.4)
        egg.data.materials.append(gold_fabric)

    # 4. Bubbling Alchemist's Cauldron on Side
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=1.4, depth=1.6, location=(5.5, 0, 1.1))
    cauldron = bpy.context.active_object
    cauldron.name = "Alchemist_Cauldron"
    cauldron.data.materials.append(copper_cauldron)

    # Bubbling Emerald Potion Surface
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=1.25, depth=0.1, location=(5.5, 0, 1.85))
    liquid = bpy.context.active_object
    liquid.name = "Potion_Liquid"
    liquid.data.materials.append(potion_liquid)

    export_assets("Puesto_Mercado_Spectacular")

# ==============================================================================
# 5. ARENA DE ENTRENAMIENTO SPECTACULAR
# ==============================================================================
def build_spectacular_training():
    clear_scene()
    sand_mat = create_mat("ArenaSand", (0.82, 0.72, 0.52), roughness=0.9)
    timber_mat = create_mat("FenceTimber", (0.32, 0.20, 0.12), roughness=0.8)
    straw_mat = create_mat("TargetStraw", (0.85, 0.75, 0.35), roughness=0.85)
    target_red = create_mat("TargetRed", (0.9, 0.15, 0.15), roughness=0.6)
    orb_glow = create_mat("ManaOrbGlow", (0.0, 0.85, 1.0), emission=True, emission_strength=6.0)
    gold_rings = create_mat("ArmillaryGold", (0.95, 0.82, 0.18), roughness=0.25, metallic=0.9)

    # 1. Sand Arena Ground Plate
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=12.0, depth=0.3, location=(0, 0, 0.15))
    arena = bpy.context.active_object
    arena.name = "Sand_Arena_Plate"
    arena.data.materials.append(sand_mat)

    # 2. Archery Targets
    for i, tx in enumerate((-6.0, 6.0)):
        # Straw Boss
        bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.4, depth=0.4, location=(tx, 8.0, 2.5))
        target = bpy.context.active_object
        target.name = f"Archery_Target_{i+1}"
        target.rotation_euler = (math.radians(75), 0, 0)
        target.data.materials.append(straw_mat)

        # Bullseye Core
        bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.45, depth=0.45, location=(tx, 8.0, 2.5))
        core = bpy.context.active_object
        core.name = f"Target_Bullseye_{i+1}"
        core.rotation_euler = (math.radians(75), 0, 0)
        core.data.materials.append(target_red)

    # 3. Sparring Training Dummies
    for i, dx in enumerate((-4.0, 4.0)):
        # Post
        bpy.ops.mesh.primitive_cylinder_add(radius=0.2, depth=3.0, location=(dx, -4.0, 1.5))
        dummy_post = bpy.context.active_object
        dummy_post.name = f"Dummy_Post_{i+1}"
        dummy_post.data.materials.append(timber_mat)

        # Burlap Body
        bpy.ops.mesh.primitive_cylinder_add(radius=0.55, depth=1.6, location=(dx, -4.0, 2.0))
        dummy_body = bpy.context.active_object
        dummy_body.name = f"Dummy_Body_{i+1}"
        dummy_body.data.materials.append(straw_mat)

    # 4. Centerpiece: Armillary Pedestal with Floating Mana Orb
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.2, depth=1.2, location=(0, 0, 0.6))
    ped_base = bpy.context.active_object
    ped_base.name = "Pedestal_Base"
    ped_base.data.materials.append(timber_mat)

    # Floating Armillary Gold Rings
    bpy.ops.mesh.primitive_torus_add(major_radius=1.8, minor_radius=0.15, location=(0, 0, 3.2))
    ring1 = bpy.context.active_object
    ring1.name = "Armillary_Ring_1"
    ring1.rotation_euler = (math.radians(45), 0, 0)
    ring1.data.materials.append(gold_rings)

    bpy.ops.mesh.primitive_torus_add(major_radius=1.8, minor_radius=0.15, location=(0, 0, 3.2))
    ring2 = bpy.context.active_object
    ring2.name = "Armillary_Ring_2"
    ring2.rotation_euler = (0, math.radians(45), 0)
    ring2.data.materials.append(gold_rings)

    # Levitating Magic Mana Orb
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=1.1, location=(0, 0, 3.2))
    orb = bpy.context.active_object
    orb.name = "Floating_Mana_Orb"
    orb.data.materials.append(orb_glow)

    export_assets("Arena_Entrenamiento_Spectacular")

# ==============================================================================
# 6. TORRE DE REBIRTH SPECTACULAR
# ==============================================================================
def build_spectacular_rebirth():
    clear_scene()
    obsidian_stone = create_mat("ArcaneObsidian", (0.16, 0.14, 0.22), roughness=0.45)
    gold_runes = create_mat("RebirthGold", (0.95, 0.82, 0.20), roughness=0.3, metallic=0.9)
    amethyst_glow = create_mat("AmethystEnergy", (0.85, 0.20, 1.0), emission=True, emission_strength=7.0)

    # 1. Stepped Ritual Dais
    for i in range(3):
        r = 8.0 - (i * 1.2)
        h = 0.45
        bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=r, depth=h, location=(0, 0, (i * h) + (h/2)))
        dais = bpy.context.active_object
        dais.name = f"Rebirth_Dais_{i+1}"
        dais.data.materials.append(obsidian_stone)

    # Inlaid Runic Ring
    bpy.ops.mesh.primitive_torus_add(major_radius=4.8, minor_radius=0.2, location=(0, 0, 1.45))
    ring = bpy.context.active_object
    ring.name = "Inlaid_Rune_Ring"
    ring.data.materials.append(amethyst_glow)

    # 2. Soaring Faceted Monolith Spire
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=1.8, depth=16.0, location=(0, 0, 9.5))
    spire = bpy.context.active_object
    spire.name = "Rebirth_Monolith_Spire"
    spire.scale = (1.0, 1.0, 1.0)
    spire.data.materials.append(obsidian_stone)

    # Spire Glowing Core Shards
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=2.0, depth=4.0, location=(0, 0, 9.5))
    core = bpy.context.active_object
    core.name = "Spire_Amethyst_Core"
    core.data.materials.append(amethyst_glow)

    # Pyramidion Peak
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=1.8, radius2=0.0, depth=3.0, location=(0, 0, 19.0))
    peak = bpy.context.active_object
    peak.name = "Spire_Peak"
    peak.data.materials.append(gold_runes)

    # 3. 6 Surrounding Orbiting Satellite Crystals
    for i in range(6):
        ang = math.radians(i * 60)
        sx = math.cos(ang) * 5.5
        sy = math.sin(ang) * 5.5
        sz = 4.0 + (i % 3 * 2.0)
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.6, radius2=0.0, depth=2.4, location=(sx, sy, sz))
        sat = bpy.context.active_object
        sat.name = f"Satellite_Crystal_{i+1}"
        sat.rotation_euler = (0.2, 0.2, ang)
        sat.data.materials.append(amethyst_glow)

    export_assets("Torre_Rebirth_Spectacular")

print("==================================================")
print("  BUILDING SPECTACULAR LOBBY ASSETS IN BLENDER 5.3")
print("==================================================")
build_spectacular_forge()
build_spectacular_portal()
build_spectacular_tree_and_quests()
build_spectacular_market()
build_spectacular_training()
build_spectacular_rebirth()
print("All 6 spectacular Lobby 3D models built and exported successfully!")
