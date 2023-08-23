local buddy_status, colorbuddy = pcall(require, "colorbuddy")
if not buddy_status then
	return
end

colorbuddy.colorscheme("kanagawa")
-- colorbuddy.colorscheme("tokyonight-storm")
