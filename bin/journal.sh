#!/bin/bash

ROOT=$HOME/.journal
if [ ! -d $ROOT ]; then
    mkdir $ROOT
fi

day=$(date +%Y/%m/%d)

private=0
verbose=0

function log
{
    LEVEL=$1
    echo $MSG
    MSG=$(cat /dev/stdin)
    NOW=$(date +'[%y-%m-%d %H:%M:%S]')
    LOG="$NOW $LEVEL $MSG"
    if [[ ! "x$MSG" == "x" ]]; then
        case $LEVEL in
            INFO | DEBUG)
                if [[ $verbose -eq 1 ]]; then
                    echo "$LOG" >> /dev/stderr
                else
                    echo "$LOG" >> $ROOT/journal.log
                fi
                ;;
            ERROR | WARNING | NOTICE)
                if [[ $verbose -eq 1 ]]; then
                    echo "$LOG" >> /dev/stdout
                else
                    echo "$LOG" >> $ROOT/journal.err
                fi
                ;;
        esac
    fi
}

function catenate
{
    file=$1
    base=$(basename $file)
    if [[ "gpg" == ${base#*.} ]]
    then
        if [[ $private -eq 1 ]]; then
            gpg --batch --decrypt $file 2>&1 | log "WARNING"
        fi
    else
        cat $file
    fi
}

function journal {
    case $1 in
        --verbose)
            verbose=1
            echo "Set to verbose" | log "DEBUG"
            shift
            journal $@
            ;;
        private)
            private=1
            echo "Enable private mode" | log "DEBUG"
            shift
            journal $@
            ;;
        create)
            echo "Create $2 directory" | log "DEBUG"
            mkdir $ROOT/$2
            ;;
        list)
            echo "Listing" | log "DEBUG" ls $ROOT
            ;;
        add)
            echo "Adding a new" | log "DEBUG"
            daypath=$ROOT/$2/$day
            journalfile=$daypath/journal_$(date +%s)
            mkdir -p $daypath
            timestamp=$(echo -e "\n## $(date)\n")
            if [ -z $3 ]; then
                which tempfile 2> /dev/null
                if [ ! $? -eq 0 ]; then
                    echo "tempfile does not exist. Install it first" | log "ERROR"
                    exit 1
                fi
                if [ ! -w /tmp ]; then
                    echo "/tmp is not writeable" | log "ERROR"
                    exit 1
                fi
                file=$(tempfile -d /tmp)
                if [ ! $? -eq 0 ]; then
                    echo "Could not create temporary file." | log "ERROR"
                    exit 1
                fi
                echo "Using temporary file $file" | log INFO
                $EDITOR $file
                if [ $? -eq 0 ]; then
                    echo -e "$timestamp\n" | cat /dev/stdin "$file" | encrypt $journalfile
                    rm $file
                else
                    echo "Error detected, changes are not saved"
                    echo "The modified file is $file"
                fi
            else
                echo -e "${timestamp}\n\n${3}" | encrypt $journalfile
            fi
            ;;
        cat)
            echo -e "# $2\n"

            for file in $(find $ROOT/$2 -iname 'journal_*.markdown' -or -iname 'journal_*.gpg' | sort); do
                catenate $file
            done

            ;;
        *)
            echo "Invalid usage"
            ;;
    esac
}


function encrypt
{
    if [[ $private -eq 1 ]]; then
        trg="$journalfile.gpg"
        cat /dev/stdin | gpg --encrypt >> $trg
    else
        trg="$journalfile.markdown"
        cat /dev/stdin >> $trg
    fi
}

journal $@
