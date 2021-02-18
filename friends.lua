
util.AddNetworkString( "ULX_AskFriendsList" )

function ulx.friends( caller, target )
	net.Start( "ULX_AskFriendsList" )
		net.WriteString( caller:SteamID() )
	net.Send( target )
	
	caller.ULX_CalledGetFriends = true
end
local friends = ulx.command( "Utility", "ulx friends", ulx.friends, { "!friends", "!listfriends" }, true )
friends:addParam{ type=ULib.cmds.PlayerArg }
friends:defaultAccess( ULib.ACCESS_ADMIN )
friends:help( "Print a player's connected steam friends." )

net.Receive( "ULX_AskFriendsList", function( len, target )
	if CLIENT then
		local callerSteamID = net.ReadString()
		local caller
		
		local Table = {}

		for _, v in ipairs( player.GetAll() ) do
			if v:GetFriendStatus() == "friend" then
				table.insert( Table, v:Nick() )
			end
			
			if v:SteamID() == callerSteamID then
				caller = v
			end
		end
		
		if IsValid( caller ) then
			net.Start( "ULX_AskFriendsList" )
				net.WriteEntity( caller )
				net.WriteTable( Table )
			net.SendToServer()
		end
	else
		local caller = net.ReadEntity()
		local Table = net.ReadTable()
		local ToString = table.ToString( Table )
		
		if !IsValid( caller ) or !Table or !caller.ULX_CalledGetFriends or !ToString or ( #ToString > 200 ) then return end
		
		if ToString != 0 then
			for _, v in ipairs( Table ) do
				caller:ChatPrint( v )
			end
		else
			caller:ChatPrint( "This user has no friends online!" )
		end
		
		caller.ULX_CalledGetFriends = false
	end
end )
