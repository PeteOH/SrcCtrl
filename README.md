# SrcCtrl
Utility that will export code from an IRIS Namespace to a folder on the server. Including the ability to commit to a git repository

## Installation

If the code is not yet in a Git Repository then create an empty repoository first.  
On the server perform a **git clone** to a local folder.  
You do not need to store credentials - the routine will prompt for git user and passwd. If you wish to then you can follow article: <a href="https://www.shellhacks.com/git-config-username-password-store-credentials" target="_blank">Git Config Username & Password</a>  

Import/compile the class and routine files `/src/CTRL/*` into you IRIS instance.
  * If you just want this on a single Namespace, then import them to that namespace. 
  * If you want it available to all namespaces then map them the the %ALL namespace.
  
Copy the script files to the root folder of your IRIS project. Edit the **update.bat** to make sure that paths are correct (keep in mind that this is for the IRIS Server).

## Manually run export ONLY

To manually use the class in IRIS
```
USER> do ##class(CTRL.Code).projectdir("C:\localfolder\project")

USER> do ##class(CTRL.Code).export("PKG,PKGB.SUBPKG")

or 

USER> do ##class(CTRL.Code).export()

```
   This will export all classes etc starting with "PKG" and "PKGB.SUBPKG" to the folder `C:\localfolder\project\src` in UDL format.  
   If you want to change "src" to something else `do ##class(CTRL.Code).srcdir("other")`


## Routine run export AND Git commit

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
 
Enter the Git Message for Commit:meaningful message


DEV>

```
   This will export all classes etc starting with "PKG" and "PKGB.SUBPKG" to the folder `C:\localfolder\project\src` in UDL format.  
   If you want to change "src" to something else `do ##class(CTRL.Code).srcdir("other")`

## Scripted run

there are 3 sample scripts included:
  * **runexport.scr** this is an IRIS script that will call the CTRL.Code class and pass in via parameters the necessary arguements  
  
  * **gitupdate.sh** this is designed to be run via GIT BASH, to _git add_ all mods, _git commit_ with a message including the datetime and then _git push_  
  
  * **update.bat** this batch file calls the preceeding scripts  
    edit this file to match the destination folder, the namespace and the packages (comma seperated list) to be exported.
    

