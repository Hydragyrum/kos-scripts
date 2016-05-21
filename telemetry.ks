FUNCTION TLM_STAGE_DELTAV {
	//fuel names
	LOCAL fuels IS LIST().
	fuels:ADD("LiquidFuel").
	fuels:ADD("Oxidizer").
	fuels:ADD("SolidFuel").
	fuels:ADD("MonoPropellant").
	//fuel densities
	LOCAL fuelDensity IS LIST().
	fuelDensity:ADD(0.005).
	fuelDensity:ADD(0.005).
	fuelDensity:ADD(0.0075).
	fuelDensity:ADD(0.004).
	LOCAL fuelMass IS 0.
	FOR r IN STAGE:RESOURCES {
		LOCAL i IS 0.
		FOR f IN fuels {
			IF f = r:NAME SET fuelMass TO fuelMass+fuelDensity[i]*r:AMOUNT.
			SET i TO i+1.
		}
	}
	LOCAL engStats IS TLM_STAGE_ENGINE_THRUST().
	LOCAL avgIsp IS engStats[1].

	LOCAL deltaV IS avgIsp*9.81*LN(SHIP:MASS/(SHIP:MASS-fuelMass)).
	RETURN deltaV.
}

FUNCTION TLM_STAGE_ENGINE_THRUST{
	LOCAL stageEngines IS LIST().
	stageEngines:CLEAR.
	LIST ENGINES IN engines.
	FOR e IN engines {
		IF e:IGNITION = TRUE AND e:FLAMEOUT = FALSE stageEngines:ADD(e).
	}
	LOCAL thrustTotal IS 0.
	LOCAL mDotTotal IS 0.
	for eng in stageEngines {
		LOCAL t is eng:AVAILABLETHRUST.
		SET thrustTotal TO thrustTotal + t.
		IF eng:ISP = 0 {SET mDotTotal TO 1.} ELSE {SET mDotTotal TO mDotTotal+t/eng:ISP.}
	}
	LOCAL avgIsp IS 0.
	IF mDotTotal = 0 {
		SET avgIsp TO 0.
	} ELSE {
		SET avgIsp TO thrustTotal / mDotTotal.
	}
	RETURN LIST(thrustTotal, avgIsp).
}

FUNCTION TLM_MEAN_ANOMALY {
	LOCAL P IS SHIP:ORBIT:PERIOD.
	LOCAL TTP IS ETA:PERIAPSIS.
	LOCAL ma IS 360 * (P - TTP) / P.
	RETURN ma.
}
