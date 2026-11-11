extends RefCounted
# Decorative only: no collision shapes, RNG calls, timers or spawned nodes.
const TEA = preload("res://assets/art/tea-stall.svg")
const TREE = preload("res://assets/art/tree.svg")
const UMBRELLA = preload("res://assets/art/umbrella.svg")
const KITE = preload("res://assets/art/kite.svg")
const CIRCUS = preload("res://assets/art/circus-tent.svg")
const CREAM = Color("fff0cc")

func draw_market(canvas: Node2D, time: float, travel: float, reduced: bool) -> void:
 var t: float = 0.0 if reduced else time
 for i in range(-1,4):
  var y := float(i*320)+fmod(travel,320.0)
  var left := i%2 == 0
  var x := 4.0 if left else 390.0
  var art: Texture2D = TEA if posmod(i,3)==0 else TREE if posmod(i,3)==1 else UMBRELLA
  # Small alternating street-side illustrations; all stay outside the road.
  canvas.draw_texture_rect(art,Rect2(x,y+115,82,104),false)
  if art == TEA:
   for puff in range(3):
    var phase := fmod(t*0.4+float(puff)/3.0,1.0)
    canvas.draw_arc(Vector2(x+26+sin(phase*5.0)*3,y+165-phase*19),3+phase*3,PI*0.2,PI*1.4,8,Color(1,0.94,0.8,(1-phase)*0.45),1.5,true)
 # Circus tents alternate on the pavement, never within a drivable lane.
 for side in range(2):
  var tent_y := fposmod(travel+side*690.0,1380.0)-160.0
  canvas.draw_texture_rect(CIRCUS,Rect2(1 if side==0 else 387,tent_y,92,133),false)
  var flag_x := 47.0 if side==0 else 433.0
  var wave := sin(t*3.0+side)*3.0
  canvas.draw_colored_polygon(PackedVector2Array([Vector2(flag_x,tent_y+2),Vector2(flag_x+20,tent_y+2+wave),Vector2(flag_x+12,tent_y+9+wave),Vector2(flag_x,tent_y+9)]),Color("55b8a7"))
 # Flower garlands remain on the pavement and sway gently, never over hazards.
 for side in [9.0,464.0]:
  for j in range(12):
   var y := float(j)*78.0+fmod(travel,78.0)
   var sway := sin(t*1.7+j*0.7)*2.0
   canvas.draw_circle(Vector2(side+sway,y),3.5,Color("f5b640"))
   canvas.draw_circle(Vector2(side+sway,y+7),3,Color("e67c54"))

func draw_flying(canvas: Node2D, time: float, reduced: bool) -> void:
 var t: float = 0.0 if reduced else time
 # Kites stay over the left/right pavement, away from the player's driving lane.
 for i in range(2):
  var at := Vector2(48 if i==0 else 432,230+i*220)
  at += Vector2(sin(t*0.65+i)*10,cos(t*0.85+i)*12)
  canvas.draw_set_transform(at,sin(t*0.7+i)*0.10)
  canvas.draw_texture_rect(KITE,Rect2(-19,-35,38,65),false)
  canvas.draw_set_transform(Vector2.ZERO)
 # Three birds cross only the far/top part of the road. Hazards are drawn later.
 for i in range(3):
  var at := Vector2(fposmod(t*22.0+i*156.0,560.0)-40.0,165.0+i*43.0+sin(t*1.2+i)*7.0)
  var wing := sin(t*7.0+i)*6.0
  canvas.draw_polyline(PackedVector2Array([at+Vector2(-11,-3-wing),at+Vector2(-5,-4),at,at+Vector2(5,-4),at+Vector2(11,-3-wing)]),CREAM,2.5,true)
  canvas.draw_line(at-Vector2(0,3),at+Vector2(1,5),Color("304452"),2,true)

func draw_dust(canvas: Node2D, at: Vector2, time: float) -> void:
 # Fixed eight-puff pool, drawn directly; no allocations of particle nodes per frame.
 for i in range(8):
  var phase := fmod(time*1.5+float(i)/8.0,1.0)
  var side := -1.0 if i%2==0 else 1.0
  canvas.draw_circle(at+Vector2(side*(18+phase*15),35+phase*48),2+phase*5,Color(0.94,0.81,0.59,(1-phase)*0.20))
