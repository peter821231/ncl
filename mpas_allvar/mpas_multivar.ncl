;======================================================================
; mpas_multivar.ncl
;
; need ncks & in2p file
;
; Concepts illustrated:
;   - Drawing typhone track
;======================================================================
begin
;======================================================================
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


casename="bndb_mes"
levelname=(/"sfc","850","700","500","250"/)
varname=(/(/"mslp","u10","v10","t2m"/),                                                  \
         (/"height_850hPa","uzonal_850hPa","umeridional_850hPa","temperature_850hPa"/),  \
         (/"height_700hPa","uzonal_700hPa","umeridional_700hPa","temperature_700hPa"/),  \
         (/"height_500hPa","uzonal_500hPa","umeridional_500hPa","temperature_500hPa"/),  \
         (/"height_250hPa","uzonal_250hPa","umeridional_250hPa","temperature_250hPa"/)/) 

path1="/disk1/peter821231/PLOT/NPT_60-15-3_case/ncks_bndb_mes/"  ;in2p for uv
path2="/disk1/peter821231/PLOT/NPT_60-15-3_case/ncks_bndb_mes/"  ;mpas original gird


length = dimsizes(varname)
x = length(0)
y = length(1)

;print(varname)

  start_cpu_time = get_cpu_time()

  inp2number=systemfunc (" csh -c 'cd " + path1 + " ; ls mpas_inp2_*.nc'")
  nfiles=dimsizes(inp2number)
  filename = new(nfiles,string)
  filename = systemfunc ("csh -c 'cd " + path1 + " ; ls mpas_inp2_*.nc'")   
  print(filename)
  diagnumber=systemfunc (" csh -c 'cd " + path2 + " ; ls mpas_ncks_*.nc'")
  nfiles=dimsizes(diagnumber)
  filename2 = new(nfiles,string)
  filename2 = systemfunc ("csh -c 'cd " + path2 + " ; ls mpas_ncks_*.nc'")
  print(filename2)


  f2        = addfile(path2 + filename2(0),"r")
  
;---Read edge and lat/lon information
  r2d = 180.0d/(atan(1)*4.0d) ; conversion from radians to degrees.
  lonCell        = f2->lonCell * r2d
  latCell        = f2->latCell * r2d
  nCells = dimsizes(latCell)


do j = 0,nfiles-1

  f        = addfile(path1 + filename(j),"r")
  f3       = addfile(path2 + filename2(j),"r")

  xtime = f->xtime
  lat = f->lat
  lon = f->lon

  do k=0,x-1
  ;o_var =  f->$vars(i)$
;--------------------------------------
;| NEED TO MODIFY IF YOU ADD NEW VARS |
;--------------------------------------
  uzonal_ll = f->$varname(k,1)$
  umeridional_ll = f->$varname(k,2)$
  temp = f3->$varname(k,3)$(0,:)
  mslp = f3->$varname(k,0)$(0,:)
;  rh = f3 -> $varname(k,4)$(0,:)
  if (k .eq. 0) then
    mslp=mslp/100.
  end if
;---------------------------------------
;---Start the graphics

 wks_type = "png"
 wks = gsn_open_wks(wks_type,casename + "_"  + levelname(k) + "_" +xtime(0:12) )

;
;  setvalues NhlGetWorkspaceObjectId()
;    "wsMaximumSize" : 300000000
;  end setvalues
  gsn_define_colormap(wks,"BlAqGrYeOrRe")

;SET RESOURCES:

  title = "Nepartak " + casename + "_" + xtime(0:12)
res = True
res@gsnDraw             = False
res@gsnFrame            = False
res@gsnLeftString  = ""
res@gsnRightString = ""
res@gsnPanelRight = 0.5
mpres=res
vcres=res
cnres=res
cn2res=res

;---Set up some vector resources.
  vcres@vcLevelSelectionMode     = "ManualLevels"
;  vcres@vcMinLevelValF           = -20.0
;  vcres@vcMaxLevelValF           =  100.0
;   vcres@vcLevelSpacingF          = 50.0    ; 20.
;  vcres@vcLevelPalette           = "amwg_blueyellowred"   ; assign color map to vectors

