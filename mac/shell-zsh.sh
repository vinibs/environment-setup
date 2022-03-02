#!/bin/sh

echo "Install Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

chmod 755 /usr/local/share/zsh
chmod 755 /usr/local/share/zsh/site-functions


echo "\nSetup files..."
rm -rf ./shell_setup
mkdir ./shell_setup

echo "\nDownload JetBrains Mono font (v2.242)..."
curl -L https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip --output shell_setup/JetBrainsMono.zip

echo "\nExtract JetBrains font..."
cd ./shell_setup/
unzip JetBrainsMono.zip

echo "\nInstall JetBrains font..."
cp -r ./fonts/ttf/* /Library/Fonts

echo "\nNow you have to manually update your terminal font settings to JetBrainsMono"

UPDATED_TERMINAM_FONT_INPUT=""
while [ "$UPDATED_TERMINAM_FONT_INPUT" != "y" ] && [ "$UPDATED_TERMINAM_FONT_INPUT" != "Y" ]; do
    echo "Have you finished setting up the terminal font? Y/n"
    read UPDATED_TERMINAM_FONT_INPUT;
done


echo "\nSetup SpaceShip..."
ZSH_PROFILE=~/.zshrc
ZSH_CUSTOM=~/.oh-my-zsh/
git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"

ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

sed -i '' "s|ZSH_THEME=.*$|ZSH_THEME=\"spaceship\"|g" $ZSH_PROFILE

echo "
SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  hg            # Mercurial section (hg_branch  + hg_status)
  exec_time     # Execution time
  line_sep      # Line break
  vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)
SPACESHIP_USER_SHOW=always
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_CHAR_SYMBOL="❯"
SPACESHIP_CHAR_SUFFIX=" "
" >> $ZSH_PROFILE

echo "\nInstall Plugins..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
echo "zinit light zdharma/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions" >> $ZSH_PROFILE


VSCODE_SETTINGS_FILE_PATH=~/Library/Application\ Support/Code/User/settings.json

echo "\nEnable new settings also on VSCode Terminal..."
TERMINAL_SHELL_SETTING=$(grep terminal.integrated.defaultProfile.osx "$VSCODE_SETTINGS_FILE_PATH" | wc -l)

if [ $TERMINAL_SHELL_SETTING -lt 1 ] 
then
    # Add shell setting
    sed -i '' "s|\}$|\t\"terminal.integrated.defaultProfile.osx\": \"zsh\",\n\}|g" "$VSCODE_SETTINGS_FILE_PATH"
else 
    # Replace shell setting
    sed -i '' "s|\"terminal.integrated.defaultProfile.osx\": \"\"|\"terminal.integrated.defaultProfile.osx\": \"zsh\",|g" "$VSCODE_SETTINGS_FILE_PATH"
fi



echo "\nUpdate font on VSCode terminal to JetBrainsMono..."
FONT_FAMILY_SETTING=$(grep editor.fontFamily "$VSCODE_SETTINGS_FILE_PATH" | wc -l)

if [ $FONT_FAMILY_SETTING -lt 1 ] 
then
    # Add font_family setting
    sed -i '' "s|\}$|\t\"editor.fontFamily\": \"'JetBrains Mono', Menlo, Monaco, 'Courier New', monospace\",\n\}|g" "$VSCODE_SETTINGS_FILE_PATH"
else 
    # Replace font_family setting
    sed -i '' "s|\"editor.fontFamily\": .*$|\"editor.fontFamily\": \"'JetBrains Mono', Menlo, Monaco, 'Courier New', monospace\"|g" "$VSCODE_SETTINGS_FILE_PATH"
fi


echo "\nDeleting remaining files..."
cd ..
rm -rf ./shell_setup


source $ZSH_PROFILE
echo "\nNow, restart the terminal and VSCode to apply changes."

exit