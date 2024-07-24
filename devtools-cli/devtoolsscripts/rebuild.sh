#!/bin/bash

###########################################
# Dev Tools Rebuild Scripts
# Always meant to be called from within the
# `devtools` script - not standalone
#
# Rebuild individual websites and satis
#
# E.g. `devtools rebuild ...`
###########################################
source "$SCRIPTPATH/devtoolsscripts/usage/rebuild.sh"

check_homebrew()
{
	brew_enabled=$(which brew)

	if [[ -n $brew_enabled ]]; then
		info "Brew is installed at ${brew_enabled}"
	else
		info "Brew is not installed"
		notify "Installing brew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		success "Brew installed"
	fi
}

switchphp () {
    installedVersion=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
    findVersion=$(brew list | grep php@${1})

    if [[ -z ${findVersion} ]]; then
        notify "PHP ${1} is not installed"
        brew install php@${1}
        brew services restart php
		success "Installed PHP ${1}"
    fi

    if (( $(echo "${1} != ${installedVersion}" | bc -l) )); then
	    notify "Switching from PHP ${installedVersion} to PHP ${1}"
	    brew unlink php@${installedVersion} && brew link --overwrite php@${1}
	    success "Switched to PHP ${1}"
    fi

	info "PHP ${1} is installed"
}

switchphp82 () {
	switchphp 8.2
}

gowebsitesconsole () {
	cd ~/code/websites-console
}

wcrebuild () {
	local FORSLUG=""
	case $1 in
		"dev")
			php di dealer:rebuild-dev --slug=${2}
			local FORSLUG="for $2"
			;;
		"prod")
			php di dealer:rebuild-prod --slug=${2}
			local FORSLUG="for $2"
			;;
		"satis")
			php di satis:rebuild
			;;
		\?)
			error "Invalid wcrebuild argument"
			exit 1
			;;
	esac
}
handlerebuildreturn () {
	if [ $? -ne 0 ] || [[ $1 == *throw* ]] || [[ $1 == *lock* ]]; then
		printf "$1\n"
		error "Something went wrong with the rebuild\n"
		exit 1
	fi

	if [[ $1 == Prod* ]]; then
		# it's a prod rebuild
		success "$1"
		local BAMBOOLINK="https://bamboo.dealerinspire.com/browse/WPP-PROD"
		notify "Opening PROD Bamboo summmary link"
	elif [[ $1 == Array* ]]; then
		# it's a dev rebuild
		success "DEV build started for $2"
		local BAMBOONUM="$(echo "$1" | sed '4!d' | sed 's/[^0-9]//g')"
		local BAMBOOLINK="https://bamboo.dealerinspire.com/browse/DI-DSR-$BAMBOONUM"
		notify "\nOpening DEV Bamboo job link"
		
	else
		success "Satis build started"
		notify "\nOpening Satis Bamboo summmary link"
		local BAMBOOLINK="https://bamboo.dealerinspire.com/browse/DI-DDCPR"
	fi

	info "$BAMBOOLINK\n"
	sleep 1
	open $BAMBOOLINK
}

rebuild-dev () {
	notify "Rebuilding ${1} development site"
	check_homebrew
	gowebsitesconsole
	switchphp82
	local WCREBUILD=$(wcrebuild "dev" "$1")
	handlerebuildreturn "$WCREBUILD" "$1"
	cd - > /dev/null
}

rebuild-prod () {
	notify "Rebuilding ${1} production site"
	check_homebrew
	gowebsitesconsole
	switchphp82
	local WCREBUILD=$(wcrebuild "prod" "$1")
	handlerebuildreturn "$WCREBUILD" "$1"
	cd - > /dev/null
}

rebuild-satis () {
	notify "Rebuilding satis"
	check_homebrew
	gowebsitesconsole
	switchphp82
	local WCREBUILD=$(wcrebuild "satis")
	handlerebuildreturn "$WCREBUILD"
	cd - > /dev/null
}

devtools_rebuild()
{
	COMMAND="$(basename "$1")"
    local HGCOMMAND=$2
    shift

	local PRODUCTION=0
	local SATIS=0
	local CURRENT=0
	while getopts ":hclps" opt; do
		case ${opt} in
			h)
				devtools_rebuild_usage
				exit 0
				;;
			[cl])
				local CURRENT=1
				;;
			p)
				local PRODUCTION=1
				;;
			s)
				local SATIS=1
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
      			;;
		esac
	done

	shift $((OPTIND -1))

	if [ "${CURRENT}" -eq 1 ]; then
		local CURRENTSITE=$(devtools hg which)
		set -- "${1:-$CURRENTSITE}"
	fi

	if [ "${SATIS}" -eq 1 ]; then
		rebuild-satis
	elif [[ -z "${1}" ]]; then
		devtools_rebuild_usage && exit;
	elif [ "${PRODUCTION}" -eq 1 ]; then
		rebuild-prod $1
	else
		rebuild-dev $1
	fi
}