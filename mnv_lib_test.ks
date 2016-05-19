REQUIRE("manoeuvre.ks").
REQUIRE("telemetry.ks").

LOG "Stage Delta V Remaining: " + TLM_STAGE_DELTAV() TO log.txt.
SET dv TO MNV_HOHMANN_DV(400000).
LOG "Hohmann Transfer to 400 km Burn 1 dv: " + dv[0] TO log.txt.
LOG "Hohmann Transfer to 400 km Time to Burn 1: " + MNV_TIME(dv[0]) TO log.txt.
LOG "Hohmann Transfer to 400 km Burn 2 dv: " + dv[1] TO log.txt.
LOG "Hohmann Transfer to 400 km Burn 2 dv: " + MNV_TIME(dv[1]) TO log.txt.
LOG "Angle of Burn Start: " + MNV_HOHMANN_START_ANGLE(400000) TO log.txt.
COPY log.txt TO 0.
