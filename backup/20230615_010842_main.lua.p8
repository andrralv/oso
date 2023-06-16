pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- main --

function _init()
 setup_game()
 clock = 1
end

function start_clock()
	if clock<2.9 then
		clock=clock+.05
	else
		clock=1
	end
end

function _update(dt)
	start_clock()
	if world.mode == "lost" then
		if btnp()>0 then
			world.mode = "title"
			return 0
		end
	end
	if world.mode == "title" then
	 if btnp(❎) then
		 location = 0
		 world.mode = "select"
		 return 0
	 end
	end
 if world.mode == "select" then
	 if btnp(➡️) and player.num+1 < #characters+1 then
		 player = characters[player.num+1]
		else if btnp(⬅️) and player.num-1 > 0 then
			player = characters[player.num-1]
		end
		if btnp(❎) then
		 world.mode = "active"		
  end
  return 0
	end
	end
 if world.mode == "active" then
 	move_player()
 	run_hazards()
	end	
end

function draw_grass()
	for i,a in ipairs(animated.grass) do
		spr(animations.grass[flr(clock)], a.x, a.y)
	end
end

function draw_currents()
	for i,a in ipairs(animated.currents) do
		spr(animations.currents[flr(clock)], a.x, a.y)
	end
end

function draw_player_bigsprite()
 if player.name == "oso" then
  spr(player.bigsprite[flr(clock)],player.pos.x,player.pos.y,2,2)
 end
end

function _draw()
	cls()
	if world.mode == "title" then
	 centertext("perritos callejeros",7,0,0)
	 print("❎", 60, 80, 7)
	end
	if world.mode == "select" then
		draw_select()	
	end	
	if world.mode == "active" then
		draw_map()
		draw_grass()	
		draw_currents()
		print("pollitos: " ..pollitos)
		if player.powered then
		 draw_player_bigsprite()
		else
	  spr(player.sprite, player.pos.x, player.pos.y)
	 end
	 for i,d in ipairs(drummetes) do
	 	spr(d.sprite, d.pos.x, d.pos.y)
	 end
	end	
	if debug.warning then
	 print(debug.warning)
	end
	if world.mode == "lost" then
	 centertext(world.lost_description,7,0)
	end
 if world.mode == "win" then
		centertext(player.name.. " se termino el pollito!",7,0)
 end
end

-->8
-- physics --

function collide(obj, other)
  if
    other.pos.x+other.hitbox.x+other.hitbox.w > obj.pos.x+obj.hitbox.x and 
    other.pos.y+other.hitbox.y+other.hitbox.h > obj.pos.y+obj.hitbox.y and
    other.pos.x+other.hitbox.x < obj.pos.x+obj.hitbox.x+obj.hitbox.w and
    other.pos.y+other.hitbox.y < obj.pos.y+obj.hitbox.y+obj.hitbox.h 
  then
    return true
  end
end
-->8
-- world --

function draw_map()
 camera(0,0)
 map(0, 0, 0, 0, 16, 16)
end

function draw_select()
	print("seleccione un perrito", 22, 20, 7)
	print("⬅️ ➡️", 54, 33, 7)
	spr(player.sprite, 60, 50)
	centertext(player.name, 7, 10,0)
	print("❎", 60, 80, 7)
end

function get_location_spr(obj)
 location = mget(flr((obj.pos.x+4)/8), flr((obj.pos.y+4)/8))
 return location
end

function get_location_spr_by_coords(x, y)
 location = mget(flr((x+4)/8), flr((y+4)/8))
 return location
end

function setup_game()
	position=100
 location=0
 pollitos=0
 debug={}
 timer=0
 tiles = {}
 tiles.grass = 19
 tiles.current = 20
 animated = {}
 animated.grass = {}
 animated.currents = {}
 animations = {}
 animations.grass = {19, 34}
 animations.currents = {20, 48}
 debug.message = ""
 debug.warning = ""
	world = {}
	music(00)
	world.sprites = {}
	world.mode = "title"
	world.sprites.water = 4
	world.sprites.shore_up = 36
	game_over=false
	player = characters[1]
	player.pos = {x=63,y=63}
	player.hitbox = {x=0,y=0,w=5,h=5}
	drummetes={}
	poison = flr(rnd(5))
	spawn_pollitos()
	spawn_grass()
	spawn_currents()
