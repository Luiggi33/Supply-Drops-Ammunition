AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "DropShipLAAT"
ENT.Author 			= "Luna"
ENT.Category		= "AmmoDrops"

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.AutomaticFrameAdvance = true

-- List of Entities that will be dropped
ENT.DropTable = {"kleinebombe","rw_sw_dispencer","rw_sw_dispencer","rw_sw_dispencer"}
-- Radius where stuff gets checked
ENT.Radius = 1000
-- The Height of the flight
ENT.Height = 3000
-- Delay Between Items in Drops
ENT.Delay = 0.1
-- Offset of Marked Position and Beginning of the Drop
ENT.Offset = -700
-- Speed of the Ship
ENT.Speed = -1000
-- Model of the Ship
ENT.Model = "models/blu/laat.mdl"
-- Sound of the Ship
ENT.Sound = "laat/loop.wav"

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
    function ENT:Initialize()
        self.LoopSound = CreateSound(self, self.Sound)
        self.LoopSound:Play()
    end
    function ENT:OnRemove()
        self.LoopSound:FadeOut(1.5)
        timer.Simple(1.5, function() self.LoopSound:Stop() end)
    end
end

if not SERVER then return end

function ENT:OnRemove()
    if timer.Exists("FlyID" .. self:GetCreationID()) then
        timer.Remove("FlyID" .. self:GetCreationID())
    end
end

function ENT:Initialize()
    if table.IsEmpty(self.DropTable) then
        error("DropTable is empty")
        self:Remove()
        return
    end
    local oPos = self:GetPos()
    self:SetModel(self.Model)
    self:SetPos(self:GetPos() + Vector(5000,0,self.Height))
    self:SetAngles(Angle( 0, 180, 0 ))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_FLY)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:SetSolid(SOLID_VPHYSICS)
    local phyis = self:GetPhysicsObject()
    if (phyis:IsValid()) then
        phyis:Wake()
    end
    DropOfFlight(self, self:GetPos(), oPos)
end

function DropOfFlight(ent, startPos, dropPos)
    local inFlight = true
    local delay = 0

    timer.Create("FlyID" .. ent:GetCreationID(), FrameTime(), 0, function()
        if inFlight == true then
            if table.HasValue(ents.FindInSphere(dropPos + Vector(ent.Offset, 0, ent.Height), ent.Radius), ent) then
                if table.IsEmpty(ent.DropTable) then
                    print(ent)
                    timedRemoval(ent, 3)
                else
                    if CurTime() < delay then
                        goto after
                    end

                    local rand = math.random(1, #ent.DropTable)
                    local randItem = ent.DropTable[rand]
                    table.remove(ent.DropTable, rand)
                    local drop = ents.Create(randItem)
                    drop:SetPos(ent:GetPos() + Vector(50, 0, -200))
                    drop:Spawn()
                    drop:Activate()
                    delay = CurTime() + ent.Delay
                end
            end

            ::after::
            ent:SetVelocity(Vector(-1000, 0, 0))
        end
    end)
end

function timedRemoval(ent, secs)
    timer.Simple(secs, function()
        if IsValid(ent) then
            ent:Remove()
        end
    end)
end