TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = GameSeagullPrefs

GameSeagullPrefs_FILES = GSPRootListController.m ../Utils.m
GameSeagullPrefs_FRAMEWORKS = UIKit CoreServices
GameSeagullPrefs_PRIVATE_FRAMEWORKS = Preferences
GameSeagullPrefs_INSTALL_PATH = /Library/PreferenceBundles
GameSeagullPrefs_CFLAGS = -fobjc-arc
GameSeagullPrefs_LIBRARIES = substrate

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
GameSeagullPrefs_CFLAGS += -DROOTLESS
endif

include $(THEOS_MAKE_PATH)/bundle.mk
