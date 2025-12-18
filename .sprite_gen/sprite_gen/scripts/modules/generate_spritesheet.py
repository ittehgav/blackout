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

total_frames = 5



top_light = bpy.data.objects.get("top_light");
bottom_light = bpy.data.objects.get("bottom_light")
camera = bpy.context.scene.camera
## will raise error on its own if one isnt found???
to_rotate = [top_light, bottom_light, camera]


collection = bpy.data.collections.get("all")

# --- Get camera ---

if camera is None:
    raise Exception("No active camera in the scene.")

sprite_gen.generate_frames(collection, total_frames, steps, output_path, pivot, to_rotate);

png_files = ["//renders/"+f for f in os.listdir(bpy.path.abspath("//renders")) if f.lower().endswith('.png')] 

sprite_gen.generate_spritesheet(png_files, total_frames);

print("✅ Finished rendering 360° around Y-axis.")


