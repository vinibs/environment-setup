#!/bin/zsh

echo "Install Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &> /dev/null

echo "\nSetup files..."
rm -rf ./shell_setup
mkdir ./shell_setup

echo "\nDownload JetBrains Mono font (v2.242)..."
curl -L https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip --output shell_setup/JetBrainsMono.zip &> /dev/null

echo "\nExtract JetBrains font..."
cd ./shell_setup/
unzip JetBrainsMono.zip > /dev/null

echo "\nInstall JetBrains font..."
cp -r ./fonts/ttf/* /Library/Fonts

echo "\nNow you have to manually update your terminal font settings to JetBrainsMono"

UPDATED_TERMINAM_FONT_INPUT=""
while [ "$UPDATED_TERMINAM_FONT_INPUT" != "y" ] && [ "$UPDATED_TERMINAM_FONT_INPUT" != "Y" ]; do
    echo "Have you finished setting up the terminal font (Y/n)?"
    read UPDATED_TERMINAM_FONT_INPUT;
done


echo "\nSetup SpaceShip..."
ZSH_PROFILE=~/.zshrc
ZSH_CUSTOM=~/.oh-my-zsh/
git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" &> /dev/null

ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

sed -i '' "s|ZSH_THEME=.*$|ZSH_THEME=\"spaceship\"|g" $ZSH_PROFILE

echo "
SPACESHIP_USER_SHOW=always
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_CHAR_SYMBOL=\"❯\"
SPACESHIP_CHAR_SUFFIX=\" \"

$(cat $ZSH_PROFILE)
" > $ZSH_PROFILE

echo "
SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  venv          # Virtual Env
  # exec_time     # Execution time
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)
" >> $ZSH_PROFILE

echo "\nInstall Plugins..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting &> /dev/null
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions &> /dev/null
git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions &> /dev/null
sed -i '' "s|plugins=\(.*\)|plugins=(git virtualenv zsh-syntax-highlighting zsh-autosuggestions zsh-completions)|g" $ZSH_PROFILE



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