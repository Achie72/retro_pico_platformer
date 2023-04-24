pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
	
global = {
	state = 0, -- 0: menu, 1: gameplay, 2: endscreen, [3: help, 4: settings]
	transition = false,
	levelEndReached = false,
	transition_y = 0,
	transition_number = 0,
	trans = {
		x = 0,
		y = 0
	},
	gravity = 0.6,
	pauseTime = 0,
	camShake = false,
	camShakeTime = 0,
	offset = 0.1,
	animation_queue = {},
	frame = 0
}

player = {
	x = 1*8,
	y = 1*8,
	ax = 0,
	ay = 0,
	acceleration = 1,
	jumpForce = 6,
	maxSpeed = 3,
	isGrounded = false,
	isStomping = false,
	stompStun = 0,
	airtime = 0;
	canJump = false;
	isFlipped = false,
	maxFall = 5,
	powerUp = 0, --0 base, 1 rock, 2 fire, 3 air
	life = 3,
	colorPairs = {{5,13},{5,13},{8,14},{9,10}},
	canDash = false,
	dashDuration = 2,
	nextDash = 0,
	nextFireball = 0,
	powerUpTime = 0,
	speedInv = 0,
	status = "",
	coins = 0,
	score = 0,
	currScore = {
		x = 0,
		y = 0,
		val = 0,
		lifetime = 0
	},
	stompCount = 0
}

crect = {
	x,
	y
}

cam = {
	x = 0,
	y = 0
}

particles = {}
fireballs = {}
enemies = {}
enemyProjectiles = {}
foliage = {}
pickups = {}
scores = {}

foliageId = {192,208,240}
mapContainer = {
	"240,16,16,16,16,16,16,16,16,16,16,16,16,16,2,34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,34,0,0,0,0,0,0,0,0,0,0,0,0,0,64,4,34,0,0,0,0,0,0,0,0,0,0,0,0,0,208,2,34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,34,0,0,0,0,0,0,0,0,0,0,0,0,0,48,4,34,0,0,0,0,0,0,0,0,0,0,0,0,48,48,5,34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,34,0,0,0,0,0,0,0,0,6,49,0,0,0,240,2,34,0,0,0,0,0,0,0,0,118,50,0,0,0,0,52,34,0,0,0,0,0,0,0,0,22,51,0,0,0,240,4,34,0,0,0,0,0,0,0,48,48,48,0,0,0,0,5,34,0,0,0,0,0,0,48,48,48,48,114,0,192,1,5,34,0,0,0,0,48,48,48,48,48,48,114,0,122,2,2,34,0,0,0,48,48,48,48,48,48,48,114,0,38,2,4,34,0,0,0,48,48,48,48,48,48,48,114,0,192,3,2,34,0,0,0,0,0,0,0,0,0,0,0,0,0,128,4,34,0,0,0,0,0,0,0,0,0,0,0,0,0,240,2,34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,52,34,0,0,0,0,0,0,0,0,0,0,0,0,0,240,2,34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,34,0,0,54,0,0,0,0,0,0,132,49,0,0,1,21,34,0,0,0,0,0,0,114,114,0,0,50,0,0,2,37,34,0,0,0,0,0,0,114,114,0,0,53,0,48,4,37,34,0,0,0,0,0,0,0,0,0,0,51,0,0,3,19,19,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,114,114,54,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,17,33,0,0,0,0,0,0,0,0,0,0,0,0,132,2,36,34,0,0,0,0,0,0,0,0,0,114,114,0,208,2,37,34,114,114,54,0,0,0,0,0,0,0,0,0,0,2,37,34,0,0,0,0,0,0,0,0,0,114,114,0,240,52,37,34,0,0,0,0,0,0,0,0,0,0,0,0,0,2,36,34,0,0,0,0,0,0,0,0,0,0,0,0,1,21,37,34,114,114,54,0,0,0,0,0,0,0,0,132,2,18,19,35,0,0,0,0,0,0,0,0,114,114,0,0,2,34,114,49,0,0,0,0,0,0,0,0,0,0,0,0,2,34,114,50,0,0,0,0,0,0,0,0,0,0,0,1,21,34,114,50,0,0,0,0,0,0,0,0,0,0,132,2,18,35,114,50,0,0,114,54,0,0,0,114,114,0,6,2,34,0,0,50,0,0,0,0,0,0,0,0,0,0,208,2,34,0,132,50,0,0,0,0,0,0,0,0,0,0,0,3,35,0,0,50,0,0,0,0,114,54,0,0,0,0,0,0,0,0,0,50,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,51,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,54,0,0,0,0,49,0,0,0,0,0,0,0,0,0,0,0,0,0,0,208,50,0,0,0,0,0,0,0,0,0,0,0,0,0,48,48,50,0,0,0,0,0,0,0,0,0,0,0,0,0,0,192,2,17,17,33,0,0,0,0,0,0,0,0,0,0,0,0,2,18,18,34,0,0,0,0,0,0,0,0,0,0,0,208,3,19,20,34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,34,0,0,0,0,0,0,0,0,0,0,0,0,0,128,4,34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,52,34,0,0,0,0,0,0,0,0,0,0,0,0,0,240,2,34,0,0,0,0,0,0,0,0,0,0,0,0,0,48,5,34,0,0,0,0,0,0,0,0,0,0,0,0,48,48,2,34,0,0,0,0,0,0,0,0,0,0,0,0,0,48,4,34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,34,0,0,0,0,0,0,0,0,0,0,0,0,0,132,2,34,0,0,0,0,0,0,0,0,0,38,54,0,0,0,5,34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,208,49,0,0,0,0,0,0,0,0,0,0,0,0,0,114,0,50,0,0,0,0,0,0,0,0,0,0,0,0,0,114,0,2,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,51,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,49,0,0,0,0,0,0,0,0,0,0,0,0,0,114,208,2,16,16,16,0,0,0,0,0,0,0,0,0,0,114,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,51,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,17,17,17,17,33,0,0,0,0,0,0,0,0,0,192,2,37,37,18,37,34,17,17,17,17,17,17,33,0,0,132,2,37,37,37,37,34,37,37,19,19,19,19,34,0,0,0,2,37,37,37,36,34,37,34,0,0,0,0,50,0,0,0,2,37,18,37,37,34,37,34,0,0,0,127,50,0,0,0,2,37,37,37,37,34,37,34,0,0,0,0,51,0,0,208,2,37,37,37,37,34,37,34,0,0,0,0,0,0,0,0,2,36,37,37,18,34,37,34,0,0,0,0,0,0,0,132,2,37,37,37,37,34,37,34,0,0,0,0,0,192,49,0,2,18,37,37,37,34,37,37,17,17,17,17,17,17,21,17,21,37,37,37,36,34,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"
}

