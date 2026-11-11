"""Original synthesized composition/recordings. No downloaded samples or melodies.
Rebuild with Python stdlib + ffmpeg. Output mono Vorbis at 22050 Hz.
"""
import math,random,wave,struct,subprocess,tempfile,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[1];RATE=22050
rng=random.Random(92381)
def render(name,duration,voices):
 data=[0.0]*round(duration*RATE)
 for start,length,freq,amp,kind in voices:
  for i in range(min(round(length*RATE),len(data)-round(start*RATE))):
   t=i/RATE;env=min(t/.015,1)*min((length-t)/.05,1)
   if kind=='flute':v=math.sin(math.tau*freq*t+0.012*math.sin(math.tau*5*t))+.12*math.sin(math.tau*2*freq*t)
   elif kind=='drone':v=math.sin(math.tau*freq*t)+.2*math.sin(math.tau*freq*2*t)
   elif kind=='drum':v=math.sin(math.tau*(freq*t+20*(1-math.exp(-t*20))/20))*math.exp(-t*14)
   elif kind=='tick':v=rng.uniform(-1,1)*math.exp(-t*50)
   else:v=(math.sin(math.tau*freq*t)+.4*math.sin(math.tau*freq*2.71*t))*math.exp(-t*6)
   data[round(start*RATE)+i]+=amp*max(0,env)*v
 # Fade both loop ends to zero to prevent clicks, with no loud normalisation.
 fade=round(.025*RATE)
 for i in range(fade):data[i]*=i/fade;data[-1-i]*=i/fade
 peak=max(abs(v) for v in data);assert peak<.95,(name,peak)
 with tempfile.NamedTemporaryFile(suffix='.wav') as f:
  with wave.open(f.name,'wb') as w:
   w.setparams((1,2,RATE,0,'NONE','not compressed'));w.writeframes(b''.join(struct.pack('<h',round(v*32767)) for v in data))
  subprocess.run(['ffmpeg','-loglevel','error','-y','-i',f.name,'-c:a','libvorbis','-q:a','2','-map_metadata','-1',str(ROOT/'assets/audio'/f'{name}.ogg')],check=True)
 print(name,round(peak,3))
beat=.6;length=beat*32
v=[(0,length,130.8128,.035,'drone'),(0,length,196.0,.018,'drone')]
# Original compact phrase over a C/D/F/G/A pitch collection; no external arrangement.
notes=[0,2,7,5,9,7,2,5,7,9,5,2,0,5,2,0]
for i,n in enumerate(notes):
 v.append((i*beat*2+.08,beat*1.25,261.6256*2**(n/12),.075,'flute'))
for i in range(32):
 v.append((i*beat,.25,85 if i%4 in [0,3] else 160,.12 if i%4==0 else .075,'drum'))
 v.append((i*beat+.3,.07,0,.025,'tick'))
render('bazaar-loop',length,v)
render('coin',.32,[(0,.17,880,.13,'bell'),(.11,.20,1320,.1,'bell')])
render('rickshaw-bell',.8,[(0,.65,1180,.13,'bell'),(.17,.60,1560,.07,'bell')])
render('run-end',.8,[(0,.22,440,.10,'flute'),(.22,.22,349.23,.09,'flute'),(.44,.30,261.63,.08,'flute')])
# Abstract quiet market atmosphere: soft rustle and distant chimes, no sampled speech.
render('market-air',6,[(i*.25,.18,0,.006,'tick') for i in range(24)]+[(.6,.6,660,.015,'bell'),(3.1,.8,880,.012,'bell')])
