"""Generate a square app icon for Transfarmation that includes all text elements."""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math
import os

SIZE = 1024  # App icon size
CENTER = SIZE // 2

# Colors
WHITE = (255, 255, 255)
DARK_GREEN = (56, 118, 29)
MID_GREEN = (76, 153, 0)
LIGHT_GREEN = (106, 168, 45)
LEAF_GREEN = (85, 139, 47)
DARK_GRAY = (51, 51, 51)
ARROW_DARK = (55, 55, 55)

img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Background: rounded square with white
margin = 20
draw.rounded_rectangle(
    [margin, margin, SIZE - margin, SIZE - margin],
    radius=180,
    fill=WHITE,
    outline=None,
)

# Subtle green gradient tint at the bottom
grad_img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
grad_draw = ImageDraw.Draw(grad_img)
for y in range(SIZE * 3 // 4, SIZE - margin):
    alpha = int(18 * (y - SIZE * 3 // 4) / (SIZE // 4))
    grad_draw.line([(margin, y), (SIZE - margin, y)], fill=(80, 160, 50, alpha))
img = Image.alpha_composite(img, grad_img)
draw = ImageDraw.Draw(img)

# === Layout: center everything vertically ===
# Content spans from ~top_pad to ~bottom_pad
# Elements: leaves+stem (~200px), recycling oval (~240px), gap(30), title(~120px), gap(15), tagline(~50px)
# Total content height ~ 200+240+30+120+15+50 = 655
# Vertical start: (1024 - 655) / 2 ≈ 185
v_start = 175

# === Draw the plant/recycling symbol ===
cx = CENTER
oval_cy = v_start + 330  # Center of recycling oval

# The recycling oval
oval_rx, oval_ry = 105, 130
oval_cx = cx

# Draw the dark (left) curved arrow
arc_bbox = [oval_cx - oval_rx, oval_cy - oval_ry, oval_cx + oval_rx, oval_cy + oval_ry]
draw.arc(arc_bbox, 155, 360, fill=ARROW_DARK, width=26)

# Draw the green (right) curved arrow  
draw.arc(arc_bbox, -15, 175, fill=MID_GREEN, width=26)

# Dark arrowhead (pointing down-left) at bottom-left
ah_x, ah_y = oval_cx - oval_rx + 18, oval_cy + 30
points_dark = [
    (ah_x, ah_y),
    (ah_x - 35, ah_y - 38),
    (ah_x + 12, ah_y - 44),
]
draw.polygon(points_dark, fill=ARROW_DARK)

# Green arrowhead (pointing up-right) at top-right
ah_x2, ah_y2 = oval_cx + oval_rx - 18, oval_cy - 30
points_green = [
    (ah_x2, ah_y2),
    (ah_x2 + 35, ah_y2 + 38),
    (ah_x2 - 12, ah_y2 + 44),
]
draw.polygon(points_green, fill=MID_GREEN)

# === Draw the stem and leaves ===
stem_base_y = oval_cy - oval_ry + 12
stem_top_y = v_start + 30

# Main stem
for i in range(-4, 5):
    draw.line([(cx + i, stem_base_y), (cx - 12 + i, stem_top_y + 50)], fill=DARK_GREEN, width=2)

# Left leaf (larger, pointing up-left)
leaf_cx, leaf_cy = cx - 60, stem_top_y + 35
leaf_points = []
for angle in range(0, 360, 3):
    rad = math.radians(angle)
    r = 72
    x = r * math.cos(rad) * 0.4
    y = r * math.sin(rad)
    rot = math.radians(-50)
    rx = x * math.cos(rot) - y * math.sin(rot)
    ry = x * math.sin(rot) + y * math.cos(rot)
    leaf_points.append((leaf_cx + rx, leaf_cy + ry))
draw.polygon(leaf_points, fill=LEAF_GREEN)
# Leaf vein (white highlight)
draw.line([(leaf_cx + 18, leaf_cy + 28), (leaf_cx - 18, leaf_cy - 35)], fill=(255, 255, 255, 160), width=3)

# Right leaf (smaller, pointing up-right)
leaf2_cx, leaf2_cy = cx + 55, stem_top_y + 60
leaf2_points = []
for angle in range(0, 360, 3):
    rad = math.radians(angle)
    r = 55
    x = r * math.cos(rad) * 0.4
    y = r * math.sin(rad)
    rot = math.radians(50)
    rx = x * math.cos(rot) - y * math.sin(rot)
    ry = x * math.sin(rot) + y * math.cos(rot)
    leaf2_points.append((leaf2_cx + rx, leaf2_cy + ry))
draw.polygon(leaf2_points, fill=LEAF_GREEN)
# Leaf vein
draw.line([(leaf2_cx - 12, leaf2_cy + 22), (leaf2_cx + 14, leaf2_cy - 25)], fill=(255, 255, 255, 160), width=3)

# === Text: "Transfarmation" ===
def find_font(size, bold=False):
    font_paths = [
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
        "C:/Windows/Fonts/calibrib.ttf" if bold else "C:/Windows/Fonts/calibri.ttf",
        "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/verdana.ttf",
    ]
    for fp in font_paths:
        if os.path.exists(fp):
            return ImageFont.truetype(fp, size)
    return ImageFont.load_default()

# Draw "Trans" in dark gray and "farmation" in green
title_y = oval_cy + oval_ry + 55
font_title = find_font(108, bold=True)

trans_text = "Trans"
farm_text = "farmation"
trans_bbox = draw.textbbox((0, 0), trans_text, font=font_title)
farm_bbox = draw.textbbox((0, 0), farm_text, font=font_title)
total_w = (trans_bbox[2] - trans_bbox[0]) + (farm_bbox[2] - farm_bbox[0])

start_x = (SIZE - total_w) // 2
draw.text((start_x, title_y), trans_text, fill=DARK_GRAY, font=font_title)
start_x += (trans_bbox[2] - trans_bbox[0])
draw.text((start_x, title_y), farm_text, fill=MID_GREEN, font=font_title)

# === Tagline ===
tagline = '" People busy transforming their farming activities "'
font_tag = find_font(40, bold=False)
tag_bbox = draw.textbbox((0, 0), tagline, font=font_tag)
tag_w = tag_bbox[2] - tag_bbox[0]
tag_x = (SIZE - tag_w) // 2
tag_y = title_y + 130

draw.text((tag_x, tag_y), tagline, fill=(110, 110, 110), font=font_tag)

# Add a subtle border
draw.rounded_rectangle(
    [margin, margin, SIZE - margin, SIZE - margin],
    radius=180,
    fill=None,
    outline=(190, 215, 190),
    width=3,
)

# Save
output_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets", "transfarmation_icon.png")
img.save(output_path, "PNG")
print(f"Icon saved to: {output_path}")

# Also save a smaller version
img_small = img.resize((512, 512), Image.LANCZOS)
output_small = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets", "transfarmation_icon_512.png")
img_small.save(output_small, "PNG")
print(f"Small icon saved to: {output_small}")
