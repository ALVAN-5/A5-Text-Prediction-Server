#!/bin/bash -i

function setVars() {
    env_vars=""
    env_type=""

    # A5TPS_ENV
    echo "Is this a dev environment (non-production)? [y/N]: "
    read isDevEnv

    if
        [[ "$isDevEnv" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        env_type=DEV
    else
        env_type=PROD
    fi

    # A5TPS_ALLOWED_IPS_URL
    echo "Enter URL for the text prediction server allowed IPs json file: "
    read A5TPS_ALLOWED_IPS_URL

    # A5TPS_INTENTS_URL
    echo "Enter URL for the text prediction server intents json file: "
    read A5TPS_INTENTS_URL

    echo ""
    echo "Environment Variables:"
    echo "Is the following information correct?"
    echo "Domain Type (DEV/PROD): $env_type"
    echo "Allowed IPs json url: $A5TPS_ALLOWED_IPS_URL"
    echo "Intents json url: $A5TPS_INTENTS_URL"
    echo ""
    echo "Is the above information correct? [y/N]: "
    read confirmation

    if
        [[ "$confirmation" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        createVarString $env_type $A5TPS_ALLOWED_IPS_URL $A5TPS_INTENTS_URL $1
    else
        echo "Variables not set."
        doNotSave=1
    fi
}

function createVarString() {
    echo "export A5TPS_ENV=$1;" >$4
    echo "export A5TPS_ALLOWED_IPS_URL=\"$2\";" >>$4
    echo "export A5TPS_INTENTS_URL=\"$3\";" >>$4
}

if
    [ $(grep -c "zsh" $SHELL) != 0 ]
then
    rcFile=".zshrc"
else
    rcFile=".bashrc"
fi

doNotSave=0

if ! [ -f ~/$rcFile ]; then
    touch ~/$rcFile
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # linux
    if ! [ -d ~/.alvan ]; then
        mkdir ~/.alvan
    fi
    if ! [ -f ~/.alvan/ALVAN_ENV ]; then
        touch ~/.alvan/ALVAN_ENV
    fi
    setVars ~/.alvan/ALVAN_ENV
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    if ! [ -d ~/Library/ALVAN ]; then
        mkdir ~/Library/ALVAN
    fi
    if ! [ -f ~/Library/ALVAN/ALVAN_ENV ]; then
        touch ~/Library/ALVAN/ALVAN_ENV
    fi
    setVars ~/Library/ALVAN/ALVAN_ENV
else
    doNotSave=1
    echo "System not supported. Try manually setting the following env variables:"
    echo "A5TPS_ENV: ('DEV'/'PROD')"
    echo "A5TPS_ALLOWED_IPS_URL: (url to allowed ips json file: ex: 'https://...allowed_ips.json')"
    echo "A5TPS_ALLOWED_IPS_URL: (url to intents json file: ex: 'https://...intents.json')"
fi

if
    [ $doNotSave == 1 ]
then
    echo "Exiting now."
elif
    [ $(grep -c "Setting ALVAN 5 Text Prediction Server Environment Variables" ~/$rcFile) == 0 ]
then
    export A5TPS_ENV=$env_type
    export A5TPS_ALLOWED_IPS_URL=$A5TPS_ALLOWED_IPS_URL
    export A5TPS_INTENTS_URL=$A5TPS_INTENTS_URL
    echo "\n# Setting ALVAN 5 Text Prediction Server Environment Variables\nsource ~/Library/ALVAN/ALVAN_ENV;" >> ~/$rcFile
    echo -e "Environment variables set. A system restart is recommended$ to include new variables."
    echo -e "Alternatively, run $(source ~/$rcFile$) to refresh terminal with new variables."

else
    export A5TPS_ENV=$env_type
    export A5TPS_ALLOWED_IPS_URL=$A5TPS_ALLOWED_IPS_URL
    export A5TPS_INTENTS_URL=$A5TPS_INTENTS_URL
    echo -e "Environment variables set. A system restart is recommended to include new variables."
    echo -e "Alternatively, run $(source ~/$rcFile) to refresh terminal with new variables."
fi