end

function spawn_grass()
 for x=0,100 do
 	for y=0,100 do
	 	t = mget(x,y)
	 	if t == tiles.grass then
	 		anim = {}
	 		anim.x = x*8
	 		anim.y = y*8
	 		add(animated.grass, anim)
	 	end
 	end
 end
end

function spawn_currents()
 for x=0,100 do
 	for y=0,100 do
	 	t = mget(x,y)
	 	if t == tiles.current then
	 		anim = {}
	 		anim.x = x*8
	 		anim.y = y*8
	 		add(animated.currents, anim)
	 	end
 	end
 end
end

function spawn_pollitos()
	for i=1,5 do
		drum = {}
		drum.pos = {}
		drum.hitbox = {}
		_x = flr(rnd(100))
		_y = flr(rnd(100))
		temp_spr = get_location_spr_by_coords(_x,_y)
		-- debug.warning = temp_spr
		if temp_spr==world.sprites.shore_up or temp_spr==world.sprites.water then
   drum.pos.x = 0
   drum.pos.y = 0
  else
   drum.pos.x = _x
   drum.pos.y = _y
  end	
  drum.hitbox.x = 0
  drum.hitbox.y = 0
  drum.hitbox.w = 5
  drum.hitbox.h = 5
 	if i==poison then
			drum.poison = true
			drum.sprite = 18
		else 
		 drum.sprite = 2
			drum.poison = false
		end
		add(drummetes, drum)
	end
end

function move_player() 
 	location = get_location_spr(player)
		if btn(➡️) then
			player.pos.x = player.pos.x + 3
		end
		if btn(⬅️) then
			player.pos.x = player.pos.x - 3
		end
		if btn(⬆️) then
			player.pos.y = player.pos.y - 3
		end
		if btn(⬇️) then
			player.pos.y = player.pos.y + 3
		end
end

function run_hazards()
 -- poison
	for i,d in ipairs(drummetes) do
		if collide(player,d) then
			if d.poison == true then
			 sfx(03)
				world.mode = "lost"
				world.lost_description = "el pollito estaba envenenado :("
				d.sprite = 18
			end
			del(drummetes,d)
			pollitos = pollitos + 1
			if #drummetes==1 then
			 sfx(01)
			 player.powered = true
			elseif #drummetes > 0 then
				sfx(00)
			end	
	 end
	end
	 -- water
	 if location==world.sprites.water then
	  location=0
 	 if world.mode != "lost" then
 	 	setup_game()
 		 sfx(03)
 		 world.mode = "lost"
 		 world.lost_description = "se murio en el agua :("
 	 end
  end
end
-->8
local bump = {
  _version     = 'bump v3.1.7-pico8',
  _url         = 'https://github.com/ruairid/pico8-bump.lua',
  _description = 'a collision detection library for lua, adapted for pico-8',
  _license     = [[
    mit license

    copyright (c) 2014 enrique garcれとa cota

    permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "software"), to deal in the software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the software, and to
    permit persons to whom the software is furnished to do so, subject to
    the following conditions:

    the above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the software.

    the software is provided "as is", without warranty of any kind, express
    or implied, including but not limited to the warranties of
    merchantability, fitness for a particular purpose and noninfringement.
    in no event shall the authors or copyright holders be liable for any
    claim, damages or other liability, whether in an action of contract,
    tort or otherwise, arising from, out of or in connection with the
    software or the use or other dealings in the software.
  ]]
}

------------------------------------------
-- auxiliary functions
------------------------------------------
local huge = 32767 -- 16-bit max because pico-8 uses 16 bit ints.
local delta = 0.0000000001 -- floating-point margin of error

