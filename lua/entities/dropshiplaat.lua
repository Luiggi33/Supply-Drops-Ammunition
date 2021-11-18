AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "DropShipLAAT"
ENT.Author 			= "Luna"
ENT.Category		= "AmmoDrops"

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.soundLoop = nil

ENT.AutomaticFrameAdvance = true

-- List of Entities that will be dropped
ENT.DropTable = {"ammocrate", "ammocrate"}
-- The Height of the flight
ENT.Height = 3000
-- Delay Between Items in Drops
ENT.Delay = 0.1
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
        self.soundLoop = Sound(self.Sound)
        self:EmitSound(self.soundLoop, 140, 100, 1, CHAN_STATIC)
    end
    function ENT:OnRemove()
        self:StopSound(self.soundLoop)
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
    local delay = 0

    local radius = 200
    local height = ent.Height

    if #ent.DropTable == 1 then
        radius = 20
    end

    timer.Create("FlyID" .. ent:GetCreationID(), FrameTime(), 0, function()
        if table.HasValue(ents.FindInSphere(dropPos + Vector(-200, 0, height), radius), ent) then
            if table.IsEmpty(ent.DropTable) then
                timedRemoval(ent, 3)
            else
                if CurTime() < delay then
                    goto after
                end

                local rand = math.random(1, #ent.DropTable)
                local randItem = ent.DropTable[rand]
                table.remove(ent.DropTable, rand)
                local drop = ents.Create(randItem)
                drop:SetPos(ent:GetPos())
                drop:Spawn()
                drop:Activate()
                delay = CurTime() + ent.Delay
            end
        end

        ::after::
        ent:SetVelocity(Vector(-1000, 0, 0))
    end)
end

function timedRemoval(ent, secs)
    timer.Simple(secs, function()
        if IsValid(ent) then
            ent:Remove()
        end
    end)
end