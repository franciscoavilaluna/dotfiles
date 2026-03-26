local M = {}

local secure_vault_dir = vim.fn.stdpath("data") .. "/sql_vault/"
local state_path = secure_vault_dir .. ".db_state"
local conn_path = secure_vault_dir .. "connections.json"
local db_state = { current_key = "" }

local function protect_file(path)
	if vim.fn.has("unix") == 1 then
		vim.fn.system("chmod 600 " .. vim.fn.shellescape(path))
	end
end

local function load_connections()
	if vim.fn.isdirectory(secure_vault_dir) == 0 then
		vim.fn.mkdir(secure_vault_dir, "p")
	end

	local f = io.open(conn_path, "r")
	if not f then
		local wf = io.open(conn_path, "w")
		if wf then
			wf:write("{}")
			wf:close()
			protect_file(conn_path)
		end
		return {}
	end
	local content = f:read("*a")
	f:close()
	if content == "" or content:match("^%s*$") then
		return {}
	end
	return vim.fn.json_decode(content) or {}
end

local function save_connections(conns)
	local f = io.open(conn_path, "w")
	if f then
		f:write(vim.fn.json_encode(conns))
		f:close()
		protect_file(conn_path)
	end
end

local function create_window(title, width_p, height_lines, is_input, example_text)
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * width_p)
	local height = math.max(1, height_lines)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
		title = " " .. title .. " ",
		title_pos = "center",
	}
	local win = vim.api.nvim_open_win(buf, true, opts)

	if is_input then
		if example_text then
			vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "  " .. example_text, " " })
			vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 0, 0, -1)
			vim.api.nvim_win_set_cursor(win, { 2, 1 })
		else
			vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "" })
		end
		vim.cmd("startinsert!")
	end
	return buf, win
end