;---Vector lengths and color
;vcres@vcGlyphStyle            = "CurlyVector"
;  vcres@vcGlyphStyle = "LineArrow"
  vcres@vcGlyphStyle = "FillArrow"
  vcres@vcFillArrowsOn            = True   
  vcres@vcLineArrowThicknessF     = 2.0
  vcres@vcFillArrowFillColor      = "white"
;  vcres@vcLineArrowColor          = "white"           ; change vector color
  vcres@vcFillArrowEdgeColor      = "black"
  vcres@vcFillArrowEdgeThicknessF = 2.0
  vcres@vcMinFracLengthF          = 0.33
  vcres@vcMinMagnitudeF           = 0.01
  vcres@vcMonoFillArrowFillColor  = True
  vcres@vcMonoLineArrowColor      = True

;REF arrow
  vcres@vcRefLengthF             = 0.045
  vcres@vcRefMagnitudeF          = 20.0
  vcres@vcRefAnnoOrthogonalPosF  = -1.3
  vcres@vcRefAnnoParallelPosF    =  0.997
  vcres@vcRefAnnoFontHeightF     = 0.01
  vcres@vcRefAnnoArrowLineColor   = "black"     ;change ref vector color
  vcres@vcRefAnnoArrowUseVecColor = False

;  vcres@lbTitlePosition          = "Bottom"
;  vcres@lbTitleString            = "Wind scale"
;  vcres@lbTitleOffsetF           = 0.
;  vcres@lbTitleFontHeightF       = 0.02
;  vcres@lbLabelFontHeightF       = 0.015
;  vcres@lbLabelAutoStride        = False
;  vcres@lbTopMarginF             = 0.5
;  vcres@lbBottomMarginF          = -0.5
  ;vcres@vcMinDistanceF          = 0.017       ; thin out vectors
;  cmap = read_colormap_file("BlAqGrYeOrReVi200")
;  vcres@vcLevelPalette      = cmap(6:193,:)

;---Make sure vectors are drawn in "predraw" phase.
  vcres@vcVectorDrawOrder        = "Predraw"


;PLOT PRE or HEIGHT

;---Turn on contour fill, and turn other things off.
  cnres@cnFillOn             = False
  cnres@cnLinesOn            = True
  cnres@cnInfoLabelOn        = True
