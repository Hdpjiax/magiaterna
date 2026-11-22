"""
=============================================================================
MAGIA ETERNA — GENERADOR DE MODELOS 3D EN BLENDER 5.3
Modela por separado cada uno de los 6 Portales de Mazmorras con detalles únicos,
más el Monumento Central de Maná, Taller de Forja, y Árbol Sagrado.
=============================================================================
"""
import bpy
import math

def clean_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def create_pbr_material(name, base_color, metallic=0.0, roughness=0.5, emission=None, emission_val=0.0):
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

# =============================================================================
# 1. MODELADO DEL PORTAL 1: BOSQUE DE LOS SUSURROS (Naturaleza, Runas Esmeralda)
# =============================================================================
def build_portal_bosque():
    clean_scene()
    col = bpy.data.collections.new("Portal_Bosque_Susurros")
    bpy.context.scene.collection.children.link(col)
    
    mat_stone = create_pbr_material("P1_Piedra_Musgo", (0.28, 0.32, 0.24, 1.0), roughness=0.85)
    mat_wood = create_pbr_material("P1_Madera_Raices", (0.32, 0.20, 0.10, 1.0), roughness=0.75)
    mat_gem = create_pbr_material("P1_Cristal_Esmeralda", (0.1, 0.9, 0.3, 1.0), roughness=0.1, emission=(0.15, 1.0, 0.35, 1.0), emission_val=12.0)
    mat_leaf = create_pbr_material("P1_Hojas_Enredadera", (0.18, 0.48, 0.15, 1.0), roughness=0.6)
    
    # Base de piedra escalonada
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=3.5, depth=0.4, location=(0, 0, 0.2))
    base1 = bpy.context.active_object; base1.name = "P1_Base_Piedra_1"; base1.data.materials.append(mat_stone); col.objects.link(base1)
    
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.8, depth=0.4, location=(0, 0, 0.6))
    base2 = bpy.context.active_object; base2.name = "P1_Base_Piedra_2"; base2.data.materials.append(mat_stone); col.objects.link(base2)
    
    # Columnas gemelas de piedra rúnica
    for side in (-1.8, 1.8):
        bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.45, depth=5.5, location=(side, 0, 3.4))
        pillar = bpy.context.active_object; pillar.name = f"P1_Pilar_{'L' if side < 0 else 'R'}"; pillar.data.materials.append(mat_stone); col.objects.link(pillar)
        # Raíces retorcidas alrededor de las columnas
        for h in range(4):
            z = 1.0 + h * 1.2
            bpy.ops.mesh.primitive_torus_add(major_radius=0.52, minor_radius=0.08, location=(side, 0, z), rotation=(0.1 * side, 0.15 * h, 0))
            vine = bpy.context.active_object; vine.name = f"P1_Enredadera_{side}_{h}"; vine.data.materials.append(mat_wood); col.objects.link(vine)
    
    # Dintel de arco gótico enlazado
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 6.2))
    arch = bpy.context.active_object; arch.name = "P1_Dintel_Arco"; arch.scale = (4.4, 0.9, 0.7); arch.data.materials.append(mat_stone); col.objects.link(arch)
    
    # Hojas y brotes en la cima
    for ox in (-1.5, -0.7, 0, 0.7, 1.5):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.4, location=(ox, 0, 6.8))
        foliage = bpy.context.active_object; foliage.name = f"P1_Hojas_{ox}"; foliage.data.materials.append(mat_leaf); col.objects.link(foliage)
        
    # Cristal flotante del portal
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.7, radius2=0, depth=1.6, location=(0, 0, 3.6))
    gem_top = bpy.context.active_object; gem_top.name = "P1_Cristal_Top"; gem_top.data.materials.append(mat_gem); col.objects.link(gem_top)
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.7, radius2=0, depth=1.6, location=(0, 0, 3.6), rotation=(math.pi, 0, 0))
    gem_bot = bpy.context.active_object; gem_bot.name = "P1_Cristal_Bot"; gem_bot.data.materials.append(mat_gem); col.objects.link(gem_bot)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Portal_Bosque_Susurros.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Portal_Bosque_Susurros.fbx")
    print("Portal 1: Bosque de los Susurros exportado con exito.")