local function floating_input(title, example, callback)
	local height = example and 2 or 1
	local buf, win = create_window(title, 0.6, height, true, example)

	local function close()
		vim.cmd("stopinsert")
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	vim.keymap.set({ "i", "n" }, "<CR>", function()
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		local input = lines[#lines]:gsub("^%s+", ""):gsub("%s+$", "")
		close()
		if input ~= "" then
			callback(input)
		end
	end, { buffer = buf })

	vim.keymap.set({ "i", "n" }, "<Esc>", close, { buffer = buf })
	vim.keymap.set("n", "q", close, { buffer = buf })
end

-- MENÚ DE SELECCIÓN
local function open_menu(title, items, callback)
	local buf, win = create_window(title, 0.4, #items, false)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, items)
	vim.wo[win].cursorline = true
	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end
	vim.keymap.set("n", "<CR>", function()
		local idx = vim.api.nvim_win_get_cursor(win)[1]
		close()
		callback(items[idx], idx)
	end, { buffer = buf })
	vim.keymap.set("n", "q", close, { buffer = buf })
	vim.keymap.set("n", "<Esc>", close, { buffer = buf })
end

-- AÑADIR CONEXIÓN
function M.add_connection()
	floating_input("NAME", "Ej: My_Database", function(name)
		open_menu("SELECT ENGINE", { "mariadb", "postgres", "sqlite" }, function(engine)
			if engine == "sqlite" then
				floating_input("DATABASE PATH", "/path/to/file.sqlite", function(path)
					local c = load_connections()
					c[name] = { type = "sqlite", path = path }
					save_connections(c)
				end)
			else
				floating_input("HOST", "localhost", function(h)
					floating_input("USER", "root", function(u)
						floating_input("PASSWORD", "password", function(p)
							floating_input("DATABASE NAME", "dbname", function(db)
								local c = load_connections()
								c[name] = { type = engine, host = h, user = u, pass = p, db = db }
								save_connections(c)
								vim.notify("󰆼 Saved: " .. name)
							end)
						end)
					end)
				end)
			end
		end)
	end)
end

-- SELECCIÓN, BORRADO Y MENÚ
function M.select_connection()
	local conns = load_connections()
	local keys = vim.tbl_keys(conns)
	if #keys == 0 then
		return vim.notify("No available connections", "warn")
	end
	open_menu("SELECT DATABASE", keys, function(choice)
		db_state.current_key = choice
		local f = io.open(state_path, "w")
		if f then
			f:write(choice)
			f:close()
		end
		vim.notify("󰆼 Active: " .. choice)
	end)
end

function M.delete_connection()
	local conns = load_connections()
	local keys = vim.tbl_keys(conns)
	if #keys == 0 then
		return
	end
	open_menu("DELETE CONNECTION", keys, function(choice)
		conns[choice] = nil
		save_connections(conns)
		if db_state.current_key == choice then
			db_state.current_key = ""
		end
		vim.notify("󰆼 Deleted: " .. choice)
	end)
end

function M.main_menu()
	local items = { "Select Connection", "Add New", "Delete Connection", "Exec Query" }
	open_menu("SQL MANAGER", items, function(choice)
		if choice:find("Select") then
			M.select_connection()
		elseif choice:find("Add") then
			M.add_connection()
		elseif choice:find("Delete") then
			M.delete_connection()
		elseif choice:find("Exec") then
			M.run_sql("n")
		end
	end)
end

function M.run_sql(mode)
	local conns = load_connections()
	local conn = conns[db_state.current_key]
	if not conn then
		return vim.notify("Select DB first", "warn")
	end

	local current_win = vim.api.nvim_get_current_win()
	local start_line, end_line

	if mode == "v" or mode == "V" or mode == "\22" then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "x", true)
		start_line = vim.api.nvim_buf_get_mark(0, "<")[1]
		end_line = vim.api.nvim_buf_get_mark(0, ">")[1]
	else
		start_line = vim.api.nvim_win_get_cursor(0)[1]
		end_line = start_line
	end

	if start_line == 0 or end_line == 0 then
		return
	end
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	local sql = table.concat(lines, "\n")
	if sql:gsub("%s+", "") == "" then
		return
	end

	local db_match = sql:lower():match("use%s+([%w_]+)")
	if db_match then
		local new_db = db_match:gsub(";", "")

		conn.db = new_db

		conns[db_state.current_key] = conn
		save_connections(conns)

		vim.notify("󰆼 Switched to Database: " .. new_db, vim.log.levels.INFO)
	end
	---------------------------------------------------------

	local cmd = ""
	local esc = vim.fn.shellescape(sql)

	if conn.type == "mariadb" or conn.type == "postgres" then
		local tool = (conn.type == "mariadb") and "mariadb" or "psql"
		cmd =
			string.format("echo %s | %s -h%s -u%s -p%s %s -t 2>&1", esc, tool, conn.host, conn.user, conn.pass, conn.db)
	elseif conn.type == "sqlite" then
		cmd = string.format("echo %s | sqlite3 %s -header -column 2>&1", esc, conn.path)
	end

	local handle = io.popen(cmd)
	local output = handle:read("*a")
	handle:close()

	local bufname = "__SQL_Result__"
	local buf = vim.fn.bufnr(bufname)
	if buf == -1 then
		buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(buf, bufname)
	end

	local win_id = vim.fn.bufwinid(buf)
	if win_id == -1 then
		vim.cmd("botright 12 split")
		win_id = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(win_id, buf)
	end

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output:gsub("%s+$", ""), "\n"))
	vim.bo[buf].modifiable, vim.bo[buf].ft, vim.bo[buf].buftype = false, "sql", "nofile"

	if vim.api.nvim_win_is_valid(current_win) then
		vim.api.nvim_set_current_win(current_win)
	end
end

local sf = io.open(state_path, "r")
if sf then
	db_state.current_key = sf:read("*a"):gsub("%s+", "")
	sf:close()
end

function M.statusline()
	if vim.bo.filetype ~= "sql" then
		return ""
	end
	return string.format(
		" %%#StatusLineMedium# 󰆼 %s ",
		db_state.current_key ~= "" and db_state.current_key or "No DB"
	)
end

return M