;  cnres@lbTitleString        = mslp@long_name
;  cnres@lbTitlePosition      = "Right"
  cnres@lbTitleFontHeightF   = 1
  cnres@lbLabelFontHeightF   = 0.005
  cnres@lbRightMarginF             = 0.8
  cnres@lbLeftMarginF          = -0.1
  cnres@lbTitlePosition          = "Left"
  cnres@lbTitleOffsetF           = 0.
  cnres@lbLabelFontHeightF       = 0.015
  cnres@lbLabelAutoStride        = False
  cnres@lbTopMarginF             = 0.5
  cnres@lbBottomMarginF          = -1.
  cnres@lbLabelStride            = 1
  cnres@cnInfoLabelOrthogonalPosF = 0.12 
  cnres@gsnContourLineThicknessesScale = 2.5 ;thickness of cnline
  
  cnres@gsnRightString      = " "
  cnres@gsnLeftStringFontHeightF = 0.02
  
  if (k .eq. 0) then
    cnres@gsnLeftString       = mslp@long_name + " (hPa)"
   
   ;---Define contour levels
    cnres@cnLevelSelectionMode = "ManualLevels"
    cnres@cnMinLevelValF       = 940.0
    cnres@cnMaxLevelValF       = 1020.0
    cnres@cnLevelSpacingF      = 2.0
  else
    cnres@gsnLeftString       = mslp@long_name + " (" + mslp@units + ")"
  end if

  cnres@cnLineLabelPlacementMode = "constant"

 ;---Define contour levels
  if (k .eq. 1) then  ;850hpa
   ; cnres@cnLevelSelectionMode = "ManualLevels"
   ; cnres@cnMinLevelValF       = 1000.0
   ; cnres@cnMaxLevelValF       = 2000.0
   ; cnres@cnLevelSpacingF      = 10.0
   cnres@cnLevelSelectionMode = "ExplicitLevels"
   a=ispan(1000,1350,50)
   b=ispan(1400,2000,10)
   c= array_append_record(a,b,0)
 ;  print(c)
   cnres@cnLevels = c
   delete(a)
   delete(b)
   delete(c)
 
  else if (k .eq. 2) then ;700hpa
   ; cnres@cnLevelSelectionMode = "ManualLevels"
   ; cnres@cnMinLevelValF       = 2000.
   ; cnres@cnMaxLevelValF       = 5000.
   ; cnres@cnLevelSpacingF      = 10.0
  cnres@cnLevelSelectionMode = "ExplicitLevels"
   a=ispan(2000,3050,50)
   b=ispan(3000,5000,10)
   c= array_append_record(a,b,0)
   cnres@cnLevels = c
   delete(a)
   delete(b)
   delete(c)
  
  else if (k .eq. 3) then ;500hpa
  ; cnres@cnLevelSelectionMode = "ManualLevels"
  ;  cnres@cnMinLevelValF       = 5000.
  ;  cnres@cnMaxLevelValF       = 7000.
  ;  cnres@cnLevelSpacingF      = 10.0
   cnres@cnLevelSelectionMode = "ExplicitLevels"
   a=ispan(4000,5750,50)
   b=ispan(5800,7000,10)
   c= array_append_record(a,b,0)
   cnres@cnLevels = c
   delete(a)
   delete(b)
   delete(c)

  else if (k .eq. 4) then ;250hpa
   ; cnres@cnLevelSelectionMode = "ManualLevels"
   ; cnres@cnMinLevelValF       = 9000.0
    ;cnres@cnMaxLevelValF       = 13000.0
   ; cnres@cnLevelSpacingF      = 10.0
  cnres@cnLevelSelectionMode = "ExplicitLevels"
   a=ispan(9000,10000,50)
   b=ispan(10050,12000,10)
   c= array_append_record(a,b,0)
   cnres@cnLevels = c
   delete(a)
   delete(b)
   delete(c)
  
  end if
  end if
  end if
  end if

;---Make sure contours are drawn in "predraw" phase.
  cnres@cnFillDrawOrder      = "Predraw"
  r2d = 180.0d/(atan(1)*4.0d) ; conversion from radians to degrees.
  cnres@sfXArray  = f2->lonCell * r2d
  cnres@sfYArray  = f2->latCell * r2d


;PLOT TEMP

;---Turn on contour fill, and turn other things off.
  cn2res@cnFillOn             = True
  cn2res@cnFillMode           = "RasterFill"  ;faster but ugly(?)
  cn2res@cnRasterSmoothingOn  = True          ; not so ugly XD
  cn2res@cnLinesOn            = False
  cn2res@cnInfoLabelOn        = False
;  cnres@cnFillPalette        = "StepSeq25"
;  cnres@lbOrientation        = "Vertical"
  cn2res@lbTitleFontHeightF   = 0.01
  cn2res@lbTitleString        = temp@long_name + " (" + temp@units + ")"
;  cnres@lbTitlePosition      = "Right"
 ; cn2res@lbTitleFontHeightF   = 0.02
;  cnres@lbLabelFontHeightF   = 0.005
;  cnres@lbLabelAutoStride        = True
;  cnres@lbRightMarginF             = 0.8
;  cnres@lbLeftMarginF          = -0.1
  cn2res@lbTitlePosition          = "Bottom"
;  cnres@lbTitleString            = "Wind scale";  cn2res@lbTitleOffsetF           = 0.
  cn2res@lbTitleOffsetF           = 0.
  cn2res@lbTitleFontHeightF       = 0.02
  cn2res@lbLabelFontHeightF       = 0.015
  cn2res@lbLabelAutoStride        = False
  cn2res@lbTopMarginF             = 0.5
  cn2res@lbBottomMarginF          = -0.5
  cn2res@lbLabelStride            = 2

;---Define contour levels

if (k .eq. 0) then  ;sfc
  cn2res@cnLevelSelectionMode = "ManualLevels"
  cn2res@cnMinLevelValF       = 290.0
  cn2res@cnMaxLevelValF       = 305.0
  cn2res@cnLevelSpacingF      = 1
