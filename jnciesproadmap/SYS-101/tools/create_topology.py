from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "topology" / "SYS-101_TOPOLOGY.png"
OUT.parent.mkdir(parents=True, exist_ok=True)
W, H = 1920, 1080
img = Image.new("RGB", (W, H), "#F5F8FC")
d = ImageDraw.Draw(img)

def font(size, bold=False):
    candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation2/LiberationSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/liberation2/LiberationSans-Regular.ttf",
    ]
    for p in candidates:
        if Path(p).exists(): return ImageFont.truetype(p, size)
    return ImageFont.load_default()

navy, blue, green, gray = "#102A43", "#1F6FB2", "#2F855A", "#52606D"
d.rectangle((0,0,W,150), fill=navy)
d.text((70,38), "SYS-101 | Initial System Settings", font=font(48,True), fill="white")
d.text((72,100), "Secure management baseline: DNS, NTP, RADIUS, Syslog, and configuration archival", font=font(24), fill="#D9EAF7")

bus_y=510
d.rounded_rectangle((180,bus_y-55,1740,bus_y+55), radius=26, fill="#D9EAF7", outline=blue, width=5)
d.text((605,bus_y-20), "Management Network 172.31.1.0/24", font=font(28,True), fill=navy)
d.text((680,bus_y+18), "Addressing injected by Containerlab", font=font(20), fill=gray)

nodes=[("R1","172.31.1.11",250), ("R2","172.31.1.12",620), ("R3","172.31.1.13",990), ("R4","172.31.1.14",1360)]
for name,ip,x in nodes:
    d.line((x+120,350,x+120,bus_y-55), fill=blue, width=6)
    d.rounded_rectangle((x,220,x+240,350),radius=22,fill="white",outline=blue,width=5)
    d.text((x+85,245),name,font=font(34,True),fill=navy)
    d.text((x+48,300),ip,font=font(22),fill=gray)

sx,sy=720,700
d.line((960,bus_y+55,960,sy),fill=green,width=8)
d.rounded_rectangle((sx,sy,sx+480,sy+220),radius=28,fill="#E6FFFA",outline=green,width=6)
d.text((sx+205,sy+22),"S1",font=font(38,True),fill=green)
d.text((sx+135,sy+72),"172.31.1.100",font=font(26,True),fill=navy)
d.text((sx+60,sy+125),"DNS  |  NTP  |  RADIUS",font=font(23),fill=gray)
d.text((sx+70,sy+165),"Syslog  |  SCP Archive",font=font(23),fill=gray)

d.text((70,995),"Containerlab prefix: empty  |  vJunos-router 25.4R1.12  |  Services base: network-multitool",font=font(21),fill=gray)
img.save(OUT, quality=95)
print(OUT)
