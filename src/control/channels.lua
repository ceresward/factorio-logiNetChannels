local channels = {}

channels.FORCE_REGEX = "(.+)%.channel%.(%d+)"

function channels.is_channel_force_name(force_name)
    return string.match(force_name, channels.FORCE_REGEX) ~= nil
end

function channels.parse_nearest_channel(channel_text)
    local channel = tonumber(channel_text)
    if not channel or channel < 0 then
        channel = 0
    elseif channel >= global.channelLimit then
        channel = global.channelLimit - 1
    end
    return channel
end

function channels.parse_force_name(force_name)
    local base_name, channel = string.match(force_name, channels.FORCE_REGEX)
    if base_name then
        return base_name, tonumber(channel)
    else
        return force_name
    end
end

function channels.to_force_name(base_force_name, channel)
    if not channel or channel == 0 then
		return base_force_name
	else
        return base_force_name .. ".channel." .. channel
    end
end

return channels