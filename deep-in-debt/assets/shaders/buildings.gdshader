shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0667, 0.0745, 0.0784, 1.0);
uniform float outline_size = 1.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    vec2 pixel = TEXTURE_PIXEL_SIZE * outline_size;

    float surrounding_alpha = 0.0;

    // 8 surrounding pixels, including corners
    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV + vec2(-pixel.x, -pixel.y)).a);

    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV + vec2(0.0, -pixel.y)).a);

    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV + vec2(pixel.x, -pixel.y)).a);

    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV + vec2(-pixel.x, 0.0)).a);

    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV + vec2(pixel.x, 0.0)).a);

    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV + vec2(-pixel.x, pixel.y)).a);

    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV + vec2(0.0, pixel.y)).a);

    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV + vec2(pixel.x, pixel.y)).a);

    if (tex_color.a > 0.0) {
        // Original sprite
        COLOR = tex_color;
    } else if (surrounding_alpha > 0.0) {
        // Outline
        COLOR = vec4(outline_color.rgb, surrounding_alpha * outline_color.a);
    } else {
        // Transparent
        COLOR = vec4(0.0);
    }
}