function parseMap(_mapString)
	local mapString = _mapString
	local actualMap = {}
	local actualToken = ""
	while #mapString > 0 do
		local firstToken = sub(mapString,1,1)
		local cut = 2
		if (firstToken != ",") then
			local workString = sub(mapString,2)
			local secondToken = sub(workString,1,1)
			if (secondToken != ",") then
				local workString = sub(mapString,3)
				local thirdToken = sub(workString,1,1)
				if (thirdToken != ",") then
					local actualToken = firstToken..secondToken..thirdToken
					add(actualMap,actualToken)
					cut = 4
				else
					local actualToken = firstToken..secondToken
					add(actualMap,actualToken)
					cut = 3
				end
			else
				add(actualMap,firstToken)
				cut = 2
			end
		end
		mapString = sub(mapString,cut)
	end
	return actualMap
end

function codeMap()
	local mapstring = ""
	for x=0,127 do
		for y=0,15 do
			mapstring = mapstring..mget(x,y)..","
		end
	end
	--add(mapstring,12)
	--printh(tostr(mapstring))
	printh(mapstring)
end

function load_map(_index)

	for x = 0,127 do
		for y=0,15 do
			mset(x,y,0)
		end
	end

	mapString = parseMap(mapContainer[_index])
	printh(mapContainer[_index])
	x = 0
	y = 0
	for id in all(mapString) do
		id = tonum(id)
		
		--walls
		if (0 < id) and (id < 64) then
			mset (y, x, id)
		end
		
		-- coins
		if (id == 114) then
			add_pickup (y, x, 0)
		end
		-- fire flower
		if (id == 118) then
			add_pickup (y, x, 1)
		end
		-- volt flower
		if (id == 122) then
			add_pickup (y, x, 2)
		end
		-- egg
		if (id == 127) then
			add_pickup (y, x, 99)
		end

		--foliageId = {192,208,240}
		if (id == 192) or (id == 208) or (id == 240) then
			add_foliage(y, x, id)
		end


		-- enemies
		if (id == 128) or (id == 132) then
			add_enemy (y, x, id)
		end

		if (id == 64) then
			player.x = y*8
			player.y = x*8
		end

		x+=1
		if (x > 15) then
			x = 0
			y+=1
		end
	end
end

function _init()
	codeMap()
end

function add_particle(_x,_y,_maxAge,_color,_type,_goal,_velocity)
	local goal = _goal
	if goal == nil then
		goal = {
			x = 0,
			y = 0
		}
	end

	local vel = _velocity
	if vel == nil then
		vel = {
			x = 0,
			y = 0
		}
	end

	local part = {
		x = _x,
		y = _y,
		lifeTime = 0,
		maxAge = _maxAge,
		tpe = _type,
		color_range = _color,
		clr = _color[1],
		dest = {
			x = goal.x,
			y = goal.y
		},
		velocity = vel
	}
	add(particles,part)
end

function add_enemy(_x,_y,_spr)
	if _spr == 128 then
		local enemy = {
			x = _x*8,
			y = _y*8,
			ay = 0,
			defspeed = 1,
			speed = 1,
			spr = _spr,
			hitspr = _spr+2,
			type = 0,
			animspeed = 6
		}
		add(enemies,enemy)
	elseif _spr == 132 then
		local enemy = {
			x = _x*8,
			y = _y*8,
			ay = 0,
			defspeed = 1,
			speed = 0.5,
			spr = _spr,
			hitspr = _spr+2,
			type = 1,
			animspeed = 6
		}
		add(enemies,enemy)
	end
end

function add_foliage(_x,_y,_spr)
	local fol = {
		x = _x*8,
		y = _y*8,
		spr = _spr
	}
	add(foliage,fol)
end

function add_pickup(_x,_y,_tpe)
	local pickup = {
		x = _x*8,
		y = _y*8,
		tpe = _tpe,
		deleteTime = nil
	}


	-- coin 
	if pickup.tpe == 0 then
		pickup.spr = 114
		pickup.animLength = 4
		pickup.animSpeed = 6
	-- fire flower
	elseif pickup.tpe == 1 then
		pickup.spr = 118
		pickup.animLength = 4
		pickup.animSpeed = 12
	-- Volt flower
	elseif pickup.tpe == 2 then
		pickup.spr = 122
		pickup.animLength = 5
		pickup.animSpeed = 14
	elseif pickup.tpe == 99 then
		pickup.spr = 127
		pickup.animLength = 1
	end

	add(pickups,pickup) 

end

function add_fireball(_x, _y, _speed)
	local fireball = {
		x = _x,
		y = _y,
		spr = 44,
		speed = 1.5 * _speed,

	}
	add(fireballs,fireball)
end

