local M = {}

local function open_dashboard()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local width = vim.api.nvim_win_get_width(win)
  local height = vim.api.nvim_win_get_height(win)

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

  vim.api.nvim_set_hl(0, 'DashboardNormalBold', { link = 'Normal', bold = true })
  vim.wo[win].winhl = 'Normal:DashboardNormalBold'

  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  vim.bo[buf].filetype = 'dashboard'

  vim.b[buf].miniindentscope_disable = true

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].cursorline = false

  local project_name = vim.fn.fnamemodify(vim.uv.cwd(), ':t')

  local lines = {
    '##############',
    '#   PROJECT  #',
    '##############',
    '',
    project_name,
    '',
    '',
    '',
    '##############',
    '#   STATUS   #',
    '##############',
    '',
    'checking',
  }

  local vpad = math.floor((height - #lines) / 2)
  local centered = {}
  for _, line in ipairs(lines) do
    local pad = math.floor((width - #line) / 2)
    if pad < 0 then
      pad = 0
    end
    table.insert(centered, string.rep(' ', pad) .. line)
  end

  local final_lines = {}
  for _ = 1, vpad do
    table.insert(final_lines, '')
  end
  vim.list_extend(final_lines, centered)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, final_lines)

  local ns = vim.api.nvim_create_namespace('dashboard')

  -- PROJECT HIGHLIGHTS
  vim.api.nvim_buf_set_extmark(buf, ns, vpad, math.floor((width - 14) / 2), {
    end_row = vpad,
    end_col = math.floor((width - 14) / 2) + 14,
    hl_group = 'Conceal',
  })

  vim.api.nvim_buf_set_extmark(buf, ns, vpad + 1, math.floor((width - 14) / 2) + 1, {
    end_row = vpad + 1,
    end_col = math.floor((width - 14) / 2) + 13,
    hl_group = 'Typedef',
  })
  vim.api.nvim_buf_set_extmark(buf, ns, vpad + 1, math.floor((width - 14) / 2) + 13, {
    end_row = vpad + 1,
    end_col = math.floor((width - 14) / 2) + 14,
    hl_group = 'Conceal',
  })
  vim.api.nvim_buf_set_extmark(buf, ns, vpad + 1, math.floor((width - 14) / 2), {
    end_row = vpad + 1,
    end_col = math.floor((width - 14) / 2) + 1,
    hl_group = 'Conceal',
  })

  vim.api.nvim_buf_set_extmark(buf, ns, vpad + 2, math.floor((width - 14) / 2), {
    end_row = vpad + 2,
    end_col = math.floor((width - 14) / 2) + 14,
    hl_group = 'Conceal',
  })
  --

  -- STATUS HIGHLIGHTS
  vim.api.nvim_buf_set_extmark(buf, ns, vpad + 8, math.floor((width - 14) / 2), {
    end_row = vpad + 8,
    end_col = math.floor((width - 14) / 2) + 14,
    hl_group = 'Conceal',
  })

  vim.api.nvim_buf_set_extmark(buf, ns, vpad + 9, math.floor((width - 14) / 2) + 1, {
    end_row = vpad + 9,
    end_col = math.floor((width - 14) / 2) + 13,
    hl_group = 'Directory',
  })
  vim.api.nvim_buf_set_extmark(buf, ns, vpad + 9, math.floor((width - 14) / 2) + 13, {
    end_row = vpad + 9,
    end_col = math.floor((width - 14) / 2) + 14,
    hl_group = 'Conceal',
  })
  vim.api.nvim_buf_set_extmark(buf, ns, vpad + 9, math.floor((width - 14) / 2), {
    end_row = vpad + 9,
    end_col = math.floor((width - 14) / 2) + 1,
    hl_group = 'Conceal',
  })

  vim.api.nvim_buf_set_extmark(buf, ns, vpad + 10, math.floor((width - 14) / 2), {
    end_row = vpad + 10,
    end_col = math.floor((width - 14) / 2) + 14,
    hl_group = 'Conceal',
  })

  local pn_pad = math.floor((width - #project_name) / 2)
  if pn_pad < 0 then
    pn_pad = 0
  end
  vim.api.nvim_buf_set_extmark(buf, ns, vpad + 4, pn_pad, {
    end_row = vpad + 4,
    end_col = pn_pad + #project_name,
    hl_group = 'Typedef',
  })
  local st_pad = math.floor((width - 8) / 2)
  if st_pad < 0 then
    st_pad = 0
  end
  vim.api.nvim_buf_set_extmark(buf, ns, vpad + 12, st_pad, {
    end_row = vpad + 12,
    end_col = st_pad + 8,
    hl_group = 'Directory',
  })

  --

  vim.system({ 'git', 'status', '--porcelain' }, { text = true }, function(obj)
    vim.schedule(function()
      vim.bo[buf].modifiable = true
      local ok = (obj.code == 0)

      local out = '++++++++'
      if not ok then
        out = 'Not repo'
      elseif ok and obj.stdout == '' then
        out = '--------'
      end

      local centered_out = {}
      local pad = math.floor((width - #out) / 2)
      if pad < 0 then
        pad = 0
      end
      table.insert(centered_out, string.rep(' ', pad) .. out)

      vim.api.nvim_buf_set_lines(buf, vpad + #lines - 1, -1, false, centered_out)
      local pn_pad = math.floor((width - #project_name) / 2)
      if pn_pad < 0 then
        pn_pad = 0
      end
      vim.api.nvim_buf_set_extmark(buf, ns, vpad + 4, pn_pad, {
        end_row = vpad + 4,
        end_col = pn_pad + #project_name,
        hl_group = 'Typedef',
      })
      local st_pad = math.floor((width - 8) / 2)
      if st_pad < 0 then
        st_pad = 0
      end
      vim.api.nvim_buf_set_extmark(buf, ns, vpad + 12, st_pad, {
        end_row = vpad + 12,
        end_col = st_pad + 8,
        hl_group = 'Directory',
      })

      vim.bo[buf].modifiable = false
    end)
  end)

  vim.bo[buf].modifiable = false
end

function M.setup()
  -- Only open dashboard if conditions match the "intro screen" case
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
        open_dashboard()
      end
    end,
  })
end

return M