# =============================================================================
# 2. MODELADO DEL PORTAL 2: CAVERNA DE CRISTALES (Geoda, Amatista Púrpura)
# =============================================================================
def build_portal_cristales():
    clean_scene()
    col = bpy.data.collections.new("Portal_Caverna_Cristales")
    bpy.context.scene.collection.children.link(col)
    
    mat_rock = create_pbr_material("P2_Roca_Geoda", (0.15, 0.14, 0.18, 1.0), roughness=0.9)
    mat_crystal = create_pbr_material("P2_Cristal_Amatista", (0.65, 0.15, 0.95, 1.0), roughness=0.1, emission=(0.75, 0.20, 1.0, 1.0), emission_val=15.0)
    
    # Base irregular de roca
    bpy.ops.mesh.primitive_cylinder_add(vertices=7, radius=3.4, depth=0.6, location=(0, 0, 0.3))
    base = bpy.context.active_object; base.name = "P2_Base_Roca"; base.data.materials.append(mat_rock); col.objects.link(base)
    
    # Arcos gemelos de roca áspera
    for side in (-1.9, 1.9):
        bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.6, depth=5.8, location=(side, 0, 3.2), rotation=(0, 0.05 * side, 0))
        pillar = bpy.context.active_object; pillar.name = f"P2_PilarRoca_{side}"; pillar.data.materials.append(mat_rock); col.objects.link(pillar)
        # Clústeres de cristales brotando de la roca
        for ci in range(5):
            cz = 1.0 + ci * 0.9
            bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=0.22, depth=0.8, location=(side * 0.8, -0.2, cz), rotation=(0.4, 0.5 * (1 if side>0 else -1), 0.3 * ci))
            spike = bpy.context.active_object; spike.name = f"P2_Spike_{side}_{ci}"; spike.data.materials.append(mat_crystal); col.objects.link(spike)

    # Techo arqueado de estalactitas
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 6.2))
    arch = bpy.context.active_object; arch.name = "P2_Techo_Geoda"; arch.scale = (4.2, 1.1, 0.8); arch.data.materials.append(mat_rock); col.objects.link(arch)
    for si in (-1.2, -0.4, 0.4, 1.2):
        bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=0.25, depth=1.1, location=(si, 0, 5.4), rotation=(math.pi, 0, 0.2 * si))
        stala = bpy.context.active_object; stala.name = f"P2_Estalactita_{si}"; stala.data.materials.append(mat_crystal); col.objects.link(stala)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Portal_Caverna_Cristales.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Portal_Caverna_Cristales.fbx")
    print("Portal 2: Caverna de Cristales exportado con exito.")

# =============================================================================
# 3. MODELADO DEL PORTAL 3: REINO DEL HIELO (Glaciar, Ventisca Ártica)
# =============================================================================
def build_portal_hielo():
    clean_scene()
    col = bpy.data.collections.new("Portal_Reino_Hielo")
    bpy.context.scene.collection.children.link(col)
    
    mat_ice = create_pbr_material("P3_Hielo_Glacial", (0.45, 0.75, 0.95, 1.0), roughness=0.15, emission=(0.2, 0.8, 1.0, 1.0), emission_val=8.0)
    mat_snow_stone = create_pbr_material("P3_Piedra_Nevada", (0.75, 0.82, 0.90, 1.0), roughness=0.6)
    
    # Plinto helado hexagonal
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=3.2, depth=0.5, location=(0, 0, 0.25))
    base = bpy.context.active_object; base.name = "P3_Base_Glaciar"; base.data.materials.append(mat_snow_stone); col.objects.link(base)
    
    # Agujas de hielo translúcidas angulares
    for side in (-1.8, 1.8):
        bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.55, depth=6.2, location=(side, 0, 3.4), rotation=(0, 0.04 * side, 0))
        spire = bpy.context.active_object; spire.name = f"P3_Aguja_Hielo_{side}"; spire.data.materials.append(mat_ice); col.objects.link(spire)
        
    # Anillo orbital de carámbanos
    bpy.ops.mesh.primitive_torus_add(major_radius=1.8, minor_radius=0.1, location=(0, 0, 3.5), rotation=(math.pi/2, 0, 0))
    ice_ring = bpy.context.active_object; ice_ring.name = "P3_Anillo_Hielo"; ice_ring.data.materials.append(mat_ice); col.objects.link(ice_ring)
    
    # Cristal de escarcha central
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.85, location=(0, 0, 3.5))
    frost_core = bpy.context.active_object; frost_core.name = "P3_Frost_Core"; frost_core.data.materials.append(mat_ice); col.objects.link(frost_core)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Portal_Reino_Hielo.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Portal_Reino_Hielo.fbx")
    print("Portal 3: Reino del Hielo exportado con exito.")

