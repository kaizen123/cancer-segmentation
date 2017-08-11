% segments the entire image
clear all; close all; clc

R = '/projects/academic/scottdoy/code/quant_risk_steve/Segment_methods';
%addpath(genpath(R))
%compile mex in linux

%% add segementation script to path 
addpath(genpath([R filesep 'Segmentation_methods\Bipartite_script']))

%% Create output folder for Blur, etc.
%Output_dir = [R filesep 'Bipartite/Output'];
Output_dir = [R filesep 'Log_results\Bad_1\Full_Image'];
Label_dir = [R filesep 'Segment_results'];


% Reduce resolution to process image faster... or use server
Res = .25; %.25 microns per pixel is orginal res. lower res means more microns per pixel.



%% Read images on PC:
img = imread([Label_dir filesep '\Annotations....tif']);
% dont forget to add to path.

%% Blur entire image

% H = fspecial('disk',5);
% blurred = imfilter(img,H,'replicate');
% img = blurred;

%% Reduce colorspace of entire image
c_dim = 4; %select reduction size
[X_no_dither,map]= rgb2ind(img,c_dim,'nodither');
X_no_dither = double(X_no_dither);
imgw = (X_no_dither./max(X_no_dither(:))).*255;
imgspace = ind2rgb(imgw,map);
%figure; imshow(img);
%imwrite(imgspace,['C:\Users\smschnei\Desktop\cspace\img' num2str(k) '.tif']);


newimg = imresize(imgspace,Res);
segnum = 6; % number of segmentations to take
seg_im = demo_SAS_BSDS(newimg,segnum);  %second dim is number of segmentations
imwrite(seg_im,[Output_dir filesep 'Point25_cspace_4.tif']);
