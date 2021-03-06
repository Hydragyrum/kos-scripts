PRINT "Loading Launch Script...".
DOWNLOAD("ascent.ks").
DOWNLOAD("general.ks").
RUN ascent.ks.
RUN general.ks.

SET ASCENT_PROFILE TO LIST (
	//Altitude,	Angle,	Thrust
	0,	80,	1 ,
	1500,	80,	0.65,
	10000,	80,	0.65,
	15000,	75,	0.65,
	20000,	70,	0.65,
	25000,	65,	0.6,
	32000,	50,	0.55,
	45000,	35,	0.5,
	50000,	25,	0.45,
	60000,	0,	0.4,
	70000,	0,	0
).

LOCK THROTTLE TO 1. WAIT 1. STAGE.
EXECUTE_ASCENT_PROFILE(90, ASCENT_PROFILE).

TOGGLE AG1.
WAIT UNTIL ETA:APOAPSIS < 30.
SET steer TO HEADING(90, 0).
LOCK STEERING TO steer.
LOCK THROTTLE TO 1.

SET prevThrust TO MAXTHRUST.
UNTIL FALSE {
	IF MAXTHRUST < (prevThrust - 10) {
		LOCK THROTTLE TO 0.
		WAIT 1. STAGE. WAIT 1.
		LOCK THROTTLE TO 1.
		SET prevThrust TO MAXTHRUST.
	}
	// IF ISH(PERIAPSIS, 10000, 500) {
	// 	LOCK THROTTLE TO 0.
	// 	WAIT 1. STAGE. WAIT 1.5.
	// 	LOCK THROTTLE TO 1.
	// 	SET prevThrust TO MAXTHRUST.
	// }
	IF PERIAPSIS > 70000 {
		BREAK.
	}
}

LOCK THROTTLE TO 0.
PRINT "Step Executed. Shutting down.".
