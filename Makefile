#
# Copyright (C) 2021 ZeakyX
#

include $(TOPDIR)/rules.mk

PKG_NAME:=SpeedtestGo
PKG_VERSION:=1.1.4
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/librespeed/speedtest-go.git
PKG_SOURCE_VERSION:=158e37d3ae14b971f3fe03f26164e93bbfaa5f5e
PKG_MIRROR_HASH:=63043004750197c501258aac93aaac8b8dcfd96f8ac0bf7a9689c077badbe542

PKG_LICENSE:=LGPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:= \
	CONFIG_SPEEDTEST_GO_COMPRESS_GOPROXY \
	CONFIG_SPEEDTEST_GO_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/librespeed/speedtest-go
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=main.Version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=SpeedtestGo is a Go backend for LibreSpeed
	URL:=https://github.com/librespeed/speedtest-go
	DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/$(PKG_NAME)/description
SpeedtestGo is a Go backend for LibreSpeed
endef

define Package/$(PKG_NAME)/config
config SPEEDTEST_GO_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config SPEEDTEST_GO_COMPRESS_UPX
	bool "Compress executable files with UPX"
	default y
endef

ifeq ($(CONFIG_SPEEDTEST_GO_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_SPEEDTEST_GO_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/SpeedtestGo
endif
endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/SpeedtestGo $(1)/usr/bin/$(PKG_NAME)
endef

$(eval $(call GoBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
