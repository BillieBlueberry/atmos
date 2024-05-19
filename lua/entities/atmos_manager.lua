
AddCSLuaFile();

ENT.Type = "point";
ENT.DisableDuplicator	= true;

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end

function ENT:SetupDataTables()

	self:NetworkVar( "Float",	0, "Time" );
	self:NetworkVar( "Float",	1, "TimeMul" );
	self:NetworkVar( "Float",	2, "TransitionMul" );
	self:NetworkVar( "Vector", 0, "SunNormal" );

	if SERVER then

		self:SetTime( 0 );
		self:SetTimeMul( Atmos:GetSettings().TimeMul );
		self:SetTransitionMul( Atmos:GetSettings().TransitionMul );

	end

end

function ENT:Initialize()

	self:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)

end

function ENT:KeyValue( key, value )

	if ( self:SetNetworkKeyValue( key, value ) ) then

		return;

	end

end

function ENT:Think()

	if ( g_AtmosManager != self ) then

			g_AtmosManager = self;

	end

end

function ENT:CanEditVariables( ply )

	return false;

end
