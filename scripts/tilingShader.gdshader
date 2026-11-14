shader_type canvas_item;

uniform vec2 tile_count = vec2(10.0, 10.0);

void fragment() {
    COLOR = texture(TEXTURE, UV * tile_count);
}