function animate(object,starterFrame,frameCount,animSpeed,flipped,isPlayer)
	if(not object.tickCount) then
		object.tickCount=0
	end
	if(not object.spriteOffset) then
		object.spriteOffset=0
	end

	object.tickCount+=1

	if(object.tickCount%(flr(30/animSpeed))==0) then	
		object.spriteOffset+=1
		if (object.spriteOffset>=frameCount) then
		 	object.spriteOffset=0
		end
	end

	object.actualframe=starterFrame+object.spriteOffset

	if object.actualframe >= starterFrame+frameCount then
		object.actualframe = starterFrame
	end

	print(object.spriteOffset,2,2,1)
	-- 3 is treant
	if (isPlayer) then
		local colors = player.colorPairs[player.powerUp+1]
		for x=0,(frameCount*8-1),1 do
			for y=0,7,1 do
				local xPos = ((starterFrame-64)*8)+x
				if sget( xPos, 32 + y) == 15 then
		  			sset( xPos, 32 + y, colors[1])
		  		end
		  		if sget( xPos, 32 + y) == 14 then
		  			sset( xPos, 32 + y, colors[2])
		  		end
		 	end
		end
	end

	spr(object.actualframe,object.x,object.y,1,1,flipped)

	if (isPlayer) then
		local colors = player.colorPairs[player.powerUp+1]
		for x=0,(frameCount*8-1),1 do
			for y=0,7,1 do
				local xPos = ((starterFrame-64)*8)+x
				if sget( xPos, 32 + y) == colors[1] then
		  			sset( xPos, 32 + y, 15)
		  		end
		  		if sget( xPos, 32 + y) == colors[2] then
		  			sset( xPos, 32 + y, 14)
		  		end
		 	end
		end
	end

	pal()
end

function create_animation(object,starting_frame,number_of_frames,speed,ticks,persistent,lifetime)
	local obj = {
		x = object.x,
		y = object.y,
	}
	local anim = {
		object = obj,
		starting_frame = starting_frame,
		number_of_frames = number_of_frames,
		speed = speed,
		ticks = ticks,
		presistent = persistent,
		lifetime = lifetime
	}
	add(global.animation_queue,anim)
end

function add_score (_x, _y, _txt, _color, _lifetime)
	local score = {
		x = _x,
		y = _y,
		txt = _txt,
		color = _color,
		lifetime = time() + _lifetime
	}
	add(scores, score)
end

function collide_rect(r1,r2)
	if ( (r1.x1 > r2.x2) or
		 (r2.x1 > r1.x2) or
		 (r1.y1 > r2.y2) or
		 (r2.y1 > r1.y2)) then
			return false
		end
		return true
end

function to_rect(x,y,h,w)
	local r = {
		x1 = x,
		x2 = x + w - 1,
		y1 = y,
		y2 = y + h - 1
	}
	return r
end


function collide_roof(obj, width, height)
    --check for collision at multiple points along the top
    --of the sprite: left, center, and right.
    for i=1,width-1,2 do
        if fget(mget((obj.x+i)/8,(obj.y)/8),0) then
            return true
        end
    end
    return false
end


function collide_side(obj,width)

    local offset=width/3
    for i=-(width/3),(width/3),2 do
    --if obj.ax>0 then
        if fget(mget((obj.x+(offset))/8,(obj.y+i)/8),0) then
            obj.ax=0
            obj.x=(flr(((obj.x+(offset))/8))*8)-(offset)
            return true
        end
    --elseif obj.ax<0 then
        if fget(mget((obj.x-(offset))/8,(obj.y+i)/8),0) then
            obj.ax=0
            obj.x=(flr((obj.x-(offset))/8)*8)+8+(offset)
            return true
        end
--    end
    end
    --didn't hit a solid tile.
    return false
end

--check if pushing into floor tile and resolve.
--requires obj.ax,obj.x,obj.y,obj.grounded,obj.airtime and 
--assumes tile flag 0 or 1 == solid
function collide_floor(obj,width,height)
    --only check for ground when falling.
    if obj.ay<0 then
        return false
    end
    local landed=false
    --check for collision at multiple points along the bottom
    --of the sprite: left, center, and right.
    for i=1,width-1,2 do
        local tile=mget((obj.x+i)/8,(obj.y+(height))/8)
        if fget(tile,0) or (fget(tile,1) and obj.ay>=0) then
            landed=true
        end
    end
    return landed
end



