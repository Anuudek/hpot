local shared = TalkAction("!shared", "!share")

function shared.onSay(player, words, param)
	if player then
		player:sendTextMessage(MESSAGE_LOOK, "A character with level " .. math.ceil((player:getLevel())) .. " can share experience with characters from level " .. math.ceil((player:getLevel() * 2) / 3) .. " up to level " .. math.ceil((player:getLevel() * player:getLevel()) / ((player:getLevel() * 2) / 3)) .. ".")
	end
	return true
end

shared:groupType("normal")
shared:register()
