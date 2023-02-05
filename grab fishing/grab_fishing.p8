pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--main tab
function _init()
	pal({-4,2,3,4,5,6,7,8,9,10,11,12},1)
	music(12,0,6)
	--game state
	mode="start"
	--stats
	score=0
	goal=0
	time=10
	level=1
	frame=0
	win=false
	stop_time=false
	stop_watch_timer=0
	total_score=0
	--menu
	menu_y=-32
	menu_x=-128
	menu_colour=14
	fish_y=64
	fish_vel=1
	--end screen
	win_y1=40
	win_y2=40
	win_velocity=0.2
	--objects
	game_objects={}
	--water
	water={
		x=0,
		y=0,
		velocity_y=0.1,
		update=function(self)
			--water scrolls and loops along the x axis
			self.x+=0.2
			if self.x>0 then
				self.x=-128
			end
			--water goes up and down along the y axis
			self.y+=self.velocity_y
			if self.y>35
			or self.y<0 then
				--changing direction by inverting velocity
				self.velocity_y= -self.velocity_y
			end
		end,
		draw=function(self)
			--drawing the front layer of water
			map(0,0,self.x,self.y,16,16)
			map(0,0,self.x+128,self.y,16,16)
			map(0,0,self.x,self.y-128,16,16)
			map(0,0,self.x+128,self.y-128,16,16)
		end
	}
	sparks={}
	local i
	for i=1,200 do
		add(sparks,{
			x=0,y=0,velx=0,vely=0,r=0,alive=false,mass=0
		})
	end
end

function _update60()
	frame_counter(60)
	if mode=="start" then
		update_start()
	elseif mode=="tutorial" then
		update_tutorial()
	elseif mode=="game" then
		update_game()
	elseif mode=="over" then
		update_over()
	elseif mode=="ending" then
		update_ending()
	end
	--sparks effect
	local i
	for i=1,#sparks do
		if sparks[i].alive then
			sparks[i].x+=sparks[i].velx/sparks[i].mass
			sparks[i].y+=sparks[i].vely/sparks[i].mass
			sparks[i].r-=0.1
			if sparks[i].r<0.1 then
				sparks[i].alive=false
			end
		end
	end
end

function _draw()
	--water background
	water:draw()
	if mode=="start" then
		draw_start()
	elseif mode=="tutorial" then
		draw_tutorial()
	elseif mode=="game" then
		draw_game()
	elseif mode=="over" then
		draw_over()
	elseif mode=="ending" then
		draw_ending()
	end
end
-->8
--game states
	function update_start()
		--water background
		water:update()
		--menu colour
		if frame>30 then
			menu_colour=2
		else
			menu_colour=14
		end
		--move grab down
		if menu_y<16 then
			menu_y+=1
		else
			--move in fishing after grab fishing
			if menu_x<8 then
				menu_x+=2
			end
		end
		--move fish up and down
		if fish_y>74
		or fish_y<40 then
			fish_vel= -fish_vel
		end
		fish_y+=fish_vel
		--start
		if btnp(4) then
			sfx(4)
			mode="tutorial"
		end
	end

	function draw_start()
		pal({-4,2,3,4,5,6,7,8,9,10,11,12},1)
		cls(1)
		--water background
		water:draw()
		--fish
		if menu_x>=8 then
			spr(136,32,fish_y,8,8)
		end

		--grab fishing
		spr(64,32,menu_y,2,2)
		spr(66,48,menu_y,2,2)
		spr(68,64,menu_y,2,2)
		spr(70,80,menu_y,2,2)
		spr(72,menu_x,32,2,2)
		spr(74,menu_x+16,32,2,2)
		spr(76,menu_x+32,32,2,2)
		spr(78,menu_x+48,32,2,2)
		spr(74,menu_x+64,32,2,2)
		spr(96,menu_x+80,32,2,2)
		spr(64,menu_x+96,32,2,2)

		--print menu text after text is in place
		if menu_x>=8 then
			rect(26,111,104,119,12)
			rectfill(27,112,103,118,1)
			print("press z/🅾️ to start",28,113,menu_colour)
		end
	end

	function update_tutorial()
		--menu colour
		if frame>30 then
			menu_colour=2
		else
			menu_colour=14
		end
		if btnp(4) then
			sfx(4)
			start_game()
		end
	end

	function draw_tutorial()
		cls(1)
		spr(41,0,0)
		spr(41,0,120,1,1,false,true)
		spr(41,120,0,1,1,true,false)
		spr(41,120,120,1,1,true,true)
		line(0,8,0,120,12)
		line(8,0,120,0,12)
		line(127,8,127,120,12)
		line(8,127,120,127,12)
		--tutorial text
		spr(9,48,4,2,1)
		spr(55,64,4)
		spr(56,72,4)
		spr(23,56,12,2,2)
		print("grab fish with ❎ to earn points",0,29,7)
		spr(1,60,35)
		print("grab coins for extra points",10,44,7)
		spr(3,60,50)
		print("stop watches will stop the timer",0,59,7)
		spr(11,44,66)
		spr(14,52,66,2,2)
		spr(12,68,66,2,1)
		print("trash will deduct points",14,83,7)
		spr(16,52,90)
		spr(32,60,90)
		spr(48,68,90)
		print("dangerous items will deduct",10,99,7)
		print("more points",42,106,7)

		print("press z/🅾️ to start",28,118,menu_colour)
	end

	function start_game()
		--resetting stats
		score=0
		win=false
		if level==1 then
			--change palette based on level
			pal({-4,2,3,4,5,6,7,8,9,10,11,12},1)
			--stats
			time=20
			goal=250
			--make game objects
			local i
			for i=0,4 do
				make_small_fish(8+i*25,-8,flr(rnd(2)),rnd(1)+0.25)
				make_seaweed(-8,8+i*25,rnd(1)+0.1)
			end
			for i=0,2 do
				make_reg_fish(12+i*42,-8,flr(rnd(3)),rnd(2)+0.75)
			end
		elseif level==2 then
			--change palette based on level
			pal({-4,2,3,4,5,6,7,8,9,10,11,12},1)
			--stats
			time=20
			goal=300
			--make game objects
			local i
			for i=0,4 do
				make_small_fish(8+i*25,-8,flr(rnd(2)),rnd(1)+0.25)
				make_seaweed(-8,8+i*25,rnd(1)+0.1)
			end
			for i=0,2 do
				make_reg_fish(12+i*42,-8,flr(rnd(3)),rnd(2)+0.75)
			end
			make_hook(-8,rnd(104)+10)
		elseif level==3 then
			pal({-4,2,3,4,5,6,7,8,9,10,11,12},1)
			--stats
			time=20
			goal=400
			--make game objects
			for i=0,4 do
				make_small_fish(8+i*25,-8,flr(rnd(2)),rnd(1)+0.25)
				make_seaweed(-8,8+i*25,rnd(1)+0.1)
			end
			for i=0,2 do
				make_reg_fish(12+i*42,-8,flr(rnd(3)),rnd(2)+0.75)
				make_hook(-8,rnd(104)+10)
			end
			make_coin(-8,rnd(104)+10)
		elseif level==4 then
			pal({1,2,3,4,5,6,7,8,9,10,11,-13},1)
			music(8,0,6)
			--stats
			time=20
			goal=450
			--make game objects
			for i=0,4 do
				make_small_fish(8+i*25,-8,flr(rnd(2)),rnd(1)+0.25)
			end
			for i=0,2 do
				make_reg_fish(12+i*42,-8,flr(rnd(3)),rnd(2)+0.75)
				make_can(-8,32+i*25,rnd(1)+0.1)
			end
			make_coin(-8,rnd(104)+10)
			make_jellyfish(-8,rnd(104)+10)
			make_jellyfish(-8,rnd(104)+10)
		elseif level==5 then
			pal({1,2,3,4,5,6,7,8,9,10,11,-13},1)
			--stats
			time=25
			goal=550
			--make game objects
			for i=0,4 do
				make_small_fish(8+i*25,-8,flr(rnd(2)),rnd(1)+0.25)
			end
			for i=0,2 do
				make_can(-8,32+i*25,rnd(1)+0.1)
				make_jellyfish(-8,32+i*25)
			end
			make_coin(-8,rnd(104)+10)
			make_eel(rnd(48)+32,-8,rnd(2)+0.75)
			make_seaweed(-8,rnd(104)+10,rnd(1)+0.1)
			make_bag(-8,rnd(104)+10,rnd(1)+0.1)
		elseif level==6 then
			pal({1,2,3,4,5,6,7,8,9,10,11,-13},1)
			--stats
			time=15
			goal=650
			--make game objects
			for i=0,4 do
				make_reg_fish(8+i*25,-8,flr(rnd(2)),rnd(1)+0.25)
			end
			for i=0,2 do
				make_can(-8,32+i*25,rnd(1)+0.1)
				make_jellyfish(-8,32+i*25)
			end
			make_stop_watch(-8,rnd(104)+10)
			make_eel(rnd(48)+32,-8,rnd(2)+0.75)
			make_bag(-8,rnd(104)+10,rnd(1)+0.1)
			make_bag(-8,rnd(104)+10,rnd(1)+0.1)
		elseif level==7 then
			pal({-13,2,3,4,5,6,7,8,9,10,11,3},1)
			music(4,0,6)
			--stats
			time=10
			goal=750
			--make game objects
			for i=0,4 do
				make_reg_fish(8+i*25,-8,flr(rnd(2)),rnd(1)+0.25)
			end
			for i=0,2 do
				make_bag(-8,32+i*25,rnd(1)+0.1)
			end
			make_stop_watch(-8,rnd(104)+10)
			make_eel(rnd(48)+32,-8,rnd(2)+0.75)
			make_jellyfish(-8,rnd(104)+10)
			make_can(-8,rnd(104)+10,rnd(1)+0.1)
		elseif level==8 then
			pal({-13,2,3,4,5,6,7,8,9,10,11,3},1)
			--stats
			time=10
			goal=800
			--make game objects
			for i=0,4 do
				make_reg_fish(8+i*25,-8,flr(rnd(2)),rnd(1)+0.25)
			end
			for i=0,2 do
				make_bag(-8,32+i*25,rnd(1)+0.1)
			end
			make_stop_watch(-8,rnd(104)+10)
			make_coin(-8,rnd(104)+10)
			make_eel(rnd(48)+32,-8,rnd(2)+0.75)
			make_bomb(-8,rnd(104)+10)
			make_jellyfish(-8,rnd(104)+10)
			make_can(-8,rnd(104)+10,rnd(1)+0.1)
		elseif level==9 then
			pal({-14,2,3,4,5,6,7,8,9,10,11,-8},1)
			music(0,0,6)
			--stats
			time=10
			goal=950
			--make game objects
			for i=0,4 do
				make_reg_fish(8+i*25,-8,flr(rnd(2)),rnd(1)+0.25)
			end
			for i=0,2 do
				make_eel(4+i*50,-8,rnd(2)+0.75)
				make_bomb(-8,32+i*25,rnd(1)+0.1)
			end
			make_bag(-8,rnd(104)+10,rnd(1)+0.1)
			make_coin(-8,rnd(104)+10)
			make_stop_watch(-8,rnd(104)+10)
			make_jellyfish(-8,rnd(104)+10)
		end
		make_player(52,64)
		--start game
		mode="game"
	end

	function update_game()
		--water background
		water:update()
		local obj
		for obj in all(game_objects)do
			obj:update()
		end
		--stop watch power up
		stop_watch_timer-=1
		if stop_watch_timer>0 then
			stop_time=true
		else
			stop_time=false
		end
		stop_watch_timer=mid(0,stop_watch_timer,300)
		--count time down
		if not stop_time then
			if time>0 then
				time-=1/60
			end
		end
		--limiting score
		score=mid(0,score,9999)
		--game end
		if score>=goal and time<0 then
			win=true
			total_score+=score
			level+=1
			mode="over"
		elseif score<goal and time<0 then
			win=false
			mode="over"
		end
	end

	function draw_game()
		cls(1)
		--water background
		water:draw()
		local obj
		for obj in all(game_objects)do
			obj:draw()
		end
		local i
		for i=1,#sparks do
			if sparks[i].alive then
				circfill(
				sparks[i].x,
				sparks[i].y,
				sparks[i].r,
				12
				)
			end
		end
		--ui
		rectfill(0,0,128,7,1)
		rect(-1,-1,129,8,12)
		print("score:"..score,1,1,7)
		print("goal:"..goal,46,1,7)
		print("time:"..flr(time),96,1,7)
		if stop_time then
			rect(0,118,41,126,1)
			rectfill(1,119,40,125,12)
			print("stopwatch:",2,120,7)
			rectfill(41,120,41+stop_watch_timer/4,124,2)
			rectfill(42,121,40+stop_watch_timer/4,123,8)
		end
	end

	function update_over()
		--removing objects from previous level
		remove(game_objects)
		--water background
		water:update()
		--start
		if win and level==10 then
			pal({-4,2,3,4,5,6,7,8,9,10,11,12},1)
			music(16,0,6)
			mode="ending"
		else
			if btnp(4) then
				sfx(4)
				start_game()
			end
		end
	end

	function draw_over()
		cls(1)
		--water background
		water:draw()
		if win then
			rect(42,42,83,51,12)
			rect(30,49,96,64,12)
			rect(20,62,110,70,12)
			rectfill(43,43,82,50,1)
			rectfill(31,50,95,63,1)
			rectfill(21,63,109,69,1)
			print("well done!",44,44,7)
			print("level score:".. score,32,51,7)
			print("total score:".. total_score,32,58,7)
			print("press z/🅾️ to continue",22,64,7)
		else
			rect(44,42,82,51,12)
			rect(30,49,96,64,12)
			rect(20,62,110,70,12)
			rectfill(45,43,81,50,1)
			rectfill(31,50,95,63,1)
			rectfill(21,63,109,69,1)
			print("try again",46,44,7)
			print("level score:".. score,32,51,7)
			print("total score:".. total_score,32,58,7)
			print("press z/🅾️ to continue",22,64,7)
		end
	end

	function update_ending()
		--water background
		water:update()
		--menu colour
		if frame>30 then
			menu_colour=2
		else
			menu_colour=14
		end
		--well done text
		if win_y1>44 or win_y1<36 then
			win_velocity= -win_velocity
		end
		win_y1+=win_velocity
		win_y2-=win_velocity
		if btnp(4) then
			sfx(4)
			mode="start"
			music(12,0,6)
			--resetting stats
			score=0
			goal=0
			time=10
			level=1
			frame=0
			win=false
			stop_time=false
			stop_watch_timer=0
			total_score=0
		end
	end

	function draw_ending()
		cls(1)
		--water background
		water:draw()
		--score
		rect(30,25,96,33,12)
		rectfill(31,26,95,32,1)
		print("total score:".. total_score,32,27,7)
		--well
		spr(106,32,win_y1,2,2)
		spr(98,48,win_y2,2,2)
		spr(108,64,win_y1,2,2)
		spr(108,80,win_y2,2,2)
		--done
		spr(100,32,win_y2+22,2,2)
		spr(110,48,win_y1+22,2,2)
		spr(96,64,win_y2+22,2,2)
		spr(98,80,win_y1+22,2,2)
		--continue
		rect(20,82,110,90,12)
		rectfill(21,83,109,89,1)
		print("press z/🅾️ to continue",22,84,menu_colour)
	end
