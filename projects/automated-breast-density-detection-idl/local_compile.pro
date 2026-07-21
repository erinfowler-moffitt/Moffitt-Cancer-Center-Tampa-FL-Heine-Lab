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
FUNCTION get_dense_2025, r, autoseg, dim, sig1, osig2, var_im, box, sa, flag
;get_dense_2025(r, full, nrsa, sig1, sig2, var_r, box, SA, flag)
	s=size(r)
	
	z1=where(autoseg eq 1, a1)
	df=(sa*(float(box)^2.))-1.0
	
	n1=n_elements(sig1)
	n2=n_elements(osig2)
	  
	pd=dblarr(n1, n2)-999.
	for i=0, n1-1 do begin &$
		for j=0, n2-1 do begin &$
			DET1=autoseg &$
    		DET2=autoseg &$
			
			thresh1=CHISQR_CVF(sig1[i], df) &$
	      	pop_var=mean(dim[z1], /double, /nan) &$
	      	norm1 = var_im*df/pop_var &$
			
			zf=where(norm1[z1] le thresh1, cnum1, complement=zd, ncomplement=cnum2) &$
      		det1[z1[zd]] = 2. &$
      		pop_var2=mean(dim[z1[zf]], /double, /nan) &$
      		othresh2=CHISQR_CVF(osig2[j], df) &$
      		if pop_var2 ne 0 then norm2=(df*var_im/pop_var2) else begin &$
        		print, 'fail pop_var2 is 0' &$
        		goto, jump &$
      		endelse &$
				
			di=where(norm2[z1] GT othresh2, d1, complement = fi, ncomplement = f1) &$
			det2[z1[di]] = 2. &$
			pd[i, j]=100.0*double(d1)/double(a1) &$
			jump: &$
    	endfor &$
	endfor
	flag=check_math()
	return,pd
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION get_dense_FFDM_raw, r, autoseg, lseg, dim, sig1, osig2, var_im, box, sa, flag
;get_dense_2025(r, full, nrsa, sig1, sig2, var_r, box, SA, flag)
	s=size(r)
	
	z1=where(autoseg eq 1, a1)
	z = where(lseg eq 1)
	df=(sa*(float(box)^2.))-1.0
	
	n1=n_elements(sig1)
	n2=n_elements(osig2)
	  
	pd=dblarr(n1, n2)-999.
	for i=0, n1-1 do begin &$
		for j=0, n2-1 do begin &$
			DET1=autoseg &$
    		DET2=autoseg &$
			
			thresh1 = CHISQR_CVF(sig1[i], df) &$
	      	pop_var = mean(dim[z], /double, /nan) &$
	      	norm1 = var_im*df/pop_var &$
			
			zf=where(norm1[z1] le thresh1, cnum1, complement=zd, ncomplement=cnum2) &$
      		det1[z1[zd]] = 2. &$
      		zf2 = where(norm1[z] le thresh1) &$
      		pop_var2=mean(dim[z[zf2]], /double, /nan) &$
      		othresh2=CHISQR_CVF(osig2[j], df) &$
      		if pop_var2 ne 0 then norm2=(df*var_im/pop_var2) else begin &$
        		print, 'fail pop_var2 is 0' &$
        		goto, jump &$
      		endelse &$
				
			di=where(norm2[z1] GT othresh2, d1, complement = fi, ncomplement = f1) &$
			det2[z1[di]] = 2. &$
			pd[i, j]=100.0*double(d1)/double(a1) &$
			jump: &$
    	endfor &$
	endfor
	flag=check_math()
	return,pd
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION get_dense_GE_image, r, autoseg, lseg, dim, sig1, osig2, var_im, box, sa, flag
;get_dense_2025(r, full, nrsa, sig1, sig2, var_r, box, SA, flag)
	s=size(r)
	
	z1=where(autoseg eq 1, a1)
	z = where(lseg eq 1)
	df=(sa*(float(box)^2.))-1.0
	
	n1=n_elements(sig1)
	n2=n_elements(osig2)
	  
	pd=dblarr(n1, n2)-999.
	im=fltarr(s[1]*n1, s[2]*n2)
	for i=0, n1-1 do begin &$
		for j=0, n2-1 do begin &$
			DET1=autoseg &$
    		DET2=autoseg &$
			
			thresh1 = CHISQR_CVF(sig1[i], df) &$
	      	pop_var = mean(dim[z], /double, /nan) &$
	      	norm1 = var_im*df/pop_var &$
			
			zf=where(norm1[z1] le thresh1, cnum1, complement=zd, ncomplement=cnum2) &$
      		det1[z1[zd]] = 2. &$
      		zf2 = where(norm1[z] le thresh1) &$
      		pop_var2=mean(dim[z[zf2]], /double, /nan) &$
      		othresh2=CHISQR_CVF(osig2[j], df) &$
      		if pop_var2 ne 0 then norm2=(df*var_im/pop_var2) else begin &$
        		print, 'fail pop_var2 is 0' &$
        		goto, jump &$
      		endelse &$
				
			di=where(norm2[z1] GT othresh2, d1, complement = fi, ncomplement = f1) &$
			det2[z1[di]] = 2. &$
			pd[i, j]=100.0*double(d1)/double(a1) &$
			print, pd[i, j] &$
			im[(i*s[1]):((i+1)*s[1])-1, ((n2-j-1)*s[2]):((n2-j)*s[2])-1]=DET2 &$
			jump: &$
    	endfor &$
	endfor
	flag=check_math()
	return,im
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION get_dense_return_image_2025, r, autoseg, dim, sig1, osig2, var_im, box, sa, flag
	
	s=size(r)
	
	z1=where(autoseg eq 1, a1)
	df=(sa*(float(box)^2.))-1.0
	
	n1=n_elements(sig1)
	n2=n_elements(osig2)
	
	pd=dblarr(n1, n2)-999.
	im=fltarr(s[1]*n1, s[2]*n2)
	for i=0, n1-1 do begin &$
		for j=0, n2-1 do begin &$
			DET1=autoseg &$
    		DET2=autoseg &$
    		
    		thresh1=CHISQR_CVF(sig1[i], df) &$
    		pop_var=mean(dim[z1], /double, /nan) &$
    		norm1=var_im*df/pop_var &$
    		
    		zf=where(norm1[z1] le thresh1, cnum1, complement=zd, ncomplement=cnum2) &$
    		det1[z1[zd]] = 2. &$
    		pop_var2=mean(dim[z1[zf]], /double, /nan) &$
    		othresh2=CHISQR_CVF(osig2[j], df) &$
    		if pop_var2 ne 0 then norm2=(df*var_im/pop_var2) else begin &$
       			print, 'fail pop_var2 is 0' &$
        		goto, jump &$
      		endelse &$
      		
      		di=where(norm2[z1] GT othresh2, d1, complement = fi, ncomplement = f1) &$
			det2[z1[di]] = 2. &$
		
			pd[i, j]=100.0*double(d1)/double(a1) &$
			print, pd[i, j] &$
			im[(i*s[1]):((i+1)*s[1])-1, ((n2-j-1)*s[2]):((n2-j)*s[2])-1]=DET2 &$
		
			jump: &$
		endfor &$
	endfor
	flag=check_math()
	return,im
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
		im[(i*s[1]):((i+1)*s[1])-1, ((n2-j-1)*s[2]):((n2-j)*s[2])-1]=bytscl(DET2) &$
		
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
im2=[[bytscl(tmp)], [bytscl(im)]]
flag=check_math()
return,im
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function get_mapp, target, warp, scale_factor0, scale_factor1, map_wtt, map_ttw
;;added on 06/21/2017
;;target is the distribution that we will mapped too
;;warp is the distribution we need to mapp
;;scale_factor0 is for target data that is non-integer
;;scale_factor1 is for warp data that is non-integer
;;mapp is returned to the user if they want it
;;newvar is returned at the bottom of this program 
;;and is the warp mapped to target
mini1=min(warp, max = maxi1)
h1=double(histogram(warp, binsize=scale_factor1, min=mini1, max=maxi1, location=num1)) 
while h1[0] ne 0 do begin &$
	mini1 = mini1-scale_factor1 &$
	h1=double(histogram(warp, binsize=scale_factor1, min=mini1, max=maxi1, location=num1)) &$
