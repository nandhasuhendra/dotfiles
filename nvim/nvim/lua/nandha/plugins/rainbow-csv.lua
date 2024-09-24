local setup, csv = pcall(require, "cameron-wags/rainbow_csv.nvim")
if not setup then
	return
end

csv.setup()
