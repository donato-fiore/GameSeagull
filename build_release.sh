rm -rf build
mkdir build

make clean
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=
cp -p "`ls -dtr1 packages/* | tail -1`" ./build/

make clean
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
cp -p "`ls -dtr1 packages/* | tail -1`" ./build/
