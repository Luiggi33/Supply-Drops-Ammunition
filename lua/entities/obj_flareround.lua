AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Flare Round"
ENT.Author 			= "DrVrej"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Information		= "Projectile made by DrVrej"
ENT.Category		= "AmmoDrops"

ENT.Spawnable = false
ENT.AdminOnly = false

if CLIENT then
	function ENT:Draw() self:DrawModel() end
end

if (not SERVER) then return end

ENT.IdleSound1 = Sound("flare/acid_idle1.wav")
ENT.TouchSound = Sound("flare/metalhit1.wav")
ENT.TouchSoundv = 30
ENT.Decal = "Scorch"
ENT.AlreadyPaintedDeathDecal = false
ENT.Dead = false
ENT.FussTime = 10
ENT.NextTouchSound = 0

function ENT:Initialize()
	if self:GetModel() == "models/error.mdl" then
	self:SetModel("models/items/ar2_grenade.mdl") end
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetOwner(self:GetOwner())
	self:SetColor(Color(255,0,0))

	-- Physics Functions
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:SetBuoyancyRatio(0)
	end

	self.StartLight1 = ents.Create("light_dynamic")
	self.StartLight1:SetKeyValue("brightness", "0.01")
	self.StartLight1:SetKeyValue("distance", "1500")
	self.StartLight1:SetLocalPos(self:GetPos())
	self.StartLight1:SetLocalAngles( self:GetAngles() )
	self.StartLight1:Fire("Color", "255 0 0")
	self.StartLight1:SetParent(self)
	self.StartLight1:Spawn()
	self.StartLight1:Activate()
	self.StartLight1:Fire("TurnOn", "", 0)
	self:DeleteOnRemove(self.StartLight1)

	if self:GetOwner():IsValid() then
		timer.Simple(5,function() if IsValid(self) then self:DoDeath() end end)
	end

	self.ENVFlare = ents.Create("env_flare")
	self.ENVFlare:SetPos(self:GetPos())
	self.ENVFlare:SetAngles(self:GetAngles())
	self.ENVFlare:SetParent(self)
	self.ENVFlare:SetKeyValue("Scale","5")
	self.ENVFlare:SetKeyValue("spawnflags","4")
	self.ENVFlare:Spawn()
	self.ENVFlare:SetColor(Color(255,0,0))

	timer.Simple(2,function()
		if IsValid(self) then
			local phyics = self:GetPhysicsObject()
			if IsValid(phyics) and phyics:GetVelocity():Length() > 500 then
				phyics:SetMass(0.005)
				timer.Simple(10,function()
					if IsValid(self) then
						phyics:SetMass(5)
					end
				end)
			end
		end
	end)
end

function ENT:PhysicsCollide(data,physobj)
	if IsValid(data.HitEntity) and (data.HitEntity:IsNPC() or data.HitEntity:IsPlayer()) then
		local damagecode = DamageInfo()
		damagecode:SetDamage(math.random(4,8))
		damagecode:SetDamageType(DMG_BURN)
		damagecode:SetAttacker(self)
		damagecode:SetInflictor(self)
		damagecode:SetDamagePosition(data.HitPos)
		data.HitEntity:TakeDamageInfo(damagecode, self)
	end
end

function ENT:DoDeath()
	-- Removes
	self.Dead = true
	self:StopParticles()

	-- Damages
	timer.Simple(2,function()
	if IsValid(self) then
		self:Remove()
		end
	end)
end

function ENT:OnRemove()
	self.Dead = true
end