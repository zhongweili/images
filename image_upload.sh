#!/bin/bash

#定义常量
git_repo="git@github.com:zhongweili/images.git"
git_path=/Users/$(whoami)/sub
repo_name="images"
github_prefix="https://raw.githubusercontent.com/zhongweili/images/master"
cur_date=$(date +"%Y%m%d")
folder=/Users/$(whoami)/Desktop/
#{query}是alfred workflowy的参数
filename=`echo "{query}" | tr 'A-Z' 'a-z' | tr -s ' ' | tr ' ' '_'`_`date +%s`.png
path=$folder$filename
#截屏
screencapture -i $path
while [ ! -f $path ]
do
sleep 1
done
width=`/usr/bin/osascript << EOT
tell application "System Events"
        activate
        set theWidth to (display dialog "Enter the width" default answer "650")
end tell
set theWidth to the text returned of theWidth as integer
return theWidth
EOT`
while [ -z "$width" ]
do
sleep 1
done
#使用imageMagick的convert方法
convert $path -resize "`echo $width`x>" $path

if [  ! -d "$git_path/$repo_name/.git" ]
then
    cd $git_path  
    git clone --quiet $git_repo  
fi
cd "$git_path/$repo_name" && \
ls   | grep -v $cur_date | xargs rm -rf &&\

if [ -f "$git_path/$repo_name/$cur_date/$filename" ]
then 
    echo "$github_prefix/$cur_date/$filename"
    exit 0
fi
#按日期建立文件夹
mkdir -p $git_path/$repo_name/$cur_date
cp $path $git_path/$repo_name/$cur_date
cd $git_path/$repo_name && \
git add  "$cur_date" > /dev/null  &&\
git commit  -m "$cur_date $filename" >/dev/null  &&\
git push --quiet origin master  &&\
#输出结果到剪切板
result="$github_prefix/$cur_date/$filename"
echo \![{query}]\($result\) | pbcopy
#删除桌面文件
rm $path
