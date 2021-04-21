export HOME=${WORKSPACE}
echo "--------- home set"

# get global vars
[ ! -z "$envfile" ] && source $envfile
[ -z "$PREFIXFNAME" ] && "echo missing param PREFIXFNAME" && exit 3
[ -z "$SRCPATH" -a -z "$srcpath" ] &&  "echo missing param SRCPATH/srcpath ($SRCPATH/$srcpath)" && exit 3

[ -z "$srcpath" ] && srcpath=$SRCPATH
cd $srcpath

SLEEP=1
prebuilts/sdk/tools/jack-admin kill-server || SLEEP=0
jack-admin kill-server || SLEEP=0

# all problematic directories (when switching between android versions)
DELDIRS="device/
kernel/
vendor/lineage
vendor/fdroid
vendor/cm
hardware/qcom/sm8150/
hardware/qcom-caf
vendor/nxp/opensource/sn100x/
vendor/nxp/opensource/pn5xx/
hardware/qcom/Android.mk
"

for deldir in $DELDIRS;do
    [ "$deldir" == "./.repo" ] && echo REPO IN DELDIR && exit 99
    [ "$deldir" == ".repo" ] && echo REPO IN DELDIR && exit 99
    [ "$deldir" == "./user-keys" ] && echo KEYS IN DELDIR && exit 99
    [ "$deldir" == "user-keys" ] && echo KEYS IN DELDIR && exit 99
    [ -d $deldir ] && rm -rvf $deldir
done

# delete the symlink or dir
[ -L out ] && rm out
[ -d out ] && rm -rf out

# clean the real out dir
[ -d  /ssd/${PREFIXFNAME}/out ] && rm -rf  /ssd/${PREFIXFNAME}/out

# create the real out dir
mkdir -p /ssd/${PREFIXFNAME}/out

# symlink out to the real out dir
ln -s /ssd/${PREFIXFNAME}/out out

ls -la out
