Hypn's OllyDbg Debug Logger v0.1
================================

This program records OllyDbg v1.10's "debug" values of a breakpoint, resuming (looping) until a specified string is found - saving you having to manually copy and paste the values, repeatedly press F9 to keep continuing, and watch for the "stop" condition being met.

DISCLAIMER: This "program" is simply an AutoIt 3 script that monitors OllyDbg's memory and sends some keypresses - that said, it is used at your own risk (keep in mind that entering an invalid, or never-reached, "stop" condition may result in a massive log file being created and you having to manually terminate the application. The code is old (2008!) and was written for Windows XP 32bit and hasn't been tested for any other operating systems.

Scenario:
	Assume you have a break point (in an application you've attached to) on:
		004E4F06 8902 MOV DWORD PTR DS:[EDX],EAX2
		
	The first time the breakpoint is triggered, the "debug" values are:
		EAX=00000033
		DS:[0068C218]=000000323
		
	You want to keep looping through each break until EAX is equal to 00000055, and log the values after each loop, without manually watching 


Solution:
	1. Run "Hypn's OllyDbg Debug Logger v0.1.exe"
	2. When prompted for "String to stop on?", enter "EAX=00000055"
	3. Watch as OllyDbg automatically "break"s and "continue"s, until it stops at your break-point once your condition is met
	4. Open "log.txt" (in the same directory as this program) for a log of all the debug values


Links:
http://www.hypn.za.net
http://www.twitter.com/hypn
