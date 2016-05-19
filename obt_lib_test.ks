DOWNLOAD("orbit.ks").
DOWNLOAD("telemetry.ks").
RUN orbit.ks.
RUN telemetry.ks.

LOG "Mean Anomaly from Telemety: " + TLM_MEAN_ANOMALY() TO log_obt_test.txt.
LOG "Mean Anomaly from Orbit: " + OBT_MEAN_ANOMALY(FALSE) TO log_obt_test.txt.
LOG "True Anomaly: " + SHIP:ORBIT:TRUEANOMALY TO log_obt_test.txt.
SET TARGET TO "Mun".
LOG "Mean Anomaly of Mun " + OBT_MEAN_ANOMALY(TRUE) TO log_obt_test.txt.
LOG "True Anomaly of Mun: " + BODY("Mun"):ORBIT:TRUEANOMALY TO log_obt_test.txt.
COPY log_obt_test.txt TO 0.
