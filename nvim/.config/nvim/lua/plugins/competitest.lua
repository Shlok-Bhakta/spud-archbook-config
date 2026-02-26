return {
  {
    "xeluxee/competitest.nvim",
    dependencies = "MunifTanjim/nui.nvim",
    keys = {
      -- group label (also serves as lazy-load triggers)
      { "<leader>C",  desc = "competitest" },
      { "<leader>Cr", desc = "Run testcases" },
      { "<leader>CR", desc = "Run (no compile)" },
      { "<leader>Cu", desc = "Show UI" },
      { "<leader>Cw", desc = "Toggle auto-run on save" },
      { "<leader>Ca", desc = "Add testcase" },
      { "<leader>Ce", desc = "Edit testcase" },
      { "<leader>Cd", desc = "Delete testcase" },
      { "<leader>Ct", desc = "Receive testcases" },
      { "<leader>Cp", desc = "Receive problem" },
      { "<leader>Cc", desc = "Receive contest" },
      { "<leader>Cl", desc = "Receive persistently" },
      { "<leader>Cs", desc = "Stop receiving" },
    },
    config = function()
      local cpp_dump_include = vim.fn.expand("~/dotfiles/cpp-dump")
      local pch_file = vim.fn.expand("~/dotfiles/pch/stdc++.h.pch")

      -- Returns the most recent normal (non-UI) buffer/window, so competitest
      -- commands always operate on the source file even when focus is on the
      -- split UI panel.
      local function source_win()
        for _, winid in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(winid)
          if vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "" then
            return winid, buf
          end
        end
        return vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
      end

      -- Temporarily focus the source window, run a command, then restore focus.
      local function ct(cmd)
        return function()
          local cur_win = vim.api.nvim_get_current_win()
          local src_win = source_win()
          vim.api.nvim_set_current_win(src_win)
          vim.cmd(cmd)
          -- only restore if we didn't open a new UI (run/show_ui manage their own focus)
          if src_win ~= cur_win and vim.api.nvim_win_is_valid(cur_win) then
            vim.api.nvim_set_current_win(cur_win)
          end
        end
      end
      require("competitest").setup({
        runner_ui = {
          interface = "split",
        },
        split_ui = {
          position = "right",
          relative_to_editor = true,
          total_width = 0.3,
          vertical_layout = {
            { 1, "tc" },
            { 1, { { 1, "so" }, { 1, "eo" } } },
            { 1, { { 1, "si" }, { 1, "se" } } },
          },
          total_height = 0.4,
          horizontal_layout = {
            { 2, "tc" },
            { 3, { { 1, "so" }, { 1, "si" } } },
            { 3, { { 1, "eo" }, { 1, "se" } } },
          },
        },
        compile_directory = ".",
        running_directory = ".",
        testcases_directory = ".",
        compile_command = {
          c = { exec = "gcc", args = { "-Wall", "$(FABSPATH)", "-o", "$(FNOEXT).bin" } },
          cpp = {
            exec = "clang++",
            args = {
              "-std=c++23",
              "-DLOCAL_DEBUG",
              "-I" .. cpp_dump_include,
              "-include-pch", pch_file,
              "$(FABSPATH)",
              "-o",
              "$(FNOEXT).bin",
            },
          },
          rust = { exec = "rustc", args = { "$(FABSPATH)", "-o", "$(FNOEXT).bin" } },
          java = { exec = "javac", args = { "$(FABSPATH)" } },
        },
        run_command = {
          c    = { exec = vim.fn.expand("~/dotfiles/run-and-clean.sh"), args = { "$(ABSDIR)/$(FNOEXT).bin" } },
          cpp  = { exec = vim.fn.expand("~/dotfiles/run-and-clean.sh"), args = { "$(ABSDIR)/$(FNOEXT).bin" } },
          rust = { exec = vim.fn.expand("~/dotfiles/run-and-clean.sh"), args = { "$(ABSDIR)/$(FNOEXT).bin" } },
          python = { exec = "python", args = { "$(FNAME)" } },
          java = { exec = "java", args = { "$(FNOEXT)" } },
        },
        received_files_extension = "cpp",
        received_problems_path = "$(CWD)/$(PROBLEM)/$(PROBLEM).$(FEXT)",
        received_problems_prompt_path = true,
        received_contests_directory = "$(CWD)",
        received_contests_problems_path = "$(PROBLEM)/$(PROBLEM).$(FEXT)",
        received_contests_prompt_directory = true,
        received_contests_prompt_extension = true,
        open_received_problems = true,
        open_received_contests = true,
        testcases_auto_detect_storage = true,
        template_file = { cpp = vim.fn.expand("~/.config/nvim/templates/cp.cpp") },
        evaluate_template_modifiers = true,
      })

      -- keymaps: always operate on the source file window
      vim.keymap.set("n", "<leader>Cr", ct("CompetiTest run"),            { desc = "Run testcases" })
      vim.keymap.set("n", "<leader>CR", ct("CompetiTest run_no_compile"), { desc = "Run (no compile)" })
      vim.keymap.set("n", "<leader>Cu", ct("CompetiTest show_ui"),        { desc = "Show UI" })
      vim.keymap.set("n", "<leader>Ca", ct("CompetiTest add_testcase"),   { desc = "Add testcase" })
      vim.keymap.set("n", "<leader>Ce", ct("CompetiTest edit_testcase"),  { desc = "Edit testcase" })
      vim.keymap.set("n", "<leader>Cd", ct("CompetiTest delete_testcase"),{ desc = "Delete testcase" })
      vim.keymap.set("n", "<leader>Ct", ct("CompetiTest receive testcases"),   { desc = "Receive testcases" })
      vim.keymap.set("n", "<leader>Cp", ct("CompetiTest receive problem"),     { desc = "Receive problem" })
      vim.keymap.set("n", "<leader>Cc", ct("CompetiTest receive contest"),     { desc = "Receive contest" })
      vim.keymap.set("n", "<leader>Cl", ct("CompetiTest receive persistently"),{ desc = "Receive persistently" })
      vim.keymap.set("n", "<leader>Cs", ct("CompetiTest receive stop"),        { desc = "Stop receiving" })

      -- auto-run on save toggle
      -- keyed by bufnr so each buffer tracks its own watch state
      local watch_augroup = vim.api.nvim_create_augroup("CompetitestWatch", { clear = true })
      local watching = {} -- bufnr -> true/false

      local function enable_watch(buf)
        if watching[buf] then return end
        watching[buf] = true
        vim.api.nvim_create_autocmd("BufWritePost", {
          group = watch_augroup,
          buffer = buf,
          callback = function()
            if watching[buf] then
              -- always run against the source buffer, not whatever is focused
              local src_win = source_win()
              vim.api.nvim_set_current_win(src_win)
              vim.cmd("CompetiTest run")
            end
          end,
          desc = "CompetiTest auto-run on save",
        })
      end

      -- enable watch automatically for all cpp buffers
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        group = watch_augroup,
        pattern = "*.cpp",
        callback = function(ev)
          enable_watch(ev.buf)
        end,
        desc = "CompetiTest auto-enable watch on cpp files",
      })

      -- also enable for any cpp buffer already open when plugin loads
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == "cpp" then
          enable_watch(buf)
        end
      end

      vim.keymap.set("n", "<leader>Cw", function()
        local _, buf = source_win()
        if watching[buf] then
          watching[buf] = false
          vim.notify("CompetiTest: stopped watching " .. vim.api.nvim_buf_get_name(buf), vim.log.levels.INFO)
        else
          enable_watch(buf)
          vim.notify("CompetiTest: watching " .. vim.api.nvim_buf_get_name(buf), vim.log.levels.INFO)
        end
      end, { desc = "Toggle auto-run on save" })
    end,
  },
}
