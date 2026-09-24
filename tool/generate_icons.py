import math
import os
import struct
import zlib

def create_png(width, height, get_pixel):
    # Generates a PNG with RGBA channels
    raw_data = bytearray()
    for y in range(height):
        raw_data.append(0)  # Filter type 0 (None)
        for x in range(width):
            r, g, b, a = get_pixel(x, y, width, height)
            raw_data.extend([r, g, b, a])
    
    compressed = zlib.compress(bytes(raw_data), 9)
    
    png = bytearray(b'\x89PNG\r\n\x1a\n')
    
    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    png.extend(struct.pack('>I', len(ihdr_data)))
    png.extend(b'IHDR')
    png.extend(ihdr_data)
    png.extend(struct.pack('>I', zlib.crc32(b'IHDR' + ihdr_data) & 0xffffffff))
    
    # IDAT chunk
    png.extend(struct.pack('>I', len(compressed)))
    png.extend(b'IDAT')
    png.extend(compressed)
    png.extend(struct.pack('>I', zlib.crc32(b'IDAT' + compressed) & 0xffffffff))
    
    # IEND chunk
    png.extend(struct.pack('>I', 0))
    png.extend(b'IEND')
    png.extend(struct.pack('>I', zlib.crc32(b'IEND') & 0xffffffff))
    
    return bytes(png)

def point_in_triangle(pt, v1, v2, v3):
    def sign(p1, p2, p3):
        return (p1[0] - p3[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p3[1])
    d1 = sign(pt, v1, v2)
    d2 = sign(pt, v2, v3)
    d3 = sign(pt, v3, v1)
    has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0)
    has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0)
    return not (has_neg and has_pos)

def point_in_quad(pt, p1, p2, p3, p4):
    return point_in_triangle(pt, p1, p2, p3) or point_in_triangle(pt, p1, p3, p4)

def get_logo_pixel(x, y, w, h):
    # Normalized coordinates -1.0 to 1.0
    nx = (x / (w - 1)) * 2.0 - 1.0
    ny = (y / (h - 1)) * 2.0 - 1.0
    
    dist = math.sqrt(nx * nx + ny * ny)
    
    # Outer circular boundary (circle radius 0.96)
    if dist > 0.98:
        return (0, 0, 0, 0) # Transparent outside
    
    # Antialiasing edge
    alpha = 255
    if dist > 0.95:
        alpha = int(255 * (0.98 - dist) / 0.03)
        alpha = max(0, min(255, alpha))
        
    # Circular Background with Radial Deep Navy/Midnight Gradient
    grad_val = min(1.0, dist)
    # Center dark navy (#101B38) to edge deep black-blue (#040914)
    bg_r = int(16 * (1 - grad_val * 0.7))
    bg_g = int(27 * (1 - grad_val * 0.7))
    bg_b = int(56 * (1 - grad_val * 0.6))
    
    # Outer Cyan glowing border ring
    if 0.91 <= dist <= 0.96:
        ring_glow = 1.0 - abs(dist - 0.935) / 0.025
        ring_r = int(0 * ring_glow + bg_r * (1 - ring_glow))
        ring_g = int(180 * ring_glow + bg_g * (1 - ring_glow))
        ring_b = int(255 * ring_glow + bg_b * (1 - ring_glow))
        return (ring_r, ring_g, ring_b, alpha)

    # Coordinate system for logo elements in unit box [0, 1]
    lx = x / (w - 1)
    ly = y / (h - 1)
    pt = (lx, ly)
    
    # 1. Central Road / Highway (Triangle)
    road_top = (0.5, 0.22)
    road_bl = (0.24, 0.88)
    road_br = (0.76, 0.88)
    
    # 2. Left Wing Quad
    lw1 = (0.06, 0.22)
    lw2 = (0.42, 0.22)
    lw3 = (0.23, 0.88)
    lw4 = (0.05, 0.88)
    
    # 3. Right Wing Quad
    rw1 = (0.58, 0.22)
    rw2 = (0.94, 0.22)
    rw3 = (0.95, 0.88)
    rw4 = (0.77, 0.88)
    
    # Wing Gradient (Electric Cyan #00D2FF to Bold Blue #0066FF to Royal Blue #1D4ED8)
    wing_t = (ly - 0.22) / (0.88 - 0.22)
    wing_t = max(0.0, min(1.0, wing_t))
    wing_r = int(0 * (1 - wing_t) + 29 * wing_t)
    wing_g = int(210 * (1 - wing_t) + 78 * wing_t)
    wing_b = int(255 * (1 - wing_t) + 216 * wing_t)
    
    # Central Highway Dashes
    if 0.47 <= lx <= 0.53:
        # Dash 1
        if 0.36 <= ly <= 0.46:
            return (255, 255, 255, alpha)
        # Dash 2
        if 0.54 <= ly <= 0.66:
            return (255, 255, 255, alpha)
        # Dash 3
        if 0.74 <= ly <= 0.86:
            return (255, 255, 255, alpha)
            
    # Check if inside Road
    if point_in_triangle(pt, road_top, road_bl, road_br):
        # Dark highway surface (#0F172A to #1E293B)
        road_r = int(15 + 15 * wing_t)
        road_g = int(23 + 18 * wing_t)
        road_b = int(42 + 20 * wing_t)
        return (road_r, road_g, road_b, alpha)

    # Check Left Wing
    if point_in_quad(pt, lw1, lw2, lw3, lw4):
        # Cutout middle triangle for stylized Y look
        cut_top = (0.28, 0.44)
        cut_bl = (0.16, 0.88)
        cut_br = (0.34, 0.88)
        if not point_in_triangle(pt, cut_top, cut_bl, cut_br):
            return (wing_r, wing_g, wing_b, alpha)

    # Check Right Wing
    if point_in_quad(pt, rw1, rw2, rw3, rw4):
        cut_top = (0.72, 0.44)
        cut_bl = (0.66, 0.88)
        cut_br = (0.84, 0.88)
        if not point_in_triangle(pt, cut_top, cut_bl, cut_br):
            return (wing_r, wing_g, wing_b, alpha)
            
    return (bg_r, bg_g, bg_b, alpha)

def main():
    sizes = {
        'assets/icon/app_icon.png': 512,
        'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
        'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
        'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
        'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
        'android/app/src/main/res/mipmap-mdpi/ic_launcher_round.png': 48,
        'android/app/src/main/res/mipmap-hdpi/ic_launcher_round.png': 72,
        'android/app/src/main/res/mipmap-xhdpi/ic_launcher_round.png': 96,
        'android/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png': 144,
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png': 192,
    }
    
    for filepath, size in sizes.items():
        print(f"Generating {filepath} ({size}x{size})...")
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        png_bytes = create_png(size, size, get_logo_pixel)
        with open(filepath, 'wb') as f:
            f.write(png_bytes)
    print("All icons successfully generated!")

if __name__ == '__main__':
    main()
