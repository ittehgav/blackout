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



camera_root = bpy.data.objects.get("camera_root")


collection = bpy.data.collections.get("all")

# --- Get camera ---



sprite_gen.generate_frames(collection, total_frames, steps, output_path, pivot, camera_root);

png_files = ["//renders/"+f for f in os.listdir(bpy.path.abspath("//renders")) if f.lower().endswith('.png')] 

sprite_gen.generate_spritesheet(png_files, total_frames);

print("✅ Finished rendering 360° around Y-axis.")


sample_files = ["render_00-3.png", "render_01-3.png", "render_02-3.png"]
sample_images = [Image.open(os.path.join("renders", f)) for f in sample_files]
frame_durations = [133, 233, 284]

sample_path = "sample.gif"
sample_images[0].save(
    sample_path,
    save_all=True,
    append_images=sample_images[1:],
    duration = frame_durations,
    loop=0,
    disposal = 2
)