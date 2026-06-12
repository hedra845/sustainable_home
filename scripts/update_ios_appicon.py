from pathlib import Path
from PIL import Image

src = Path("assets/logo_sustainable.png")
dst = Path("ios/Runner/Assets.xcassets/AppIcon.appiconset")
if not src.exists():
    raise FileNotFoundError(f"Source logo not found: {src}")
if not dst.exists():
    raise FileNotFoundError(f"AppIcon asset folder not found: {dst}")

sizes = {
    "Icon-App-20x20@1x.png": (20, 20),
    "Icon-App-20x20@2x.png": (40, 40),
    "Icon-App-20x20@3x.png": (60, 60),
    "Icon-App-29x29@1x.png": (29, 29),
    "Icon-App-29x29@2x.png": (58, 58),
    "Icon-App-29x29@3x.png": (87, 87),
    "Icon-App-40x40@1x.png": (40, 40),
    "Icon-App-40x40@2x.png": (80, 80),
    "Icon-App-40x40@3x.png": (120, 120),
    "Icon-App-50x50@1x.png": (50, 50),
    "Icon-App-50x50@2x.png": (100, 100),
    "Icon-App-57x57@1x.png": (57, 57),
    "Icon-App-57x57@2x.png": (114, 114),
    "Icon-App-60x60@2x.png": (120, 120),
    "Icon-App-60x60@3x.png": (180, 180),
    "Icon-App-72x72@1x.png": (72, 72),
    "Icon-App-72x72@2x.png": (144, 144),
    "Icon-App-76x76@1x.png": (76, 76),
    "Icon-App-76x76@2x.png": (152, 152),
    "Icon-App-83.5x83.5@2x.png": (167, 167),
    "Icon-App-1024x1024@1x.png": (1024, 1024),
}

with Image.open(src) as img:
    img = img.convert("RGBA")
    for filename, size in sizes.items():
        out_path = dst / filename
        resized = img.resize(size, Image.LANCZOS)
        resized.save(out_path)
        print(f"wrote {out_path} {size}")
