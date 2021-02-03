local mod_gui = require("mod-gui")

local guis = {}

function guis.editor_gui(player)
	local parent = mod_gui.get_frame_flow(player)
	if not parent.logiNetChannelEditor then
		local editor = mod_gui.get_frame_flow(player).add{
			type="frame",
			name="logiNetChannelEditor",
            caption={"logiNetChannel.editor_frame_caption"},
			direction="vertical"
		}
		editor.visible = false
		
		local sliderRow = editor.add{ type="flow", name="sliderRow", caption="Slider Row", direction="horizontal" }
		sliderRow.style.horizontal_spacing = 12;
		
        sliderRow.add{ type="label", name="label", caption="0" }
        sliderRow.label.style.font = "default-large-semibold"

        sliderRow.add{
            type="textfield", name="textfield", caption="0",
            numeric=true, lose_focus_on_confirm=true,
            style="logiNetChannels_textfield_edit_channel"
        }
        
        local channelLimit = settings.global["logiNetChannelLimit"].value
		sliderRow.add{
			type="slider", name="slider",
			minimum_value=0, maximum_value=(channelLimit-1), value_step=1,
			discrete_slider=true, discrete_values=true
		}
        
        local labelRow = editor.add{ type="flow", name="labelRow", caption="Label Row", direction="horizontal" }
        labelRow.style.horizontal_spacing = 12;
        
        labelRow.add{ type="label", name="label", caption={"logiNetChannel.editor_label_caption"} }
        labelRow.add{ type="label", name="default_label", caption={"logiNetChannel.default_label"}}
        labelRow.add{ type="textfield", name="textfield", lose_focus_on_confirm=true }
    end
	return parent.logiNetChannelEditor
end

function guis.hover_gui(player)
	local parent = mod_gui.get_frame_flow(player)
    if not parent.logiNetChannelHover then
		local hoverLabel = parent.add{
			type="label",
			name="logiNetChannelHover",
			caption={"logiNetChannel.hover_caption_with_label",""},
        }
	end
	return parent.logiNetChannelHover
end

function guis.reset_guis(player)
    local parent = mod_gui.get_frame_flow(player)
    if parent.logiNetChannelEditor then
        parent.logiNetChannelEditor.destroy()
    end
    if parent.logiNetChannelHover then
        parent.logiNetChannelHover.destroy()
    end
    if parent.logiNetChannelDefaultLabel then
        parent.logiNetChannelDefaultLabel.destroy()
    end
end

function guis.update_editor(player, channel, channel_label)
    local editor = guis.editor_gui(player)
    if channel and channel >= 0 then
        editor.sliderRow.label.caption = channel
        editor.labelRow.textfield.text = channel_label
        editor.labelRow.default_label.visible = (channel == 0)
        editor.labelRow.textfield.visible = (channel ~= 0)
    else
        editor.sliderRow.label.caption = '?'
        editor.labelRow.textfield.text = ''
        editor.labelRow.default_label.visible = false
        editor.labelRow.textfield.visible = false
    end
end

function guis.update_hover(player, channel, channel_label)
    local hover = guis.hover_gui(player)
    if channel and channel >= 0 then
        if channel_label and #channel_label > 0 then
            hover.caption = {"logiNetChannel.hover_caption_with_label", channel, channel_label}
        else
            hover.caption = {"logiNetChannel.hover_caption_with_no_label", channel}
        end
    end
end

return guis