endwhile
while h1[-1] ne 0 do begin &$
	maxi1 = maxi1+scale_factor1 &$
	h1=double(histogram(warp, binsize=scale_factor1, min=mini1, max=maxi1, location=num1)) &$
endwhile
test = h1
trap = where(h1 ne 0, ct)
if ct gt 0 then test=interpol(h1[trap], num1[trap], num1, /quadratic)
cumh1= total(test, /cumulative, /double)
cumh1 = cumh1/max(cumh1)

;;create the cumulative sum for the warp distribution
mini = min(target, max = maxi)
h0=histogram(target, binsize=scale_factor0, min=mini, max=maxi, location=num0)
while h1[0] ne 0 do begin &$
	mini = mini-scale_factor0 &$
	h0=histogram(target, binsize=scale_factor0, min=mini, max=maxi, location=num0) &$
endwhile
while h0[-1] ne 0 do begin &$
	maxi = maxi+scale_factor0 &$
	h0=histogram(target, binsize=scale_factor0, min=mini, max=maxi, location=num0) &$
endwhile
test = h0
trap = where(h0 ne 0, ct)
if ct gt 0 then test = interpol(h0[trap], num0[trap], num0, /quadratic)
cumh0 = total(test, /cumulative, /double)
cumh0 = cumh0/max(cumh0)
;;create the cumulative sum for the target distribution

