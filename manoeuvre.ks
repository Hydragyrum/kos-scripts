DOWNLOAD("telemetry.ks"). RUN telemetry.ks.
DOWNLOAD("orbit.ks"). RUN orbit.ks.
SET burnoutCheck TO "reset".
FUNCTION MNV_BURNOUT {
	PARAMETER autoStage.
	IF burnoutCheck = "reset" {
		SET burnoutCheck TO MAXTHRUST.
		RETURN FALSE.
	}
	IF burnoutCheck - MAXTHRUST > 10 {
		IF autoStage {
			SET currentThrottle TO THROTTLE.
			LOCK THROTTLE TO 0.
			WAIT 1. STAGE. WAIT 1.
			LOCK THROTTLE TO currentThrottle.
		}
		SET burnoutCheck TO "reset".
		RETURN TRUE.
	}
	RETURN FALSE.
}
FUNCTION MNV_TIME{
	PARAMETER dv.
	LOCAL engStats IS TLM_STAGE_ENGINE_THRUST().
	SET engThrust TO engStats[0].
	SET engIsp TO engStats[1].
	IF engThrust = 0 OR engIsp = 0 {
		NOTIFY("No engines available on this stage!").
		RETURN 0.
	} ELSE {
		LOCAL f IS engThrust * 1000.    //kN -> N
		LOCAL m IS SHIP:MASS * 1000.    //T -> kg
		LOCAL e IS CONSTANT:E.
		LOCAL p IS engISP.
		LOCAL g IS SHIP:ORBIT:BODY:MU / SHIP:ORBIT:BODY:RADIUS^2.
		RETURN g * m * p * (1 - e^(-dv / (g * p))) / f.
	}
}
FUNCTION MNV_HOHMANN_DV {
	PARAMETER r1. PARAMETER r2. PARAMETER i.
	SET b TO SHIP:ORBIT:BODY.
	SET v0 TO OBT_VELOCITY(r1, SHIP:ORBIT:PERIAPSIS, SHIP:ORBIT:APOAPSIS, b).
	SET v1p TO OBT_VELOCITY(r1, r1, r2, b).
	SET v1a TO OBT_VELOCITY(r2, r1, r2, b).
	SET v2 TO OBT_VELOCITY(r2, r2, r2, b).
	SET dv1 TO v1p-v0.
	SET dv2 TO SQRT(v2*v2+v1a*v1a-2*v2*v1a*COS(i)).
	SET dv2t TO v2-v1a.
	SET dv2i TO dv2-dv2t.
	RETURN LIST(V(0, 0, dv1), V(0, dV2i, dV2t)).
}
FUNCTION MNV_HOHMANN_START_ANGLE {
	PARAMETER desiredAltitude.
	SET u TO SHIP:ORBIT:BODY:MU.
	SET pi TO CONSTANT:PI.
	SET r1 TO SHIP:ORBIT:SEMIMAJORAXIS.
	SET r2 TO desiredAltitude + SHIP:ORBIT:BODY:RADIUS.
	SET a TO CONSTANT:RAD2DEG * pi * (1 - (1 / (2 * SQRT(2))) * SQRT(((r1 / r2) + 1)^3)).
	RETURN a.
}
FUNCTION MNV_CREATE_NODE {
	PARAMETER burn.	//Radial, Normal, Prograde.
	PARAMETER timeToNode.
	SET newNode TO NODE(TIME:SECONDS + timeToNode, burn:X, burn:Y, burn:Z).
	ADD newNode.
}
FUNCTION MNV_EXEC_NODE {
	PARAMETER autoWarp.
	LOCAL n IS NEXTNODE.
	LOCAL v IS n:BURNVECTOR.
	LOCAL startTime is TIME:SECONDS + n:ETA - MNV_TIME(v:MAG) / 2.
	LOCK STEERING TO n:BURNVECTOR.
	IF autoWarp {
		WARPTO(startTime - 30).
	}
	WAIT UNTIL TIME:SECONDS >= startTime.
	LOCK THROTTLE TO MIN(MNV_TIME(n:BURNVECTOR:MAG), 1).
	WAIT UNTIL VDOT(n:BURNVECTOR, v) < 0.1.
	LOCK THROTTLE TO 0.
	UNLOCK STEERING.
	REMOVE n.
}