else if (k .eq. 1)  ;850hpa
  cn2res@cnLevelSelectionMode = "ManualLevels"
  cn2res@cnMinLevelValF       = 285.0
  cn2res@cnMaxLevelValF       = 295.0
  cn2res@cnLevelSpacingF      = 0.5
else if (k .eq. 2)  ;700hpa
  cn2res@cnLevelSelectionMode = "ManualLevels"
  cn2res@cnMinLevelValF       = 280.0
  cn2res@cnMaxLevelValF       = 287.0
  cn2res@cnLevelSpacingF      = 0.5
else if (k .eq. 3)  ;500hpa
  cn2res@cnLevelSelectionMode = "ManualLevels"
  cn2res@cnMinLevelValF       = 265.0
  cn2res@cnMaxLevelValF       = 272.0
  cn2res@cnLevelSpacingF      = 0.5
else if (k .eq. 4)  ;250hpa
  cn2res@cnLevelSelectionMode = "ManualLevels"
  cn2res@cnMinLevelValF       = 230.0
  cn2res@cnMaxLevelValF       = 239.0
  cn2res@cnLevelSpacingF      = 0.5
end if
end if
end if
end if
end if

;---Make sure contours are drawn in "predraw" phase.
  cn2res@cnFillDrawOrder      = "Predraw"
  r2d = 180.0d/(atan(1)*4.0d) ; conversion from radians to degrees. 
  cn2res@sfXArray  = f2->lonCell * r2d
  cn2res@sfYArray  = f2->latCell * r2d

;---Control appearance of map.
;  mpres@mpProjection           = "LambertEqualArea"
 ; mpres@mpDataBaseVersion = "HighRes"     ; Alias 'MediumRes'
 ; mpres@mpDataSetName     = "Earth..4"   
  mpres@mpLabelsOn             = True
  mpres@mpPerimOn              = True
  mpres@mpGridAndLimbOn        = True
  mpres@mpFillOn               = False
  mpres@mpOutlineOn            = True
  mpres@mpGridAndLimbOn      = True          ; default is every 15 deg
  mpres@mpGridSpacingF       = 30            ; change to match labels
  mpres@mpOutlineDrawOrder     = "PostDraw"
;  mpres@mpFillDrawOrder        = "Predraw"
;  mpres@mpOceanFillColor       = "lightskyblue1"
;  mpres@mpLandFillColor        = "gray"
  mpres@mpGeophysicalLineThicknessF = 5.0  ;change thickness of landsea line
  mpres@mpGeophysicalLineColor = "grey30" ;change color of landsea line
 ; mpres@mpCountyLineThicknessF = 20.0
;---Zoom in on area that is roughly the United States.
;  mpres@mpLimitMode            = "LatLon"
  mpres@mpMinLatF              =    0.
  mpres@mpMaxLatF              =   40.
  mpres@mpMinLonF              =  110.
  mpres@mpMaxLonF              =  170.
;  mpres@mpCenterLonF           = 130.0
;  mpres@mpCenterLatF           = 20.0

  mpres@mpGridAndLimbDrawOrder = "Predraw"
  mpres@tiMainString           = title
;
; Create, but don't draw, a vector, streamline, contour
; and map plot. Stride the vector and contour data to
; thin it a little.
;


;;plot;;
   map     = gsn_csm_map(wks,mpres)
   contour = gsn_csm_contour(wks,mslp,cnres)
   contour2 = gsn_csm_contour(wks,temp,cn2res)
   vector  = gsn_csm_vector(wks,uzonal_ll(::10,::10),umeridional_ll(::10,::10),vcres)

   overlay(map,contour)
   overlay(map,contour2)
   overlay(map,vector)
;*********************************************

   draw(map)  


   frame(wks)   
   delete(cnres)
   delete(cn2res)   
   
   end do
   delete(f)
   delete(f3)
   end_cpu_time = get_cpu_time()
   print("===> CPU elapsed time = " + (end_cpu_time-start_cpu_time))

   end do
   delete(f2)
end