map_wtt=interpol(num0, cumh0, cumh1)
keep = where(finite(map_wtt) eq 1)
map_wtt = map_wtt[keep]

nwarp=(warp-num1[0])/scale_factor1
newvar=map_wtt[nwarp]

map_ttw=interpol(num1, cumh1, cumh0) ;;original map for target to warp... ;; couldn't get it to work;;
keep = where(finite(map_ttw) eq 1)
map_ttw = map_ttw[keep]

return, newvar
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



FUNCTION SDP_ORDER_SEG,f1,d11,seg, box
;;f1 is the f1=image-d11 image;;
;;d11 is the d11 image;;
;;seg is a 0 1 image that indicates the eroded breast region we will use;;
;;box is the size of the ROI that will move around the image;;
;;UPDATED on 2/4/2025 to have doubles instead of floats!;;

sz=size(seg)
;;consider the image seg[i,j]

xrange=total(seg, 2, /double, /nan)
;;xrange equals the number of pixels within the breast region of corresponding [i, *]
;; |||
;;column summations or the bottom to top of breast region given row and has the same dimensions of seg sz[1]

yrange=total(seg, 1, /double, /nan)
;;yrange equals the number of pixels within the breast region of corresponding [*, j]
;;__
;;__
;;__
;;row summations or how far out it goes from the left side given height and has the same dimensions of seg sz[2]

xmaxi = max(where(xrange ne 0), min=xmini)
;;finds the min and max of the breast region on the xaxis
ymaxi = max(where(yrange ne 0), min=ymini)
;;finds the min and max of the breast region on the yaxis

xdiff = xmaxi-xmini + 1
ydiff = ymaxi-ymini + 1
;;finds the box around the eroded breast region;;

tmp = dblarr(xdiff, ydiff)
d = tmp
f = tmp
tmp[*, *] = seg[xmini:xmaxi, ymini:ymaxi]
d[*, *] = double(d11[xmini:xmaxi, ymini:ymaxi])
f[*, *] = double(f1[xmini:xmaxi, ymini:ymaxi])
;;creates images that only incases the eroded breast region;;

