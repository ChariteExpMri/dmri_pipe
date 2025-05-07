#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri May 10 15:36:47 2024

@author: skoch
"""

print("QA:orthoview densitymap in standardSpacce, create png-");



import nibabel as nib
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
from PIL import Image,ImageEnhance
import os



b3 = nib.load('./../AVGT.nii').get_fdata()
f3 = nib.load('densMap_10k_SS.nii').get_fdata()

#b3 = nib.load('AVGT.nii').get_fdata()
#f3 = nib.load('densMap_10k_SS.nii').get_fdata()

sizvol=b3.shape[1]
#----
f3 = f3.astype(np.float64)
f3=f3*50

f3 = f3.astype(np.uint8)
f0=f3
#--------
b3 = b3.astype(np.float64)
b3=b3-b3.min()
b3=b3/b3.max()
b3=b3*255
#b3=b3.round
b3 = b3.astype(np.uint8)
b0=b3
#b3=ImageEnhance.Contrast(Image.fromarray(b3)).enhance(2)
#b3=b3.tolist()


#----- get midpoint-slices (orthoview)
#plt.imshow(b[:,:,b.shape[2]//2])  ;plt.show()

b1=b3[b3.shape[0]//2,:,:]
f1=f3[f3.shape[0]//2,:,:,:]

b2=b3[:,b3.shape[1]//2,:]
f2=f3[:,f3.shape[1]//2,:,:]

b3=b3[:,:,b3.shape[2]//2]
f3=f3[:,:,f3.shape[2]//2,:]

#-----------------------------
resizefac    = 2
transparency =  0.7
interp=3
#------SAGITAL-----------------------
ff = Image.fromarray(f1);
bb = Image.fromarray((b1)); bb =bb.convert('RGB');
siz=bb.size
bb=bb.resize((siz[0]*resizefac,siz[1]*resizefac),resample=3)
ff=ff.resize((siz[0]*resizefac,siz[1]*resizefac),resample=interp)
bb=bb.transpose(Image.ROTATE_90)
ff=ff.transpose(Image.ROTATE_90)
w1 = Image.blend(bb, ff, transparency)
w1 = ImageEnhance.Brightness(w1); w1 = w1.enhance(1.5)
#w1.save("new.png","PNG")
#------CORONAL-----------------------
ff = Image.fromarray(f2);
bb = Image.fromarray((b2)); bb =bb.convert('RGB');
siz=bb.size
bb=bb.resize((siz[0]*resizefac,siz[1]*resizefac),resample=3)
ff=ff.resize((siz[0]*resizefac,siz[1]*resizefac),resample=interp)
bb=bb.transpose(Image.ROTATE_90)
ff=ff.transpose(Image.ROTATE_90)
w2 = Image.blend(bb, ff, transparency)
w2 = ImageEnhance.Brightness(w2); w2 = w2.enhance(1.5)
#w2.save("new.png","PNG")


#------axial-----------------------
ff = Image.fromarray(f3);
bb = Image.fromarray((b3)); bb =bb.convert('RGB');
siz=bb.size
bb=bb.resize((siz[0]*resizefac,siz[1]*resizefac),resample=3)
ff=ff.resize((siz[0]*resizefac,siz[1]*resizefac),resample=interp)
#bb=bb.transpose(Image.ROTATE_90)
#ff=ff.transpose(Image.ROTATE_90)
w3 = Image.blend(ff, bb, transparency)
w3 = ImageEnhance.Brightness(w3); w3 = w3.enhance(1)
#w3.save("new1.png","PNG")
#----upper panel---
c1=np.concatenate((w2, w1), axis=1)
c1=Image.fromarray(c1)
#c1.save("new1.png","PNG")
#----lower panel----
#Out[209]: (474, 1128, 3)
#          (492, 636, 3)
c1siz=np.shape(c1)
w3siz=np.shape(w3)
z=np.zeros((w3siz[0],c1siz[1]-w3siz[1]  ,3)).astype(np.uint8)
c2=np.concatenate((w3, z ) , axis=1)
c2=Image.fromarray(c2)
#c2.save("new2.png","PNG")
#---merge panels----
cm=np.concatenate((c1,c2 ) , axis=0)
cm=Image.fromarray(cm)
#cm.save("new3.png","PNG")

cm2 = ImageEnhance.Brightness(cm); cm2 = cm2.enhance(2)
cm2.save("QA_densitymap_standardSpace_python.png","PNG")

# %% plot coronal slices
#============= coronar plot
nslices=20;
percent_startslice=10.0;

startslice=round(sizvol*1/percent_startslice);
slicelims=np.array([startslice,sizvol-startslice])

ixslices=ixslices=np.round(np.linspace(slicelims[0],slicelims[1], nslices )).astype(np.int64)
nsubplot=np.ceil(np.sqrt(nslices)).astype(np.int64)
pan=[];
nc=1;
s3=[];

#raise SystemExit



for i in range(1, nslices+1):
    #print(i)
    sliceidx=ixslices[i-1];
    #print(sliceidx)
    
    b2=b0[:,sliceidx,:]
    f2=f0[:,sliceidx,:,:]
    
    ff = Image.fromarray(f2);
    bb = Image.fromarray((b2)); bb =bb.convert('RGB');
    bb = ImageEnhance.Brightness(bb); bb = bb.enhance(1.5)
    siz=bb.size
    bb=bb.resize((siz[0]*resizefac,siz[1]*resizefac),resample=3)
    ff=ff.resize((siz[0]*resizefac,siz[1]*resizefac),resample=interp)
    bb=bb.transpose(Image.ROTATE_90)
    ff=ff.transpose(Image.ROTATE_90)
    w2 = Image.blend(bb, ff, transparency)
    
    if i==1:
        s3=np.zeros((1, np.shape(w2)[1]*nsubplot,3)).astype(np.uint8)
    
    if nc==1:
        pan=w2
    else:
        pan=np.append(pan,w2,axis=1)
       
    
    
    if nc==nsubplot:
        #nzeros=size(f2,2)*nsubplot-size(pan,2);  
       fillrest=np.zeros((w2.size[1], np.shape(w2)[1]*nsubplot-np.shape(pan)[1],3)).astype(np.uint8)
       pan=np.append(pan,fillrest,axis=1)
       
       s3=np.append(s3,pan,axis=0)
       nc=0
       pan=[]
    nc=nc+1   
    
s4=Image.fromarray(s3)
s4=ImageEnhance.Brightness(s4)
s4 = s4.enhance(3)
s4.save("QA_densitymap_standardSpace_coronar_python.png","PNG")
#plt.imshow(s4)  ;plt.show()
         
# %% ----------
















#============

raise SystemExit





