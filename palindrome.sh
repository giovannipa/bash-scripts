#!/usr/bin/env bash
#
## @file palindrome.sh
## @brief check if a string is palindrome or doesn't
##
## @author Giovanni Panzera <giovannipa04@gmail.com>
## @date 2020/12/14 - 21:00
## @update 2020/12/14 - 21:00
## @license GPLv3
## @version 1.00.000
##

## more info:
## - cat /usr/include/sysexits.h
##
declare -r EX_USAGE=64
declare -r EX_DATAERR=65
declare -r EX_NOINPUT=66
declare -r EX_UNKNOWN=113

declare -r VERSION='1.00.000'
CHECK='false'

##
## @fn ger_err_msg()
## @brief map error_code
##
## @param [in] $1         error message
## @param [in] $2         error code
##
function get_err_msg {
        local code err_msg err_msg_by_code
        if [ -n "$1" ]; then err_msg="$1"; else err_msg="UNKNOWN";   fi
        if [ -n "$2" ]; then code="$2";    else code="$EX_UNKNOWN"; fi
        case "$code" in
            "$EX_USAGE")
                err_msg_by_code="Command line usage error"
                ;;
            "$EX_DATAERR")
                err_msg_by_code="Data format error"
                ;;
            "$EX_NOINPUT")
                err_msg_by_code="Cannot open input"
                ;;
            "$EX_UNKNOWN")
                err_msg_by_code="Unknown error"
                ;;
            *)
                err_msg_by_code="Internal Error"
                ;;
        esac

        echo "$err_msg - $err_msg_by_code"
}

##
## @fn print_version()
## @brief print version of the script
##
function print_version {
    echo "$VERSION"
    exit 0
}

##
## @fn print_usage()
## @brief print usage and some useful information of the script
##
function print_usage {
    echo ""
    echo "Usage: $(basename $0) COMMAND [--version] [--help]"
    echo ""
    echo " COMMAND"
    echo "    check                                          check string"
    echo "       --string=<string>                        string to check"
    echo ""
    echo "    --version, -v                 Returns version of the script"
    echo "    --help, -h                                             Help"
    echo ""
    exit 0
}

##
## @fn print_error()
## @brief print error messages
##
## @param [in] $1         error message
## @param [in] $2         error code
##
## @return error code
##
function print_error {
    local err_msg err_code
    if [ -n "$1" ]; then err_msg="$1";  else err_msg="UNKNOWN";   fi
    if [ -n "$2" ]; then err_code="$2"; else err_code=1; fi
    echo ""
    echo "************************************************************************"
    echo " ERROR [$err_code]: $err_msg"
    echo "************************************************************************"
    echo ""

    return "$err_code"
}

##
## @fn check_commands()
## @brief check if a command exists
##
## @param $1  command to check
##
## @return exit code
##
function check_commands {
    local err_msg exit_code
    if [ "$#" -eq 1 ]; then
        which "$1" >/dev/null; exit_code=$?
        if [ "$exit_code" -ne 0 ]; then err_msg="$1 not found"; fi
    elif [ "$#" -gt 1 ]; then
        for command in "$@"; do
            which "$command" >/dev/null; exit_code=$?
            if [ "$exit_code" -ne 0 ]; then
                err_msg="$command not found"; break;
            fi
        done
    else
        err_msg="${FUNCNAME[0]} must have at least one argument"; exit_code="$EX_USAGE"
    fi

    if [ "$exit_code" -ne 0 ]; then
        print_error "$(get_err_msg "$err_msg in ${FUNCNAME[0]} function" "$exit_code" )" "$exit_code"
    fi

    return "$exit_code"
}

check_commands 'rev' 'sed'; exit_code="$?"
if [ "$exit_code" -ne 0 ]; then
    exit "$exit_code"
fi

if [ "$#" -eq 0 ]; then
    print_usage
else
    for par in "$@"; do
        case "$par" in
            'check')
                CHECK='true'
            ;;
            '--string='*)
                string="${par#*=}"
            ;;
            --version|-v)
                print_version
            ;;
            --help|-h)
                print_usage
            ;;
            *)
                print_error "$(get_err_msg "Invalid parameter $par" "$EX_USAGE" )" "$EX_USAGE"; exit_code=$?
                if [ "$exit_code" -ne 0 ]; then
                    exit "$exit_code"
                fi
            ;;
        esac
    done
fi

if [ "$CHECK" = 'false' ]; then
    exit_code="$EX_USAGE";  err_msg="$(get_err_msg "param check must be passed on the command line." "$EX_USAGE")"
else
    if [ -z "$string" ]; then
        exit_code="$EX_NOINPUT"; err_msg="$(get_err_msg "string param can't be empty." "$EX_NOINPUT")"
    else
        regex='^[a-z ]+$'
        if ! [[ "${string,,}" =~ $regex ]]; then
            exit_code="$EX_DATAERR";  err_msg="$(get_err_msg "$string string contains no valid characters. Only alphabetical characters allowed." "$EX_DATAERR")"
        else
            string_trim=$(sed 's/ //g' <<< "${string,,}")
            string_rev="$(rev <<< "${string_trim,,}")"
            if [ "$string_trim" = "$string_rev" ]; then
                outcome="palindrome"
            else
                outcome="not palindrome"
            fi
        fi
    fi
fi

if [ "$exit_code" -ne 0 ]; then
    print_error "$err_msg" "$exit_code"
else
    echo "----------------------------------------------------------------------"
    echo "$string is $outcome"
    echo "----------------------------------------------------------------------"
fi

exit "$exit_code"
