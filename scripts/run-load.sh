#/opt/homebrew/Cellar/bash/5.2.15/bin/bash

set -e;

# TODO: find a way to include it once for each bash script
source .env;

/opt/homebrew/Cellar/bash/5.2.15/bin/bash ./scripts/extract-databases.sh

DATABASE_NAMES="$(cat $SELECTED_DATABASE_LOCATION)";

# set databases url
DB_SOURCE_URL="$DB_SOURCE_PROTOCOL://$DB_SOURCE_USER:$DB_SOURCE_PASSWORD@$DB_SOURCE_HOST"
DB_DEST_URL="$DB_DEST_PROTOCOL://$DB_DEST_USER:$DB_DEST_PASSWORD@$DB_DEST_HOST:$DB_DEST_PORT"

# loop on databases to create and load each of them
for key in ${DATABASE_NAMES[@]}; do
    DATABASE_NAME=$key;

    PROJECT_NAME=${DATABASE_NAME}_to_${DATABASE_NAME}

    # youamlhp_sadmin_to_youamlhp_sadmin
    PROJECT_LOCATION=projects/${PROJECT_NAME}

    DATE=$(date +"%y-%m-%d_%H-%M-%S")
    OUTPUT="${PROJECT_LOCATION}/result_from_${DATE}.txt"
    LOGFILE="$(pwd)/${PROJECT_LOCATION}/log.txt"

    echo ">>>> Loading database "$DATABASE_NAME" from $DB_SOURCE_PROTOCOL to $DB_DEST_PROTOCOL... ⏳";
    echo "- Migration Project Location: ${PROJECT_LOCATION}"

    php scripts/create-databases.php $DATABASE_NAME

    set +e # to catch error
    ./scripts/prepare-load.sh $DB_SOURCE_URL/$DATABASE_NAME $DB_DEST_URL/$DATABASE_NAME $DATABASE_NAME
    return_code=$?
    if [ $return_code -ne 0 ]; then
        echo "<<<< Preparing database '$DATABASE_NAME' failed ❌"
        continue;
    fi
    set -e

    echo ">>>> Starting loading process of $DATABASE_NAME... ⏳"
    touch $LOGFILE

    pgloader -L $LOGFILE "${PROJECT_LOCATION}/mysql-to-pgsql.load" --dynamic-space-size 1000 > $OUTPUT
    echo ">>>> Loaded $DATABASE_NAME.................... ✅"

done

