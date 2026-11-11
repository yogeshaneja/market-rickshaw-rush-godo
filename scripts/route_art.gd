extends RefCounted
const FACADES = [preload("res://assets/art/facade-0.svg"),preload("res://assets/art/facade-1.svg"),preload("res://assets/art/facade-2.svg")]
const PALM = preload("res://assets/art/palm.svg")
const VENDOR = preload("res://assets/art/vendor.svg")
const SHOPPER = preload("res://assets/art/shopper.svg")
const KITE = preload("res://assets/art/kite.svg")
const SKINS = [preload("res://assets/art/rickshaw.svg"),preload("res://assets/art/rickshaw-indigo.svg"),preload("res://assets/art/rickshaw-coral.svg")]
const GROUND = [Color("d9aa7a"),Color("d9d6b1"),Color("93aeb2")]
const ROAD = [Color("514d50"),Color("3f5a62"),Color("344b5d")]

func street(canvas: Node2D, prefs: Dictionary, time: float, travel: float, font: Font) -> void:
 var t: float = 0.0 if prefs.reduce_effects else time
 if prefs.route == 1:
  # Glimpses of a coastal promenade at the outer edges, away from road markings.
  for edge in [0.0,467.0]:
   canvas.draw_rect(Rect2(edge,0,13,900),Color("5dafa9"))
   for i in range(10):
    var y := fposmod(float(i*100)+travel*0.6,1000.0)-40
    canvas.draw_arc(Vector2(edge+7,y),8,0.2,2.8,8,Color("cbe4d1"),1.5,true)
 for i in range(-1,4):
  var y := float(i*330)+fmod(travel,330.0)
  var x := 7.0 if posmod(i,2)==0 else 397.0
  if prefs.route == 1:
   canvas.draw_texture_rect(PALM,Rect2(x-1,y-40,78,130),false)
  # Every figure stays at least 8px outside the nearest road edge.
  var motion := sin(t*2.0+i)*2.0
  var who: Texture2D = VENDOR if posmod(i,2)==0 else SHOPPER
  canvas.draw_texture_rect(who,Rect2(x+17,y+120+motion,44,75),false)
  if who == VENDOR:
   # A small pouring-chai gesture near the counter; no pedestrian crosses a lane.
   canvas.draw_line(Vector2(x+47,y+154+motion),Vector2(x+57,y+151+motion+sin(t*2.0)*2),Color("c58d61"),4,true)
   canvas.draw_line(Vector2(x+57,y+152+motion),Vector2(x+55,y+163+motion),Color("f4dab0"),1.5,true)
  var signs := ["CHAI","FLOWERS","FRUIT"] if prefs.language == "en" else ["चाय","फूल","फल"]
  canvas.draw_rect(Rect2(x,y+90,72,20),Color("264552"))
  canvas.draw_string(font,Vector2(x+5,y+105),signs[posmod(i,3)],HORIZONTAL_ALIGNMENT_LEFT,64,11,Color("ffe1a0"))
  # Marigolds frame shop signs, never the road.
  for k in range(7):
   canvas.draw_circle(Vector2(x+5+k*10,y+88+sin(k*0.5)*3),3.2,Color("f2b438"))
 if prefs.route == 2:
  # Puddles are light pavement decoration, not ambiguous dark road obstacles.
  for i in range(6):
   var y := fposmod(float(i*170)+travel,1020.0)-50
   var x := 45.0 if i%2==0 else 434.0
   canvas.draw_set_transform(Vector2(x,y),0,Vector2(1,0.3))
   canvas.draw_circle(Vector2.ZERO,25,Color("7db8ca"))
   canvas.draw_arc(Vector2.ZERO,17,0,PI,12,Color("c2dde2"),2,true)
   canvas.draw_set_transform(Vector2.ZERO)
  if not prefs.reduce_effects:
   for i in range(28):
    var x := fposmod(float(i*71)+t*16,480.0)
    var y := fposmod(float(i*103)+t*260,900.0)
    canvas.draw_line(Vector2(x,y),Vector2(x-3,y+12),Color(0.78,0.89,0.94,0.24),1,true)
 # Lighting is composed below hazards, vehicles and UI for legibility.
 if prefs.evening:
  canvas.draw_rect(Rect2(0,0,480,900),Color(0.08,0.10,0.24,0.32))
  for side in [86.0,394.0]:
   for i in range(3):
    var y := fposmod(travel+float(i*360),1080.0)-60
    canvas.draw_line(Vector2(side,y),Vector2(side,y+60),Color("344351"),3,true)
    for radius in [24.0,16.0,8.0]: canvas.draw_circle(Vector2(side,y),radius,Color(1,0.79,0.40,0.07))
    canvas.draw_circle(Vector2(side,y),4,Color("ffe4a1"))
 else:
  canvas.draw_rect(Rect2(0,0,480,900),Color(1,0.72,0.40,0.055 if prefs.route==0 else 0.025))

func festival(canvas: Node2D, prefs: Dictionary, time: float, travel: float) -> void:
 var t: float = 0.0 if prefs.reduce_effects else time
 if prefs.festival == 1:
  for i in range(4):
   var x := 26.0 if i%2==0 else 451.0
   var y := 110.0+i*180.0+sin(t+i)*6.0
   canvas.draw_set_transform(Vector2(x,y),sin(t*0.7+i)*0.08)
   canvas.draw_texture_rect(KITE,Rect2(-13,-20,26,45),false)
   canvas.draw_set_transform(Vector2.ZERO)
 elif prefs.festival == 2:
  for row in range(-1,3):
   var y := float(row*410)+fmod(travel,410.0)
   canvas.draw_line(Vector2(82,y),Vector2(398,y+12),Color("40505a"),1,true)
   for i in range(13):
    var at := Vector2(90+i*25,y+i*1.0)
    canvas.draw_line(at,at+Vector2(0,8),Color("e4b57e"),1,true)
    canvas.draw_circle(at+Vector2(0,10),7,Color(1,0.75,0.30,0.12))
    canvas.draw_circle(at+Vector2(0,10),2.5,Color("ffe4a0"))
