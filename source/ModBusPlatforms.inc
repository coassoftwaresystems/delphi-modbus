{$IFDEF DMB_DELPHIXE3}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or
  {$IFDEF DMB_DELPHI10_2_TOKYO}
                               pidLinux32 or pidLinux64 or
  {$ENDIF}
  {$IFDEF DMB_DELPHI10_1_BERLIN}
                               pidiOSDevice32 or pidiOSSimulator32 or
                               pidAndroid32Arm or pidAndroid64Arm or
                               pidiOSDevice64 or pidiOSSimulator64 or
  {$ELSE}
    {$IFDEF DMB_DELPHIXE4}
                               pidiOSDevice or pidiOSSimulator or
    {$ENDIF}
    {$IFDEF DMB_DELPHIXE5}
                               pidAndroid or
    {$ENDIF}
  {$ENDIF}
  {$IFDEF DMB_DELPHI10_3_RIO}
                               pidOSX32 or pidOSX64 or
  {$ELSE}
                               pidOSX or
  {$ENDIF}
                               0)] // Make statement complete with 0 (which is harmless)
{$ENDIF}
