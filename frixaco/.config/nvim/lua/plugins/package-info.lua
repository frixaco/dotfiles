return {
  {
    'vuki656/package-info.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      {
        '<leader>ns',
        mode = { 'n' },
        function()
          require('package-info').show({ force = true })
        end,
        desc = 'Toggle Spectre',
        silent = true,
        noremap = true,
      },
      {
        '<leader>nd',
        mode = { 'n' },
        function()
          require('package-info').delete()
        end,
        desc = 'Toggle Spectre',
        silent = true,
        noremap = true,
      },
      {
        '<leader>np',
        mode = { 'n' },
        function()
          require('package-info').change_version()
        end,
        desc = 'Toggle Spectre',
        silent = true,
        noremap = true,
      },
      {
        '<leader>ni',
        mode = { 'n' },
        function()
          require('package-info').install()
        end,
        desc = 'Toggle Spectre',
        silent = true,
        noremap = true,
      },
    },
    opts = {
      colors = {
        up_to_date = '#3C4048', -- Text color for up to date dependency virtual text
        outdated = '#d19a66', -- Text color for outdated dependency virtual text
      },
      icons = {
        enable = true, -- Whether to display icons
        style = {
          up_to_date = '|  ', -- Icon for up to date dependencies
          outdated = '|  ', -- Icon for outdated dependencies
        },
      },
      autostart = true, -- Whether to autostart when `package.json` is opened
      hide_up_to_date = false, -- It hides up to date versions when displaying virtual text
      hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
      -- Can be `npm`, `yarn`, or `pnpm`. Used for `delete`, `install` etc...
      -- The plugin will try to auto-detect the package manager based on
      -- `yarn.lock` or `package-lock.json`. If none are found it will use the
      -- provided one, if nothing is provided it will use `yarn`
      package_manager = 'yarn',
    },
    config = function(_, opts)
      require('package-info').setup(opts)

      pcall(require('telescope').load_extension, 'package_info')
    end,
  },
}
