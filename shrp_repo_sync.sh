# enforce that we do not write history
unset HISTFILE

export HOME=${WORKSPACE}
echo "--------- home set"

# enforce that we do not write history
unset HISTFILE

SRCPATH=/home/androidsource/do-not-touch/shrp

RECOVERYREPOINIT="git://github.com/SHRP/platform_manifest_twrp_omni.git"

cp /home/jenkins/.gitconfig ${WORKSPACE}/

# clean up manifest xmls which changes a lot between branches and so can 
# produce conflicts like: 
# error.GitError: manifests rev-list ('^db00adfe201b50d63423f25746da3debbab48174', 'HEAD', '--'): fatal: bad revision 'HEAD'
cd ${SRCPATH}
rm -Rfv .repo/manifests kernel/
[ -d ${SRCPATH}/.repo/local_manifests ] && rm -rf ${SRCPATH}/.repo/local_manifests

case $twrpversion in
	gtexslte)
    	SRCPATH=/home/androidsource/do-not-touch/gtexslte_recovery
        TWRPXML=omni-default.xml
        androidbranch="cm-14.1"
		    DTBRANCH="cm-14.1_recovery"
        DTPATH=${SRCPATH}/device/samsung/gtexslte
        DTURI=https://github.com/smt285/device_samsung_gtexslte.git
        KERNPATH=kernel/samsung/gtexslte
        
        cd ${SRCPATH}
        
        [ -d ${SRCPATH}/.repo/local_manifests ] && rm -rf ${SRCPATH}/.repo/local_manifests
        git clone git@github.com:smt285/local_manifests.git -b lineage-14.1_shrp ${SRCPATH}/.repo/local_manifests
        
        repo init -u git://github.com/LineageOS/android.git -b cm-14.1
        
        ;;
    g4)
        TWRPXML=default.xml
        androidbranch="android-9.0_shrp"
        DTBRANCH="${androidbranch}"
        DTPATH=${SRCPATH}/device/lge/g4
        DTURI=https://github.com/steadfasterX/android_device_lge_g4.git
        KERNPATH=kernel/lge/g4
        KERNGIT=https://github.com/LGgFour/kernel_lge_msm8992.git
        KERNBRANCH=android-9.0
        
        [ -d ${SRCPATH}/device/lge/g4 ] && rm -rf ${SRCPATH}/device/lge/g4
        git clone https://github.com/steadfasterX/android_device_lge_g4.git -b ${androidbranch} ${SRCPATH}/device/lge/g4
        
        # init SHRP manifest
        repo init -u $RECOVERYREPOINIT -b v3_9.0
		;;
    fajita)
        TWRPXML=default.xml
        androidbranch="android-9.0"
        DTBRANCH="${androidbranch}_shrp"
        DTPATH=${SRCPATH}/device/oneplus/fajita
        DTURI=git@github.com:sfX-Android/android_device_oneplus_fajita_recovery.git
        KERNPATH=kernel/oneplus/fajita
        
        git clone git@github.com:sfX-Android/android_local_manifests_fajita.git -b ${androidbranch}_shrp ${SRCPATH}/.repo/local_manifests
        
        # init SHRP manifest
        repo init -u $RECOVERYREPOINIT -b v3_9.0
        ;;
    hotdog)
        TWRPXML=default.xml
        androidbranch="android-10"
        DTBRANCH="${androidbranch}_shrp"
        DTPATH=${SRCPATH}/device/oneplus/hotdog
        DTURI=git@github.com:sfX-android/android_device_oneplus_hotdog.git
        KERNPATH=kernel/oneplus/hotdog
        
        git clone git@github.com:sfX-android/android_local_manifests_hotdog.git -b ${androidbranch}.0_shrp ${SRCPATH}/.repo/local_manifests
        
        # init SHRP manifest
        repo init -u $RECOVERYREPOINIT -b v3_10.0
        ;;
    j5y17lte)
        TWRPXML=default.xml
        androidbranch="android-9.0"
        DTBRANCH="android-9.0_shrp"
        DTPATH=${SRCPATH}/device/samsung/j5y17lte
        DTURI=ssh://gitea@code.binbash.rocks:22227/MVA-VoLTE/android_device_samsung_j5y17lte.git
        KERNPATH=kernel/samsung/exynos7870
        
        # init SHRP manifest
        repo init -u $RECOVERYREPOINIT -b v3_9.0
    	  ;;
	  *)
        echo "NO (valid) twrpversion variable set ($twrpversion)!!!!"
        false
    ;;
esac


