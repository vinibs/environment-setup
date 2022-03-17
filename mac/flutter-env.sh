#!/bin/sh

ZSH_PROFILE=~/.zshrc

LOG_FILE=$(pwd)/flutter-setup.log
CURRENT_DATE=`date`

if [ -f $LOG_FILE ]; then
    rm -f $LOG_FILE
fi

touch $LOG_FILE
echo "Flutter installation - $CURRENT_DATE" >> $LOG_FILE
echo '' >> $LOG_FILE


MAC_ARCH=`uname -m`
if [[ $MAC_ARCH == 'arm64' ]]; then
    echo '>> Installing Rosetta...'
    echo '>> Install Rosetta...' >> $LOG_FILE
    sudo softwareupdate --install-rosetta --agree-to-license >> $LOG_FILE 2>&1
fi


FLUTTER_BASE_DIR=~/.flutter
if ! [ -d $FLUTTER_BASE_DIR ]; then
    mkdir -p $FLUTTER_BASE_DIR >> $LOG_FILE 2>&1
fi

cd $FLUTTER_BASE_DIR

EXPORT_CMD="export PATH=\"\$PATH:$FLUTTER_BASE_DIR/flutter/bin\""
eval "$EXPORT_CMD"

if ! [ -d "flutter" ]; then
    echo '\n>> Setting up latest Flutter SDK...'
    echo '\n>> Get latest Flutter SDK...' >> $LOG_FILE
    git clone https://github.com/flutter/flutter.git -b stable >> $LOG_FILE 2>&1

    echo '\n>> Download necessary binaries...' >> $LOG_FILE
    flutter precache >> $LOG_FILE 2>&1
else
    echo '>> Flutter SDK already downloaded.'
    echo '\n>> Flutter SDK already downloaded.' >> $LOG_FILE
fi


if ! grep -q "Flutter" "$ZSH_PROFILE"; then
    echo '\n>> Add Flutter path to profile...' >> $LOG_FILE
    echo '# Flutter settings' >> $ZSH_PROFILE
    echo "$EXPORT_CMD" >> $ZSH_PROFILE
    echo '\n' >> $ZSH_PROFILE
else
    echo '\n>> Update Flutter path on profile...' >> $LOG_FILE
    sed -i '' "s|export PATH=\"\$PATH:.*flutter.*\/bin\"|$EXPORT_CMD|g" $ZSH_PROFILE >> $LOG_FILE 2>&1
fi

echo '\n>> Check Flutter installation...' >> $LOG_FILE
DOCTOR_CMD="flutter doctor"
eval "$DOCTOR_CMD" >> $LOG_FILE 2>&1

echo '\n>> Checking Flutter installation...'
eval "$DOCTOR_CMD"


## Android Studio/SDK and Xcode installation step

ASK_FOR_ANDROID_AND_IOS=false

AVAILABLE_BOOL_ANSWERS=()
POSITIVE_ANSWERS=("Y", "y")
NEGATIVE_ANSWERS=("N", "n")
for answer in "${POSITIVE_ANSWERS[*]}"; do AVAILABLE_BOOL_ANSWERS+=("$answer"); done
for answer in "${NEGATIVE_ANSWERS[*]}"; do AVAILABLE_BOOL_ANSWERS+=("$answer"); done

INVALID_ANSWER_MESSAGE="\n\033[31m>> Invalid answer. Please provide a valid one.\033[0m"

if $ASK_FOR_ANDROID_AND_IOS; then

    # TODO: check for android SDK/android studio
    while [[ -z "$INSTALL_ANDROID_STUDIO" || ! " ${AVAILABLE_BOOL_ANSWERS[*]} " =~ " ${INSTALL_ANDROID_STUDIO} " ]];
    do
        echo "\n>> Do you want to install the Android SDK with Android Studio? (Y/n)"
        read INSTALL_ANDROID_STUDIO

        if [[ ! " ${AVAILABLE_BOOL_ANSWERS[*]} " =~ " ${INSTALL_ANDROID_STUDIO} " ]]; then
            echo $INVALID_ANSWER_MESSAGE
        fi
    done

    # TODO: check for xcode
    while [[ -z "$INSTALL_XCODE" || ! " ${AVAILABLE_BOOL_ANSWERS[*]} " =~ " ${INSTALL_XCODE} " ]];
    do
        echo "\n>> Do you want to install Xcode? (Y/n)"
        read INSTALL_XCODE

        if [[ ! " ${AVAILABLE_BOOL_ANSWERS[*]} " =~ " ${INSTALL_XCODE} " ]]; then
            echo $INVALID_ANSWER_MESSAGE
        fi
    done

fi
# ...