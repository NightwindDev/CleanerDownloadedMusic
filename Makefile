TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = Music

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CleanerDownloadedMusic

CleanerDownloadedMusic_FILES = Sources/Tweak.S Sources/Tweak.swift
CleanerDownloadedMusic_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
