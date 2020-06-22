#!/usr/bin/env bash
set -o errexit #abort if any command fails
me=$(basename "$0")

help_message="\
Usage:
  $me --branch <branch-name> [--remote] [--verbose]
  $me --help

Arguments:
  -h, --help                    Displays this help screen.
  -b, --branch <branch-name>    The name of the branch to verify.
  -r, --remote                  Verifies that the branch also exists in the
                                remote 'origin'.
  -v, --verbose                 Increase verbosity. Useful for debugging."

parse_args() {
    while : ; do
        if [[ $1 = "-h" || $1 = "--help" ]]; then
            echo "$help_message"
            return 0
        elif [[ ( $1 = "-b" || $1 = "--branch" ) && -n $2 ]]; then
            branch_name=$2
            shift 2
        elif [[ ( $1 = "-r" || $1 = "--remote" ) && -n $2 ]]; then
            verify_remote=true
            shift
        elif [[ $1 = "-v" || $1 = "--verbose" ]]; then
            verbose=true
            shift
        else
            break
        fi
    done

    if [[ -z "$branch_name" ]]; then
        echo "Missing required argument: --branch <branch-name>."
        echo "$help_message"
        return 1
    fi
}

#echo expanded commands as they are executed (for debugging)
enable_expanded_output() {
    if [ $verbose ]; then
        set -o xtrace
        set +o verbose
    fi
}

main() {
    parse_args "$@"

    enable_expanded_output

    current_ref=$(git rev-parse --abbrev-ref HEAD)

    if [[ $current_ref == "HEAD" ]]; then
        current_ref=$(git rev-parse --verify HEAD)
    fi

    git checkout "$branch_name"
    
    [ $verbose ] && ls -la
    
    if [[ ! -f index.html ]]; then
        echo "No 'index.html' file found. Aborting." 1>&2
        exit 1
    fi

    git checkout --force "$current_ref"

    if [ $verify_remote ]; then
        matching_remote_branches=$(git ls-remote --heads origin "$branch_name" | wc -l | xargs)
        if [ "$matching_remote_branches" -gt 0 ]; then
            [ $verbose ] && echo "$branch_name successfully found in remote 'origin'."
        else
            echo "$branch_name not found in remote 'origin'." 1>&2
            exit 1
        fi
    fi
}

main "$@"
