


function makeScreenshot_densemap(mrtrixpath)

cd(mrtrixpath);
disp('create sreenshots-matlab');
disp(['workingdir: ' pwd]);


%% ====read niftis===========================================
f1='./../AVGT.nii';
f2='densMap_10k_SS.nii';
try
hb = niftiinfo(f1);
b= niftiread(hb);
%---ovl
ha = niftiinfo(f2);
a= niftiread(ha);
catch
    [hb b]=rgetnii(f1);
    [ha a]=rgetnii(f2);
    
end


%% ===============================================
% figure
% imshow(imfuse(s2,t,'blend','Scaling','joint'),[]);
alph = 0.6;
resizfac=2;

try
siz=hb.ImageSize;
catch
    siz=hb.dim;
end
mid=round(siz/2);
%------
s=squeeze(b(mid(1),:,:));
t=squeeze(a(mid(1),:,:,:));
s2=repmat(s,[1 1 3]); s2=uint8(s2);
t2=round(t);
f1 = alph*im2double(s2) + (1-alph)*im2double(t2);
f1 = im2uint8(f1);
f1 =flipud(permute(f1,[2 1 3]));
f1=imresize(f1,resizfac);
% figure; imshow(f1)
% =================
s=squeeze(b(:,mid(2),:));
t=squeeze(a(:,mid(2),:,:));
s2=repmat(s,[1 1 3]); s2=uint8(s2);
t2=round(t);
f2 = alph*im2double(s2) + (1-alph)*im2double(t2);
f2 = im2uint8(f2);
f2 =flipud(permute(f2,[2 1 3]));
f2=imresize(f2,resizfac);
% figure; imshow(f2)
% ===============================================
s=squeeze(b(:,:,mid(3)));
t=squeeze(a(:,:,mid(3),:));
s2=repmat(s,[1 1 3]); s2=uint8(s2);
t2=round(t);
f3 = alph*im2double(s2) + (1-alph)*im2double(t2);
f3 = im2uint8(f3);
f3=imresize(f3,resizfac);
% figure; imshow(f3)

%% ===============================================
domax=max([size(f1,1) size(f2,1)]);
f11=uint8(zeros(domax,size(f1,2),3));
f11(1:size(f1,1),1:size(f1,2),:)=f1;
f22=uint8(zeros(domax,size(f2,2),3));
f22(1:size(f2,1),1:size(f2,2),:)=f2;

w=[[f22 f11]; [f22 f11].*0];
w(end-size(f3,1)+1:end,1:size(f3,2),: )=f3;
figure; imshow([w]);
imwrite(uint8(w),'QA_densitymap_standardSpace_matlab.png');

% ==============================================
%%   coronal slices
% ===============================================
nslices=20;
% bmean=mean(b(:));
% b2=b>bmean;
% slicvalid=find(sum(sum(b2,1),3)>0)
% ixslices=round(linspace(1,siz(2),nslices));
% ixslices=round(linspace(slicvalid(1),slicvalid(end),nslices));
percent_startslice=10;
startslice=round(size(b,2)*1/percent_startslice);
slicelims=[startslice size(b,2)-startslice];
ixslices=round(linspace(slicelims(1),slicelims(2),nslices));

nsubplot=ceil(sqrt(nslices));
 pan=[];
 nc=1;
 s3=[];
  close all;
%  clc
for i=1:nslices
    sliceidx=ixslices(i);
    s=squeeze(b(:,sliceidx,:));
    t=squeeze(a(:,sliceidx,:,:));
    s2=repmat(s,[1 1 3]); s2=uint8(s2);
    t2=round(t);
    f2 = alph*im2double(s2) + (1-alph)*im2double(t2);
    f2 = im2uint8(f2);
    f2 =flipud(permute(f2,[2 1 3]));
    f2=imresize(f2,resizfac);
    %figure; imshow(f2)
    if i==1
        blank=uint8(zeros(size(f2)));
     end
    
    if nc<=nsubplot
        pan=[pan f2];
    end
    
    if nc==nsubplot
        nzeros=size(f2,2)*nsubplot-size(pan,2);
        fillrest=uint8(zeros([ size(f1,1)  nzeros 3 ]));
        pan2=[pan fillrest];
        s3=[s3; pan2] ;
        nc=0;
        pan=[];
    end
    nc=nc+1;    
end
% fg,imshow(s3)
% figure; imshow(f2)
%% ===============================================

imwrite(uint8(s3),'QA_densitymap_standardSpace_coronar_matlab.png');




