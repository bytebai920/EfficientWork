#!/bin/bash

source Shells/appIcon_launch_func.sh

#文件名称
fileNameAll="AppIcon.png"
#检测文件是否存在
isExistFile $fileNameAll
#转化成可操作的格式
switchToSRGB
#目标文件夹名称
targetFileDir=./iMac/AppIcon.appiconset
#创建目标文件夹
mkdir -p ${targetFileDir}
#目标文件夹写入json文件
createContentsMac $targetFileDir
#目标文件夹写入图片
setImageMac $targetFileDir $fileNameAll
