function seg_im = demo_SAS_BSDS(patch,segnum)


% This code is to reproduce the experiments reported in paper
% "Segmentation Using Superpixels: A Bipartite Graph Partitioning Approach"
% Zhenguo Li, Xiao-Ming Wu, and Shih-Fu Chang, CVPR 2012
% {zgli, xmwu, sfchang}@ee.columbia.edu
%addpath(genpath('C:\Users\smschnei\Desktop\Segmentation\Bipartite_script'))

% addpath(genpath('/projects/academic/scottdoy/code/quant_risk_steve/temp/Segmentation/CVPR12_SAS_code'))

% addpath 'msseg'
% addpath 'others'
% addpath 'evals'
% addpath 'algorithms'
% addpath 'Graph_based_segment'

%%% set parameters for bipartite graph
% alpha_v = [.0001:.005:.1];
% for n = 1:length(alpha_v)
%     para.alpha{n} = alpha_v(n); % affinity between pixels and superpixels
% end
para.alpha = 0.0008;
para.beta  =  20;   % scale factor in superpixel affinity
para.nb  =  2; %may adjust this...
% beta_v = [1:4:80];
% for n2 = 1:length(beta_v)
%     para.beta{n2} = beta_v(n2);
% end
% nb_v = [1:2:40];
% for n3 = 1:length(nb_v)
%     para.nb{n3} = nb_v(n3);
% end
%para.nb = 1; % number of neighbors for superpixels
%para.nb = 3;
%%% set number of segments parameter
%Nseg = 2;

%read numbers of segments used in the paper 
%bsdsRoot = 'E:\Coding\Misc\Segmentation\BSDS300';
bsdsRoot = 'C:\Users\smschnei\Desktop\Bipartite_script\BSDS300';
% bsdsRoot = '/projects/academic/scottdoy/code/quant_risk_steve/temp/Segmentation/CVPR12_SAS_code/BSDS300';

outRoot = 'C:\Users\smschnei\Desktop';

%x = dir('C:\Users\smschnei\Desktop\Patch');
%for k = 3:100, names = x(k).name; y{k-2} = names; end
%img_loc = ['C:\Users\smschnei\Desktop\Patch\S15-6200-D2-01A_' num2str(patchnum) '_' ...
%            Crop_reg(patchnum,1) '_' Crop_reg(patchnum,2) '.tif'];
% img_loc = '/projects/academic/scottdoy/code/quant_risk_steve/temp/Segmentation/CVPR12_SAS_code/S15-6200--B3/6702-6163/40x/S15-6200-D2-01A_001.tif';

% Make image size ~250x
[m,n,~] = size(patch);
% dimin = m;  %must be greater than 200 (for now)
% Factor = dimin/m;
Factor = 1;
% set name of image to be segmented
%img_name = ['S156200_33_' num2str(dimin) '_' num2str(m) 'x' num2str(n)];  %names folder according to orig image size?
img_name = 'full_res';
%fid = fopen(fullfile('results','BSDS300','Nsegs.txt'),'r');
%Nimgs = 1; % number of images in BSDS300
%[BSDS_INFO] = fscanf(fid,'%d %d \n',[2,Nimgs]);
[BSDS_INFO] = [111;segnum];
% fclose(fid);
Nimgs = 1;  %sets all vars = 0.
PRI_all = zeros(Nimgs,1);
VoI_all = zeros(Nimgs,1);
GCE_all = zeros(Nimgs,1);
BDE_all = zeros(Nimgs,1);

% for idxI = 1:Nimgs
idxI = 1;  % # of images used
% read number of segments
%     Nseg = BSDS_INFO(2,idxI);
% locate image
%img_name = int2str(BSDS_INFO(1,idxI));
% img_loc = fullfile(bsdsRoot,'images','test',[img_name,'.tif']);
% if ~exist(img_loc,'file')
%     img_loc = fullfile(bsdsRoot,'images','train',[img_name,'.tif']);
% end
img = imresize(im2double(patch),Factor); [X,Y,~] = size(img); %reads im, rescales /255 and gets x,y size.
% out_path = fullfile('results','BSDS300',img_name);
out_path = fullfile(outRoot,img_name);
%mkdir(out_path);  %makes folder with same name as img_name

