# Copyright (c) 2019 Ayoume Inc.
# All rights reserved.
#
# "Common Makefile For Golang Project Building" version 1.0
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#    * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#    * Neither the name of Ayoume Inc. nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES_; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ---
# Author:  Zich
# Created: 2019-03-07 10:46:00
# E-mail:  zich@ayoume.com
#
# ---
# Description:
#   The common makefile for building golang project.
#
###############################################################################

.PHONY: \
	all start init build install clean stop docker help \
	alls alls-init alls-execute alls-clean alls-stop \
	preinstall-all preinstall-start preinstall-clean \
	preinstall-init preinstall-execute preinstall-finish \
	apps apps-all apps-start apps-init apps-compile apps-clean apps-finish \
	protos protos-all protos-start protos-init \
	protos-build protos-clean protos-finish \
	releases releases-all releases-start releases-init \
	releases-execute releases-clean releases-clean-all releases-finish \
	tests tests-all tests-start tests-init tests-execute \
	bench-tests cover-tests func-tests tests-clean tests-finish \
	watch stop-watch serve stop-serve \
	monitor stop-monitor commit-init commit stop-commit \
	logs-start logs-backup logs-init logs-clean logs-finish

###############################################################################

override SHELL              := /bin/bash

override EMPTY              :=
override SPACE              := $(EMPTY) $(EMPTY)
override COMMA              := ,

override SYS_BIN_DIR        := $(HOME)/.binary
override SYS_TEMP_DIR       := $(HOME)/.temporary
override GOLANG_ROOT        := $(HOME)/.go
override GOLANG_PATH        := $(HOME)/.go

override CURRENT_DIR        := $(shell pwd)
override BIN_DIR            := bin
override RELEASES_DIR       := releases
override LOGS_DIR           := logs
override SYSTEM             := $(shell uname -s | tr [A-Z] [a-z])
override ORIGINAL_ARCH      := $(shell uname -m | tr [A-Z] [a-z])
override CURRENT_GIT_BRANCH := $(shell git symbolic-ref --short -q HEAD)
override GIT_REPO           := $(shell git remote -v | grep "(fetch)" | awk "{print $$2}")

override define translate_arch
	$(shell \
		if [ "$(1)" = "i386" ]; then \
			echo "386"; \
		elif [ "$(1)" = "x86_64" ]; then \
			echo "amd64"; \
		elif [ "$(1)" = "amd64p32" ]; then \
			echo "amd64p32"; \
		elif [ "$(1)" = "arm" ]; then \
			echo "arm"; \
		elif [ "$(1)" == "arm64" ]; then \
			echo "arm64"; \
		elif [ "$(1)" = "mips" ]; then \
			echo "mips"; \
		elif [ "$(1)" = "mips64" ]; then \
			echo "mips64"; \
		elif [ "$(1)" = "mips64le" ]; then \
			echo "mips64le"; \
		elif [ "$(1)" = "mipsle" ]; then \
			echo "mipsle"; \
		elif [ "$(1)" = "ppc64" ]; then \
			echo "ppc64"; \
		elif [ "$(1)" = "ppc64le" ]; then \
			echo "ppc64le"; \
		elif [ "$(1)" = "s390x" ]; then \
			echo "s390x"; \
		else \
			echo "$(1)"; \
		fi
	)
endef

###############################################################################

APP_NAME           := $(shell basename $(CURRENT_DIR))
ARCH               := $(strip $(call translate_arch,$(ORIGINAL_ARCH)))
GOOSARCHS          := $(SYSTEM)/$(ARCH)
MONITOR_GIT_BRANCH := $(CURRENT_GIT_BRANCH)
MONITOR_INTERVAL   := 1m
COMMIT_INTERVAL    := 5m

###############################################################################

ifdef version
	VERSION := $(version)
endif

ifdef branch
	MONITOR_GIT_BRANCH := $(branch)
endif

ifdef app
	APP_NAME := $(app)
endif

ifdef monitor_interval
	MONITOR_INTERVAL := monitor_interval
endif

ifdef commit_interval
	COMMIT_INTERVAL := commit_interval
endif