sx = xdiff/box
sy = ydiff/box
;;create the new sx sy given the box shift;;

;;create three new images for variance, average, and new sized segmented image
vard = dblarr(sx+1,sy+1)
av = vard
seg_av_size=av
k=0
for i=0,xdiff-box,box do begin &$
	l=0 &$
	for j=0,ydiff-box,box do begin &$
		boxcheck=where(tmp[i:i+box-1,j:j+box-1] ne 1) &$
		;;This is so we only compute when all pixels in the box are within the eroded breast region;;
		if boxcheck[0] eq -1 then begin &$
			vard[k,l]=(4.0/4.0)*variance(d[i:i+box-1,j:j+box-1], /double, /nan) &$
			ave=mean(f[i:i+box-1,j:j+box-1], /double, /nan) &$
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
keep = where(seg_av_size eq 1.)
;;;;use the new seg_av_size to find the eroded breast region and only use those pixels in the analysis;;
x = av[keep]
y = vard[keep]
;;;;;;;;;;;;;;;;;;;;;;;;;;;
x = floor(x, /L64)
;;;;;;;;;fix X so you can sort;;;;;;;;;;;;;;;
sort_index1=sort(x)
x=x[sort_index1]
y=y[sort_index1]

x = long(x)
y = long(y)

;;;;;;;;sort a second time after letting the pixels be long;;;;;;;;;;
sort_index2 = sort(x)

x=x[sort_index2]
y=y[sort_index2]

mx=max(x, min=mn)
sig_av=1.0
v_ave=1.0

for i=mn,mx do begin &$
	k=where(x EQ i) &$
	if(k[0] NE -1) then begin &$
		sig_av=[sig_av,i] &$
		tp=total(double(y[k]), /double, /nan)/double(n_elements(k)) &$
		v_ave=[v_ave,tp] &$
	endif &$

endfor

sig_av=sig_av[2:*]
v_ave=v_ave[2:*]
xx=sig_av
yy=v_ave

r=dblarr(2,double(n_elements(xx)))

r[0,*]=xx[*]
r[1,*]=yy[*]

return,r
END



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
x=floor(x)
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





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SORTS THE SIGNAL DEPENDENT NOISE using the eroded breast region;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


FUNCTION SDP_ORDER_2021, f, d, seg, box, v, m, seg_av_size
;;f1 is the f1=image-d11 image;;
;;d11 is the d11 image;;
;;seg is a 0 1 image that indicates the eroded breast region we will use;;
;;box is the size of the ROI that will move around the image;;

sz=size(seg)
sx = floor(sz[1]/box)
sy = floor(sz[2]/box)

v = dblarr(sx+1,sy+1)
m = v
seg_av_size = v
k = 0
for i = 0, sz[1]-box, box do begin &$
	l=0 &$
	for j = 0, sz[2]-box, box do begin &$
		boxcheck=where(seg[i:i+box-1,j:j+box-1] ne 1, ct) &$
		if ct eq 0 then begin &$
			v[k, l] = variance(d[i:i+box-1, j:j+box-1], /double, /nan) &$
			m[k, l] = mean(f[i:i+box-1,j:j+box-1], /double, /nan) &$
			seg_av_size[k, l] = 1.0 &$
		endif &$
		l++ &$
	endfor &$
	k++ &$
endfor
keep=where(seg_av_size eq 1.)
y=v[keep]
x=floor(m[keep])

mx = max(x, min=mn)

sig_av = dindgen(mx-mn+1, start = mn, increment = 1)
v_ave = sig_av*0.
l=0
for i=mn, mx do begin &$
	k=where(x EQ i, ct) &$
	if ct gt 0 then v_ave[l] = mean(y[k], /double, /nan) else v_ave[l] = !values.D_NAN &$
	l++ &$
endfor
trap = where(finite(v_ave) eq 1)
sig_av = sig_av[trap]
v_ave = v_ave[trap]

r=transpose([[sig_av], [v_ave]])

return,r
END


