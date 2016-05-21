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
	PARAMETER desiredAltitude.
	SET u TO SHIP:ORBIT:BODY:MU.
	SET r1 TO SHIP:ORBIT:SEMIMAJORAXIS.
	SET r2 TO desiredAltitude + SHIP:ORBIT:BODY:RADIUS.
	SET v1 TO SQRT(u / r1) * (SQRT((2 * r2) / (r1 + r2)) - 1).
	SET v2 TO SQRT(u / r2) * (1 - SQRT((2 * r1) / (r1 + r2))).
	RETURN LIST(v1, v2).
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

FUNCTION MNV_INCLINATION_DV {
	PARAMETER dI.
	LOG dI TO mnv_4.txt.
	PARAMETER timeToBurn.
	SET m TO TLM_MEAN_ANOMALY().
	SET dm TO OBT_MEAN_ANGLE_FROM_TIME(timeToBurn).
	SET bm TO OBT_LNG_TO_DEGREES(m+dm).
	LOG bm TO mnv_4.txt.
	SET ecc TO SHIP:ORBIT:ECCENTRICITY.
	LOG ecc TO mnv_4.txt.
	SET w TO SHIP:ORBIT:ARGUMENTOFPERIAPSIS.
	LOG w TO mnv_4.txt.
	SET ea TO OBT_MEAN_TO_ECC_ANOMALY(bm, ecc).
	LOG ea TO mnv_4.txt.
	SET f TO OBT_ECC_TO_TRUE_ANOMALY(ea, ecc).
	LOG f TO mnv_4.txt.
	SET n TO 360 / SHIP:ORBIT:PERIOD.
	LOG n TO mnv_4.txt.
	SET a TO SHIP:ORBIT:SEMIMAJORAXIS.
	LOG a TO mnv_4.txt.
	SET dV TO (2 * SIN(dI/2) * SQRT(1 - ecc*ecc) * COS(w + f) * n * a) / (1 + (ecc * COS(f))).
	LOG dV TO mnv_4.txt.
	RETURN dV.
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
