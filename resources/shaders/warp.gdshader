shader_type canvas_item;

uniform float strength : hint_range(-1.0, 1.0) = 0.5;
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // UVs for the screen (maps this rect to the screen content under it)
    vec2 uv = SCREEN_UV;

    // Distance from the vertical center of the effect region
    float dist_from_center = UV.y - 0.5;

    // Warp horizontally
    uv.y += dist_from_center * strength;

    // Sample the screen with the warped UVs
    COLOR = texture(SCREEN_TEXTURE, uv);
}