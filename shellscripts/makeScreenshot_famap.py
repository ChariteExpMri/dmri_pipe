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


#b3 = nib.load('AVGT.nii').get_fdata()
b3 = nib.load('./../AVGT.nii').get_fdata()
f3 = nib.load('fa_SS.nii').get_fdata()
#----
f3 = f3.astype(np.float64)
f3=f3*255

f3 = f3.astype(np.uint8)
#--------
b3 = b3.astype(np.float64)
b3=b3-b3.min()
b3=b3/b3.max()
b3=b3*255
#b3=b3.round
b3 = b3.astype(np.uint8)
#b3=ImageEnhance.Contrast(Image.fromarray(b3)).enhance(2)
#b3=b3.tolist()


#----- get midpoint-slices (orthoview)
#plt.imshow(b[:,:,b.shape[2]//2])  ;plt.show()

b1=b3[b3.shape[0]//2,:,:]
f1=f3[f3.shape[0]//2,:,:]

b2=b3[:,b3.shape[1]//2,:]
f2=f3[:,f3.shape[1]//2,:]

b3=b3[:,:,b3.shape[2]//2]
f3=f3[:,:,f3.shape[2]//2]

#-----------------------------
resizefac    = 2
transparency =  0.5
interp=3
#------SAGITAL-----------------------
ff = Image.fromarray(f1);
bb = Image.fromarray((b1)); bb =bb.convert('RGB');
siz=bb.size
bb=bb.resize((siz[0]*resizefac,siz[1]*resizefac),resample=3)
ff=ff.resize((siz[0]*resizefac,siz[1]*resizefac),resample=interp)
bb=bb.transpose(Image.ROTATE_90)
ff=ff.transpose(Image.ROTATE_90)

norm = (ff - np.min(ff)) / (np.max(ff) - np.min(ff))
cmap = plt.cm.jet  # colormap, it can be inferno, rainbow, viridis, etc
v = np.round(255 * cmap(norm)).astype(int)[:, :, :3]
w1=Image.blend(bb,Image.fromarray((v.astype(np.uint8))),transparency)
#plt.imshow(w1); plt.show(w1)
#w1.save("new.png","PNG")




#------CORONAL-----------------------
ff = Image.fromarray(f2);
bb = Image.fromarray((b2)); bb =bb.convert('RGB');
siz=bb.size
bb=bb.resize((siz[0]*resizefac,siz[1]*resizefac),resample=3)
ff=ff.resize((siz[0]*resizefac,siz[1]*resizefac),resample=interp)
bb=bb.transpose(Image.ROTATE_90)
ff=ff.transpose(Image.ROTATE_90)

norm = (ff - np.min(ff)) / (np.max(ff) - np.min(ff))
cmap = plt.cm.jet  # colormap, it can be inferno, rainbow, viridis, etc
v = np.round(255 * cmap(norm)).astype(int)[:, :, :3]
w2=Image.blend(bb,Image.fromarray((v.astype(np.uint8))),transparency)
#plt.imshow(w2); plt.show(w2)
#w2.save("new.png","PNG")



#------axial-----------------------
ff = Image.fromarray(f3);
bb = Image.fromarray((b3)); bb =bb.convert('RGB');
siz=bb.size
bb=bb.resize((siz[0]*resizefac,siz[1]*resizefac),resample=3)
ff=ff.resize((siz[0]*resizefac,siz[1]*resizefac),resample=interp)
#bb=bb.transpose(Image.ROTATE_90)
#ff=ff.transpose(Image.ROTATE_90)


norm = (ff - np.min(ff)) / (np.max(ff) - np.min(ff))
cmap = plt.cm.jet  # colormap, it can be inferno, rainbow, viridis, etc
v = np.round(255 * cmap(norm)).astype(int)[:, :, :3]
w3=Image.blend(bb,Image.fromarray((v.astype(np.uint8))),transparency)
#plt.imshow(w3); plt.show(w3)
#w3.save("new.png","PNG")



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

cm2 = ImageEnhance.Brightness(cm)
cm2 = cm2.enhance(2)
cm2.save("QA_FAmap_standardSpace_python.png","PNG")



raise SystemExit





