local _2afile_2a = "fnl/snap/preview/file.fnl"
local snap = require("snap")
local snap_io = snap.get("io")
local function _1_(request)
  local path
  local function _2_(...)
    return vim.fn.fnamemodify(tostring(request.selection), ":p", ...)
  end
  path = snap.sync(_2_)
  local handle = io.popen(string.format("file -n -b --mime-encoding %s", path))
  local encoding = string.gsub(handle:read("*a"), "^%s*(.-)%s*$", "%1")
  handle:close()
  snap.continue()
  local preview
  if (encoding == "binary") then
    preview = {"Binary file"}
  else
    local databuffer = ""
    local reader = coroutine.create(snap_io.read)
    while (coroutine.status(reader) ~= "dead") do
      local _, cancel, data = coroutine.resume(reader, path)
      if (data ~= nil) then
        databuffer = (databuffer .. data)
      end
      snap.continue(cancel)
    end
    preview = vim.split(databuffer, "\n", true)
  end
  local function _4_()
    if not request.canceled() then
      vim.api.nvim_win_set_option(request.winnr, "cursorline", false)
      vim.api.nvim_win_set_option(request.winnr, "cursorcolumn", false)
      vim.api.nvim_buf_set_lines(request.bufnr, 0, -1, false, preview)
      local fake_path = (vim.fn.tempname() .. "%" .. vim.fn.fnamemodify(tostring(request.selection), ":p:gs?/?%?"))
      vim.api.nvim_buf_set_name(request.bufnr, fake_path)
      local function _5_(...)
        return vim.api.nvim_command("filetype detect", ...)
      end
      return vim.api.nvim_buf_call(request.bufnr, _5_)
    end
  end
  return snap.sync(_4_)
end
return _1_