# =============================================================================
# 4. MODELADO DEL PORTAL 4: CRIPTA DE LAS ALMAS (Gótico, Obsidiana, Espectros)
# =============================================================================
def build_portal_cripta():
    clean_scene()
    col = bpy.data.collections.new("Portal_Cripta_Almas")
    bpy.context.scene.collection.children.link(col)
    
    mat_obsidian = create_pbr_material("P4_Obsidiana_Cripta", (0.05, 0.04, 0.07, 1.0), metallic=0.4, roughness=0.2)
    mat_soul_flame = create_pbr_material("P4_Fuego_Espectral", (0.2, 1.0, 0.7, 1.0), roughness=0.0, emission=(0.1, 1.0, 0.6, 1.0), emission_val=20.0)
    mat_metal = create_pbr_material("P4_Hierro_Corrupto", (0.12, 0.10, 0.14, 1.0), metallic=0.9, roughness=0.35)
    
    # Base sepulcral escalonada
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.3))
    base = bpy.context.active_object; base.name = "P4_Base_Sepulcro"; base.scale = (5.2, 3.2, 0.6); base.data.materials.append(mat_obsidian); col.objects.link(base)
    
    # Pilares góticos con púas de hierro
    for side in (-1.8, 1.8):
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.45, depth=5.6, location=(side, 0, 3.2))
        pillar = bpy.context.active_object; pillar.name = f"P4_Pilar_Gotico_{side}"; pillar.data.materials.append(mat_obsidian); col.objects.link(pillar)
        # Braseros de fuego espectral a los lados
        bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.4, depth=0.5, location=(side * 1.5, 0.8, 1.8))
        brazier = bpy.context.active_object; brazier.name = f"P4_Brasero_{side}"; brazier.data.materials.append(mat_metal); col.objects.link(brazier)
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.25, location=(side * 1.5, 0.8, 2.2))
        flame = bpy.context.active_object; flame.name = f"P4_Llama_{side}"; flame.data.materials.append(mat_soul_flame); col.objects.link(flame)

    # Arco ojival gótico
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 6.2))
    arch = bpy.context.active_object; arch.name = "P4_Arco_Ojival"; arch.scale = (4.0, 0.8, 0.8); arch.data.materials.append(mat_obsidian); col.objects.link(arch)
    # Calavera / gárgola en el centro del arco
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.45, location=(0, -0.3, 6.2))
    skull = bpy.context.active_object; skull.name = "P4_Mascara_Gotica"; skull.data.materials.append(mat_soul_flame); col.objects.link(skull)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Portal_Cripta_Almas.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Portal_Cripta_Almas.fbx")
    print("Portal 4: Cripta de las Almas exportado con exito.")

