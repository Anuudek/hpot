local CHANNEL_HELP = 7

local muted = Condition(CONDITION_CHANNELMUTEDTICKS, CONDITIONID_DEFAULT)
muted:setParameter(CONDITION_PARAM_SUBID, CHANNEL_HELP)
muted:setParameter(CONDITION_PARAM_TICKS, 3600000)

local mutedCooldown = Condition(CONDITION_CHANNELMUTEDTICKS, CONDITIONID_DEFAULT)
mutedCooldown:setParameter(CONDITION_PARAM_SUBID, CHANNEL_HELP)
mutedCooldown:setParameter(CONDITION_PARAM_TICKS, 120000)

function onSpeak(player, type, message)
	local playerGroupType = player:getGroup():getId()
	if player:getLevel() < 50 and playerGroupType == GROUP_TYPE_NORMAL then
		player:sendCancelMessage("Only players level 50+ are allowed to send messages on this channel.")
		return false
	end

	if player:getCondition(CONDITION_CHANNELMUTEDTICKS, CONDITIONID_DEFAULT, CHANNEL_HELP) then
		player:sendCancelMessage("You may only send another message in 120 seconds.")
		return false
	end

	if playerGroupType == GROUP_TYPE_NORMAL then
		player:addCondition(mutedCooldown)
	end

	local hasExhaustion = player:kv():get("channel-help-exhaustion") or 0
	if hasExhaustion > os.time() then
		player:sendCancelMessage("You are muted from the Help channel for using it inappropriately.")
		return false
	end

	if playerGroupType >= GROUP_TYPE_TUTOR then
		if string.sub(message, 1, 6) == "!mute " then
			local targetName = string.sub(message, 7)
			local target = Player(targetName)
			if target then
				if playerGroupType > target:getAccountType() then
					if not target:getCondition(CONDITION_CHANNELMUTEDTICKS, CONDITIONID_DEFAULT, CHANNEL_HELP) then
						target:addCondition(muted)
						target:kv():set("channel-help-exhaustion", os.time() + 180) -- 3 minutes
						sendChannelMessage(CHANNEL_HELP, TALKTYPE_CHANNEL_R1, target:getName() .. " has been muted by " .. player:getName() .. " for using Help Channel inappropriately.")
					else
						player:sendCancelMessage("That player is already muted.")
					end
				else
					player:sendCancelMessage("You are not authorized to mute that player.")
				end
			else
				player:sendCancelMessage(RETURNVALUE_PLAYERWITHTHISNAMEISNOTONLINE)
			end
			return false
		elseif string.sub(message, 1, 8) == "!unmute " then
			local targetName = string.sub(message, 9)
			local target = Player(targetName)
			if target then
				if playerGroupType > target:getAccountType() then
					local hasExhaustionTarget = target:kv():get("channel-help-exhaustion") or 0
					if hasExhaustionTarget > os.time() then
						target:removeCondition(CONDITION_CHANNELMUTEDTICKS, CONDITIONID_DEFAULT, CHANNEL_HELP)
						sendChannelMessage(CHANNEL_HELP, TALKTYPE_CHANNEL_R1, target:getName() .. " has been unmuted.")
						target:kv():remove("channel-help-exhaustion")
					else
						player:sendCancelMessage("That player is not muted.")
					end
				else
					player:sendCancelMessage("You are not authorized to unmute that player.")
				end
			else
				player:sendCancelMessage(RETURNVALUE_PLAYERWITHTHISNAMEISNOTONLINE)
			end
			return false
		end
	end

	if type == TALKTYPE_CHANNEL_Y then
		if playerGroupType >= GROUP_TYPE_TUTOR or player:hasFlag(PlayerFlag_TalkOrangeHelpChannel) then
			type = TALKTYPE_CHANNEL_O
		end
	elseif type == TALKTYPE_CHANNEL_O then
		if playerGroupType < GROUP_TYPE_TUTOR and not player:hasFlag(PlayerFlag_TalkOrangeHelpChannel) then
			type = TALKTYPE_CHANNEL_Y
		end
	elseif type == TALKTYPE_CHANNEL_R1 then
		if playerGroupType < GROUP_TYPE_GAMEMASTER and not player:hasFlag(PlayerFlag_CanTalkRedChannel) then
			if playerGroupType >= GROUP_TYPE_TUTOR or player:hasFlag(PlayerFlag_TalkOrangeHelpChannel) then
				type = TALKTYPE_CHANNEL_O
			else
				type = TALKTYPE_CHANNEL_Y
			end
		end
	end
	return type
end
