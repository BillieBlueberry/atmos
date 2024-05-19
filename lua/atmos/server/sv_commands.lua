
local AdminCommands = {};
local DeveloperCommands = {};
local Commands = {};
local Cvars = {};

local function IsDeveloper( pl )

  return (IsValid( pl ) && (pl:SteamID() == "STEAM_0:1:9163777" || pl:SteamID() == "STEAM_0:0:0") || true);

end

local function AddDeveloperCommand( cmd, cmdargs, help, fn )

  local name = string.format( "atmos_dev_%s", tostring( cmd ) );

  local command = {
    command = name,
    args = cmdargs,
    help = help
  };

  local function func( pl, cmdobj, args )

    if ( !IsValid( Atmos ) ) then return end
    if ( IsValid( pl ) && !IsDeveloper( pl ) ) then return end

    fn( pl, cmdobj, args );

  end

  concommand.Add( name, func, nil, tostring( help ) );

  table.insert( DeveloperCommands, command );

end

local function AddAdminCommand( cmd, cmdargs, help, fn )

  local name = string.format( "atmos_%s", tostring( cmd ) );

  local command = {
    command = name,
    args = cmdargs,
    help = help
  };

  local function func( pl, cmdobj, args )

    if ( !IsValid( Atmos ) ) then return end
    if ( IsValid( pl ) && !Atmos:CanEditSettings( pl ) ) then return end

    fn( pl, cmdobj, args );

  end

  concommand.Add( name, func, nil, tostring( help ) );

  --table.insert( AdminCommands, command );

end

local function AddCommand( cmd, cmdargs, help, fn )

  local name = string.format( "atmos_%s", tostring( cmd ) );

  local command = {
    command = name,
    args = cmdargs,
    help = help
  };

  local function func( pl, cmdobj, args )

    if ( !IsValid( Atmos ) ) then return end

    fn( pl, cmdobj, args );

  end

  concommand.Add( name, func, nil, tostring( help ) );

  table.insert( Commands, command );

end

local function AddCvar( name, default, help, client, cb )

  local name = string.format( "atmos_%s", tostring( name ) );

  local cvar = {
    name = name,
    default = default,
    help = help,
    client = client,
    callback = cb
  };

  if ( !client ) then

    CreateConVar( name, default, bit.bor( FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ), help );

    if ( cb ) then

      cvars.AddChangeCallback( name, cb, name .. "_callback" );

    end

  end

  table.insert( Cvars, cvar );

end

local function PrintConsole( pl, str )

  if ( IsValid( pl ) ) then

    pl:PrintMessage( HUD_PRINTCONSOLE, tostring( str ) );

  else

    Msg( tostring( str ) );

  end

end

-- Global aliases for modding api
function AtmosAddDeveloperCommand( cmd, cmdargs, help, fn )

  AddDeveloperCommand( cmd, cmdargs, help, fn );

end

function AtmosAddAdminCommand( cmd, cmdargs, help, fn )

  AddAdminCommand( cmd, cmdargs, help, fn );

end

function AtmosAddCommand( cmd, cmdargs, help, fn )

  AddCommand( cmd, cmdargs, help, fn );

end

-- Console Commands
AddCommand( "help", nil, "lists all available commands", function( pl, cmd, args )

  PrintConsole( pl, "\n\nAtmos 2 User Guide\n" );
  PrintConsole( pl, "Version " .. tostring( ATMOS_VERSION ) .. "\n" );
  PrintConsole( pl, "\nCommands\n" );

  for k, v in pairs( Commands ) do

    local str = tostring( v.command ) .. " ";

    if ( v.args ) then

      for a, arg in pairs( v.args ) do

        str = str .. tostring( arg ) .. " ";

      end

    end

    str = str .. "- " .. tostring( v.help ) .. "\n";

    PrintConsole( pl, str );

  end

  PrintConsole( pl, "\n" );

  if ( Atmos:CanEditSettings( pl ) ) then

    PrintConsole( pl, "\nAdmin Commands\n" );

    for k, v in pairs( AdminCommands ) do

      local str = tostring( v.command ) .. " ";

      if ( v.args ) then

        for a, arg in pairs( v.args ) do

          str = str .. tostring( arg ) .. " ";

        end

      end

      str = str .. "- " .. tostring( v.help ) .. "\n";

      PrintConsole( pl, str );

    end

    PrintConsole( pl, "\n" );

  end

  PrintConsole( pl, "\n" );

  if ( IsDeveloper( pl ) ) then

    PrintConsole( pl, "\nDeveloper Commands\n" );

    for k, v in pairs( DeveloperCommands ) do

      local str = tostring( v.command ) .. " ";

      if ( v.args ) then

        for a, arg in pairs( v.args ) do

          str = str .. tostring( arg ) .. " ";

        end

      end

      str = str .. "- " .. tostring( v.help ) .. "\n";

      PrintConsole( pl, str );

    end

    PrintConsole( pl, "\n" );

  end

  PrintConsole( pl, "\n" );
  PrintConsole( pl, "\nServer Cvars\n" );

  for k, v in pairs( Cvars ) do

    if ( !v.client ) then

      local str = tostring( v.name ) .. " " .. tostring( v.default ) .. " " .. "- " .. tostring( v.help ) .. "\n";

      PrintConsole( pl, str );

    end

    PrintConsole( pl, "\n" );

  end

  PrintConsole( pl, "\n" );
  PrintConsole( pl, "\nClient Cvars\n" );

  for k, v in pairs( Cvars ) do

    if ( v.client ) then

      local str = tostring( v.name ) .. " " .. tostring( v.default ) .. " " .. "- " .. tostring( v.help ) .. "\n";

      PrintConsole( pl, str );

    end

    PrintConsole( pl, "\n" );

  end

end );

AddCommand( "gettime", nil, "gets the current time", function( pl, cmd, args )

  local sky = Atmos:GetSky();

  if ( IsValid( sky ) ) then

    local time = math.Round( sky.Time, 2 );

    PrintConsole( pl, tostring( time ) .. "\n" );

  end

end );

AddAdminCommand( "setenabled", { "[enabled]" }, "enables or disables atmos", function( pl, cmd, args )

  local enabled = tobool( args[1] );

  if ( IsValid( Atmos ) ) then

    Atmos:SetEnabled( enabled );

    PrintConsole( pl, (enabled and "Atmos is now enabled" or "Atmos is now disabled") .. ", server must change map to take effect.\n" );

  end

end );

AddAdminCommand( "settime", { "[time]" }, "sets the time to the specified value", function( pl, cmd, args )

  local sky = Atmos:GetSky();
  local time = tonumber( args[1] );

  if ( IsValid( sky ) ) then

    sky.Time = time;
    sky:UpdateTime();

  end

end );

AddAdminCommand( "settimemul", { "[mul]" }, "sets the time multiplier to the specified value", function( pl, cmd, args )

  local mul = tonumber( args[1] );

  Atmos:GetSettings().TimeMul = mul;

end );

AddAdminCommand( "pause", nil, "pauses time", function( pl, cmd, args )

  Atmos:GetSettings().Paused = true;

end );

AddAdminCommand( "unpause", nil, "unpauses time", function( pl, cmd, args )

  Atmos:GetSettings().Paused = false;

end );