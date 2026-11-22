"""
=============================================================================
MAGIA ETERNA — MODELADO DE JEFES Y COFRE DEL BOSQUE DE LOS SUSURROS EN BLENDER 5.3
1. Treant Ancestral (Jefe Final - 3 Fases)
2. Guardián de Raíces (Mini-Jefe de Raíces)
3. Cofre del Tesoro Ancestral
=============================================================================
"""
import bpy
import math

def clean_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def create_pbr_mat(name, base_color, metallic=0.0, roughness=0.6, emission=None, emission_val=0.0):
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

def build_treant_boss():
    clean_scene()
    col = bpy.data.collections.new("Treant_Ancestral_Boss")
    bpy.context.scene.collection.children.link(col)
    
    mat_bark = create_pbr_mat("T_Corteza_Ancestral", (0.25, 0.16, 0.08, 1.0), roughness=0.85)
    mat_moss = create_pbr_mat("T_Musgo_Foliage", (0.18, 0.45, 0.15, 1.0), roughness=0.7)
    mat_core = create_pbr_mat("T_Nucleo_Corrupto", (1.0, 0.25, 0.05, 1.0), roughness=0.1, emission=(1.0, 0.25, 0.05, 1.0), emission_val=18.0)
    mat_stone = create_pbr_mat("T_Piedra_Runa", (0.35, 0.35, 0.38, 1.0), roughness=0.7)

    # Torso masivo de tronco retorcido (4 x 3 x 6m)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=1.8, depth=5.5, location=(0, 0, 4.5))
    torso = bpy.context.active_object; torso.name = "Treant_Torso"; torso.data.materials.append(mat_bark); col.objects.link(torso)
    
    # Núcleo de corazón ardiente en el pecho
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.65, location=(0, -1.5, 4.8))
    core = bpy.context.active_object; core.name = "Treant_Corazon_Core"; core.data.materials.append(mat_core); col.objects.link(core)

    # Cabeza con corona de ramas y cuernos de madera
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=1.2, depth=2.0, location=(0, 0, 7.8))
    head = bpy.context.active_object; head.name = "Treant_Cabeza"; head.data.materials.append(mat_bark); col.objects.link(head)
    
    # Ojos brillantes
    for ex in (-0.45, 0.45):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.18, location=(ex, -1.1, 7.8))
        eye = bpy.context.active_object; eye.name = f"Treant_Ojo_{ex}"; eye.data.materials.append(mat_core); col.objects.link(eye)
        
    # Corona de follaje en la cabeza
    for fi in range(5):
        fang = fi * (math.pi / 2.5)
        fx = math.cos(fang) * 1.4
        fy = math.sin(fang) * 1.4
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.7, location=(fx, fy, 9.0))
        crown = bpy.context.active_object; crown.name = f"Treant_Corona_{fi}"; crown.data.materials.append(mat_moss); col.objects.link(crown)

    # Brazos titánicos con garras de madera
    for side in (-1, 1):
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.6, depth=4.5, location=(side * 2.8, -0.4, 4.5), rotation=(0.3, side * 0.4, 0))
        arm = bpy.context.active_object; arm.name = f"Treant_Brazo_{'L' if side<0 else 'R'}"; arm.data.materials.append(mat_bark); col.objects.link(arm)

    # Piernas / Raíces de soporte en el suelo
    for ri in range(4):
        rang = ri * (math.pi / 2) + math.pi/4
        rx = math.cos(rang) * 1.8
        ry = math.sin(rang) * 1.8
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.55, depth=3.0, location=(rx, ry, 1.5), rotation=(0.2 * ry, -0.2 * rx, 0))
        leg = bpy.context.active_object; leg.name = f"Treant_Raiz_Leg_{ri}"; leg.data.materials.append(mat_bark); col.objects.link(leg)

    # Cofre del Tesoro Ancestral
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -6.0, 0.6))
    chest = bpy.context.active_object; chest.name = "Cofre_Ancestral"; chest.scale = (2.2, 1.4, 1.2); chest.data.materials.append(mat_stone); col.objects.link(chest)

    bpy.ops.wm.save_as_mainfile(filepath="c:/Users/Antonio Garcia/Downloads/blender/Dungeon_Bosque_Assets.blend")
    bpy.ops.export_scene.fbx(filepath="c:/Users/Antonio Garcia/Downloads/blender/Dungeon_Bosque_Assets.fbx")
    print("Assets del Bosque de los Susurros exportados exitosamente.")

if __name__ == "__main__":
    build_treant_boss()