-->8
--game objects
--from bridgs tutorial
function make_game_object(name,x,y,props)
	local obj={
		name=name,
		x=x,
		y=y,
		velocity_x=0,
		velocity_y=0,
		update=function(self)
		end,
		draw=function(self)
		end,
		draw_bounding_box=function(self,colour)
			rect(self.x,self.y,self.x+self.width,self.y+self.height,colour)
		end,
		center=function(self)
			return self.x+self.width/2,self.y+self.height/2
		end,
		check_for_hit=function(self,other)
			return bounding_box_overlapping(self,other)
		end,
		check_for_collision=function(self,other,indent)
			--calculating the hit boxes
			local x,y,w,h=self.x,self.y,self.width,self.height
			--hit box top (blue)
			local top_hitbox={x=x+indent,y=y,width=w-2*indent,height=h/2}
			--hit box bottom (red)
			local bottom_hitbox={x=x+indent,y=y+h/2,width=w-2*indent,height=h/2}
			--hit box left (green)
			local left_hitbox={x=x,y=y+indent,width=w/2,height=h-2*indent}
			--hit box right (yellow)
			local right_hitbox={x=x+w/2,y=y+indent,width=w/2,height=h-2*indent}
			if bounding_box_overlapping(bottom_hitbox,other) then
				return "down"
			elseif bounding_box_overlapping(left_hitbox,other) then
				return "left"
			elseif bounding_box_overlapping(right_hitbox,other) then
				return "right"
			elseif bounding_box_overlapping(top_hitbox,other) then
				return "up"
			end
		end
	}
	--loop goes through the keys and values to add the properties to object
	local key,value
	for key,value in pairs(props) do
		obj[key]=value
	end
	add(game_objects,obj)
	return obj
end

function make_player(x,y)
	return make_game_object("player",x,y,{
		velocity_x=0,
		velocity_y=0,
		width=24,
		height=21,
		move_speed=1,
		grabbing=false,
		grab=0,
		update=function(self)
			--reset grab
			self.grabbing=false
			--friction
			self.velocity_x*=0.6
			self.velocity_y*=0.6
			--move left
			if btn(0) then
				self.velocity_x-=self.move_speed
			end
			--move right
			if btn(1) then
				self.velocity_x+=self.move_speed
			end
			--move up
			if btn(2) then
				self.velocity_y-=self.move_speed
			end
			--move down
			if btn(3) then
				self.velocity_y+=self.move_speed
			end
			--grabbing
			if btn(5) then
				self.grab+=1
			else
				self.grab=0
			end
			--this will stop the player from holding grab
			if self.grab>0 and self.grab<20 then
				self.grabbing=true
			end
			--limiting velocity
			self.velocity_x=mid(-4,self.velocity_x,4)
			self.velocity_y=mid(-4,self.velocity_y,4)
			--applying velocity
			self.x+=self.velocity_x
			self.y+=self.velocity_y
			--stoping hand from moving off screen
			self.x=mid(0,self.x,128-self.width)
			self.y=mid(9,self.y,128-self.height)
		end,
		draw=function(self)
			if self.grabbing then
				spr(17,self.x,self.y,3,3)
			else
				spr(4,self.x,self.y,3,4)
			end
			--player arm
			rectfill(self.x+4,self.y+self.height,self.x+19,128,4)
			
		end
	})
end

function make_reg_fish(x,y,colour,speed)
	return make_game_object("reg_fish",x,y,{
		width=16,
		height=8,
		sprite=7,
		is_collected=false,
		colour=colour,
		speed=speed,
		update=function(self) 
			if self.colour==0 then
				self.sprite=7
			elseif self.colour==1 then
				self.sprite=9
			else
				self.sprite=25
			end
			--movement
			self.y+=self.speed
			--looping
			if self.y>128 then
				self.y=-8
			end
			--collision
			for_each_game_object("player",function(player)
				if self:check_for_hit(player) 
				and player.grabbing
				and not self.is_collected then
					self.is_collected=true
					score+=10
					sfx(0)
					sfx(1)
					--sparks effect
					explosion(player.x+player.width/2,player.y+player.height/2,8,12)
				end
			end)
			--respawn
			if self.is_collected then
				self.y=-24
				self.colour=flr(rnd(3))
				self.speed=rnd(2)+0.75
				self.is_collected=false
			end
		end,
		draw=function(self)
			if not self.is_collected then
				spr(self.sprite,self.x,self.y,2,1)
				
			end
		end
	})
end

function make_small_fish(x,y,colour,speed)
	return make_game_object("small_fish",x,y,{
		width=8,
		height=8,
		sprite=55,
		is_collected=false,
		colour=colour,
		speed=speed,
		update=function(self) 
			if self.colour==1 then
				self.sprite=56
			else
				self.sprite=55
			end
			--movement
			self.y+=self.speed
			--looping
			if self.y>128 then
				self.y=-8
			end
			--collision
			for_each_game_object("player",function(player)
				if self:check_for_hit(player) 
				and player.grabbing
				and not self.is_collected then
					self.is_collected=true
					score+=5
					sfx(0)
					sfx(1)
					--sparks effect
					explosion(player.x+player.width/2,player.y+player.height/2,8,12)
				end
			end)
			--respawn
			if self.is_collected then
				self.y=-24
				self.colour=flr(rnd(2))
				self.speed=rnd(1)+0.25
				self.is_collected=false
			end
		end,
		draw=function(self)
			if not self.is_collected then
				spr(self.sprite,self.x,self.y)
				
			end
		end
	})
end

