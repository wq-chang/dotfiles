local wezterm = require("wezterm")
local config = {}
local act = wezterm.action

local colors = wezterm.color.load_scheme(
	wezterm.home_dir .. "/.local/share/wezterm/tokyonight_night.toml"
)

config.term = "wezterm"
config.font = wezterm.font("JetBrains Mono", { weight = "Bold" })
config.window_padding = {
	bottom = 0,
}
config.window_background_image = wezterm.home_dir
	.. "/dotfiles/config/wezterm/bg.jpeg"
config.window_background_image_hsb = {
	brightness = 0.015,
	hue = 1.0,
	saturation = 1.0,
}
config.colors = colors
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

local function find_active_pane_by_title(mux_win, title)
	local tabs = mux_win:tabs()
	for i, tab in ipairs(tabs) do
		local active_pane = tab:active_pane()
		if active_pane:get_title() == title then
			return i - 1, active_pane
		end
	end
	return nil
end

local function get_active_tab_index(mux_win)
	for _, item in ipairs(mux_win:tabs_with_info()) do
		if item.is_active then
			return item.index
		end
	end
end

local function open_or_switch_to_lazygit(win, pane)
	if pane:get_title() == "lazygit" then
		return
	end
	local mux_win = win:mux_window()
	local active_tab_index = get_active_tab_index(mux_win)
	local lazygit_tab_index, lazygit_pane =
		find_active_pane_by_title(mux_win, "lazygit")
	if lazygit_pane then
		win:perform_action(act.ActivateTab(lazygit_tab_index), pane)
	else
		mux_win:spawn_tab({
			args = { "env", "TERM=xterm-256color", "lazygit" },
			set_environment_variables = {
				PATH = wezterm.home_dir
					.. "/.nix-profile/bin:"
					.. wezterm.home_dir
					.. "/go/bin:/opt/homebrew/bin:"
					.. os.getenv("PATH"),
				XDG_CONFIG_HOME = wezterm.home_dir .. "/.config",
			},
		})
		lazygit_tab_index = active_tab_index + 1
	end

	if lazygit_tab_index > active_tab_index then
		win:perform_action(act.MoveTab(active_tab_index), pane)
	else
		win:perform_action(act.MoveTab(active_tab_index - 1), pane)
	end
end

local function toggle_background_image(win, _)
	local overrides = win:get_config_overrides() or {}
	if not overrides.window_background_image then
		overrides.window_background_image = ""
		overrides.window_background_opacity = 0.95
	else
		overrides.window_background_image = nil
		overrides.window_background_opacity = nil
	end
	win:set_config_overrides(overrides)
end

config.leader = { key = "Space", mods = "SHIFT" }
config.keys = {
	{ key = "d", mods = "CTRL|SHIFT", action = act.ScrollByLine(1) },
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Right"),
	},
	{ key = "u", mods = "CTRL|SHIFT", action = act.ScrollByLine(-1) },
	{
		key = "c",
		mods = "LEADER",
		action = act.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "f",
		mods = "LEADER",
		action = act.QuickSelect,
	},
	{
		key = "g",
		mods = "LEADER",
		action = wezterm.action_callback(function(win, pane)
			open_or_switch_to_lazygit(win, pane)
		end),
	},
	{
		key = "i",
		mods = "LEADER",
		action = wezterm.action_callback(function(win, pane)
			toggle_background_image(win, pane)
		end),
	},
	{
		key = "s",
		mods = "LEADER",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "t",
		mods = "LEADER",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "v",
		mods = "LEADER",
		action = act.SplitHorizontal({
			domain = "CurrentPaneDomain",
		}),
	},
	{
		key = "w",
		mods = "LEADER",
		action = act.CloseCurrentTab({ confirm = true }),
	},
}

return config
