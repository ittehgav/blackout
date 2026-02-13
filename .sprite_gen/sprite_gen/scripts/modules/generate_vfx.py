from PIL import Image
import os

from datetime import datetime
import bpy
import sprite_gen


steps = 8                 # 360 / 45 = 8
angle_step = 360 / steps  # degrees per step
pivot = (0, 0, 0)         # rotate around world origin

camera = bpy.context.scene.camera

frames = 1
final_found = False
while not final_found:
    frame = bpy.data.objects.get("f"+str(frames))
    if not frame:
        final_found = True;
        frames -= 1;
    else:
        frame.hide_render = True
    frames += 1;

for f in range(frames - 1): ## becuase it starts at 0 and we just add the 1 back in
    if f:
        previous = bpy.data.objects.get("f" + str(f));
        previous.hide_render = True;
    
    frame_name = "f"+str(f + 1)
    current = bpy.data.objects.get(frame_name)
    current.hide_render = False


    for s in range(steps):
        bpy.context.scene.render.filepath = "//renders/"+frame_name +"_"+str(s)
        bpy.ops.render.render(write_still=True)

        sprite_gen.rotate_around_y(camera, pivot)

png_files = ["//renders/"+f for f in os.listdir(bpy.path.abspath("//renders")) if f.lower().endswith('.png')]
sprite_gen.generate_spritesheet(png_files, frames - 1)