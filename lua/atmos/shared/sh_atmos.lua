
AtmosClass = atmos_class();

function AtmosClass:__constructor()

	self.NextOutsideCheck = 0;
	self.OutsideCheckDelay = 1;

	self.Valid = true;

end

function AtmosClass:__tostring()

	return "[Atmos Object]";

end

function AtmosClass:IsValid()

	return self.Valid;

end

function AtmosClass:Initialize()

	self.Initialized = true;

end

function AtmosClass:SetEnabled( bEnabled )

	self:GetSettings().Enabled = bEnabled;

	self.Settings:Save();

end

function AtmosClass:GetEnabled()

	return self:GetSettings().Enabled;

end

function AtmosClass:GetSettings()

	if ( self.Settings == nil ) then

		self.Settings = SettingsClass();

	end

	return self.Settings:GetSettingsTable();

end

function AtmosClass:ResetSettings()

	self.Settings:Reset();

end

function AtmosClass:CanEditSettings( pl )

	if ( IsValid( pl ) ) then

		-- Prevent SteamID Spoofers from abusing admin access
		if ( !pl:IsFullyAuthenticated() ) then return false end

		-- Atmos moderators
		--if ( table.HasValue( self:GetSettings().Admins, tostring( pl:SteamID() ) ) ) then return true end

		-- GMod moderators
		if ( pl:IsAdmin() || pl:IsSuperAdmin() ) then return true end

		-- ULX moderators
		if ( ( ucl && pl.CheckGroup ) && ( pl:CheckGroup( "owner") || pl:CheckGroup( "moderator" ) || pl:CheckGroup( "atmos" ) ) ) then return true end

		-- Evolve moderators
		if ( evolve && ( pl:EV_IsOwner() || pl:EV_IsSuperAdmin() || pl:EV_IsAdmin() || pl:EV_GetRank() == "moderator" ) ) then return true end

		-- ServerGuard moderators
		if ( serverguard ) then

			local group = serverguard.player:GetRank( pl );
			local name = serverguard.ranks:GetRank( group ).name || "";

			if ( name == "owner" || name == "moderator" || name == "atmos" || name == "superadmin" || name == "admin" ) then

				return true;

			end

		end

		-- Custom moderators
		if ( hook.Call( "AtmosCanEditSettings", GAMEMODE || nil, pl ) ) then return true end

	else

		-- Console
		return true;

	end

	return false;

end

function AtmosClass:Think()

	if ( !self:GetEnabled() ) then return end

	-- NOTE: required wait for ISteamHTTP to be initialized
	if ( !self.Initialized ) then

		self:Initialize();

	end

	if ( IsValid( self.Sky ) ) then

		self.Sky:Think();

	end

	if CLIENT then

		if ( IsValid( LocalPlayer() ) ) then

			if ( self.NextOutsideCheck < CurTime() ) then

				local pos = LocalPlayer():EyePos();

				LocalPlayer().isOutside = atmos_outside( pos );
				LocalPlayer().isSkyboxVisible = util.IsSkyboxVisibleFromPoint( pos );

				self.NextOutsideCheck = CurTime() + self.OutsideCheckDelay;

			end

			-- update particles
			self:ParticleThink();

		end

	end

end

if CLIENT then

	function AtmosClass:ParticleThink()

		if ( self.Emitter2D ) then

			self.Emitter2D:Finish();
			self.Emitter2D = nil;

			atmos_log( "Emitter2D destroyed" );

		end

		if ( self.Emitter3D ) then

			self.Emitter3D:Finish();
			self.Emitter3D = nil;

			atmos_log( "Emitter3D destroyed" );

		end

	end

end

function AtmosClass:SetSky( sky )

	self.Sky = sky;

end

function AtmosClass:GetSky()

	return self.Sky;

end

function AtmosClass:GetMap()

	return string.lower( tostring( game.GetMap() ) );

end
