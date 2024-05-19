
-- Network Events
net.Receive( "atmos_lightmaps", function( len )

	render.RedownloadAllLightmaps();

end );

hook.Add( "InitPostEntity", "AtmosFirstJoinLightmaps", function()

	render.RedownloadAllLightmaps();

end );

hook.Add( "RenderScene", "AtmosRenderScene", function( origin, angles, fov )

	if ( IsValid( Atmos ) and IsValid( Atmos:GetSky() ) ) then

		local sky = Atmos:GetSky();

		sky:RenderScene( origin, angles, fov );

	end

end );

hook.Add( "CalcView", "AtmosCalcView", function( pl, pos, ang, fov, nearZ, farZ )

	if ( IsValid( Atmos ) and IsValid( Atmos:GetSky() ) ) then

		local sky = Atmos:GetSky();

		sky:CalcView( pl, pos, ang, fov, nearZ, farZ );

	end

end );

hook.Add( "PostDrawSkyBox", "AtmosPostDrawSkyBox", function()

	if ( IsValid( Atmos ) and IsValid( Atmos:GetSky() ) ) then

		local sky = Atmos:GetSky();

		sky:RenderMoon();

	end

end );
