
-- Construct Atmos Class
Atmos = Atmos or AtmosClass();
GetRPTime = true

atmos_log( "Atmos created " .. tostring( Atmos ) );

function GetRPTime()

	--local timeMul = ( Atmos:GetSettings().TimeMul || 0.002 )
	local currentTime = Atmos:GetSky().Time
	return currentTime*150+800, 3500

end

-- Hooks
hook.Add( "Initialize", "AtmosInit", function()

	if ( CLIENT or !Atmos:GetEnabled() ) then return end

	RunConsoleCommand( "sv_skyname", "painted" );

end );

hook.Add( "PlayerInitialSpawn", "AtmosPlayerInit", function( pl )

	if ( CLIENT or !Atmos:GetEnabled() ) then return end

	-- Sync current state of atmos to the player, wait 1 second for client to initialize
	if ( IsValid( pl ) ) then

	  Atmos.Settings:SendSettings( pl );

	end

end );

hook.Add( "InitPostEntity", "AtmosInitPost", function()

	if ( !Atmos:GetEnabled() ) then return end

	if SERVER then

		-- Spawn Manager Entity, Syncs Time
		local manager = ents.Create( "atmos_manager" );
		manager:Spawn();
		manager:Activate();

		-- HACK: fixes the darkened sky effect on evocity
		local map = string.lower( game.GetMap() );

		if ( string.find( map, "evocity" ) != nil ) then

			for _, brush in pairs( ents.FindByName( "daynight_brush" ) ) do

				atmos_log( "removing daynight_brush " .. tostring( brush ) );

				brush:Remove();

			end

		end

	end

	-- Construct Sky class
	local sky = SkyClass();

	Atmos:SetSky( sky );

end );

hook.Add( "Think", "AtmosThink", function()

	if ( IsValid( Atmos ) ) then

		Atmos:Think();

	end

end );