# =============================================================================
# 5. MODELADO DEL PORTAL 5: TEMPLO DE LOS CIELOS (Mármol, Halo Solar, Oro)
# =============================================================================
def build_portal_cielos():
    clean_scene()
    col = bpy.data.collections.new("Portal_Templo_Cielos")
    bpy.context.scene.collection.children.link(col)
    
    mat_marble = create_pbr_material("P5_Marmol_Celestial", (0.95, 0.94, 0.92, 1.0), roughness=0.2)
    mat_gold = create_pbr_material("P5_Oro_Divino", (1.0, 0.82, 0.22, 1.0), metallic=0.95, roughness=0.15)
    mat_sun = create_pbr_material("P5_Luz_Solar", (1.0, 0.9, 0.4, 1.0), roughness=0.0, emission=(1.0, 0.88, 0.35, 1.0), emission_val=22.0)
    
    # Base circular de mármol
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=3.2, depth=0.4, location=(0, 0, 0.2))
    base = bpy.context.active_object; base.name = "P5_Base_Marmol"; base.data.materials.append(mat_marble); col.objects.link(base)
    
    # Columnas dóricas estriadas
    for side in (-1.8, 1.8):
        bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.42, depth=5.6, location=(side, 0, 3.2))
        col_pillar = bpy.context.active_object; col_pillar.name = f"P5_Columna_{side}"; col_pillar.data.materials.append(mat_marble); col.objects.link(col_pillar)
        # Capitel dorado
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(side, 0, 6.0))
        cap = bpy.context.active_object; cap.name = f"P5_Capitel_{side}"; cap.scale = (1.1, 1.1, 0.3); cap.data.materials.append(mat_gold); col.objects.link(cap)
        
    # Frontón celestial dorado
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 6.4))
    entablature = bpy.context.active_object; entablature.name = "P5_Fronton"; entablature.scale = (4.4, 1.0, 0.5); entablature.data.materials.append(mat_marble); col.objects.link(entablature)
    
    # Halo solar alado radiante
    bpy.ops.mesh.primitive_torus_add(major_radius=1.6, minor_radius=0.12, location=(0, 0, 3.5), rotation=(math.pi/2, 0, 0))
    halo = bpy.context.active_object; halo.name = "P5_Halo_Solar"; halo.data.materials.append(mat_sun); col.objects.link(halo)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Portal_Templo_Cielos.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Portal_Templo_Cielos.fbx")
    print("Portal 5: Templo de los Cielos exportado con exito.")

# =============================================================================
# 6. MODELADO DEL PORTAL 6: ABISMO DEL INFINITO (Basalto, Cuernos, Magma)
# =============================================================================
def build_portal_abismo():
    clean_scene()
    col = bpy.data.collections.new("Portal_Abismo_Infinito")
    bpy.context.scene.collection.children.link(col)
    
    mat_basalt = create_pbr_material("P6_Basalto_Volcanico", (0.06, 0.05, 0.06, 1.0), roughness=0.8)
    mat_magma = create_pbr_material("P6_Lava_Infernal", (1.0, 0.15, 0.05, 1.0), roughness=0.05, emission=(1.0, 0.15, 0.02, 1.0), emission_val=25.0)
    
    # Base irregular de piedra fracturada
    bpy.ops.mesh.primitive_cylinder_add(vertices=7, radius=3.5, depth=0.5, location=(0, 0, 0.25))
    base = bpy.context.active_object; base.name = "P6_Base_Basalto"; base.data.materials.append(mat_basalt); col.objects.link(base)
    
    # Cuernos titánicos curvados de basalto
    for side in (-1.8, 1.8):
        bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.6, depth=6.2, location=(side, 0, 3.3), rotation=(0, -0.08 * side, 0))
        horn = bpy.context.active_object; horn.name = f"P6_Cuerno_Abisal_{side}"; horn.data.materials.append(mat_basalt); col.objects.link(horn)
        # Falso río de magma en el cuerno
        for mi in range(4):
            bpy.ops.mesh.primitive_torus_add(major_radius=0.45 - mi*0.06, minor_radius=0.04, location=(side, 0, 1.2 + mi*1.2))
            magma_vein = bpy.context.active_object; magma_vein.name = f"P6_VenaMagma_{side}_{mi}"; magma_vein.data.materials.append(mat_magma); col.objects.link(magma_vein)
            
    # Orbe del Vacío Infernal
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=1.1, location=(0, 0, 3.4))
    rift = bpy.context.active_object; rift.name = "P6_Fisura_Abisal"; rift.data.materials.append(mat_magma); col.objects.link(rift)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Portal_Abismo_Infinito.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Portal_Abismo_Infinito.fbx")
    print("Portal 6: Abismo del Infinito exportado con exito.")

if __name__ == "__main__":
    build_portal_bosque()
    build_portal_cristales()
    build_portal_hielo()
    build_portal_cripta()
    build_portal_cielos()
    build_portal_abismo()
    print("=== TODOS LOS 6 PORTALES HAN SIDO MODELADOS Y EXPORTADOS EN BLENDER EXITOSAMENTE ===")
