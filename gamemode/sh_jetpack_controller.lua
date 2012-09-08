DEFINE_BASECLASS( "drive_base" );

drive.Register( "drive_jetpack", 
{
	--
	-- Calculates the view when driving the entity
	--
	CalcView =  function( self, view )

		--
		-- Use the utility method on drive_base.lua to give us a 3rd person view
		--
		--RunConsoleCommand("say", "asd")
		--self:CalcView_ThirdPerson( view, 100, 2, { self.Entity } )
		--view.origin = view.origin + view.angles:Forward() * 1000
		--self.Entity:SetNoDraw(false)

	end,

	--
	-- Called before each move. You should use your entity and cmd to 
	-- fill mv with information you need for your move. 
	--
	StartMove =  function( self, mv, cmd )

		--
		-- Update move position and velocity from our entity
		--
		mv:SetOrigin( self.Entity:GetNetworkOrigin() )
		mv:SetVelocity( self.Entity:GetAbsVelocity() )

	end,

	--
	-- Runs the actual move. On the client when there's 
	-- prediction errors this can be run multiple times.
	-- You should try to only change mv.
	--
	Move = function( self, mv )	
		local vel = mv:GetVelocity()
		local pos = mv:GetOrigin()
		
		vel = vel - Vector(0, 0, 300) * FrameTime()
		
		mv:SetVelocity(vel)
		--mv:SetOrigin(pos)
		
		local power = 200
		if mv:KeyDown(IN_JUMP) then
			power = 400
		end
		
		if mv:KeyDown(IN_RUN) then
			power = power * 4
		end
		
		if mv:KeyDown(IN_DUCK) then
			power = power / 4
		end
		
		self.Power = power
		
		local ang = mv:GetMoveAngles()
		
		local sidemove = 0
		if mv:KeyDown(IN_MOVELEFT) then
			sidemove = -1
		end
		if mv:KeyDown(IN_MOVERIGHT) then
			sidemove = 1
		end
		
		local fwdmove = 0
		if mv:KeyDown(IN_FORWARD) then
			fwdmove = -1
		end
		if mv:KeyDown(IN_BACK) then
			fwdmove = 1
		end
		
		fwdmove = fwdmove * 45
		sidemove = sidemove * 45
		
		self.FwdMove = self.FwdMove or 0
		self.FwdMove = self.FwdMove * 0.975
		self.FwdMove = self.FwdMove + fwdmove * FrameTime()
		
		self.SideMove = self.SideMove or 0
		self.SideMove = self.SideMove * 0.975
		self.SideMove = self.SideMove + sidemove * FrameTime()
		
		ang:RotateAroundAxis(ang:Right(), self.FwdMove)
		ang:RotateAroundAxis(ang:Forward(), self.SideMove)
		
		vel = vel + ang:Up() * power * FrameTime()
		pos = pos + vel
		
		mv:SetVelocity(vel)
		--mv:SetOrigin(pos)
		mv:SetMoveAngles(ang)
		
		
		if true then return end
		--
		-- Set up a speed, go faster if ( shift is held down
		--
		local speed = 0.0005 * FrameTime()
		if ( mv:KeyDown( IN_SPEED ) ) then speed = 0.005 * FrameTime() end

		--
		-- Get information from the movedata
		--
		local ang = mv:GetMoveAngles()
		local pos = mv:GetOrigin()
		local vel = mv:GetVelocity()

		--
		-- Add velocities. This can seem complicated. On the first line
		-- we're basically saying get the forward vector, ) then multiply it
		-- by our forward speed ( which will be > 0 if ( we're holding W, < 0 if ( we're
		-- holding S and 0 if ( we're holding neither ) - and add that to velocity.
		-- We do that for right and up too, which gives us our free movement.
		--
		vel = vel + ang:Forward() * mv:GetForwardSpeed() * speed
		vel = vel + ang:Right() * mv:GetSideSpeed() * speed
		vel = vel + ang:Up() * mv:GetUpSpeed() * speed

		--
		-- We don't want our velocity to get out of hand so we apply
		-- a little bit of air resistance. If no keys are down we apply
		-- more resistance so we slow down more.
		--
 		if ( math.abs( mv:GetForwardSpeed() ) + math.abs( mv:GetSideSpeed() ) + math.abs( mv:GetUpSpeed() ) < 0.1 ) then
			vel = vel * 0.90
		else
			vel = vel * 0.99
		end

		--
		-- Add the velocity to the position ( this is the movement )
		--
		pos = pos + vel

		--
		-- We don't set the newly calculated values on the entity itself
		-- we instead store them in the movedata. These get applied in F inishMove.
		--
		mv:SetVelocity( vel )
		mv:SetOrigin( pos )
		
		
		
	end,

	--
	-- The move is finished. Use mv to set the new positions
	-- on your entities/players.
	--
	FinishMove =  function( self, mv )

		--
		-- Update our entity!
		--
		--self.Entity:SetNetworkOrigin( mv:GetOrigin() )
		--self.Entity:SetAbsVelocity( mv:GetVelocity() )
		self.Entity:SetAngles( mv:GetMoveAngles() )
		
		self.Entity:SetAbsVelocity(mv:GetVelocity())
		
		if not self.sParent then
			self.sParent = true
			self.Player:SetPos(self.Entity:GetPos() + self.Entity:GetAngles():Forward() * 15 + self.Entity:GetAngles():Up() * -50)
			self.Player:SetParent(self.Entity)
			local pl = self.Player
			self.Entity:CallOnRemove("Unparent", function()
				pl:SetParent(nil)
				pl:SetPos(pl:GetShootPos())
			end)
		end
		--
		-- If we have a physics object update, that too; but only on the server.
		--
		if ( SERVER && IsValid( self.Entity:GetPhysicsObject() ) ) then

			--self.Entity:GetPhysicsObject():EnableMotion( true )
			--self.Entity:GetPhysicsObject():SetPos( mv:GetOrigin() );
			self.Entity:GetPhysicsObject():SetVelocity( mv:GetVelocity() );
			self.Entity:GetPhysicsObject():Wake()
			self.Entity:GetPhysicsObject():EnableMotion( true )
			
			local tr = util.QuickTrace(self.Entity:GetPos(), self.Entity:GetVelocity() * FrameTime() * 10, {self.Entity, self.Entity.Blade, self.Player})
			if tr.Hit then
				debugoverlay.Line(tr.StartPos, tr.HitPos, 5)
				self.Entity:Remove()
				self:Stop()
			end
			
			local blade = self.Entity.Blade
			local bladeang = blade:GetAngles()
			bladeang:RotateAroundAxis(bladeang:Up(), 30)
			blade:SetAngles(bladeang)
		end
		
		
		
	end,

}, "drive_base" );

if CLIENT then
	net.Receive("start_drive", function()
		local ent = net.ReadEntity()
		print(ent)
	end)
end

if SERVER then
	util.AddNetworkString("start_drive")
	concommand.Add("jetpack_stop", function(pl)
		drive.PlayerStopDriving( pl )
		pl:SetParent(nil)
	end)

	concommand.Add("jetpack", function(pl)
		local ent = ents.Create("prop_physics")
		ent:SetModel("models/props_c17/TrapPropeller_Engine.mdl")
		ent:SetPos(pl:GetEyeTrace().HitPos + Vector(0, 0, 100))
		ent:SetAbsVelocity(Vector(0, 0, 100))
		ent:Spawn()
		
		local blade = ents.Create("prop_physics")
		blade:SetModel("models/props_c17/TrapPropeller_Blade.mdl")
		
		local entang = ent:GetAngles()
		blade:SetPos(ent:GetPos() + entang:Up() * 25 + entang:Right() * 2.5)
		blade:Spawn()
		
		ent.Blade = blade
		
		blade:SetParent(ent)
		pl.JetPack = true
		
		net.Start("start_drive")
			net.WriteEntity(ent)
		net.Send(pl)
		
		
		drive.PlayerStartDriving( pl, ent, "drive_jetpack" )
		
	end)
	
	
	
	hook.Add("PlayerSpawn", function(pl) 
		if pl.JetPack then 
			pl.JetPack = false 
			pl:SetParent(nil)
		end
	end)
end