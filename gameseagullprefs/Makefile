TARGET := iphone:clang:14.4:13.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = gameseagullprefs

gameseagullprefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
gameseagullprefs_FILES = GSPRootListController.m
gameseagullprefs_FRAMEWORKS = UIKit
gameseagullprefs_PRIVATE_FRAMEWORKS = Preferences
gameseagullprefs_INSTALL_PATH = /Library/PreferenceBundles
gameseagullprefs_CFLAGS = -fobjc-arc -Wdeprecated-declarations -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/bundle.mk
