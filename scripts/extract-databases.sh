#/opt/homebrew/Cellar/bash/5.2.15/bin/bashs
bash --version
set -e;

DATABASES="$(php -f scripts/get-source-databases-list.php) Quit"

source .env;

declare -A SelectedOptions

for database in ${DATABASES[@]}; do
    clear
    echo -en "Searching databases, found: $database... \r";
    SelectedOptions+=([$database]=0)
    sleep 0.05
    tput rc;tput el
done

select opt in $DATABASES; do
    if [ "$opt" = "Quit" ]; then
        echo done
        break;
    elif [ ! "$opt" = "Quit" ]; then
        if [ "${SelectedOptions[$opt]}" == "1" ]; then
            SelectedOptions+=([$opt]=0);
            echo "Removed database: $opt"
        else
            SelectedOptions+=([$opt]=1)
            echo "Added database: $opt"
        fi
    else
        clear
        echo bad option
    fi
done

SelectedDatabases=''
for key in ${!SelectedOptions[@]}; do
    if [ "${SelectedOptions[$key]}" == "1" ]; then
        SelectedDatabases="$SelectedDatabases $key";
    fi
done

echo "Writing down the selected databases ($SelectedDatabases) in: $SELECTED_DATABASE_LOCATION"
echo "$SelectedDatabases" > $SELECTED_DATABASE_LOCATION