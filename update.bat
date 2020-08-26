
@echo off
echo ================================================
echo == Updating Github repository from IRIS
echo ==
echo ==    exportng IRIS packages
c:\intersystems\iris\bin\iristerm /console=cn_ap:iris C:\DEV\SrcCtrl\runexport.scr DEV C:\DEV\SrcCtrl CTRL
echo ==
echo ==    pushing to github...
c:\git\git-bash gitupdate.sh
echo ==
echo == Finished
echo ==
echo ================================================
