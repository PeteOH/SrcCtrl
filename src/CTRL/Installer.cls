Class CTRL.Installer Extends %Projection.AbstractProjection
{

Projection Reference As Installer;

Parameter VERSION = "1.0.0";

/// In older Cache versions, method "GetISCProduct" does not exist
Parameter iscProductVersion = {$case(
        ##class(%Dictionary.CompiledMethod).IDKEYExists("%SYSTEM.Version", "GetISCProduct"),
        1: $CLASSMETHOD("%SYSTEM.Version", "GetISCProduct"),
        : 2
    )};

/// This method is invoked when a class is compiled.
ClassMethod CreateProjection(
	cls As %String,
	ByRef params) As %Status
{

	new $Namespace
	set ns = $Namespace // ought to be package home namespace!
	set st = $$$OK
	
    write !, "Installing CTRL application to " _ ns

    do ..CreateAllNamespace()
    
    write !, "Mapping CTRL package into all namespaces:"
    set st = ..Map(ns)
    if ($$$ISERR(st)) {
        write !, "ERROR: CTRL package was not mapped into %ALL namespace !!!."
    } else {
	    write !, "CTRL package successfully mapped into all namespaces."
    }
    
    return st
}

/// This method is invoked when a class is 'uncompiled'.
ClassMethod RemoveProjection(
	cls As %String,
	ByRef params,
	recompile As %Boolean) As %Status
{

	set st = $$$OK
	
	new $Namespace

	write:(recompile) !, "Recompiling CTRL, skipping the deletion..."
    return:(recompile) $$$OK

	set ns = $get(^WebTerminal("HomeNamespace"), $Namespace)
    write !, "Uninstalling CTRL application from ", ns
    zn "%SYS"

    write !, "Unmapping CTRL package from all namespaces:"
	set st = ..UnMap(ns)
    if ($$$ISERR(st)) {
	    write !, "Unmapping failed."
    } else {
	    write !, "Unmapping complete."
    }

    return st
}

ClassMethod CreateAllNamespace() As %Status
{

	new $Namespace
    set $Namespace = "%SYS"
	set ns = "%All"
    set st = $$$OK

	if ('##Class(Config.Namespaces).Exists(ns)) {

        set dbPrefix = $case(..#iscProductVersion >= 4, 1: "IRIS", : "CACHE")
        set Properties("Globals") = dbPrefix _ "TEMP"
        set Properties("Library") = dbPrefix _ "LIB"
        set Properties("Routines") = dbPrefix _ "TEMP"
        set Properties("SysGlobals") = dbPrefix _ "SYS"
        set Properties("SysRoutines") = dbPrefix _ "SYS"
        set Properties("TempGlobals") = dbPrefix _ "TEMP"
		
		set st = ##Class(Config.Namespaces).Create(ns, .Properties)
		if ($$$ISERR(st)) {
        	do $System.Status.DisplayError(st)
    	} else {
        	write !, "%All namespace is created."
        }

    }

    return st
}

ClassMethod Map(fromNS = "") As %Status
{
	new $Namespace
    set $Namespace = "%SYS"
    set st = $$$OK

    set mapTo = $LISTBUILD("%All")
    do ##Class(Config.Namespaces).Get(fromNS, .InstallNSProps)
    set Properties("Database") = $get(InstallNSProps("Routines"))
    set ptr = 0
    while $LISTNEXT(mapTo, ptr, namespace) {
        continue:(fromNS = namespace)
        continue:('##Class(Config.Namespaces).Exists(namespace))
        write " ", namespace
        if ('##Class(Config.MapPackages).Exists(namespace, "CTRL")) {
        	set st1 = ##Class(Config.MapPackages).Create(namespace, "CTRL", .Properties)
        }
        if ('##Class(Config.MapRoutines).Exists(namespace, "CTRLCheckin.mac")) {
	        set st2 = ##Class(Config.MapRoutines).Create(namespace, "CTRL.Checkin.mac", .Properties)
        }
        set st = $$$ADDSC(st,$$$ADDSC($get(st1,$$$OK),$get(st2,$$$OK)))
    }
    return st
}

ClassMethod UnMap(fromNS As %String) As %Status
{
	new $Namespace
    set $Namespace = "%SYS"
    set st = $$$OK
    
	set mapTo = $LISTBUILD("%All")
    set ptr = 0
    while $LISTNEXT(mapTo, ptr, namespace) {
	    continue:(fromNS = namespace)
	    continue:('##Class(Config.Namespaces).Exists(namespace))
        write " ", namespace
        if (##Class(Config.MapPackages).Exists(namespace, "CTRL")) {
        	set st1 = ##Class(Config.MapPackages).Delete(namespace, "CTRL", .Properties)
        }
        if (##Class(Config.MapRoutines).Exists(namespace, "CTRLCheckin.mac")) {
	        set st2 = ##Class(Config.MapRoutines).Delete(namespace, "CTRL.Checkin.mac", .Properties)
        }
        set st = $$$ADDSC(st,$$$ADDSC($get(st1,$$$OK),$get(st2,$$$OK)))
    }
    return st
}

}
