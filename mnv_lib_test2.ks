DOWNLOAD("general.ks").
DOWNLOAD("manoeuvre.ks").
RUN general.ks.
RUN manoeuvre.ks.

NOTIFY("EXECUTING FIRST NODE...").
MNV_EXEC_NODE(TRUE).
NOTIFY("DONE FIRST NODE!").
WAIT 10.
NOTIFY("EXECUTING SECOND NODE...").
MNV_EXEC_NODE(TRUE).
NOTIFY("DONE SECOND NODE!").
