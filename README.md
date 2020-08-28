# SrcCtrl
Utility that will export code from an IRIS Namespace to a folder on the server. Including the ability to commit to a git repository

## Installation

To Install this in your IRIS instance just import ` /src/CTRL.xml `. This includes the Installer which will compile and setup %ALL Namespace.

### notes on usage

In order to use this utility: 
* If the code is not yet in a Git Repository then create an empty repoository first.  
  * On the IRIS server perform a **git clone** to a local folder.  
  * You do not need to store credentials - the routine will prompt for git user and passwd. If you wish to store credentials then you can follow article: <a href="https://www.shellhacks.com/git-config-username-password-store-credentials" target="_blank">Git Config Username & Password</a>  
  * If you wish to only run on a signle Namespace:
Import/compile the class and routine files `/src/CTRL/*` into you IRIS instance - **SKIP THe Installer.cls**.

## Routine run export AND Git commit

Start a terminal, change to the relevant Namespace...

```
USER> do ^CTRLCheckin

This routine will export code from this namespace and push to github
Are you sure (Y/n)?
 
GIT path (): c:\git\bin\
GIT repo (): https://github.com/gituer/gitrepo.git
Local Dir (): C:\DEV\gitrepo
Enter GIT Username:gituser
Enter GIT Password: ***********
Export Packages - ALL for all packages (): ALL

#; Exporting to C:\DEV\gitrepo\src

...

#; Exported to C:\DEV\gitrepo\src
 
Enter the Git Message for Commit: A meaningful message
 
 Updating GIT...
 
FINISHED.

USER>

```
   This will export all classes etc starting with "PKG" and "PKGB.SUBPKG" to the folder `C:\localfolder\project\src` in UDL format.  
   If you want to change "src" to something else `do ##class(CTRL.Code).srcdir("other")`



## Manually run export ONLY

To manually use the class in IRIS
```
USER> do ##class(CTRL.Code).projectdir("C:\localfolder\project")

USER> do ##class(CTRL.Code).export("PKG,PKGB.SUBPKG")

or 

USER> do ##class(CTRL.Code).export()

```
   This will export all classes etc to the folder `C:\localfolder\project\src` in UDL format.  
   If you want to change "src" to something else `do ##class(CTRL.Code).srcdir("other")`  
   It will then run the commands to add these to the git repository.

## Manually run Git commands

To manually push the changes to git:

```
	Set gitpath="C:\GIT\bin\"
	Set wrkdir="C:\localfolder\project"
	Set homedir=""
	Set pAuthName="myGitUserName"
	Set pAuthEmail="myemail@org.com"
	Set pout=wrkdir_"\git.out"
	Set perr=wrkdir_"\git.err"
	Set gitrepo="https://github.com/myrepo/srcctrl.git"

 set git=##class(CTRL.GITClient).%New(gitpath,wrkdir,homedir,pAuthName,pAuthEmail,pout,perr,gitrepo)
	set sout = ""
	
	do git.Add("",.sout,1)
 w sout

	do git.Commit("","a meaningful message",.sout)
	w sout
	
	do git.Push(.sout)
	w sout

```

## Scripted run

there are 3 sample scripts included:
  * **runexport.scr** this is an IRIS script that will call the CTRL.Code class and pass in via parameters the necessary arguements  
  
  * **gitupdate.sh** this is designed to be run via GIT BASH, to _git add_ all mods, _git commit_ with a message including the datetime and then _git push_  
  
  * **update.bat** this batch file calls the preceeding scripts  
    edit this file to match the destination folder, the namespace and the packages (comma seperated list) to be exported.
    
## IMPORT

assuming you have **git pull**'ed the code from git, then just reverse the import:
```
USER> do ##class(CTRL.Code).projectdir("C:\DEV\gitrepo")

USER> do ##class(CTRL.Code).import()
```

this will recurse through the folders and import and compile the files.



```

