#/bin/bash
# Requires bash >= 3.2

set -e;

source .env;

# Source Database url: $1
# Target Database url: $2
# Source Database name: $3
# Target Database name: $4 => default to Source database url

# Requires bash >= 3.2
urlRegex='(mysql|pgsql|postgresql)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
# not working with bash 3.2 under mac
# urlRegex='^(mysql|pgsql|postgresql)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'


DATABASE_SOURCE_URL="$1"
DATABASE_TARGET_URL="$2"
DATABASE_SOURCE_NAME="$3"
DATABASE_TARGET_NAME="$4"
DATABASE_TARGET_NAME=${DATABASE_TARGET_NAME:=${DATABASE_SOURCE_NAME}}

if [[ "$1" == "--help" ]]; then
    echo 'USAGE:'
    echo "prepare-load.sh [DATABASE_SOURCE_URL] [DATABASE_TARGET_URL] [DATABASE_SOURCE_NAME]"
    echo "prepare-load.sh [DATABASE_SOURCE_URL] [DATABASE_TARGET_URL] [DATABASE_SOURCE_NAME] [DATABASE_TARGET_NAME]"
    echo '\nExample:'
    echo "prepare-load.sh mysql://root:mysecretpassword@localhost:13306/youamlhp_sadmin pgsql://postgres:mysecretpassword@localhost:5432/youamlhp_sadmin youamlhp_sadmin"
    exit 0;
fi

if [[ ! $DATABASE_SOURCE_URL =~ $urlRegex || ! $DATABASE_TARGET_URL =~ $urlRegex  ]]
then 
    echo "One of ($DATABASE_SOURCE_URL, $DATABASE_TARGET_URL) is not a valid url."
    exit 1;
fi

PROJECT_NAME=${DATABASE_SOURCE_NAME}_to_${DATABASE_TARGET_NAME}
PROJECT_LOCATION=projects/${PROJECT_NAME}
TMP_FILE="mysql-to-pgsql.${DATABASE_SOURCE_NAME}.load.tmp"
OUTPUT_FILE="${PROJECT_LOCATION}/mysql-to-pgsql.load"

if [[ -f "$OUTPUT_FILE" ]]; then
    echo "This project already exists. The existing files won't be created or deleted"
else
    mkdir -p $PROJECT_LOCATION

    echo "Writing Mysql url..."
    sed "s#DATABASE_MYSQL_URL#${DATABASE_SOURCE_URL}#" samples/mysql-to-pgsql.sample.load > $TMP_FILE

    echo "Writing Pgsql url..."
    # PGsql is case sensitive
    db_target_to_lower=$(echo "${DATABASE_TARGET_URL}" | tr "[:upper:]" "[:lower:]")
    sed "s#DATABASE_PGQSL_URL#${db_target_to_lower}#" $TMP_FILE > $OUTPUT_FILE

    echo "Removing temporary files..."
    rm -rf $TMP_FILE
fi
