DOWNLOAD("telemetry.ks").
RUN telemetry.ks.

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
