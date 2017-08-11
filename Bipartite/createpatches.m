clear all; close all; clc

%This script is used to create patches using a tissue image and its
%corresponding annotation (mask image). The patches are then individually
%segmented to delineate non-tumor from tumor region. Finally, segmented patches are
%"sewn" back together into the original image size.

%Be sure to either clear the folder where patches are created or change the
%script so for each run of the script the patches are output into the same
%folder.

% add Bipartite_script folder to path
addpath(genpath('C:\Users\smschnei\Desktop\Segmentation\Bipartite_script'))

% add path to directory with image and associated mask
%Input =('C:\...inputfolder');
%addpath(genpath(Input))

% Select output directory
R = 'C:\Users\smschnei\Desktop\NewSegFiles';

%select parameters:

%size of patch x dim. 
patchsize_x = 200;
%size of patch y dim. 
patchsize_y = 200; 
%resolution of image before patches are taken.
Res = .7;
%distance between patch center points (a factor of resolution)0
patchinterval = 40*Res;  
%select number of segments to take from each patch
segnum = 2;

%Read image and mask here:
%img = imread([R filesep 'S14-39636-I9-04.tif']);
%imgMask = imread([R filesep 'S14-39636-I9-04_mask.tif']);
img = img(:,:,[1,2,3]);
% imgMask = imgMask(:,:,2);

img = imresize(img,Res);
imgMask = imresize(imgMask,Res);


%% If transforming image before patches are taken:

% Blur entire image

% second dimension of H controls amount of blur to add to image 
% H = fspecial('disk',5);
% blurred = imfilter(img,H,'replicate');
% img = blurred;

% Reduce colorspace of entire image

%select reduction size
% c_dim = 10; 
% [X_no_dither,map]= rgb2ind(img,c_dim,'nodither');
% X_no_dither = double(X_no_dither);
% imgw = (X_no_dither./max(X_no_dither(:))).*255;
% img = ind2rgb(imgw,map);


%% Use the annotated images to find coordinates of annotated edges.

%The output B is a nx1 cell array where n is the amount of closed
%boundary shapes in the image.. As n increases, the size of the shape
%decreases. Inside each cell are the x,y coordinates for each pixel on the boundary 
% for the correpsonding shape (first cell is largest shape). L is purely for visualization purposes. 

[B,L] = bwboundaries(imgMask,'noholes');

%% Use this script to view the boundaries on the image to verify the previous function.
%imshow(img)
%hold on
%for k = 1:length(B)
%    boundary = B{k};
%    plot(boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2)
%end
%imshow(label2rgb(L, @jet, [.5 .5 .5]))

%% Use the coordinates to form rectangles where each coordinate is a center point for a rectangle. Patches may overlap.


[img_row,img_col] = size(imgMask); %total image size
Empty_mat = ones(img_row,img_col);
 
for k = 1:length(B)
    
    cd(R)
    Seg_dir = ['Segment_' num2str(k)];
    mkdir(Seg_dir)
    Seg_R = [R filesep Seg_dir];
    cd(Seg_R)
    mkdir(['Patches_' num2str(patchsize_x) 'x' num2str(patchsize_y)])
    
    count_m = [];
    vect_size = [1:patchinterval:length(B{k})];
    boundary = B{k};
    
    for m = 1:length(vect_size)    %adjusts # of patches per segment
        
         centerpoints = B{k}(vect_size(m),:); %selects x,y coordinate for centerpoint m in segmentation k..
         L_x = max(1,centerpoints(2)-ceil(patchsize_y/2)); %x location of left edge
         R_x = min(img_col,centerpoints(2) + ceil(patchsize_y/2)); % x location of right edge
         B_y = max(1,centerpoints(1)-ceil(patchsize_x/2)); %y location of bottom
         T_y = min(img_row,centerpoints(1) + ceil(patchsize_y/2)); % x location of top 
         
     
         patch = img(B_y:T_y,L_x:R_x,:);
        
         %% If transforming image after patches are taken:
         
         % Blur entire image
         
         %H = fspecial('disk',5);
         %blurred = imfilter(img,H,'replicate');
         %img = blurred;
         
         % Reduce colorspace of entire image
         
         % c_dim = 10; %select reduction size
         % [X_no_dither,map]= rgb2ind(img,c_dim,'nodither');
         % X_no_dither = double(X_no_dither);
         % imgw = (X_no_dither./max(X_no_dither(:))).*255;
         % img = ind2rgb(imgw,map);
         % figure; imshow(img);
         
         
         patch_loc = [L_x B_y patchsize_x patchsize_y];
         
         
         %% View rectangles
         %
         %     imshow(img); hold on
         %
         %     for l = 1:length(patch_loc)
         %          rectangle('Position',patch_loc{l},'EdgeColor','b', ...
         %               'LineWidth',2);
         %     end
         %     hold off

         %% for patch labeling only
            count_m = [count_m;m]; 
            q = length(count_m);
             if q < 10
                 patch_num = ['000' num2str(q)];
             elseif (10<=q) && (q<100)
                 patch_num = ['00' num2str(q)];
             elseif (100<=q) && (q<1000)
                 patch_num = ['0' num2str(q)];
             else
                 patch_num = num2str(q);
             end
         %% save patches to folder with locations in .mat file
          imwrite(patch,[Seg_R filesep 'Patches_' num2str(patchsize_x) 'x' ...
          num2str(patchsize_y) '\patch_' patch_num '.tif']);
          
         %% Segment patches with bipartite graph method
         [patch_row,patch_col] = size(patch);
%          if patch_row | patch_col < 200
%              continue
%          else
%          end
         seg_im = demo_SAS_BSDS(patch,segnum);
         imwrite(seg_im,[Seg_R filesep 'Patches_' num2str(patchsize_x) 'x' ...
          num2str(patchsize_y) '\seg_' patch_num '.tif']);

         %% Remap patches into empty matrix
         Empty_mat(B_y:T_y,L_x:R_x) = Empty_mat(B_y:T_y,L_x:R_x) + double(seg_im==0);
         clear seg_im
         %hold on        % only hold on here for viewing
         % display segmentation boundary for viewing purposes
         %plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2); hold on
     end
    mat_1 = Empty_mat>1; %all greater than 1 instance of segmentation (overlap)
    imwrite(mat_1, ...
    [Res_dir filesep 'Combined_segments_' num2str(patchsize_x) '_' num2str(k) '.tif']);
    save([Seg_R filesep 'emptymat_' num2str(k) '.mat'], 'mat_1');
end

%Creates resulting images with threshold for overlap in place.
 for k =1:size(unique(Empty_mat(:)))
  mat_1 = Empty_mat > k;
  mat_2 = ~mat_1;
  imwrite(mat_2,[Res_dir filesep '\Thresh_' num2str(k) '.tif']);
 end

