FUNCTION ISH {
	PARAMETER x.
	PARAMETER y.
	PARAMETER ishyness.

	RETURN (x - ishyness) < y AND (x + ishyness) > y.
}

//Display a message in the main window
FUNCTION NOTIFY {
    PARAMETER message.
    HUDTEXT("kOS: " + message, 5, 2, 50, YELLOW, false).
}
