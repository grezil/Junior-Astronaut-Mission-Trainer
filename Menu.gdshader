shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Độ cong màn hình (2.0 đến 3.0 là tối ưu nhất)
uniform float warp_amount : hint_range(0.0, 5.0) = 2.2;

// Tự động phóng to nhẹ để bù trừ phần cong, không bị hở viền (1.05 đến 1.1)
uniform float scale_compensation : hint_range(1.0, 1.2) = 1.07;

// Độ đậm nhạt sọc quét ngang
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.22;

// Bo tối 4 góc vừa phải
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.35;

// Thuật toán uốn cong có bù trừ kích thước để luôn khít viền
vec2 warp(vec2 uv) {
	// Dịch tâm về giữa (0.5, 0.5) và phóng to nhẹ để bù viền
	vec2 delta = (uv - 0.5) / scale_compensation;
	float delta_2 = dot(delta, delta);
	float delta_4 = delta_2 * delta_2;
	float delta_offset = delta_2 * (warp_amount * 0.04) + delta_4 * (warp_amount * 0.006);
	return 0.5 + delta * (1.0 + delta_offset);
}

void fragment() {
	// 1. Áp dụng biến dạng cong lồi cho UV
	vec2 warped_uv = warp(SCREEN_UV);
	
	// 2. Lấy hình ảnh màn hình game (Không discard để tránh hở viền đen ngoài rìa)
	vec2 clamped_uv = clamp(warped_uv, 0.001, 0.999);
	vec4 color = texture(screen_texture, clamped_uv);
	
	// 3. Đường sọc quét Scanline mềm mại
	float screen_height = vec2(textureSize(screen_texture, 0)).y;
	float scanline = sin(clamped_uv.y * screen_height * 3.14159 * 1.5);
	scanline = (1.0 - scanline_intensity) + (scanline * 0.12);
	color.rgb *= scanline;
	
	// 4. Hiệu ứng tối 4 góc (Vignette) bo tròn tự nhiên không bị lỗi cắt góc
	vec2 vign_uv = clamped_uv * (1.0 - clamped_uv.yx);
	float vignette = vign_uv.x * vign_uv.y * 15.0;
	vignette = clamp(pow(vignette, 0.22), 0.0, 1.0);
	color.rgb *= mix(1.0, vignette, vignette_intensity);
	
	COLOR = color;
}