function make_eel(x,y,speed)
	return make_game_object("eel",x,y,{
		width=16,
		height=16,
		is_collected=false,
		speed=speed,
		update=function(self)
			--movement
			self.y+=self.speed
			--looping
			if self.y>128 then
				self.y=-16
			end
			--collision
			for_each_game_object("player",function(player)
				if self:check_for_hit(player) 
				and player.grabbing
				and not self.is_collected then
					self.is_collected=true
					score+=25
					sfx(0)
					sfx(1)
					--sparks effect
					explosion(player.x+player.width/2,player.y+player.height/2,8,12)
				end
			end)
			--respawn
			if self.is_collected then
				self.y=-64
				self.speed=rnd(2)+1.5
				self.is_collected=false
			end
		end,
		draw=function(self)
			if not self.is_collected then
				spr(23,self.x,self.y,2,2)
				
			end
		end
	})
end

function make_seaweed(x,y,speed)
	return make_game_object("seaweed",x,y,{
		width=8,
		height=8,
		is_collected=false,
		speed=speed,
		update=function(self)
			--movement
			self.x+=self.speed
			--looping
			if self.x>128 then
				self.x=-8
			end
			--collision
			for_each_game_object("player",function(player)
				if self:check_for_hit(player) 
				and player.grabbing
				and not self.is_collected then
					self.is_collected=true
					score-=10
					sfx(0)
					sfx(3)
					--sparks effect
					explosion(player.x+player.width/2,player.y+player.height/2,8,12)
				end
			end)
			--respawn
			if self.is_collected then
				self.x=-64
				self.speed=rnd(1)+0.1
				self.is_collected=false
			end
		end,
		draw=function(self)
			if not self.is_collected then
				spr(11,self.x,self.y)
				
			end
		end
	})
end

function make_can(x,y,speed)
	return make_game_object("can",x,y,{
		width=16,
		height=8,
		is_collected=false,
		speed=speed,
		update=function(self)
			--movement
			self.x+=self.speed
			--looping
			if self.x>128 then
				self.x=-8
			end
			--collision
			for_each_game_object("player",function(player)
				if self:check_for_hit(player) 
				and player.grabbing
				and not self.is_collected then
					self.is_collected=true
					score-=10
					sfx(0)
					sfx(3)
					--sparks effect
					explosion(player.x+player.width/2,player.y+player.height/2,8,12)
				end
			end)
			--respawn
			if self.is_collected then
				self.x=-64
				self.speed=rnd(1)+0.1
				self.is_collected=false
			end
		end,
		draw=function(self)
			if not self.is_collected then
				spr(12,self.x,self.y,2,1)
				
			end
		end
	})
end

function make_bag(x,y,speed)
	return make_game_object("bag",x,y,{
		width=16,
		height=8,
		is_collected=false,
		speed=speed,
		update=function(self)
			--movement
			self.x+=self.speed
			--looping
			if self.x>128 then
				self.x=-16
			end
			--collision
			for_each_game_object("player",function(player)
				if self:check_for_hit(player) 
				and player.grabbing
				and not self.is_collected then
					self.is_collected=true
					score-=10
					sfx(0)
					sfx(3)
					--sparks effect
					explosion(player.x+player.width/2,player.y+player.height/2,8,12)
				end
			end)
			--respawn
			if self.is_collected then
				self.x=-64
				self.speed=rnd(1)+0.1
				self.is_collected=false
			end
		end,
		draw=function(self)
			if not self.is_collected then
				spr(14,self.x,self.y,2,2)
				
			end
		end
	})
end

function make_coin(x,y)
	return make_game_object("coin",x,y,{
		width=8,
		height=8,
		is_collected=false,
		speed=2,
		update=function(self)
			--movement
			self.x+=self.speed
			--looping
			if self.x>128 then
				self.x=-8
			end
			--collision
			for_each_game_object("player",function(player)
				if self:check_for_hit(player) 
				and player.grabbing
				and not self.is_collected then
					self.is_collected=true
					score+=50
					sfx(0)
					sfx(2)
					--sparks effect
					explosion(player.x+player.width/2,player.y+player.height/2,8,12)
				end
			end)
			--respawn
			if self.is_collected then
				self.x=-512
				self.y=rnd(104)+10
				self.is_collected=false
			end
		end,
		draw=function(self)
			if not self.is_collected then
				spr(1,self.x,self.y)
				
			end
		end
	})
end

function make_stop_watch(x,y)
	return make_game_object("stop_watch",x,y,{
		width=8,
		height=8,
		is_collected=false,
		speed=3.2,
		update=function(self)
			--movement
			self.x+=self.speed
			--looping
			if self.x>128 then
				self.x=-8
			end
			--collision
			for_each_game_object("player",function(player)
				if self:check_for_hit(player) 
				and player.grabbing
				and not self.is_collected then
					self.is_collected=true
					stop_watch_timer=300
					sfx(0)
					sfx(2)
					--sparks effect
					explosion(player.x+player.width/2,player.y+player.height/2,8,12)
				end
			end)
			self.power_counter=mid(0,self.power_counter,300)
			--respawn
			if self.is_collected and stop_watch_timer==0 then
				self.x=-1024
				self.y=rnd(104)+10
				self.is_collected=false
			end
		end,
		draw=function(self)
			if not self.is_collected then
				spr(3,self.x,self.y)
			end
		end
	})
end

function make_bomb(x,y)
	return make_game_object("bomb",x,y,{
		width=8,
		height=8,
		is_collected=false,
		speed=1,
		update=function(self)
			--movement
			self.x+=self.speed
			--looping
			if self.x>128 then
				self.x=-8
			end
			--collision
			for_each_game_object("player",function(player)
				if self:check_for_hit(player) 
				and player.grabbing
				and not self.is_collected then
					self.is_collected=true
					score-=50
					sfx(0)
					sfx(3)
					--sparks effect
					explosion(player.x+player.width/2,player.y+player.height/2,8,12)
				end
			end)
			--respawn
			if self.is_collected then
				self.x=-128
				self.y=rnd(104)+10
				self.is_collected=false
			end
		end,
		draw=function(self)
			if not self.is_collected then
				spr(16,self.x,self.y)
				
			end
		end
	})
end

function make_jellyfish(x,y)
	return make_game_object("jellyfish",x,y,{
		width=8,
		height=8,
		is_collected=false,
		speed=1,
		update=function(self)
			--movement
			self.x+=self.speed
			--looping
			if self.x>128 then
				self.x=-8
			end
			--collision
			for_each_game_object("player",function(player)
				if self:check_for_hit(player) 
				and player.grabbing
				and not self.is_collected then
					self.is_collected=true
					score-=25
					sfx(0)
					sfx(3)
					--sparks effect
					explosion(player.x+player.width/2,player.y+player.height/2,8,12)
				end
			end)
			--respawn
			if self.is_collected then
				self.x=-128
				self.y=rnd(104)+10
				self.is_collected=false
			end
		end,
		draw=function(self)
			if not self.is_collected then
				spr(32,self.x,self.y)
				
			end
		end
	})
end

function make_hook(x,y)
	return make_game_object("hook",x,y,{
		width=8,
		height=8,
		is_collected=false,
		speed=1,
		update=function(self)
			--movement
			self.x+=self.speed
			--looping
			if self.x>128 then
				self.x=-8
			end
			--collision
			for_each_game_object("player",function(player)
				if self:check_for_hit(player) 
				and player.grabbing
				and not self.is_collected then
					self.is_collected=true
					score-=10
					sfx(0)
					sfx(3)
					--sparks effect
					explosion(player.x+player.width/2,player.y+player.height/2,8,12)
				end
			end)
			--respawn
			if self.is_collected then
				self.x=-128
				self.y=rnd(104)+10
				self.is_collected=false
			end
		end,
		draw=function(self)
			if not self.is_collected then
				spr(48,self.x,self.y)
				
			end
		end
	})
end
-->8
--collision
--from bridgs tutorial
function rects_overlapping(left1,right1,top1,bottom1,left2,right2,top2,bottom2)
	return right1>left2 and right2>left1 and bottom1>top2 and bottom2>top1
end

--from bridgs tutorial
function bounding_box_overlapping(obj1,obj2)
	return rects_overlapping(obj1.x,obj1.x+obj1.width,obj1.y,obj1.y+obj1.height,obj2.x,obj2.x+obj2.width,obj2.y,obj2.y+obj2.height)
end
-->8
--functions
function frame_counter(limit)
	frame+=1
	if frame>limit then
		frame=0
	end
end

function remove(list)
	local i
	for i=1,#list do
		del(list, list[1])
	end
end

--from bridgs tutorial
function for_each_game_object(name,callback)
	local obj
	for obj in all(game_objects) do
		if obj.name==name then
			callback(obj)
		end
	end
end

--spark effect from mikamulperi
function explosion(x,y,r,particles)
	local selected=0
	for i=1,#sparks do
		if not sparks[i].alive then
			sparks[i].x=x
			sparks[i].y=y
			sparks[i].velx= -1+rnd(4)
			sparks[i].vely= -1+rnd(4)
			sparks[i].mass=0.5+rnd(1)
			sparks[i].r=0.2+rnd(r)
			sparks[i].alive=true
			selected+=1
			if selected==particles then
			break end
		end
	end
end

