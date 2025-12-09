local M = {}

function M.setup()
  -- WSL clipboard support and fix for the lags on first actions
  -- First, add win32yank.exe to PATH:
  --   curl -LO https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
  --   unzip win32yank-x64.zip
  --   sudo mv win32yank.exe /usr/local/bin/
  --   sudo chmod +x /usr/local/bin/win32yank.exe

  if vim.fn.has('wsl') == 1 then
    -- try to pick win32yank.exe, because it's faster
    local clipboard_exe = vim.fn.executable('win32yank.exe') == 1 and 'win32yank.exe' or '/mnt/c/Windows/System32/clip.exe'

    -- register our own provider, so clipboard provider detector doesn't run
    vim.g.clipboard = {
      name = 'wsl-clipboard',
      copy = {
        ['+'] = clipboard_exe .. ' -i --crlf',
        ['*'] = clipboard_exe .. ' -i --crlf',
      },
      paste = {
        ['+'] = clipboard_exe .. ' -o --lf',
        ['*'] = clipboard_exe .. ' -o --lf',
      },
      -- keep the first spawned process and re-use it:
      cache_enabled = 1,
    }
  end
end

return M
