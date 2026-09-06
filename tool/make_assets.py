"""Build original vector/shape brand assets and quiet synthesized audio."""
from pathlib import Path
from PIL import Image, ImageDraw
import math, wave, struct
root=Path(__file__).resolve().parents[1]
svg='''<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 300 300">
<rect width="300" height="300" rx="68" fill="#dcebdc"/>
<ellipse cx="87" cy="83" rx="24" ry="52" transform="rotate(-18 87 83)" fill="#f0bd85"/>
<ellipse cx="211" cy="83" rx="24" ry="52" transform="rotate(25 211 83)" fill="#f0bd85"/>
<ellipse cx="87" cy="79" rx="12" ry="32" transform="rotate(-18 87 79)" fill="#f3ba9a"/>
<ellipse cx="211" cy="79" rx="12" ry="32" transform="rotate(25 211 79)" fill="#f3ba9a"/>
<ellipse cx="150" cy="208" rx="81" ry="59" fill="#f0bd85"/>
<ellipse cx="150" cy="150" rx="106" ry="77" fill="#f0bd85"/>
<ellipse cx="93" cy="167" rx="17" ry="10" fill="#f3ba9a"/><ellipse cx="207" cy="167" rx="17" ry="10" fill="#f3ba9a"/>
<ellipse cx="115" cy="144" rx="9" ry="13" fill="#344a46"/><ellipse cx="185" cy="144" rx="9" ry="13" fill="#344a46"/>
<ellipse cx="112" cy="140" rx="3" ry="4" fill="white"/><ellipse cx="182" cy="140" rx="3" ry="4" fill="white"/>
<ellipse cx="150" cy="166" rx="10" ry="7" fill="#344a46"/><path d="M132 180 Q150 199 168 180" stroke="#344a46" stroke-width="4" fill="none" stroke-linecap="round"/>
<ellipse cx="151" cy="79" rx="7" ry="14" fill="#638a72"/><ellipse cx="162" cy="70" rx="7" ry="14" transform="rotate(45 162 70)" fill="#638a72"/>
<rect x="87" y="213" width="126" height="20" rx="10" fill="#638a72"/><rect x="181" y="220" width="21" height="40" rx="8" fill="#638a72"/>
</svg>'''
(root/'assets/brand/app-icon.svg').write_text(svg)
# Same shape identity, rendered without external image dependencies.
im=Image.new('RGB',(1200,1200),'#dcebdc');d=ImageDraw.Draw(im)
def ellipse(box,fill):d.ellipse(tuple(round(v*4) for v in box),fill=fill)
def rounded(box,r,fill):d.rounded_rectangle(tuple(round(v*4) for v in box),radius=r*4,fill=fill)
ellipse((62,26,109,135),'#f0bd85');ellipse((191,26,239,135),'#f0bd85')
ellipse((74,42,97,114),'#f3ba9a');ellipse((203,42,226,114),'#f3ba9a')
ellipse((69,149,231,267),'#f0bd85');ellipse((44,73,256,227),'#f0bd85')
ellipse((76,157,110,177),'#f3ba9a');ellipse((190,157,224,177),'#f3ba9a')
for x in [106,176]:ellipse((x,131,x+18,157),'#344a46');ellipse((x+3,134,x+9,142),'white')
ellipse((140,159,160,173),'#344a46');d.arc((132*4,172*4,168*4,193*4),0,180,fill='#344a46',width=16)
ellipse((144,65,158,93),'#638a72');ellipse((155,56,173,79),'#638a72')
rounded((87,213,213,233),10,'#638a72');rounded((181,220,202,260),8,'#638a72')
for size in [512,1024]:im.resize((size,size),Image.Resampling.LANCZOS).save(root/f'assets/brand/app-icon-{size}.png')
for density,size in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
 out=root/f'android/app/src/main/res/mipmap-{density}';out.mkdir(parents=True,exist_ok=True);im.resize((size,size),Image.Resampling.LANCZOS).save(out/'ic_launcher.png')
(root/'assets/brand/wordmark.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="250" viewBox="0 0 1000 250"><rect width="1000" height="250" rx="40" fill="#fff8ea"/><text x="500" y="145" text-anchor="middle" font-family="sans-serif" font-weight="800" font-size="98" fill="#344a46">Milo &amp; Me</text><text x="500" y="208" text-anchor="middle" font-family="sans-serif" font-size="25" fill="#638a72">Little adventures. A lovely friendship.</text></svg>''')
sr=22050
for name,duration in [('reward',1.2),('room',12)]:
 samples=[]
 for i in range(int(sr*duration)):
  t=i/sr
  if name=='reward':
   value=0
   for start,hz in [(0,523.25),(.18,659.25),(.36,783.99)]:
    age=t-start
    if age>=0:value+=math.sin(2*math.pi*hz*age)*math.exp(-age*5)*min(1,age*100)*.14
  else:
   # Integer periods, zero-valued ends and a fade: a quiet loop with no sharp edge.
   fade=min(1,t/1.5,(duration-t)/1.5)
   value=sum(math.sin(2*math.pi*hz*t)*.045 for hz in [220,275,330])*max(0,fade)
  samples.append(struct.pack('<h',round(max(-1,min(1,value))*32767)))
 with wave.open(str(root/f'assets/audio/{name}.wav'),'wb') as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(sr);w.writeframes(b''.join(samples))
print('Original icons, wordmark and two audio assets generated.')
