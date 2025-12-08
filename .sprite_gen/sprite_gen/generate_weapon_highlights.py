from PIL import Image
import os

from datetime import datetime

import bpy
import math



# --- Settings ---
output_path = "//render_"  # "//" = current .blend file folder
steps = 8                 # 360 / 45 = 8
angle_step = 360 / steps  # degrees per step
pivot = (0, 0, 0)         # rotate around world origin

total_frames = 2

frame_size = 98

# Get total width and maximum height
total_width = frame_size * 8
max_height = frame_size * total_frames


top_light = bpy.data.objects.get("top_light");
bottom_light = bpy.data.objects.get("bottom_light")
camera = bpy.context.scene.camera

collection = bpy.data.collections.get("all")


# Global dictionary to store collection states for restoration
COLLECTION_STATES = {}

def apply_prefix_material(prefix, collection_name, material_name):
    global COLLECTION_STATES
    collection = bpy.data.collections.get(collection_name)
    if not collection:
        print(f"Collection '{collection_name}' not found.")
        return

    mat = bpy.data.materials.get(material_name)
    if not mat:
        print(f"Material '{material_name}' not found.")
        return

    # Save state
    prev_state = {}
    for obj in collection.objects:
        prev_state[obj.name] = {
            "hide_set": obj.hide_get(),
            "hide_viewport": obj.hide_viewport,
            "hide_render": obj.hide_render,
            "materials": [slot.material for slot in obj.material_slots]
        }

    COLLECTION_STATES[collection_name] = prev_state

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


def restore_collection_state(collection_name):
    global COLLECTION_STATES
    if collection_name not in COLLECTION_STATES:
        print(f"No stored state for collection '{collection_name}'.")
        return

    collection = bpy.data.collections.get(collection_name)
    if not collection:
        print(f"Collection '{collection_name}' not found.")
        return

    saved = COLLECTION_STATES.pop(collection_name)

    for obj in collection.objects:
        if obj.name not in saved:
            continue
        
        state = saved[obj.name]

        # Restore visibility
        obj.hide_set(state["hide_set"])
        obj.hide_viewport = state["hide_viewport"]
        obj.hide_render = state["hide_render"]

        # Restore material list
        obj.data.materials.clear()
        for mat in state["materials"]:
            obj.data.materials.append(mat)



# --- Get camera ---

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
    

apply_prefix_material("weapon_", "all", "weapon_blur")

for frame in range(total_frames):
    bpy.context.scene.frame_set((frame + 3) * 5)
    for i in range(steps):
        for obj in collection.objects:
            if obj.animation_data and obj.animation_data.action:
                obj.update_tag()
        print(frame, i)
        # Set file path for render
        file_name = f"{output_path}"
        if frame < 10:
            file_name += "0"
        file_name += f"{int(frame)}-{int(i)}.png"
        bpy.context.scene.render.filepath = "//weapon_renders/"+file_name

        # Render still image
        bpy.ops.render.render(write_still=True)

        # Rotate camera for next frame
        
        
        rotate_around_y(camera, pivot, angle_step)



png_files = ["//weapon_renders/"+f for f in os.listdir(bpy.path.abspath("//weapon_renders")) if f.lower().endswith('.png') and not f.startswith("combined")] 

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
images = [Image.open(bpy.path.abspath(f)) for f in png_files]



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
        y_offset += frame_size
        x_offset = 0 

# Save result
dir = "weapon_sheets"

filename = get_unique_name("combined", dir);


time_string = datetime.now().strftime(" %H %M %d-%m")
filename = dir + "/" + filename + time_string + ".png"

combined.save(filename)
print(f"Combined image saved as "+filename)
restore_collection_state("all")