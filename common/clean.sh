export HOME=${WORKSPACE}
echo "--------- home set"

# get global vars
[ ! -z "$envfile" ] && source $envfile
[ -z "$PREFIXFNAME" ] && "echo missing param PREFIXFNAME" && exit 3
[ -z "$BDEVICE" ] && "echo missing param BDEVICE" && exit 3
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
packages/apps/Trebuchet
hardware/marvell
frameworks/av
frameworks/native
packages/apps/Updater
system/core
system/sepolicy
build/make
system/security
"

for deldir in $DELDIRS;do
    [ "$deldir" == "./.repo" ] && echo REPO IN DELDIR && exit 99
    [ "$deldir" == ".repo" ] && echo REPO IN DELDIR && exit 99
    [ "$deldir" == "./user-keys" ] && echo KEYS IN DELDIR && exit 99
    [ "$deldir" == "user-keys" ] && echo KEYS IN DELDIR && exit 99
    [ -d $deldir ] && rm -rvf $deldir
done

# known broken links after switching the android version
LINKS="hardware/qcom/Android.mk"
for l in $LINKS; do
    if [ -L $l ];then
        test -e $l || rm -v $l
    fi
done

if [ "$clean_out" == "true" ];then
    # delete the symlink or dir
    [ -L out ] && rm -v out
    [ -d out ] && rm -rf out

    # clean the real out dir
    [ -d  /ssd/${PREFIXFNAME}${BDEVICE}/out ] && rm -rf  /ssd/${PREFIXFNAME}${BDEVICE}/out
else
    find out -name build.prop -delete || true
    find out -name boot.img -delete || true
    find out -name blrecovery.img -delete || true
    echo "skipped full cleaning out/ dir as requested"
fi

# create the real out dir
[ ! -d "/ssd/${PREFIXFNAME}${BDEVICE}/out" ] && mkdir -p /ssd/${PREFIXFNAME}${BDEVICE}/out

# symlink out to the real out dir
[ ! -L out ] && ln -s /ssd/${PREFIXFNAME}${BDEVICE}/out

ls -la | grep out
