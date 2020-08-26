# SrcCtrl
Utility that will export code from an IRIS Namespace to a folder on the server.

## Installation

Import/compile the class file `/src/CTRL/Code.cls` into you IRIS instance.
  * If you just want this on a single Namespace, then import it to that namespace. 
  * If you want it available to all namespaces then map it the the %ALL namespace.
  
Copy the script files to the root folder of your IRIS project. Edit the **update.bat** to make sure that paths are correct (keep in mind that this is for the IRIS Server).

On the IRIS server you will need to make sure that the folder for the GIT project is correctly configured.
  * **git clone** your project. 
  * store git credentials (Good article: [Git Config Username & Password](https://www.shellhacks.com/git-config-username-password-store-credentials/#:~:text=When%20credentials%20storage%20is%20enabled,provide%20the%20username%20and%20password.)

## Manually run

To manually use the class in IRIS
```
USER> do ##class(CTRL.Code).projectdir("C:\localfolder\project")

USER> do ##class(CTRL.Code).export("PKG,PKGB.SUBPKG")
```
   This will export all classes etc starting with "PKG" and "PKGB.SUBPKG" to the folder C:\localfolder\project\src in UDL format.
   if you want to change "src" to something else `do ##class(CTRL.Code).srcdir("other")`
   
## Scripted run

there are 3 sample scripts included:
  * **runexport.scr** this is an IRIS script that will call the CTRL.Code class and pass in via parameters the necessary arguements  
  
  * **gitupdate.sh** this is designed to be run via GIT BASH, to _git add_ all mods, _git commit_ with a message including the datetime and then _git push_  
  
  * **update.bat** this batch file calls the preceeding scripts  
    

