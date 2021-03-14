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
		
        addEditorComponents(editor)
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

function guis.changer_gui(player)
    local parent = mod_gui.get_frame_flow(player)
	if not parent.logiNetChannelChanger then
		local changer = mod_gui.get_frame_flow(player).add{
			type="frame",
			name="logiNetChannelChanger",
            caption={"logiNetChannel.changer_frame_caption"},
			direction="vertical"
		}
		changer.visible = false
		
        addEditorComponents(changer)
    end
	return parent.logiNetChannelChanger
end

function guis.changer_gui_old(player)
    local guiRoot = player.gui.screen
    local gui = guiRoot["logiNetChannelChanger"]
    if not gui then
        gui = guiRoot.add {
            type="frame",
            name="logiNetChannelChanger",
            caption="Temp caption",
            direction="vertical"
        }
        gui.visible = false
    
        gui.add{ type="label", name="label", caption="Temp label" }
        gui.add{ type="button", name="close", caption="X", style="cancel_close_button" }
    end

    gui.force_auto_center()
    return gui
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
        editor.sliderRow.textfield.caption = channel
        editor.sliderRow.slider.slider_value = channel

        editor.labelRow.textfield.text = channel_label or ''
        editor.labelRow.default_label.visible = (channel == 0)
        editor.labelRow.textfield.visible = (channel ~= 0)
    else
        editor.sliderRow.textfield.caption = ''
        editor.sliderRow.slider.slider_value = 0

        editor.labelRow.textfield.text = ''
        editor.labelRow.default_label.visible = false
        editor.labelRow.textfield.visible = false
    end
end

function guis.update_editor(player, channel, channel_label)
    local editor = guis.editor_gui(player)
    update_editor(editor, channel, channel_label)
end

function guis.update_hover(player, channel, channel_label)
    local hover = guis.hover_gui(player)
    if channel_label and #channel_label > 0 then
        hover.caption = {"logiNetChannel.hover_caption_with_label", channel, channel_label}
    else
        hover.caption = {"logiNetChannel.hover_caption_with_no_label", channel}
    end
end

function guis.update_changer(player, channel, channel_label)
    local changer = guis.changer_gui(player)
    update_editor(changer, channel, channel_label)
end

-----------------------------------------------------------
--  Private functions
-----------------------------------------------------------
function addEditorComponents(editor)
    local sliderRow = editor.add{ type="flow", name="sliderRow", caption="Slider Row", direction="horizontal" }
    sliderRow.style.horizontal_spacing = 12;
    
    sliderRow.add{
        type="textfield", name="textfield", caption="0",
        numeric=true,
        style="logiNetChannels_textfield_edit_channel"
    }
    
    local channelLimit = settings.global["logiNetChannelLimit"].value
    sliderRow.add{
        type="slider", name="slider",
        minimum_value=0, maximum_value=(channelLimit-1), value_step=1,
        discrete_slider=true, discrete_values=true,
        style="logiNetChannels_slider_edit_channel"
    }
    
    local labelRow = editor.add{ type="flow", name="labelRow", caption="Label Row", direction="horizontal" }
    labelRow.style.horizontal_spacing = 12;
    
    labelRow.add{ type="label", name="label", caption={"logiNetChannel.editor_label_caption"} }
    labelRow.add{ type="label", name="default_label", caption={"logiNetChannel.default_label"}}
    labelRow.add{ type="textfield", name="textfield", lose_focus_on_confirm=true }
end

function update_editor(editor, channel, channel_label)
    if channel and channel >= 0 then
        editor.sliderRow.textfield.caption = channel
        editor.sliderRow.slider.slider_value = channel

        editor.labelRow.textfield.text = channel_label or ''
        editor.labelRow.default_label.visible = (channel == 0)
        editor.labelRow.textfield.visible = (channel ~= 0)
    else
        editor.sliderRow.textfield.caption = ''
        editor.sliderRow.slider.slider_value = 0

        editor.labelRow.textfield.text = ''
        editor.labelRow.default_label.visible = false
        editor.labelRow.textfield.visible = false
    end
end

return guis