__gfx__
0000000000cccc00000cc00000cccc000000000000044000000000000cc000ccccccc0000cc000ccccccc0000cc000c000cccccccccccc0000cc00000000cc00
000000000caaaac000c77c000c6666c0000000000047740000000000ceec0ceeeeeeec00cbbc0cbbbbbbbc00cbbcccbc0c628887878826c00c76c000000c76c0
00700700caaaaaac0c7777c0c677776c000000440047740044000000ceeeceee2eeeeec0cbbbcbbb3bbbbbc00ccbbcbcc66628788878826cc7cc6c0000c7cc6c
00077000caa99aacc777777cc677876c000004774044440477400000ceeeeee2eeee2eeccbbbbbb3bbbb3bbccbccbbc0c65628877788826cc7cc6c0000c7cc6c
00077000caaaaaaccc7777ccc678776c000004774044440477400000ceeeeee2eeee2eeccbbbbbb3bbbb3bbc0cbbbbc0c65628888888826cc7cc6cc000c7cc6c
00700700c9aaaa9c0c7777c0c677776c000004444044440444400440ceeeceee2eeeeec0cbbbcbbb3bbbbbc0cbcbbbc0c66628888888826cc766777cc0c76c6c
000000000c9999c00c7777c00c6666c0000004444044440444404774ceec0ceeeeeeec00cbbc0cbbbbbbbc000cbcbcbc0c628888888826c0c77777777c77767c
0000000000cccc000cccccc000cccc000000044440422404444047740cc000ccccccc0000cc000ccccccc00000c0c0c000cccccccccccc00c77777777776777c
000cc00000000000000220000000000000000422404444042240444400cccccccccccc000cc000ccccccc000000000000000000000000000c77777777777667c
00c57c000000002200444200220000000440044440444404444044440caaaaaaaaaaaac0c99c0c9999999c00000000000000000000000000c77778777777777c
0c5557c0000004442044440444200000477404444044440444404444caaaaaaaaaaaaaacc999c999299999c00000000000000000000000000c7777777787777c
c555595c000004444044440444400000477404444044440444404444caaaccccccccaaacc99999929999299c0000000000000000000000000c778777777777c0
c555555c000004444044440444400220444404444044440444404224caac00000000caacc99999929999299c0000000000000000000000000c77787778777c00
c555555c000424444044440444404442444404444044440444404444caac000000000cc0c999c999299999c000000000000000000000000000c7778887777c00
0c5555c0044424444044440444404444444404444044440444404444caaacccccccccc00c99c0c9999999c00000000000000000000000000000c77777777c000
00cccc00424424444044440444404444422404444044440444404444caaaaaaaaaaaaac00cc000ccccccc0000000000000000000000000000000cccccccc0000
00cccc004424244444444444444444444444044444444444444444440caaaaaaaaaaaaac000ccccc000000000000000000000000000000000000000000000000
0c77e7c044442422444224442244444444440422444224442244444400ccccccccccaaac00c00000000000000000000000000000000000000000000000000000
c7eeeeec4444044424444244442422444444044424444244442422440caaaaaaaaaaaaac0c000000000000000000000000000000000000000000000000000000
ceeeeeec444444444444444444444424444444444444444444444424caaaaaaaaaaaaac0c0000000000000000000000000000000000000000000000000000000
ceeeeeec442244444444444444444444442244444444444444444444caaacccccccccc00c0000000000000000000000000000000000000000000000000000000
0c2e2ec0424444444444444444444444424444444444444444444444c9a9c00000000000c0000000000000000000000000000000000000000000000000000000
0c2e2ec0444444444444444444444444444444444444444444444444caaac00000000000c0000000000000000000000000000000000000000000000000000000
0cccccc04444444444444444444444444444444444444444444444440ccc000000000000c0000000000000000000000000000000000000000000000000000000
0c0000004444444444444444444444444444444444444444444444440000000000ccc00000000000000000000000000000000000000000000000000000000000
c6c000004444444444444444444444444444444444444444444444440c0ccc000c222c0000000000000000000000000000000000000000000000000000000000
c6c00c00444444444444444444444444444444444444444444444444c9c999c0c2eee2c000000000000000000000000000000000000000000000000000000000
c6c0c6c0044444444444444444444440044444444444444444444440c999929cc222e29c00000000000000000000000000000000000000000000000000000000
c6cc666c044444444444444444444440044444444444444444444440c999999cc22e229c00000000000000000000000000000000000000000000000000000000
c6ccc6c0004444444444444444444400004444444444444444444400c9c999c0c999999c00000000000000000000000000000000000000000000000000000000
0c666c000004444444444444444440000004444444444444444440000c0ccc000cccccc000000000000000000000000000000000000000000000000000000000
00ccc000000044444444444444440000000044444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000
00eeeeeeeeeeee0000eeeeeeeeeeee0000eeeeeeeeeeee0000eeeeeeeeeeee0000eeeeeeeeeeee0000eeeeeeeeeeee0000eeeeeeeeeeee0000ee00000000ee00
0eeeeeeeeeeeeee00eeeeeeeeeeeeee00eeeeeeeeeeeeee00eeeeeeeeeeeeee00eeeeeeeeeeeeee00eeeeeeeeeeeeee00eeeeeeeeeeeeee00eeee000000eeee0
2eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeee000002eeee0
2eeeeeeeeeeeee002eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeeeeeeeeeeee0022eeeeeeeeeeee002eeeeeeeeeeeee002eeee000002eeee0
2eeee222222220002eeee222222eeee02eeee222222eeee02eeee222222eeee02eeee22222222000022222eeee2220002eeee222222220002eeee000002eeee0
2eeee000000000002eeee000002eeee02eeee000002eeee02eeee000002eeee02eeee00000000000000002eeee0000002eeee000000000002eeee000002eeee0
2eeee000eeeeee002eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeeeeeeeeeeee002eeeeeeeeeeeee00000002eeee0000002eeeeeeeeeeeee002eeeeeeeeeeeeee0
2eeee002eeeeeee02eeeeeeeeeeeee002eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeeeeeeeeeeeee0000002eeee00000022eeeeeeeeeeeee02eeeeeeeeeeeeee0
2eeee002222eeee02eeeeeeeee2220002eeee222222eeee02eeee222222eeee02eeeeeeeeeeeeee0000002eeee00000002222222222eeee02eeeeeeeeeeeeee0
2eeee000002eeee02eeee2eeeee000002eeee000002eeee02eeee000002eeee02eeeeeeeeeeeee00000002eeee00000000000000002eeee02eeeeeeeeeeeeee0
2eeeeeeeeeeeeee02eeee22eeeee00002eeee000002eeee02eeeeeeeeeeeeee02eeee2222222200000eeeeeeeeeeee0000eeeeeeeeeeeee02eeee222222eeee0
2eeeeeeeeeeeeee02eeee022eeeee0002eeee000002eeee02eeeeeeeeeeeeee02eeee000000000000eeeeeeeeeeeeee00eeeeeeeeeeeeee02eeee000002eeee0
2eeeeeeeeeeeeee02eeee0022eeeee002eeee000002eeee02eeeeeeeeeeeeee02eeee000000000002eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeee000002eeee0
22eeeeeeeeeeee0022ee000022eeeee022ee00000022ee0022eeeeeeeeeeee0022ee00000000000022eeeeeeeeeeee0022eeeeeeeeeeee0022ee00000022ee00
02222222222220000220000002222200022000000002200002222222222220000220000000000000022222222222200002222222222220000220000000022000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eeeeeeeeeeee0000eeeeeeeeeeee0000eeeeeeeeee000000ee00000000ee0000ee00000000ee0000ee00000000ee0000ee00000000000000eeeeeeeeeeee00
0eeeeeeeeeeeeee00eeeeeeeeeeeeee00eeeeeeeeeeee0000eeee000000eeee00eeee000000eeee00eeee000000eeee00eeee000000000000eeeeeeeeeeeeee0
2eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeeeeeeeeeeee002eeee000002eeee02eeeee0000eeeee02eeee000002eeee02eeee000000000002eeeeeeeeeeeeee0
2eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeee000002eeee022eeeee00eeeee002eeee000002eeee02eeee000000000002eeeeeeeeeeeeee0
2eeee222222eeee02eeee222222eeee02eeee22222eeeee02eeee000002eeee0022eeeeeeeeee0002eeee000002eeee02eeee000000000002eeee222222eeee0
2eeee000002eeee02eeee000002eeee02eeee000022eeee02eeee000002eeee00022eeeeeeee00002eeee000002eeee02eeee000000000002eeee000002eeee0
2eeee000002eeee02eeeeeeeeeeeeee02eeee000002eeee02eeee000002eeee000022eeeeee000002eeee00ee02eeee02eeee000000000002eeee000002eeee0
2eeee000002eeee02eeeeeeeeeeeee002eeee000002eeee02eeee000002eeee000002eeeeee000002eeee02ee02eeee02eeee000000000002eeee000002eeee0
2eeee000002eeee02eeee222222220002eeee000002eeee02eeee000002eeee00000eeeeeeee00002eeee02ee02eeee02eeee000000000002eeee000002eeee0
2eeee000002eeee02eeee000000000002eeee00000eeeee02eeee000002eeee0000eeeeeeeeee0002eeee02ee02eeee02eeee000000000002eeee000002eeee0
2eeee000002eeee02eeeeeeeeeeeee002eeeeeeeeeeeeee02eeeeeeeeeeeeee000eeeee22eeeee002eeeeeeeeeeeeee02eeeeeeeeeeeee002eeeeeeeeeeeeee0
2eeee000002eeee02eeeeeeeeeeeeee02eeeeeeeeeeeee002eeeeeeeeeeeeee00eeeee0022eeeee02eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeeeeeeeeeeeee0
2eeee000002eeee02eeeeeeeeeeeeee02eeeeeeeeeeee0002eeeeeeeeeeeeee02eeee000022eeee02eeeeeeeeeeeeee02eeeeeeeeeeeeee02eeeeeeeeeeeeee0
22ee00000022ee0022eeeeeeeeeeee0022eeeeeeeeee000022eeeeeeeeeeee0022ee00000022ee0022eeeeeeeeeeee0022eeeeeeeeeeee0022eeeeeeeeeeee00
02200000000220000222222222222000022222222220000002222222222220000220000000022000022222222222200002222222222220000222222222222000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000ccccccc0000000000000000000ccc00000000000000000cc000000000000000000000000000000000000000000000000000000000000000000000
00000000000ccccccc00000000000000000ccccc00000000000000000cc000000000000000000000000000000000000000000000000000000000000000000000
0000000000ccccccccc0000000000000cccccccccc000000000000000ccc00000000000000000000000000000000000000000000000000000000000000000000
00000000ccccc000cccc0000000000ccccccc0ccccc0000000000000cccc00000000000000000000000000000000000000000000000000000000000000000000
0000000cccc000000ccccc0000000ccccc000000ccccc0000000000cccccc0000000000000000000000033000000000000000000000000000000000000000000
cccccccccc00000000cccccc000ccccc000000000cccccc0000000cccccccccc00000000000000000003bb300000000000000000000000000000000000000000
ccccccccc00000000000cccccccccccc00000000000ccccccc000ccccccccccc0000000000000000003bbbb30000000333333333333000000000000000000000
ccccccccc000000000000ccccccccccc0000000000000cccccccccccccc00ccc000000000000000003bbbbbb3000333bbbbbbbbbbbb333333000000000000000
000000ccccc0000000000cccccccccc000000000000000ccccccccccc000000000000000000000003bbbbbbb3333bbbbbbbbbbbbbbbbbbbbb303333000000000
000000000cc0000000000cccccccccc0000000000000000ccccccc00000000000000000000000003bbbbbb33bbbbbbbbbbbbbbbbbb333bbbbb3bbbb300000000
0000000000cc00000000ccccccccccc0000000000000000cccccc000000000000000000000000003bbbb33bbbbbbbbbbbbbbbbbbb37223bbb3bbbbbb30000000
00000000000cc000000cccccccccccccc00000000000000cccc0000000000000000000000000003bbbb3bbbbbbbbbbbbbbbbbbbbb3723bbb3bbb33bbb3000000
00000000000cc00000ccccc000000ccccc0000000000000ccc00000000000000000000000000003bbb3bbbbbbbbbbbbbbbbbbbbbbb33bbb3bbb3ee3bb3000000
00000000000cc0000ccc00000000000ccccc00000000000ccc0000000000000000000000000003bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3eee3bb3000000
00000000000ccccccc000000000000000ccccc000000000ccc0000000000000000000000000003bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbb3eee3bb3000000
0000000000ccccccc0000000000000000ccccccc0000000cc0000000000000000000000000003bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3eeee3bb3000000
0000000000ccccccc000000000000000000cccccccccccccc0000000000000000000000000003bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3eeee3bb3000000
000000000ccccccc0000000000000000000ccccccccccccccc00000000000000000000000003bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3eeee3bb3000000
000000000cccccccccc00000000000000ccccccccccccccccc00000000000000000000000003bb3bbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbb3eeee3bb3000000
000000000cccc000cccc00000000000ccccccc000000cccccc00000000000000000000000003b3bbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbb333333333300000
000000000ccc0000000cccc0000000cccccc0000000000ccccc0000000000000000000000003b3bbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbb30000
00000000cccc000000000ccccc000ccccccc000000000000cccccc00000000000000000000033bbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbb3000
0000cccccc00000000000ccccccccccccccc0000000000000ccccccccccccc000000000000003bbbbbbbbbb333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3000
cccccccccc00000000000000ccccccccccc0000000000000000ccccccccccccc0000000000003bbbbbbb333bbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000
cccccccccc0000000000000000ccccccccccc0000000000000cccccccccccccc0000000000003bbbbb33bbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbb300000
ccccccccc00000000000000000000cccccccccc0000000000ccccc0000000ccc000000000003bbbb33bbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbb3000000
00000cccc000000000000000000000ccccccccccccc00000ccccc00000000000000000000333bbb3bbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbb330000000
000000ccc00000000000000000000000ccccccccccccccccccccc00000000000000000003bb3bbbb33bbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbb33000000000
000000cccc0000000000000000000000cccccc00cccccccccccccc000000000000000003bbb3bbbbbb33bbbbbbbb3333bb33bbbbbbbbbbbbb333300000000000
0000000ccccc000000000000000000000ccc00000000000cccccccccc000000000000003bb3bbbbbbbbb33bbb333bbbbbbbbbbbbbbbbbbbb3b30000000000000
000000ccccccc00000000000000000000cc0000000000000000ccccccccccc0000000003bb3bbbbbbbbbbb333bbbbbbbbbbbbbbbbbbbbbb3bb30000000000000
0000ccccccccccc000000000000000ccccc00000000000000000000ccccccccc00000003bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbb3000000000000
ccccccccccccccccccc00000000000cccccc000000000000000000000ccccccc00000003bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3033bb3000000000000
ccccc00000cccccccccccccccccccccccccc0000000000000000000000cccccc00000003bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000330000000000000
00000000000ccccccccccccccccccccccccccc00000000000000000000cccc0000000003bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb300000000000000000000
00000000000cccccc0000000000ccccccccccccc00000000000000000cccc00000000003bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3000000000000000000000
00000000000ccccc000000000000000ccccccccccc0000000000000ccccc0000000000003b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000
00000000000ccccc0000000000000000cccccccccccccc000000000ccccc0000000000003b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbb300000000000000000000000
00000000000cccc000000000000000000cccc0000ccccccccc0000ccccccc000000000003b3bbbbbbbbbbbbbbbbbbbbbbbbbbb33000000000000000000000000
00000000000cccc000000000000000000cccc000000cccccccccccccccccccc0000000003b3bbbbbbbbbbbbbbbbbbbbbbbbb3300000000000000000000000000
000000000cccccc000000000000000000ccc00000000000cccccccc00ccccccc000000003b3bbbbbbbbbbbbbbbbbbbbbbb330000000000000000000000000000
cc000ccccccccc000000000000000000cccc000000000000000000000ccccccc000000003b3bbbbbbbbbbbbbbbbbbbbb33000000000000000000000000000000
ccccccccccccccc00000000000000000ccccc000000000000000000000cccccc0000000003b3bbbbbbbbbbbbbbbbbb3300000000000000000000000000000000
cccccccccccccccc000000000000000ccccccccc000000000000000000cccccc0000000003b3bbbbbbbbbbbbbbbb330003330000000000000000000000000000
000000000000cccccc000000000000ccccccccccccc000000000000000ccc000000000000033bbbbbbbbbbbbb33300033bbb3000000000000000000000000000
0000000000000cccccc0000000000cccccccccccccccc000000000000ccc00000000000000003bbbbbbbbbbb3000033bbbbb3000000000000000000000000000
00000000000000ccccccc000000ccccc0000ccccccccccccccccccccccc000000000000000003bbbbbbbbbbbb3333bbbbbbb3000000000000000000000000000
000000000000000ccccccccccccccc00000000cccccccccccccccccccc0000000000000000003bbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000
00000000000000cccccccccccccccc0000000000cccccccccccccccccc00000000000000000003bbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000
0000000000000cccc000000000cccc00000000000ccccccc0000ccccc000000000000000000003bbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000
00000000000ccccc0000000000cccc00000000000ccc000000000000cc000000000000000000003bbbbbbbbbbbbbbbbbbbb30000000000000000000000000000
0000000000ccccc0000000000000ccc0000000000cc00000000000000cc000000000000000000003bbbbbbbbbbbbbbbbbbb30000000000000000000000000000
000000000ccccc00000000000000ccc0000000000ccc00000000000000cc000000000000000000003bbbbbbbbbbbbbbbbbb30000000000000000000000000000
ccc00000cccc0000000000000000ccc00000000000cc000000000000000ccccc000000000000000003bbbbbbbbbbbbbbbbbb3000000000000000000000000000
cccccc00cccc00000000000000000ccc0000000000cccc0000000000000ccccc00000000000000000033bbbbbbbbbbbbbbbbb300000000000000000000000000
ccccccccccc000000000000000000ccccc00000000ccccccc0000000000ccccc0000000000000000000033bbbbbbbbbbbbbbb300000000000000000000000000
0000cccccc000000000000ccccccccccccc0000000ccccccccccc000000ccc00000000000000000000000033bbbbbbbbbbbbbb30000000000000000000000000
00000ccccc00000000000ccccccccccccccc000000cccccccccccc00000ccc0000000000000000000000000033bbbbbbbbbbbb30000000000000000000000000
0000000ccc0000000000cccccccccccccccc000000cccccccccccccc0ccccc000000000000000000000000000033bbbbbbbbbbb3000000000000000000000000
0000000cccc00000000cccccccc00cccccccc00000cccccc000cccccccccc000000000000000000000000000000033bbbbbbbbb3000000000000000000000000
00000000ccc0000000cccccc000000000cccccccccccc00000000cccccccc000000000000000000000000000000000333bbbbbbb300000000000000000000000
000000000cccccccccccc0000000000000ccccccccc00000000000cccccc0000000000000000000000000000000000000333bbbbb30000000000000000000000
000000000cccccccccccc000000000000000ccccc00000000000000ccccc00000000000000000000000000000000000000003333300000000000000000000000
00000000000ccccccccc00000000000000000cccc000000000000000cccc00000000000000000000000000000000000000000000000000000000000000000000
__label__
cccsssssssssssssssssscccccsssssssscccccccssssssssssccccccccccccccccsssssssssssssssssscccccsssssssscccccccssssssssssccccccccccccc
ccsssssssssssscccccccccccccssssssscccccccccccsssssscccssssssccccccsssssssssssscccccccccccccssssssscccccccccccsssssscccsssssscccc
ccssssssssssscccccccccccccccssssssccccccccccccssssscccssssssscccccssssssssssscccccccccccccccssssssccccccccccccssssscccsssssssccc
ccssssssssssccccccccccccccccssssssccccccccccccccscccccssssssssscccssssssssssccccccccccccccccssssssccccccccccccccscccccsssssssssc
cccssssssssccccccccssccccccccsssssccccccsssccccccccccssssssssssccccssssssssccccccccssccccccccsssssccccccsssccccccccccssssssssssc
cccsssssssccccccsssssssssccccccccccccssssssssccccccccssssssssssscccsssssssccccccsssssssssccccccccccccssssssssccccccccsssssssssss
sccccccccccccssssssssssssscccccccccsssssssssssccccccsssssssssssssccccccccccccssssssssssssscccccccccsssssssssssccccccssssssssssss
sccccccccccccssssssssssssssscccccsssssssssssssscccccsssssssssssssccccccccccccssssssssssssssscccccsssssssssssssscccccssssssssssss
ssscccccccccsssssssssssssssssccccsssssssssssssssccccssssssssssssssscccccccccsssssssssssssssssccccsssssssssssssssccccssssssssssss
ssscccccccssssssssssssssssssscccsssssssssssssssssccsssssssssssssssscccccccssssssssssssssssssscccsssssssssssssssssccsssssssssssss
ssscccccccssssssssssssssssscccccsssssssssssssssssccsssssssssssssssscccccccssssssssssssssssscccccsssssssssssssssssccsssssssssssss
sscccccccccsssssssssssssccccccccccssssssssssssssscccsssssssssssssscccccccccsssssssssssssccccccccccssssssssssssssscccssssssssssss
cccccsssccccsssssssssscccccccscccccsssssssssssssccccsssssssssssscccccsssccccsssssssssscccccccscccccsssssssssssssccccssssssssssss
cccsssssscccccssssssscccccsssssscccccssssssssssccccccssssssssssccccsssssscccccssssssscccccsssssscccccssssssssssccccccssssssssssc
ccssssssssccccccssscccccsssssssssccccccsssssssccccccccccccccccccccssssssssccccccssscccccsssssssssccccccssssssscccccccccccccccccc
csssssssssssccccccccccccssssssssssscccccccsssccccccccccccccccccccsssssssssssccccccccccccssssssssssscccccccsssccccccccccccccccccc
csssssssssssscccccccccccsssssssssseeeeeeeeeeeecccceeeeeeeeeeeecccseeeeeeeeeeeecccceeeeeeeeeeeesssssssccccccccccccccssccccccccccc
cccssssssssssccccccccccsssssssssseeeeeeeeeeeeeecceeeeeeeeeeeeeecceeeeeeeeeeeeeecceeeeeeeeeeeeeessssssscccccccccccssssssssssssscc
sccssssssssssccccccccccsssssssss2eeeeeeeeeeeeees2eeeeeeeeeeeeees2eeeeeeeeeeeeeec2eeeeeeeeeeeeeesssssssscccccccssssssssssssssssss
ssccsssssssscccccccccccsssssssss2eeeeeeeeeeeeess2eeeeeeeeeeeeees2eeeeeeeeeeeeeec2eeeeeeeeeeeeeessssssssccccccsssssssssssssssssss
sssccssssssccccccccccccccsssssss2eeee22222222sss2eeee222222eeees2eeee222222eeeec2eeee222222eeeessssssssccccsssssssssssssssssssss
sssccssssscccccsssssscccccssssss2eeeesscccssssss2eeeesssss2eeees2eeeesssss2eeees2eeeeccccc2eeeesssssssscccssssssssssssssssssssss
sssccsssscccssssssssssscccccssss2eeeessceeeeeess2eeeeeeeeeeeeees2eeeeeeeeeeeeees2eeeeeeeeeeeeessssssssscccssssssssssssssssssssss
ssscccccccssssssssssssssscccccss2eeeess2eeeeeees2eeeeeeeeeeeeess2eeeeeeeeeeeeees2eeeeeeeeeeeeeesssssssscccssssssssssssssssssssss
sscccccccssssssssssssssssccccccc2eeeess2222eeees2eeeeeeeee222sss2eeee222222eeees2eeee222222eeeecsssssssccsssssssssssssssssssssss
sscccccccssssssssssssssssssccccc2eeeeccccs2eeees2eeee2eeeeesssss2eeeeccccs2eeees2eeeesssss2eeeeccccccccccsssssssssssssssssssssss
scccccccsssssssssssssssssssccccc2eeeeeeeeeeeeees2eeee22eeeeessss2eeeecccss2eeees2eeeeeeeeeeeeeecccccccccccssssssssssssssssssssss
sccccccccccssssssssssssssccccccc2eeeeeeeeeeeeees2eeees22eeeeesss2eeeeccccc2eeees2eeeeeeeeeeeeeecccccccccccssssssssssssssssssssss
sccccsssccccssssssssssscccccccss2eeeeeeeeeeeeees2eeeess22eeeeess2eeeessscc2eeees2eeeeeeeeeeeeeesssssccccccssssssssssssssssssssss
scccsssssssccccsssssssccccccssss22eeeeeeeeeeeess22eessss22eeeees22eessssss22eecs22eeeeeeeeeeeesssssssscccccsssssssssssssssssssss
ccccssssssssscccccssscccccccsssss222222222222csss22ssssss22222ssc22csssssss22cccc222222222222sssssssssssccccccssssssssssssssssss
ccssssssssssscccccccccccccccssssssssssssscccccccccccccssssssccccccssssssssssscccccccccccccccssssssssssssscccccccccccccsssssscccc
ccsssssssseeeeeeeeeeeecccceeeeeeeeeeeesssseeeeeeeeeeeecccceeccccccsseesssseeeeeeeeeeeecccceeeeeeeeeeeesssseeeeeeeeeeeecccccccccc
ccssssssseeeeeeeeeeeeeecceeeeeeeeeeeeeesseeeeeeeeeeeeeecceeeecccccseeeesseeeeeeeeeeeeeecceeeeeeeeeeeeeesseeeeeeeeeeeeeeccccccccc
csssssss2eeeeeeeeeeeeeec2eeeeeeeeeeeeees2eeeeeeeeeeeeeec2eeeeccccs2eeees2eeeeeeeeeeeeeec2eeeeeeeeeeeeees2eeeeeeeeeeeeeeccccccccc
csssssss2eeeeeeeeeeeeecc22eeeeeeeeeeeess2eeeeeeeeeeeeess2eeeeccccs2eeees22eeeeeeeeeeeecc2eeeeeeeeeeeeees2eeeeeeeeeeeeesssssssccc
csssssss2eeee22222222sssc22222eeee222ccc2eeee22222222sss2eeeescccs2eeeess22222eeee222sss2eeee222222eeeec2eeee22222222ssssssssscc
ccssssss2eeeesssssssssssccccc2eeeecccccc2eeeecssssssssss2eeeescccc2eeeessssss2eeeessssss2eeeecsscc2eeeec2eeeecsssssssssssssssscc
ccccssss2eeeeeeeeeeeeessscccs2eeeesssssc2eeeeeeeeeeeeess2eeeeeeeeeeeeeessssss2eeeessssss2eeeesssss2eeeec2eeeeccceeeeeesssssssssc
cccccsss2eeeeeeeeeeeeeessccss2eeeessssss22eeeeeeeeeeeees2eeeeeeeeeeeeeessssss2eeeessssss2eeeesssss2eeees2eeeecc2eeeeeeessssssscc
cccccccs2eeeeeeeeeeeeeeccccss2eeeesssssss2222222222eeeec2eeeeeeeeeeeeeessssss2eeeesssscc2eeeesssss2eeees2eeeess2222eeeecsssscccc
cccccccc2eeeeeeeeeeeeeccccccs2eeeesssssssssssssssc2eeeec2eeeeeeeeeeeeeeccccss2eeeesssscc2eeeesssss2eeees2eeeessssc2eeeeccccccccc
sscccccc2eeee22222222ccccceeeeeeeeeeeesssseeeeeeeeeeeeec2eeee222222eeeeccceeeeeeeeeeeecc2eeeesssss2eeees2eeeeeeeeeeeeeeccccccsss
sssccccc2eeeecccccccccccceeeeeeeeeeeeeesseeeeeeeeeeeeees2eeeesssss2eeeecceeeeeeeeeeeeeec2eeeecssss2eeees2eeeeeeeeeeeeeesssssssss
sssccccc2eeeessssssccccc2eeeeeeeeeeeeees2eeeeeeeeeeeeees2eeeesssss2eeeec2eeeeeeeeeeeeeec2eeeecccss2eeees2eeeeeeeeeeeeeesssssssss
sssccccc22eesssssssssssc22eeeeeeeeeeeess22eeeeeeeeeeeess22eessssss22eecc22eeeeeeeeeeeesc22eecccccc22eess22eeeeeeeeeeeessssssssss
ssscccccs22sssssssssssssc222222222222csss222222222222ssss22ssssssss22cccs222222222222sssc22cccccccc22csss222222222222sssssssssss
sssccccssssssssssssssssssccccsssscccccccccsssscccccccssssssssssssssccccssssssssssssssssssccccsssscccccccccsssscccccccsssssssssss
sssccccssssssssssssssssssccccssssssccccccccccccccccccccssssssssssssccccssssssssssssssssssccccssssssccccccccccccccccccccsssssssss
sccccccsssssssssssssssssscccsssssssssssccccccccsscccccccsssssssssccccccsssssssssssssssssscccsssssssssssccccccccsscccccccssssssss
ccccccssssssssssssssssssccccssssssssssssssssssssscccccccccssscccccccccssssssssssssssssssccccssssssssssssssssssssscccccccccsssccc
cccccccssssssssssssssssscccccssssssssssssssssssssscccccccccccccccccccccssssssssssssssssscccccssssssssssssssssssssscccccccccccccc
ccccccccssssssssssssssscccccccccssssssssssssssssssccccccccccccccccccccccssssssssssssssscccccccccsssssssssssssssssscccccccccccccc
ssssccccccsssssssssssscccccccccccccssssssssssssssscccsssssssssssssssccccccsssssssssssscccccccccccccssssssssssssssscccsssssssssss
sssssccccccssssssssssccccccccccccccccsssssssssssscccsssssssssssssssssccccccssssssssssccccccccccccccccsssssssssssscccssssssssssss
sssssscccccccsssssscccccsssscccccccccccccccccccccccssssssssssssssssssscccccccsssssscccccsssscccccccccccccccccccccccsssssssssssss
ssssssscccccccccccccccssssssssccccccccccccccccccccssssssssssssssssssssscccccccccccccccssssssssccccccccccccccccccccssssssssssssss
ssssssccccccccccccccccssssssssssccccccccccccccccccssssssssssssssssssssccccccccccccccccssssssssssccccccccccccccccccssssssssssssss
sssssccccsssssssssccccssssssssssscccccccsssscccccssssssssssssssssssssccccsssssssssccccssssssssssscccccccsssscccccsssssssssssssss
ssscccccssssssssssccccssssssssssscccssssssssssssccssssssssssssssssscccccssssssssssccccssssssssssscccssssssssssssccssssssssssssss
sscccccssssssssssssscccssssssssssccssssssssssssssccssssssssssssssscccccssssssssssssscccssssssssssccssssssssssssssccsssssssssssss
scccccsssssssssssssscccsssssssssscccsssssssssssssscc33ssssssssssscccccsssssssssssssscccsssssssssscccssssssssssssssccssssssssssss
ccccsssssssssssssssscccsssssssssssccsssssssssssssss3bb3ccccsssssccccsssssssssssssssscccsssssssssssccsssssssssssssssccccccccsssss
ccccssssssssssssssssscccssssssssssccccssssssssssss3bbbb3ccccccs333333333333sssssssssscccssssssssssccccssssssssssssscccccccccccss
cccsssssssssssssssssscccccsssssssscccccccssssssss3bbbbbb3ccc333bbbbbbbbbbbb333333sssscccccsssssssscccccccssssssssssccccccccccccc
ccsssssssssssscccccccccccccssssssscccccccccccsss3bbbbbbb3333bbbbbbbbbbbbbbbbbbbbb3c3333ccccssssssscccccccccccsssssscccsssssscccc
ccssssssssssscccccccccccccccssssssccccccccccccs3bbbbbb33bbbbbbbbbbbbbbbbbb333bbbbb3bbbb3ccccssssssccccccccccccssssscccsssssssccc
ccssssssssssccccccccccccccccssssssccccccccccccc3bbbb33bbbbbbbbbbbbbbbbbbb37223bbb3bbbbbb3cccssssssccccccccccccccscccccsssssssssc
cccssssssssccccccccssccccccccsssssccccccsssccc3bbbb3bbbbbbbbbbbbbbbbbbbbb3723bbb3bbb33bbb3cccsssssccccccsssccccccccccssssssssssc
cccsssssssccccccsssssssssccccccccccccssssssssc3bbb3bbbbbbbbbbbbbbbbbbbbbbb33bbb3bbb3ee3bb3cccccccccccssssssssccccccccsssssssssss
sccccccccccccssssssssssssscccccccccssssssssss3bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3eee3bb3cccccccccsssssssssssccccccssssssssssss
sccccccccccccssssssssssssssscccccssssssssssss3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbb3eee3bb3sscccccsssssssssssssscccccssssssssssss
ssscccccccccsssssssssssssssssccccsssssssssss3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3eeee3bb3sssccccsssssssssssssssccccssssssssssss
ssscccccccssssssssssssssssssscccssssssssssss3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3eeee3bb3ssscccsssssssssssssssssccsssssssssssss
ssscccccccssssssssssssssssscccccsssssssssss3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3eeee3bb3scccccsssssssssssssssssccsssssssssssss
sscccccccccsssssssssssssccccccccccsssssssss3bb3bbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbb3eeee3bb3ccccccccssssssssssssssscccssssssssssss
cccccsssccccsssssssssscccccccscccccssssssss3b3bbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbb3333333333ccscccccsssssssssssssccccssssssssssss
cccsssssscccccssssssscccccsssssscccccssssss3b3bbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbb3sssscccccssssssssssccccccssssssssssc
ccssssssssccccccssscccccsssssssssccccccssss33bbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbb3ssssccccccssssssscccccccccccccccccc
csssssssssssccccccccccccssssssssssscccccccss3bbbbbbbbbb333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3sssssscccccccsssccccccccccccccccccc
csssssssssssscccccccccccsssssssssssssccccccc3bbbbbbb333bbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3sssssssssccccccccccccccssccccccccccc
cccssssssssssccccccccccssssssssssssssscccccc3bbbbb33bbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbb3ssssssssssscccccccccccssssssssssssscc
sccssssssssssccccccccccsssssssssssssssscccc3bbbb33bbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbb3ssssssssssssscccccccssssssssssssssssss
ssccsssssssscccccccccccsssssssssssssssscc333bbb3bbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbb33ssssssssssssssccccccsssssssssssssssssss
sssccssssssccccccccccccccssssssssssssssc3bb3bbbb33bbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbb33ccssssssssssssssccccsssssssssssssssssssss
sssccssssscccccsssssscccccsssssssssssss3bbb3bbbbbb33bbbbbbbb3333bb33bbbbbbbbbbbbb3333cccccssssssssssssscccssssssssssssssssssssss
sssccsssscccssssssssssscccccsssssssssss3bb3bbbbbbbbb33bbb333bbbbbbbbbbbbbbbbbbbb3b3sssscccccssssssssssscccssssssssssssssssssssss
ssscccccccssssssssssssssscccccsssssssss3bb3bbbbbbbbbbb333bbbbbbbbbbbbbbbbbbbbbb3bb3sssssscccccssssssssscccssssssssssssssssssssss
sscccccccsssssssssssssssscccccccsssssss3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbb3ssssscccccccsssssssccsssssssssssssssssssssss
sscccccccsssssssssssssssssscccccccccccc3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3s33bb3sssssssccccccccccccccsssssssssssssssssssssss
scccccccssssssssssssssssssscccccccccccc3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3ssss33sssssssscccccccccccccccssssssssssssssssssssss
sccccccccccsssssssssssssscccccccccccccc3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3ssssssssssssscccccccccccccccccssssssssssssssssssssss
sccccsssccccssssssssssscccccccssssssccc3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3cssssssssssscccccccssssssccccccssssssssssssssssssssss
scccsssssssccccsssssssccccccsssssssssscc3b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3sccccsssssssccccccsssssssssscccccsssssssssssssssssssss
ccccssssssssscccccssscccccccssssssssssss3b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3sssscccccssscccccccssssssssssssccccccssssssssssssssssss
ccssssssssssscccccccccccccccssssssssssss3b3bbbbbbbbbbbbbbbbbbbbbbbbbbb33ssssscccccccccccccccssssssssssssscccccccccccccsssssscccc
ccsssssssssssssscccccccccccsssssssssssss3b3bbbbbbbbbbbbbbbbbbbbbbbbb33sssssssssscccccccccccssssssssssssssssccccccccccccccccccccc
ccsssssssssssssssscccccccccccsssssssssss3b3bbbbbbbbbbbbbbbbbbbbbbb33sssssssssssssscccccccccccssssssssssssscccccccccccccccccccccc
cssssssssssssssssssssccccccccccsssssssss3b3bbbbbbbbbbbbbbbbbbbbb33sssssssssssssssssssccccccccccsssssssssscccccsssssssccccccccccc
cssssssssssssssssssssscccccccccccccsssssc3b3bbbbbbbbbbbbbbbbbb33cssssssssssssssssssssscccccccccccccssssscccccssssssssssssssssccc
csssssssssssssssssssssssccccccccccccccccc3b3bbbbbbbbbbbbbbbb33ccc333sssssssssssssssssssscccccccccccccccccccccssssssssssssssssscc
ccssssssssssssssssssssssccccccsscccccccccc33bbbbbbbbbbbbb333ssc33bbb3sssssssssssssssssssccccccssccccccccccccccsssssssssssssssscc
ccccssssssssssssssssssssscccsssssssssssccccc3bbbbbbbbbbb3ssss33bbbbb3sssssssssssssssssssscccsssssssssssccccccccccssssssssssssssc
cccccssssssssssssssssssssccssssssssssssssssc3bbbbbbbbbbbb3333bbbbbbb3ssssssssssssssssssssccsssssssssssssssscccccccccccsssssssscc
cccccccssssssssssssssscccccsssssssssssssssss3bbbbbbbbbbbbbbbbbbbbbb3cccssssssssssssssscccccsssssssssssssssssssscccccccccsssscccc
cccccccccccsssssssssssccccccsssssssssssssssss3bbbbbbbbbbbbbbbbbbbbb3cccccccsssssssssssccccccsssssssssssssssssssssccccccccccccccc
ssccccccccccccccccccccccccccsssssssssssssssss3bbbbbbbbbbbbbbbbbbbbb3ccccccccccccccccccccccccsssssssssssssssssssssscccccccccccsss
ssscccccccccccccccccccccccccccssssssssssssssss3bbbbbbbbbbbbbbbbbbbb3ccccccccccccccccccccccccccssssssssssssssssssssccccssssssssss
sssccccccsssssssssscccccccccccccsssssssssssssss3bbbbbbbbbbbbbbbbbbb3cccccsssssssssscccccccccccccsssssssssssssssssccccsssssssssss
ssscccccssssssssssssssscccccccccccsssssssssssssc3bbbbbbbbbbbbbbbbbb3ccccssssssssssssssscccccccccccssssssssssssscccccssssssssssss
ssscccccssssssssssssssssccccccccccccccssssssssscc3bbbbbbbbbbbbbbbbbb3cccssssssssssssssssccccccccccccccssssssssscccccssssssssssss
sssccccssssssssssssssssssccccsssscccccccccsssscccc33bbbbbbbbbbbbbbbbb3cssssssssssssssssssccccsssscccccccccsssscccccccsssssssssss
sssccccssssssssssssssssssccccssssssccccccccccccccccc33bbbbbbbbbbbbbbb3cssssssssssssssssssccccssssssccccccccccccccccccccsssssssss
sccccccsssssssssssssssssscccsssssssssssccccccccssccccc33bbbbbbbbbbbbbb3sssssssssssssssssscccsssssssssssccccccccsscccccccssssssss
ccccccssssssssssssssssssccccsssssssssssssssssssssccccccc33bbbbbbbbbbbb3sssssssssssssssssccccssssssssssssssssssssscccccccccsssccc
cccccccssssssssssssssssscccccssssssssssssssssssssscccccccc33bbbbbbbbbbb3sssssssssssssssscccccssssssssssssssssssssscccccccccccccc
ccccccccssssssssssssssscccccccccsssssssssssssssssscccccccccc33bbbbbbbbb3ssssssssssssssscccccccccsssssssssssssssssscccccccccccccc
ssssccccccsssssssssssscccccccccccccssssssssssssssscccsssssssss333bbbbbbb3csssssssssssscccccccccccccssssssssssssssscccsssssssssss
sssssccccccssssssssssccccccccccccccccsssssssssssscccsssssssssssss333bbbbb3cssssssssssccccccccccccccccsssssssssssscccssssssssssss
sssssscccccccsssssscccccsssscccccccccccccccccccccccsssssssssssssssss33333ccccsssssscccccsssscccccccccccccccccccccccsssssssssssss
ssssssscccccccccccccccssssssssccccccccccccccccccccssssssssssssssssssssscccccccccccccccssssssssccccccccccccccccccccssssssssssssss
ssssssccccccccccccccccssssssssssccccccccccccccccccssssssssssssssssssssccccccccccccccccssssssssssccccccccccccccccccssssssssssssss
sssssccccsssssssssccccssssssssssscccccccsssscccccssssssssssssssssssssccccsssssssssccccssssssssssscccccccsssscccccsssssssssssssss
ssscccccssssssssssccccssssssssssscccssssssssssssccssssssssssssssssscccccssssssssssccccssssssssssscccssssssssssssccssssssssssssss
sscccccssssssssssssscccssssssssssccssssssssssssssccssssssssssssssscccccssssssssssssscccssssssssssccssssssssssssssccsssssssssssss
scccccsssssssssssssscccsssssssssscccssssssssssssssccssssssssssssscccccsssssssssssssscccsssssssssscccssssssssssssssccssssssssssss
ccccsssssssssssssssscccsssssssssssccsssssssssssssssccccccccsssssccccsssssssssssssssscccsssssssssssccsssssssssssssssccccccccsssss
ccccssssssssssssssssscccssssssssssccccssssssssssssscccccccccccssccccssssssssssssssssscccssssssssssccccssssssssssssscccccccccccss

