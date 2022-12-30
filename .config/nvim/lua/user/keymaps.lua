local opts = { noremap = true, silent = true }
local term_opts = { silent = true }


-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts) --VERY IMPORTANT, THIS IS YOU LEADER KEY AND WE SET IT TO SPACE FOR NVIM!!!
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Legends
--  "C-" == Ctrl
--  "A-" == Alt
--  "S-" == Shift
--  "<leader>" == spacebar, as noted above

keymap("t", "<Esc>", "<C-\\><C-n>", term_opts) 


-- Normal --
-- Personal Tweak because I use colemak-dh and keybinding would be too wierd
keymap("n", "h", "l", opts)
keymap("n", "j", "k", opts)
keymap("n", "k", "h", opts)
keymap("n", "l", "j", opts)


--Same personal tweak as above, but for the visual modes (including visual block and visual line)
keymap("v", "h", "l", opts)
keymap("v", "j", "k", opts)
keymap("v", "k", "h", opts)
keymap("v", "l", "j", opts)


-- Better window navigation
keymap("n", "<C-w>h", "<C-w>l", opts) -- these won't work because they interfere with tmux C-[hjkl] for pane navigation
keymap("n", "<C-w>j", "<C-w>k", opts) -- these won't work because they interfere with tmux C-[hjkl] for pane navigation
keymap("n", "<C-w>k", "<C-w>h", opts) -- these won't work because they interfere with tmux C-[hjkl] for pane navigation
keymap("n", "<C-w>l", "<C-w>j", opts) -- these won't work because they interfere with tmux C-[hjkl] for pane navigation
keymap("n", "<leader>e", ":Lex 30<cr>", opts)


-- Center my cursor when scrolling or searching
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)


-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-j>", ":bprevious<CR>", opts)


-- Select All
keymap("n", "<leader>a", "ggVG", opts)
keymap("n", "<leader>y", ":\"*y", opts)


-- Personal Shit Because I Like it
keymap("n", "<leader>h", ":nohlsearch<CR>", opts) -- this clears any highlighting on the screen from a residual search (I'm OCD lol)
keymap("n", "<leader>q", ":bd<CR>", opts) -- this closes an open vim buffer (like filetree or help menus)


-- Insert --
-- Nothing here yet


-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)


-- Move text up and down
keymap("v", "<A-l>", ":m .+1<CR>==", opts)
keymap("v", "<A-j>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts) -- This is a sneaky so that you're register doesn't dynamically change in visual mode, which is the behavior by default


-- Visual Block --
-- Move text up and down
-- keymap("x", "L", ":move '>+1<CR>gv-gv", opts) --these two with "L and J" are the same as the other two "Alt-l and Alt-j"
-- keymap("x", "J", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-l>", ":move '>+1<CR>gv-gv", opts) --so basically, just giving you more that one keybinding to do the same thing
keymap("x", "<A-j>", ":move '<-2<CR>gv-gv", opts)


-- Terminal --
-- Better terminal navigation -- I don't know what any of the below lines do. But I understand the rest of the config, not bad eh? :)
-- keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
-- keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
-- keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
-- keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
