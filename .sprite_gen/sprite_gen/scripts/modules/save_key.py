import bpy

# Change this to your collection's name
collection_name = "all"

# Get the collection
col = bpy.data.collections.get(collection_name)
if not col:
    print(f"Collection '{collection_name}' not found.")
else:
    # Get the current frame
    frame = bpy.context.scene.frame_current

    # Loop through all objects in the collection
    for obj in col.objects:
        if obj.type == 'MESH' or obj.type == "CURVE" or obj.type == 'VOLUME' or obj.type == 'EMPTY':
            # Insert keyframes for location, rotation, and scale
            obj.keyframe_insert(data_path="location", frame=frame)
            obj.keyframe_insert(data_path="rotation_euler", frame=frame)
            obj.keyframe_insert(data_path="scale", frame=frame)
            obj.keyframe_insert(data_path="hide_render", frame=frame)
    
    print(f"Saved transforms for all meshes in '{collection_name}' at frame {frame}.")