function control_player()
	local dashing = player.canDash
	local startx = player.x
	
	if (player.stompStun > time()) then
		--player.status = "stun"
	elseif (player.isStomping) then
		--player.status = "stomp"
	else
		--player.status = "chill"
	end

	if (not player.isStomping) and (not (player.stompStun > time())) then
		if btn(0) then
			player.ax -= player.acceleration
			player.isFlipped = true
		elseif btn(1) then 
			player.ax += player.acceleration
			player.isFlipped = false
		elseif (btn(3) and (not player.isGrounded)) then
			player.ax = 0
			player.ay = 2
			sfx(0)
			player.isStomping = true
		else
			player.ax = 0
		end

		if btnp(4) then
			player.powerUp += 1
			if player.powerUp > 3 then
				player.powerUp = 0
			end
		end
		
		if btnp(5) then
			if player.powerUp == 3 then
				if time() > player.nextDash then
					player.canDash = true
					player.nextDash = time() + player.dashDuration
					player.speedInv =  time() + 0.3
				end
			end
			if player.powerUp == 2 then
				if time() > player.nextFireball then
					local speed = 1
					if player.isFlipped then
						speed = -1
					end
					if not (player.ax == 0) then
						speed = player.ax
					end
					add_fireball(player.x, player.y, speed, player.isFlipped)
					player.nextFireball =  time() + 1
				end
			end
		end
	end

	if time() > player.speedInv then
		player.canDash = false
	end


	if player.ax > 0 then
		if player.ax > player.maxSpeed then
			player.ax = player.maxSpeed
		end
	elseif player.ax < 0 then
		if player.ax < -player.maxSpeed then
			player.ax = -player.maxSpeed
		end
	end

	if dashing then
		player.ax = 6
		local vel = {
			x = sin(rnd(1)),
			y = sin(rnd(1))/4 
		}
		if player.flip then
			add_particle(player.x+7,player.y+1,5,{10,9,6},3,nil,vel)
			add_particle(player.x+7,player.y+3,5,{10,9,6},3,nil,vel)
			add_particle(player.x+7,player.y+5,5,{10,9,6},3,nil,vel)
		else
			add_particle(player.x,player.y+1,5,{10,9,6},3,nil,vel)
			add_particle(player.x,player.y+3,5,{10,9,6},3,nil,vel)
			add_particle(player.x,player.y+5,5,{10,9,6},3,nil,vel)	
		end

		if player.isFlipped then
			player.ax = -6
		end
	end

	-- move player through x
	player.x += player.ax

	-- check collision
	local xoffset=0
	if player.ax >0 then xoffset=7 end

	local possible_wall_tile = mget((player.x+xoffset)/8,(player.y+7)/8)
	if fget(possible_wall_tile,0) then
		player.x = startx
	end

	--normalize vertical speed add gravity
	if not (player.isGrounded) then
			player.ay += global.gravity
		if player.ay > player.maxFall then
			player.ay = player.maxFall
		end
	end

	-- move player
	player.y += player.ay
	player.isGrounded = false


	if btn(2) and (player.isGrounded or player.airtime < 4) then
		if player.canJump then
			player.ay -= player.jumpForce
			player.canJump = false
		end
	end

	-- hit floor
	if collide_floor(player, 8, 8) then
		if player.isStomping and fget(mget(flr((player.x+2)/8),flr((player.y+8)/8)),1) and (btn(3)) then
			mset(flr((player.x+2)/8),flr((player.y+8)/8), 0)
			for xVel =-1,-0.2,0.2 do
				local vel = {
					x = xVel+sin(rnd(1)),
					y = xVel+sin(rnd(1))/4 
				}
				--function add_particle(_x,_y,_maxAge,_color,_type,_goal,_velocity)
				add_particle(player.x+4,player.y+8,10,{9,4,6},1,nil,vel)
				vel.x = vel.x * -1 
				add_particle(player.x+4,player.y+8,10,{9,4,6},1,nil,vel)
				global.camShake = true
				global.camShakeTime = time() + 0.5
				global.offset = 0.1
				sfx(1)
			end
		elseif player.isStomping then
			--add particles
			--small stun
			player.stompStun = time() + 0.5
			player.isStomping = false

			for xVel =-1,-0.2,0.2 do
				local vel = {
					x = xVel,
					y = xVel/4 
				}
				--function add_particle(_x,_y,_maxAge,_color,_type,_goal,_velocity)
				add_particle(player.x+4,player.y+8,10,{2,5,6},1,nil,vel)
				vel.x = vel.x * -1 
				add_particle(player.x+4,player.y+8,10,{2,5,6},1,nil,vel)
				
			end
			global.camShake = true
			global.camShakeTime = time() + 0.5
			global.offset = 0.1
			sfx(1)
		end
			-- place player on top
			--player.status = "coll"
			player.y = flr((player.y)/8)*8
			player.ay = 0
			player.isGrounded = true
			player.airtime = 0
			player.canJump = true
			player.stompCount = 0
	else
		--player.status = "nocoll"
		player.airtime += 1
	end


	
	-- hit ceiling
	if player.ay < 0 then
		--player.status = "jump"
		-- check for solide tile
		if collide_roof(player, 8, 8) then
			player.y = flr((player.y+8)/8)*8
			player.ay = 0
		end
	end

	if (player.ay > 0) and (not player.isStomping) and (not (player.stompStun > time())) then
		--player.status = "fall"
	end

end

-- 0: menu, 1: gameplay, 2: endscreen, [3: help, 4: settings]
function _update ()
	global.frame += 1
	if global.frame > 30 then
		global.frame = 0
	end

	if not (global.transition == true) then
		if global.state == 0 then
			update_menu()
		elseif global.state == 1 then
			update_game()
		elseif global.state == 2 then
			camera(0,0)
			update_end_screen()
		end
	end
end

