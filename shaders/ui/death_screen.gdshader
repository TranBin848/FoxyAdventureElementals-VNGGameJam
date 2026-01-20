shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
// Note: 'lod' here is just used as a "strength" for the blur radius, not actual hardware LOD.
uniform float lod: hint_range(0.0, 5.0) = 0.0;

void fragment() {
    vec4 color = vec4(0.0);
    // Simple 9-tap blur (very cheap, good for low strength)
    float radius = lod * SCREEN_PIXEL_SIZE.x;
    
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-radius, -radius));
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, -radius));
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(radius, -radius));
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-radius, 0.0));
    color += texture(SCREEN_TEXTURE, SCREEN_UV); // Center
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(radius, 0.0));
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-radius, radius));
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, radius));
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(radius, radius));
    
    COLOR = color / 9.0;
}