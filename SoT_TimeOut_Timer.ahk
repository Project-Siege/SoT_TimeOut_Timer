#Persistent
#SingleInstance Force
SetTitleMatchMode, 2  ; Allows partial matching of window titles

; Variables
IdleTime := 600  ; 10 minutes in seconds
WarningStart := 120  ; 2 minutes in seconds
WarningDuration := 480  ; 8 minutes countdown in seconds
Timer := 0
SoTWindow := "SoTGame.exe"  ; Window title or exe name of Sea of Thieves
LastInputTime := A_TickCount
OverlayActive := false

; Create the overlay GUI (hidden by default)
Gui, +AlwaysOnTop +ToolWindow -Caption +E0x20 +Owner  ; Transparent and click-through
Gui, Color, FFE4C4  ; Pirate parchment color
Gui, Font, s22 cBlack, Verdana  ; Adjust font size
Gui, Add, Text, x0 y0 w300 h100 BackgroundTrans vTimeDisplay Center, 

; Position the overlay in the top middle of the screen
Gui, Show, NoActivate w300 h50 xCenter y10, Countdown  ; 300px wide, 100px tall

; Make the entire GUI semi-transparent
Gui, +LastFound
WinSet, Transparent, 150  ; 50% transparency (255 is fully opaque, 0 is fully transparent)

; Initially hide the overlay
Gui, Hide

; Check for inactivity every second
SetTimer, CheckInactivity, 1000

Return

CheckInactivity:
    ; Check if Sea of Thieves is running
    IfWinExist, ahk_exe %SoTWindow%
    {
        ; Calculate idle time in Sea of Thieves
        InputIdleTime := A_TickCount - LastInputTime

        ; Check if the user has been idle for 2 minutes
        if (InputIdleTime >= WarningStart * 1000)
        {
            if (!OverlayActive)
            {
                ; Show the overlay if it's not already active
                OverlayActive := true
                Gui, Show, NoActivate
            }

            ; Calculate remaining time and format it as MM:SS
            Timer := WarningDuration - (InputIdleTime / 1000 - WarningStart)
            Minutes := Floor(Timer / 60)
            Seconds := Round(Mod(Timer, 60))  ; Round seconds to nearest whole number

            ; Format the time to MM:SS with leading zeroes if needed
            TimeDisplay := Format("{:02}:{:02}", Minutes, Seconds)

            ; Update the countdown timer on the overlay
            GuiControl,, TimeDisplay, % TimeDisplay

            ; Check if time has run out
            if (Timer <= 0)
            {
                ; 10 second countdown before kicking user
                Loop, 10
                {
                    GuiControl,, TimeDisplay, % "Kicking in " . (10 - A_Index) . " seconds..."
                    Sleep, 1000
                }

                ; Close the game
                WinClose, ahk_exe %SoTWindow%
            }
        }
        else if (OverlayActive)
        {
            ; Hide the overlay and reset the timer when user activity is detected
            OverlayActive := false
            Gui, Hide
            Timer := 0
        }
    }
Return

; Reset LastInputTime only when there's input within Sea of Thieves
~*Esc::
~*Space::
~*Enter::
~*LButton::
~*RButton::
    IfWinExist, ahk_exe %SoTWindow%
    {
        LastInputTime := A_TickCount

        ; Hide the overlay if it was showing
        if (OverlayActive)
        {
            OverlayActive := false
            Gui, Hide
            Timer := 0
        }
    }
Return
