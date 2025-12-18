from PIL import Image
import os

from datetime import datetime

import bpy

import sprite_gen



# --- Settings ---
output_path = "//render_"  # "//" = current .blend file folder
steps = 8                 # 360 / 45 = 8
angle_step = 360 / steps  # degrees per step
pivot = (0, 0, 0)         # rotate around world origin

total_frames = 2


top_light = bpy.data.objects.get("top_light");
bottom_light = bpy.data.objects.get("bottom_light")
camera = bpy.context.scene.camera
to_rotate = [top_light, bottom_light, camera]

collection = bpy.data.collections.get("all")
frame_offset = 3

# --- Get camera ---

if camera is None:
    raise Exception("No active camera in the scene.")

def apply_prefix_material(prefix, collection_name, material_name):
    collection = bpy.data.collections.get(collection_name)
    if not collection:
        print(f"Collection '{collection_name}' not found.")
        return

    mat = bpy.data.materials.get(material_name)
    if not mat:
        print(f"Material '{material_name}' not found.")
        return




    # Apply modifications
    for obj in collection.objects:
        if obj.name.startswith(prefix):
            # Ensure visible
            obj.hide_set(False)
            obj.hide_viewport = False
            obj.hide_render = False

            # Replace materials
            if obj.material_slots:
                for i in range(len(obj.material_slots)):
                    obj.material_slots[i].material = mat
            else:
                obj.data.materials.clear()
                obj.data.materials.append(mat)
        else:
            # Hide objects that don't match
            obj.hide_set(True)
            obj.hide_viewport = True
            obj.hide_render = True





## just saves before replacing the materials then reloads the file
## loses the undo history?
bpy.ops.wm.save_mainfile()
apply_prefix_material("weapon_", "all", "weapon_blur")

sprite_gen.generate_frames(collection, total_frames, steps, output_path, pivot, to_rotate, frame_offset)

png_files = ["//weapon_renders/"+f for f in os.listdir(bpy.path.abspath("//weapon_renders")) if f.lower().endswith('.png') and not f.startswith("combined")] 
sprite_gen.generate_spritesheet(png_files, total_frames)