ifdef platforms
ifeq ($(platforms),all)
	GOOSARCHS := darwin/amd64    \
                 darwin/386      \
                 linux/amd64     \
                 linux/386       \
                 linux/arm       \
                 linux/arm64     \
                 linux/ppc64     \
                 linux/ppc64le   \
                 linux/mips      \
                 linux/mipsle    \
                 linux/mips64    \
                 linux/mips64le  \
                 linux/s390x     \
                 netbsd/386      \
                 netbsd/amd64    \
                 netbsd/arm      \
                 openbsd/386     \
                 openbsd/amd64   \
                 openbsd/arm     \
                 solaris/amd64   \
                 windows/386     \
                 windows/amd64   \
                 dragonfly/amd64 \
                 freebsd/386     \
                 freebsd/amd64   \
                 freebsd/arm     \
                 #nacl/386       \
                 #nacl/amd64p32  \
                 #nacl/arm       \
                 #plan9/386      \
                 #plan9/amd64    \
                 #plan9/arm
else
	GOOSARCHS := $(shell echo "$(platforms)" | sed -e "s/,/ /g")
endif
endif

###############################################################################

ifeq ($(CURRENT_DIR),$(EMPTY))
$(error CURRENT_DIR not allow to be empty!)
else ifeq ($(CURRENT_DIR),/)
$(error CURRENT_DIR not allow to be root directory!)
endif

ifeq ($(RELEASES_DIR),$(EMPTY))
$(error RELEASES_DIR not allow to be empty!)
else ifeq ($(RELEASES_DIR),/)
$(error RELEASES_DIR not allow to be root directory!)
endif

ifeq ($(BIN_DIR),$(EMPTY))
$(error BIN_DIR not allow to be empty!)
else ifeq ($(BIN_DIR),/)
$(error BIN_DIR not allow to be root directory!)
endif

ifeq ($(LOGS_DIR),$(EMPTY))
$(error LOGS_DIR not allow to be empty!)
else ifeq ($(LOGS_DIR),/)
$(error LOGS_DIR not allow to be root directory!)
endif

###############################################################################

init: apps-init

install: clean build

all: clean init build

build: apps-compile

clean: apps-clean

start: stop logs
	@nohup make monitor 2>&1 >> $(LOGS_DIR)/$(APP_NAME)_monitor.log &
	@nohup make watch 2>&1 >> $(LOGS_DIR)/$(APP_NAME)_watch.log &
	@nohup make commit 2>&1 >> $(LOGS_DIR)/$(APP_NAME)_commit.log &

stop: stop-monitor stop-watch

###############################################################################

alls: preinstall-all protos-all tests-all releases-all apps-all logs-all

alls-init: preinstall-init protos-init tests-init releases-init apps-init \
	logs-init commit-init

alls-execute: preinstall-execute protos-build tests-execute apps-compile \
	releasess-execute logs-backup monitor watch serve commit

alls-clean: preinstall-clean protos-clean tests-clean releases-clean apps-clean logs-clean

alls-stop: stop-watch stop-monitor stop-serve stop-commit

###############################################################################

preinstall-all: preinstall

preinstall: preinstall-start preinstall-clean preinstall-init preinstall-execute preinstall-finish

preinstall-start:
	$(info Starting to make preinstall ...)

preinstall-init:
	$(info Initing preinstall ...)
	@mkdir -p $(SYS_BIN_DIR) $(SYS_TEMP_DIR)
	@echo "Init preinstall finished!"

preinstall-execute:

make:
	@brew install make

go:
	@brew install go

go-env:
	@export GOROOT="/usr/local/Cellar/go/1.11.5/libexec/"
	@export GOPATH=$(HOME)/.go

protobuf:

protoc-gen-go:
	@go get -u github.com/golang/protobuf/protoc-gen-go

fswatch:
	@brew install fswatch

pre-commit:
	@brew install pre-commit

syntax-check:
	@go get -u golang.org/x/lint/golint
	@go get -u github.com/sqs/goreturns
	@go get -u golang.org/x/tools/cmd/goimports

