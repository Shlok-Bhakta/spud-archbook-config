return {
  {
    "xeluxee/competitest.nvim",
    dependencies = "MunifTanjim/nui.nvim",
    keys = {
      -- group label
      { "<leader>C", group = "competitest" },
      -- run
      { "<leader>Cr", "<cmd>CompetiTest run<cr>",            desc = "Run testcases" },
      { "<leader>CR", "<cmd>CompetiTest run_no_compile<cr>", desc = "Run (no compile)" },
      { "<leader>Cu", "<cmd>CompetiTest show_ui<cr>",        desc = "Show UI" },
      -- watch mode toggle
      { "<leader>Cw", desc = "Toggle auto-run on save" },
      -- testcase management
      { "<leader>Ca", "<cmd>CompetiTest add_testcase<cr>",    desc = "Add testcase" },
      { "<leader>Ce", "<cmd>CompetiTest edit_testcase<cr>",   desc = "Edit testcase" },
      { "<leader>Cd", "<cmd>CompetiTest delete_testcase<cr>", desc = "Delete testcase" },
      -- receive (competitive-companion)
      { "<leader>Ct", "<cmd>CompetiTest receive testcases<cr>",    desc = "Receive testcases" },
      { "<leader>Cp", "<cmd>CompetiTest receive problem<cr>",      desc = "Receive problem" },
      { "<leader>Cc", "<cmd>CompetiTest receive contest<cr>",      desc = "Receive contest" },
      { "<leader>Cl", "<cmd>CompetiTest receive persistently<cr>", desc = "Receive persistently" },
      { "<leader>Cs", "<cmd>CompetiTest receive stop<cr>",         desc = "Stop receiving" },
    },
    config = function()
      local cpp_dump_include = vim.fn.expand("~/dotfiles/cpp-dump")
      local pch_file = vim.fn.expand("~/dotfiles/pch/stdc++.h.pch")
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
          c = { exec = "gcc", args = { "-Wall", "$(FABSPATH)", "-o", "$(ABSDIR)/solution" } },
          cpp = {
            exec = "clang++",
            args = {
              "-std=c++23",
              "-DLOCAL_DEBUG",
              "-I" .. cpp_dump_include,
              "-include-pch", pch_file,
              "$(FABSPATH)",
              "-o",
              "$(ABSDIR)/solution",
            },
          },
          rust = { exec = "rustc", args = { "$(FABSPATH)", "-o", "$(ABSDIR)/solution" } },
          java = { exec = "javac", args = { "$(FABSPATH)" } },
        },
        run_command = {
          c    = { exec = "sh", args = { "-c", "$(ABSDIR)/solution; rm -f $(ABSDIR)/solution" } },
          cpp  = { exec = "sh", args = { "-c", "$(ABSDIR)/solution; rm -f $(ABSDIR)/solution" } },
          rust = { exec = "sh", args = { "-c", "$(ABSDIR)/solution; rm -f $(ABSDIR)/solution" } },
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
        local buf = vim.api.nvim_get_current_buf()
        if watching[buf] then
          watching[buf] = false
          vim.notify("CompetiTest: stopped watching " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
        else
          enable_watch(buf)
          vim.notify("CompetiTest: watching " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
        end
      end, { desc = "Toggle auto-run on save" })
    end,
  },
}
