pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- wall and actor collisions
-- by zep

actor = {} -- all actors

-- make an actor
-- and add to global collection
-- x,y means center of the actor
-- in map tiles
function make_actor(k, x, y)
	a={
		k = k,
		x = x,
		y = y,
		dx = 0,
		dy = 0,		
		bigsprite=false,
		biggersprite=false,
		animation=false,
		can_move=true,
		can_talk=false,
		can_swim=false,
		talk_count=0,
		frame = 0,
		t = 0,
		sound=0,
		friction = 0.15,
		bounce  = 0.6,
		frames = 1,
		
		-- half-width and half-height
		-- slightly less than 0.5 so
		-- that will fit through 1-wide
		-- holes.
		w = 0.4,
		h = 0.41
	}
	
	add(actor,a)
	
	return a
end

function _init(has_key)
 actor={}
 if has_key==true then
	 start_game(true)
	else
	 start_game(false)
	end
 spawn_npcs()
 spawn_enemies()
	pl = make_actor(1,10,10)
	pl.name="oso"
	pl.role="protag"
	pl.friction = 0.1
	pl.dialog=oso.dialog
	pl.animation=oso.animation
	
	-- red ball: bounce forever
	-- (because no friction and
	-- max bounce)
	--local ball = make_actor(49,7,8)
	--ball.dx=-0.1
	--ball.dy=0.15
	--ball.friction=0
	--ball.bounce=1
	
	-- treasure
 for i=0,7 do
	 a = make_actor(02,18+rnd(12),2+rnd(8))
  a.w=0.25 a.h=0.25
	end
	a = make_actor(18,18+rnd(12),2+rnd(14)) 
	
	-- blue peopleoids
	
	--a = make_actor(5,7,5)
	--a.frames=4
	--a.dx=1/8
	--a.friction=0.1
	
	--for i=1,6 do
	-- a = make_actor(5,20+i,24)
	-- a.frames=4
	-- a.dx=1/8
	-- a.friction=0.1
	-- end	
end

function move_actor(a)
	-- only move actor along x
	-- if the resulting position
	-- will not overlap with a wall
	if btn(⬅️) and a.role=="protag" then
	 pl.flipped=false
	end
	if btn(➡️) and a.role=="protag" then
	 pl.flipped=true
	end
	if land_a(a, a.dx, 0) then
	 game.swimming_on=false
 end
 if land_a(a, a.dy, 0) then
  game.swimming_on=false
 end
	if hazard_a(a, a.dx, 0) and a.role=="protag" then
		game.swimming_on=true
		if pl.can_swim != true then
			game.state="lost"
		 game.message="estas muerto"
		end
	end
	if hazard_a(a, a.dy, 0) and a.role=="protag" then
	 game.swimming_on=true
	 if pl.can_swim != true then
			game.state="lost"
		 game.message="estas muerto"
		end
	end
	
	if warp_a(a, a.dx, 0) and a.role=="protag" then
		if actor!=nil then
		 foreach(actor, delete_all_bullets)
		end
		if game.frames.x == 8 and game.frames.y == 1 then
		  pl.x = 25
	   pl.y = 22
	   game.frames.x = 2
	   game.frames.y = 2
	  return nil
		end
		if game.frames.x == 8 and game.frames.y == 2 then
		  pl.x = 105
	   pl.y = 24
	   game.frames.x = 7
	   game.frames.y = 2
	   return nil
		end
  --
  if game.frames.x == 4 and game.frames.y == 1 and game.has_key==true then
		  pl.x = 72
	   pl.y = 12
	   game.frames.x = 5
	   game.frames.y = 1
	  return nil
		end
		if game.frames.x == 5 and game.frames.y == 1 then
		  pl.x = 56
	   pl.y = 10
	   game.frames.x = 4
	   game.frames.y = 1
	  return nil
		end
  --
	 if game.frames.x == 2 and game.frames.y == 2 then
	  	pl.x = 120
	   pl.y = 12
	   game.frames.x = 8
	   return nil    
	 end
	 if game.frames.x == 7 and game.frames.y ==  2 then
	   pl.x = 120
	   pl.y = 27
	   game.frames.x = 8
	   return nil
	 end
	end
	
	if warp_a(a, a.dy, 0) and a.role=="protag" then
		if a!=nil then
		 foreach(actor, delete_all_bullets)
		end
		if game.frames.x == 8 and game.frames.y == 1 then
		  pl.x = 25
	   pl.y = 22
	   game.frames.x = 2
	   game.frames.y = 2
	  return nil
		end
		if game.frames.x == 8 and game.frames.y == 2 then
		  pl.x = 105
	   pl.y = 24
	   game.frames.x = 7
	   game.frames.y = 2
	   return nil
		end
  --
  if game.frames.x == 4 and game.frames.y == 1 and game.has_key==true then
		  pl.x = 72
	   pl.y = 12
	   game.frames.x = 5
	   game.frames.y = 1
	  return nil
		end
		if game.frames.x == 5 and game.frames.y == 1 then
		  pl.x = 56
	   pl.y = 10
	   game.frames.x = 4
	   game.frames.y = 1
	  return nil
		end
  --
	 if game.frames.x == 2 and game.frames.y == 2 then
	  	pl.x = 120
	   pl.y = 12
	   game.frames.x = 8
	   return nil    
	 end
	 if game.frames.x == 7 and game.frames.y ==  2 then
	   pl.x = 120
	   pl.y = 27
	   game.frames.x = 8
	   return nil
	 end
	end

 if game.can_move != false then
	 if not solid_a(a, a.dx, 0) and 
	        a.can_move == true then
	 	a.x += a.dx
	 else
	 	a.dx *= -a.bounce
	 end

	 -- ditto for y
	 if not solid_a(a, 0, a.dy) and 
	        a.can_move == true then
		 a.y += a.dy
	 else
		 a.dy *= -a.bounce
	 end
end
	
	-- apply friction
	-- (comment for no inertia)
	
	a.dx *= (1-a.friction)
	a.dy *= (1-a.friction)
	
	-- advance one frame every
	-- time actor moves 1/4 of
	-- a tile
	
	a.frame += abs(a.dx) * 4
	a.frame += abs(a.dy) * 4
	a.frame %= a.frames

	a.t += 1
	
end

function control_player(pl)

	accel = 0.05
	if (btn(0)) pl.dx -= accel 
	if (btn(1)) pl.dx += accel 
	if (btn(2)) pl.dy -= accel 
	if (btn(3)) pl.dy += accel 
	
end

function _update()
 start_clock()
	control_player(pl)
	track_frame()
	track_areas()
	foreach(actor, move_actor)
	button_events()
	if game.pollitos > 4 then
	 if pl.bigsprite==false then
	  sfx(1)
	 end
	 pl.bigsprite=true
	end
	foreach(actor, track_bullet)
	if game.malfin_dead and game.palo_divino==false then
		del(actor, malfin_bullet)
 	del(actor, malfin_bullet_2)
	 del(actor, malfin_bullet_3)
	 del(actor, chidori)
	 palo_divino=make_actor(206,104,6)
	 palo_divino.bigsprite=true
	 palo_divino.name="palo divino"
	 palo_divino.can_move="false"
	 malfin.k=112
	 malfin.chiquitillo=true
	 malfin.bigsprite=false
	 malfin.biggersprite=false
	 game.palo_divino=true
	 sfx(14)
	end
end

function draw_actor(a)
	if pl.name=="viento" and game.swimming_on==false then
  pl.animation={76,108}
 end
 if pl.name=="viento" and game.swimming_on==true then
  pl.animation={71,103}
 end
 if pl.name=="gaturri" and game.swimming_on==false then
  pl.animation={78,78}
 end
 if pl.name=="gaturri" and game.swimming_on==true then
  pl.animation={99,99}
 end
 debug.active=true
	local sx = (a.x * 8) - 4
	local sy = (a.y * 8) - 4
	if a.bigsprite==false and a.biggersprite==true then
	 if a.animation!=false then
	  spr(a.animation[flr(clock)], sx, sy,4,4,a.flipped)
	 else
	  spr(a.k + a.frame, sx, sy,4,4)
	 end
	elseif a.biggersprite==false and a.bigsprite==true then
	 if a.animation!=false then
	  spr(a.animation[flr(clock)], sx, sy,2,2,a.flipped)
	 else
	  spr(a.k + a.frame, sx, sy,2,2)
	 end
	else
	 if a.name and a.name=="malfin_bullet" then
	  spr(a.animation[flr(clock)], sx, sy)
	 else
		 spr(a.k + a.frame, sx, sy)
		end
	end
end

function _draw()
	cls()
	if game.game_e==true then
	 game.frames.x=1
	 game.frames.y=1
	 centertext_wo("you finished the game",5,7)
	 return nil
	end
	room_x=flr(pl.x/16)
	room_y=flr(pl.y/16)
	camera(room_x*128,room_y*128)
	map()
	foreach(actor,draw_actor)
	if debug.active == true then
	 centertext(debug.message,9)
	end
	if debug.warning != false then
	 centertext(debug.warning,4)
	end
	
	if game.state=="lost" then
		game_over()
	end
 print_dialog()
end

function centertext(txt,clr)
 x_text = 0
 y_text = 61
 if game.frames.x == 1 then
	 x_text = 64-#txt*2
 else
 	x_text = (128*(game.frames.x-1)-1)+64-#txt*2
 end
 if game.frames.y > 1 then
  y_text = 126+61
 end
 print(txt,x_text,y_text,clr)
end

function game_over()
 print(game.frames.x, 128, 0)
 if game.frames.x == 1 then
  rect(0,0,127,127,8)
 else
   rect(128*(game.frames.x-1),0,128*(game.frames.x-1)+127, 127, 8)
 end
	centertext(game.message,8) 
	if game.over_sound == false then
	 sfx(3)
	 game.over_sound = true
	end
	game.can_move=false
		if btn(4) or btn(❎) then
	 _init(game.has_key)
	end
end

function centertext_wo(txt,offset,clr)
 x_text = 64-#txt*2
 y_text = 126+61+offset
 print(txt,x_text,y_text,clr)
end
-->8
-- utils

