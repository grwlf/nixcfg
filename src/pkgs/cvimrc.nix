{ pkgs ? import <nixpkgs> {}, me } :
pkgs.writeText "cvimrc" ''
  set nosmoothscroll
  set typelinkhints
  set noautofocus

  let searchlimit = 30
  let scrollstep = 70
  let barposition = "top"

  let locale = "uk"
  let hintcharacters = "123890"

  command g tabnew google

  let searchalias g = "google"
  let searchalias d = "duckduckgo"

  let blacklists = [ "https://mail.google.com/*", "*://mail.google.com/*", "@https://mail.google.com/mail/*"]

  unmap <C-w>

  map <C-a>c :tabnew<Space>http://duckduckgo.com<CR>
  map <C-ф>с :tabnew<Space>http://duckduckgo.com<CR>
  map o :open!<Space>
  map щ :open!<Space>
  map <A-o> :open!<Space>
  map <A-щ> :open!<Space>
  map <A-e> lastTab
  map <A-у> lastTab

  map R reloadTabUncached
  map К reloadTabUncached
  map d closeTab
  map в closeTab

  map u lastClosedTab
  map г lastClosedTab
  map U :restore<Space>
  map Г :restore<Space>

  map <C-u> rootFrame
  map <A-q> previousTab
  map <A-й> previousTab
  map <A-w> nextTab
  map <A-ц> nextTab

  map <C-d> scrollPageDown
  map <C-в> scrollPageDown
  map <C-u> scrollPageUp
  map <C-г> scrollPageUp

  map <A-i> goToInput
  map <A-ш> goToInput

  imap <A-f> forwardWord
  imap <A-а> forwardWord

  imap <A-b> backwardWord
  imap <A-и> backwardWord

  imap <C-w> deleteWord
  imap <C-ц> deleteWord

  imap <A-d> deleteForwardWord
  imap <A-в> deleteForwardWord

  map <A-d> :open<Space>
  map <A-в> :open<Space>

  map <C-o> goBack
  map <C-щ> goBack

  map <C-i> goForward
  map <C-ш> goForward

  map о j
  map л k
  map д l
  map р h
  map а f
  map А F
  map щ o
  map Щ O
  map . /
  map П G
  map пп gg
  map т n
  map Т N

  echo(link) -> {{
    alert(link.href);
  }}
  map <C-f> createScriptHint(echo)

  let configpath = '/home/${me}/.nix-profile/etc/cvimrc'
  set localconfig
''

