return function(self)
    self:setmusic("flowey_test.mp3")
    self.soul:setlove(19)
    self.battlebg.image = IMAGE "boss_battle_bg"
    local opponent = self:makeopponent("Flowey", "flowey", 999, {
        fleechance = 0,
        canspare = false,
        atk = 19,
        def = 45
    })
    opponent:makeacts("* FLOWEY - 9999 ATK 9999 DEF\n* Your best friend!\n* Also has a gun.", {
        {
            text = "Talk",
            onclick = function()
                self:endturn{"* He has a gun what are you doing"}
            end
        }
    })
    opponent.hidden = true
    local explodepiece = self:makebullet {
        spawned = function(self, xv, yv, movedelay)
            self.xv = xv
            self.yv = yv
            self.movedelay = movedelay or 0
            self.damage = 19
            self.animtimer = 0
        end,
        image = "friendly_bullet",
        update = function(self, battle)
            self.animtimer = self.animtimer + 1
            if self.animtimer > 4 then
                self.animtimer = 0
                if self.image == IMAGE "friendly_bullet" then
                    self.image = IMAGE "friendly_bullet_2"
                else
                    self.image = IMAGE "friendly_bullet"
                end
            end
            if self.movedelay > 0 then
                self.movedelay = self.movedelay - 1
                if self.movedelay == 0 then
                    PLAYSOUND "snd_arrow.wav"
                end
                return
            end
            self.x = self.x + self.xv
            self.y = self.y + self.yv
        end,
        width = 8,
        height = 8
    }
    function self:onupdate()
        if self.soul.hp <= 19 then
            opponent.image = IMAGE "flowey_grin"
        end
    end
    local testbullet = self:makebullet {
        spawned = function(self, bounces)
            self.damage = 19
            self.yv = 3
            self.canfall = bounces or 3
            self.isfalling = true
            self.explodetimer = 0
            if math.random() > 0.5 then
                self.xv = -2
            else
                self.xv = 2
            end
        end,
        image = "attack_smile",
        update = function(self, battle)
            if self.isfalling then
                self.x = self.x + self.xv
                self.y = self.y + self.yv
                self.yv = self.yv + 0.125
            else
                self.explodetimer = self.explodetimer + 1
                if self.explodetimer % 10 == 1 then
                    PLAYSOUND "snd_noise.wav"
                end
                if self.explodetimer > 30 then
                    battle:destroy(self)
                    battle:spawn(explodepiece, self.x, self.y, 4, 4)
                    battle:spawn(explodepiece, self.x, self.y, -4, 4)
                    battle:spawn(explodepiece, self.x, self.y, -4, -4)
                    battle:spawn(explodepiece, self.x, self.y, 4, -4)
                    battle:spawn(explodepiece, self.x, self.y, 6, 0)
                    battle:spawn(explodepiece, self.x, self.y, -6, 0)
                    battle:spawn(explodepiece, self.x, self.y, 0, 6)
                    battle:spawn(explodepiece, self.x, self.y, 0, -6)
                    PLAYSOUND "snd_bomb.wav"
                end
            end
            if self.canfall > 0 then
                if self.x < battle.box.x + self.width / 2 and self.xv < 0 then
                    self.x = battle.box.x + self.width / 2
                    self.xv = 2
                    PLAYSOUND "snd_bigdoor_open.wav"
                end
                if self.x > battle.box.x + battle.box.width - self.width / 2 and self.xv > 0 then
                    self.x = battle.box.x + battle.box.width - self.width / 2
                    self.xv = -2
                    PLAYSOUND "snd_bigdoor_open.wav"
                end
                if self.y > battle.box.y + battle.box.height - self.height / 2 and self.yv > 0 then
                    self.y = battle.box.y + battle.box.height - self.height / 2
                    self.yv = -4
                    self.canfall = self.canfall - 1
                    PLAYSOUND "snd_bigdoor_open.wav"
                end
            elseif self.yv == 0 then
                self.isfalling = false
            end
        end,
        draw = function(self, battle)
            if self.explodetimer % 10 <= 5 and self.explodetimer ~= 0 then
                love.graphics.setColor(1, 0, 0)
            end
            love.graphics.draw(self.image, self.x - self.image:getWidth() / 2, self.y - self.image:getHeight() / 2)
            love.graphics.setColor(1, 1, 1)
        end,
    }
    local function menubullet()
        self:queue(function()
            self:spawn(explodepiece, 640, self.buttons[self.selectedbutton].y + self.buttons[self.selectedbutton].souly, -6, 0)
            self:spawn(explodepiece, 640, self.buttons[self.selectedbutton].y + self.buttons[self.selectedbutton].souly - 10, -6, 0)
            self:spawn(explodepiece, 640, self.buttons[self.selectedbutton].y + self.buttons[self.selectedbutton].souly + 10, -6, 0)
        end)
        self:wait(1)
        self:queue(menubullet)
    end
    self:startattack(function()
        local x = self.box.x + math.random() * self.box.width
        self:queuespawn(testbullet, x, self.box.y - 150)
        self:wait(3)
        for i = 1, 10 do
            local x = self.box.x + math.random() * self.box.width
            self:queuespawn(testbullet, x, self.box.y - 150)
            self:wait(0.7)
        end
        self:queue(function()
            self:endattack("* what the actual fuck")
            menubullet()
            opponent.hidden = false
        end)
    end)
    local attacks = {
        {function()
            for i = 1, 14 do
                local x = self.box.x + math.random() * self.box.width
                self:queuespawn(testbullet, x, self.box.y - 150, 1)
                self:wait(0.5)
            end
            self:queue(function()
                self:endattack("* where did he get the bombs\n  from")
                menubullet()
            end)
        end, 288, 180},
        {function()
            for i = 1, 5 do
                for j = 1, i do
                    local x = self.box.x + math.random() * self.box.width
                    self:queuespawn(testbullet, x, self.box.y - 150 - math.random() * 50, 1)
                    self:wait(0.1)
                end
                self:wait(1)
            end
            self:queue(function()
                self:endattack("* airstrike")
                menubullet()
            end)
        end, 288, 180},
        {function()
            for i = 1, 15 do
                self:queue(function ()
                    self:spawn(explodepiece, self.soul.x, self.box.y - 50, 0, 4, 20)
                    self:spawn(explodepiece, self.soul.x, self.box.y + self.box.height + 50, 0, -4, 20)
                end)
                self:wait(0.25)
                self:queue(function ()
                    self:spawn(explodepiece, self.box.x - 50, self.soul.y, 4, 0, 20)
                    self:spawn(explodepiece, self.box.x + self.box.width + 50, self.soul.y, -4, 0, 20)
                end)
                self:wait(0.25)
            end
            self:queue(function()
                self:endattack("* Flowey commits armed robbery")
                menubullet()
                opponent.image = IMAGE "flowey_wink"
            end)
        end, 160, 140},
        {function()
            for i = 1, 15 do
                self:queue(function ()
                    self:spawn(explodepiece, self.soul.x, self.soul.y - 150, 0, 4, 10)
                    self:spawn(explodepiece, self.soul.x, self.soul.y + 150, 0, -4, 10)
                    self:spawn(explodepiece, self.soul.x - 150, self.soul.y, 4, 0, 10)
                    self:spawn(explodepiece, self.soul.x + 150, self.soul.y, -4, 0, 10)
                end)
                self:wait(0.5)
            end
            self:queue(function()
                self:endattack("* oh my god he has a gun")
                menubullet()
            end)
        end, 160, 140},
        {function()
            for i = 1, 10 do
                self:queue(function ()
                    self:spawn(explodepiece, self.soul.x, self.soul.y - 150, 0, 6, 30)
                    self:spawn(explodepiece, self.soul.x + 100, self.soul.y - 100, -4, 4, 30)
                    self:spawn(explodepiece, self.soul.x + 150, self.soul.y, -6, 0, 30)
                    self:spawn(explodepiece, self.soul.x + 100, self.soul.y + 100, -4, -4, 30)
                    self:spawn(explodepiece, self.soul.x, self.soul.y + 150, 0, -6, 30)
                    self:spawn(explodepiece, self.soul.x - 100, self.soul.y + 100, 4, -4, 30)
                    self:spawn(explodepiece, self.soul.x - 150, self.soul.y, 6, 0, 30)
                    self:spawn(explodepiece, self.soul.x - 100, self.soul.y - 100, 4, 4, 30)
                end)
                self:wait(0.8)
            end
            self:queue(function()
                self:endattack("* Smells like unoriginal\n  flavor text")
                menubullet()
            end)
        end, 160, 140},
        {function()
            for i = 1, 5 do
                for i = 1, 4 do
                    self:queue(function ()
                        local randx = math.random(-10, 10)
                        local randy = math.random(-10, 10)
                        PLAYSOUND "snd_noise.wav"
                        self:spawn(explodepiece, randx+self.soul.x, randy+self.soul.y - 150, 0, 6, 30)
                        self:spawn(explodepiece, randx+self.soul.x + 100, randy+self.soul.y - 100, -4, 4, 30)
                        self:spawn(explodepiece, randx+self.soul.x + 150, randy+self.soul.y, -6, 0, 30)
                        self:spawn(explodepiece, randx+self.soul.x + 100, randy+self.soul.y + 100, -4, -4, 30)
                        self:spawn(explodepiece, randx+self.soul.x, randy+self.soul.y + 150, 0, -6, 30)
                        self:spawn(explodepiece, randx+self.soul.x - 100, randy+self.soul.y + 100, 4, -4, 30)
                        self:spawn(explodepiece, randx+self.soul.x - 150, randy+self.soul.y, 6, 0, 30)
                        self:spawn(explodepiece, randx+self.soul.x - 100, randy+self.soul.y - 100, 4, 4, 30)
                    end)
                    self:wait(0.2)
                end
                self:wait(1)
            end
            self:queue(function()
                self:endattack("* Flowey started blasting")
                menubullet()
            end)
        end, 500, 280},
        {function ()
            for i = 1, 4 do
                for j = 1, 5, 1 do
                    self:queue(function ()
                        self:spawn(explodepiece, self.soul.x, self.box.y - 50, 0, 4)
                        PLAYSOUND "snd_arrow.wav"
                    end)
                    self:wait(0.15)
                end
                self:wait(0.15)
                for j = 1, 5, 1 do
                    self:queue(function ()
                        self:spawn(explodepiece, self.soul.x, self.box.y + self.box.height + 50, 0, -4)
                        PLAYSOUND "snd_arrow.wav"
                    end)
                    self:wait(0.15)
                end
                self:wait(0.15)
            end
            self:queue(function()
                self:endattack("* Flowey ran out of friendliness\n  pellets.\n* Those are just bullets.")
                menubullet()
            end)
        end},
        {function ()
			for j = 1, 30, 1 do
				self:queue(function ()
					self:spawn(explodepiece, self.soul.x, self.box.y - 50, 0, 4)
					self:spawn(explodepiece, self.soul.x, self.box.y + self.box.height + 50, 0, -4)
					self:spawn(explodepiece, self.box.x - 50, self.soul.y, 4, 0)
					self:spawn(explodepiece, self.box.x + 50 + self.box.width, self.soul.y, -4, 0)
					PLAYSOUND "snd_arrow.wav"
				end)
				self:wait(0.05)
			end
            self:queue(function()
                self:endattack("* what the fuck was that")
                menubullet()
            end)
        end},
    }
	local prevhp = opponent.hp
    function self:onenemyturn()
        local att = math.floor(math.random() * #attacks + 1)
        self:startattack(unpack(attacks[att]))
        opponent.image = IMAGE "flowey"
		if opponent.hp ~= prevhp then
			opponent.def = opponent.def - 4 - (45 - opponent.def) / 3
			if opponent.def < -700 then
				opponent.def = -700
			end
		end
		prevhp = opponent.hp
    end
end