function start_game(_has_key)
 clock = 1
 state = "active"
	debug = {
	 active=false,
	 message="",
	 warning=false,
	 frames=false
	}
	endings={}
	endings.oso={"oso descrubre la verdad", "oculta, usa su poder para", "destruir a las corporaciones", "y salvar al mundo"}
	endings.gaturri={"gaturri toma el poder", "del palo divino", "para su beneficion propio", "un genocidio es inminente"}
	endings.lechu={"lechu se come el palo", "divino, no sucede mayor", "cosa..."}
	endings.viento={"viento no entiende nada", "acerca de nada", "se pone a llorar", "hasta que su dueno lo recoja"}
	game = {
	 floater_on=false,
	 has_balsa=false,
	 red_chidori=true,
	 malfin_dead=false,
	 has_key=_has_key,
	 swimming_on=false,
	 super_move=false,
	 talking=false,
	 talkedgolfin=0,
	 pollitos=0,
	 over_sound=false,
	 frames = {x=0,y=0},
	 state="active",
	 message="",
	 can_move=true,
	 shooting_area=false,
	 palo_divino=false,
	 game_e=false
	}
	animations = {
	 x_btn = {5,6,7,6}
	}
end

function track_frame()
 if pl.x > 0 and pl.x < 16 then
 	game.frames.x=1
 end
 if pl.y > 0 and pl.y < 16 then
 	game.frames.y=1
 end
 
 if pl.x > 16 and pl.x < 32 then
 	game.frames.x=2
 end
 if pl.y > 16 and pl.y < 32 then
 	game.frames.y=2
 end
 
 if pl.x > 32 and pl.x < 48 then
  game.frames.x=3
 end
 if pl.y > 32 and pl.y < 48 then
  game.frames.y=3
 end
 
 if pl.x > 48 and pl.x < 64 then
  game.frames.x=4
 end
 if pl.y > 48 and pl.y < 64 then
  game.frames.y=4
 end
 
 if pl.x > 64 and pl.x < 80 then
  game.frames.x=5
 end
 if pl.y > 64 and pl.y < 80 then
  game.frames.y=5
 end
 
 if pl.x > 80 and pl.x < 96 then
  game.frames.x=6
 end
 if pl.y > 80 and pl.y < 96 then
  game.frames.y=6
 end
 
 if pl.x > 96 and pl.x < 112 then
  game.frames.x=7
 end
 if pl.y > 96 and pl.y < 112 then
  game.frames.y=7
 end
 
 if pl.x > 112 and pl.x < 128 then
  game.frames.x=8
 end
 if pl.y > 112 and pl.y < 128 then
  game.frames.y=8
 end
end

function track_areas()
 if game.frames.x==5 and game.frames.y==2 then
  spawn_dynamics()
 elseif game.frames.x==6 and game.frames.y==1 then
  spawn_dynamics()
 elseif game.frames.x==7 and game.frames.y==1 then
  spawn_dynamics()
 else
  spawn_dynamics(true)
 end
end

function clear_text()
 game.dialog = false
 game.dialog_msg = ""
 cls(7)
 cls(0)
end

function button_events()
 if btnp(❎) then
  clear_text()
  golfin_convo()
 end
 if btnp(04) then
  if pl.name=="gaturri" then
   sfx(13)
   if game.red_chidori==true then
    sp=172
    _x=0.7
   else
    sp=140
    _x=0.4
   end
   if btn(04) and btn(➡️) then
    _x=0-_x
   end
   chidori=make_actor(sp,pl.x,pl.y)
	  chidori.name="chidori"
	  chidori.bigsprite=true
	  chidori.friction=0
	  chidori.dx=_x
	  chidori.dy=0
  end
 end
end

function print_dialog()
	if game.dialog == true then
		if game.frames.x == 1 then
		 rectfill(0,128,128,100,0)
			for l=1,#game.dialog_msg do
			 print(game.dialog_msg[l],game.frames.x,100+(l*6),7)
			end
		 print("❎",120,120,animations.x_btn[flr(clock)])
		else
		 rectfill(game.frames.x*128,game.frames.y*128,128,game.frames.y*128-30,0)
		 -- a
		 for l=1,#game.dialog_msg do
		  print(game.dialog_msg[l],(game.frames.x-1)*128,(game.frames.y*128-30)+(l*6),7)
		 end
		 print("❎",((game.frames.x-1)*128)+120,game.frames.y*128-10,animations.x_btn[flr(clock)])
		end
	end
end

function start_clock()
	if clock<2.9 then
		clock=clock+.05
	else
		clock=1
	end
end

function wait(a) for i = 1,a do flip() end end

