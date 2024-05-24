local CHANNEL_WORLD_CHAT = 3

local muted = Condition(CONDITION_CHANNELMUTEDTICKS, CONDITIONID_DEFAULT)
muted:setParameter(CONDITION_PARAM_SUBID, CHANNEL_WORLD_CHAT)
muted:setParameter(CONDITION_PARAM_TICKS, 60000)

function onSpeak(player, type, message)
	local playerGroupType = player:getGroup():getId()
	if player:getLevel() < 100 and playerGroupType < GROUP_TYPE_GAMEMASTER then
		player:sendCancelMessage("Only players level 100+ are allowed to send messages on this channel.")
		return false
	end

	if player:getCondition(CONDITION_CHANNELMUTEDTICKS, CONDITIONID_DEFAULT, CHANNEL_WORLD_CHAT) then
		player:sendCancelMessage("You may only send another message in 60 seconds.")
		return false
	end

	if playerGroupType == GROUP_TYPE_NORMAL then
		player:addCondition(muted)
	end

	if type == TALKTYPE_CHANNEL_Y then
		if playerGroupType >= GROUP_TYPE_GAMEMASTER then
			type = TALKTYPE_CHANNEL_O
		end
	elseif type == TALKTYPE_CHANNEL_O then
		if playerGroupType < GROUP_TYPE_GAMEMASTER then
			type = TALKTYPE_CHANNEL_Y
		end
	elseif type == TALKTYPE_CHANNEL_R1 then
		if playerGroupType < GROUP_TYPE_GAMEMASTER and not player:hasFlag(PlayerFlag_CanTalkRedChannel) then
			type = TALKTYPE_CHANNEL_Y
		end
	end
	return type
end