preinstall-clean:
	$(info Cleaning preinstall ...)
	@-rm -rf $(SYS_TEMP_DIR)/*
	@echo "Clean preinstall finished!"

preinstall-finish:
	$(info Make preinstall finished!)

###############################################################################

logs-all: logs

logs: logs-start logs-backup logs-init logs-finish

logs-start:
	$(info Starting to make logs ...)

logs-init:
	$(info Initing logs ...)
	@mkdir -p $(LOGS_DIR)
	@echo "Init logs finished!"

logs-backup:
	$(info Backing up logs ...)
	$(eval backdir := $(shell date "+%Y%m%d%H%M%S"))
	@mkdir -p $(LOGS_DIR)/$(backdir)
	@if [ `ls -l $(LOGS_DIR)/*.log` ]; then \
		@-mv $(LOGS_DIR)/*.log $(LOGS_DIR)/$(backdir)/
	fi
	@echo "Back up logs finished!"

logs-clean:
	$(info Cleaning logs ...)
	@-rm -rf $(LOGS_DIR)/*
	@echo "Clean logs finished!"

logs-finish:
	$(info Make logs finished!)

###############################################################################

apps-all: apps

apps: apps-start apps-clean apps-init apps-compile apps-finish

apps-start:
	$(info Starting to make apps ...)

apps-init: protos
	$(info Initing apps ...)
	@go mod vendor
	@echo "Init apps finished!"

apps-compile: main.go
	$(info Compiling apps ...)
	@echo $(foreach \
		osarch, \
		$(GOOSARCHS), \
		"Compiling $(osarch)/$(APP_NAME) ..."; \
		env \
			GOOS=$(word 1, $(subst /, ,$(osarch))) \
			GOARCH=$(word 2, $(subst /, ,$(osarch))) \
			go build -mod=vendor -o $(BIN_DIR)/$(osarch)/$(APP_NAME) $<; \
		echo "Compile $(osarch)/$(APP_NAME) finished!" \
	)
	@-rm -rf $(CURRENT_DIR)/$(APP_NAME)
	@ln -s $(BIN_DIR)/$(SYSTEM)/$(ARCH)/$(APP_NAME) .
	@echo "Compile apps finished!"

apps-clean:
	$(info Cleaning apps ...)
	@-rm -rf $(BIN_DIR)/*
	@-rm -rf $(CURRENT_DIR)/$(APP_NAME)
	@echo "Clean apps finished!"

apps-finish:
	$(info Make apps finished!)

###############################################################################

serve: stop-serve apps
	$(info Starting "$(APP_NAME)" service ...)
	@$(CURRENT_DIR)/$(APP_NAME) serve &
	@echo "Service $(APP_NAME) started!"

stop-serve:
	$(info Stopping "$(APP_NAME)" service ...)
	$(eval SVRPIDS := $(shell \
		ps aux | \
		egrep "$(CURRENT_DIR)/$(APP_NAME) serve" | \
		egrep -v "e?grep " | \
		awk "{print $$2}" \
	))
	@echo "Killing $(APP_NAME) progresses ..."
	@if [ -z "$(strip $(SVRPIDS))" ]; then \
		echo "No $(APP_NAME) progress to kill!"; \
	else \
		echo "$(SVRPIDS)" | xargs kill -9; \
		echo "$(APP_NAME) progresses $(SVRPIDS) have been killed!"; \
	fi
	@echo "Service \"$(APP_NAME)\" stopped!"

###############################################################################

watch: stop-watch serve
	$(info Starting to watch "$(CURRENT_DIR)" ...)
	@fswatch $(CURRENT_DIR) \
		--exclude=\\.bak \
		--exclude=\\.backup \
		--exclude=\\.md \
		--exclude=\\.txt \
		--exclude=\\.log \
		--exclude=\\.git \
		--exclude=\\.swp \
		--exclude=\\.swx \
		--exclude=\\.dockerignore \
		--exclude=\\.gitignore \
		--exclude=\\.pre-commit-config.yaml \
		--exclude=\\.pre-commit-hooks.yaml \
		--exclude=Makefile \
		--exclude=Dockerfile \
		--exclude=Dockerfile.dev \
		--exclude=Dockerfile.stage \
		--exclude=Dockerfile.prod \
		--exclude=releases/ \
		--exclude=examples/ \
		--exclude=docs/ \
		--exclude=doc.go \
		--exclude=client/ \
		--exclude=bin/ \
		--exclude=log/ \
		--exclude=logs/ \
		--exclude=$(CURRENT_DIR)/$(APP_NAME) \
	| while read file; do \
		file=` \
			echo "$${file}" | \
			egrep -v "$(CURRENT_DIR)/[0-9]+" | \
			egrep -v "$(CURRENT_DIR)/.*\~" \
		`; \
		if [ -n "$${file}" ]; then \
			clear; \
			echo "File \"$${file}\" changed!"; \
			make serve; \
		fi \
	done
	@echo "Watch \"$(CURRENT_DIR)\" exit!"

stop-watch:
	$(info Stopping to watch "$(CURRENT_DIR)" ...)
	$(eval WATCHPIDS := $(shell \
		ps aux | \
		egrep "fswatch $(CURRENT_DIR)" | \
		egrep -v "e?grep fswatch $(CURRENT_DIR)" | \
		egrep -v "e?grep --color=auto fswatch $(CURRENT_DIR)" | \
		awk "{print $$2}" \
	))
	@echo "Killing watch \"$(CURRENT_DIR)\" progresses ..."
	@if [ -z "$(strip $(WATCHPIDS))" ]; then \
		echo "No watch progress to kill!"; \
	else \
		echo "$(WATCHPIDS)" | xargs kill -9; \
		echo "Watch \"$(CURRENT_DIR)\" progresses $(WATCHPIDS) have been killed!"; \
	fi
	@echo "Watch \"$(CURRENT_DIR)\" stopped!"

###############################################################################

monitor: stop-monitor
	$(info Monitorring git branch \"$(MONITOR_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" ...)
	@while true; do \
		echo "Pulling git branch \"$(MONITOR_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" ..."; \
		git pull origin $(MONITOR_GIT_BRANCH); \
		echo "Pull git branch \"$(MONITOR_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" finished!"; \
		sleep $(MONITOR_INTERVAL); \
	done
	@echo "Monitor git branch \"$(MONITOR_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" exit!"

stop-monitor:
	$(info Stopping to monitor git branch "$(MONITOR_GIT_BRANCH)" of repo \"$(GIT_REPO)\" ...)
	$(eval MONITORPIDS := $(shell \
		ps aux | \
		egrep "while true; do" | \
		egrep "git pull origin $(MONITOR_GIT_BRANCH)" | \
		egrep -v "e?grep while true; do" | \
		egrep -v "e?grep --color=auto while true; do" | \
		egrep -v "e?grep git pull origin $(MONITOR_GIT_BRANCH)" | \
		egrep -v "e?grep --color=auto git pull origin $(MONITOR_GIT_BRANCH)" | \
		awk "{print $$2}" \
	))
	@echo "Killing monitor git branch \"$(MONITOR_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" progresses ..."
	@if [ -z "$(strip $(MONITORPIDS))" ]; then \
		echo "No monitor progress to kill!"; \
	else \
		echo "$(MONITORPIDS)" | xargs kill -9; \
		echo "Monitor git branch \"$(MONITOR_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" progresses $(MONITORPIDS) have been killed!"; \
	fi
	@echo "Monitor git branch \"$(MONITOR_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" stopped!"

###############################################################################

commit-init:
	$(info Initting commit git branch \"$(CURRENT_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" ...)
	@pre-commit install
	@pre-commit install --hook-type pre-push
	@echo "Init commit git branch \"$(CURRENT_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" exit!"

commit: stop-commit commit-init
	$(info Prepare to Commit git branch \"$(CURRENT_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" ...)
	@while true; do \
		echo "Committing git branch \"$(CURRENT_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" ..."; \
		git add --all; \
		$(eval files := $(shell git diff --name-only --cached)); \
		if [ -z "$(files)" ]; then \
			echo "No file to commit!"; \
		else \
			git commit -m "[SCHEDULE] Update files: $(subst $(SPACE),$(COMMA),$(files))." && \
			git push origin $(CURRENT_GIT_BRANCH); \
			echo "Commit git branch \"$(CURRENT_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" finished!"; \
		fi \
		sleep $(COMMIT_INTERVAL); \
	done
	@echo "Commit git branch \"$(CURRENT_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" exit!"

stop-commit:
	$(info Stopping to commit git branch "$(CURRENT_GIT_BRANCH)" of repo \"$(GIT_REPO)\" ...)
	$(eval COMMITPIDS := $(shell \
		ps aux | \
		egrep "while true; do" | \
		egrep "git add --all" | \
		egrep -v "e?grep while true; do" | \
		egrep -v "e?grep --color=auto while true; do" | \
		egrep -v "e?grep git add --all" | \
		egrep -v "e?grep --color=auto git add --all" | \
		awk "{print $$2}" \
	))
	@echo "Killing commit git branch \"$(CURRENT_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" progresses ..."
	@if [ -z "$(strip $(COMMITPIDS))" ]; then \
		echo "No commit progress to kill!"; \
	else \
		echo "$(COMMITPIDS)" | xargs kill -9; \
		echo "Commit git branch \"$(CURRENT_GIT_BRANCH)\" progresses $(COMMITPIDS) have been killed!"; \
	fi
	@echo "Commit git branch \"$(CURRENT_GIT_BRANCH)\" of repo \"$(GIT_REPO)\" stopped!"

###############################################################################

protos-all: protos

protos: protos-start protos-clean protos-init protos-build protos-finish

protos-start:
	$(info Starting to make protos ...)

protos-init:
	$(info Initting protos ...)
	# TODO
	@echo "Init protos finished!"

protos-build:
	$(info Building protos ...)
	@cd protos && make && make install && cd -
	@echo "Build protos finished!"

protos-clean:
	$(info Cleaning protos ...)
	@cd protos && make clean && cd -
	@echo "Clean protos finished!"

protos-finish:
	$(info Make protos finished!)

###############################################################################

releases-all: releases

releases: releases-start releases-clean releases-init releases-execute releases-finish

releases-start:
	$(info Starting to make releases ...)

releases-init:
	$(info Initting releases ...)
ifndef VERSION
	$(error [ERROR] Please add version=<some-version> to command line, Example: "make version=v1.0.0 releases")
endif
	@mkdir -p $(RELEASES_DIR)/$(VERSION)
	@-rm -rf $(RELEASES_DIR)/$(VERSION)/*
	@echo "Init releases finished!"

releases-execute: releases-init
	$(info Executing releases ...)
	@echo $(foreach \
		osarch, \
		$(GOOSARCHS), \
		"Releasing $(osarch)/$(APP_NAME) ..."; \
		echo "Tarring ..."; \
		tar -cvzf \
			$(RELEASES_DIR)/$(VERSION)/$(APP_NAME)-$(subst /,-,$(osarch))-release-$(VERSION).tar.gz \
			$(BIN_DIR)/$(osarch)/$(APP_NAME); \
		echo "Zipping ..."; \
		zip \
			$(RELEASES_DIR)/$(VERSION)/$(APP_NAME)-$(subst /,-,$(osarch))-release-$(VERSION).zip \
			$(BIN_DIR)/$(osarch)/$(APP_NAME); \
		echo "Release $(osarch)/$(APP_NAME) finished!g" \
	)
	@echo "Execute releases finished!"

releases-clean: releases-init
	$(info Cleaning releases ...)
	@-rm -rf $(RELEASES_DIR)/$(VERSION)
	@echo "Clean releases finished!"

releases-clean-all:
	$(info Cleaning all versions of releases ...)
	@-rm -rf $(RELEASES_DIR)/*
	@echo "Clean all versions of releases finished!"

releases-finish:
	$(info Make releases finished!)

###############################################################################

tests-all: tests

tests: tests-start tests-clean tests-init tests-execute tests-finish

tests-start:
	$(info Starting to make tests ...)

tests-init:
	$(info Initting tests ...)
	# TODO
	@echo "Init tests finished!"

tests-execute: func-tests bench-tests cover-tests

func-tests:
	$(info Executing func tests ...)
	@go test -v ".*"
	@echo "Execute func tests finished!"

bench-tests:
	$(info Executing bench tests ...)
	@go test -test.bench=".*"
	@echo "Execute bench tests finished!"

cover-tests:
	$(info Executing cover tests ...)
	@go test -cover ".*"
	@echo "Execute cover tests finished!"

tests-clean:
	$(info Cleaning tests ...)
	# TODO
	@echo "Clean tests finished!"

tests-finish:
	$(info Make tests finished!)

###############################################################################

docker:
	@make apps platforms=linux/amd64

###############################################################################

help:
	$(info Available Targets:)
	@cat $(MAKEFILE_LIST) | \
		egrep -v ":=" | \
		egrep -v "^(\t+| +)" | \
		egrep -o "^.+:" | \
		egrep -v "^(#|\.)" | \
		sed -e "s/://g" -e "s/^/    /g"
