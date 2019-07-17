;Prain_nldasET.ncl
;
;***************************************************************************
load "/usr/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "/usr/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "/usr/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
  print("made it past load")
; LOAD THE NEEDED NLDAS2 VARIABLES FROM FILE LIST
  nldas_files = systemfunc("ls *FORA*.grb")
  f       = addfiles(nldas_files, "r")
  print("made it past addfiles")
  ListSetType (f, "join")
  APCP  = f[:]->A_PCP_110_SFC_acc1h
  DSWR = f[:]->DSWRF_110_SFC
  DLWR = f[:]->DLWRF_110_SFC
  TMP = f[:]->TMP_110_HTGL
  UGRD = f[:]->U_GRD_110_HTGL
  VGRD = f[:]->V_GRD_110_HTGL
  PRESS = f[:]->PRES_110_SFC
  SPFH = f[:]->SPF_H_110_HTGL
  lat_110 = f[:]->lat_110
  lon_110 = f[:]->lon_110
;  printVarSummary(P)
;  printVarSummary(ET)
  nlat=dimsizes(f[:]&lat_110)
  nlon=dimsizes(f[:]&lon_110)
  Pdims=dimsizes(APCP)
  ntim = Pdims(0)
  print("ntim:  " + ntim)
;LOOP OVER AND WRITE HOURLY FORCING
   hourly_forcing = new ((/ntim, 8/), double, -9999.0d)
   do i = 0, ntim-1
      hourly_forcing(i,0) = DSWR(i,1,1)
      hourly_forcing(i,1) = DLWR(i,1,1)
      hourly_forcing(i,2) = APCP(i,1,1) / 3600.0d
      hourly_forcing(i,3) = TMP(i,1,1)
      hourly_forcing(i,4) = UGRD(i,1,1)
      hourly_forcing(i,5) = VGRD(i,1,1)
      hourly_forcing(i,6) = PRESS(i,1,1)
      hourly_forcing(i,7) = SPFH(i,1,1)
   end do
   printVarSummary(hourly_forcing)
   write_matrix((/hourly_forcing/), "8F16.8", False)
   exit   
   end
