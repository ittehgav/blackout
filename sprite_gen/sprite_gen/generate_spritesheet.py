import PIL
from PIL import Image
import os

from datetime import datetime

import bpy
import math


collection = bpy.data.collections.get("all")

def crop_center_64x64(image_path):
    # Open the image
    img = Image.open(bpy.path.abspath(image_path))
    width, height = img.size

    # Calculate the coordinates for the 64x64 center crop
    left = (width - 64) // 2
    top = (height - 64) // 2
    right = left + 64
    bottom = top + 64

    # Crop and return the result
    cropped_img = img.crop((left, top, right, bottom))
    return cropped_img

# --- Settings ---
output_path = "//render_"  # "//" = current .blend file folder
steps = 8                 # 360 / 45 = 8
angle_step = 360 / steps  # degrees per step
pivot = (0, 0, 0)         # rotate around world origin

# --- Get camera ---
camera = bpy.context.scene.camera
if camera is None:
    raise Exception("No active camera in the scene.")

# --- Function to rotate camera around Y-axis ---
def rotate_around_y(obj, pivot, angle_deg):
    from mathutils import Matrix, Vector
    angle_rad = math.radians(45)

    # Create rotation matrix around Y
    rot_mat = Matrix.Rotation(angle_rad, 4, 'Y')

    # Move to pivot, rotate, move back
    loc = Vector(obj.location) - Vector(pivot)
    loc = rot_mat @ loc
    obj.location = loc + Vector(pivot)

    # Rotate camera orientation
    obj.matrix_world = rot_mat @ obj.matrix_world

# --- Main loop ---

total_frames = 5

for frame in range(total_frames):
    bpy.context.scene.frame_set(frame * 5)
    for i in range(steps):
        for obj in collection.objects:
            if obj.animation_data and obj.animation_data.action:
                obj.update_tag()
        # Set file path for render
        file_name = f"{output_path}"
        if frame < 10:
            file_name += "0"
        file_name += f"{int(frame)}-{int(i)}.png"
        bpy.context.scene.render.filepath = "//renders/"+file_name

        # Render still image
        bpy.ops.render.render(write_still=True)

        # Rotate camera for next frame
        rotate_around_y(camera, pivot, angle_step)





print("✅ Finished rendering 360° around Y-axis.")

png_files = ["//renders/"+f for f in os.listdir(bpy.path.abspath("//renders")) if f.lower().endswith('.png') and not f.startswith("combined")] 
print(png_files)

def get_unique_name(base_name, directory="."):
    """
    Returns a unique filename (without extension or path).
    If a file starting with base_name exists, appends an incremented number.
    
    Example:
        get_unique_name("output") 
        -> "output" or "output_1", "output_2", etc.
    """
    name = base_name
    counter = 1

    existing_files = [
        os.path.splitext(f)[0]
        for f in os.listdir(directory)
        if os.path.isfile(os.path.join(directory, f))
    ]

    while any(f.startswith(name) for f in existing_files):
        name = f"{base_name}_{counter}"
        counter += 1

    return name


# Open all images
images = [crop_center_64x64(f) for f in png_files]


# Get total width and maximum height
total_width = 64*8
max_height = 64*total_frames

# Create a new blank image
combined = Image.new("RGBA", (total_width, max_height))

# Paste each image side by side
x_offset = 0
y_offset = 0

i = 0;
for img in images:
    combined.paste(img, (x_offset, y_offset))
    x_offset += img.width
    
    i += 1; 
    if i % 8 == 0:
        y_offset += 64
        x_offset -= total_width

# Save result
dir = "sheets"

filename = get_unique_name("combined", dir);


time_string = datetime.now().strftime(" %H %M %d-%m")
filename = dir + "/" + filename + time_string + ".png"

combined.save(filename)
print(f"Combined image saved as "+filename)