function update_menu()
	if btnp(5) then
		print(control,64-(#control*2),40,9)
		-- enter the game
		global.state = 1
		global.transition = true
		global.trans.x = 0
		global.trans.y = 0
		load_map(1)
		sfx(0)
	end
end

function update_game()
	if not (global.pauseTime > time()) then
		control_player()
		update_fireballs()
		update_enemies()
		check_stomp()
		update_scores()
		--update_bouncers()
		update_pickup()
	end

	update_particles()
	if player.life <= 0 then
		-- set our state to endscreen

		global.state = 2
		global.endScreenMessage = endScreenMessages[flr(rnd(#endScreenMessages)+1)]
		global.transition = true
		global.trans.x = player.x-64
		global.trans.y = player.y-64
		--camera(0,0)
	end

	if time() > global.camShakeTime then
		global.camShake = false
	end
end



function update_particles()
	if not (#particles == 0) then
		for particle in all(particles) do
			-- lifetime and color changes
			if particle.lifeTime > particle.maxAge then
				del(particles,particle)
			else
				if #particle.color_range == 1 then
					particle.clr = particle.color_range[1]
				else
					local idx = particle.lifeTime / particle.maxAge
					idx = 1 + flr(idx*#particle.color_range)
					if idx > #particle.color_range then idx = #particle.color_range end
					particle.clr = particle.color_range[idx]
					--if (particle.clr == 0) then particle.clr = 5 end 
				end
			end
			particle.lifeTime +=1
		
			if not (particle.velocity == nil) then
				particle.x += particle.velocity.x
				particle.y += particle.velocity.y
			end
		end
	end
end

function update_fireballs()
	for fireball in all(fireballs) do
		fireball.x += fireball.speed
	end
end


function move_enemy(object,w,h)
	next_wall = 0
	next_floor = 0
	-- type 0
	if object.type == 0 then

		if object.speed > 0 then
			next_wall = mget(object.x/8+(1*sgn(object.speed)),object.y/8)
		end

		if object.speed < 0 then
			next_wall = mget(ceil(object.x/8)+(1*sgn(object.speed)),object.y/8)
		end

		if(fget(next_wall)==1) then
			object.speed = object.speed * (-1)
		end

		next_floor = mget(flr(object.x/8),(object.y/8)+1)
		if fget(next_floor,0) == false then
			object.ay += global.gravity
		else
			object.ay = 0
		end
	end
	-- type 1
	if object.type == 1 then
		if object.speed > 0 then
			next_floor = mget(object.x/8+(1*sgn(object.speed)),object.y/8+1)
		end

		if object.speed < 0 then
			next_floor = mget(ceil(object.x/8)+(1*sgn(object.speed)),object.y/8+1)
		end

		if(fget(next_floor) == 0) then
			object.speed = object.speed * (-1)
		end

		if object.speed > 0 then
			next_wall = mget(object.x/8+(1*sgn(object.speed)),object.y/8)
		end

		if object.speed < 0 then
			next_wall = mget(ceil(object.x/8)+(1*sgn(object.speed)),object.y/8)
		end

		if(fget(next_wall)==1) then
			object.speed = object.speed * (-1)
		end

		next_wall = mget(flr(object.x/8),flr((object.y+object.ay)/8)+1)
		if(fget(next_wall,0) == 0) then
			object.ay += global.gravity
		else
			object.ay = 0
		end

	end
	object.x += object.speed
	object.y += object.ay
end

function update_enemies()
	for enemy in all(enemies) do
		for fireball in all(fireballs) do
			printh(fireball.x.." "..fireball.y)
			if (collide_rect(to_rect(enemy.x, enemy.y, 7, 7),to_rect(fireball.x, fireball.y, 7, 7))) then
				del(fireballs,fireball)
				del(enemies,enemy)
				return
			end
		end
		move_enemy(enemy,7,7)
	end
end

function update_scores()
	if player.currScore.lifetime > time() then
		player.currScore.lifetime -= 1
		player.currScore.y -= 1
	end
end

function player_enemy_collision()
	for monster in all(enemies) do
		if( (collide_rect(to_rect(monster.x, monster.y,7,7),to_rect(player.x, player.y,7,7))) and (global.tick > player.nextinvc) ) then
			player.status = "hit"
		end
	end
end

function check_stomp()
	for enemy in all(enemies) do
		if (collide_rect (to_rect (player.x,player.y,8,8), to_rect (enemy.x, enemy.y, 8, 8))) and (player.ay > 0) then		
			local score = 0
			if enemy.speed < 0 then
				create_animation(enemy,enemy.hitspr,2,4,false,false,10)
			else
				create_animation(enemy,enemy.hitspr,2,4,true,false,10)
			end
			del(enemies,enemy)

			player.ay = -player.jumpForce
			if player.isStomping then
				player.ay-= 2
				player.isStomping = false
			end
			player.stompCount += 1
			score = player.stompCount * 200
			player.score += score

			if player.currScore.lifetime > time () then
				score = player.currScore.val + score
				player.currScore.lifetime = time() + 5
			end
			player.currScore = {
				x = player.x+4, 
				y = player.y-8,
				val = score, 
				lifetime = time() + 5
			}
		end
	end
end

function update_enemy_projectiles()
end


function update_pickup()
	for pickup in all(pickups) do
		if (pickup.deleteTime == nil) then
			if collide_rect(to_rect(player.x, player.y, 8, 8), to_rect(pickup.x, pickup.y, 8,8 )) then
				local score = 0
				local p_col_map = {}
				-- coin
				if pickup.tpe == 0 then
					player.coins += 1
					pickup.animSpeed = pickup.animSpeed*2
					pickup.deleteTime = time() + 1
					score = 200
					player.score += score
					sfx(2)
				end
				-- fire flower
				if pickup.tpe == 1 then
					player.powerUp = 2
					pickup.animSpeed = pickup.animSpeed*2
					pickup.deleteTime = time() + 0.1
					score = 400
					player.score += score
					add_particle(pickup.x + 4 + rnd(5), pickup.y + 4+rnd(5), 15, {8, 7, 8, 2, 5}, 2, nil, nil)
					add_particle(pickup.x + 4 +rnd(5), pickup.y + 4+rnd(5), 25, {8, 7, 8, 2, 5}, 2, nil, nil)
					add_particle(pickup.x + 4 +rnd(5), pickup.y + 4+rnd(5), 30, {8, 7, 8, 2, 5}, 2, nil, nil)
					global.camShake = true
					global.camShakeTime = time() + 1
					global.offset = 0.07
					global.pauseTime = time() + 1
					player.powerUpTime = time() + 1
				end
				-- volt flower
				if pickup.tpe == 2 then
					player.powerUp = 3
					pickup.animSpeed = pickup.animSpeed*2
					pickup.deleteTime = time() + 0.1
					score = 400
					player.score += score
					--function add_particle(_x,_y,_maxAge,_color,_type,_goal,_velocity)
					add_particle(pickup.x + 4 +rnd(5), pickup.y + 4+rnd(5), 15, {10,7,10,9,6}, 2, nil, nil)
					add_particle(pickup.x + 4 +rnd(5), pickup.y + 4+rnd(5), 25, {10,7,10,9,6}, 2, nil, nil)
					add_particle(pickup.x + 4 +rnd(5), pickup.y + 4+rnd(5), 30, {10,7,10,9,6}, 2, nil, nil)
					global.camShake = true
					global.camShakeTime = time() + 1
					global.offset = 0.07
					global.pauseTime = time() + 1
					player.powerUpTime = time() + 1
				end
				-- egg
				if pickup.tpe == 99 then
					pickup.deleteTime = time() + 0.1
					score = 2000
					player.score += score
					global.levelEndReached = true
					global.transition = true
				end
				printh("added score")
				if player.currScore.lifetime > time () then
					score = player.currScore.val + score
				end
				player.currScore = {
					x = player.x+4, 
					y = player.y,
					val = score, 
					lifetime = time() + 5
				}
			end
		elseif (pickup.deleteTime > time()) then
			pickup.y -= 0.5
		else
			del(pickups, pickup)
		end

	end
end

-- 0: menu, 1: gameplay, 2: endscreen, [3: help, 4: settings]
function _draw()
	if not (global.transition) then
		if global.state == 0 then
			draw_menu()
		elseif global.state == 1 then
			draw_game()
		elseif global.state == 2 then
			draw_end_screen()
		end
	else
		draw_transition(global.trans.x,global.trans.y)
	end
end

function draw_menu()
	cls()
	map()
	title = "dINO wIP pROJECT"
	control = "press x to play"
	print(title,64-(#title*2),20,9)

	if (time()%1 > 0.5) then
		print(control,64-(#control*2),40,6)
	end
end

function draw_game()
	local xPos = player.x
	local yPos = player.y
	cls()
	rectfill(-70,0,1200,300,12)
	map()
	rectfill(crect.x1,crect.y1,crect.x2,crect.y2, 6)
	draw_fireballs()
	draw_enemies()
	
	if player.powerUpTime > time() then
		if (global.frame % 2 == 1) then
			spr(64, player.x, player.y, 1, 1, player.isFlipped, false)
		end
	else
		if player.isStomping or (player.stompStun > time()) then
			animate(player,76,1,10,player.isFlipped,true)
		else
			if (player.ax == 0) then
				animate(player,66,4,10,player.isFlipped,true)
			else
				animate(player,64,2,13,player.isFlipped,true)
			end
		end
	end

	draw_particles()

	print(player.status, xPos, yPos-8, 8)
	--draw_enemy_projectile()
	draw_global_animations()



	-- camera setup
	local target_pos = {
		x = player.x-60,
		y = 0
	}

	local camera_treshold = 16

	local position_minimum = {
		x = 0,
		y = 0
	}
	local position_maximum = {
		x = 128*8-64,
		y = 64+182
	}
	-- calculate out of buffer corrigations
	if (cam.x + camera_treshold) < target_pos.x then
		cam.x += min(target_pos.x - (cam.x + camera_treshold), 4)
	end
	if (cam.x - camera_treshold) > target_pos.x then
		cam.x += min(target_pos.x - (cam.x - camera_treshold), 4)
	end
	if (cam.y + camera_treshold) < target_pos.y then
		cam.y += min(target_pos.y - (cam.y + camera_treshold), 4)
	end
	if (cam.y - camera_treshold) > target_pos.y then
		cam.y += min(target_pos.y - (cam.y - camera_treshold), 4)
	end

	if cam.x < position_minimum.x then
		cam.x = position_minimum.x
	end
	if cam.x > position_maximum.x then
		cam.x = position_maximum.x 
	end
	if cam.y < position_minimum.y then
		cam.y = position_minimum.y
	end
	if cam.y > position_maximum.y then
		cam.y = position_maximum.y
	end

	if global.camShake then
		screen_shake(cam.x, cam.y)
	else
		camera(cam.x, cam.y)
	end
	draw_pickups()
	draw_ui(cam.x+2, 0)
	pal()

	pset(flr((player.x+4)),flr((player.y+8)),7)
end

function screen_shake(x, y)
  local fade = 0.95
  local offset_x=16-rnd(32)
  local offset_y=16-rnd(32)
  offset_x*=global.offset
  offset_y*=global.offset
  
  camera(x+offset_x,y+offset_y)
  global.offset*=fade
  if global.offset<0.05 then
    global.offset=0
  end
end

function draw_fireballs()
	for fireball in all(fireballs) do
		animate(fireball, 96, 4, 12, false, false)
	end
end

function draw_end_screen()
end

function draw_particles()
	if not (#particles == 0) then
		for particle in all(particles) do
			-- moving dot particle
			if particle.tpe == 1 then
				circfill( particle.x+sin(rnd()), particle.y+sin(rnd()), particle.lifeTime/10, particle.clr )
			end
			-- circle particles
			if particle.tpe == 2 then
				if sin(rnd()) > 0.3 then
					circ(particle.x+rnd(), particle.y+rnd(), particle.lifeTime, particle.clr)
				end
			-- circl fill particle
			end
			if particle.tpe == 3 then
				circfill( particle.x+sin(rnd()), particle.y+sin(rnd()), particle.lifeTime/1, particle.clr )
				--pset( particle.x+sin(rnd()), particle.y+sin(rnd()), particle.clr )
				--print("\146", particle.x+sin(rnd()), particle.y+sin(rnd()), particle.clr )
			end
		end
	end
end

function draw_enemies()
	for enemy in all(enemies) do
		if (enemy.speed <= 0) animate(enemy,enemy.spr,2,enemy.animspeed,true,false)
		if (enemy.speed > 0) animate(enemy,enemy.spr,2,enemy.animspeed,false,false)
	end
end

function draw_global_animations()
	-- draw animated grass
	for grass in all(foliage) do
		animate(grass,grass.spr,4,flr(rnd(6)) + 1,false,false)
	end
	-- initiate animation queue
	if not (#global.animation_queue == 0) then
		for anim in all(global.animation_queue) do
			animate(anim.object,anim.starting_frame,anim.number_of_frames,anim.speed,anim.tick,false)
			anim.lifetime -= 1
			if (not anim.persistent) and (anim.lifetime <= 0) then
				del(global.animation_queue,anim)
			end
		end
	end
end

function draw_ui(x,y)
	print("score", x, y+1, 7)
	print(player.score, x, y+9)
	spr(114, x+60, y)
	if player.currScore.lifetime > time() then
		print(player.currScore.val, player.currScore.x, player.currScore.y, 7)
	end
	print("x"..player.coins, x+68, y+1, 7)
end

function draw_pickups()
	for pickup in all(pickups) do
		if pickup.animLength > 1 then
			animate(pickup, pickup.spr, pickup.animLength, pickup.animSpeed, false, false)
		else
			spr(pickup.spr, pickup.x, pickup.y)
		end
	end
end

function draw_box(x1,y1,x2,y2,color1,color2)
		rectfill(x1,y1,x2,y2,color1)
		rectfill(x1+1,y1+1,x2-1,y2-1,color2)
end

function draw_foliage()
	for fol in all(foliage) do
		animate(fol, fol.spr, 4, 2, false, false)
	end
end


function draw_transition(_x,_y)
	local dither = {…,░,▤,█}
	--0b0011001111001100
	--0b0001000100010001
	fillp(dither[global.transition_number+1])
	for i=1,16 do
		rectfill(_x,_y+global.transition_y*8,_x+i*8,_y+(global.transition_y+1)*8,0)	
	end
	global.transition_y+=1
	if (global.transition_y > 16) then
		global.transition_y = 0
		global.transition_number+=1
		if global.transition_number > 4 then
			global.transition = false
			global.transition_y = 0
			global.transition_number = 0
		end
	end
end


__gfx__
000000000bbbbbbbbbbbbbbbbbbbbb00bbbbbbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbb333333bbbb33333bbbb333bbb333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bb33322222233332222233bb233333223332233200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b32224444442222444442233423232442324422400000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b32444444444444444444423442424444244444400000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000324444444444444444444442444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000032444444444444444444444244444444444444440000b000000000000000000000000000000000000000000000000000000000000000000000000000
00000000324444444444444444444442444444444444444400b0b0b0000000000000000000000000000000000000000000000000000000000000000000000000
2444444224444444444444444444442044222bbbbb22444400000000000000000000000000000000000000000000000000000000000000000000000000000000
024444420244444444422244444444424233333b33bb244400000000000000000000000000000000000000000000000000000000000000000000000000000000
00244442002444444420002444444420442223323332444400000000000000000000000000000000000000000000000000000000000000000000000000000000
02444420024444444200002444444420444442242324444400000000000000000000000000000000000000000000000000000000000000000000000000000000
02444420024444444200024444444442444444444244444400000000000000000000000000000000000000000000000000000000000000000000000000000000
24444420244444444420022444444442444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
24444420244444444422244444444420444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
0244444202444444444444444444420044444444444444440b00b000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb244444444444444444444442444442444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
333bbbb3024444444444444444444442444420244444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
22233332024444444444444444444420444420244444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
44422224244444444444444444444420444442444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
44644444244444444444444444444420424444444444444400000700000000000000000000000000000000000000000000000000000000000000000000000000
44444446244444444444444444444422202444444444444400007870000000000000000000000000000000000000000000000000000000000000000000000000
44442244024442444442224444444222200244444444444400000700000000000000000000000000000000000000000000000000000000000000000000000000
22220022002220222220002222222000422444444444444400000b00000000000000000000000000000000000000000000000000000000000000000000000000
444444440bbbbbbbbbbbbbbbbbbbbb00bccccccbbccccccb0bbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000
44999944bb333333333bbbb3bb3333b03111111331111113b33bbbbb000000000000000000000000000000000000000000000000000000000000000000000000
4949949433222222222333323322223b33122132331221322223333b000000000000000000000000000000000000000000000000000000000000000000000000
49944994324444444442222422444423232442242324422424422223000000000000000000000000000000000000000000000000000000000000000000000000
49944994324444444444444444444423424444444244444402444442000000000000000000000000000000000000000000000000000000000000000000000000
49499494324444444444444444444422444444444444444424444442000000000000000000000000000000000000000000000000000000000000000000000000
44999944022444424444224444444420444444444422224424424442000000000000000000000000000000000000000000000000000000000000000000000000
44444444000222222222002222222200444444442200002202202220000000000000000000000000000000000000000000000000000000000000000000000000
00f0f00000f0f00000f0f00000000000000000000000000000f0f000000000000000f0f00000f0f00ee0f0ff00eefff00f0f0000000000000000000000000000
0fffffff0fffffff0fffffff00f0f00000f0f00000f0f0000fffffff00f0f00000fffff00fffffff00efffff000efff0fffffff0000000000000000000000000
00f71fff00f71fff00f71fff0fffffff0fffffff0fffffff00f71fff00fffff000fffff00fff17f000e71fff000e1ff00f71fff0000000000000000000000000
00f77fff00f77fff00f77fff00f71fff00f7ffff00f71fff00f77fff00fffff000fffff00fff770000e77fff000e7ff00f77fff0000000000000000000000000
00067700000677000006770000f77fff00f77fff00f77fff0006770000fffff000067700000776000066776000067760fe667f00000000000000000000000000
ffe666f00ffe66f0ffe666f0000677000006770000067700ffe666f000067700ffe666f0ffe666f0ee6666600ee66660fee46200000000000000000000000000
0fee66ff00fee6f00fee66ffffe666f0ffe666f0ffe666f00fee66ffffe666f00fee66ff0fee66ff0ee6660000e6660000442200000000000000000000000000
00440220000442000044022000440220004402200044022000440220004402200044022000440220004402200004420000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000880000008800000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00898800008988000089980000899800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00889800008998000088980000899800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000880000008800000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000800000000080000000000000033330000333300003333000a993300003333000000000
0005000000090000000aa0000000000000000000000aa000008000000000800000000000008000000030000300300003009aa0030a300a030030000300077000
005050000090900000aa9a00000aa0000000a000000970000000800000000000008000000000000000300003003000030a300a03003000030030000300787700
000500000009000000aa9a0000079000000070000009700000080000008000000008000000008000000a00030009a0030a0a0a03a00900a30009000307777760
005500000099000000a99a000007900000007000000a700000898000008880000089800000888000000000bb000aa0bb0a000abb0000000b0000000b07877260
0005000000090000000aa0000007a00000007000000aa0000b898b000b898b000b898b000b898b00000000bb000000bb00aaa0bb0a000abb000000bb47776664
005500000099000000000000000aa0000000a0000000000003383300033833000338330003383300000003bb000003bb000003bb000a03bb000003bb24242424
00000000000000000000000000000000000000000000000000333000003330000033300000333000003333b0003333b0003333b0003333b0003333b002424240
00000666555556660000000000000000000000605555506000000000000000000000000000000000000000000000000000000000000000000000000000000000
555550665f8f80660000006600000000555550605f8f806000000060000000000000000000000000000000000000000000000000000000000000000000000000
5f8f80604ffff06055555066000000005f8f80402ffff04055555060000000000000000000000000000000000000000000000000000000000000000000000000
4ffff0604ffff0605f8f8060000000002ffff0402ffff0405f8f8060000000000000000000000000000000000000000000000000000000000000000000000000
55655ff055655ff055655ff05555500055955f4055955f4055955ff0555550000000000000000000000000000000000000000000000000000000000000000000
5424504054245040542450605f8f8f006642504026625040524250405f8f80000000000000000000000000000000000000000000000000000000000000000000
4444400044444000444440405555500066222040566220402222204055955f000000000000000000000000000000000000000000000000000000000000000000
50006000050600005000600044444066500600400506004050006000524250660000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555066000000005555506000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5f8f8060555550005f8f806055555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55655ff05f8f800055955ff05f8f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5424506055555f005242504055955f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444040444440002222204052425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50006000500060665000600050006066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00880880000808800088088000080880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80008988008089888000899808808998000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08808898800089980880889880088998000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080880088808800008088000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090000000000000077077000770770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00909000000000000788788707667667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090000088088000788888707666667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00990000088888000078887000766670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090000b08880b00078887000766670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00990000b33833b00007870000076700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003330000000700000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b00000000b000000b000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0b0b000b0b00b00b0b0b00b00b0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03b3b30003b3b30003b3b3003bb3b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333300033333000333330003333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000b000000000000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b030b00000b0bb00b030b000b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b030b0000b030b00b030b0b0030b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003b3b300003b3b3003b3b300b033300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b3b3b3000bb3b300b3b3b30b3bb3b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b33333b0b33333b0b33333bb33333b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333333033333330333333333333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800000000080000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000008000000008000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00898000008880000089800000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b898b000b898b000b898b000b898b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03383300033833000338330003383300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333000003330000033300000333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000400000000400000040000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04000400004000404000040004004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040300004400304040030004403000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03040300003400303040030003400300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030300030303000303030003030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303b3000303b3000303b3000303b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03b3b3b003b3b3b003b3b3b003b3b3b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001010101010000000000000000000001010101010100000000000000000000010101010101000000000000000000000301010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
f000000000000000000000000000000000000000000000000000000072000000007200000072000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000112525252525252525130000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000000000000000000000000000000000072000000007200000072000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000112522222222222225130000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000000000000000000000036000000000036000000003600000036000000007200000000000000000000000000000000000000000000000000000000000000000000000000000000111300000000000011130000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000000303000000000000000000000000000000000000000000000000000003600000000000000000000000000000000000000000000000000000000000000000000000000000000111300000000000011130000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000030303000000000000000000000000000000000000000000000000000000000007200000000000000000000000000000000000000000000000000000000000000000000000000111300000000000011130000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000000303030000000000000000000000000000000000000000000000000000000000036000000000000000000000000000000000000000000000000000000000000000000000000001113007f0000000011130000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000003030303000000000000000727200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000212232323300000011130000000000000000000000000000000000000000000000000000000000000000000000
100000000000000000000030303030300000000000000072720000000000000000000000000000000000720000000000360000000000000000000000000000000000000000000000000000000000000000000000000000000000c011130000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000067616303030303000000000000000000000000000000000000000000000720000007200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003115130000000000000000000000000000000000000000000000000000000000000000000000
10000000000000003132333030303030000000000000840000000000000000007200720000007200000000000000000000000000000000000000000000000026000000000000000000000000000000000000c084000000d000840011130000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000072727272000000000000313235330000000000007200720000000000008406d0000000000000300000000000000000000000003600000000000000000000007272000000000102020202020202020215130000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000000000000000000000000000000000000000000000000000000840000010202020300000000d030c000d0000000000000000000000000000000000000000000d000000000001125252525252524251225130000000000000000000000000000000000000000000000000000000000000000000000
100000000000300000000000c07a26c000000000000000003000000000000084d000f0000102020215122222230000003132320202030000000000300000000000000000727200000000310202330000001125252512252525252525130000000000000000000000000000000000000000000000000000000000000000000000
100040d000303000f000f0000102020380f000f000000102040300000000010202023402151222222223000000000000000000111213008000f0303030008400000000d0000000000000001000000000001112252525252525252525130000000000000000000000000000000000000000000000000000000000000000000000
0202040202040502023404050502040204023402040215252513000000001124252525242513727272720084000000000000001112140204340205020405020503000031320233000000001000000000001125252425252512252524130000000000000000000000000000000000000000000000000000000000000000000000
2222222222222222222222222222222222222222222222222213000000002122222222222223313232323232323233000000002122222222222222222222222223000000001000000000001000000000002122222222222222222222230000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0101000000050010500205003050050500605008050140501605008050090500b0500d0501005018050190500d000090000200001000000000000000000000000000000000000000000000000000000000000000
000100000e1600c1500a1400914007130051300212001120001100010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
011000002b03037050370301800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
