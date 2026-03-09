#! /bin/bash
#
# inspiration links:
# https://gist.github.com/mzabriskie/6631607
# https://gist.github.com/lmj0011/1a8dd1e376234ac7bf0fba2748ecdd0f
# https://gist.github.com/gimbo/f1cc9f5c7a9b5e13dbb007acb0a993d4
# https://github.com/MaxWinterstein/check_git_pullstatus/blob/master/check_git_pullstatus.sh
#

# To fix recurring ssh passphrase questions, use https://askubuntu.com/questions/362280/enter-ssh-passphrase-once
# or similar, not an issue with the script

echo_blue() {
	echo -en "\\033[0;36m"
	echo "$1"
	echo -en "\\033[0m"
}

log_error() {
    echo "!!_!!_ $1 _!!_!!"
}

log_warning() {
    echo "[!] $1"
}

log_success() {
    echo "[*] $1"
}

check_git_repo() {
	clean=0
	repo=$(basename "$1")

	echo_blue "** Checking $repo..."

	inside_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
	if [ ! "$inside_git_repo" ]; then
		echo_blue "----> Not a Git repository"
		return 1
	fi

	# Appending $? assigns the variable to return value, $(command)$?
	#### Only works on already tracked files, not untracked ones
	all_staged=$(git diff-files --quiet --ignore-submodules --)$?
	all_tracked=$(git status | grep 'Untracked' -c)
	all_commited=$(git diff-index --cached --quiet HEAD --ignore-submodules --)$?

	if [ "$all_staged" -ne 0 ]; then
		log_warning "Need to handle unstaged files"
		clean=1
	fi

	if [ "$all_tracked" -ne 0 ]; then
		log_warning "Need to handle untracked files"
		clean=1
	fi

	if [ "$all_commited" -ne 0 ]; then
		log_warning "Need to commit files"
		clean=1
	fi

	# have to convert string output into a list
	git fetch --all &> /dev/null
	remotes=($(git remote))
	if [ ! -z "${remotes[*]}" ]; then
		default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
		default_branch="${default_branch:-main}"
		for remote in "${remotes[@]}"; do
			echo_blue "----> Checking remote ${remote}/${default_branch}..."
			output=$(git log HEAD.."$remote"/"$default_branch" --oneline)
			if [ "$output" != "" ]; then
				log_warning "HEAD is behind ${remote}/${default_branch}, need to pull"
				clean=1
			fi
		done
	else
		log_error "Repository has no remotes"
	fi

	#check push
# TODO: use plumbing git commands not porcelain for info
	if [ "$(git status | grep 'Your branch is ahead' -c)" -ne 0 ]; then
		log_warning "Commits need to be pushed"
		clean=1
	fi

	if [ $clean -eq  0 ]; then
		log_success "Repo is clean, nothing to do"
	fi

}

git_summary() {
	# if check_num_args $# ne 1; then
	# 	log_error "Need a directory argument..."
	# 	exit 1
	# fi
# TODO: this will fail unless you check if greadlink is installed (brew install coreutils), most probably don't have it
	case "${os}" in
		Linux*) dir="$(readlink -fn "$1")";;
		Darwin*) dir="$(greadlink -f "$1")";;
		*) exit 1
	esac

	if [ !  -d "$dir" ]; then
		log_error "Not a directory..."
		exit 1
	fi

	cd "$dir" || exit
	inside_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
	# check if given directory is git, run just there, otherwise recursively
	# --- what should we do if run from inside a git repo directory?
	# ------currently this returns as if its not git
	if [ "$inside_git_repo" ]; then
	# only check this directory
		root_dir="$(git rev-parse --show-toplevel)"

		if [ "$dir" != "$root_dir" ]; then
			echo_blue "Running from $dir for git root directory $root_dir..."
		else
			echo_blue "Running on $dir..."
		fi
		check_git_repo "$root_dir"
	else
	# Recursively check directories in this dir
		echo_blue "Running on directories under $dir..."
		for f in "$dir"/*; do
			# Only run on directories
			[ -d "${f}" ] || continue
			cd "$f" || exit
			check_git_repo "$f"
		done
	fi
}

os=$(uname -s)
echo $os
git_summary "$@"
cowsay " All Done! "
