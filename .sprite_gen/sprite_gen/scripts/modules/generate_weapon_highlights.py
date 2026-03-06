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
camera = bpy.context.scene.camera
to_rotate = [top_light, camera]

collection = bpy.data.collections.get("all")
frame_offset = 3

# --- Get camera ---

if camera is None:
    raise Exception("No active camera in the scene.")


to_hide = []
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

            # Replace materials
            if obj.material_slots:
                for i in range(len(obj.material_slots)):
                    obj.material_slots[i].material = mat
            else:
                obj.data.materials.clear()
                obj.data.materials.append(mat)
        else:
            # Hide objects that don't match
            obj.animation_data.action = None;
            obj.hide_set(True)
            obj.hide_render = True;
            

        



## just saves before replacing the materials then reloads the file
## loses the undo history?
bpy.ops.wm.save_mainfile()
apply_prefix_material("weapon_", "all", "weapon_blur")


for frame in range(total_frames):
        bpy.context.scene.frame_set((frame + frame_offset) * 5)
        print((frame + frame_offset) * 5)
        
        for i in range(steps):
            for obj in collection.objects:
                if obj.animation_data and obj.animation_data.action:
                    obj.update_tag()
            # Set file path for render
            file_name = f"{output_path}"
            if frame < 10:
                file_name += "0"
            file_name += f"{int(frame)}-{int(i)}.png"
            bpy.context.scene.render.filepath = "//weapon_renders/"+file_name

            # Render still image
            bpy.ops.render.render(write_still=True)

            # Rotate camera for next frame
            
            for obj in to_rotate:
                sprite_gen.rotate_around_y(obj, pivot)


png_files = ["//weapon_renders/"+f for f in os.listdir(bpy.path.abspath("//weapon_renders")) if f.lower().endswith('.png') and not f.startswith("combined")] 
sprite_gen.generate_spritesheet(png_files, total_frames, "weapon_sheets")




