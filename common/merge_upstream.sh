export HOME=${WORKSPACE}
echo "--------- home set"

# enforce that we do not write history
unset HISTFILE

cp /home/jenkins/.gitconfig "${WORKSPACE}/"
if [ ! -d "$HOME/.ssh" ];then
	mkdir -p "$HOME/.ssh"
fi
cp /home/jenkins/.ssh/github_jenkins_ed25519 "${HOME}/.ssh/"
cp /home/jenkins/.ssh/config "${HOME}/.ssh/"
    
REPOONLY=$repo_name_no_path
BSRC=$local_base_directory

LBRANCH=$my_branch
UBRANCH=$upstream_branch

TSRC=$BSRC/$REPOONLY
TURL="git@github.com:SHRP/${REPOONLY}.git"
UPSTREAM="git@github.com:SHRP/${REPOONLY}.git"

if [ -d $TSRC ];then
	cd $TSRC
    git reset --hard
	git checkout $LBRANCH
    git pull origin $LBRANCH
else
	mkdir -p $TSRC || echo dir already created
	cd $BSRC
	git clone $TURL
    cd $TSRC
    git checkout $LBRANCH  || (git checkout $UBRANCH && git branch ${LBRANCH} && git checkout $LBRANCH)
fi


##############################################################################
# https://github.com/pursonchen/sync-fork/blob/master/sync-local-upstream.sh: 
##############################################################################
 
function sync_fork() {

#Check if the local repository exists upstream.
#If it exists, it is in direct sync.
#If not, add upstream to fork.
my_remote_repository=$(git remote -v)
echo $my_remote_repository
if [[ $my_remote_repository =~ "upstream" ]]
then
   sync_source
else
   git remote add upstream $UPSTREAM
   sync_source
fi
}

#Syncing a Fork with the main repository
function sync_source() {
   #current_branch=$(git rev-parse --abbrev-ref HEAD)
  
   git fetch upstream
   git checkout $LBRANCH
   git merge upstream/$UBRANCH
   git push origin $LBRANCH
   git checkout $LBRANCH
}

sync_fork
