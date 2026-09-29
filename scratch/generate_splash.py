import os
from PIL import Image

app_icon_path = r'c:\Users\sadik\SIH-26165\assets\images\app_icon.png'
res_dir = r'c:\Users\sadik\SIH-26165\android\app\src\main\res'

img = Image.open(app_icon_path).convert("RGBA")
w, h = img.size
print(f"Original app_icon.png size: {w}x{h}")

# Canvas 512x512 with logo centered at ~300x300 (58% of canvas for Android 12 safe area)
def create_padded_splash(target_canvas_size, logo_scale_ratio=0.60):
    canvas = Image.new("RGBA", (target_canvas_size, target_canvas_size), (247, 248, 250, 0)) # transparent or RGBA
    logo_size = int(target_canvas_size * logo_scale_ratio)
    resized_logo = img.resize((logo_size, logo_size), Image.Resampling.LANCZOS)
    
    offset = (target_canvas_size - logo_size) // 2
    canvas.paste(resized_logo, (offset, offset), resized_logo)
    return canvas

# 1. Generate 512x512 splash_logo for drawable-nodpi and drawable
splash_512 = create_padded_splash(512, logo_scale_ratio=0.60)
os.makedirs(os.path.join(res_dir, 'drawable-nodpi'), exist_ok=True)
os.makedirs(os.path.join(res_dir, 'drawable'), exist_ok=True)

splash_512.save(os.path.join(res_dir, 'drawable-nodpi', 'splash_logo.png'), 'PNG')
splash_512.save(os.path.join(res_dir, 'drawable', 'splash_logo.png'), 'PNG')
print("Saved 512x512 splash_logo.png to drawable & drawable-nodpi")

# 2. Generate density-specific splash icons for mipmaps
densities = {
    'mipmap-mdpi': 108,
    'mipmap-hdpi': 162,
    'mipmap-xhdpi': 216,
    'mipmap-xxhdpi': 324,
    'mipmap-xxxhdpi': 432
}

for folder, size in densities.items():
    folder_path = os.path.join(res_dir, folder)
    os.makedirs(folder_path, exist_ok=True)
    splash_icon = create_padded_splash(size, logo_scale_ratio=0.60)
    splash_icon.save(os.path.join(folder_path, 'splash_logo.png'), 'PNG')
    print(f"Saved {size}x{size} splash_logo.png to {folder}")

print("All splash logos generated successfully!")
