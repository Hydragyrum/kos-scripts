//Generalized Boot Script for all vessels.
//Adapted from http://youtube.com/gisikw

//Check for new commands from KSC.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

//Check to see if a given file exists
FUNCTION FILE_EXISTS {
    PARAMETER name.
    PARAMETER vol.

    SWITCH TO vol.
    LIST FILES IN allFiles.
    FOR file IN allFiles {
        IF file:NAME = name {
            SWITCH to 1.
            RETURN TRUE.
        }
    }

    SWITCH TO 1.
    RETURN FALSE.
}

FUNCTION DELAY {
    SET dTime TO ADDONS:RT:DELAY(SHIP) * 3. //Total delay time
    SET accTime TO 0.

    UNTIL accTime >= dTime {
        SET start TO TIME:SECONDS.
        WAIT UNTIL (TIME:SECONDS - start) > (dTime - accTime) OR NOT ADDONS:RT:HASCONNECTION(SHIP).
        SET accTime TO accTime + TIME:SECONDS - start.
    }
}

FUNCTION DOWNLOAD {
    PARAMETER name.

    DELAY().
    IF FILE_EXISTS(name, 1) {
        DELETE name.
    }
    IF FILE_EXISTS(name, 0){
        COPY name FROM 0.
    }
}

FUNCTION UPLOAD {
	PARAMETER name.

	DELAY().
	IF FILE_EXISTS(name, 0) {
		SWITCH TO 0. DELETE name. SWITCH TO 1.
	}
	IF FILE_EXISTS(name, 1) {
		COPY name TO 0.
	}
}

//Run a library, downloading it from the KSC if necessary
FUNCTION REQUIRE {
	PARAMETER name.

	IF NOT FILE_EXISTS(name, 1) {
		DOWNLOAD(name).
	}
	RENAME name TO "tmp.exec.ks".
	RUN tmp.exec.ks.
    IF NOT FILE_EXISTS(name, 1) {
        RENAME "tmp.exec.ks" TO name.
    } ELSE {
        DELETE tmp.exec.ks.
    }
}

//BOOTUP Sequence.
SET updateScript TO SHIP:NAME + ".update.ks".

//If we have a connection, see if there are new instructions, then downlaod and run them.
IF ADDONS:RT:HASCONNECTION(SHIP) {
	IF FILE_EXISTS(updateScript, 0) {
		DOWNLOAD(updateScript).
		SWITCH TO 0. DELETE updateScript. SWITCH TO 1.
		IF FILE_EXISTS("update.ks", 1) {
			DELETE update.ks.
		}
		RENAME updateScript TO "update.ks".
		RUN update.ks.
		DELETE update.ks.
	}
}

IF FILE_EXISTS("startup.ks", 1) {
	RUN startup.ks.
} ELSE {
	WAIT UNTIL ADDONS:RT:HASCONNECTION(SHIP).
	WAIT 10.	//Avoid Thrashing the CPU in a persistant rebot loop
	REBOOT.
}