local floor = flr

local function sort(a, f)
    for i=1,#a do
        local j = i
        while j > 1 and f(a[j-1], a[j]) do
            a[j],a[j-1] = a[j-1],a[j]
            j = j - 1
        end
    end
end


local function sign(x)
  if x > 0 then return 1 end
  if x == 0 then return 0 end
  return -1
end

local function nearest(x, a, b)
  if abs(a - x) < abs(b - x) then return a else return b end
end

local defaultfilter = function()
  return 'slide'
end

------------------------------------------
-- rectangle functions
------------------------------------------

local function rect_getnearestcorner(x,y,w,h, px, py)
  return nearest(px, x, x+w), nearest(py, y, y+h)
end

-- this is a generalized implementation of the liang-barsky algorithm, which also returns
-- the normals of the sides where the segment intersects.
-- returns nil if the segment never touches the rect
-- notice that normals are only guaranteed to be accurate when initially ti1, ti2 == -math.huge, math.huge
local function rect_getsegmentintersectionindices(x,y,w,h, x1,y1,x2,y2, ti1,ti2)
  ti1, ti2 = ti1 or 0, ti2 or 1
  local dx, dy = x2-x1, y2-y1
  local nx, ny
  local nx1, ny1, nx2, ny2 = 0,0,0,0
  local p, q, r

  for side = 1,4 do
    if     side == 1 then nx,ny,p,q = -1,  0, -dx, x1 - x     -- left
    elseif side == 2 then nx,ny,p,q =  1,  0,  dx, x + w - x1 -- right
    elseif side == 3 then nx,ny,p,q =  0, -1, -dy, y1 - y     -- top
    else                  nx,ny,p,q =  0,  1,  dy, y + h - y1 -- bottom
    end

    if p == 0 then
      if q <= 0 then return nil end
    else
      r = q / p
      if p < 0 then
        if     r > ti2 then return nil
        elseif r > ti1 then ti1,nx1,ny1 = r,nx,ny
        end
      else -- p > 0
        if     r < ti1 then return nil
        elseif r < ti2 then ti2,nx2,ny2 = r,nx,ny
        end
      end
    end
  end

  return ti1,ti2, nx1,ny1, nx2,ny2
end

-- calculates the minkowsky difference between 2 rects, which is another rect
local function rect_getdiff(x1,y1,w1,h1, x2,y2,w2,h2)
  return x2 - x1 - w1,
         y2 - y1 - h1,
         w1 + w2,
         h1 + h2
end

local function rect_containspoint(x,y,w,h, px,py)
  return px - x > delta      and py - y > delta and
         x + w - px > delta  and y + h - py > delta
end

