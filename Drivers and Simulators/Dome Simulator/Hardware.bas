Attribute VB_Name = "Hardware"
' ==============
'  Hardware.BAS
' ==============
'
' Dome hardware abstraction layer.  Same interfaces can be used for real dome.
'
' Written:  15-Jun-03   Jon Brewster
'
' Edits:
'
' When      Who     What
' --------- ---     -----------------------------------------------------------
' 15-Jun-03 jab     Initial edit
' 27-Jun-03 jab     Initial release
' 03-Sep-03 jab     Additional checks for home/park positions
' 31-Jan-04 jab     Treat home/park as state, not position
' 03-Dec-04 rbd     Add "Start up with shutter error" mode, dome azimuth,
'                   altitude, and shutter state are now persistent.
' 06-Dec-04 rbd     4.0.2 - More non-standard behavior - AtHome/AtPark by
'                   position, Slewing = True while opening/closing shutter.
'                   Move slewing detection logic into HW layer. New props
'                   HW_AtPark and HW_AtHome take into account the step size
'                   instead of requiring position to be exactly the set pos.
' -----------------------------------------------------------------------------

Option Explicit

Public Enum Going
    slewCCW = -1        ' just running till halt
    slewNowhere = 0     ' stopped, complete. not slewing
    slewCW = 1          ' just running till halt
    slewSomewhere = 2   ' specific Az based slew
    slewPark = 3        ' parking
    slewHome = 4        ' going home
End Enum

Public Property Get HW_Slewing() As Boolean

    ' slewing is true if either Alt or Az are in motion
    HW_Slewing = (g_eSlewing <> slewNowhere) Or (g_dDomeAlt <> g_dTargetAlt)
    ' Non-standard, Slewing true if shutter is opening/closing
    If g_bSlewingOpenClose Then HW_Slewing = HW_Slewing Or _
        (g_eShutterState = shutterClosing) Or (g_eShutterState = shutterOpening)
        
End Property

'
' Indicates if the azimuth is "close enough" to the Set Park position
'
Public Property Get HW_AtPark()
    Dim X As Double
    
    X = AzScale(Abs(g_dDomeAz - g_dSetPark))
    If X > 180 Then _
        X = 360 - X
    HW_AtPark = (X < PARK_HOME_TOL)
    
End Property

'
' Indicates if the azimuth is "close enough" to the Set Home position
'
Public Property Get HW_AtHome()
    Dim X As Double
    
    X = AzScale(Abs(g_dDomeAz - g_dSetHome))
    If X > 180 Then _
        X = 360 - X
    HW_AtHome = (X < PARK_HOME_TOL)
    
End Property

Public Sub HW_CloseShutter()
    
    If Not g_show Is Nothing Then
        If g_show.chkHW.Value = 1 Then _
            g_show.TrafficLine "HW_CloseShutter"
    End If
    
    If g_eShutterState = shutterClosed Then _
        Exit Sub
        
    g_dOCProgress = g_dOCDelay
    g_eShutterState = shutterClosing

End Sub

Public Function HW_Fetch() As Double

    If Not g_show Is Nothing Then
        If g_show.chkHW.Value = 1 Then _
            g_show.TrafficLine "HW_Fetch: " & Format$(g_dDomeAz, "000.0")
    End If
    
    HW_Fetch = g_dDomeAz
    
End Function

Public Sub HW_FindHome()
    
    If Not g_show Is Nothing Then
        If g_show.chkHW.Value = 1 Then _
            g_show.TrafficLine "HW_FindHome"
    End If
    
    g_bAtHome = False
    g_bAtPark = False
    g_handBox.RefreshLEDs
    g_dTargetAz = g_dSetHome
    g_eSlewing = slewHome
    
End Sub

