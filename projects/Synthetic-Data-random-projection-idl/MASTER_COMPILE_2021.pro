;;Updates By Erin Fowler 05/2016;;
;;All mean/stddev/variance /double, /nan were added
;;check_math() was added to all programs to be a flag returned
;;/doube was added to all total()
;;/edge_wrap was changed to /edge_mirror on all CONVOL

;;Updates By Erin Fowler 01/2017;;
;;VT/HZ/DD code was updated by Dr. Heine to fix an issue with filters that are not same numbered 
;;(i.e. 11 22 33 44 55 66 were fine 21 31 41 51 ect were not)
;;this same issue was not an issue with "ALL/ORIGINAL" wavelet
;;corrlenskip_sigma is no longer a function and has been replaced with correlation_2017
;;The box with the piece from the image in it's center is no longer intiated as an intarr but a dblarr
;;It's size has been changed from 3*bx to 2*bx + 1
;;ref image has been changed from 2*bx to 2*bx + 1
;;alignment when shifting has been verified
;;width of k has been made an option for future manipulation (corrlenskip default was 0.01 see notes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Pro Rdpix, Image,X0, Y0 ;Read the value of the pixel under the cursor
      ;Display x,y and the pixel value under the cursor
;+
; NAME:
; RDPIX
;
; PURPOSE:
; Interactively display the X position, Y position, and pixel value
; of the cursor.
;
; CATEGORY:
; Image display.
;
; CALLING SEQUENCE:
; RDPIX, Image [, X0, Y0]
;
; INPUTS:
; Image:  The array that represents the image being displayed.  This
;   array may be of any type.  Rather reading pixel values from
;   the display, they are taken from this parameter, avoiding
;   scaling difficulties.
;
; OPTIONAL INPUT PARAMETERS:
; X0, Y0: The location of the lower-left corner of the image area on
;   screen.  If these parameters are not supplied, they are
;   assumed to be zero.
;
; OUTPUTS:
; None.
;
; COMMON BLOCKS:
; None.
;
; SIDE EFFECTS:
; The X, Y, and value of the pixel under the cursor are continuously
; displayed.
;
; RESTRICTIONS:
; None.
;
; PROCEDURE:
; Instructions are printed and the pixel values are printed as the
; cursor is moved over the image.
;
; Press the left or center mouse button to create a new line of output,
; saving the previous line.
;
; Press the right mouse button to exit the procedure.
;
; MODIFICATION HISTORY:
; DMS, Dec, 1987.
; Rob Montgomery (rob@hao.ucar.edu), 9/21/92;
;   Correct indices for case of !order = 1
;
;-

COMPILE_OPT strictarr
on_error,2              ;Return to caller if an error occurs
print,'Press left or center mouse button for new output line."
print,'... right mouse button to exit.'
s = size(image)
if s[0] ne 2 then message, 'Image parameter not 2d.'
s[1] = s[1]-1   ;To n-1
s[2] = s[2]-1
!mouse.button=0
if n_elements(x0) le 0 then x0 = 0
if n_elements(y0) le 0 then y0 = 0
if s[s[0]+1] ge 4 then form = 'F' else form = 'I'
case !version.os_family of
        'Windows': cr = string("15b) + $
        string("12b) ; carriage and new line
        'MacOS': cr = string("15b)      ; carriage return
        'unix': cr = string("15b)     ; carriage (for BC on
              ; UNIX use CR rather
              ; than CR/LF)
        else: cr = string("15b)       ; carriage return
endcase
form="($,'x=',i4,', y=',i4,', value=',"+form+",a)"
while !mouse.button ne 4 do begin
  CURSOR,x,y,2,/dev
  if (!mouse.button and 3) ne 0 then begin  ;New line?
     print,form="($,a)",string("12b)
     while (!mouse.button ne 0) do begin wait,.1 & CURSOR,x,y,0,/dev & end
    endif

  x = x-x0 & y = y - y0
  if (x le s[1]) and (y le s[2]) and (x ge 0) and (y ge 0) then begin
     if (!order eq 1) then yy = s[2] - y else yy = y
     print,form = form, x,y,Image[x,yy],cr
  endif
endwhile
print,form="(/)"
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION read_sas_txt, file
tmpN = ''
tags2 = ''
openr, 59, file
while (eof(59) ne 1) do begin &$
	readf, 59, tmpN  &$
	tags2=[tags2, tmpN] &$
endwhile
close, 59
tags2 = tags2[1:*]

n = n_elements(tags2)

tags2=strtrim(tags2, 2)
tmp = strsplit(tags2[0], '	', /extract, count = dn)


par=strarr(n, dn)+'-999'
for i=0, n-1 do begin &$
	tmp = strsplit(tags2[i], '	', /extract, count = ct) &$
	if ct eq dn then par[i, *] = tmp else print, ';FAIL! Incorrect number of tabs: ', ct, ' Correct number of tabs: ', dn, ' Location of Fail: ', i &$
endfor

return, par


end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION SMALL, IMAGE, FACTOR, DIL=DIL
;+
; NAME           small
; PURPOSE        reduce an image in size by a factor
; INPUTS         image: a 2-d array
; OPTIONAL INPUT factor: factor to reduce by
;                  default: factor=0 or not given = fit onto screen
;                dil: if set, dilate the image before reducing
;                  useful for to preserve lines in binary images
; RETURNS        the minimized image
; AUTHOR         Robert Velthuizen, DMIP, Wed Dec 17 1997
;                4-27-99, RPV: added dilation option
;-
d=size(image)
If n_params() lt 2 then factor=0
If factor le 0 then begin & $
    s_size=float(get_screen_size()) & $
    factor=ceil( d(1)/s_size(0)) > ceil(d(2)/s_size(1)) & $
endif
If (fix(factor) ne factor) then message,'ERROR: Only integer factors allowed'

copyim=image
If keyword_set (DIL) then begin
   s=bytarr(3,3)+1
   for i=0,factor-2 do copyim=dilate(copyim,s)
endif
news=d(1:2)/factor
return,rebin(copyim(0:news(0)*factor-1,0:news(1)*factor-1),news(0),news(1))
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function SCOTT_AZ_one_to_many,  var, caco, group, iter, flag
;;VAR is the variable
;;caco is the case status (CASES MUST BE 1)
;;Group is the matching element
;;iter is the number of iterations you want;;
;;THERE IS NO LOOP OR WAIT RUNS VERY FAST;;
;;returns mean AZ of iterations

ca=where(caco eq 1, nh, complement=co, ncomplement=m)

cas=var[ca]
con=var[co]

gcas=group[ca]
gcon=group[co]

Az=fltarr(iter)
rn=fix(randomu(seed, nh, iter)*nh)
diff=rn[*, *]*0.
for i=0, iter-1 do begin &$
	for j=0, nh-1 do begin &$
		trap=where(gcon eq gcas[rn[j, i]], ct) &$
		pick=fix(randomu(seed, 1)*ct) &$
		diff[j, i]=cas[rn[j, i]]-con[trap[pick]] &$
	endfor &$
endfor

cnt=diff[*, *]*0.
ind=where(diff gT 0, n) &$
indt=where(diff EQ 0, nt) &$
if n ne 0 then cnt[ind]=1.
if nt ne 0 then cnt[indt]=0.5
az=total(cnt, 1, /double)/float(nh)

res=mean(az, /double, /nan)
flag=check_math()
return, res
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function pvalue_one_to_many,  var, caco, group, iter, flag
;;VAR is the variable
;;caco is the case status (CASES MUST BE 1)
;;Group is the matching element
;;iter is the number of iterations you want;;
;;THERE IS NO LOOP OR WAIT RUNS VERY FAST;;
;;returns mean AZ of iterations

ca=where(caco eq 1, nh, complement=co, ncomplement=m)

cas=var[ca]
con=var[co]

gcas=group[ca]
gcon=group[co]

pvalue=fltarr(iter)
rn=fix(randomu(seed, nh, iter)*nh)
for i=0, iter-1 do begin &$
	var1=cas[rn[*, i]] &$
	var2=var1*0. &$
	for j=0, nh-1 do begin &$
		trap=where(gcon eq gcas[rn[j, i]], ct) &$
		pick=fix(randomu(seed, 1)*ct) &$
		var2[j]=con[trap[pick]] &$
	endfor &$
	res=tm_test(var1, var2, /paired) &$
	pvalue[i]=res[1] &$
endfor
res=mean(pvalue, /double, /nan)
flag=check_math()
return, res
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro black_space_removal, r, full, seg75, seg65, flag
sz=size(r)
t1=total(full, 1)
t2=total(full, 2)
xmax=max(where(t2 ne 0), min=xmin)
ymin=min(where(t1 ne 0), max=ymax)
full=full[xmin:(xmax+5.)<(sz[1]-1), (ymin-5.)>0:(ymax+5.)<(sz[2]-1)]
seg75=seg75[xmin:(xmax+5.)<(sz[1]-1), (ymin-5.)>0:(ymax+5.)<(sz[2]-1)]
seg65=seg65[xmin:(xmax+5.)<(sz[1]-1), (ymin-5.)>0:(ymax+5.)<(sz[2]-1)]
r=r[xmin:(xmax+5.)<(sz[1]-1), (ymin-5.)>0:(ymax+5.)<(sz[2]-1)]
flag=check_math()
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
pro add_back_on, r, full, seg75, seg65, gen, flag
sz=size(r)
num=(gen*2.)+100.
halfnum=fix(num/2.)
tmp1=dblarr(sz[1]+num, sz[2]+num)
tmp2=dblarr(sz[1]+num, sz[2]+num)
tmp3=dblarr(sz[1]+num, sz[2]+num)
tmp4=dblarr(sz[1]+num, sz[2]+num)
tmp1[halfnum:halfnum+sz[1]-1, halfnum:halfnum+sz[2]-1]=r*full
tmp2[halfnum:halfnum+sz[1]-1, halfnum:halfnum+sz[2]-1]=full
tmp3[halfnum:halfnum+sz[1]-1, halfnum:halfnum+sz[2]-1]=seg75
tmp4[halfnum:halfnum+sz[1]-1, halfnum:halfnum+sz[2]-1]=seg65
tmp1[0>(halfnum-sz[1]):halfnum-1, halfnum:halfnum+sz[2]-1]=reverse(r[0:(halfnum-1)<(sz[1]-1), *]*full[0:(halfnum-1)<(sz[1]-1), *], 1)
r=tmp1
full=tmp2
seg75=tmp3
seg65=tmp4
seg75[halfnum:halfnum+5, *]=0. &$
seg65[halfnum:halfnum+5, *]=0. &$
full[halfnum:halfnum+5, *]=0. &$
flag=check_math()
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function create_hanning, box, flag
sz=size(box)
x=0.5*(1.+ cos(2.*(!pi)*((findgen(sz[1]))-(sz[1]/2)+0.5)/(sz[1]-1)))
y=0.5*(1.+ cos(2.*(!pi)*((findgen(sz[2]))-(sz[2]/2)+0.5)/(sz[2]-1)))

hanning=double(x)#(double(y))

hbox=hanning*box
flag=check_math()
return, hbox
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION Run_Fourier_ARC, box, band, arc, micron, flag
;Ring integration over Fourier space im
;Author: John J. Heine, May 11, 2000
;Modifications: different way of calculated ellipses, RPV May 12,2000
;Modifications: FFT updates, Center Point, Center Circle-Center Point, Rings, Corner Return
;Modifications : Zero Pad

;micron must be enter as thus 70um or 100um (70. or 100.)

;; Fist step: create filter bands in Fourier space
;;revised on 01/24/2014 by E3F to do the mean removed / stddev and FFT in program;;
;;tmp1 is the image;;
;;tmp2 is the number of bands;;

sz=size(box)
tmp=(double(box[*, *])-mean(double(box), /double, /nan))
;box=dblarr(sz[1]*2., sz[2]*2.)
;xhalf=floor(sz[1]/2.)
;yhalf=floor(sz[2]/2.)
;box[xhalf:xhalf+sz[1]-1, yhalf:yhalf+sz[2]-1]=tmp

;f
im=abs(FFT(tmp, -1, /double))^2.
;im=rebin(fim, sz[1], sz[2])


;The output array is ordered in the same manner as almost all discrete Fourier transforms. Element 0 contains the zero frequency component, F0.


del=micron*(10.^(-3.))
;;70um * (1m/10^6um) * (10^3mm/1m) = .070mm
;;70um * 10^-3 = 0.070mm
fc=1./double(del)
sample=fc/2. ;;pow is the highest resolvable frequency following the niquist criteria;; we need to sample twice as fast to resolve it...
delf=sample/double(band)

nhx=fix(sz[1]/2.)
nhy=fix(sz[2]/2.)
nx=shift((findgen(sz[1])-nhx)/nhx, -nhx)
ny=shift((findgen(sz[2])-nhy)/nhy, -nhy)

x=(nx#(fltarr(sz[2])+1.))
y=((fltarr(sz[1])+1.)#ny)
spat=sqrt((x^2.)+(y^2.))
ang=atan(y, x)
trap=where(ang lt 0, ct)
if ct ne 0 then ang[trap]=!dpi+ang[trap]

spat=spat*sample

dst=((dindgen(band+1)+1.0)/double(band+1.))*sample
slice=((dindgen(arc+1))/double(arc))*!dtor*180.


dmap=spat*0.
amap=ang*0.
for k=0,band-1 do begin &$
	trap=where(spat gt dst[k] and spat le dst[k+1], ct) &$
	if ct ne 0 then dmap[trap]=k+1 &$
endfor
dmap[where(spat gt dst[band])]=band+1
dmap[0, 0]=-9.
for k=0, arc-1 do begin &$
	trap=where(ang lt slice[k+1] and ang ge slice[k], ct) &$
	if ct ne 0 then amap[trap]=k+1 &$
endfor


;;THIS IS WHERE THE MEAN SHOULD BE BUT IS ZERO BECAUSE OF MEAN REMOVAL;;
;;THIS point is NOT included in the center calculations;;
result=dblarr(band+2, arc)
;tmp=im &$
;around=0.
for k=0,band+1 do begin &$
	for a=1, arc do begin &$
		z=where(dmap eq k and amap eq a, ct) &$
		if ct ne 0 then result[k, a-1]=total(im[z], /double) &$
	endfor &$
endfor
flag=check_math()
return,result
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION Run_Fourier_ARCBAND, box, freq, arc, micron, flag
;Ring integration over Fourier space im
;Author: John J. Heine, May 11, 2000
;Modifications: different way of calculated ellipses, RPV May 12,2000
;Modifications: FFT updates, Center Point, Center Circle-Center Point, Rings, Corner Return
;Modifications : Zero Pad

;micron must be enter as thus 70um or 100um (70. or 100.)
;ARC must be in degrees

arc= !DtoR*arc[*]


;; Fist step: create filter bands in Fourier space
;;revised on 01/24/2014 by E3F to do the mean removed / stddev and FFT in program;;
;;tmp1 is the image;;
;;tmp2 is the number of bands;;

sz=size(box)
tmp=(double(box[*, *])-mean(double(box), /double, /nan))
;box=dblarr(sz[1]*2., sz[2]*2.)
;xhalf=floor(sz[1]/2.)
;yhalf=floor(sz[2]/2.)
;box[xhalf:xhalf+sz[1]-1, yhalf:yhalf+sz[2]-1]=tmp

;f
im=abs(FFT(tmp, -1, /center, /double))^2.
;im=rebin(fim, sz[1], sz[2])


;The output array is ordered in the same manner as almost all discrete Fourier transforms. Element 0 contains the zero frequency component, F0.


del=micron*(10.^(-3.))
;;70um * (1m/10^6um) * (10^3mm/1m) = .070mm
;;70um * 10^-3 = 0.070mm
fc=1./double(del)
sample=fc/2. ;;pow is the highest resolvable frequency following the niquist criteria;; we need to sample twice as fast to resolve it...
delf=sample/double(band)

nhx=fix(sz[1]/2.)
nhy=fix(sz[2]/2.)
nx=(dindgen(sz[1])-nhx)/nhx
ny=(dindgen(sz[2])-nhy)/nhy

x=(nx#(fltarr(sz[2])+1.))
y=((fltarr(sz[1])+1.)#ny)
spat=sqrt((x^2.)+(y^2.))
ang=atan(y, x)
trap=where(ang lt 0, ct)
if ct ne 0 then ang[trap]=!dpi+ang[trap]

spat=spat*sample

mask=spat*0.
trap=where(spat le max(freq) and spat ge min(freq) and ang le max(arc) and ang ge min(arc), ct)
mask[trap]=1.
if ct ne 0 then result=total(im[trap], /double)



return,result
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION Run_Fourier, tmp1, tmp2, flag
;Ring integration over Fourier space im
;Author: John J. Heine, May 11, 2000
;Modifications: different way of calculated ellipses, RPV May 12,2000
;Modifications: FFT updates, Center Point, Center Circle-Center Point, Rings, Corner Return
;Modifications : Zero Pad 

;; Fist step: create filter bands in Fourier space
;;revised on 01/24/2014 by E3F to do the mean removed / stddev and FFT in program;;
;;tmp1 is the image;;
;;tmp2 is the number of bands;;

sz=size(tmp1)
tmp=(double(tmp1[*, *])-mean(tmp1, /double, /nan))
;box=dblarr(sz[1]*2., sz[2]*2.)
;xhalf=floor(sz[1]/2.)
;yhalf=floor(sz[2]/2.)
;box[xhalf:xhalf+sz[1]-1, yhalf:yhalf+sz[2]-1]=tmp

;f
im=abs(FFT(tmp, -1, /double))^2.
;im=rebin(fim, sz[1], sz[2])

band=tmp2
;The output array is ordered in the same manner as almost all discrete Fourier transforms. Element 0 contains the zero frequency component, F0.
;;OUR mean has already been removed so the center can be calculated


sd=size(im)
wx=shift(dindgen(sd[1])-(sd[1]/2-1),-sd[1]/2+1)/sd[1]
wy=shift(dindgen(sd[2])-(sd[2]/2-1),-sd[2]/2+1)/sd[2]
d=(wx # transpose(dblarr(sd[2])+1))^2 + ((dblarr(sd[1])+1) # transpose(wy))^2
;xs=D(indgen(band+1)+1) ;;does nothing
xs=findgen(band+1)+1.0
xs=.5*xs/double(band+1.0)
dst=(reverse(xs))^2
dmap=fltarr(sd[1],sd[2])
for k=1,band do begin &$
	;print, k+1 &$
	trap=where(d le dst[k-1] and d gt dst[k], ct) &$
	if ct ne 0 then dmap[where(d le dst[k-1] and d gt dst[k])]=k+1 &$
endfor
dmap[where(d gt dst[0])]=1
dmap[0, 0]=-9.
;;THIS IS WHERE THE MEAN SHOULD BE BUT IS ZERO BECAUSE OF MEAN REMOVAL;;
;;THIS point is NOT included in the center calculations;;
n0=where(dmap eq 0)
n1=where(DMAP eq 1)
centr=total(im[n0], /double)
cornr=total(im[n1], /double)
;; Calculate power in each band
p=dblarr(band)
for k=1,band do begin &$
	z=where(dmap eq k+1) &$
	if z[0] ne -1 then p[k-1]=total(im(z), /double) &$
endfor
res=[centr, reverse(p), cornr]
flag=check_math()
return,res
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION CUT_BOX, RawIm, SegIm,cutX0,cutX1,cutY0,cutY1, flag
;+
; Name:       CutIm
; PURPOSE:    Cut the largest possible box out of an LCC view image.
; Input:
;      RawIm--- Raw Lumisys image.
;      Segim--- Segmentation image of the raw image.
; Output:
; Output:
;       cut out box image.
;       (cutX0,cutY0)---- Lower left corner location.
;       (cutX1,cutY1)---- Upper right corner location.
;
; LIMITATION:    For LCC view image only.
;-
;;E3F modified on 10/09/2014;;
;;E3F modified on 02/16/2016;;
;;Put in so it would cutoff the left side margin before processing;; cutx0, cutx1 need this cutoff added back on at the end;;



im1in=RawIm  
im1=im1in
seg=segim

cutoff=min(where(total(seg, 2) ne 0))
seg=seg[cutoff:*, *]
im1=im1[cutoff:*, *]
im1in=im1in[cutoff:*, *]
d=size(im1in)

ywidth2=total(seg,2)
ymax=max(ywidth2,ipos)
seg(0:ipos[0],*)=0  
 
im1=im1*seg
ywidth=total(seg,1)   
ymax=max(ywidth,inx)  
ymonotone=0.0*ywidth  
ymonotone[inx]=ymax  
for i=inx-1,0,-1 do ymonotone[i]=ywidth[i] < ymonotone[i+1]  
for i=inx+1,d[2]-1 do ymonotone[i]=ywidth[i] < ymonotone[i-1]  
ymonotone=[0,ymonotone,0]  

Lowery=round(interpol(indgen(inx+2)-1,[ymonotone[0:inx],ymax],indgen(ymax-1)))  
uppery=round(interpol(reverse(indgen(d[2]-inx+2)+inx),$
reverse(ymonotone[inx:*]),indgen(ymax-1))) 
area=smooth(reverse((uppery-lowery)*findgen(ymax-1)),21)  

maxareas=where(area[1:*] - area lt 0)  
index=0  
while area[maxareas(index)] lt 0.67*max(area) do index=index+1  
aindex=ymax-3-maxareas(index)  
nNum=n_elements(lowery) 
;seg=fillin(seg)

for i=aindex,nNum-2 do begin & $  ;;; Find (x,y) for contained rectangle
   aindex=aindex+1        & $
   checkline=seg[*,lowery[aindex]]   & $
   ones=where(checkline eq 1)        & $
   x00=(where(checkline(ones)-(checkline(ones))[1:*] ne 0,nx0))[0] & $
   if nx0 eq 1 then begin & $
      x0=x00  & $
      Goto, Cpoint &$
   endif      &$
endfor &$
;;;; If no condition meets,then setting a value to aindex and x0 both to following value.
flag=1 &$
aindex=ymax-3-maxareas(index) &$
x0=aindex &$
Cpoint: &$

ys=round([lowery[aindex],uppery[aindex]])  
x1=x0        
x0=0             
xmarg=round((x1-x0)*0.01) & ymarg=round((ys[1]-ys[0])*0.10)  
ys=ys+[ymarg,-ymarg] 

;;;;;;********************************************************

;;;;;; x11=x1-xmarg ;;;;;;   Original one. 5% on each side.
x11=x1              ;;;;;;   Modified one. 5% on only one side.

;;;;;; Above lines are assuming the breast im is starting at zero-edged. 


ones=where(seg eq 1)
XX=ones mod d[1]
mxx=max(XX,min=mxi)
 
;;;;;; For display purpose, and Lower left and upper right locations.

	x0=x0+mxi
	x11=x11+mxi
	x11=x11*0.90         					;;;;;;This pushes the margin to the left edge.
	if (x0 gt 50) then x0=x0*0.1				;;;;;;This makes sure the left side of the box is close to the left edge of image.
 	seg[x0+xmarg:x11<d[1]-1,ys[0]:ys[1]<d[2]-1]=2
	;print,'Cut image size:  ',(x1-xmarg)-x0-xmarg+1,ys[1]-ys[0]+1  
	;print,'lower point (x,y)',x0+xmarg,ys[0]  
	disp=im1  & mxd=2*max(im1)  
	disp[x0+xmarg:x11<d[1]-1,ys[0]]=mxd  
	disp[x0+xmarg:x11<d[1]-1,ys[1]<d[2]-1]=mxd  
	disp[x0+xmarg,ys[0]:ys[1]<d[2]-1]=mxd  
	disp[x11<d[1]-1,ys[0]:ys[1]<d[2]-1]=mxd  
;	wtv,disp  
	;set_plot,'x' & wtv,small(seg,4) & set_plot,'ps'       ;; ##DEBUG
	;tvscl,small(seg,10),xsize=6.5,ysize=9,/inches & erase  ;; ##DEBUG

	cutX0=round(x0+xmarg)
	cutX1=round(x11)
	cutY0=round(ys[0])
	cutY1=round(ys[1])
	
	out=im1in[cutX0:x11<d[1]-1,ys[0]:ys[1]<d[2]-1]

return,out     
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION dilate_erode_seg,full,parm, flag
;;FUNCTION CALL WILL LOOK LIKE seg=dilate_erode_seg(full, 0.75) or dil=dilate_erode_seg(full, 1.25);;
;;FULL is the name of the full segmented image: parm is the 1 +/- the amount wanted to erode (-) or dilate (+);;


;;Erin's Version 01.04.2011;;
;;Orginal found @ /data/Heine/work/Cao/R01_images/STUDY_IMAGES/Programs/erode_seg.pro;;
;;PARM needs to be what you want to expand or shrink;;
;;i.e. if you want to erode by 25% parm should be 0.75;;
;;if you want to dialate by 10% parm should be 1.1;;
;;this program now takes into consideration the margin of film images;;

b0=where(full eq 0)
cutoff=min(where(total(full, 2) ne 0))
seg0=full[cutoff:*, *]


sz=size(seg0)
y=total(seg0, 1)
tmp=max(y, middle)
x=findgen(sz[2])-middle
templ=where(y[0:middle] gt 0 and y[0:middle] lt 30, ct)
if ct gt 1 then kl=max(templ) else kl=fix(min(where(y[0:middle] gt 0)))
kl=fix(kl)
tempr=where(y[middle+1:*] gt 0 and y[middle+1:*] lt 30, ct)
if ct gt 1 then kr=min(tempr)+middle+1 else kr=fix(max(where(y[middle+1:*] gt 0))+middle+1)
kr=fix(kr)
r0=sqrt((x*x)+(y*y))
rtrim=(float(r0[kl:kr]))
r1=parm[0]*rtrim
xtrim=float(x[kl:kr])
ytrim=float(y[kl:kr])
strim=n_elements(xtrim)

k2=where(xtrim eq 0, c2)
k3=where(xtrim lt 0, c3)
k4=where(xtrim gt 0, c4)
k1=[k3, k4]
c1=c2+c3
th=fltarr(strim)
x01=fltarr(strim)
y01=fltarr(strim)
if c1 ne 0 then begin &$
	th[k1]=atan(ytrim[k1]/xtrim[k1]) &$
	if c3 ne 0 then x01[k3]=(-1)*r1[k3]*cos(th[k3]) &$
	if c4 ne 0 then x01[k4]=r1[k4]*cos(th[k4]) &$
endif
if c2 ne 0 then begin &$
	th[k2]=!pi/2.0 &$
	x01[k2]=0.0 &$
endif
y01=abs(r1*sin(th))
newseg=seg0*0.

x11=fix(x01+middle)
trap=where(x11 lt 0 or x11 gt sz[2]-1, complement=keep)
x11=x11[keep]
y01=y01[keep]
mini=min(x11)
maxi=max(x11)
di=maxi-mini+1
filly=fltarr(di)

for k=0,di-1 do begin &$
	temp=where(x11 eq mini+k) &$
	if (max(float(temp)) eq -1) then filly[k]=filly[k-1] else filly[k]=mean(y01[temp]) &$
endfor
trap=where(filly gt sz[1]-1 or filly lt 0, ct)
if ct ne 0 then filly[trap]=sz[1]-1 &$
fill=fltarr(sz[2])
loc=findgen(di)+mini
fill[loc]=filly
for ii=0,sz[2]-1 do if (fill[ii] gt 0) then newseg[0:fill[ii], ii]=1.

ret=full*0.
ret[cutoff:*, *]=newseg
if parm le 1.0 then ret[b0]=0.
flag=check_math()
return, ret

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION DBA,im, flag
;;FUNCTION CALL WILL LOOK LIKE RDBA=DBA(R*FULL, 0.75) OR RDBA=DBA(R, 0.75) WHERE R IS THE FILM IMAGE ALREADY SEGMENTED BY FULL OR NEEDS TO BE. FULL IS A ZERO ONE IMAGE ZERO*ANYTHING=ZERO 1*ANYTHING=ANYTHING.
;;;IM IS THE FULL SEGMENTED FILM IMAGE

; Purpose: 
;	Used to transform an Array  (Range: 0~~4095,Uint) image into an OD image.
im=float(im)
;p=.10
;t=p*4095.0
;kt=where(im GE 4095-t)
;im(kt)=0
od=-(float(im)-4010.1)/992.19
k=where(od LE 0.0)
if(k[0] NE -1) then od[k]=0.0
nim=29891.0*exp(-2.36*OD)
flag=check_math()
return,nim

END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;FOR LS-85
Function LumDBA, grayim, flag
;;FUNCTION CALL WILL LOOK LIKE RDBA=LumDBA(R*FULL, 0.75) OR RDBA=LumDBA(R, 0.75) WHERE R IS THE FILM IMAGE ALREADY SEGMENTED BY FULL OR NEEDS TO BE. FULL IS A ZERO ONE IMAGE ZERO*ANYTHING=ZERO 1*ANYTHING=ANYTHING.
;;;GRAYIM IS THE FULL SEGMENTED FILM IMAGE

; Purpose: 
;	Used to transform a lumisys  (Range: 0~~4095,Uint) image into an OD image.
;
; Date:
; 	05/10/2003

x_value=[3810,3810,3808,3797,3770,3721,3610,3408,3032,2481,1842,1304,1006,831,697,603,528,467,420,401]

y_value=[0.00,0.00,0.01,0.02,0.04,0.09,0.19,0.40,0.74,1.24,1.84,2.35,2.69,2.87,3.01,3.10,3.21,3.28,3.34,3.37]

result=linfit(x_value,y_value)

b=result[0]
m=result[1]

od=m*float(grayim)+b
f=where(od LE 0.0)
if(f[0] NE -1) then od[f]=0.0
outim=od

output=fix(29891.0*exp(-outim*2.36))
flag=check_math()
return,output
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function DBA_8bit_unknown, grayim, flag
;;FUNCTION CALL WILL LOOK LIKE RDBA=LumDBA(R*FULL, 0.75) OR RDBA=LumDBA(R, 0.75) WHERE R IS THE FILM IMAGE ALREADY SEGMENTED BY FULL OR NEEDS TO BE. FULL IS A ZERO ONE IMAGE ZERO*ANYTHING=ZERO 1*ANYTHING=ANYTHING.
;;;GRAYIM IS THE FULL SEGMENTED FILM IMAGE

; Purpose: 
;	Used to transform a lumisys  (Range: 0~~4095,Uint) image into an OD image.
;
; Date:
; 	05/10/2003

x_value=[3810,3810,3808,3797,3770,3721,3610,3408,3032,2481,1842,1304,1006,831,697,603,528,467,420,401]

slope=regress([0, 4095], [0, 255], const=c)
x_map=fix(x_value*slope[0])

y_value=[0.00,0.00,0.01,0.02,0.04,0.09,0.19,0.40,0.74,1.24,1.84,2.35,2.69,2.87,3.01,3.10,3.21,3.28,3.34,3.37]

;result=linfit(x_value,y_value)
result=linfit(x_map,y_value)

b=result[0]
m=result[1]

od=m*float(grayim)+b
f=where(od LE 0.0)
if(f[0] NE -1) then od[f]=0.0
outim=od

output=fix(29891.0*exp(-outim*2.36))
flag=check_math()
return,output
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION  get_filter_ODVH, im, im2, LF, filterhigh, filterlow, TMP_PATH, wavetype, flag
;;FUNCTION CALL WILL LOOK LIKE D=GET_FILTER_ODVH(R*FULL, FULL, IMAGE_NAME, FILTERHIGH, FILTERLOW, TMP_PATH, WAVETYPE)
;;IM IS THE R*FULL OR RDBA*FULL GIVEN DIGITIAL (R) OR FILM (RDBA) FORMAT.
;;IM2 IS JUST THE FULL IMAGE.
;;THERE WILL BE TWO STRARR BEFORE INITIATION OF THIS COMMAND THAT LOOKS LIKE:
;;b=['1', '2', '3', '4', '5', '6']
;;TXT=['ORIGINAL', 'VERTICAL', 'HORIZONTAL','DIAGONAL']
;;THIS WILL MAKE LOOPING EASIER FOR THE CREATION OF D IMAGES
;;FILTERHIGH IS ACTUALLY THE LOW PASS FILTER BUT IT HAS A HIGHER NUMBER;;
;;IF YOU GET HIGH LOW CONFUSED YOU WILL NOT GET AN ERROR MESSAGE BUT THE RETURNED FILTER IMAGE WILL BE ALL ZEROS.
;;SO IF YOU WANT A D 1 - 6 IMAGE YOU WOULD PASS THE FUNCTION D=GET_FILTER_ODVH(R*FULL, FULL, IMAGE_NAME, '6', '1', TMP_PATH, WAVETYPE) 
;;OR IF YOU ARE USING THE B STRARR  D=GET_FILTER_ODVH(R*FULL, FULL, IMAGE_NAME, B[5], B[0], TMP_PATH, WAVETYPE)
;;THERE ARE FOUR WAVELET TYPES ORIGINAL VERTICAL HORIZONTAL AND DIAGONAL.. ORIGINAL IS REALLY A COMBINATION OF VERTICAL HORIZONTAL AND DIAGONAL.
;;WAVE TYPE USES THE TXT COMMAND TO SELECT WHICH TYPE YOU WOULD LIKE TO LOOK AT.
;;SO IF YOU WANT D 2 4 WAVETYPE VERTICAL THEN YOU WOULD PASS THE FUNCTION D=GET_FILTER_ODVH(R*FULL, FULL, IMAGE_NAME, '4', '2', TMP_PATH, 'VERTICAL')
;;OR IF YOU WANT USING THE B AND TXT STRARRS D=GET_FILTER_ODVH(R*FULL, FULL, IMAGE_NAME, B[3], B[1], TMP_PATH, TXT[1])


;;TMP_PATH IS EXTREMELY IMPORTANT;;
;;YOU CAN NOT USE THE SAME TMP PATH IF YOU ARE RUNNING TWO PROGRAMS AT ONCE.;;
;;THEY HAVE TO BE UNIQ SO YOU ARE USING THE CORRECT .VFF IMAGE THAT IS CREATED INSIDE THE C CODE.
;;EXAMPLE: TMP_PATH='/data/Heine/work/Common_outputs/DS944_tmp_2015/'  ;;<- not that i have a / on the end this is also important;;

;;so if you want to run a loop of all possible wavelet filters from d11 to d66 the code would look like
;;wavelet=dblarr(n, 21, 4) 6+5+4+3+2+1
;;for l=0, 3 do begin &$ ;;wavetype
;;	ct=0 &$
;;	for k=0, 5 do begin &$ ;;filter low
;;		for j=k, 5 do begin &$ ;;filter high note that the lowest filter high can be is equal to filter low
;;			d=GET_FILTER_ODVH(R*FULL, FULL, IMAGE_NAME, B[j], B[k], TMP_PATH, txt[l]) &$
;;			wavelet[i, ct, l]=stddev(d[where(seg eq 1)]) &$
;;			print, ';', '	', b[j], '	', b[k], '	', txt[l], ct &$
;;			ct++ &$
;;		endfor &$
;;	endfor &$
;;endfor &$
r=im
full=im2
sz=size(r)
cutoff=min(where(total(full, 2) ne 0))
xmargin=200.
ymargin=200.

tmp1=dblarr(sz[1]+xmargin, sz[2]+(2*ymargin))
tmp1[xmargin:*, ymargin:sz[2]+ymargin-1]=r
if (2.*cutoff)+xmargin-1 le sz[1]-1 then newx=r[cutoff:(2.*cutoff)+xmargin-1, *] else begin &$
	newx=fltarr(xmargin+cutoff, sz[2]) &$
	tmp=r[cutoff:*, *] &$
	s=size(tmp) &$
	newx[0:s[1]-1, *]=tmp &$
endelse
tmp1[0:xmargin+cutoff-1, ymargin:sz[2]+ymargin-1]=reverse(newx, 1)
ylow=tmp1[*, ymargin:(ymargin*2.)-1]
yhigh=tmp1[*, sz[2]:sz[2]+ymargin-1]
tmp1[*, 0:ymargin-1]=reverse(ylow, 2)
tmp1[*,  sz[2]+ymargin:*]=reverse(yhigh, 2)




;;IM is the image you want to filter
;;IM2 is the FULL MASK of the image you want to filter;;
;;LF is tag name
;;;;This is a modification of the GET_FILTER_DIGITIAL.pro.
;;;;filterhigh and filterlow are string numbers such as 1 1 or 5 1 for filtering
;;ADDED TMP_PATH TO OUTSIDE OF PROGRAM;;

;print, lf, '	', filterhigh, '	', filterlow, '	', wavetype
;;;;;;fold out the image;;;;

;;fold out in the xleft ytop and ybottom direction writing into the margin cuttoff if it exsists;;

PTS=STRSPLIT(LF,'.',/EXTRACT)
;;make sures the tag on the end and dot is removed from image name;;

filetag_pre=TMP_PATH
check_file=findfile(filetag_pre,count=num)
comm_clean='rm '+filetag_pre+'*.*'
if num ne 0 then spawn, comm_clean
;;This checks to make sure there are no images left inside the tmps folder;;
;;If there is an image spawn, comm_clean deletes it;;
;;Therefore when the entire program is over the last image is inside;;

FPATH=TMP_PATH+PTS[0]
file=TMP_PATH+PTS[0]+'d1.vff'

;;;;write_vff is a procedure it will add .vff to FPATH
write_vff,hd, fix(tmp1),FPATH
;;writes an image that C can read;;
;;wrtie_vff is a special for our IDL;;
;;hd is a set variable that the guy wrote in;;

if wavetype eq 'ORIGINAL' then prog='/data/Heine/work/Erin/MASTER_MODULES/wavecode/wavecode' else begin &$
	if wavetype eq 'DIAGONAL' then prog='/data/Heine/work/Erin/MASTER_MODULES/wavecode/waveDD' else begin &$
		if wavetype eq 'VERTICAL' then prog='/data/Heine/work/Erin/MASTER_MODULES/wavecode/waveVT' else begin &$
			if wavetype eq 'HORIZONTAL' then prog='/data/Heine/work/Erin/MASTER_MODULES/wavecode/waveHZ' else begin &$
				print, 'wavetype FAIL please change your program to enter wavetype in all caps as either ORIGINAL, DIAGONAL, VERTICAL, or HORIZONTAL thank you' &$
				filter=-99. &$
				goto, jump &$
			endelse &$
		endelse &$
	endelse &$
endelse
;;I don't know how to open and look at this program =( ;;
;;I also have no idea what this does - E3F;;
OrigFile=FPATH &$
command=prog+' '+OrigFile+' 12 '+file+' '+filterhigh+' '+filterlow &$
;print, command
spawn, command &$
read_file,file, hd, filter &$
;;filter is the image that comes back;;

filter=filter[xmargin:*, ymargin:sz[2]+ymargin-1] &$
;;removes the add on and sets the image back to original size;;
jump: &$
flag=check_math()
return,filter
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro butterworth, input, output, sz, ff

nx=sz[1]+1
ny=sz[2]+1
;;x and y size plus 1 so they are odd

vx=dindgen(nx)-fix(nx/2)
vy=dindgen(ny)-fix(ny/2)
;;create an array with 0 in the center

nnx=double(nx)/2.0
nny=double(ny)/2.
;;variable set up for the w of the butterworth filter

rat=input/output
;rat is the ratio of the two resolutions.

m=10.0
p=2.0*m
;;ten pole filter;;

fcx=rat*nnx
fcy=rat*nny
;;set up the w in the x and y direction

Hx10=1.0/sqrt([1+(vx/fcx)^p])
hy10=1.0/sqrt([1+(vy/fcy)^p])
;;create the frequency reponse (gain) remember that sqrt(1) is one

gu=shift(hx10,fix(nnx)+1)
;;shift it so the drop is in the center

tu=fft(gu,1, /double)
hr=real_part(tu)
hi=imaginary(tu)
hr=shift(hr, 200)
;;keep the real part and shift so the ends are together

hr=hr/max(hr)
;;normalize

filt=hr(200-15:200+15)
;;capture the odd sized filter

ff=filt#filt
;;make it 2-dimensional

ff=ff/sqrt(total(ff^2., /double))
;;normalize by the sum of squares

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function var_box_redundant, im, box, step, cut, flag
;*******************************************************************
; NAME:-          var_box
; PURPOSE:-        
; USAGE:-         k=var_box(image_array,1024,)
; AUTHOR:-        received from Dr.John Heine                
; DATE:-          on 03/27/2001       
; MODIFICATIONS:- 10/15/2002 Monika Shinde
;                 documentation
;		02/15/2012 Erin Fowler changed size to box because size is also a function
;********************************************************************

if n_params(0) lt 2 then begin &$
	print, 'Needs a minimum of 2 parameters' &$
	return,-1 &$
endif &$

s=size(im)
x=cut
y=s[2]
op=fltarr(s[1],s[2])
;	
if (box gt x) OR (box gt y) then begin &$
	print,'Block size is greater than image size' &$
	return,-1 &$
endif

for i=0,x-1, box do begin &$
	for j=0,y-1, box do begin &$
		if (i+box-1 le x-1 ) AND (j+box-1 le y-1) then begin &$
			b1 = im[i:i+box-1, j:j+box-1] &$
			op[i:i+box/2-1, j:j+box/2-1] = stddev(b1, /double, /nan)^2 &$               ;
		endif &$
;
		if (i+step+box-1 le x-1) AND (j+box-1 le y-1) then begin &$  
			b2 = im[i+step:i+step+box-1, j:j+box-1] &$
			op[i+box/2:i+box-1, j:j+box/2-1] = stddev(b2, /double, /nan)^2 &$
                endif &$
;
		if (i+box-1 le x-1) AND (j+step+box-1 le y-1) then begin &$
			b3 = im[i:i+box-1, j+step:j+step+box-1] &$
			op[i:i+box/2-1, j+box/2:j+box-1] = stddev(b3, /double, /nan)^2 &$
		endif &$
;
		if (i+step+box-1 le x-1) AND (j+step+box-1 le y-1) then begin &$
			b4 = im[i+step:i+step+box-1, j+step:j+step+box-1] &$
			op[i+box/2:i+box-1, j+box/2:j+box-1] = stddev(b4, /double, /nan)^2 &$
		endif &$
        endfor &$
endfor
flag=check_math()
return,op
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function var_box_replace, im, box, step, cut, flag
;*******************************************************************
; NAME:-          var_box
; PURPOSE:-        
; USAGE:-         k=var_box(image_array,1024,)
; AUTHOR:-        received from Dr.John Heine                
; DATE:-          on 03/27/2001       
; MODIFICATIONS:- 10/15/2002 Monika Shinde <--- BAD GIRL!!
;                 documentation
;		08/08/2012 Erin Fowler changed the entire function to work
;********************************************************************

if n_params(0) lt 2 then begin &$
	print, 'Needs a minimum of 2 parameters' &$
	return,-1 &$
endif &$
;	
s=size(im)
x=cut
y=s[2]
op=fltarr(s[1],s[2])
;	
if (box gt x) OR (box gt y) then begin &$
	print,'Block size is greater than image size' &$
	return,-1 &$
endif

for i=0,x-1, step do begin &$
	for j=0,y-1, step do begin &$
		if (i+box-1 le x-1 ) AND (j+box-1 le y-1) then begin &$
			b1 = im[i:i+box-1, j:j+box-1] &$
			op[i:i+box-1, j:j+box-1] = stddev(b1, /double, /nan)^2 &$               ;
		endif &$
        endfor &$
endfor
flag=check_math()
return,op
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION mstage1, z1, dim, df, thresh, segim, var_im, flag
;*******************************************************************
; NAME:-          stage1
; PURPOSE:-        
; USAGE:-         k=stage1
; AUTHOR:-        received from Dr.John Heine                
; DATE:-          on 03/27/2001       
; MODIFICATIONS:- 08/06/2004 Deng
;                 documentation
;********************************************************************
pop_var=stddev(dim[z1], /double, /nan)^2
norm=var_im*df/pop_var
ztf=where(norm le thresh, cnum1, complement=ztd, ncomplement=cnum2)
 
if cnum1 ne 0 then norm[ztf]=1
if cnum2 ne 0 then norm[ztd]=2
norm=norm*segim
res=fix(norm)
flag=check_math()
return,res
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION get_dense, r, autoseg, dim, sig1, osig2, var_im, box, flag, file

s=size(r)

cutoff=min(where(total(autoseg, 2, /double) ne 0))

segtmp=autoseg
segtmp[0:cutoff+box+1,*]=4

z1=where(segtmp eq 1)
a1=float(n_elements(z1))

df=float(box)^2-1.0
n1=n_elements(sig1)
n2=n_elements(osig2)
pd=dblarr(n1, n2)
pd[*, *]=-999.
im=intarr(s[1]*n1, s[2]*n2)
tmp=intarr(s[1]*n1, s[2])
for i=0, n1-1 do begin &$
	for j=0, n2-1 do begin &$
		DET1=autoseg &$
		DET2=intarr(s[1],s[2]) &$
		DET1[0:cutoff+box+1,*]=4 &$
		
		thresh1=CHISQR_CVF(sig1[i], df) &$
		pop_var=stddev(dim[z1], /double, /nan)^2 &$
		norm=var_im*df/pop_var &$
		
		zf=where(norm[z1] le thresh1, cnum1, complement=zd, ncomplement=cnum2) &$
		pop_var2=stddev(dim[z1[zf]], /double, /nan)^2 &$
		othresh2=CHISQR_CVF(osig2[j], df) &$
		if pop_var2 ne 0 then norm2=(df*var_im/pop_var2)*autoseg else begin &$
			print, 'fail pop_var2 is 0' &$
			goto, jump &$
		endelse &$
		
		di=where(norm2[z1] GT othresh2, d1) &$
		fi=where(norm2[z1] LE othresh2, f1) &$
		
		if d1 ne 0 then DET2[z1[di]]=2 &$
		if f1 ne 0 then DET2[z1[fi]]=1 &$
		
		pd[i, j]=100.0*d1/a1 &$
		im[(i*s[1]):((i+1)*s[1])-1, ((n2-j-1)*s[2]):((n2-j)*s[2])-1]=DET2 &$
		
		jump: &$
	endfor &$
	tmp[(i*s[1]):((i+1)*s[1])-1, *]=bytscl(r*autoseg) &$
endfor
;tmp=bytscl([r*autoseg, r*autoseg]) 
im2=[[bytscl(im)], [tmp]]
if file ne '' then write_png, file, im2, order=0
flag=check_math()
return,pd
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION get_dense_return_image, r, autoseg, dim, sig1, osig2, var_im, box, flag

s=size(r)

cutoff=min(where(total(autoseg, 2, /double) ne 0))

segtmp=autoseg
segtmp[0:cutoff+box+1,*]=4

z1=where(segtmp eq 1)
a1=float(n_elements(z1))

df=float(box)^2-1.0
n1=n_elements(sig1)
n2=n_elements(osig2)
pd=dblarr(n1, n2)
pd[*, *]=-999.
im=intarr(s[1]*n1, s[2]*n2)
tmp=intarr(s[1]*n1, s[2])
for i=0, n1-1 do begin &$
	for j=0, n2-1 do begin &$
		DET1=autoseg &$
		DET2=intarr(s[1],s[2]) &$
		DET1[0:cutoff+box+1,*]=4 &$
		
		thresh1=CHISQR_CVF(sig1[i], df) &$
		pop_var=stddev(dim[z1], /double, /nan)^2 &$
		norm=var_im*df/pop_var &$
		
		zf=where(norm[z1] le thresh1, cnum1, complement=zd, ncomplement=cnum2) &$
		pop_var2=stddev(dim[z1[zf]], /double, /nan)^2 &$
		othresh2=CHISQR_CVF(osig2[j], df) &$
		if pop_var2 ne 0 then norm2=(df*var_im/pop_var2)*autoseg else begin &$
			print, 'fail pop_var2 is 0' &$
			goto, jump &$
		endelse &$
		
		di=where(norm2[z1] GT othresh2, d1) &$
		fi=where(norm2[z1] LE othresh2, f1) &$
		
		if d1 ne 0 then DET2[z1[di]]=2 &$
		if f1 ne 0 then DET2[z1[fi]]=1 &$
		
		pd[i, j]=100.0*d1/a1 &$
		im[(i*s[1]):((i+1)*s[1])-1, ((n2-j-1)*s[2]):((n2-j)*s[2])-1]=DET2 &$
		
		jump: &$
	endfor &$
	tmp[(i*s[1]):((i+1)*s[1])-1, *]=bytscl(r*autoseg) &$
endfor
;tmp=bytscl([r*autoseg, r*autoseg]) 
im2=[bytscl(tmp), bytscl(im)]
flag=check_math()
return,im2
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function create_hanning, box, flag
sz=size(box)
x=0.5*(1.+ cos(2.*(!pi)*((findgen(sz[1]))-(sz[1]/2)+0.5)/(sz[1]-1)))
y=0.5*(1.+ cos(2.*(!pi)*((findgen(sz[2]))-(sz[2]/2)+0.5)/(sz[2]-1)))

hanning=double(x)#(double(y))

hbox=hanning*box
flag=check_math()
return, hbox
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro create_law_filter, law_filter, flag
;E5 is a bndpass filter peak anout .25.
;S5; band pass centered at 0.5
;w5: band pass centered at .75
;R5 Hp 
;;;; RR > WW > SS > EE > LL

simple_filter=dblarr(5, 5)
simple_filter[*, 4] = double([1,-4,6,-4,1]) ;;[*, 0] = R
simple_filter[*, 3] = double([-1,2,0,-2,1]) ;;[*, 1] = W
simple_filter[*, 2] = double([-1,0,2,0,-1]) ;;[*, 2] = S
simple_filter[*, 1] = double([-1,-2,0,2,1]) ;;[*, 3] = E
simple_filter[*, 0] = double([1,4,6,4,1])   ;;[*, 4] = L

c=dblarr(5)
for i=0, 5-1 do c[i]=1./sqrt(total(simple_filter[*, i]^2., /double))
for i=0, 5-1 do simple_filter[*, i]=c[i]*simple_filter[*, i]
tmp=simple_filter[*, 1]*c[1]


name_scheme=reverse(['R5', 'W5', 'S5', 'E5', 'L5'])

l5=double([1,4,6,4,1])
l5=l5/total(l5, /double)

I=0
J=0
law_filter=create_struct(NAME_SCHEME[I]+NAME_SCHEME[J], L5#L5)
FOR I=0, 4 DO BEGIN &$
	IF I EQ 0 THEN START =1 ELSE START=0 &$
	FOR J=START, 4 DO BEGIN &$
		law_filter=create_struct(LAW_FILTER, NAME_SCHEME[I]+NAME_SCHEME[J], simple_filter[*, I]#simple_filter[*, J]) &$
	ENDFOR &$
ENDFOR

flag=check_math()

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro GET_CONVOL_STD_FULL, IM, box, LAWS, seg75, seg65, ret75, ret65, retbox, flag

SZ=SIZE(IM)
N=N_TAGS(LAWS)
b75=where(seg75 eq 1)
b65=where(seg65 eq 1)
ret75=dblarr(n)
ret65=dblarr(n)
retbox=dblarr(n)

for i=0, N-1 do begin &$
	TMP=LAWS.(I)
	IMNEW=convol(IM, tmp, /center, /edge_mirror) &$
	ret75[i]=stddev(imnew[b75], /double, /nan) &$
	ret65[i]=stddev(imnew[b65], /double, /nan) &$
	IMNEW=convol(box, tmp, /center, /edge_mirror) &$
	retbox[i]=stddev(IMNEW, /double, /nan) &$
endfor
flag=check_math()
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function co_occurence, im, distance, xy, flag
;; box is from the cut box program.
;; distance is the seperation of the to be explored
;; angle determines the x, y, and (x and y) direction of seperation must be on the order of 45 degrees
;; BITS is power of grey-level (i.e. RAW FFDM = 14 PROC: FFDM/FILM = 12: 8-bit FILM = 8)
;; THIS IS BECAUSE OF THE SUMMATION IN THE 2D histogram.. when double (not float) causes little differences on the order of 0.001
box=im
s=size(box)
box=box+1.

if xy eq 'x' then begin &$
  v_shift1x=shift(box,-Distance,0) &$
  v_shift1x=v_shift1x[0:s[1]-1-distance, *] &$
  box1x=box[0:s[1]-1-distance, *] &$
endif else begin &$
  v_shift1x=shift(box,0,Distance) &$
  v_shift1x=v_shift1x[*, distance:*] &$
  box1x=box[*, distance:*] &$
endelse

;;removed bits for space save;;
m1 = min(box1x, max = m2)
m3 = min(v_shift1x, max = m4)
co_box1x=hist_2d(box1x, v_shift1x, min1=m1, min2=m3, max1=m2, max2=m4)

sum1x=total(co_box1x, /double)

p1x=co_box1x/sum1x

sz=size(p1x)

;;changed for space saving.;;
x=(dindgen(sz[1])+m1) # (dblarr(sz[2])+1.)
y=(dblarr(sz[1])+1.) # (dindgen(sz[2])+m3)



p_xym1x=dblarr((sz[1]>sz[2])+1)

for i=0, sz[1]-1 do begin &$
  for j=0, sz[2]-1 do begin &$
    p_xym1x[abs((i+1)-(j+1))]=p_xym1x[abs((i+1)-(j+1))] + p1x[i, j] &$
  endfor &$
  ;print, i, sz[1]-1 &$
endfor

px1x=total(p1x, 2, /double) ;;sumation of j=1 to n def From Pressman (the image was compressed to a horizontal line)

py1x=total(p1x, 1, /double) ;;sumation of i=1 to n Def From Pressman (the image was compressed to a vertical line)

sx1x=px1x # (dblarr(sz[2])+1.)

sy1x=(dblarr(sz[1])+1) # py1x

mx1x=total(x*p1x, /double)

my1x=total(y*p1x, /double)

hxy1x=total((-1.)*p1x*alog10(Sx1x*Sy1x>1e-13), /double)

hx1x=total((-1.)*px1x*alog10(px1x>1E-13), /double)


hy1x=total((-1.)*py1x*alog10(py1x>1E-13), /double)

res=dblarr(11)
;;0 homogeneity: Lachmann
;;1 contrast;; FROM Lachmann and Pressman (T2)
;;2 differential inverse moment: Lachmann and Pressman (T5) [ex8feat F4 local homogeneity]
;;3 Diagonal Moment: Lachmann and Pressman (T18)
;;4 The Maximum of the Intensity Probability: Lachmann and Pressman (T16) [ex8feat F5 maximum probability]
;;5 Entropy: Pressman (T9) and Chandrasekaran [8] [ex8feat F3 entropy]
;;6 Difference Moment: Pressman (T4) [ex8feat F1 interia]
;;7 Angular Second Moment: Pressman (T1) and Chandrasekaran [7] [ex8feat F2 total energy]
;;8 Information Measure A: Pressman (T12) [ex8feat F8 total energy]
;;CLUSTER SHADE and CLUSTER PROMINENCE must come from the last paper...;;Huo
;;9 Cluster Shade: [ex8feat F6]
;;10 Cluster Prominence: [ex8feat F7]
p=p1x
p_xym=p_xym1x
hxy=hxy1x
hx=hx1x
hy=hy1x
mx=mx1x
my=my1x
sx=sx1x
sy=sy1x
res[*]=[total(p*(1./(1.+abs(x-y))), /double, /nan), total(dindgen((sz[1]>sz[2])+1.)^2. * p_xym , /double, /nan), total(p*(1./(1.+((x-y)^2.))) , /double, /nan), total(sqrt(0.5*abs(x-y)*p) , /double, /nan), max(p),total((-1.)*p*alog10(p>1E-13), /double, /nan), total(((x-y)^2.)*p, /double, /nan), total(p^2., /double, /nan),((total((-1.)*p*alog10(p>1E-13), /double, /nan))-hxy)/max([hx, hy]), total(((x[*]-mx[0]+y[*]-my[0])^3.)*p, /double, /nan), total(((x[*]-mx[0]+y[*]-my[0])^4.)*p, /double, /nan)]
flag=check_math()
return, res
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function correlation_2018, CUTBOX, half, sigma, width, flag
;;this function recieves the CUT BOX image and the half-even size of the box which will also be the jump size.

ss=n_elements(sigma)

;half=floor(bx/2.)
bx = (half*2.)+1
skip = half

sz=size(CUTBOX)
tmp=cutbox

s=size(tmp)
mask=dblarr(half*4. + 1., half*4. + 1.)

numx=fix((s[1]-bx)/skip)+1
numy=fix((s[2]-bx)/skip)+1

res=dblarr(numx, numy, ss)



mask[*, *]= 0
k=(-1.)*alog(width)/(double(half*2.))
;;exp(-kx)=0.01
;;exp(-kbx)=0.01
;;-kbx=alog(0.01)
;;-k=alog(0.01)/bx


x=[exp(reverse(dindgen(bx))*(-1.)*k), exp((dindgen(bx-1)+1)*(-1.)*k)]
ref=x#x
;ref2=ref+randomu(seed, bx*2, bx*2)
m=double(n_elements(ref))
;print, total(exp((-1.)*(((ref-z)/sigma)^2.)))/m


cx=0
for i=half, s[1]-half-1, skip do begin &$
	cy=0 &$
	for j=half, s[2]-half-1, skip do begin &$
		mask[*, *]= 0 &$
		;;set mask to zero to erase all prior information;;
		
		rp=tmp[i-half:i+half, j-half:j+half] &$
		rp=rp-mean(rp, /double, /nan) &$
		;;take out the scan box size and normalize by removing the mean.;;
		
		mask[HALF:(BX+HALF)-1, HALF:(bx+HALF)-1]=rp &$
		;;place the scan box in the zero padded image;;
		
		z=fft(mask, -1, /double) &$
		zabs=abs(z)^2. &$
		cor=double(fft(zabs, 1, /double)) &$
		;;taken the zero padded image and transform to Fourier domain;;
		;;in the fourier domain abs square to get rid of complex numbers;;
		;;note a multiplication in one domain is a convol in the other domain;;
		;;bring back to the image domain;;
		
		cors=shift(cor, BX-1, BX-1) &$
		;;shift the image so zero padding is in the center;;
		
		ncor=cors  &$
		
		if max(ncor) ne 0 then z=ncor/max(ncor) else z=ncor &$
		;;normalize by the max of the image before it gets cut out.;;
		
		for k=0, ss-1 do res[cx, cy, k]=mean(exp((-1.)*(((ref-z)/sigma[k])^2.)), /double, /nan) &$
		;;I used mean but is the same as total(exp())/n... which is the NUMBER normalized
		;print, numx, cx, numy, cy &$
		;;the sigma is small because of small numbers.
		cy++ &$
		
		;im=exp((-1.)*(((ref-z)/sigma)^2.)) &$
		;print, cx, cy &$
	endfor &$
	cx++ &$
endfor
result=dblarr(2, ss)
ct=double(n_elements(res[*, *, 0]))
for k=0, ss-1 do result[*, k]=[mean(res[*, *, k], /double, /nan), stddev(res[*, *, k], /double, /nan)]
flag=check_math()
return, result
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function correlation_2017, CUTBOX, bx, skip, sigma, width, flag
;;this function recieves the CUT BOX image and the width size of the box for scanning

ss=n_elements(sigma)

half=floor(bx/2.)

sz=size(CUTBOX)
tmp=cutbox

s=size(tmp)
mask=dblarr(bx*2. + 1., bx*2. + 1.)

numx=fix((s[1]-bx)/skip)+1
numy=fix((s[2]-bx)/skip)+1

res=dblarr(numx, numy, ss)



mask[*, *]= 0
k=(-1.)*alog(width)/(double(bx))
;;exp(-kx)=0.01
;;exp(-kbx)=0.01
;;-kbx=alog(0.01)
;;-k=alog(0.01)/bx


x=[exp(reverse(dindgen(bx+1))*(-1.)*k), exp((dindgen(bx)+1)*(-1.)*k)]
ref=x#x
;ref2=ref+randomu(seed, bx*2, bx*2)
m=double(n_elements(ref))
;print, total(exp((-1.)*(((ref-z)/sigma)^2.)))/m


cx=0
for i=half, s[1]-half-1, skip do begin &$
	cy=0 &$
	for j=half, s[2]-half-1, skip do begin &$
		mask[*, *]= 0 &$
		;;set mask to zero to erase all prior information;;
		
		rp=tmp[i-half:i+half, j-half:j+half] &$
		rp=rp-mean(rp, /double, /nan) &$
		;;take out the scan box size and normalize by removing the mean.;;
		
		mask[HALF+1:(BX+HALF), HALF+1:(bx+HALF)]=rp &$
		;;place the scan box in the zero padded image;;
		
		z=fft(mask, -1, /double) &$
		zabs=abs(z)^2. &$
		cor=double(fft(zabs, 1, /double)) &$
		;;taken the zero padded image and transform to Fourier domain;;
		;;in the fourier domain abs square to get rid of complex numbers;;
		;;note a multiplication in one domain is a convol in the other domain;;
		;;bring back to the image domain;;
		
		cors=shift(cor, BX, BX) &$
		;;shift the image so zero padding is in the center;;
		
		ncor=cors  &$
		
		if max(ncor) ne 0 then z=ncor/max(ncor) else z=ncor &$
		;;normalize by the max of the image before it gets cut out.;;
		
		for k=0, ss-1 do res[cx, cy, k]=mean(exp((-1.)*(((ref-z)/sigma[k])^2.)), /double, /nan) &$
		;;I used mean but is the same as total(exp())/n... which is the NUMBER normalized
		;print, numx, cx, numy, cy &$
		;;the sigma is small because of small numbers.
		cy++ &$
		
		;im=exp((-1.)*(((ref-z)/sigma)^2.)) &$
		;print, cx, cy &$
	endfor &$
	cx++ &$
endfor
result=dblarr(3, ss)
ct=double(n_elements(res[*, *, 0]))
for k=0, ss-1 do result[*, k]=[mean(res[*, *, k], /double, /nan), stddev(res[*, *, k], /double, /nan), sqrt(total((res[*, *, k]-mean(res[*, *, k], /double, /nan))^2., /double, /nan)/ct)]
flag=check_math()
return, result
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function create_contrast, CUTBOX, lbox, bbox, flag
;;this function recieves the CUT BOX image the width size of the smaller box for scanning and the width size of the larger box for scanning

;;CUTBOX is the CUT BOX
;;LBOX is the smaller box for scanning
;;BBOX is the larger box for scanning

if BBOX lt LBOX then begin &$
	tmp1=BBOX &$
	tmp2=LBOX &$
	
	LBOX=tmp1 &$
	BBOX=tmp2 &$
	print, 'THE LBOX AND BBOX HAVE BEEN SWITCHED' &$
endif
lhalf=floor(lbox/2.)
bhalf=floor(bbox/2.)

sz=size(CUTBOX)
tmp=dblarr(sz[1]+(BBOX*2), sz[2]+(BBOX*2))

tmp[BBOX:sz[1]+BBOX-1,BBOX:sz[2]+BBOX-1]=CUTBOX
tmp[0:BBOX-1, *]=reverse(tmp[bbox:(2*bbox)-1, *])
tmp[sz[1]+BBOX:*, *]=reverse(tmp[sz[1]:sz[1]+bbox-1, *])
tmp[*, 0:BBOX-1]=reverse(tmp[*, bbox:(2*bbox)-1], 2)
tmp[*, sz[2]+BBOX:*]=reverse(tmp[*, sz[2]:sz[2]+bbox-1], 2)

s=size(tmp)
dm=dblarr(s[1], s[2])
dv=dm

mask=intarr(bbox, bbox)
mask[bhalf-lhalf:bhalf+lhalf, bhalf-lhalf:bhalf+lhalf]=1
k0=where(mask eq 1, c1, complement=k1, ncomplement=c2)
;check=dv
;ct=0L
for i=bhalf, s[1]-bhalf-1 do begin &$
	for j=bhalf, s[2]-bhalf-1 do begin &$
		box=tmp[i-bhalf:i+bhalf-1, j-bhalf:j+bhalf-1] &$
		m0=mean(box[k0], /double, /nan) &$
		m1=mean(box[k1], /double, /nan) &$
		v0=variance(box[k0], /double, /nan) &$
		v1=variance(box[k1], /double, /nan) &$
		dm[i, j]=m0-m1 &$
		dv[i, j]=v0+v1 &$
		;check[i-bhalf:i+bhalf-1, j-bhalf:j+bhalf-1]=ct &$
		;ct++ &$
	endfor &$
	;wtv, small(check) &$
endfor

dm2=dm[BBOX:sz[1]+BBOX-1,BBOX:sz[2]+BBOX-1]
dv2=dv[BBOX:sz[1]+BBOX-1,BBOX:sz[2]+BBOX-1]

cim=100.*(dm2/sqrt(dv2))
flag=check_math()
return, cim
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function anisotropic_diffusion_edge, image, kk, lamda, flag
;;THIS IS FOR CUTBOX ONLY!!;;
sz=size(image)

center=image
i_n=center*0.
i_s=center*0.
i_e=center*0.
i_w=center*0.

i_n[*, 0:sz[2]-2]=center[*, 1:sz[2]-1] ;;NORTH;;
i_s[*, 1:sz[2]-1]=center[*, 0:sz[2]-2] ;;SOUTH;;
i_e[0:sz[1]-2, *]=center[1:sz[1]-1, *] ;;EAST;;
i_w[1:sz[1]-1, *]=center[0:sz[1]-2, *] ;;WEST;;

g_n=i_n-center
g_s=i_s-center
g_e=i_e-center
g_w=i_w-center

g_n[*, sz[2]-1]=0.
g_s[*, 0]=0.
g_e[sz[1]-1, *]=0.
g_w[0, *]=0.


c_n  =exp(-(kk*(g_n^2.)  ))
c_s  =exp(-(kk*(g_s^2.)  ))
c_e  =exp(-(kk*(g_e^2.)  ))
c_w  =exp(-(kk*(g_w^2.)  ))

test1=(g_n*c_n)
test2=(g_s*c_s)
test3=(g_w*c_w)
test4=(g_e*c_e)
test=test1+test2+test3+test4
trap=where(image ne 0, ct)
if ct ne 0 then begin &$
	test[trap]=test[trap]*lamda &$
	output=image &$
	output[trap]=output[trap] + test[trap] &$
endif

flag=check_math()
return, output
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;function anisotropic_diffusion_edge, input, kk, lamda, flag
;sz=size(input)
;
;center=input[1:sz[1]-2, 1:sz[2]-2]
;i_n=   input[1:sz[1]-2, 2:sz[2]-1] ;;NORTH;;
;i_s=   input[1:sz[1]-2, 0:sz[2]-3] ;;SOUTH;;
;i_e=   input[2:sz[1]-1, 1:sz[2]-2] ;;EAST;;
;i_w=   input[0:sz[1]-3, 1:sz[2]-2] ;;WEST;;
;
;
;g_n=i_n-center
;g_s=i_s-center
;g_e=i_e-center
;g_w=i_w-center
;
;
;c_n  =exp(-(kk*(g_n^2.)  ))
;c_s  =exp(-(kk*(g_s^2.)  ))
;c_e  =exp(-(kk*(g_e^2.)  ))
;c_w  =exp(-(kk*(g_w^2.)  ))
;
;
;output=input
;output[1:sz[1]-2, 1:sz[2]-2]=output[1:sz[1]-2, 1:sz[2]-2] + (lamda*(g_n*c_n + g_s*c_s + g_w*c_w + g_e*c_e))
;flag=check_math()
;return, output
;end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function anisotropic_diffusion_edge_corners, input, kk, lamda, flag
sz=size(input)

center=input[1:sz[1]-2, 1:sz[2]-2]
i_n=   input[1:sz[1]-2, 2:sz[2]-1] ;;NORTH;;
i_s=   input[1:sz[1]-2, 0:sz[2]-3] ;;SOUTH;;
i_e=   input[2:sz[1]-1, 1:sz[2]-2] ;;EAST;;
i_w=   input[0:sz[1]-3, 1:sz[2]-2] ;;WEST;;
i_ne=  input[2:sz[1]-1, 2:sz[2]-1] ;;NORTH EAST;;
i_nw=  input[0:sz[1]-3, 2:sz[2]-1] ;;NORTH WEST;;
i_se=  input[2:sz[1]-1, 0:sz[2]-3] ;;SOUTH EAST;;
i_sw=  input[0:sz[1]-3, 0:sz[2]-3] ;;SOUTH WEST;;
;help, center, i_n, i_s, i_e, i_w, i_ne, i_nw, i_se, i_sw
;print, input[5, 5], center[4, 4], i_n[4, 3], i_s[4, 5], i_e[3, 4], i_w[5, 4], i_ne[3, 3], i_nw[5, 3], i_se[3, 5], i_sw[5, 5]

;;HOW THE IMAGES SLIDE!
;;INPUT
;;;;;;;;;;;;;;;;;;;;;;;;
;;1 2 3 4 &;;5 5 5 5 &;;
;;1 2 3 4 5;;4 4 4 4 4;;
;;1 2 3 4 5;;3 3 3 3 3;;
;;1 2 3 4 5;;2 2 2 2 2;;
;;1 2 3 4 5;;1 1 1 1 1;;
;;;;;;;;;;;;;;;;;;;;;;;;
;;center
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;0 2 3 4 &;;0 5 5 5 &;;;;;;1 2 3 &;;;;4 4 4 &;;
;;0 2 3 4 5;;0 4 4 4 4;;;;;;1 2 3 4;;;;3 3 3 3;;
;;0 2 3 4 5;;0 3 3 3 3;;;;;;1 2 3 4;;;;2 2 2 2;;
;;0 2 3 4 5;;0 2 2 2 2;;;;;;1 2 3 4;;;;1 1 1 1;;
;;0 0 0 0 0;;0 0 0 0 0;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;north
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;0 2 3 4 &;;0 5 5 5 &;;;;;;1 2 3 &;;;;3 3 3 &;;
;;0 2 3 4 5;;0 4 4 4 4;;;;;;1 2 3 4;;;;2 2 2 2;;
;;0 2 3 4 5;;0 3 3 3 3;;;;;;1 2 3 4;;;;1 1 1 1;;
;;0 0 0 0 0;;0 0 0 0 0;;;;;;;;;;;;;;;;;;;;;;;;;;
;;0 0 0 0 0;;0 0 0 0 0;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;south
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;0 2 3 4 &;;0 5 5 5 &;;;;;;1 2 3 &;;;;5 5 5 &;;
;;0 2 3 4 5;;0 4 4 4 4;;;;;;1 2 3 4;;;;4 4 4 4;;
;;0 2 3 4 5;;0 3 3 3 3;;;;;;1 2 3 4;;;;3 3 3 3;;
;;0 2 3 4 5;;0 2 2 2 2;;;;;;1 2 3 4;;;;2 2 2 2;;
;;0 2 3 4 5;;0 1 1 1 1;;;;;;1 2 3 4;;;;1 1 1 1;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;east
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;0 0 3 4 &;;0 0 5 5 &;;;;;;;;1 2 &;;;;;;4 4 &;;
;;0 0 3 4 5;;0 0 4 4 4;;;;;;;;1 2 3;;;;;;3 3 3;;
;;0 0 3 4 5;;0 0 3 3 3;;;;;;;;1 2 3;;;;;;2 2 2;;
;;0 0 3 4 5;;0 0 2 2 2;;;;;;;;1 2 3;;;;;;1 1 1;;
;;0 0 0 0 0;;0 0 0 0 0;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;west
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;1 2 3 4 &;;5 5 5 5 &;;;;1 2 3 4 &;;4 4 4 4 &;;
;;1 2 3 4 5;;4 4 4 4 4;;;;1 2 3 4 5;;3 3 3 3 3;;
;;1 2 3 4 5;;3 3 3 3 3;;;;1 2 3 4 5;;2 2 2 2 2;;
;;1 2 3 4 5;;2 2 2 2 2;;;;1 2 3 4 5;;1 1 1 1 1;;
;;0 0 0 0 0;;0 0 0 0 0;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;north east
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;0 0 3 4 &;;0 0 5 5 &;;;;;;;;1 2 &;;;;;;3 3 &;;
;;0 0 3 4 5;;0 0 4 4 4;;;;;;;;1 2 3;;;;;;2 2 2;;
;;0 0 3 4 5;;0 0 3 3 3;;;;;;;;1 2 3;;;;;;1 1 1;;
;;0 0 0 0 0;;0 0 0 0 0;;;;;;;;;;;;;;;;;;;;;;;;;;
;;0 0 0 0 0;;0 0 0 0 0;;;;;;;;;;;;;;;;;;;;;;;;;;.run /data/Heine/work/Erin/MASTER_MODULES/MASTER_COMPILE.pro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;north west
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;1 2 3 4 &;;5 5 5 5 &;;;;1 2 3 4 &;;3 3 3 3 &;;
;;1 2 3 4 5;;4 4 4 4 4;;;;1 2 3 4 5;;2 2 2 2 2;;
;;1 2 3 4 5;;3 3 3 3 3;;;;1 2 3 4 5;;1 1 1 1 1;;
;;0 0 0 0 0;;0 0 0 0 0;;;;;;;;;;;;;;;;;;;;;;;;;;
;;0 0 0 0 0;;0 0 0 0 0;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;south east
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;0 0 3 4 &;;0 0 5 5 &;;;;;;;;1 2 &;;;;;;5 5 &;;
;;0 0 3 4 5;;0 0 4 4 4;;;;;;;;1 2 3;;;;;;4 4 4;;
;;0 0 3 4 5;;0 0 3 3 3;;;;;;;;1 2 3;;;;;;3 3 3;;
;;0 0 3 4 5;;0 0 2 2 2;;;;;;;;1 2 3;;;;;;2 2 2;;
;;0 0 3 4 5;;0 0 1 1 1;;;;;;;;1 2 3;;;;;;1 1 1;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;south west
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;1 2 3 4 &;;5 5 5 5 &;;;;1 2 3 4 &;;5 5 5 5 &;;
;;1 2 3 4 5;;4 4 4 4 4;;;;1 2 3 4 5;;4 4 4 4 4;;
;;1 2 3 4 5;;3 3 3 3 3;;;;1 2 3 4 5;;3 3 3 3 3;;
;;1 2 3 4 5;;2 2 2 2 2;;;;1 2 3 4 5;;2 2 2 2 2;;
;;1 2 3 4 5;;1 1 1 1 1;;;;1 2 3 4 5;;1 1 1 1 1;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

g_n=i_n-center
g_s=i_s-center
g_e=i_e-center
g_w=i_w-center
g_ne=i_ne-center
g_nw=i_nw-center
g_se=i_se-center
g_sw=i_sw-center

c_n  =exp(-(kk*(g_n^2.)  ))
c_s  =exp(-(kk*(g_s^2.)  ))
c_e  =exp(-(kk*(g_e^2.)  ))
c_w  =exp(-(kk*(g_w^2.)  ))
c_ne  =exp(-(kk*(g_ne^2.)  ))
c_nw  =exp(-(kk*(g_nw^2.)  ))
c_se  =exp(-(kk*(g_se^2.)  ))
c_sw  =exp(-(kk*(g_sw^2.)  ))


output=input
output[1:sz[1]-2, 1:sz[2]-2]=output[1:sz[1]-2, 1:sz[2]-2] + (lamda*(g_n*c_n + g_s*c_s + g_w*c_w + g_e*c_e + ((g_ne*c_ne + g_nw*c_nw + g_se*c_se + g_sw*c_sw)/SQRT(2.))))
flag=check_math()
return, output
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function get_mapp, target, warp, scale_factor0, scale_factor1, map_wtt
;;added on 06/21/2017
;;target is the distribution that we will mapped too
;;warp is the distribution we need to mapp
;;scale_factor0 is for target data that is non-integer
;;scale_factor1 is for warp data that is non-integer
;;mapp is returned to the user if they want it
;;newvar is returned at the bottom of this program 
;;and is the warp mapped to target
mini1=min(warp, max = maxi1)
mx=mean(warp, /double, /nan)
sx=stddev(warp, /double, /nan)
warp=(round(warp/scale_factor1)*scale_factor1)
h1 = 1.
while h1[0] ne 0 do begin &$
	mini1 = mini1-scale_factor1 &$
	h1=double(histogram(warp, binsize=scale_factor1, min=mini1, max=maxi1, location=num1)) &$
endwhile
;test = h1
;trap = where(h1 ne 0)
;test=interpol(h1[trap], num1[trap], num1, /quadratic)
cumh1= total(h1, /cumulative, /double)
cumh1 = cumh1/max(cumh1)

;;create the cumulative sum for the warp distribution
mini = min(target, max = maxi)
target=(round(target/scale_factor0)*scale_factor0)
n = n_elements(target)
h0 = 1.
while h0[0] ne 0 do begin &$
	mini = mini-scale_factor0 &$
	h0=histogram(target, binsize=scale_factor0, min=mini, max=maxi, location=num0) &$
endwhile
cumh0 = total(h0, /cumulative, /double)
cumh0 = cumh0/max(cumh0)
;;create the cumulative sum for the target distribution

map_wtt=interpol(num0, cumh0, cumh1)
trap = where(finite(map_wtt) eq 1)
map_wtt = map_wtt[trap]

nwarp=(warp-min(warp))/scale_factor1
newvar=map_wtt[nwarp]

;map_ttw=interpol(num1, cumh1, cumh0) ;;original map for target to warp... ;; couldn't get it to work;;

;norm_warp = (randomn(seed, n)*sx)+mx
;mini2=min(norm_warp, max = maxi2)
;scale_factor2 = (maxi2-mini2)/5000.
;norm_warp=(round(norm_warp/scale_factor2)*scale_factor2)
;h2 = 1.
;while h2[0] ne 0 do begin &$
;	mini2 = mini2-scale_factor2 &$
;	h2=double(histogram(norm_warp, binsize=scale_factor2, min=mini2, max=maxi2, location=num2)) &$
;endwhile
;cumh2= total(h2, /cumulative, /double)
;cumh2 = cumh2/max(cumh2)

;map_ttw=interpol(num2, cumh2, cumh0)
;mini2 = min(norm_warp)

return, newvar
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


function get_Hologic_covariates, idn, STUDY_LOG
par=read_sas_txt(STUDY_LOG)
tags=par[0, *]
par=par[1:*, *]
;;[*, 0] idn
;;[*, 1] AGE
;;[*, 2] Cancer Side
;;[*, 3] group
;;[*, 4] HRT
;;[*, 5] os=outside patient / M=Moffitt patient
;;[*, 6] MG date
;;[*, 7] BIRADS
;;[*, 8] race
;;[*, 9] ethnicity
;;[*, 10] BMI
;;[*, 11] MS 0 "experiencing menese" 1 "menopausal"
id=par[*, 0]
trap = where(strmid(id, 0, 1) eq 'R')
id[trap] = 'N'+strmid(id[trap], 1)

m=n_elements(idn)
index=fltarr(m)-999.
for i=0, m-1 do begin &$
	trap=where(id eq idn[i], ct) &$
	if ct eq 1 then index[i]=trap[0] else print, ct, '	', idn[i] &$
endfor
covar=strarr(m, 12)
covar[*, *]='-999'
covar[*, 0]=idn
trap=where(index ne -999)
covar[trap, *]=par[index[trap], *]
return, covar
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SORTS THE SIGNAL DEPENDENT NOISE using the eroded breast region;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


FUNCTION SDP_ORDER_SEG,f1,d11,seg, box
;;f1 is the f1=image-d11 image;;
;;d11 is the d11 image;;
;;seg is a 0 1 image that indicates the eroded breast region we will use;;
;;box is the size of the ROI that will move around the image;;

sz=size(seg)
;;consider the image seg[i,j]

xrange=total(seg, 2)
;;xrange equals the number of pixels within the breast region of corresponding [i, *]
;; |||
;;column summations or the bottom to top of breast region given row and has the same dimensions of seg sz[1]

yrange=total(seg, 1)
;;yrange equals the number of pixels within the breast region of corresponding [*, j]
;;__
;;__
;;__
;;row summations or how far out it goes from the left side given height and has the same dimensions of seg sz[2]

xmaxi=max(where(xrange ne 0), min=xmini)
;;finds the min and max of the breast region on the xaxis
ymaxi=max(where(yrange ne 0), min=ymini)
;;finds the min and max of the breast region on the yaxis

xdiff=xmaxi-xmini + 1
ydiff=ymaxi-ymini + 1
;;finds the box around the eroded breast region;;

tmp=fltarr(xdiff, ydiff)
d=tmp
f=tmp
tmp[*, *]=seg[xmini:xmaxi, ymini:ymaxi]
d[*, *]=float(d11[xmini:xmaxi, ymini:ymaxi])
f[*, *]=float(f1[xmini:xmaxi, ymini:ymaxi])
;;creates images that only incases the eroded breast region;;

sx=xdiff/box
sy=ydiff/box
;;create the new sx sy given the box shift;;

;;create three new images for variance, average, and new sized segmented image
vard=fltarr(sx+1,sy+1)
av=vard
seg_av_size=av
k=0
for i=0,xdiff-box,box do begin &$
	l=0 &$
	for j=0,ydiff-box,box do begin &$
		boxcheck=where(tmp[i:i+box-1,j:j+box-1] ne 1) &$
		;;This is so we only compute when all pixels in the box are within the eroded breast region;;
		if boxcheck[0] eq -1 then begin &$
			vard[k,l]=(4.0/4.0)*variance(d[i:i+box-1,j:j+box-1]) &$
			ave=mean(f[i:i+box-1,j:j+box-1]) &$
			av[k,l]=ave &$
			seg_av_size[k,l]=1.0 &$
		endif &$
		l=l+1 &$
	endfor &$
	k=k+1 &$
endfor
vard=vard[0:sx-1,0:sy-1]
av=av[0:sx-1,0:sy-1]
trap=where(av lt 0)
if trap[0] ne -1 then seg_av_size[trap]=0.

;;;;;change here
keep=where(seg_av_size eq 1.)
;;;;use the new seg_av_size to find the eroded breast region and only use those pixels in the analysis;;
x=av[keep]
y=vard[keep]
;;;;;;;;;;;;;;;;;;;;;;;;;;;
x=fix(x)
;;;;;;;;;fix X so you can sort;;;;;;;;;;;;;;;
sort_index1=sort(x)
x=x[sort_index1]
y=y[sort_index1]

x=long(x)
y=long(y)

;;;;;;;;sort a second time after letting the pixels be long;;;;;;;;;;
sort_index2=sort(x)

x=x[sort_index2]
y=y[sort_index2]

mx=max(x,min=mn)
sig_av=1.0
v_ave=1.0

for i=mn,mx do begin &$
	k=where(x EQ i) &$
	if(k[0] NE -1) then begin &$
		sig_av=[sig_av,i] &$
		tp=total(float(y[k]))/n_elements(k) &$
		v_ave=[v_ave,tp] &$
	endif &$

endfor

sig_av=sig_av[2:*]
v_ave=v_ave[2:*]
xx=sig_av
yy=v_ave

r=fltarr(2,n_elements(xx))

r[0,*]=xx[*]
r[1,*]=yy[*]

return,r
END