function slice(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end

function golfin_convo()
 if pl.name=="oso" and pl.bigsprite==true then
  if game.talking == "golfin" and game.talkedgolfin==0 then
   t = slice(golfin.special_dialog,5,8,1)
   game.dialog_msg=t
   game.dialog=true
   game.talkedgolfin=1 
  elseif game.talking == "golfin" and game.talkedgolfin==1 then
   t = slice(golfin.special_dialog,9,12,1)
   game.dialog_msg=t
   game.dialog=true
   game.talkedgolfin=2
  elseif game.talking == "golfin" and game.talkedgolfin==2 then
   t = slice(golfin.special_dialog,13,16,1)
   game.dialog_msg=t
   game.dialog=true
   game.talkedgolfin=3
		elseif game.talkedgolfin==3 then
		 clear_text()
		 game.talkedgolfin=4
		-- second layer of text
		elseif game.talkedgolfin==4 then
		 t = slice(golfin.special_dialog_2,5,8,1)
   game.dialog_msg=t
   game.dialog=true
   game.talkedgolfin=5
  elseif game.talkedgolfin==5 then
		 t = slice(golfin.special_dialog_2,9,12,1)
   game.dialog_msg=t
   game.dialog=true
   game.talkedgolfin=6
  elseif game.talkedgolfin==6 then
		 t = slice(golfin.special_dialog_2,12,16,1)
   game.dialog_msg=t
   game.dialog=true
   game.talkedgolfin=7
		end
	end
end
-->8
-- physics


-- for any given point on the
-- map, true if there is wall
-- there.

function solid(x, y)
	-- grab the cel value
	val=mget(x, y)
	
	-- check if flag 1 is set (the
	-- orange toggle button in the 
	-- sprite editor)
	return fget(val, 1)	
end

function hazard(x, y)
	val=mget(x, y)
	return fget(val, 0)	
end

function warp(x, y)
	val=mget(x, y)
	return fget(val, 2)	
end

function land(x, y)
	val=mget(x, y)
	return fget(val, 3)	
end

-- solid_area
-- check if a rectangle overlaps
-- with any walls

--(this version only works for
--actors less than one tile big)

function solid_area(x,y,w,h)
 if game.super_move==true then
  return false
 end
	return 
		solid(x-w,y-h) or
		solid(x+w,y-h) or
		solid(x-w,y+h) or
		solid(x+w,y+h)
end

function hazard_area(x,y,w,h)
 if game.super_move==true then
  return false
 end
 is_hazard = 
		hazard(x-w,y-h) or
		hazard(x+w,y-h) or
		hazard(x-w,y+h) or
		hazard(x+w,y+h)
		if pl.name=="oso" or pl.name=="lechu" then
		 pl.can_swim=false
		end
		if pl.name=="gaturri" and game.has_balsa==true then
		 pl.can_swim=true
		end
		return is_hazard
end


function land_area(x,y,w,h)
 is_land = 
		land(x-w,y-h) or
		land(x+w,y-h) or
		land(x-w,y+h) or
		land(x+w,y+h)
 return is_land
end

function warp_area(x,y,w,h)
	return 
		warp(x-w,y-h) or
		warp(x+w,y-h) or
		warp(x-w,y+h) or
		warp(x+w,y+h)
end

-- true if [a] will hit another
-- actor after moving dx,dy

-- also handle bounce response
-- (cheat version: both actors
-- end up with the velocity of
-- the fastest moving actor)

function solid_actor(a, dx, dy)
	for a2 in all(actor) do
		if a2 != a then
		
			local x=(a.x+dx) - a2.x
			local y=(a.y+dy) - a2.y
			
			if ((abs(x) < (a.w+a2.w)) and
					 (abs(y) < (a.h+a2.h)))
			then
				
				-- moving together?
				-- this allows actors to
				-- overlap initially 
				-- without sticking together    
				
				-- process each axis separately
				
				-- along x
				
				if (dx != 0 and abs(x) <
				    abs(a.x-a2.x))
				then
					
					v=abs(a.dx)>abs(a2.dx) and 
					  a.dx or a2.dx
					a.dx,a2.dx = v,v
					
					local ca=
					 collide_event(a,a2) or
					 collide_event(a2,a)
					return not ca
				end
				
				-- along y
				
				if (dy != 0 and abs(y) <
					   abs(a.y-a2.y)) then
					v=abs(a.dy)>abs(a2.dy) and 
					  a.dy or a2.dy
					a.dy,a2.dy = v,v
					
					local ca=
					 collide_event(a,a2) or
					 collide_event(a2,a)
					return not ca
				end
				
			end
		end
	end
	
	return false
end


-- checks both walls and actors
function solid_a(a, dx, dy)
	if solid_area(a.x+dx,a.y+dy,
				a.w,a.h) then
				return true end
	return solid_actor(a, dx, dy) 
end

function hazard_a(a, dx, dy)
	if hazard_area(a.x,a.y,
				a.w,a.h) then
				return true end 
end

function warp_a(a, dx, dy)
	if warp_area(a.x,a.y,
				a.w,a.h) then
				return true end 
end

function land_a(a, dx, dy)
	if land_area(a.x,a.y,
				a.w,a.h) then
				return true end 
end

-- return true when something
-- was collected / destroyed,
-- indicating that the two
-- actors shouldn't bounce off
-- each other

function collide_event(a1,a2)
 if a1.role=="protag" and a2.can_talk then
  game.talking = a2.name
 	a2.talk_count += 1
 	if a1.role=="protag" and a2.name=="golfin" and a1.name=="oso" and a1.bigsprite==true then
 	 if a2.special_dialog != false then
 	  game.dialog_msg=a2.special_dialog
 	 else
 	 game.dialog_msg=a2.dialog
 	 end
 	 if game.talkedgolfin==4 then
 	  game.dialog_msg=a2.special_dialog_2
 	 end
 	 game.dialog=true
 	else
 	 game.dialog=true
   game.dialog_msg=a2.dialog
 	end
  sfx(a2.sound)
 end
 if a1.role=="protag" and a2.name=="andrea" and a2.talk_count>1 then
 	game.dialog_msg=a2.dialog_2
 	if pl.bigsprite==true then
 	 game.pollitos=0
 	 pl.can_swim=false
 		pl.bigsprite=false
 	else
 	 pl.bigsprite=true
 	 pl.can_swim=true
 	end
 end
 if a1.role=="protag" and a2.name=="crab" and a2.talk_count > 1 then
  game.dialog_msg=a2.dialog_2
 end
 if a1.role=="protag" and a2.name=="pablo" and a2.talk_count > 1 then
  game.dialog_msg=a2.dialog_2
 end
 if a1.role=="protag" and a2.name=="pablo" and a2.talk_count > 7 then
  game.dialog_msg=a2.dialog_7
 end
 if a1.role=="protag" and a2.name=="tabash" and a2.talk_count > 1 then
  game.dialog_msg=a2.dialog_2
 end
 if a1.role=="protag" and a2.name=="palo divino" then
  game.game_e=true
 end
 if a1.role=="protag" and a2.name=="andre" and a2.talk_count > 1 then
  game.dialog_msg=a2.dialog_2
 end
 if a1.role=="protag" and 
 a2.name=="malfin" and 
 a2.bigsprite==false and 
 a2.biggersprite==false and
 a1.name=="oso" then
  game.dialog_msg=a2.dialog_2
 end
 if a1.role=="protag" and a2.name=="fuan" and a2.talk_count > 7 then
  game.dialog_msg=a2.dialog_2
 end
 if a1.role=="protag" and a1.name==pl.name and a2.name=="malfin_bullet" then
  game.state="lost"
		game.message="estas muerto"
 end
 if a1.role=="protag" and a2.name=="naranita" and a2.talk_count > 1 then
  game.dialog_msg=a2.dialog_2
 end
 if a1.role=="protag" and a2.name=="naranita_2" and a2.talk_count > 1 then
  change_random_character()
 end
 if a1.role=="protag" and a2.name=="shark"  then
  game.state="lost"
		game.message="estas muerto"
 end
 if a1.role=="protag" and a2.name=="bullet"  then
  game.state="lost"
		game.message="estas muerto"
 end
 if a1.name=="bullet" and a2.name=="bichillo"  then
  if game.frames.x==6 and game.frames.y==1 then
   del(actor,a2)
  end
 end
 if a1.role=="protag" and a2.name=="bubibul" and a2.talk_count > 1 then
  if pl.bigsprite==true then
   pl.bigsprite=false
  else
   pl.bigsprite=true
  end
 end
 if a1.role=="protag" and a2.name=="casa" and a2.talk_count > 1 then
  _init(game.has_key)
 end
 if a1.role=="protag" and a2.name=="passage" and a1.name=="gaturri" then
  game.super_move=true
  pl.x=6
  pl.y=35
  game.frames.x=1
  game.frames.y=3
 end
 if a1.name=="chidori" and 
 a2.name !=pl.name and 
 a2.name!="malfin" and 
 a2.name!="palo divino" then
  if a2.k!=129 and a2.k!=144 and a2.k!=89 then
   del(actor,a1)
   del(actor,a2)
  end
  if a2.k==107 then
   del(actor,a1)
  end
 end
 if a1.name=="chidori" and a2.name !=pl.name and game.red_chidori==true then
  if (a2.name=="malfin") then
   if malfin.damage==5 then
    game.malfin_dead=true
   end
   malfin.damage=malfin.damage+1
   sfx(11)
   pal(6,8)
  end
 end
 if a1.role=="protag" and a2.name=="red_chidori" and 
  a1.name=="gaturri" and 
  a1.bigsprite==false then
   game.super_move=false
   pl.x=39
   pl.y=14
   game.red_chidori=true
   game.frames.x=3
   game.frames.y=1
 end
 if (
  a2.name=="lechu" 
  or a2.name=="oso"
  or a2.name=="viento"
  or a2.name=="gaturri"
 ) 
 and a1.role=="protag"
 and a2.talk_count > 1 then
  --
  _k = pl.k
  pl.k = a2.k
  a2.k=_k
  _n = pl.name
  pl.name=a2.name
  a2.name=_n
  _d = pl.dialog
  pl.dialog=a2.dialog
  a2.dialog=_d
  pl.can_talk=false
  a2.can_talk=true
  _a = pl.animation
  pl.animation=a2.animation
  a2.animation=_a
  _t=pl.friction
  a1.friction=a2.friction
  a2.friction=_t
  
  --
 end
 if (a1==pl and 
 pl.bigsprite==true and 
 pl.name=="lechu" and 
 can_lechu_eat(a2)) then
		del(actor,a2)
		sfx(5)
		return true
	end
	if a1.role=="protag" and a1.bigsprite==true and
	 a1.name=="viento" and 
	 includes(a2, floater.sprites) then
	  viento.can_swim=true
	  a1.can_swim=true
	  game.swimming_on=true
	  del(actor,a2)
	  return nil
	end
	if a1.role=="protag" and a1.name=="viento" and 
	 includes(a2, balsa.sprites) then
	  game.has_balsa=true
	  del(actor,a2)
	  return nil
	end
	if a1.role=="protag" and a2.name=="key" then
	  game.has_key=true
	  del(actor,a2)
	  return nil
	end
	-- player collects treasure
	if a1.role=="protag" and (a1==pl and a2.k==02) then
		del(actor,a2)
		game.pollitos += 1
		sfx(5)
		return true
	end
	-- player dies drowned
	if a1.role=="protag" and pl.can_swim==false then
	 if (a1==pl and a2.k==04) then
		 del(actor,a2)
		 sfx(3)
		 return true
	 end
	end
	-- poisoned chicken
	if a1.role=="protag" and (a1==pl and a2.k==18) then
		pal(04,07)
		game.state = "lost"
		game.message= "te envenenaron"
		return true
	end
	return false
end

function includes(el, arr)
 for i=1,#arr do
  if el.k==arr[i] then
   return true
  end
 end
 return false
end

function includes_raw(el, arr)
 for i=1,#arr do
  if el==arr[i] then
   return true
  end
 end
 return false
end

function can_lechu_eat(a2)
 return a2.k==35 or a2.k==89 or a2.k==64 or a2.k==107
end

-->8
-- spawning

function spawn_npcs()
 	-- make npcs
	pablo = make_actor(8,7,4)
	pablo.name="pablo"
	pablo.role="npc"
	pablo.bigsprite=true
	pablo.can_move=false
	pablo.animation={8,40}
	pablo.can_talk=true
	pablo.sound=07
	pablo.dialog={"cada animalito tiene sus", "virtudes ...y sus defectos", "mae por cierto"}
	pablo.dialog_2={"hable mas veces con la gente", "ahora todo mundo esta", "con ese jueputa celular"}
	pablo.dialog_7={"hay un mundo secreto", "debes presionar un boton", "solo los gatos pueden entrar"}
	
	tabash = make_actor(134,54,21)
	tabash.name="tabash"
	tabash.role="npc"
	tabash.bigsprite=true
	tabash.can_move=false
	tabash.animation={134,166}
	tabash.can_talk=true
	tabash.sound=07
	tabash.dialog={"que? cual golfin", "yo solo estoy aca, no me meta", "en eso...en realidad", "se me varo el carro"}
	tabash.dialog_2={"que pijeado, el otro dia", "me sone que era chiquitillo", "y hablaba con una palmera", "en una isla desierta"}
	
	fuan = make_actor(192,20,6)
	fuan.name="fuan"
	fuan.role="npc"
	fuan.bigsprite=true
	fuan.animation={192,224}
	fuan.can_move=false
	fuan.can_talk=true
	fuan.sound=08
	fuan.dialog={"el pollito sabe muy rico", "pero te puede hacer mal.."}
	fuan.dialog_2={"necesitas el chidori rojo", "para derrotar a malfin", "abraza la palmera"}
	
	andre = make_actor(65,42,18)
	andre.name="andre"
	andre.role="npc"
	andre.bigsprite=true
	andre.animation={65,97}
	andre.can_move=false
	andre.can_talk=true
	andre.sound=08
	andre.dialog={"algo le pasa a golfin! aa", "no para de llorar …"}
	andre.dialog_2={"a malfin no se le puede", "hacer dano con un chidori normal..", "....si te echas para atras", "puedes tirar cosas al otro lado"}
	
	andrea = make_actor(74,102,25)
	andrea.name="andrea"
	andrea.role="npc"
	andrea.bigsprite=true
	andrea.can_move=false
	andrea.can_talk=true
	andrea.sound=08
	andrea.dialog={"golfin? oh no", "la llave de la casa esta", "ahi adentro", "...por ahi"}
	andrea.dialog_2={"ahh si, yo le ayudo", "con este treat", "se puede hacer grande", "o chiquitillo"}
	
	golfin = make_actor(65,38.5,8)
	golfin.name="golfin"
	golfin.role="npc"
	golfin.biggersprite=true
	golfin.animation={198,202}
	golfin.can_move=false
	golfin.can_talk=true
	golfin.sound=10
	golfin.dialog={"█★█⬅️⌂⬇️♪⬅️ !", "⌂⬅️😐♪웃⌂🐱ˇ", "ˇ웃♥●웃⌂♥⌂★██@##!", "$%^▤⬆️●█!!!"}
	golfin.special_dialog={"mae ese hijueputa malfin", "le tira uno los golpes ユか◆め", "por tantiar digo yo!", "los tiro asi 🐱◆", "y digo mae lo tengo que pegar", "mae y no le doyユ", "el hijueputa ese es magico", "bicho", "hijueputa", "malparido igual que usted", "pasa en una brincadera el hijueputa", "pibibibibibibib", "mae", "mi hermano", "ahhh ..picha", "suave para calmarme"}
	golfin.special_dialog_2={"..ya ahora si", "mae es que estaba jugando", "smash con mi hermanillo", "y se puso a fumar espiral", "se encamoto y saco un chopo", "..la casa esta cerrada con llave", "en el agua deje un flotador", "talvez en la isla", "alguien pueda ayudar", "..viento puede ir", "malparido malfin", "..", "mae", "jueputa susto ah?", ".................esperon", "..........esperon"}
	
	tabash_c = make_actor(130,56,18)
	tabash_c.name="carro"
	tabash_c.role="npc"
	tabash_c.biggersprite=true
	tabash_c.can_move=false
	tabash_c.can_talk=false

	crab = make_actor(38,11.5,1.5)
	crab.name="crab"
	crab.role="npc"
	crab.can_move=false
	crab.can_talk=true
	crab.sound=09
	crab.dialog={"no le haga caso a ese mae", "...el esconde algo..."}
	crab.dialog_2={"para algunas cosas es", "bueno ser chiquitillo", "para otras es mejor ser grande"}
	
	magician = make_actor(142,119.5,9)
	magician.name="naranita"
	magician.role="npc"
	magician.can_move=true
	magician.bigsprite=true
	magician.animation={142,174}
	magician.can_talk=true
	magician.sound=09
	magician.dialog={"aca puedes tomar relevo", "con un amigo"}
	magician.dialog_2={"algunas cosas solo", "se puede hacer chiquitillo", "otras grande, otras no importa"}

	magician_a = make_actor(142,68,9)
	magician_a.name="naranita_2"
	magician_a.role="npc"
	magician_a.can_move=true
	magician_a.bigsprite=true
	magician_a.animation={142,174}
	magician_a.can_talk=true
	magician_a.sound=09
	magician_a.dialog={"cambie de bicho conmigo", "solo empujeme"}
	
	magician_b = make_actor(138,74,9)
	magician_b.name="bubibul"
	magician_b.role="npc"
	magician_b.can_move=true
	magician_b.bigsprite=true
	magician_b.animation={138,138}
	magician_b.can_talk=true
	magician_b.sound=09
	magician_b.dialog={"no nos conocemos", "me llamo bubibul", "empujeme para cambiar de tamano"}
	
 lechu = make_actor(07,116,4)
	lechu.name="lechu"
	lechu.friction=0.10
	lechu.role="character"
	lechu.animation={14,46}
	lechu.can_talk=true
	lechu.can_move=false
	lechu.dialog={"lechu", "+1 atq", "skill: comer piedras"}
	
	viento = make_actor(23,120,4)
	viento.name="viento"
	viento.role="character"
	viento.friction=0.30
	viento.animation={76,108}
	viento.can_talk=true
	viento.can_move=false
	viento.dialog={"viento", "-3 velocidad", "skill: nadar"}
	
	
	gaturri = make_actor(39,124,4)
	gaturri.name="gaturri"
	gaturri.friction=0.05
	gaturri.role="character"
	gaturri.animation={78,110}
	gaturri.can_talk=true
	gaturri.can_move=false
	gaturri.dialog={"gaturri", "-2 defensa", "skill: chidori"}
	
	casa = make_actor(55,1,10)
	casa.name="casa"
	casa.role="npc"
	casa.can_move=false
	casa.can_talk=true
	casa.dialog={"habla conmigo otra vez", "para empezar de nuevo"}

		-- make player
		
	oso = {}
	oso.k = 1
	oso.friction=0.15
	oso.name="oso"
	oso.animation={10,42}
	oso.can_talk=true
	oso.dialog={"oso", "-3 energia", "skill: ???"}
	
	--rock1=make_actor(35,30.5,18.5)
	rock2=make_actor(35,30.5,19.5)
	rock3=make_actor(35,30.5,20.5)
 --rock1.can_move=false
	rock2.can_move=false
	rock3.can_move=false
		
	-- floater
	floater = make_actor(69,41.5,28.5) 
	floater.bigsprite=true
	floater.name="floater"
	floater.animation={69,101}
	floater.can_move=false
	floater.sprites={69,70,85,86}
	
	-- balsa
	balsa = make_actor(110,100.5,19.5) 
	balsa.bigsprite=true
	balsa.name="balsa"
	balsa.can_move=false
	balsa.can_talk=true
	balsa.sprites={110,111,125,126}
	balsa.dialog={"has conseguido la balsa", "...un animal pequeno", "cabe en ella"}
	
	passage=make_actor(160,107.5,21.5)
	passage.bigsprite=true
	passage.name="passage"
	passage.can_move=false
	passage.can_talk=true
	passage.dialog={"solo los gatos..", "comprenden la realidad", "alterna"}
	
	red_chidori=make_actor(172,104,60)
	red_chidori.bigsprite=true
	red_chidori.name="red_chidori"
	red_chidori.can_move=false
	red_chidori.can_talk=true
	red_chidori.dialog={"has despertado tu poder", "para derrotar a malfin", ".. y tal vez mas"}
	
		-- key
	key = make_actor(171,120,22) 
	key.name="key"
	key.can_move=false
	key.can_talk=true
	key.dialog={"has conseguido la llave", "de la casa de", "golfin"}  
end

function spawn_enemies()
	malfin = make_actor(194,102.5,7)
	malfin.name="malfin"
	malfin.role="npc"
	malfin.damage=0
	malfin.shot=false
	malfin.alive=true
	malfin.biggersprite=true
	malfin.can_move=true
	malfin.can_talk=true
	malfin.sound=10
	malfin.dx=-0.1
	malfin.dy=-0.2
	malfin.bounce=1
	malfin.dialog={"█★e⬇️♪gat⬅️ !", "sed😐♪웃⌂🐱ˇ", "ˇ웃♥●웃muert█@##!", "$%^▤no●█!!!"}
 malfin.dialog_2={"..no dejes que gaturri", "ahhl", "tome el poder", "..sagrado..", "lo a ●♥⬆️⬆️", "⬇️░★⧗⬆️", "⬇️░★⧗➡️⬆️destruccion", "..si", "malparido", "...", "mae", "me deje", "...", ".!"}
	
	-- bouncy ball 2 sea 1
	shark = make_actor(33,72,27)
	shark.name="shark"
	shark.dx=0.37
	shark.dy=-0.4
	shark.friction=0.004
	shark.bounce=0.9
	
	-- bouncy ball 2 sea 2
	shark = make_actor(33,82,28)
	shark.name="shark"
	shark.dx=0.03
	shark.dy=-0.9
	shark.friction=0.004
	shark.bounce=0.92
	
	-- bouncy ball 2 sea 3
	shark = make_actor(33,60,29)
	shark.name="shark"
	shark.dx=-0.005
	shark.dy=0.08
	shark.friction=0.004
	shark.bounce=0.92
	
	-- bouncy ball 2 sea 3
	shark = make_actor(33,84,26)
	shark.name="shark"
	shark.dx=-0.02
	shark.dy=0.04
	shark.friction=0.003
	shark.bounce=0.92
	
	-- shooter
	shooters={}
	shooters_boss={}
	
	shooters[1] = {}
	shooters[1] = make_actor(238,74,24.5)
	shooters[1].name="shooter"
	shooters[1].bigsprite=true
	shooters[1].can_move=false
	shooters[1].shot=false
	
	shooters[2] = {}
	shooters[2] = make_actor(238,68,24.5)
	shooters[2].name="shooter"
	shooters[2].bigsprite=true
	shooters[2].can_move=false
	shooters[2].shot=false
	
	shooters_boss[1] = {}
	shooters_boss[1] = make_actor(238,90,1)
	shooters_boss[1].name="shooter"
	shooters_boss[1].bigsprite=true
	shooters_boss[1].can_move=false
	shooters_boss[1].shot=false
	
	shooters_boss[2] = {}
	shooters_boss[2] = make_actor(238,84,1)
	shooters_boss[2].name="shooter"
	shooters_boss[2].bigsprite=true
	shooters_boss[2].can_move=false
	shooters_boss[2].shot=false
	
	rocks_boss = {}
	rocks_boss[1] = make_actor(107,83.4,7.5)
	rocks_boss[1].name="rock"
	rocks_boss[1].can_move=false
	
	rocks_boss[2] = make_actor(107,83.4,8.5)
	rocks_boss[2].name="rock"
	rocks_boss[2].can_move=false
	
	rocks_boss[2] = make_actor(107,91.5,7.5)
	rocks_boss[2].name="rock"
	rocks_boss[2].can_move=false
	
	rocks_boss[2] = make_actor(107,91.5,8.5)
	rocks_boss[2].name="rock"
	rocks_boss[2].can_move=false

	
	--bichillos
	for i=1,3 do
	 bichillo=make_actor(73,83+i,12)
	 bichillo.name="bichillo"
	 bichillo.dx=0.1-i
	 bichillo.dy=0.1+i
	 bichillo.friction=0.001
	 bichillo.bounce=0.5
	end
end

function spawn_dynamics(_reset)
 if _reset then
  for i=1,2 do
	  _shooter = shooters[i]
	  _shooter.shot=false
	 end
	 return nil
 end
	for i=1,2 do
	 _shooter = shooters[i]
	 if _shooter.shot==false then
	  bullet = make_actor(129,_shooter.x,_shooter.y+1)
	  bullet.dy=0.1
	  bullet.name="bullet"
	  bullet.friction=0.002
	  _shooter.shot=true
	 end
	end
	s1=shooters_boss[1]
	s2=shooters_boss[2]
	if s1.shot==false then
	 bullet=make_actor(129,s1.x+0.5,s1.y+1)
	 bullet.dy=0.2
	 bullet.name="bullet"
	 bullet.friction=0.002
	 bullet.bounce=1
	 s1.shot=true
	end
	
	if s2.shot==false then
	 bullet=make_actor(129,s2.x+0.5,s2.y+1)
	 bullet.dy=0.2
	 bullet.name="bullet"
	 bullet.friction=0.002
	 s2.shot=true
	end
	
 if malfin.shot==false then
  malfin_bullet=make_actor(144, malfin.x+3, malfin.y)
	 malfin_bullet.animation={144,170}
	 malfin_bullet.name="malfin_bullet"
	 malfin_bullet.friction=0
	 malfin_bullet.dx=rnd(1)-0.5
	 malfin_bullet.dy=rnd(1)-0.5
	 malfin_bullet_2=make_actor(89, malfin.x+3, malfin.y)
	 malfin_bullet_2.animation={89,89}
	 malfin_bullet_2.name="malfin_bullet"
	 malfin_bullet_2.friction=0
	 malfin_bullet_2.dx=rnd(1)-0.5
	 malfin_bullet_2.dy=rnd(1)-0.5
	 malfin_bullet_3=make_actor(129, malfin.x+3, malfin.y)
	 malfin_bullet_3.animation={129,129}
	 malfin_bullet_3.name="malfin_bullet"
	 malfin_bullet_3.friction=0
	 malfin_bullet_3.dx=rnd(1)-0.5
	 malfin_bullet_3.dy=rnd(1)-0.5
	 malfin.shot=true
	end
end

function delete_all_bullets(a)
 if a.name then
  if a.name=="bullet" then
   del(actor,a)
  end
 end
end

function track_bullet(a)
 if a.name then
  if game.frames.x==5 and game.frames.y==2 then
   if a.name=="bullet" then
    if flr(a.y)+0.5==30.5 then
     a.y=26
    end
   end
  end
  if game.frames.x==6 and game.frames.y==1 then
   if a.name=="bullet" then
    if flr(a.y)==14 then
     a.y=2
     a.dy=0.4
    end
    if flr(a.y)==1 then
     a.y=2
     a.dy=0.3
    end
   end
  end
  if game.frames.x==7 and game.frames.y==1 then
   if a.name=="malfin_bullet" then
    if flr(a.y)==14 then
     a.y=malfin.y+2
     a.x=malfin.x+3
     a.dx=rnd(1)-0.5
     a.dy=rnd(1)-0.5
    end
    if flr(a.y)==2 then
     a.y=malfin.y+2
     a.x=malfin.x+3
     a.dy=rnd(1)-0.5
     a.dx=rnd(1)-0.5
    end
    if flr(a.x)==110 then
     a.y=malfin.y+2
     a.x=malfin.x+3
     a.dy=rnd(1)-0.5
     a.dx=rnd(1)-0.5
    end
    if flr(a.x)==98 then
     a.y=malfin.y+2
     a.x=malfin.x+3
     a.dy=0.3
     a.dx=0.1
    end
   end
  end
  if a.name=="chidori" then
  if game.red_chidori==true then
   if flr(a.x)>(pl.x+9) or flr(a.x)<(pl.x-8) or
      flr(a.y)>(pl.y+9) or flr(a.y)<(pl.y-8) then
    del(actor,a)
   end
  else
   if flr(a.x)>(pl.x+9) or flr(a.x)<(pl.x-5) or
      flr(a.y)>(pl.y+9) or flr(a.y)<(pl.y-5) then
    del(actor,a)
   end
  end
  if a.name=="malfin" then
   if flr(a.x)>10 or flr(a.x)<4 then
    a.x=102.5
   end
   if flr(a.y)>10 or flr(a.y)<4 then
    a.y=7
   end
  end
 end
 end
end

function delete_shooters()
 for i=1,#actor do
  if actor[i]==shooters[1] or
     actor[i]==bullet or
     actor[i]==shooters[2] then
   del(actor, actor[i])
  end
 end
end

function change_random_character()
 characters = {"oso", "lechu", "viento", "gaturri"}
 character_sprites = {}
 character_sprites.oso = 1
 character_sprites.lechu = 7
 character_sprites.viento = 23
 character_sprites.gaturri = 39
 --
 character_animations = {}
 character_animations.oso = {10,42}
 character_animations.lechu = {14,46}
 character_animations.viento = {76,108}
 character_animations.gaturri = {78,110}
 --
 character_f = {}
 character_f.oso = 0.15
 character_f.lechu = 0.10
 character_f.viento = 0.3
 character_f.gaturri = 0.05
 
 randnum = 1+ flr(rnd(4))
 name=tostr(characters[randnum])
 pl.name = name
 pl.k = character_sprites[name]
 pl.friction = character_f[name]
 pl.animation = character_animations[name]
end
__gfx__
c888cccc0000000000000000333333331111111166666666ffffffff000000023333331111333333000000001100000033333311133333330000010000000000
c888cccc0404000000000000333333331111111166666666ffffffff0000002233331111111113330011000014100000333331133133333300111711100000e0
c888cccc4404400404440000333333331111111166666666ffffffff7007f07e333111111111133301410001444100013333113331133333001776771100002e
888888884141404444444777333333331111111166666666ffffffff7777007733333f5ff4533333014411144411001133311333331133330177677761100e6e
888888884414444444444477333333331111111166666666ffffffff7575777633333ffff44333331445544441000011333133136331333316777777f1000e67
888888884484444404440000333333331111111166666666ffffffff77477770333555ffff433333141554144100114133313133333113331f617717f100167e
c888cccc0444444000000000333333331111111166666666ffffffff0777777033333fffa453333311554444441114413331333335133133117777777f111771
c888cccc0440044000000000333333331111111166666666ffffffff0077007033333aaaaa433333414114444444441033113333313331130174f777f7777770
00000000111111110000000033333333111111116d6666d6ffffffff0000000033333aaaaa433333014114444144441033131633133333130176777777777710
000000001111111100000000333333b3111111116d6666d6fff6ffff0404400033333aaaaa333333001444444144441131133333333333130017776776776711
000000001111111104440000333333b31cc11111ddddddddffff6fff4777477033333aaaaa33333300018844144454413135335333513113000167776777f771
0000000011111111444447773b333b3311111111666d6666fffff6ff4171447733333aaaaa33333300011441444451413133333351353133000176777677f771
0000000011111111444444773bb33b3311c11cc1666d6666ff6fffff4787411733333aaaa33333330001511441451441331133355131113300017777767f7710
00000000111111110445000033b3333311111111ddddddddfff6ffff0777777733333222233333330001451441411441333311515151333300017f77717ff710
00000000111111110000000033333333111111116d6666d6ffffffff0717151733333322233333330014451441100110333333511113333300011ff71111f710
00000000111111110000000033333333111111116d6666d6ffffffff071755773333344443333333001111011000000033333311113333330001111000011100
44244111111111113333333333111133c166c6166c16166cffffffff000000003333331111333333000000001100000044444444333333320000010000000000
222221411111c1113b333333311551136c1611c161c11c11ffffff880000000033331111111133330011000014100000444444443333332200111711100000e0
24142141111ccc113b3333b33155551111111111c11111118f0880f800000000363111111111133301410001444100015555544433333222001776771100002e
2414211111cccc113b333b331155755111111111111111118f8888880505000533333f5fff553333014411144411001144445555333322220177677761100e6e
244422221ccccc113bb33b33155557511111111161111111888888ff5a5a000533633fffff4533331445544441000011444444443332222216777777f1000e67
42224442161d1d6133b3333315555551111111111c111111ff8ff8ff05555555333355ffff433333141554144100114144444455332222221f617717f100167e
111244221111111133333333315555111111111161111111ffffffff0555555033353fffa453333311554444441114415555555432222222117777777f111771
1112222411111111333333333311111311111111c6111111ffffffff0055005033333aaaaa433333414114444444441044444444222222220174f777f7777770
11111111444444449999999900000000c111111111111116000000000000000033333aaaaa333333014114444144441022222222233333330176777777777710
111111114444444490000009000000006c111111111111c1000000000000000033333aaaaa333333001444444144441122222222223333330017776776776711
1ccc111144444444900000090000000061111111111111c1000000000101000033333aaaaa33333300018844144454412200022222233333000167776777f771
11111111444554449000000909090007c111111111111116010100011101100133333aaaaa33333300011441444451412200022222223333000176777677f771
11cc1c1155555555900000099393900916111111111111c11b1b00011a1a100133333aaaa333333300001114414554102200022222222333000001767f717710
1111111144444444900000090999999961111111111111160111111111811111333332222333333300015514414551002222222222222233000001777ff11f10
11111111444444449000000909997790c1111111111111c10777777001111111333333222333333300001551111151002222222222222223000001176f111f10
11111111444444449000000900990090161111111111111600770070001100103333344443333333000011100001110022222222222222220000001111111110
11cccc113333333333333333333333333333333311111111111111110000000000000000000cc000ffffffffffffffff00000000000000000000000000000000
1cc55cc1333333443333333333333333333333331111111111111111000000000000000000cccc00ffffffffffffffff00000000000000000000500000505550
1c5555cc33334444444333333333373333333333111111111111111104400004400000070caccac0fffff55522ffffff04400004400000070000555555505050
cc55755c33334ffff44433333333333333733333111111888888111104477774400000070c8cc8c0ffffc5fffc5fffff04477774400000070000555555500055
c555575c33334f1f144333333333333333333333118888778878811104767774440000570cccccc0ffff5f1f151fffff047677744400005705505a555a500505
c555555c33333fffff333333833333333333333818888777887788110717777f440005750cccccc0ffffefffffefffff0717777f440005750055555555505005
1c5555cc33333ff1ff33333338888888888888831878887788777781047771ff4400577000c00c00ffffeff1ffefffff047771ff440057700005555d55550005
11ccccc13333dddddddd333388888888888888888877888888877788047777774477445000d00d00ffff1aaaaaaaffff04777777447744500005555555555005
55555555333d3ddddd3dd333833833333333833887778881118887880471f77f5477750000888800fffafaaaaafaafff0471f77f547775000000555555555005
5555555533dd3ddddd33d33333383333333383338788888118888881007f67776477750008855880ffaafaaaaaffafff007f6777647775000000555555555505
5555555533333ddddd33333333383333333383338888878888777881000777476777750808555588ffffffaaaaffffff00077747677775000000555555555555
55555555333335555533333333383333333383338887778877777781088788878887887088557558ffffffaa55ffffff00054777777077000000555555555505
55555555333335555533333333383333333383331877778877777881c60c0600060c00c085555758ffffff5555ffffff00057745740077000000055555555555
55555555333335555333333333383333333383331887778877777811000000000000000085555558ffffff5555ffffff00057755740057000000005500555550
55555555333333555333333333883333333388331118888887888111000000000000000008555588ffffff555fffffff00057757740054000000005000000500
55555555333334444333333333833333333338331111188888111111000000000000000000888880fffff99f99ffffff00004404440000000000055000055500
00000000333333333333333300000000000000001111111111111111000000000000000011111111222222220011110000000000000000004444444444444444
055555503733334433333c3344444444444444441111111111111111000000000000000011111111200000020115511000000000000000004444444444444444
05555550333344447443333344444444444444441111111111111111044000044000000711111111200000020155551104400004400000075555544455555444
055555503333cffff444333344455555555555441111118888881111047777744000000711111111200000021155755104777774400000074444555544445555
0555555033334f1f14433c3355554444445545551188887887788111447677744400005711111111200000021555575144767774440000574444444444444444
0555555033733fffff333333444454454444544418877778877788114717717f440005751111111120000002155555514717717f440005754444445544444455
0555555033333ff1ff3333334444a5a5444454441877777887777781477777ff44005770111111112000000201555511477777ff440057705555555455555554
000000003333ddddddd3333344445555555554441888788888878881077777774477445011111111200000020011111007777777447744504444444444444444
00000000333ddddddddd3333444455555555444487888811118888810071f77f547774003333333322222222333333330071f77f547774004444444444444444
60777707333d3ddddd3d333344444555544544448777888118877781007f677764777700336333332222222233333633007f6777647777004444444444444444
0773337833333ddddd3dd33355555555444555558777778888777781087777477777888033666633222222223333663300077747677777005555544455555444
0730303733333555553333334444444555555444877778877887778108877887887880c036666663222222223663663300047777777577004444555544445555
0733333733333d555d333333444444444444444418777887788778110c60c00c0606070033333333222222223663663300007747740577004444444444444444
0773037033333d555333333344444444444444441887887777887811000000000000000036666633222222223663663300007757550557004444445544444455
00777700333333555333333300000000000000001118887778888111000000000000000033666663222222223663333300000057550554005555555455555554
00400040333334444333333300000000000000001111118881111111000000000000000033333333222222223333333300000005550000004444444444444444
33333333000000003333333333333333333333333333333333333331133333333333333333333333000000000000000000000000000000000000000011000000
33333333000000003333333333333333333333333333333333333311113333333333555133333333000060000060000000000000000000000000011111000000
333333330000000033333333333334444444444333333333333331ffff1333333315511553111333000066777660606000000070000000000000111111111111
333333330008800033333333343444444994444333333333333331f1f11333333355531551155133000066777660006600000177100000001111111119900000
333333330008800033333333344444499999994333333333333331ffff13333331331131113551530000617771600606000011c7710000000000939993900099
333333330000000033333333411149999994494433333333333333711f3333333331111153311133000666777660600600011cc77c1000000060999999900009
333333330000000033333333411114444444111443333333333337ff51533333351133315133113300006677766600060001cc777c1100000000999a99900009
3333333300000000333333344111114411191111443133333333755555f3333333133333513311130000677f776660060001cc77777770000000995999900009
0000000088888888333333341111111411199144441333333333355555f33333351331315133151300006777776660070001c7777c1000000060057777990009
0bbbbbb088888188333334444111111411114449994333333333335555f3333335135131513335130000677777666607000017ccc11000000005597777ff9009
0b000b008818888833344444411111144114499999443333333333555533333335335331513335330000677777666667000017cc1100000000050f7777ff9909
0b00b0008888888833444449441111114449999999943333333333555533333335333331513333330000077777766607000077111000000000000f7777ff9909
0b0b00008888888834444499944414444999999999943333333333ccc333333333333551513333330000077777776677000000000000000000900f7777ff9909
0bb000008818881831449999999444111999991119443333333333ccc3333333333333513133333300000077707777700000000000000000009fff7777777799
0b0000008888888833779999944999911999911114433333333333cc113333333333333131533333000000770000770000000000000000000099999707777990
00000000888888883177999944999999999991151333333333333111113333333333333155533333000007700007770000000000000000000099977007999990
ffffffffffffffff3199499449999999999441151333333333333311113333337777777711111111000000004444494400000000000000000000001111100000
ff1331ff5ff53fff3149949799199999944431111333333333d33111111333337000000711111111000000b04444999400000000000000000000111111100000
ff1551155f111fff33114777111199994433311113333333633331ffff133333700000071111111100000bb04444949400000070000000000600111111111111
ff555f35511551ff33319977111119443333311133333333336331f1f113333370000007111111110000b0b04449999400000877800000001111111119900097
f1ff11f311f5315f33311499115114433333333333333333333331ffff1333337000000755555555000b00b044994444000088e7780000000000939993900099
fff111135ff131ff33331111115113333333333333333333333333711f333333700000071111111100b000b04994444400088ee77e8000000600999999900009
f531fff151ff13ff3333331311111333333333333333333333d337ff5153333370000007111111110bbbbbb0494944440008ee777e8800000000999a99900009
ff3fffff51ff111f333333331111133333333333333333333333855555533333700000071111111100000000444444440008ee77777770000600995999900009
f51ff1f351ff151f333333333311333333333333333333333333355555f33333444444444444444000000000666666660008e7777e8000000060057777990009
f53f51f353fff31f33333333333333333333333333333333333333555533333348369814444444540000000069929996000087eee88000000005597777ff9009
f5ff5ff151fff5ff33333333333333333333333333333333333333555533333348369814444444540000000069599896000087ee8800000000050f7777ff9909
f5fffff153fff3ff33333333333333333333333333333333333333555533333348369814444444590000000069995996000077888000000000000f7777ff9909
fffff55153ffffff33333333333333333333333333333333333333ccc333333348369814444444590000000069299916000000000000000000900f7777ff9909
ffffff51f3ffffff33333333333333333333333333333333333333ccc3333333483698144444445400000000666666660000000000000000009fff7777777799
fffffff1f35fffff33333333333333333333333333333333333333cc113333334836981444444454000000000060060000000000000000000099999707777990
fffffff1555fffff3333333333333333333333333333333333333111113333334737971444444440000000000600006000000000000000000099977007999990
33333311133333330000000000000000000000000000000033333333333333333333333333333333333333333333333333333333333333330000000000000000
3333311111333333000000000000000077777770000000003333333333333333777777733337777733333333333333337777777333377777aba8000000000000
333331fff13333330000000000000077111111770000000033333333333333771111117733371117333333333333337711111177333711170700777777770000
3333311f113333330000000000007711111111170000000033333333333377111111111733337117333333333333771111111117333371170000007788877000
333331fff13333330000000000071111111117117000000033333333333711111111171173337117333333333337111111111711733371170070000078870070
333331f1f1333333000000000771771111177771170000003333333337717711111777711733777733333333377177111117777117337777a77700a807700000
3333313f313333330070000077177777117788711700000033733333771711771177117117337333337333337717117711771171173373330070000007700000
333336777666f333077700071177888711788571170000003777333711771177117711711733733337773337117711771177117117337333ab7bab0007000000
33333677733333330777007711785887117788711770000037773377117777771177777117737333377733771177777711777771177373330070000070000700
3333367773333333077700711177887711177771117700003777337111771177111777711177733337773371117711771117777111777333ab7babab70000700
33333f77733333330070071111177771177177171177770033733711111117711771771711777333337337111111177117717717117773330000007700007770
3333331113333333007707111111711111711117177117703377371111117111117111171773733333773711111171111171111717737333000000a800000700
333333111333333300070711111111111171111117155170333737111111111111711111173337333337371c1111111111711111c73337330000077000000700
3333331113333333000771111117111111111111171551703337711111171111111111111733373333377c11111711177771111117333733ab00a80000700700
33333311133333330007711111771111111177711771177033377111117711111111777117333733333771111111777111111171173337330000700000000000
3333344344333333000071117777777111117111707447003333711177777771111171117333373333337111777711111111117173333733ab00000000000000
3333331133333333000071111111111777777111707447003333711111111117777771117333373333337111111111171117177173c337330000000000000000
333331111133333300007111111111111111111700077000333371111111111111111117333337333333c1111111111777711117333337330000000000000000
33333111f1333333000071111bbbbbb111bbbbb00000000033337111177777711177777333333733333371111777777171777773333337330000000000000000
3333311f13333333000007111b5555b111b555b00000000033333711171111711171117333333733333337111711117111711173333c37330000000000000000
3333311ff3333333000007111b5555b111b5555b0000000033333711171111711171111733333733333337111711117111711117333337330000000000000000
333331ff13333333000007711bbb55bbbbbbb55bbb00000033333771177711777777711777333733333337711777117777777117773337330000000bb000d000
3333311f3333333300000071111b55bb5b00b55b5b0000003333337111171177173371171733333333333371111711771733711717333333000dddbbbbdddd00
3333367776333333000000077777bbb55b00bbb55b00000033333337777777711733777117333333333333377777777117337771173333330dddddbbbbdddd00
3333367776333333000000000000bb555b000b55b000000033333333333377111733371173333333333333333333771117333711733333330ddd0d4bbf000000
333336777f333333000000000000b555bb00bb5bb0000000333333333333711177337717733333333333333333337111773377177333333300000044ff000000
33333f7773333333000000000000b55bb0000bb00000000033333333333371177333377333333333333333333333711773333773333333330000044ff0000000
3333331113333333000000000000bbbb000000000000000033333333333377773333333333333333333333333333777733333333333333330000044000000000
33333311133333330000000000000000000000000000000033333333333333333333333333333333333333333333333333333333333333330000010000000000
33333311133333330000000000000000000000000000000033333333333333333333333333333333333333333333333333333333333333330000000000000000
33333311133333330000000000000000000000000000000033333333333333333333333333333333333333333333333333333333333333330000000000000000
33333343443333330000000000000000000000000000000033333333333333333333333333333333333333333333333333333333333333330000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888eeeeee888777777888eeeeee888eeeeee888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88ee88eee88778887788ee888ee88ee8e8ee88888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8eeee8eee8777778778eeeee8ee8eee8e8ee88888e88888888888888888888888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8eeee8eee8777888778eeee88ee8eee888ee8888eee8888888888888888888888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee8eeee8eee8777877778eeeee8ee8eeeee8ee88888e88888888888888888888888888888ff888ff888822228888228222888882282888222288888
888eee888ee8eee888ee8777888778eee888ee8eeeee8ee888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8eeeeeeee8777777778eeeeeeee8eeeeeeee888888888888888888888888888888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee11111666161116661616166616661111166611661166111116161111171111111cc11ccc1ccc11111eee1e1e1eee1ee111111111111111111111
111111e11e11111116161611161616161611161611111616161616111111161611111171111111c1111c1c1c111111e11e1e1e111e1e11111111111111111111
111111e11ee1111116661611166616661661166111111666161616661111116111111117111111c11ccc1ccc111111e11eee1ee11e1e11111111111111111111
111111e11e11111116111611161611161611161611111611161611161111161611111171111111c11c111c1c111111e11e1e1e111e1e11111111111111111111
11111eee1e1111111611166616161666166616161171161116611661117116161111171111111ccc1ccc1ccc111111e11e1e1eee1e1e11111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111666166616661666166617711cc1117711111ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116111616161616661611171111c111171777111c11111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116611661166616161661171111c1111711111ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116111616161616161611171111c1111717771c1111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111611161616161616166617711ccc117711111ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166616161111111111111cc11c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111666161611111777111111c11c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111616116111111111111111c11ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111616161611111777111111c11c1c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616161111111111111ccc1ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111666161116661616166616661111166611661166111116161111111111111cc111111111111111111111111111111111111111111111111111111111
1111111116161611161616161611161611111616161616111111161611111777111111c111111111111111111111111111111111111111111111111111111111
1111111116661611166616661661166111111666161616661111116111111111111111c111111111111111111111111111111111111111111111111111111111
1111111116111611161611161611161611111611161611161111161611111777111111c111111111111111111111111111111111111111111111111111111111
111111111611166616161666166616161171161116611661117116161111111111111ccc11111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1eee1eee1e1e1eee1ee111111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e1e1e1111e11e1e1e1e1e1e11111c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111ee11ee111e11e1e1ee11e1e11111c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e1e1e1111e11e1e1e1e1e1e11111c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e1e1eee11e111ee1e1e1e1e11111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1e1e1eee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaeeeaeeeaaaaa666a6aaa666a6a6a666a666aaaaa666aa66aa66aaaaa6a6aaaaaaa7aaaaacccaaaaaeeeaeeaaeeaaaaaa666a666a666a666a666a77aacca
aaaaaaeaaeaaaaaaa6a6a6aaa6a6a6a6a6aaa6a6aaaaa6a6a6a6a6aaaaaaa6a6aaaaaa7aaaaaacacaaaaaeaeaeaeaeaeaaaaa6aaa6a6a6a6a666a6aaa7aaaaca
aaaaaaeaaeeaaaaaa666a6aaa666a666a66aa66aaaaaa666a6a6a666aaaaaa6aaaaaa7aaaaaaacacaaaaaeeeaeaeaeaeaaaaa66aa66aa666a6a6a66aa7aaaaca
aaaaaaeaaeaaaaaaa6aaa6aaa6a6aaa6a6aaa6a6aaaaa6aaa6a6aaa6aaaaa6a6aaaaaa7aaaaaacacaaaaaeaeaeaeaeaeaaaaa6aaa6a6a6a6a6a6a6aaa7aaaaca
aaaaaeeeaeaaaaaaa6aaa666a6a6a666a666a6a6aa7aa6aaa66aa66aaa7aa6a6aaaaaaa7aaaaacccaaaaaeaeaeaeaeeeaaaaa6aaa6a6a6a6a6a6a666a77aaccc
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaa666a6a6aaaaaaaaaaaaacccaaaaa1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaa666a6a6aaaaa777aaaaacacaaaaa1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaa6a6aa6aaaaaaaaaaaaaacacaaaaa1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaa6a6a6a6aaaaa777aaaaacacaaaaa1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaa6a6a6a6aaaaaaaaaaaaacccaaaaa1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa11111111111111111111111111111111111111111111111
aaaaaaaaa666a6aaa666a6a6a666a666aaaaa666aa66aa66aaaaa6a6aaaaaaaaaaaaaccaacccaaaaa11111111111111111111111111111111111111111111111
aaaaaaaaa6a6a6aaa6a6a6a6a6aaa6a6aaaaa6a6a6a6a6aaaaaaa6a6aaaaa777aaaaaacaacacaaaaa11111111111111111111111111111111111111111111111
aaaaaaaaa666a6aaa666a666a66aa66aaaaaa666a6a6a666aaaaaa6aaaaaaaaaaaaaaacaacacaaaaa11111111111111111111111111111111111111111111111
aaaaaaaaa6aaa6aaa6a6aaa6a6aaa6a6aaaaa6aaa6a6aaa6aaaaa6a6aaaaa777aaaaaacaacacaaaaa11111111111111111111111111111111111111111111111
aaaaaaaaa6aaa666a6a6a666a666a6a6aa7aa6aaa66aa66aaa7aa6a6aaaaaaaaaaaaacccacccaaaaa11111111111111111111111111111111111111111111111
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaeeeaeeeaeeeaeaeaeeeaeeaaaaaacccaaaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaeaeaeaaaaeaaeaeaeaeaeaeaaaaacacaaaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaeeaaeeaaaeaaeaeaeeaaeaeaaaaacacaaaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaeaeaeaaaaeaaeaeaeaeaeaeaaaaacacaaaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaeaeaeeeaaeaaaeeaeaeaeaeaaaaacccaaaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa111111111111111111111111111
aaaaaeeeaeaaaaeeaeeeaeeeaeeeaaaaa666a666a666a666a666a77aaccaaa77aaaaaaaaacccaaaaaeeeaeaeaeeeaeeaaaaaa111111111111111111111111111
aaaaaeaaaeaaaeaaaeaaaaeaaeaaaaaaa6aaa6a6a6a6a666a6aaa7aaaacaaaa7a777a777aaacaaaaaaeaaeaeaeaaaeaeaaaaa111111111111111111111111111
aaaaaeeaaeaaaeeeaeeaaaeaaeeaaaaaa66aa66aa666a6a6a66aa7aaaacaaaa7aaaaaaaaacccaaaaaaeaaeeeaeeaaeaeaaaaa111111111111111111111111111
aaaaaeaaaeaaaaaeaeaaaaeaaeaaaaaaa6aaa6a6a6a6a6a6a6aaa7aaaacaaaa7a777a777acaaaaaaaaeaaeaeaeaaaeaeaaaaa111111111111111111111111111
aaaaaeeeaeeeaeeaaeeeaeeeaeaaaaaaa6aaa6a6a6a6a6a6a666a77aacccaa77aaaaaaaaacccaaaaaaeaaeaeaeeeaeaeaaaaa111111111111111111111111111
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaa666a6a6aaaaaaaaaaaaacccaaaaaaaaa111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaa666a6a6aaaaa777aaaaacacaaaaaaaaa111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaa6a6aa6aaaaaaaaaaaaaacacaaaaaaaaa111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaa6a6a6a6aaaaa777aaaaacacaaaaaaaaa111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaa6a6a6a6aaaaaaaaaaaaacccaaaaaaaaa111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1111111111111111111111111111111111111111111
aaaaaaaaa666a6aaa666a6a6a666a666aaaaa666aa66aa66aaaaa6a6aaaaaaaaaaaaaccaacccacccaaaaa1111111111111111111111111111111111111111111
aaaaaaaaa6a6a6aaa6a6a6a6a6aaa6a6aaaaa6a6a6a6a6aaaaaaa6a6aaaaa777aaaaaacaaaacaaacaaaaa1111111111111111111111111111111111111111111
aaaaaaaaa666a6aaa666a666a66aa66aaaaaa666a6a6a666aaaaaa6aaaaaaaaaaaaaaacaacccaaacaaaaa1111111111111111111111111111111111111111111
aaaaaaaaa6aaa6aaa6a6aaa6a6aaa6a6aaaaa6aaa6a6aaa6aaaaa6a6aaaaa777aaaaaacaacaaaaacaaaaa1111111111111111111111111111111111111111111
aaaaaaaaa6aaa666a6a6a666a666a6a6aa7aa6aaa66aa66aaa7aa6a6aaaaaaaaaaaaacccacccaaacaaaaa1111111111111111111111111111111111111111111
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaeeeaeeeaeeeaeaeaeeeaeeaaaaaacccaaaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaeaeaeaaaaeaaeaeaeaeaeaeaaaaacacaaaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaeeaaeeaaaeaaeaeaeeaaeaeaaaaacacaaaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaeaeaeaaaaeaaeaeaeaeaeaeaaaaacacaaaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaeaeaeeeaaeaaaeeaeaeaeaeaaaaacccaaaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaaaaaaaaaaaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaeeeaeaaaaeeaeeea11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaeaaaeaaaeaaaeaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaeeaaeaaaeeeaeeaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaeaaaeaaaaaeaeaaa11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaeeeaeeeaeeaaeeea11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111dd111dd1ddd1dd11d1d1dd111dd111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111d1d1d1d11d11d1d1d1d1d1d1d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ddd1ddd11111d1d1d1d11d11d1d1ddd1d1d1d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111d1d1d1d11d11d1d1d1d1d1d1d1d111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111d1d1dd111d11d1d1d1d1d1d1ddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1e1e1eee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb1bbb11711666161611111ccc11111ccc111111111ccc111111111cc11c11111111111cc11c111171111111111111111111111111111111111111
11111bbb1b1b1b1b17111666161611111c1c11111c1c111111111c1c1111111111c11c111111111111c11c111117111111111111111111111111111111111111
11111b1b1bbb1bbb17111616116111111c1c11111c1c111111111c1c1111111111c11ccc1111111111c11ccc1117111111111111111111111111111111111111
11111b1b1b1b1b1117111616161611711c1c11711c1c117111111c1c1171111111c11c1c1171111111c11c1c1117111111111111111111111111111111111111
11111b1b1b1b1b1111711616161617111ccc17111ccc171111111ccc171111111ccc1ccc171111111ccc1ccc1171111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee11111666161116661616166616661111166611661616166616661666166111111eee1e1e1eee1ee1111111111111111111111111111111111111
111111e11e11111116161611161616161611161611111616161616161611161616111616111111e11e1e1e111e1e111111111111111111111111111111111111
111111e11ee1111116661611166616661661166111111666161616161661166116611616111111e11eee1ee11e1e111111111111111111111111111111111111
111111e11e11111116111611161611161611161611111611161616661611161616111616111111e11e1e1e111e1e111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822882288882822882228222888888888888888888888888888888888888888882828228888882228822828282228228882288866688
82888828828282888888882888288828882882828882888888888888888888888888888888888888888882828828888888288282828282888282828888888888
82888828828282288888882888288828882882228882888888888888888888888888888888888888888882228828888888288282822882288282822288822288
82888828828282888888882888288828882888828882888888888888888888888888888888888888888888828828888888288282828282888282888288888888
82228222828282228888822282228288822288828882888888888888888888888888888888888888888888828222888888288228828282228282822888822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0000000001000800000000000303000004000100010300000000000003030000020000120003000000000000020000000008040203030000000000000000000012000000000000000000000000000000000000000000000000130000000000000000000000000000000000120000020200000000000000000000000000000202
0301000000000000030300000000000001030000000000000303000000000000030300000000000004000100000000000303000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0c0d808080808080808080061604111135158889888988898889888988890c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d91919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191919120202020202020202020202020202020
1c1d230303031303032303261614111135159899989998999899989998991c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d91000000000000000000000000000091910000000000000000000000000000919100000000000000000000000000009120202020202020202020202020202020
8013030303030303030303061604111135152203030303030303030303030c0d0c0d2313230303434403222303230c0d0c0d0303030303030303038889030c0d910000000000000000000000000000919100000000000000000000000059009191ba00000000006b6b000000000000912020babababababababababababa2020
8003030303030303030303061604111135151322030303030303030303031c1d1c1d0303220303535403130313131c1d1c1d0388890303035003039899031c1d910000000000000000000000000000919100000000000000000000000059009191ba00000000000000000000000000912020babababababababababababa2020
8079030303030303031303061604111435150313030303030303030303030c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d039899032d7a5003030303030c0d9100000000000000000000000000009191000059ba596b590000baba5959599191ba0000ba00006b000000ba6b0000912020babababababababababababa2020
8003033131030303030303061604111135151303030303030303030303031c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d0303032d7a7a503d2d3d03031c1d910000000000000000000000000000919100baba000000000000ba590000009191ba000000000000000000ba000000912020babababababababababababa2020
2424243131242424242424242404111135152213030303030303030303030c0d0c0d0303030303030303030303030c0d0c0d0322032c2c2c2c2c2c2c03030c0d91000000000000000000000000000091916b6bbaba0000000000ba6b00ba6b9191bababa00000000000000006b0000912020babababababababababababa2020
0404043131041404040404040404111135152203030303030303030303031c1d1c1d0303030303030303220303031c1d1c1d0303032c6a326a2c2c2c03031c1d910000000000000000000000000000bababababa000000000000baba00babababababa6b0000000000000000000000912020babababababababababababa2020
1515153131151515151515151515151515150313030303030303030303030c0d0c0d030303030303030303030303030303030303030303790303030303030c0d910000000000000000000000000000bababababa000000000000baba00babababababa6b00000000000000006b0000912020babababababababababababa2020
8003033131031323030303030313030303030303030303030303030303031c1d1c1d030303030303030303030303037b7b7b7b7b7b7b7b790322030303031c1d91000000000000000000000000000091916b6bbaba0000000000ba6b00ba6b9191bababa0000000000000000000000912020babababababababababababa2020
8013030303030303031303790303030303030303030303030303030303030c0d0c0d030303030303030303030303030303030303030303030303030303030c0d910000000000000000000000000000919100baba000000000000ba590000009191ba000000000000000000006b0000912020babababababababababababa2020
2303030303030303030303030303030303030303030303030303030303031c1d1c1d0303030303030303030303030c0d0c0d0313030303030303031303031c1d9100000000000000000000000000009191000059ba596b590000baba5959599191ba0000ba00006b000000ba000000912020babababababababababababa2020
0505050505050505050505050505050505050505050303030303030303030c0d0c0d0303031303030303030313031c1d1c1d0303030303030303030303030c0d910000000000000000000000000000919100000000000000000000000059009191ba000000000000000000ba000000912020babababababababababababa2020
1515151515151515151515151515151515151515150303030303030303031c1d1c1d0303030303030303030303030c0d0c0d0303030303030303030303031c1d9100000000000000000000000000009191000000000000000000000000590091910000000000006b6b000000000000912020babababababababababababa2020
2424242424242424242424242424242424242406150303030303030303030c0d0c0d0303030303030303030303031c1d1c1d0303030303030303030303030c0d9100000000000000000000000000009191000000000000000000000000000091910000000000000000000000000000912020babababababababababababa2020
0404040404040404040404040404040404040406150303030303030303031c1d1c1d2303030303030303030303230c0d0c0d0303030303030303030303031c1d91919191919191101091919191919191919191919191919191919191919191919191919191919191919191919191919120202020202020101020202020202020
0404040404041404040404040414040404040406150303030303030303030c0d0c0d0303030303030303030303031c1d1c1d0303030303030303030303031c1d0303030303030303030388890303030303030303030303030303030303030303404040404040404040404040404040402c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c
0404040404040404040414040404040404140406150303030303030303031c1d1c1d0303030303030303030303030c0d0c0d0303030303030303030303030c0d0388890322030303030398990303030303030c0d03031313030303030c0d0303400404040404040404040404040404402c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c
0404040404040404040404040404040404040406150303112d3c3d110303030303030303030303030303030303221c1d1c1d0322030303030303030303131c1d0398990303030303030322220303030313031c1d03030303031303031c1d0303400404040404060606060606060604402c2c70b8b8b8b87070b8b8b8b8702c2c
1111111111111111111111111104040404040406150303112c2c2c110303030303030303030303030303030303030c0d0c0d0303030303030303130303030c0d0303030303030303030322030303030303030303030388890c0d030303130303400406046969060303030606060604402c2cbabababababababababababa2c2c
1111111111111111111111111104040404041406150303112c322c110303030303030303030303030303030303031c1d1c1d1303030303030303030303031c1d8889888903038889888903038889888903888903030398991c1d038889030303400406060606032d3c3d0306060404402c2cb9bababababababababababa2c2c
1111111111111111111111111104040404040406152303030303030303030c0d0c0d0303032203030303030303030c0d0c0d8889030303030303030388890c0d9899989903039899989903039899989903989913031303030303039899030303400406060606032c2c2c0306060604402c2cb9baa9a9a9a9a9a9a9a9baba2c2c
1111111111111111111111111104040404040406150303030303030303031c1d1c1d0303030303030303030303031c1d1c1d9899030303030303030398991c1d0505050505050505050505050505050505050505050505050505050505050505400406060606032ca82c0306060604402c2cbabaa9a9a9a9a9a9a9a9ba702c2c
111111111111111111111111110404040404040615151515151515151515151515151515151515153131313115151515151515151515151515151515151515150505050505050505050505050505050505050505050505050505050505050505400404160606030303030306060604402c2cb9baa9a9a9a9a9a9a9a9ba702c2c
1111111111111111111111111104040414040406060606060606060606060606060606060606060631313131060606060606060606060606060606060606060640404040404040404040404040404040404040404040404040404040404040404004040606060606060606a0a11404402c2cb9baa9a9a9a9a9a9a9a9babb2c2c
1111111111111111111111110404040404040404040404040404040404040404400404040404046931313131690404042404040404040404040404040424240404040404040404040404040404040404040404040404040404040404040404040404040416060606061606b0b10404402c2cbabaa9a9b8b8b8b8a9a9ba702c2c
111111111111111111111111111104040404040404040404040404040404040440040404040404693131313169040404040404040404040404140404040404040404403004040404040404040440044014040404040440040404400404044069046904040606160606060606060604402c2cb9baa9a9a9a9a9a9a9a9ba702c2c
111111111111111111111111040404040404040404040404041404040404040440040430040404693131313169040404040414040404040404040404300404040404040404044004040404040469040404044004040404040404040404043004040469040606060606060606060404402c2cb9baa9a9a9a9a9a9a9a9baba2c2c
111111111111111111111111111104040404043004040404040404040404040440040404040404692424242469040404040404040404040404040404040404040404040404040404040404400404040404040404040404040414040414044069040404040406060606060604040404402c2cbabababababababababababa2c2c
111111111111111111111111111104040404040404040404040404040404040440040404040404696969696969040404040404040404040404040404040404040430046904400404041404040404406969040404044004040404040404696904304004040404040606060430040404402c2cbabababababababababababa2c2c
111111111111111111111111111104040404040404040404040404040404040440040404040404040404040404300404040404040404040404040404040404040404040404040404040404040404300404040404040404040404040404044069040404040404040404040404040404402c2c2c2c2c2c101010102c2c2c2c2c2c
111111111111111111111111110404040404040404040404040404040404040440404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040402c2c2c2c2c2c101010102c2c2c2c2c2c
__sfx__
00090000007000070000700127500d750127500d75000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
38060000000500000000150001500015001150031500615007150091500a1500c1500d1500d1500f150101501315015150161501b3501e350223503c7503c7503c7503c7503c7503c7503c7503c7503c7503c750
00060000000000000000000000000000000000000000000000000000000c050000000405000000110500000000050000000000000000000000000000000000000000000000000000000000000000000000000000
000600002d5502b55028550245501e55015550115500b55004550045500070010000160001b0001d0001b0001700012000130000c0000600001000000000000002000000000d0000100001000010000000000000
00100000001000a150051500d15004150011501610002150001000115000100021500010018100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00010000004001c150127502125000400231501a75028250282500040003000004000040000400124001240000400114000040000400004000040000400004000040000400004000040000400004000040000400
0004000000000000000a6201262029620326203d6203d750000000000000000000000000004620096201362026620336203e6203d150000000000000000000000000000000000000000000000000000000000000
00050000007001b7500070000700007000b75000700007001a7500070000700017100070003700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00050000003001a330003000030008330003001832000300063300030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000500000060019650006000060008650006001865000600076500060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0005000000600006002b25000600192500c6500d6500f650184501465017650196501b65028250092501f65000600206502f25020650006002065025450006001865029250176501b65000600006000060000600
000300000000000000082500b25011250182501f25026250332502025024250253502035016250153500a25011250002500935008250190201202011020110200000000000000000000000000000000000000000
001000001915019150191500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000005000050000500005000050000500005000050000500005001b5502055025550295502e5500050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0003000009050090500a0200b0200c0500e020110500b050130500d01016050190501b0201d0301f01020050295502a55023050240102e5502d010280502f0103552023020360202b020390203b0103e5103e750
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000070014720007000070000700130200070000700267400070002020013100e7200e7000d710070200d7000e7400131000700021100302005720007100711000700060500e71000700007000070005050
001400000000000000013100131001000000000130001010013100100001000010000130001010013000330003000030000201002020010100231001000023100001001300000000001001300000000000000010
001000000000000000005500000000000050500000000000006100000001630000000102000000000000041002420000000000001020000000001003010030100000000000000000041000400015100041000000
001000000000000000000000011000130001200012000110001100012000120011100111001110011100112001120021300213002130021300212002120011300002000020000300411000030041100002000000
001000000b7500b750007000070000700007000a750007000070000700007000070000700007000a750007000070000700007000070000700007000b75000700007000070011750007000a750007000070000700
00100118000000e0100b0100b0100601001000090100901009020030100901009020020100902002010010100501007020070100f0101a0000d010030300b0200000000000000000000000000000000000000000
040600100e0101f0000000000000000000100001000000000e000000000000000000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2140000006000462000600006000060010620006000660000600006000d620006200060006620006001b620006000060005600006201962000620086000060000600006000d6300060006600006000262000600
001008001040010410104101d40000400004000040014410004000040000400004000040000400004000942000400004000040000400004000040000400004000040000430004000040000400004000040000400
__music__
01 14555b58
01 41154344
00 56421644
01 58424318