Public Sub HW_Halt()
    
    If Not g_show Is Nothing Then
        If g_show.chkHW.Value = 1 Then _
            g_show.TrafficLine "HW_Halt"
    End If

    g_dTargetAlt = g_dDomeAlt
    g_eSlewing = slewNowhere
    
    ' clear home / park (state is fragile in standard)
    If g_bStandardAtPark Then g_bAtPark = False
    If g_bStandardAtHome Then g_bAtHome = False
    
    g_handBox.RefreshLEDs
     
    ' If the shutter is in motion, then cause it to jam
    If g_dOCProgress > 0 Then
        g_dOCProgress = 0
        g_eShutterState = shutterError
    End If

End Sub

Public Sub HW_Move(Az As Double)

    If Not g_show Is Nothing Then
        If g_show.chkHW.Value = 1 Then _
            g_show.TrafficLine "HW_Move: " & Format$(Az, "000.0")
    End If
    
    g_bAtHome = False
    g_bAtPark = False
    g_handBox.RefreshLEDs
    g_dTargetAz = Az
    g_eSlewing = slewSomewhere
    
End Sub

Public Sub HW_MoveShutter(Alt As Double)

    If Not g_show Is Nothing Then
        If g_show.chkHW.Value = 1 Then _
            g_show.TrafficLine "HW_MoveShutter: " & Format$(Alt, "00.0")
    End If
    
    ' If the shutter is opening or closing, then cause it to jam
    If g_dOCProgress > 0 Then
        g_dOCProgress = 0
        g_eShutterState = shutterError
    Else
        g_dTargetAlt = Alt
    End If
    
End Sub

Public Sub HW_OpenShutter()
    
    If Not g_show Is Nothing Then
        If g_show.chkHW.Value = 1 Then _
            g_show.TrafficLine "HW_OpenShutter"
    End If
    
    ' Ensure that the Alt stays in bounds
    If g_dMinAlt > g_dDomeAlt Then
        g_dTargetAlt = g_dMinAlt
        g_dDomeAlt = g_dMinAlt
    End If
    
    If g_dMaxAlt < g_dDomeAlt Then
        g_dTargetAlt = g_dMaxAlt
        g_dDomeAlt = g_dMaxAlt
    End If

    If g_eShutterState = shutterOpen Then _
        Exit Sub
    
    If g_eShutterState = shutterError Then _
        Exit Sub
    
    g_dOCProgress = g_dOCDelay
    g_eShutterState = shutterOpening
    
End Sub

Public Sub HW_Park()
    
    If Not g_show Is Nothing Then
        If g_show.chkHW.Value = 1 Then _
            g_show.TrafficLine "HW_Park"
    End If
    
    g_bAtHome = False
    g_bAtPark = False
    g_handBox.RefreshLEDs
    g_dTargetAz = g_dSetPark
    g_eSlewing = slewPark
    
End Sub

Public Sub HW_Run(Dir As Boolean)
    
    If Not g_show Is Nothing Then
        If g_show.chkHW.Value = 1 Then _
            g_show.TrafficLine "HW_Run: " & Dir
    End If
    
    g_bAtHome = False
    g_bAtPark = False
    g_handBox.RefreshLEDs
    g_eSlewing = IIf(Dir, slewCW, slewCCW)
    
End Sub

Public Sub HW_Sync(Az As Double)

    If Not g_show Is Nothing Then
        If g_show.chkHW.Value = 1 Then _
            g_show.TrafficLine "HW_Sync: " & Format$(Az, "000.0")
    End If

    g_eSlewing = slewNowhere
    g_dTargetAz = Az
    g_dDomeAz = g_dTargetAz

    ' Handle standard (fragile) and non-standard park/home changes
    If g_bStandardAtHome Then
        g_bAtHome = False                           ' Fragile (standard)
    Else
        g_bAtHome = HW_AtHome                       ' Position (non-standard)
    End If

    If g_bStandardAtPark Then
        g_bAtPark = False                           ' Fragile (standard)
    Else
        g_bAtPark = HW_AtPark                       ' Position (non-standard)
    End If
    
    g_handBox.RefreshLEDs
    
End Sub

