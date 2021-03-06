# Copyright 2016-2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.
PYTHONDIR:=/opt/anaconda3/bin
PYTHON:=python3
SHELL:=/bin/bash

python: prep
	@cd "$$(dirname "$(readlink -f "$0")")" || exit 1
	rm -f ec2rl.tgz
	@echo "Creating ec2rl.tgz..."
	@mkdir /tmp/ec2rl
	@cp ec2rl /tmp/ec2rl
	@cp ec2rl.py /tmp/ec2rl
	@cp -r ec2rlcore /tmp/ec2rl
	@cp -r lib /tmp/ec2rl
	@cp -r mod.d /tmp/ec2rl
	@cp -r post.d /tmp/ec2rl
	@cp -r pre.d /tmp/ec2rl
	@cp -r docs /tmp/ec2rl
	@cp -r exampleconfigs /tmp/ec2rl
	@cp -r ssmdocs /tmp/ec2rl
	@cp functions.bash /tmp/ec2rl
	@cp README.md /tmp/ec2rl
	@cp requirements.txt /tmp/ec2rl
	@cp LICENSE /tmp/ec2rl
	@cp NOTICE /tmp/ec2rl
	@tar -czf ec2rl.tgz -C /tmp ec2rl
	@rm -rf /tmp/ec2rl
	@echo "Done!"

binary: prep
	@cd "$$(dirname "$(readlink -f "$0")")" || exit 1
	rm -f ec2rl-binary.tgz
	@$(PYTHONDIR)/$(PYTHON) make_bin_modules.py
	@$(PYTHONDIR)/pyinstaller -y \
	-p lib \
	--add-data "functions.bash:." \
	--add-data "LICENSE:." \
	--add-data "NOTICE:." \
	--add-data "README.md:." \
	--add-data "ec2rlcore/help.yaml:ec2rlcore/" \
	--add-data "bin:bin" \
	--add-data "docs:docs" \
	--add-data "exampleconfigs:exampleconfigs" \
	--add-data "ssmdocs:ssmdocs" \
	--add-data "pre.d:pre.d" \
	--add-data "mod.d:mod.d" \
	--add-data "post.d:post.d" \
	--hidden-import botocore \
	ec2rl.py

	@$(PYTHONDIR)/$(PYTHON) make_symlinks.py

	@# Build the one-directory binary tarball
	@echo "Building tarball, ec2rl-binary.tgz ..."
	@tar -czf ec2rl-binary.tgz -C dist ec2rl
	@echo "Done!"


menuconfig:
	@cd "$$(dirname "$(readlink -f "$0")")" || exit 1
	@if [ -d ec2rlcore/__pycache__/ ] ; then		\
		rm -rf ec2rlcore/__pycache__/;				\
	fi;												\
	if [ -e debug.log ] ; then						\
		rm debug.log;								\
	fi;												\
	./ec2rl menu-config --debug

prep:
	rm -rf dist
	rm -rf build
	rm -f ec2rl.spec
	rm -rf /tmp/ec2rl

clean: prep
	rm -f ec2rl.tgz
	rm -f ec2rl-binary.tgz

all: python binary