__map__
8081828384858687808182838485868700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9091929394959697909192939495969700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a1a2a3a4a5a6a7a0a1a2a3a4a5a6a700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b1b2b3b4b5b6b7b0b1b2b3b4b5b6b700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1c2c3c4c5c6c7c0c1c2c3c4c5c6c700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d2d3d4d5d6d7d0d1d2d3d4d5d6d700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e1e2e3e4e5e6e7e0e1e2e3e4e5e6e700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0f1f2f3f4f5f6f7f0f1f2f3f4f5f6f700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8081828384858687808182838485868700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9091929394959697909192939495969700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a1a2a3a4a5a6a7a0a1a2a3a4a5a6a700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b1b2b3b4b5b6b7b0b1b2b3b4b5b6b700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1c2c3c4c5c6c7c0c1c2c3c4c5c6c700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d2d3d4d5d6d7d0d1d2d3d4d5d6d700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e1e2e3e4e5e6e7e0e1e2e3e4e5e6e700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0f1f2f3f4f5f6f7f0f1f2f3f4f5f6f700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010500001265313650166301863018620186201962019610196151961500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000016770187601d7602775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500002277024770297603376000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000018770117700d7600876005740027400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000014770187601d750217500000014770187601d750217500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001305013050130301303013010130100f0500f0300f0300f0100c0500c0500c0300c0300c0100c0100f0500f0500f0300f0300f0100f0100c0500c0300c0300c010110501105011030110301101011010
0110000013050130501303013030130101301016050160301603016010180501805018030180301801018010130501305013030130301301013010110501103011030110100e0500e0500e0300e0300e0100e010
011000001305013050130301303013010130100f0500f0300f0300f0100e0500e0500e0300e0300e0100e0101105011050110301103011010110100e0500e0300e0300e0100c0500c0500c0300c0300c0100c010
011000001f5501f5501f5301f5301f5101f5101b5501b5301b5301b5101855018550185301853018510185101b5501b5501b5301b5301b5101b510185501853018530185101d5501d5501d5301d5301d5101d510
011000002355023550235302353023510235101f5501f5301f5301f5101b5501b5501b5301b5301b5101b5101f5501f5501f5301f5301f5101f5101b5501b5301b5301b510205502055020530205302051020510
011000001f5501f5501f5301f5301f5101f510225502253022530225102455024550245302453024510245101f5501f5501f5301f5301f5101f5101d5501d5301d5301d5101a5501a5501a5301a5301a5101a510
0110000023550235502353023530235102351026550265302653026510275502755027530275302751027510245502455024530245302451024510205502053020530205101d5501d5501d5301d5301d5101d510
011000001f5501f5501f5301f5301f5101f5101b5501b5301b5301b5101a5501a5501a5301a5301a5101a5101d5501d5501d5301d5301d5101d5101a5501a5301a5301a510185501855018530185301851018510
011000002355023550235302353023510235101f5501f5301f5301f5101d5501d5501d5301d5301d5101d5102055020550205302053020510205101d5501d5301d5301d5101b5501b5501b5301b5301b5101b510
011000000c153000001a235000000c153000000000000000306330000300003000030c153000001a235000000c153000001a235000000c153000000000000000306330000000000000000c153000003063330633
01100000130501305013040130401303013030130101301010050100501004010040100301003010010100100f0500f0300c0500c0300f0500f0500f0400f0400f0300f0300f0100f01012050120301203012010
01100000130501305013040130401303013030130101301010050100501004010040100301003010010100100f0500f0300c0500c0300f0500f0500f0400f0400f0300f0300f0100f01010050100301505015030
011000001305013050130401304013030130301301013010100501005010040100401003010030100101001012050120301305013030120501205012040120401203012030120101201013050130301505015030
011000001f5501f5501f5401f5401f5301f5301f5101f5101c5501c5501c5401c5401c5301c5301c5101c5101b5501b53018550185301b5501b5501b5401b5401b5301b5301b5101b5101e5501e5301e5301e510
0110000023550235502354023540235302353023510235101f5501f5501f5401f5401f5301f5301f5101f5101e5501e5301c5501c5301e5501e5501e5401e5401e5301e5301e5101e51021550215302153021510
011000001f5501f5501f5401f5401f5301f5301f5101f5101c5501c5501c5401c5401c5301c5301c5101c5101b5501b53018550185301b5501b5501b5401b5401b5301b5301b5101b5101c5501c5302155021530
0110000023550235502354023540235302353023510235101f5501f5501f5401f5401f5301f5301f5101f5101e5501e5301c5501c5301e5501e5501e5401e5401e5301e5301e5101e5101f5501f5302455024530
011000001f5501f5501f5401f5401f5301f5301f5101f5101c5501c5501c5401c5401c5301c5301c5101c5101e5501e5301f5501f5301e5501e5501e5401e5401e5301e5301e5101e5101f5501f5302155021530
0110000023550235502354023540235302353023510235101f5501f5501f5401f5401f5301f5301f5101f51021550215302355023530215502155021540215402153021530215102151023550235302455024530
011000000c153000000c1000000030633000001a200000000c153000031a2003060030633000001a200000000c153000000c1530000030633000001a200000000c153000001a2000000030633000003063330600
011000000c0500c0300c0300c010110501105011040110401103011030110101101010050100501004010040100301003010010100100d0500d0300d0300d0101305013050130401304013030130301301013010
011000000c0500c0300c0300c010110501105011040110401103011030110101101010050100501004010040100301003010010100100d0500d0500d0500d0400d0400d0400d0300d0300d0300d0200d0100d010
011000000c0500c0300c0300c010110501105011040110401103011030110101101010050100501004010040100301003010010100100d0500d0500d0400d0400d0300d0300d0100d0100a0500a0300a0300a010
01100000185501853018530185101d5501d5501d5401d5401d5301d5301d5101d5101c5501c5501c5401c5401c5301c5301c5101c510195501953019530195101f5501f5501f5401f5401f5301f5301f5101f510
011000001c5501c5301c5301c51020550205502054020540205302053020510205101f5501f5501f5401f5401f5301f5301f5101f5101d5501d5301d5301d5102255022550225402254022530225302251022510
01100000185501853018530185101d5501d5501d5401d5401d5301d5301d5101d5101c5501c5501c5401c5401c5301c5301c5101c510195501955019550195401954019540195301953019530195201951019510
011000001c5501c5301c5301c51020550205502054020540205302053020510205101f5501f5501f5401f5401f5301f5301f5101f5101d5501d5501d5501d5401d5401d5401d5301d5301d5301d5201d5101d510
01100000185501853018530185101d5501d5501d5401d5401d5301d5301d5101d5101c5501c5501c5401c5401c5301c5301c5101c510195501955019540195401953019530195101951016550165301653016510
011000001c5501c5301c5301c51020550205502054020540205302053020510205101f5501f5501f5401f5401f5301f5301f5101f5101d5501d5501d5401d5401d5301d5301d5101d51019550195301953019510
011000000c1530c1533060000000306330c10030633000000c1530c15330600306000c1533060030633306000c1530c15330600000000c1530000030633306000c1530c153306000000030633000003063330600
011000000f0500f0300f0300f01011050110301305013050130301303013010130101105011030110301101016050160501604016040160301603016010160101305013050130301303013010130101105011030
011000000f0500f0300f0300f0101105011030130501305013030130301301013010110501103011030110100f0500f0500f0400f0400f0300f0300f0100f0100c0500c0500c0300c0300c0100c0100e0500e030
011000000f0500f0300f0300f0101105011030130501305013030130301301013010110501103011030110100f0500f0500f0400f0400f0300f0300f0100f0100c0500c0500c0400c0400c0300c0300c0100c010
011000001b5501b5301b5301b5101d5501d5301f5501f5501f5301f5301f5101f5101d5501d5301d5301d51022550225502254022540225302253022510225101f5501f5501f5301f5301f5101f5101d5501d530
011000001f5501f5301f5301f51021550215302255022550225302253022510225102155021530215302151026550265502654026540265302653026510265102255022550225302253022510225102155021530
011000001b5501b5301b5301b5101d5501d5301f5501f5501f5301f5301f5101f5101d5501d5301d5301d5101b5501b5501b5401b5401b5301b5301b5101b5101855018550185301853018510185101a5501a530
011000001f5501f5301f5301f5102155021530225502255022530225302251022510215502153021530215101f5501f5501f5401f5401f5301f5301f5101f5101b5501b5501b5301b5301b5101b5101e5501e530
011000001b5501b5301b5301b5101d5501d5301f5501f5501f5301f5301f5101f5101d5501d5301d5301d5101b5501b5501b5401b5401b5301b5301b5101b5101855018550185401854018530185301851018510
011000001f5501f5301f5301f5102155021530225502255022530225302251022510215502153021530215101f5501f5501f5401f5401f5301f5301f5101f5101b5501b5501b5401b5401b5301b5301b5101b510
011000000c1530c10030600000000c1530c1003060000000306330c10030600306000c1533060030633306000c1530c10030600000000c153000003060030600306330c10030600000000c153306003063330633
011000000e0500e0300e0300e0100b0500b0300b0300b0100e0500e030100501003000000000001205012050120301203012010120100e0500e0500e0300e0300e0100e0100d0500d0300b0500b0300b0300b010
011000000e0500e0300e0300e0100b0500b0300b0300b0100e0500e030100501003000000000001205012050120301203012010120100e0500e0500e0300e0300e0100e0100d0500d03010050100301003010010
011000000e0500e0300e0300e0100b0500b0300b0300b0100e0500e030100501003000000000001205012050120301203012010120100d0500d0500d0500d0400d0400d0400d0300d0300d0300d0200d0200d010
011000001a5501a5301a5301a510175501753017530175101a5501a5301c5501c53000000000001e5501e5501e5301e5301e5101e5101a5501a5501a5301a5301a5101a510195501953017550175301753017510
011000001e5501e5301e5301e5101a5501a5301a5301a5101e5501e5301f5501f53000000000002155021550215302153021510215101e5501e5501e5301e5301e5101e5101c5501c5301a5501a5301a5301a510
011000001a5501a5301a5301a510175501753017530175101a5501a5301c5501c53000000000001e5501e5501e5301e5301e5101e5101a5501a5501a5301a5301a5101a51019550195301c5501c5301c5301c510
011000001e5501e5301e5301e5101a5501a5301a5301a5101e5501e5301f5501f53000000000002155021550215302153021510215101e5501e5501e5301e5301e5101e5101c5501c5301f5501f5301f5301f510
011000001a5501a5301a5301a510175501753017530175101a5501a5301c5501c53000000000001e5501e5501e5301e5301e5101e510195501955019550195401954019540195301953019530195201952019510
011000001e5501e5301e5301e5101a5501a5301a5301a5101e5501e5301f5501f53000000000002155021550215302153021510215101c5501c5501c5501c5401c5401c5401c5301c5301c5301c5201c5201c510
011000000c1530c1001a2351a2000c1530c10030633000000c1530c10030600306000c1003060030633306000c1530c1001a2351a2000c1530c10030633000000c1530c1001a235000000c15330600306001a200
__music__
01 0508090e
00 060a0b0e
00 0508090e
02 070c0d0e
01 0f121318
00 10141518
00 0f121318
02 11161718
01 191c1d22
00 1a1e1f22
00 191c1d22
02 1b202122
01 2326272c
00 2428292c
00 2326272c
02 252a2b2c
01 2d303136
00 2e323336
00 2d303136
02 2f343536

