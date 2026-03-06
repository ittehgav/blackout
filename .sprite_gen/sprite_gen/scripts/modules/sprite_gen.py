from PIL import Image
import bpy
import math
from datetime import datetime
import os

## leaving this as a global here since all sheets are gonna be overlapping visualizations of the same objects
## (at least for all fighter sprites)
frame_size = 128

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

def rotate_around_y(obj, pivot):
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

def generate_frames(collection, total_frames, steps, output_path, pivot, to_rotate, frame_offset = 0):
    for frame in range(total_frames):
        bpy.context.scene.frame_set((frame + frame_offset) * 5)
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
            
            for obj in to_rotate:
                rotate_around_y(obj, pivot)

def generate_spritesheet(png_files, total_frames, dir="sheets"):
    height = frame_size * total_frames
    width = frame_size * 8

    images = [Image.open(bpy.path.abspath(f)) for f in png_files]
    # Create a new blank image
    combined = Image.new("RGBA", (width, height))
    # Paste each image side by side
    x_offset = 0
    y_offset = 0

    i = 0;
    for img in images:
        combined.paste(img, (x_offset, y_offset))
        x_offset += img.width
        
        i += 1; 
        if i % 8 == 0:
            y_offset += frame_size
            x_offset -= width

    # Save result

    filename = get_unique_name("combined", dir);


    time_string = datetime.now().strftime(" %H %M %d-%m")
    filename = dir + "/" + filename + time_string + ".png"

    combined.save(filename)
    print(f"Combined image saved as "+filename)