# complete clean sources
SRCDIRS="./sdk ./device ./vendor ./doc ./pdk ./compatibility ./art ./system ./platform_testing ./bootable ./external ./cts ./bionic ./frameworks ./toolchain ./lineage ./colors ./autoload ./build ./libcore ./dalvik ./android ./developers ./development ./packages ./tools ./syntax ./plugin ./libnativehelper ./hardware ./prebuilts"
#SRCDIRS=skip

if [ "$SRCDIRS" != "skip" ];then
	for deldir in $SRCDIRS;do
    	[ "$deldir" == "./.repo" ] && echo REPO IN DELDIR && exit 99
    	[ "$deldir" == ".repo" ] && echo REPO IN DELDIR && exit 99
    	[ "$deldir" == "./user-keys" ] && echo KEYS IN DELDIR && exit 99
    	[ "$deldir" == "user-keys" ] && echo KEYS IN DELDIR && exit 99
    	[ -d $deldir ] && rm -rf $deldir
	done
fi

#sed -i "s#<project.*path=\"bootable/recovery\".*#<project path=\"bootable/recovery\" name=\"android_bootable_recovery\"  remote=\"omnirom\" revision=\"$twrpbranch\" groups=\"pdk-cw-fs\" />#g" .repo/manifests/$TWRPXML
#cp $SRCPATH/.repo/local_manifests/remove-twrp-v1.xml.orig $SRCPATH/.repo/local_manifests/remove-twrp-v1.xml

#case $twrpversion in
#	datamedia)
#    cp $SRCPATH/.repo/local_manifests/set-twrp-version-datamedia.xml.orig $SRCPATH/.repo/local_manifests/set-twrp-version.xml
#    ;;
#    *)
#    cp $SRCPATH/.repo/local_manifests/set-twrp-version.xml.orig $SRCPATH/.repo/local_manifests/set-twrp-version.xml
#    ;;
#esac
 
repo sync -c -j20 --force-sync --no-tags --no-clone-bundle

# clone the device tree FRESH
[ -d $DTPATH ] && rm -rf $DTPATH
git clone $DTURI $DTPATH -b $DTBRANCH

[ ! -z $KERNGIT ] && git clone --depth 1 $KERNGIT $KERNPATH -b $KERNBRANCH

case $twrpversion in
	g4)
    	sed -i 's#<linux/msm_mdp.h>#"../../../hardware/qcom/msm8994/kernel-headers/linux/msm_mdp.h"#g' bootable/recovery/minui/graphics_overlay.cpp
    	sed -i 's#<linux/msm_ion.h>#"../../../hardware/qcom/msm8994/kernel-headers/linux/msm_ion.h"#g' bootable/recovery/minui/graphics_overlay.cpp
    ;;
	gtexslte)
      # can a hack be more dirty? pff anyways.. the gtexslte is such a big mess that this shit does not matter at all ..
      # why not removing it in shrp_build? bc its easier to keep updated on shrp this way.
      rm -rf $SRCPATH/build/make/target $SRCPATH/build/make/tools $SRCPATH/build/make/tests $SRCPATH/build/make/core
      #for del in $(find $SRCPATH/build/make/ -maxdepth 1 | egrep -v "\.git|shrp");do
      #	rm -rf $del
      #done
    
      # apply special patches
      if [ "$SRCDIRS" != "skip" ];then
        #build/ is special check manifest: cd build && patch -p1 < $SRCPATH/external/android_patches/android_build.patch
        cd $SRCPATH; cd bionic && patch -p1 < $SRCPATH/external/android_patches/android_bionic.patch
        cd $SRCPATH; cd frameworks/av && patch -p1 < $SRCPATH/external/android_patches/frameworks_av.patch
        cd $SRCPATH; cd frameworks/native && patch -p1 < $SRCPATH/external/android_patches/frameworks_native.patch
        cd $SRCPATH; cd system/core && patch -p1 < $SRCPATH/external/android_patches/system_core.patch
        # we build ENG so this is useless for recovery: cd $SRCPATH; patch -p1 < $SRCPATH/external/android_patches/system_sepolicy.patch
        cd $SRCPATH
        #DO NOT USE before fixing BT: cd hardware/libhardware && patch -p1 < external/android_patches/hardware_libhardware.patch && cd $SRCPATH
      fi  
    ;;
    j5y17lte)
    	[ -d "$KERNPATH" ] && rm -rvf $KERNPATH
        git clone ssh://gitea@code.binbash.rocks:22227/MVA-VoLTE/android_kernel_samsung_exynos7870.git -b android-10.0_permissive $KERNPATH
    ;;
esac
