[Variables]
; AIUsage right-click menu — provider switch on top, then the standard widget
; entries (mirrors @Resources/Scripts/Contexts/Widget.inc).
AIUsageContextTitle    = Codex
AIUsageContextAction   = [!WriteKeyValue Variables Provider "Codex" "#@#Variables\AIUsage.inc"][!SetVariable Provider "Codex"][!Refresh]
AIUsageContextTitle2   = Claude
AIUsageContextAction2  = [!WriteKeyValue Variables Provider "Claude" "#@#Variables\AIUsage.inc"][!SetVariable Provider "Claude"][!Refresh]
AIUsageContextTitle3   = ---
AIUsageContextAction3  = []
AIUsageContextTitle4   = #tEdit# "[#t[#WidgetName]]"
AIUsageContextAction4  = [!ActivateConfig "#CURRENTCONFIG#" "Settings.ini"]
AIUsageContextTitle5   = ---
AIUsageContextAction5  = []
AIUsageContextTitle6   = #tSmall#
AIUsageContextAction6  = [!WriteKeyValue Variables "[#WidgetName]WidgetSize" "Small" "#@#Variables\Layout.inc"][!ActivateConfig "#CURRENTCONFIG#" "Small.ini"]
AIUsageContextTitle7   = #tMedium#
AIUsageContextAction7  = [!WriteKeyValue Variables "[#WidgetName]WidgetSize" "Medium" "#@#Variables\Layout.inc"][!ActivateConfig "#CURRENTCONFIG#" "Medium.ini"]
AIUsageContextTitle8   = #tWide#
AIUsageContextAction8  = [!WriteKeyValue Variables "[#WidgetName]WidgetSize" "Wide" "#@#Variables\Layout.inc"][!ActivateConfig "#CURRENTCONFIG#" "Wide.ini"]
AIUsageContextTitle9   = #tLarge#
AIUsageContextAction9  = [!WriteKeyValue Variables "[#WidgetName]WidgetSize" "Large" "#@#Variables\Layout.inc"][!ActivateConfig "#CURRENTCONFIG#" "Large.ini"]
AIUsageContextTitle10  = ---
AIUsageContextAction10 = []
AIUsageContextTitle11  = #tRemoveWidget#
AIUsageContextAction11 = [!DeactivateConfig "#CURRENTCONFIG#"]
AIUsageContextTitle12  = ---
AIUsageContextAction12 = []
AIUsageContextTitle13  = #tSendFeedback#
AIUsageContextAction13 = ["https://forms.gle/ZtCrtG44SFG8eaQKA"]
AIUsageContextTitle14  = #tEditWidgets#
AIUsageContextAction14 = [!WriteKeyValue Variables SettingsTab "Widgets" "#@#Variables\Layout.inc"][!ToggleConfig "#ROOTCONFIG#" "Settings.ini"][!ActivateConfig "#ROOTCONFIG#" "Settings.ini"]
AIUsageContextAction15 =

[SetProviderTick]
Measure=String
String=#Provider#
DynamicVariables=1
UpdateDivider=1
IfMatch=Codex
IfMatchAction=[!SetVariable AIUsageContextTitle "Codex  [\x2714]"]
IfMatch2=Claude
IfMatchAction2=[!SetVariable AIUsageContextTitle2 "Claude  [\x2714]"]

[SetSizeTick]
Measure=String
String=#WidgetSize#
DynamicVariables=1
UpdateDivider=1
IfMatch=Small
IfMatchAction=[!SetVariable AIUsageContextTitle6 "#tSmall#  [\x2714]"]
IfMatch2=Medium
IfMatchAction2=[!SetVariable AIUsageContextTitle7 "#tMedium#  [\x2714]"]
IfMatch3=Wide
IfMatchAction3=[!SetVariable AIUsageContextTitle8 "#tWide#  [\x2714]"]
IfMatch4=Large
IfMatchAction4=[!SetVariable AIUsageContextTitle9 "#tLarge#  [\x2714]"]