local function rect_isintersecting(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and x2 < x1+w1 and
         y1 < y2+h2 and y2 < y1+h1
end

local function rect_getsquaredistance(x1,y1,w1,h1, x2,y2,w2,h2)
  local dx = x1 - x2 + (w1 - w2)/2
  local dy = y1 - y2 + (h1 - h2)/2
  return dx*dx + dy*dy
end

local function rect_detectcollision(x1,y1,w1,h1, x2,y2,w2,h2, goalx, goaly)
  goalx = goalx or x1
  goaly = goaly or y1

  local dx, dy      = goalx - x1, goaly - y1
  local x,y,w,h     = rect_getdiff(x1,y1,w1,h1, x2,y2,w2,h2)

  local overlaps, ti, nx, ny

  if rect_containspoint(x,y,w,h, 0,0) then -- item was intersecting other
    local px, py    = rect_getnearestcorner(x,y,w,h, 0, 0)
    local wi, hi    = min(w1, abs(px)), min(h1, abs(py)) -- area of intersection
    ti              = -wi * hi -- ti is the negative area of intersection
    overlaps = true
  else
    local ti1,ti2,nx1,ny1 = rect_getsegmentintersectionindices(x,y,w,h, 0,0,dx,dy, -1 * huge, huge)
    -- item tunnels into other
    if ti1
    and ti1 < 1
    and (abs(ti1 - ti2) >= delta) -- special case for rect going through another rect's corner
    and (0 < ti1 + delta
      or 0 == ti1 and ti2 > 0)
    then
      ti, nx, ny = ti1, nx1, ny1
      overlaps   = false
    end
  end

  if not ti then return end

  local tx, ty

  if overlaps then
    if dx == 0 and dy == 0 then
      -- intersecting and not moving - use minimum displacement vector
      local px, py = rect_getnearestcorner(x,y,w,h, 0,0)
      if abs(px) < abs(py) then py = 0 else px = 0 end
      nx, ny = sign(px), sign(py)
      tx, ty = x1 + px, y1 + py
    else
      -- intersecting and moving - move in the opposite direction
      local ti1, _
      ti1,_,nx,ny = rect_getsegmentintersectionindices(x,y,w,h, 0,0,dx,dy, -1 * huge, 1)
      if not ti1 then return end
      tx, ty = x1 + dx * ti1, y1 + dy * ti1
    end
  else -- tunnel
    tx, ty = x1 + dx * ti, y1 + dy * ti
  end

  return {
    overlaps  = overlaps,
    ti        = ti,
    move      = {x = dx, y = dy},
    normal    = {x = nx, y = ny},
    touch     = {x = tx, y = ty},
    itemrect  = {x = x1, y = y1, w = w1, h = h1},
    otherrect = {x = x2, y = y2, w = w2, h = h2}
  }
end

------------------------------------------
-- grid functions
------------------------------------------

local function grid_toworld(cellsize, cx, cy)
  return (cx - 1)*cellsize, (cy-1)*cellsize
end

local function grid_tocell(cellsize, x, y)
  return floor(x / cellsize) + 1, floor(y / cellsize) + 1
end

-- grid_traverse* functions are based on "a fast voxel traversal algorithm for ray tracing",
-- by john amanides and andrew woo - http://www.cse.yorku.ca/~amana/research/grid.pdf
-- it has been modified to include both cells when the ray "touches a grid corner",
-- and with a different exit condition

local function grid_traverse_initstep(cellsize, ct, t1, t2)
  local v = t2 - t1
  if     v > 0 then
    return  1,  cellsize / v, ((ct + v) * cellsize - t1) / v
  elseif v < 0 then
    return -1, -cellsize / v, ((ct + v - 1) * cellsize - t1) / v
  else
    return 0, huge, huge
  end
end

local function grid_traverse(cellsize, x1,y1,x2,y2, f)
  local cx1,cy1        = grid_tocell(cellsize, x1,y1)
  local cx2,cy2        = grid_tocell(cellsize, x2,y2)
  local stepx, dx, tx  = grid_traverse_initstep(cellsize, cx1, x1, x2)
  local stepy, dy, ty  = grid_traverse_initstep(cellsize, cy1, y1, y2)
  local cx,cy          = cx1,cy1

  f(cx, cy)

  -- the default implementation had an infinite loop problem when
  -- approaching the last cell in some occassions. we finish iterating
  -- when we are *next* to the last cell
  while abs(cx - cx2) + abs(cy - cy2) > 1 do
    if tx < ty then
      tx, cx = tx + dx, cx + stepx
      f(cx, cy)
    else
      -- addition: include both cells when going through corners
      if tx == ty then f(cx + stepx, cy) end
      ty, cy = ty + dy, cy + stepy
      f(cx, cy)
    end
  end

  -- if we have not arrived to the last cell, use it
  if cx ~= cx2 or cy ~= cy2 then f(cx2, cy2) end

end

local function grid_tocellrect(cellsize, x,y,w,h)
  local cx,cy = grid_tocell(cellsize, x, y)
  local cr,cb = ceil((x+w) / cellsize), ceil((y+h) / cellsize)
  return cx, cy, cr - cx + 1, cb - cy + 1
end

------------------------------------------
-- responses
------------------------------------------

local cross = function(world, col, x,y,w,h, goalx, goaly, filter)
  local cols, len = world:project(col.item, x,y,w,h, goalx, goaly, filter)
  return goalx, goaly, cols, len
end

local slide = function(world, col, x,y,w,h, goalx, goaly, filter)
  goalx = goalx or x
  goaly = goaly or y

  local tch, move  = col.touch, col.move
  if move.x ~= 0 or move.y ~= 0 then
    if col.normal.x ~= 0 then
      goalx = tch.x
    else
      goaly = tch.y
    end
  end

  col.slide = {x = goalx, y = goaly}

  x,y = tch.x, tch.y
  local cols, len  = world:project(col.item, x,y,w,h, goalx, goaly, filter)
  return goalx, goaly, cols, len
end

------------------------------------------
-- world
------------------------------------------

local world = {}
local world_mt = {__index = world}

-- private functions and methods

local function sortbyweight(a,b) return a.weight < b.weight end

local function sortbytianddistance(a,b)
  if a.ti == b.ti then
    local ir, ar, br = a.itemrect, a.otherrect, b.otherrect
    local ad = rect_getsquaredistance(ir.x,ir.y,ir.w,ir.h, ar.x,ar.y,ar.w,ar.h)
    local bd = rect_getsquaredistance(ir.x,ir.y,ir.w,ir.h, br.x,br.y,br.w,br.h)
    return ad < bd
  end
  return a.ti < b.ti
end

local function additemtocell(self, item, cx, cy)
  self.rows[cy] = self.rows[cy] or setmetatable({}, {__mode = 'v'})
  local row = self.rows[cy]
  row[cx] = row[cx] or {itemcount = 0, x = cx, y = cy, items = setmetatable({}, {__mode = 'k'})}
  local cell = row[cx]
  self.nonemptycells[cell] = true
  if not cell.items[item] then
    cell.items[item] = true
    cell.itemcount = cell.itemcount + 1
  end
end

local function removeitemfromcell(self, item, cx, cy)
  local row = self.rows[cy]
  if not row or not row[cx] or not row[cx].items[item] then return false end

  local cell = row[cx]
  cell.items[item] = nil
  cell.itemcount = cell.itemcount - 1
  if cell.itemcount == 0 then
    self.nonemptycells[cell] = nil
  end
  return true
end

local function getdictitemsincellrect(self, cl,ct,cw,ch)
  local items_dict = {}
  for cy=ct,ct+ch-1 do
    local row = self.rows[cy]
    if row then
      for cx=cl,cl+cw-1 do
        local cell = row[cx]
        if cell and cell.itemcount > 0 then -- no cell.itemcount > 1 because tunneling
          for item,_ in pairs(cell.items) do
            items_dict[item] = true
          end
        end
      end
    end
  end

  return items_dict
end

local function getresponsebyname(self, name)
  local response = self.responses[name]
  if not response then
    error(('unknown collision type: %s (%s)'):format(name, type(name)))
  end
  return response
end


-- misc public methods

function world:addresponse(name, response)
  self.responses[name] = response
end

function world:project(item, x,y,w,h, goalx, goaly, filter)
  goalx = goalx or x
  goaly = goaly or y
  filter  = filter  or defaultfilter

  local collisions, len = {}, 0

  local visited = {}
  if item ~= nil then visited[item] = true end

  -- this could probably be done with less cells using a polygon raster over the cells instead of a
  -- bounding rect of the whole movement. conditional to building a querypolygon method
  local tl, tt = min(goalx, x),       min(goaly, y)
  local tr, tb = max(goalx + w, x+w), max(goaly + h, y+h)
  local tw, th = tr-tl, tb-tt

  local cl,ct,cw,ch = grid_tocellrect(self.cellsize, tl,tt,tw,th)

  local dictitemsincellrect = getdictitemsincellrect(self, cl,ct,cw,ch)

  for other,_ in pairs(dictitemsincellrect) do
    if not visited[other] then
      visited[other] = true

      local responsename = filter(item, other)
      if responsename then
        local ox,oy,ow,oh   = self:getrect(other)
        local col           = rect_detectcollision(x,y,w,h, ox,oy,ow,oh, goalx, goaly)

        if col then
          col.other    = other
          col.item     = item
          col.type     = responsename

          len = len + 1
          collisions[len] = col
        end
      end
    end
  end

  sort(collisions, sortbytianddistance)

  return collisions, len
end

function world:countcells()
  local count = 0
  for _,row in pairs(self.rows) do
    for _,_ in pairs(row) do
      count = count + 1
    end
  end
  return count
end

function world:hasitem(item)
  return not not self.rects[item]
end

function world:getitems()
  local items, len = {}, 0
  for item,_ in pairs(self.rects) do
    len = len + 1
    items[len] = item
  end
  return items, len
end

function world:countitems()
  local len = 0
  for _ in pairs(self.rects) do len = len + 1 end
  return len
end

function world:getrect(item)
  local rect = self.rects[item]
  if not rect then
    error('item ' .. tostring(item) .. ' must be added to the world before getting its rect. use world:add(item, x,y,w,h) to add it first.')
  end
  return rect.x, rect.y, rect.w, rect.h
end

function world:toworld(cx, cy)
  return grid_toworld(self.cellsize, cx, cy)
end

function world:tocell(x,y)
  return grid_tocell(self.cellsize, x, y)
end


--- query methods

function world:queryrect(x,y,w,h, filter)
  local cl,ct,cw,ch = grid_tocellrect(self.cellsize, x,y,w,h)
  local dictitemsincellrect = getdictitemsincellrect(self, cl,ct,cw,ch)

  local items, len = {}, 0

  local rect
  for item,_ in pairs(dictitemsincellrect) do
    rect = self.rects[item]
    if (not filter or filter(item))
    and rect_isintersecting(x,y,w,h, rect.x, rect.y, rect.w, rect.h)
    then
      len = len + 1
      items[len] = item
    end
  end

  return items, len
end

function world:querypoint(x,y, filter)
  local cx,cy = self:tocell(x,y)
  local dictitemsincellrect = getdictitemsincellrect(self, cx,cy,1,1)

  local items, len = {}, 0

  local rect
  for item,_ in pairs(dictitemsincellrect) do
    rect = self.rects[item]
    if (not filter or filter(item))
    and rect_containspoint(rect.x, rect.y, rect.w, rect.h, x, y)
    then
      len = len + 1
      items[len] = item
    end
  end

  return items, len
end


--- main methods

function world:add(item, x,y,w,h)
  local rect = self.rects[item]
  if rect then
    error('item ' .. tostring(item) .. ' added to the world twice.')
  end

  self.rects[item] = {x=x,y=y,w=w,h=h}

  local cl,ct,cw,ch = grid_tocellrect(self.cellsize, x,y,w,h)
  for cy = ct, ct+ch-1 do
    for cx = cl, cl+cw-1 do
      additemtocell(self, item, cx, cy)
    end
  end

  return item
end

function world:remove(item)
  local x,y,w,h = self:getrect(item)

  self.rects[item] = nil
  local cl,ct,cw,ch = grid_tocellrect(self.cellsize, x,y,w,h)
  for cy = ct, ct+ch-1 do
    for cx = cl, cl+cw-1 do
      removeitemfromcell(self, item, cx, cy)
    end
  end
end

function world:update(item, x2,y2,w2,h2)
  local x1,y1,w1,h1 = self:getrect(item)
  w2,h2 = w2 or w1, h2 or h1

  if x1 ~= x2 or y1 ~= y2 or w1 ~= w2 or h1 ~= h2 then

    local cellsize = self.cellsize
    local cl1,ct1,cw1,ch1 = grid_tocellrect(cellsize, x1,y1,w1,h1)
    local cl2,ct2,cw2,ch2 = grid_tocellrect(cellsize, x2,y2,w2,h2)

    if cl1 ~= cl2 or ct1 ~= ct2 or cw1 ~= cw2 or ch1 ~= ch2 then

      local cr1, cb1 = cl1+cw1-1, ct1+ch1-1
      local cr2, cb2 = cl2+cw2-1, ct2+ch2-1
      local cyout

      for cy = ct1, cb1 do
        cyout = cy < ct2 or cy > cb2
        for cx = cl1, cr1 do
          if cyout or cx < cl2 or cx > cr2 then
            removeitemfromcell(self, item, cx, cy)
          end
        end
      end

      for cy = ct2, cb2 do
        cyout = cy < ct1 or cy > cb1
        for cx = cl2, cr2 do
          if cyout or cx < cl1 or cx > cr1 then
            additemtocell(self, item, cx, cy)
          end
        end
      end

    end

    local rect = self.rects[item]
    rect.x, rect.y, rect.w, rect.h = x2,y2,w2,h2

  end
end

function world:move(item, goalx, goaly, filter)
  local actualx, actualy, cols, len = self:check(item, goalx, goaly, filter)

  self:update(item, actualx, actualy)

  return actualx, actualy, cols, len
end

function world:check(item, goalx, goaly, filter)
  filter = filter or defaultfilter

  local visited = {[item] = true}
  local visitedfilter = function(itm, other)
    if visited[other] then return false end
    return filter(itm, other)
  end

  local cols, len = {}, 0

  local x,y,w,h = self:getrect(item)

  local projected_cols, projected_len = self:project(item, x,y,w,h, goalx,goaly, visitedfilter)

  while projected_len > 0 do
    local col = projected_cols[1]
    len       = len + 1
    cols[len] = col

    visited[col.other] = true

    local response = getresponsebyname(self, col.type)

    goalx, goaly, projected_cols, projected_len = response(
      self,
      col,
      x, y, w, h,
      goalx, goaly,
      visitedfilter
    )
  end

  return goalx, goaly, cols, len
end


-- public library functions

bump.newworld = function(cellsize)
  cellsize = cellsize or 64
  local world = setmetatable({
    cellsize       = cellsize,
    rects          = {},
    rows           = {},
    nonemptycells  = {},
    responses = {}
  }, world_mt)

  world:addresponse('touch', touch)
  world:addresponse('cross', cross)
  world:addresponse('slide', slide)
  world:addresponse('bounce', bounce)

  return world
end
-->8
-- utils --

textlabel="this is some cool text!!!"

function hcenter(s)
  -- screen center minus the
  -- string length times the 
  -- pixels in a char's width,
  -- cut in half
  return 64-#s*2
end

function vcenter(s, offset)
  -- screen center minus the
  -- string height in pixels,
  -- cut in half
  return 61 + offset
end

function centertext(textlabel, _color, offset)
  print(textlabel,hcenter(textlabel),vcenter(textlabel, offset),_color)
end

characters = {}
characters[1] = {num=1,name="oso",sprite=01,powered=false,bigsprite={10,42}}
characters[2] = {num=2,name="viento", sprite=23}
characters[3] = {num=3,name="lechu", sprite=07}
characters[4] = {num=4,name="gaturri", sprite=39}
characters[5] = {num=5,name="casa", sprite=55}


function delay(frames)
  for i=1,frames do
    yield()
  end
end
__gfx__
c888cccc0000000000000000333333331111111166666666ffffffff000000020000000000000000000000001100000000000000000000000000000000000000
c888cccc0404000000000000333333331111111166666666ffffffff000000220000000000000000001100001410000000000000000000000000000000000000
c888cccc4404400404440000333333331111111166666666ffffffff7007f07e0000000000000000014100014441000100000000000000000000000000000000
888888884141404444444777333333331111111166666666ffffffff777700770000000000000000014411144411001100000000000000000000000000000000
888888884414444444444477333333331111111166666666ffffffff757577760000000000000000144554444100001100000000000000000000000000000000
888888884484444404440000333333331111111166666666ffffffff774777700000000000000000141554144100114100000000000000000000000000000000
c888cccc0444444000000000333333331111111166666666ffffffff077777700000000000000000115544444411144100000000000000000000000000000000
c888cccc0440044000000000333333331111111166666666ffffffff007700700000000000000000414114444444441000000000000000000000000000000000
33333333333333330000000033333333111111116d6666d6ffffffff000000000000000000000000014114444144441000000000000000000000000000000000
333333333333333300000000333333b3111111116d6666d6fff6ffff040440000000000000000000001444444144441100000000000000000000000000000000
333333333333333304440000333333b31cc11111ddddddddffff6fff477747700000000000000000000188441444544100000000000000000000000000000000
3333333333333333444447773b333b3311111111666d6666fffff6ff417144770000000000000000000114414444514100000000000000000000000000000000
3333333333333333444444773bb33b3311c11cc1666d6666ff6fffff478741170000000000000000000151144145144100000000000000000000000000000000
33333333333333330445000033b3333311111111ddddddddfff6ffff077777770000000000000000000145144141144100000000000000000000000000000000
33333333333333330000000033333333111111116d6666d6ffffffff071715170000000000000000001445144110011000000000000000000000000000000000
33333333333333330000000033333333111111116d6666d6ffffffff071755770000000000000000001111011000000000000000000000000000000000000000
33333333333333333333333333111133c166c6166c16166c00000000000000000000000000000000000000001100000000000000000000000000000000000000
33333333333333333b333333311551136c1611c161c11c1100000000000000000000000000000000001100001410000000000000000000000000000000000000
33333333333333333b3333b33155551111111111c111111100000000000000000000000000000000014100014441000100000000000000000000000000000000
33333333333333333b333b3311557551111111111111111100000000050500050000000000000000014411144411001100000000000000000000000000000000
33333333333333333bb33b33155557511111111161111111000000005a5a00050000000000000000144554444100001100000000000000000000000000000000
333333333333333333b3333315555551111111111c11111100000000058555550000000000000000141554144100114100000000000000000000000000000000
33333333333333333333333331555511111111116111111100000000055555500000000000000000115544444411144100000000000000000000000000000000
3333333333333333333333333311111311111111c611111100000000005500500000000000000000414114444444441000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000014114444144441000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000001444444144441100000000000000000000000000000000
1ccc1111000000000000000000000000000000000000000000000000010100000000000000000000000188441444544100000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000110110010000000000000000000114414444514100000000000000000000000000000000
11cc1c110000000000000000000000000000000000000000000000001a1a10010000000000000000000011144145541000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000118111110000000000000000000155144145510000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000011111110000000000000000000015511111510000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000001100100000000000000000000011100001110000000000000000000000000000000000
__gff__
0000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0303030303030303030303061604040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303230303031303032303061614040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303061604040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030505030303030303061604040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030505030303031303061604041400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030505030323030303061604040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424240505242424242424242404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040505041404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515150505151515151515151515151500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303031303030303030313030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0313030303030303031303230303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060606060606060606060606060607000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424242424242424242424242424242400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404041404040404040414040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040414040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000002500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000002500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000002500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00090000007000070000700127500d750127500d75000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
38060000000500000000150001500015001150031500615007150091500a1500c1500d1500d1500f150101501315015150161501b3501e350223503c7503c7503c7503c7503c7503c7503c7503c7503c7503c750
00060000000000000000000000000000000000000000000000000000000c050000000405000000110500000000050000000000000000000000000000000000000000000000000000000000000000000000000000
000600002d5502b55028550245501e55015550115500b55004550045500070010000160001b0001d0001b0001700012000130000c0000600001000000000000002000000000d0000100001000010000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c041a000000000000000000003a500197102271001500000000d52003500000000d520005001150010520105000050010520000001a52000000000001a5200000000000000000000000000000000000000000
0506001003730005000050000500005000150001500005000e500005000050000500005000f500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
d3140000007000471000700007000070010710007000670000700007000d710007000070006710007001b710007000070005700007101971000710087000070000700007000d7100070006700007000271000700
__music__
02 591a1b44

