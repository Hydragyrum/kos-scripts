//Execute Acsent Profile
FUNCTION EXECUTE_ASCENT_STEP {
	PARAMETER direction.
	PARAMETER minAlt.
	PARAMETER newAngle.
	PARAMETER newThrust.

	SET prevThrust TO MAXTHRUST.

	UNTIL FALSE {
		//Stage if we're flamed out
		IF MAXTHRUST < (prevThrust - 10) {
			SET currentThrottle TO THROTTLE.
			LOCK THROTTLE TO 0.
			WAIT 1. STAGE . WAIT 1.
			LOCK THROTTLE TO currentThrottle.
			SET prevThrust to MAXTHRUST.
		}

		//Set the new values if we've reached the minimum altitude.
		IF ALTITUDE > minAlt {
			LOCK STEERING TO HEADING(direction, newAngle).
			LOCK THROTTLE TO newThrust.
			BREAK.
		}

		WAIT 0.1.
	}
}

FUNCTION EXECUTE_ASCENT_PROFILE {
	PARAMETER direction.
	PARAMETER profile.

	SET step TO 0.
	UNTIL step >= profile:length - 1 {
		EXECUTE_ASCENT_STEP(
			direction,
			profile[step],
			profile[step+1],
			profile[step+2]
		).
		SET step to STEP+3.
	}
}
