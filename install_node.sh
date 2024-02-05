#!/usr/bin/env zsh

# **************************************************************************** #
#                                                                              #
#                                                   :::      ::::::::          #
#    transetup.sh                                 :+:      :+:    :+:          #
#                                               +:+ +:+         +:+            #
#      NodeJS install script                  +#+  +:+       +#+               #
#      for ft_transcendence                 +#+#+#+#+#+   +#+                  #
#                                                #+#    #+#                    #
#    jkong <jkong@student.42seoul.kr>           ###   ########.seoul.kr        #
#                                                                              #
# **************************************************************************** #

SETUP_DIRECTORY=~/goinfre
SHRC_PATH=~/.zshrc

while getopts 'd:s:f' name
do
	case $name in
		d) SETUP_DIRECTORY=$OPTARG ;;
		s) SHRC_PATH=$OPTARG ;;
		f) INSTALL_NODE_FORCE=1 ;;

		?)
			printf "Usage: %s: [-d SetUpDirectory] [-s ShellRCPath] [-f]" $0
			exit 2
		;;
	esac
done

function distro_name() {
	case $(uname -s) in
		Linux)
			KERNEL_NAME="linux"
			;;
		Darwin)
			KERNEL_NAME="darwin"
			;;
		*)
			echo "Unknown kernel name"
			exit 2
			;;
	esac

	case $(uname -m) in
		x86_64)
			MACHINE_NAME="x64"
			;;
		arm64)
			MACHINE_NAME="arm64"
			;;
		*)
			echo "Unknown machine name"
			exit 2
			;;
	esac

	echo $KERNEL_NAME-$MACHINE_NAME
}

function node_version() {
	curl https://nodejs.org/dist/index.tab 2> /dev/null |
		head -n 2 |
		tail -n 1 |
		while read -r ver _
		do
			echo $ver
		done
}

NODE_VERSION=$(node_version)
NODE_DISTRO=$(distro_name)
NODE_DIST_NAME=node-$NODE_VERSION-$NODE_DISTRO

function validate_node() {
	curl https://nodejs.org/dist/$NODE_VERSION/SHASUMS256.txt | grep $NODE_DIST_NAME.tar.gz | shasum -a 256 -c -
}

function download_node() {
	curl -O https://nodejs.org/dist/$NODE_VERSION/$NODE_DIST_NAME.tar.gz && validate_node
}

function install_node() {
	echo "Install node.js. . ."

	if [ -f $NODE_DIST_NAME.tar.gz ]
	then
		echo "File already exists, so we'll validate it first."
		if validate_node
		then
			echo "The integrity of the file has been verified. Continue."
		else
			echo "An existing file is corrupted. Download the file again."
			if ! download_node
			then
				echo "The file failed to download."
				exit 1
			fi
		fi
	else
		echo "Download a new file."
		if ! download_node
		then
			echo "The file failed to download."
			exit 1
		fi
	fi

	tar -xf $NODE_DIST_NAME.tar.gz
	rm -rf $NODE_DIST_NAME.tar.gz
}

function move_node_cache() {
	mkdir -p $SETUP_DIRECTORY/node_cache
	npm config set cache $SETUP_DIRECTORY/node_cache --global

	echo "Changed the path to the NPM cache directory."
}

function export_node_path() {
	if [ $(uname -s) = "Linux" ]; then
		sed -i '/#Auto-generated-by-42-transcendence-script/d' $SHRC_PATH
	else
		sed -i '' '/#Auto-generated-by-42-transcendence-script/d' $SHRC_PATH
	fi
	# echo 'export PATH="'"$HOME/Applications"'/Visual Studio Code.app/Contents/Resources/app/bin/":$PATH #Auto-generated-by-42-transcendence-script' >> $SHRC_PATH
	echo 'export PATH='"$SETUP_DIRECTORY/$NODE_DIST_NAME/bin"':$PATH #Auto-generated-by-42-transcendence-script' >> $SHRC_PATH

	source $SHRC_PATH

	echo "Exported the PATH environment variable."
}

export_node_path

(
	cd $SETUP_DIRECTORY

	if [ -f .node_installed ]
	then
		if [ -z $INSTALL_NODE_FORCE ]
		then
			echo "You already have a node installed. To force an overwrite and proceed, use the -f option."
			exit 1
		fi
		rm .node_installed
	fi

	install_node

	touch .node_installed
) &&
move_node_cache &&
(
	# npm install -g \
	# 	pnpm \
	# 	@nestjs/cli \
	# ;

	# NextJS
	# pnpm create next-app
	# pnpm run dev

	# NestJS
	# nest new
	# pnpm run start:dev

	# Prisma
	# pnpm install --save-dev prisma
	# npx prisma init

	# TypeScript
	# pnpm install --save-dev typescript ts-node @types/node
	# npx tsc --init
	# npx ts-node

	# ESLint
	# npm init @eslint/config
)
