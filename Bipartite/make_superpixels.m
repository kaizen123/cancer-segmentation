function [seg,L,seg_vals,seg_lab_vals,seg_edges,seg_img] = make_superpixels(patch,para_MS,para_FH,Factor)

% Perform multiple over-segmentations by Mean Shift and FH with varying
% parameters

img = imresize(patch,Factor);
[X,Y,Z] = size(img);
lab_img = colorspace('Lab<-', img);
lab_vals = reshape(lab_img, X*Y, Z);

%%% do segmentation
for k = 1:para_MS.K
    [~, L{k}, seg{k}, seg_vals{k}, seg_lab_vals{k}, seg_edges{k}] = ...
        msseg(double(img),lab_vals,para_MS.hs{k},para_MS.hr{k},para_MS.M{k});
end

for i = 1:para_FH.K
    k = i + para_MS.K;
    [seg{k}, L{k}, seg_vals{k}, seg_lab_vals{k}, seg_edges{k}] = ...
        gbis(img,lab_vals,para_FH.sigma{i},para_FH.k{i},para_FH.minsize{i});
end

%%% make mean color image for display
for k = 1:(para_MS.K + para_FH.K)
    Mimg = zeros(X*Y,Z); 
    for i = 1:size(seg{k},2)
        for j = 1:Z
            Mimg(seg{k}{i},j) = seg_vals{k}(i,j)/255;
        end
    end
    seg_img{k} = reshape(Mimg,[X,Y,Z]);
end

