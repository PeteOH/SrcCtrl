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
Method %OnNew(
	pGitPath As %String,
	pWorkDir As %String,
	pHomeDir As %String,
	pAuthorName As %String,
	pAuthorEmail As %String,
	pOutput As %String,
	pError As %String,
	pGitRepo As %String) As %Status
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
Method Clone() As %Status
{
	set retval = $$$OK

	set git = $G(^CTRL.Code("gitpath"),"/usr/bin/git")
	set repo = $G(^CTRL.Code("gitrepo"),"github.com/Buddybet-Group/BuddyBet-IRISv2.0.git")
	set user = $G(^CTRL.Code("gitusername"),"Buddybetadmin")
	set token = $G(^CTRL.Code("gittoken"),"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")
	set prj = $G(^CTRL.Code("projectdir"), "/CoreDatabase/GIT/BuddyBet-IRISv2.0")
	
	set repo = "https://"_user_":"_token_"@"_repo
	set flags = "/LOGCMD /SHELL /STDOUT="""_tmp_"/git.out"" /STDERR="""_tmp_"/git.err"" "
	
	set ctr = 0
	set args($I(ctr)) = "clone"
	set args($I(ctr)) = repo
	set args($I(ctr)) = prj
	
	set status = $ZF(-100,flags,git,.args)
	
	set retval=(status=0)
	
	return retval
}

/// 
/// git pull
ClassMethod Pull() As %Status
{
	
	set retval = $$$OK
	
	set tmp = $G(^CTRL.Code("workdir"),"/tmp")
	set git = $G(^CTRL.Code("gitpath"),"/usr/bin/git")
	set prj = $G(^CTRL.Code("projectdir"),"/CoreDatabase/GIT/BuddyBet-IRISv2.0")
	
	set flags = "/LOGCMD /SHELL /STDOUT="""_tmp_"/git.out"" /STDERR="""_tmp_"/git.err"" "
	
	set args(1) = "-C"
	set args(2) = prj
	set args(3) = "pull"
	
	set status = $ZF(-100,flags,git,.args)
	
	set retval=(status=0)
	
	return retval
}

ClassMethod initSettings() As %Status
{
	set ^CTRL.Code("gitpath") = "/usr/bin/git"
	set ^CTRL.Code("gitrepo") = "github.com/Buddybet-Group/BuddyBet-IRISv2.0.git"
	set ^CTRL.Code("gittoken") = "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"
	set ^CTRL.Code("gitusername") = "Buddybetadmin"
	set ^CTRL.Code("projectdir") = "/CoreDatabase/GIT/BuddyBet-IRISv2.0"
	set ^CTRL.Code("workdir") = "/tmp"
	
	return $$$OK
}

}
