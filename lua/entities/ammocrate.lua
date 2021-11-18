AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Ammo Box"
ENT.Author 			= "Luiggi33"
ENT.Contact 		= "Luiggi33"
ENT.Information		= "Ammo Box to be dropped"
ENT.Category		= "AmmoDrops"

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()

    self:NetworkVar( "Int", 1, "Amount" )

    if SERVER then
        self:SetAmount(4)
    end

end

if CLIENT then
    function ENT:Draw() self:DrawModel() end
end

if not SERVER then return end

function ENT:Initialize()
    self:SetModel("models/Items/ammocrate_ar2.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    local phyis = self:GetPhysicsObject()
    if (phyis:IsValid()) then
        phyis:Sleep()
    end
    ControllFall(self)
    self.use = true
end

function ControllFall(entity)
    landed = false
    entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
    timer.Create("controlledFalling", FrameTime(), 0, function()
        local mins = entity:OBBMins() + Vector(0,0,-10)
        local maxs = entity:OBBMaxs() + Vector(0,0,-10)
        local startpos = entity:GetPos()

        local tr = {
            start = startpos,
            endpos = startpos,
            mins = mins,
            maxs = maxs
        }

        local hullTrace = util.TraceHull( tr )
        if (hullTrace.HitWorld) then
            landed = true
            timer.Remove( "controlledFalling" )
            entity:SetCollisionGroup(COLLISION_GROUP_NONE)
            entity:SetMoveType(MOVETYPE_VPHYSICS)
        else
            entity:GetPhysicsObject():SetVelocity(Vector(0,0,-1000))
        end
    end)
end

function ENT:Use(activator)
    if (self.use) then
        if self:GetAmount() > 0 then
            local curAmmoType = activator:GetActiveWeapon()
            curAmmoType = curAmmoType:GetPrimaryAmmoType()
            activator:GiveAmmo(200, curAmmoType)

            self:SetAmount(math.Clamp(self:GetAmount() - 1, 0, 4))

            self.use = false
            timer.Create("InUseAmmoCrate", 0.3, 1, function() usereply(self) end )
        elseif self:GetAmount() <= 0 then
            self:Remove()
        end
    end
end

function usereply(self)
    self.use = true
end