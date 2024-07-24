# Pull ALL THE REPOS

DEV=~
PARALLEL=4

pull_all_repos() {
echo -e "Finding all mercurial repositories and pulling $PARALLEL at a time"
(find $DEV -type d -name .hg | (xargs -I_dir -P $PARALLEL -- sh -c 'cd "_dir" && pwd && hg pull -u || :') && echo -e "\033[0;32mALL THE Mercurial REPOSITORIES have been pulled.\033[0m") || (echo -e "\033[0;31mThere was an error!\033[0m")
echo -e "Finding all git repositories and pulling $PARALLEL at a time"
(find $DEV -type d -name .git | (xargs -I_dir -P $PARALLEL -- sh -c 'cd "_dir/.." && pwd && git pull || :') && echo -e "\033[0;32mALL THE GIT REPOSITORIES have been pulled.\033[0m") || (echo -e "\033[0;31mThere was an error!\033[0m")
    $SHELL
}
update_all_repos() {
echo -e "Finding all mercurial repositories and updating $PARALLEL at a time"
(find $DEV -type d -name .hg | (xargs -I_dir -P $PARALLEL -- sh -c 'cd "_dir" && hg update -C && hg pull;') && echo -e "\033[0;32mALL THE REPOSITORIES have been updated.\033[0m") || (echo -e "\033[0;31mThere was an error!\033[0m")
echo -e "Finding all git repositories and pulling $PARALLEL at a time"
(find $DEV -type d -name .git | (xargs -I_dir -P $PARALLEL -- sh -c 'cd "_dir/.." && pwd && git pull || :') && echo -e "\033[0;32mALL THE GIT REPOSITORIES have been pulled.\033[0m") || (echo -e "\033[0;31mThere was an error!\033[0m")
    echo -e "Update all repos"
    $SHELL
}
collect_input_pull() {
        prompt="$1"
        echo -e "\033[0;33m$prompt"
        echo -e "\033[0;33mYes (y) or No (n)?"
        echo -en "\033[0m"
    while true; do
        read -p "" yn
            case $yn in
                Y|y ) pull_all_repos;;
                N|n ) exit;;
                *   ) echo -e -n "\033[0;31mPlease answer yes (y) or no (n).\033[0m";;
            esac
    done
}
collect_input_update() {
        prompt="$1"
        echo -e "\033[0;33m$prompt"
        echo -e "\033[0;33mYes (y) or No (n)?"
        echo -en "\033[0m"
    while true; do
        read -p "" yn
            case $yn in
                Y|y ) update_all_repos;;
                N|n ) exit;;
                *   ) echo -e -n "\033[0;31mPlease answer yes (y) or no (n).\033[0m";;
            esac
    done
}
if [[ $1 == "-c" ]]; then
    collect_input_update "Running this script will wipe out any uncommitted changes. Please check your changes first. Do you want to run this?"
else
    collect_input_pull "This script will only do hg pull -u on all Repositories. This may cause merge conflicts if you recently worked on that repo.  Do you want to run this?"
fi
