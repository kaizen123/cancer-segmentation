function B = build_bipartite_graph(patch,para,seg,seg_lab_vals,seg_edges,Factor)
%add pars and k after para
% if pars == 1 %alpha
%     par1 = k; par2 = 10; par3 = 10;
% elseif pars == 2  %beta
%     par1 = 10; par2 =k; par3 = 10;
% else  %nb
%     par1 = 10; par2 =10; par3 = k;
% end    

img = imresize(patch,Factor); 
[X,Y,~] = size(img); 
Np = X*Y; 

% get the overall number of superpixels
Nsp = 0;
for k = 1:length(seg)
    Nsp = Nsp + size(seg{k},2); 
end

W_Y = sparse(Nsp,Nsp); 
edgesXY = []; 
j = 1;
for k = 1:length(seg) % for each over-segmentation
    
    % affinities between superpixels
    % w = makeweights(seg_edges{k},seg_lab_vals{k},para.beta{par2});
    w = makeweights(seg_edges{k},seg_lab_vals{k},para.beta);

    W = adjacency(seg_edges{k},w);
    Nk = size(seg{k},2); % number of superpixels in over-segmentation k
%     W_Y(j:j+Nk-1,j:j+Nk-1) = prune_knn(W,para.nb{par3});
W_Y(j:j+Nk-1,j:j+Nk-1) = prune_knn(W,para.nb);
    % affinities between pixels and superpixels
    for i = 1:Nk
        idxp = seg{k}{i}; % pixel indices in superpixel i
        Nki = length(idxp); 
        idxsp = j + zeros(Nki,1);
        edgesXY = [edgesXY; [idxp, idxsp]];
        j = j + 1;
    end
end

% W_XY = sparse(edgesXY(:,1),edgesXY(:,2),para.alpha{par1},Np,Nsp);
W_XY = sparse(edgesXY(:,1),edgesXY(:,2),para.alpha,Np,Nsp);


% affinity between a superpixel and itself is set to be the maximum 1.
W_Y(1:Nsp+1:end) = 1;

B = [W_XY;W_Y];
