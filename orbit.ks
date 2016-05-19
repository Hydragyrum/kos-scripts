FUNCTION OBT_LNG_TO_DEGREES {
	PARAMETER lng.
	RETURN MOD(lng+360, 360).
}

FUNCTION OBT_ORBITABLE {
	PARAMETER name.

	LIST TARGETS in vessels.
	FOR vs IN vessels {
		IF vs:NAME = name {
			RETURN VESSEL(name).
		}
	}
	RETURN BODY(name).
}

FUNCTION OBT_TARGET_ANGLE {
	PARAMETER target.

	RETURN MOD(
		OBT_LNG_TO_DEGREES(OBT_ORBITABLE(target):LONGITUDE)
		- OBT_LNG_TO_DEGREES(SHIP:LONGITUDE) + 360,
		360
	).
}

FUNCTION OBT_TARGET_ANGLE2 {
	PARAMETER target.
 	LOCAL tgtOrbit IS OBT_ORBITABLE(target):ORBIT.
	LOCAL shpOrbit IS SHIP:ORBIT.

	LOCAL tgtTA IS tgtOrbit:TRUEANOMALY.
	LOCAL tgtARGP IS tgtOrbit:ARGUMENTOFPERIAPSIS.
	LOCAL tgtLAN IS tgtOrbit:LAN.
	LOCAL tgtEcc IS tgtOrbit:ECCENTRICITY.
	LOCAL shpTA IS shpOrbit:TRUEANOMALY.
	LOCAL shpARGP IS shpOrbit:ARGUMENTOFPERIAPSIS.
	LOCAL shpLAN IS shpOrbit:LAN.
	LOCAL shpEcc IS shpOrbit:ECCENTRICITY.

	LOCAL tgtTheta IS OBT_LNG_TO_DEGREES(tgtTA + tgtARGP + tgtLAN).
	LOCAL shpTheta IS OBT_LNG_TO_DEGREES(shpTA + shpARGP + shpLAN).
	LOCAL tgtE IS OBT_TRUE_TO_ECCENTRIC_ANOMALY(tgtTheta, tgtEcc).
	LOCAL tgtM IS OBT_ECCENTRIC_TO_MEAN_ANOMALY(tgtE, tgtEcc).
	LOCAL shpE IS OBT_TRUE_TO_ECCENTRIC_ANOMALY(shpTheta, shpEcc).
	LOCAL shpM IS OBT_ECCENTRIC_TO_MEAN_ANOMALY(shpE, shpEcc).
	RETURN OBT_LNG_TO_DEGREES(tgtM - shpM).
}

FUNCTION OBT_MEAN_TIME_FROM_ANGLE {
	PARAMETER meanAnomaly.
	RETURN SHIP:ORBIT:PERIOD * ( meanAnomaly / 360 ).
}

FUNCTION OBT_MEAN_ANOMALY {
	PARAMETER useTarget.
	LOCAL tgt IS SHIP.
	IF useTarget = TRUE {
		SET tgt TO TARGET.
	}
	LOCAL ta IS tgt:ORBIT:TRUEANOMALY.
	LOCAL ecc IS tgt:ORBIT:ECCENTRICITY.
	LOCAL ea IS OBT_TRUE_TO_ECCENTRIC_ANOMALY(ta, ecc).
	LOCAL ma IS OBT_ECCENTRIC_TO_MEAN_ANOMALY(ea, ecc).
	RETURN ma.
}

FUNCTION OBT_TRUE_TO_ECCENTRIC_ANOMALY {
	PARAMETER ta.
	PARAMETER ecc.
	RETURN MOD(360 + ARCTAN2(SQRT(1 - ecc*ecc) * SIN(ta), ecc + COS(ta)), 360).
}

FUNCTION OBT_ECCENTRIC_TO_MEAN_ANOMALY {
	PARAMETER ea.
	PARAMETER ecc.
	RETURN MOD(360 + (ea - (CONSTANT:RADTODEG * ecc * SIN(ea))), 360).
}