% generate superpixels
[para_MS, para_FH] = set_parameters_oversegmentation(patch,Factor); %gets mean shitf and FH parameters
[seg,labels_img,seg_vals,seg_lab_vals,seg_edges,seg_img] = make_superpixels(patch,para_MS,para_FH,Factor);

% save over-segmentations   
%view_oversegmentation(labels_img,seg_img,out_path,img_name);
clear labels_img seg_img;

% build bipartite graph...can adjust para here...
B = build_bipartite_graph(patch,para,seg,seg_lab_vals,seg_edges,Factor);
% for k = 1:20
% %Cycle through alpha par
% B_alpha{k} = build_bipartite_graph(img_loc,para,1,k,seg,seg_lab_vals,seg_edges,Factor);
% %Cycle through beta par
% B_beta{k} = build_bipartite_graph(img_loc,para,2,k,seg,seg_lab_vals,seg_edges,Factor);
% %Cycle through nb par
% B_nb{k} = build_bipartite_graph(img_loc,para,3,k,seg,seg_lab_vals,seg_edges,Factor);

clear seg seg_lab_vals seg_edges;

% Transfer Cut
label_img = Tcut(B,segnum,[X,Y]); clear B;
% label_img_alpha{k} = Tcut(B_alpha{k},Nseg,[X,Y]); 
% label_img_beta{k} = Tcut(B_beta{k},Nseg,[X,Y]);
% label_img_nb{k} = Tcut(B_nb{k},Nseg,[X,Y]);
% end

clear seg seg_lab_vals seg_edges B_alpha B_beta B_nb;

% save segmentation  
% for k = 1:20
seg_im = view_segmentation(img,label_img(:),out_path,img_name,0);

% view_segmentation(img,label_img_alpha{k}(:),para.alpha{k},1,out_path,img_name,0); %results with alpha changing
% view_segmentation(img,label_img_beta{k}(:),para.beta{k},2,out_path,img_name,0);
% view_segmentation(img,label_img_nb{k}(:),para.nb{k},3,out_path,img_name,0);
% end

% evaluate segmentation
% [gt_imgs gt_cnt] = view_gt_segmentation(bsdsRoot,img,BSDS_INFO(1,idxI),out_path,img_name,1); clear img;
% out_vals{k} = eval_segmentation(label_img_alpha{k},gt_imgs); 


clear gt_imgs label_img_alpha label_img_beta label_img_nb

end
% fprintf('%6s: %2d %9.6f, %9.6f, %9.6f, %9.6f \n', img_name, Nseg, out_vals.PRI, out_vals.VoI, out_vals.GCE, out_vals.BDE);
% 
% PRI_all(idxI) = out_vals.PRI;
% VoI_all(idxI) = out_vals.VoI;
% GCE_all(idxI) = out_vals.GCE;
% BDE_all(idxI) = out_vals.BDE;
% 
% 

%end
% fprintf('Mean: %14.6f, %9.6f, %9.6f, %9.6f \n', mean(PRI_all), mean(VoI_all), mean(GCE_all), mean(BDE_all));

% fid_out = fopen(fullfile('results','BSDS300','evaluation.txt'),'w');
% for idxI=1:Nimgs
%     fprintf(fid_out,'%6d %9.6f, %9.6f, %9.6f, %9.6f \n', BSDS_INFO(1,idxI), PRI_all(idxI), VoI_all(idxI), GCE_all(idxI), BDE_all(idxI));
% end
% fprintf(fid_out,'Mean: %10.6f, %9.6f, %9.6f, %9.6f \n', mean(PRI_all), mean(VoI_all), mean(GCE_all), mean(BDE_all));
% fclose(fid_out);
