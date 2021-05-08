TARGET := iphone:clang:latest:7.0

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = gameseagullprefs

gameseagullprefs_FILES = GSPRootListController.m
gameseagullprefs_FRAMEWORKS = UIKit
gameseagullprefs_PRIVATE_FRAMEWORKS = Preferences
gameseagullprefs_INSTALL_PATH = /Library/PreferenceBundles
gameseagullprefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
