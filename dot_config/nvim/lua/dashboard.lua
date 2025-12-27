local M = {}

local function get_git_info()
  local info = {
    is_repo = false,
    branch = nil,
    status = nil,
    files_changed = 0,
  }

  local branch_result = vim.system({ 'git', 'branch', '--show-current' }, { text = true }):wait()
  if branch_result.code == 0 then
    info.is_repo = true
    info.branch = vim.trim(branch_result.stdout)
  end

  if info.is_repo then
    local status_result = vim.system({ 'git', 'status', '--porcelain' }, { text = true }):wait()
    if status_result.code == 0 then
      local stdout = status_result.stdout
      if stdout == '' then
        info.status = 'clean'
      else
        info.status = 'dirty'
        local count = 0
        for _ in stdout:gmatch('[^\n]+') do
          count = count + 1
        end
        info.files_changed = count
      end
    end
  end

  return info
end

local function get_recent_files()
  local oldfiles = vim.v.oldfiles or {}
  local cwd = vim.uv.cwd()
  local recent = {}
  local max_files = 5

  for _, file in ipairs(oldfiles) do
    if #recent >= max_files then
      break
    end
    if vim.startswith(file, cwd) and vim.fn.filereadable(file) == 1 then
      local rel_path = file:sub(#cwd + 2)
      if not vim.startswith(rel_path, '.git/') then
        table.insert(recent, rel_path)
      end
    end
  end

  return recent
end

local function render_dashboard(buf, win)
  local width = vim.api.nvim_win_get_width(win)
  local height = vim.api.nvim_win_get_height(win)

  local min_width = 40
  local min_height = 15

  if width < min_width or height < min_height then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'Terminal too small', 'Minimum: 40x15' })
    return
  end

  local margin_left = 4
  local margin_top = 2

  local project_name = vim.fn.fnamemodify(vim.uv.cwd(), ':t')
  local git_info = get_git_info()
  local recent_files = get_recent_files()

  local lines = {}
  table.insert(lines, '  ' .. string.rep('─', math.min(width - margin_left * 2 - 2, 60)))
  table.insert(lines, '  ' .. project_name)
  table.insert(lines, '  ' .. string.rep('─', math.min(width - margin_left * 2 - 2, 60)))
  table.insert(lines, '')
  table.insert(lines, '  Location: ' .. vim.uv.cwd())
  table.insert(lines, '')

  if git_info.is_repo then
    table.insert(lines, '  Git Repository')
    table.insert(lines, '  ├─ Branch: ' .. (git_info.branch or 'unknown'))
    if git_info.status == 'clean' then
      table.insert(lines, '  └─ Status: clean')
    else
      table.insert(lines, '  └─ Status: ' .. git_info.files_changed .. ' file(s) changed')
    end
  else
    table.insert(lines, '  Not a git repository')
  end

  table.insert(lines, '')

  if #recent_files > 0 then
    table.insert(lines, '  Recent Files')
    for i, file in ipairs(recent_files) do
      local prefix = i == #recent_files and '  └─ ' or '  ├─ '
      local max_len = width - margin_left * 2 - 6
      local display_file = file
      if #file > max_len then
        display_file = '...' .. file:sub(#file - max_len + 4)
      end
      table.insert(lines, prefix .. display_file)
    end
    table.insert(lines, '')
  end

  table.insert(
    lines,
    '  █████ █████ █████ █████ █████ █████ █████ █████ █████ █████'
  )

  local color_bar_line_idx = margin_top + #lines - 1

  local final_lines = {}
  for _ = 1, margin_top do
    table.insert(final_lines, '')
  end

  for _, line in ipairs(lines) do
    local padded_line = string.rep(' ', margin_left) .. line
    table.insert(final_lines, padded_line)
  end

  while #final_lines < height do
    table.insert(final_lines, '')
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, final_lines)

  local is_dark = vim.o.background == 'dark'
  local colors
  if is_dark then
    colors = {
      '#5ea1ff', -- blue
      '#5eff6c', -- green
      '#5ef1ff', -- cyan
      '#ff6e5e', -- red
      '#f1ff5e', -- yellow
      '#ff5ef1', -- magenta
      '#ff5ea0', -- pink
      '#ffbd5e', -- orange
      '#bd5eff', -- purple
      '#7b8496', -- grey
    }
  else
    colors = {
      '#0057d1', -- blue
      '#008b0c', -- green
      '#008c99', -- cyan
      '#d11500', -- red
      '#997b00', -- yellow
      '#d100bf', -- magenta
      '#f40064', -- pink
      '#d17c00', -- orange
      '#a018ff', -- purple
      '#7b8496', -- grey
    }
  end

  for i, color in ipairs(colors) do
    vim.api.nvim_set_hl(0, 'DashboardColor' .. i, { fg = color })
  end

  local ns = vim.api.nvim_create_namespace('dashboard')
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  local row = margin_top

  vim.api.nvim_buf_set_extmark(buf, ns, row + 1, margin_left + 2, {
    end_col = margin_left + 2 + #project_name,
    hl_group = 'DashboardColor6',
  })

  if git_info.is_repo then
    vim.api.nvim_buf_set_extmark(buf, ns, row + 6, margin_left + 2, {
      end_col = margin_left + 16,
      hl_group = 'DashboardColor1',
    })

    local branch_text = (git_info.branch or 'unknown')
    local branch_line = '  ├─ Branch: ' .. branch_text
    local branch_start = margin_left + vim.fn.strlen('  ├─ Branch: ')

    vim.api.nvim_buf_set_extmark(buf, ns, row + 7, branch_start, {
      end_col = branch_start + vim.fn.strlen(branch_text),
      hl_group = 'DashboardColor3',
    })

    local status_text = git_info.status == 'clean' and 'clean' or (git_info.files_changed .. ' file(s) changed')
    local status_start = margin_left + vim.fn.strlen('  ├─ Status: ')
    local status_hl = git_info.status == 'clean' and 'DashboardColor2' or 'DashboardColor4'
    vim.api.nvim_buf_set_extmark(buf, ns, row + 8, status_start, {
      end_col = status_start + vim.fn.strlen(status_text),
      hl_group = status_hl,
    })
  else
    local not_git_text = 'Not a git repository'
    vim.api.nvim_buf_set_extmark(buf, ns, row + 6, margin_left + 2, {
      end_col = margin_left + 2 + vim.fn.strlen(not_git_text),
      hl_group = 'DashboardColor7',
    })
  end

  if #recent_files > 0 then
    local recent_row = git_info.is_repo and (row + 10) or (row + 8)

    for i, file in ipairs(recent_files) do
      local file_row = recent_row + i
      local file_start = margin_left + vim.fn.strlen('  ├─ ')
      local max_len = width - margin_left * 2 - 6
      local display_file = file
      if #file > max_len then
        display_file = '...' .. file:sub(#file - max_len + 4)
      end
      vim.api.nvim_buf_set_extmark(buf, ns, file_row, file_start, {
        end_col = file_start + vim.fn.strlen(display_file),
        hl_group = 'DashboardColor10',
      })
    end
  end

  local color_ns = vim.api.nvim_create_namespace('dashboard_colorbar')
  local base_col = margin_left + 2
  local byte_width = vim.fn.strlen('█')
  local block_width = byte_width * 5
  local step = block_width + 1

  for i = 1, #colors do
    local col = base_col + step * (i - 1)
    vim.api.nvim_buf_set_extmark(buf, color_ns, color_bar_line_idx, col, {
      end_col = col + block_width,
      hl_group = 'DashboardColor' .. i,
      priority = 200,
    })
  end
end

local function open_dashboard()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  local saved_cmdheight = vim.o.cmdheight
  local saved_laststatus = vim.o.laststatus
  vim.o.cmdheight = 0
  vim.o.laststatus = 0

  local saved_opts = {
    number = vim.wo[win].number,
    relativenumber = vim.wo[win].relativenumber,
    signcolumn = vim.wo[win].signcolumn,
    cursorline = vim.wo[win].cursorline,
  }

  vim.api.nvim_create_autocmd({ 'BufWipeout', 'BufDelete' }, {
    buffer = buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        for k, v in pairs(saved_opts) do
          vim.wo[win][k] = v
        end
        vim.o.cmdheight = saved_cmdheight
        vim.o.laststatus = saved_laststatus
      end
    end,
  })

  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'dashboard'

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = true

  vim.b[buf].miniindentscope_disable = true

  render_dashboard(buf, win)

  vim.bo[buf].modifiable = false

  vim.keymap.set('n', 'q', '<cmd>quit<cr>', { buffer = buf, silent = true })
  vim.keymap.set('n', 'e', '<cmd>enew<cr>', { buffer = buf, silent = true })
end

function M.setup()
  local function setup_dashboard()
    local buf = 1
    if vim.fn.argc(-1) > 0 then
      return
    end
    if vim.api.nvim_buf_get_name(0) ~= '' then
      return
    end
    if vim.bo[buf].modified then
      return
    end
    if vim.api.nvim_buf_line_count(buf) > 1 or #(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or '') > 0 then
      return
    end

    open_dashboard()
  end

  vim.api.nvim_create_autocmd('VimEnter', {
    callback = setup_dashboard,
  })

  vim.api.nvim_create_autocmd('VimResized', {
    callback = function()
      if vim.bo.filetype == 'dashboard' then
        vim.bo.modifiable = true
        local buf = vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_get_current_win()
        render_dashboard(buf, win)
        vim.bo.modifiable = false
      end
    end,
  })

  vim.api.nvim_create_autocmd('OptionSet', {
    pattern = 'background',
    callback = function()
      if vim.bo.filetype == 'dashboard' then
        vim.bo.modifiable = true
        local buf = vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_get_current_win()
        render_dashboard(buf, win)
        vim.bo.modifiable = false
      end
    end,
  })
end

return M
