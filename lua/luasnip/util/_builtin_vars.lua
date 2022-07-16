local util = require("luasnip.util.util")
local lazy_vars = {}


-- Variables defined in https://code.visualstudio.com/docs/editor/userdefinedsnippets#_variables

-- Inherited from TextMate
function lazy_vars.TM_FILENAME()
    return vim.fn.expand("%:t")
end

function lazy_vars.TM_FILENAME_BASE()
    return vim.fn.expand("%:t:s?\\.[^\\.]\\+$??")
end

function lazy_vars.TM_DIRECTORY()
    return vim.fn.expand("%:p:h")
end

function lazy_vars.TM_FILEPATH()
    return vim.fn.expand("%:p")
end

-- Vscode only

function lazy_vars.CLIPBOARD() -- The contents of your clipboard
    return vim.fn.getreg('"', 1, true)
end

local function buf_to_ws_part()
    local LSP_WORSKPACE_PARTS = "LSP_WORSKPACE_PARTS"
    local ok, ws_parts = pcall(vim.api.nvim_buf_get_var, 0, LSP_WORSKPACE_PARTS)
    if not ok then
        local file_path = vim.fn.expand("%:p")

        for _, ws in pairs(vim.lsp.buf.list_workspace_folders()) do
            if file_path:find(ws, 1, true) == 1 then
                ws_parts = { ws, file_path:sub(#ws + 2, -1) }
                break
            end
        end
        -- If it can't be extracted from lsp, then we use the file path
        if not ok and not ws_parts then
            ws_parts = { vim.fn.expand("%:p:h"), vim.fn.expand("%:p:t") }
        end
        vim.api.nvim_buf_set_var(0, LSP_WORSKPACE_PARTS, ws_parts)
    end
    return ws_parts
end

function lazy_vars.RELATIVE_FILEPATH() -- The relative (to the opened workspace or folder) file path of the current document
    return buf_to_ws_part()[2]
end

function lazy_vars.WORKSPACE_FOLDER() -- The path of the opened workspace or folder
    return buf_to_ws_part()[1]
end

function lazy_vars.WORKSPACE_NAME() -- The name of the opened workspace or folder
    local parts = vim.split(buf_to_ws_part()[1] or "", "[\\/]")
    return parts[#parts]
end

-- DateTime Related
function lazy_vars.CURRENT_YEAR()
    return os.date("%Y")
end

function lazy_vars.CURRENT_YEAR_SHORT()
    return os.date("%y")
end

function lazy_vars.CURRENT_MONTH()
    return os.date("%m")
end

function lazy_vars.CURRENT_MONTH_NAME()
    return os.date("%B")
end

function lazy_vars.CURRENT_MONTH_NAME_SHORT()
    return os.date("%b")
end

function lazy_vars.CURRENT_DATE()
    return os.date("%d")
end

function lazy_vars.CURRENT_DAY_NAME()
    return os.date("%A")
end

function lazy_vars.CURRENT_DAY_NAME_SHORT()
    return os.date("%a")
end

function lazy_vars.CURRENT_HOUR()
    return os.date("%H")
end

function lazy_vars.CURRENT_MINUTE()
    return os.date("%M")
end

function lazy_vars.CURRENT_SECOND()
    return os.date("%S")
end

function lazy_vars.CURRENT_SECONDS_UNIX()
    return tostring(os.time())
end

-- For inserting random values

math.randomseed(os.time())

function lazy_vars.RANDOM()
    return string.format("%06d", math.random(999999))
end

function lazy_vars.RANDOM_HEX()
    return string.format("%06x", math.random(16777216)) --16^6
end

function lazy_vars.UUID()
    local random = math.random
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    local out
    local function subs(c)
        local v = (((c == "x") and random(0, 15)) or random(8, 11))
        return string.format("%x", v)
    end

    out = template:gsub("[xy]", subs)
    return out
end

function lazy_vars.LINE_COMMENT()
    return util.buffer_comment_chars()[1]
end

function lazy_vars.BLOCK_COMMENT_START()
    return util.buffer_comment_chars()[2]
end

function lazy_vars.BLOCK_COMMENT_END()
    return util.buffer_comment_chars()[3]
end

-- These are the vars that have to be populated once the snippet starts to avoid any issue
local function eager_vars(pos)
    local vars = {}
    vars.TM_CURRENT_LINE = vim.api.nvim_buf_get_lines(0, pos[1], pos[1] + 1, false)[1]
    vars.TM_CURRENT_WORD = util.word_under_cursor(pos, vars.TM_CURRENT_LINE)
    vars.TM_LINE_INDEX = tostring(pos[1])
    vars.TM_LINE_NUMBER = tostring(pos[1] + 1)
    vars.SELECT_RAW, vars.SELECT_DEDENT, vars.TM_SELECTED_TEXT = util.get_selection()
    return vars
end

local builtin_ns = { SELECT = true }

for name, _ in pairs(lazy_vars) do
    local parts = vim.split(name, "_")
    if #parts > 1 then
        builtin_ns[ parts[1] ] = true
    end
end

local _is_table = {
        TM_SELECTED_TEXT = true,
        SELECT_RAW = true,
        SELECT_DEDENT = true,
    }

return {
    is_table = function(key) return _is_table[key] or false end,
    lazy = lazy_vars,
    eager = eager_vars,
    builtin_ns = builtin_ns,
}
