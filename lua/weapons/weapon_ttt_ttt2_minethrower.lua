if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/weapon_minethrower.vmt")
end

SWEP.PrintName = "Minethrower"
SWEP.Author = "mexikoedi"
SWEP.Contact = "Steam"
SWEP.Instructions = "Left click fires a combine mine."
SWEP.Purpose = "Shoot mines to create traps for your enemies."
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.AdminSpawnable = false

if CLIENT then
    SWEP.Slot = 6
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 60
    SWEP.DrawCrosshair = false

    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "Minethrower",
        desc = "Shoot out combine mines with left click!"
    }

    SWEP.Icon = "vgui/ttt/weapon_minethrower"
    SWEP.IconLetter = "I"
end

SWEP.Base = "weapon_tttbase"
SWEP.HoldType = "physgun"
SWEP.Kind = WEAPON_EQUIP

SWEP.CanBuy = {ROLE_DETECTIVE, ROLE_TRAITOR}

SWEP.UseHands = false
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_IRifle.mdl"
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 5.0
SWEP.LimitedStock = true
SWEP.NoSights = true
SWEP.AllowDrop = true
SWEP.AutoSpawnable = false

function SWEP:PrimaryAttack()
    if self:Clip1() > 0 then
        self:SetNextPrimaryFire(CurTime() + 0.5)
        if CLIENT then return end
        local ent = ents.Create("combine_mine")
        if not IsValid(ent) then return end
        ent.origin = "weapon_ttt_ttt2_minethrower"
        ent:SetPos(self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * 30)
        ent:SetAngles(self:GetOwner():EyeAngles())
        ent:SetOwner(self:GetOwner())
        ent:SetPhysicsAttacker(self:GetOwner())
        ent:Spawn()
        local phys = ent:GetPhysicsObject()

        if not IsValid(phys) then
            ent:Remove()

            return
        end

        local velocity = self:GetOwner():GetAimVector()
        velocity = velocity * 7000
        phys:ApplyForceCenter(velocity)
        self:TakePrimaryAmmo(1)
        self:SetNextPrimaryFire(CurTime() + 0.5)
    end
end

if SERVER then
    hook.Add("EntityTakeDamage", "TTT2MineThrowerDamage", function(target, dmginfo)
        if target:IsPlayer() and dmginfo:IsExplosionDamage() and dmginfo:GetAttacker():GetClass() == "combine_mine" and dmginfo:GetAttacker().origin == "weapon_ttt_ttt2_minethrower" then
            dmginfo:SetInflictor(ents.Create("weapon_ttt_ttt2_minethrower"))
            dmginfo:SetAttacker(dmginfo:GetAttacker():GetOwner())
        end
    end)
end