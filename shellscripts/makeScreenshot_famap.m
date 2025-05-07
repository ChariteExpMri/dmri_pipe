


function makeScreenshot_famap(mrtrixpath)


% mrtrixpath='X:\Imaging\Paul_DTI\test_7mai\data\a002\20220725AB_MPM_12-4_DTI_T2_MPM\mrtrix'

cd(mrtrixpath);
disp('create sreenshots-matlab');
disp(['workingdir: ' pwd]);


%% ====read niftis===========================================
hb = niftiinfo('./../AVGT.nii');
b= niftiread(hb);
%---ovl
ha = niftiinfo('fa_SS');
a= niftiread(ha);


%% ===============================================
% figure
% imshow(imfuse(s2,t,'blend','Scaling','joint'),[]);
alph = 0.7;
resizfac=2;
%----
cmap = jet;  % Get the figure's colormap.
L = size(cmap,1);
siz=hb.ImageSize;
mid=round(siz/2);

%% ===pan1==============
s=squeeze(b(mid(1),:,:));
t=squeeze(a(mid(1),:,:,:));
s2=repmat(s,[1 1 3]); s2=uint8(s2);
% --colorcode--image
G = t;
Gs = round(interp1(linspace(min(G(:)),max(G(:)),L),1:L,G));% Scale the matrix to the range of the map.
t2 = reshape(cmap(Gs,:),[size(Gs) 3]); % Make RGB image from scaled.
t2=im2uint8(t2);
% ----
f1 = alph*im2double(s2) + (1-alph)*im2double(t2);
f1 = im2uint8(f1);
f1 =flipud(permute(f1,[2 1 3]));
f1=imresize(f1,resizfac);
% figure; imshow(f1)

%% ====pan2=============
s=squeeze(b(:,mid(2),:));
t=squeeze(a(:,mid(2),:,:));
s2=repmat(s,[1 1 3]); s2=uint8(s2);
% --colorcode--image
G = t;
Gs = round(interp1(linspace(min(G(:)),max(G(:)),L),1:L,G));% Scale the matrix to the range of the map.
t2 = reshape(cmap(Gs,:),[size(Gs) 3]); % Make RGB image from scaled.
t2=im2uint8(t2);
% ----
f2 = alph*im2double(s2) + (1-alph)*im2double(t2);
f2 = im2uint8(f2);
f2 =flipud(permute(f2,[2 1 3]));
f2=imresize(f2,resizfac);
% figure; imshow(f2)

%% ====pan3=============
s=squeeze(b(:,:,mid(3)));
t=squeeze(a(:,:,mid(3),:));
s2=repmat(s,[1 1 3]); s2=uint8(s2);
% --colorcode--image
G = t;
Gs = round(interp1(linspace(min(G(:)),max(G(:)),L),1:L,G));% Scale the matrix to the range of the map.
t2 = reshape(cmap(Gs,:),[size(Gs) 3]); % Make RGB image from scaled.
t2=im2uint8(t2);
% ----
f3 = alph*im2double(s2) + (1-alph)*im2double(t2);
f3 = im2uint8(f3);
f3=imresize(f3,resizfac);
% figure; imshow(f3)

%% ====orthoplot=============
domax=max([size(f1,1) size(f2,1)]);
f11=uint8(zeros(domax,size(f1,2),3));
f11(1:size(f1,1),1:size(f1,2),:)=f1;
f22=uint8(zeros(domax,size(f2,2),3));
f22(1:size(f2,1),1:size(f2,2),:)=f2;

w=[[f22 f11]; [f22 f11].*0];
w(end-size(f3,1)+1:end,1:size(f3,2),: )=f3;
% figure; imshow([w]);
imwrite(uint8(w),'QA_FAmap_standardSpace_matlab.png');

%% ===============================================




