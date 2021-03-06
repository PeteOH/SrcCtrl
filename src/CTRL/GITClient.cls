Class CTRL.GITClient Extends %RegisteredObject
{

/// Name of the subdir that will hold Caché files in Git workdir
Parameter SRCDIRNAME = "src/";

/// Logger instance to display messages
Property Logger As CTRL.Logger;

/// Path to GIT binaries (with trailing slash)
Property GitPath As %String(MAXLEN = "");

/// Path to GIT work dir (with trailing slash)
Property WorkDir As %String(MAXLEN = "");

/// HOME path (Unix only). The value will be set as $HOME before executing git commands.
Property HomeDir As %String(MAXLEN = "");

/// Git Author name (used in commits). If set, it will be used in the GIT_AUTHOR_EMAIL env. variable
Property AuthorName As %String(MAXLEN = 1024);

/// Git Author email (used in commits). If set, it will be used in the GIT_AUTHOR_EMAIL env. variable
Property AuthorEmail As %String(MAXLEN = 1024);

/// Path to Cache files in GIT work dir (with trailing slash)
Property CacheDir As %String;

/// Temporary file to store errors from commands
Property ErrorFile As %String;

/// Temporary file to store output from commands
Property OutputFile As %String;

/// Path to the Git Repository for this User/Namespace
Property GitRepository As %String;

/// 
/// Constructor. Initializations
Method %OnNew(pGitPath As %String, pWorkDir As %String, pHomeDir As %String, pAuthorName As %String, pAuthorEmail As %String, pOutput As %String, pError As %String, pGitRepo As %String) As %Status
{
    if ((pWorkDir="")||(pOutput="")||(pError="")) {
	    $$$ThrowStatus($$$ERROR($$$GeneralError,"WorkDir, OutputFile or ErrorFile is set to null"))
    }
	set ..GitRepository=pGitRepo
    set ..GitPath = pGitPath
    set ..WorkDir = pWorkDir
    set ..HomeDir = pHomeDir
    set ..AuthorName = pAuthorName
    set ..AuthorEmail = pAuthorEmail
    set ..CacheDir = pWorkDir_..#SRCDIRNAME
    set ..OutputFile = pOutput
    set ..ErrorFile = pError
    set ..Logger = ##class(CTRL.Logger).%New()
    
    quit $$$OK
}

/// 
/// git clone
Method Clone(ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	quit ..RunCmd("git clone "_..GitRepository, .pOutput, pLog)
}

/// 
/// git add
Method Add(pFile As %String = "", ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	if pFile'="" {
		quit ..RunCmd("git add """_pFile_"""", .pOutput, pLog)
	} else {
		quit ..RunCmd("git add --all", .pOutput, pLog)

	}
}

/// 
/// git commit
Method Commit(pFile As %String, pMsg As %String, ByRef pOutput, pAmend As %Boolean = 0, pLog As %Boolean = 1) As %Status
{
	set opts="-a"
	set:pAmend opts=opts_" --amend"
	quit ..RunCmd("git commit "_opts_" -m """_pMsg_"""", .pOutput, pLog)
}

/// 
/// git status
Method Status(pFile As %String, ByRef statuscode As %String, ByRef statusdesc As %String, ByRef pOutput, pLog As %Boolean = 1, pPorcelain As %Boolean = 0) As %Status
{
	set (ret,statuscode,statusdesc)=""
	
	if pFile'="" {
		set ret = ..RunCmd("git status -s """_pFile_"""", .pOutput, pLog)
		if $data(pOutput(1)) {
			set line=$zstrip(pOutput(1),"<W")
			set s=$extract(line,0,1)
			set statuscode=s
			set statusdesc=$case(s,
				"?":"untracked",
				"M":"updated in index",
				"A":"added to index",
				"D":"deleted from index",
				"R":"renamed in index",
				"C":"copied in index",
				"!":"ignored"
			)
		} else {
			set ret = ..RunCmd("git ls-files -v """_pFile_"""", .pOutput, pLog)
			if $data(pOutput(1)) {
				set line=$zstrip(pOutput(1),"<W")
				set s=$zconvert($extract(line,0,1),"U")
				if s="H" {
					set statuscode="H"
					set statusdesc="Cached"
				}
			}
		} 
	} else {
		set opts=""
		set:pPorcelain opts="--porcelain"
		set ret = ..RunCmd("git status "_opts, .pOutput, pLog)
	}
	
	quit ret
}

/// 
/// git checkout
Method Checkout(pFile As %String = "", pBranch As %String = "", ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	if pFile'="" {
		quit ..RunCmd("git checkout -- """_pFile_"""", .pOutput, pLog)
	}
	else {
		quit ..RunCmd("git checkout "_pBranch, .pOutput, pLog)
	}
}

/// 
/// git log
Method Log(pFile As %String, ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	set file = ""
	if pFile'="" set file = ""_pFile_""
	
	quit ..RunCmd("git log --pretty=format:""%h %ad | %s%d [%an]"" --graph --date=short --max-count=20 "_file, .pOutput, pLog)
}

/// 
/// git reset
Method Reset(pFile As %String, ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	quit ..RunCmd("git reset HEAD """_pFile_"""", .pOutput, pLog)
}

/// 
/// git branch
Method Branch(pBranch As %String, ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	if pBranch="" {
		quit ..RunCmd("git branch", .pOutput, pLog)
	}
	quit ..RunCmd("git branch """_pBranch_"""", .pOutput, pLog)
}

/// 
/// git config --list
Method ListConfig(ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	quit ..RunCmd("git config --list", .pOutput, pLog)
}

/// 
/// Returns a string with the name of the current branch
Method GetCurrentBranch() As %String
{
	set result=""
	set tSC=..CurrentBranch(.output,0)
	if $$$ISOK(tSC) set result=output(1)
	quit result
}

/// 
/// current branch
Method CurrentBranch(ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	quit ..RunCmd("git rev-parse --symbolic-full-name --abbrev-ref HEAD", .pOutput, pLog)
}

/// 
/// git diff --name-status: useful to know what changes (status) have been done to files
Method DiffStatus(pBranch As %String = "", pReverse As %Boolean = 1, ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	set current = ..GetCurrentBranch()
	set opts="--name-status"
	set:pReverse opts=opts_" -R"
	quit ..RunCmd("git diff "_opts_" "_pBranch, .pOutput, pLog)
}

/// 
/// git diff --stat: useful to report statistics about changes
Method DiffStat(pBranch As %String = "", pReverse As %Boolean = 1, ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	set current = ..GetCurrentBranch()
	set opts="--stat"
	set:pReverse opts=opts_" -R"
	quit ..RunCmd("git diff "_opts_" "_pBranch, .pOutput, pLog)
}

/// 
/// git diff: simple changes made in a file
Method Diff(pFile As %String = "", ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	set opts="--patience"
	quit ..RunCmd("git diff "_opts_" "_pFile, .pOutput, pLog)
}

/// 
/// git push
Method Push(ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	quit ..RunCmd("git push "_..GitRepository_" --all", .pOutput, pLog, 1)
}

/// 
/// git pull
Method Pull(ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	quit ..RunCmd("git pull", .pOutput, pLog)
}

/// 
/// git remote update group
Method RemoteUpdate(pGroup As %String, ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	quit ..RunCmd("git remote update "_pGroup, .pOutput, pLog)
}

/// 
/// git merge
Method Merge(pBranch As %String, pAbort As %Boolean = 0, ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	set opts="--no-commit --no-ff"
	set:pAbort opts="--abort"
	quit ..RunCmd("git merge "_opts_" "_pBranch, .pOutput, pLog)
}

/// 
/// git ls-files
Method LsFiles(ByRef pOutput, pLog As %Boolean = 1) As %Status
{
	quit ..RunCmd("git ls-files --cached -v", .pOutput, pLog)
}

/// 
/// Runs a cmd in the OS and returns the output and error
Method RunCmd(cmd As %String, ByRef pOutput, pLog As %Boolean = 1, pAsync As %Boolean = 0) As %Status [ Private ]
{
	#define DQUOTE(%arg)	$char(34)_%arg_$char(34)
	#define ISWINDOWS		($zversion(1)=2)
	
	set ret=$$$OK
	try {
		set (sc,pOutput)=""
		set text=cmd
		
		if ..GitPath'="" {
			set exe=$piece(cmd," ")
			set args=$piece(cmd," ", 2, $l(cmd," "))
			set cmd=$$$DQUOTE(..GitPath_exe)_" "_args
		}
		
		set cmds=""
		
		// WINDOWS
		if $$$ISWINDOWS {
			if ..AuthorName'="" set cmds = cmds_$lb("set GIT_AUTHOR_NAME="_$$$DQUOTE(..AuthorName))
			if ..AuthorEmail'="" set cmds = cmds_$lb("set GIT_AUTHOR_EMAIL="_$$$DQUOTE(..AuthorEmail))
			if ..AuthorName'="" set cmds = cmds_$lb("set GIT_COMMITTER_NAME="_$$$DQUOTE(..AuthorName))
			if ..AuthorEmail'="" set cmds = cmds_$lb("set GIT_COMMITTER_EMAIL="_$$$DQUOTE(..AuthorEmail))
			set cmds = cmds_$lb("set GCM_TRACE=1")
			set cmds = cmds_$lb("cd /D "_$$$DQUOTE(..WorkDir))
			set cmds = cmds_$lb(cmd)
			set cmd = $listtostring(cmds, " & ")
		}
		// LINUX 
		else {
			set cmds=cmds_$lb("export LD_LIBRARY_PATH=""""")
			if ..AuthorName'="" set cmds = cmds_$lb("export GIT_AUTHOR_NAME="_$$$DQUOTE(..AuthorName))
			if ..AuthorEmail'="" set cmds = cmds_$lb("export GIT_AUTHOR_EMAIL="_$$$DQUOTE(..AuthorEmail))
			if ..AuthorName'="" set cmds = cmds_$lb("export GIT_COMMITTER_NAME="_$$$DQUOTE(..AuthorName))
			if ..AuthorEmail'="" set cmds = cmds_$lb("export GIT_COMMITTER_EMAIL="_$$$DQUOTE(..AuthorEmail))
			if ..HomeDir'="" set cmds = cmds_$lb("export HOME="_$$$DQUOTE(..HomeDir))
			set cmds = cmds_$lb("if [ ! -d "_$$$DQUOTE(..WorkDir)_" ]; then mkdir -p "_$$$DQUOTE(..WorkDir)_"; fi")
			set cmds = cmds_$lb("cd "_$$$DQUOTE(..WorkDir))
			set cmds = cmds_$lb("env > /tmp/myenv.txt")
			//set cmds = cmds_$lb("echo $PATH > /tmp/mypath.txt")
			set cmds = cmds_$lb("whoami > /tmp/whoami.txt")
			set cmds = cmds_$lb(cmd)
			set cmd = $listtostring(cmds, " && ")
		}
	
		set stdout = "/STDOUT="""_..OutputFile_""""
		set stderr = "/STDERR="""_..ErrorFile_""""
		set logit = ""
		set async = ""
		set stdin = ""
		
		set:(pLog) logit=" /LOGCMD"
		//set:(pAsync) async=" /ASYNC"
		//set:(pAsync) 

		set flags = "/SHELL /NOQUOTE "_stdout_" "_stderr_logit_async_stdin
		//  
		//do:(pLog) ..Logger.Info($c(13)_">"_text)
		//do ..Logger.Debug(cmd)
		//do ..Logger.Debug(flags)

		// $zf(-1) is deprecated - replaced with $zf(-100)
		//set rc=$zf(-1,cmd_" 2> """_..ErrorFile_""" > """_..OutputFile_"""")
		set rc=$zf(-100,flags,cmd)
		//w:(pAsync) !,"--- waiting 30sec..."
		//HANG:(pAsync) 30
						
		set errorstream=##class(%Stream.FileCharacter).%New()
		set tsc = errorstream.LinkToFile(..ErrorFile)

		set ind=0
		if errorstream.Size>0 {		
			while 'errorstream.AtEnd {
				set errorLine=errorstream.ReadLine()
				do ..Logger.Debug(errorLine)
				set ind=ind+1
				set pOutput(ind)=errorLine
			}
		}
		do errorstream.Clear()
		kill errorstream
		
		set outputstream=##class(%Stream.FileCharacter).%New()
		set tsc = outputstream.LinkToFile(..OutputFile)
	
		if outputstream.Size>0 {
			while 'outputstream.AtEnd {
				set outputLine=outputstream.ReadLine()
				do ..Logger.Debug(outputLine)
				set ind=ind+1
				set pOutput(ind)=outputLine
			}
		}
		do outputstream.Clear()
		kill outputstream
		
	} catch errObj {
		set ret=errObj.AsStatus()
	}
		
	quit ret
}

ClassMethod testme()
{
	
	Set gitpath="C:\GIT\bin\"
	Set wrkdir="C:\DEV\SrcCtrl"
	Set homedir=""
	Set pAuthName="PeteOH"
	Set pAuthEmail="peteohalloran@gmail.com"
	Set pout=wrkdir_"\git.out"
	Set perr=wrkdir_"\git.err"
	Set gitrepo="https://PeteOH:Bluesky!GH1@github.com/peteoh/srcctrl.git"
	
	#dim git As CTRL.GITClient
	 
	Set git=##class(CTRL.GITClient).%New(gitpath,wrkdir,homedir,pAuthName,pAuthEmail,pout,perr,gitrepo)

	set sout = ""
	
	Do git.Add("",.sout,1)

	w sout

	Do git.Commit("","testing",.sout)

	w sout
	
	Do git.Push(.sout)

	w sout
}

}

