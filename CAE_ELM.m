addpath('voxeldata');
%load stanford_train2_and_test1_voxel.mat;
load submodelnet40_30voxelset.mat;
%load cupvoxel.mat;

%load sixteenVoxel.mat;
% %load bedandchair.mat;
% % addpath('psbdata');
% % load PSBVoxel.mat;
data=voxelData;
clear voxelData
labels=voxelLabel;
clear voxelLabel

%addpath('sdfrawdata');
%addpath('sdfmodelnet40');
%load stanford_train2_and_test1_voxel.mat;
% load sdfdataset.mat
% data = sdfdata;
% labels = sdflabels;
% clear sdfdata sdflabels;

shapedim = nthroot(size(data,1),3);

%data = data';
inputDim = shapedim; %sqrt(size(data,1));
sampleNum = size(data,2);
data = reshape(data,inputDim,inputDim,inputDim,sampleNum);

class_number = length(unique(labels));
labels(labels==0)=class_number;
T = full(sparse(labels,1:sampleNum,1));  %groundTruth [classnumber, samplenumber]


%���㣬 featuremapsNum=80,kerneldim=5,pooldim = 2,C=1e8��׼ȷ�ʴﵽ86.1%


tic;

if(length(size(data))==5)
    inputFeatureMapNum = size(data,5);
    sampleNum = size(data,4);  %inputdata:��ά���ݣ�ǰ��ά��ʾ���ŵ�ͼ��ά�ȣ�����ά��ʾͼƬ����������ά��ʾ����ͼ����Ŀ
else
    inputFeatureMapNum = 1;
    sampleNum = size(data,4);
end
load wu_filters.mat;
for k = 1:layersNum
    outputFeatureMapNum = param{k}.featuremapsNum;
    model{k}.kernel = zeros(param{k}.kernelDim,param{k}.kernelDim,param{k}.kernelDim,inputFeatureMapNum,outputFeatureMapNum);
    hidden_size = param{k}.hiddenNum;
    %inputDim =floor( (inputDim-param{k}.kernelDim+1)/param{k}.pooldim);
    inputDim =(inputDim-param{k}.kernelDim+1);
    for i = 1:outputFeatureMapNum
        for j = 1:inputFeatureMapNum
            model{k}.kernel(:,:,:,j,i) = rand(param{k}.kernelDim,param{k}.kernelDim, param{k}.kernelDim)*2-1;
            %model{k}.kernel(:,:,:,j,i) = filters(:,:,:,i);%rand(param{k}.kernelDim,param{k}.kernelDim, param{k}.kernelDim);
        end  
        %model{k}.W{i} = rand(hidden_size,inputDim * inputDim* inputDim)*2-1;
        %model{k}.b{i} = rand(hidden_size,1);
    end
%     inputFeatureMapNum = outputFeatureMapNum;
%     inputDim = nthroot(hidden_size,3);
end

% load filters.mat;
%  for i = 1:outputFeatureMapNum
%          model{k}.kernel(:,:,:,1,i) = filters(:,:,:,i);
% 
% end



out = data;
clear data
for l = 1:layersNum
    out = CAE_getH(out,model{l},param{l});
   
%     for j = 1:param{l}.featuremapsNum
        %fprintf('training the %d th auto-encoder!\n',j);
        %[out_arr{j},model{l}.W{j}] = AE_train(H_array{j},model{l}.W{j}, model{l}.b{j},param{l});
        
%         if j == 1
%             out = out_arr{j};
%         else
%             out = cat(5,out,out_arr{j});
%         end
    
%     end
end
% clear H_array
% clear out_arr;

H = combine_Harray(out);

clear out

%C = 0.01;
fprintf('begin inv!\n');





if sampleNum > param{1}.featuremapsNum*inputDim^3
    model{layersNum+1}.OutputWeight=inv(eye(size(H,1))/C+H * H') * H * T';
else
    model{layersNum+1}.OutputWeight=H*inv(eye(size(H,2))/C+H' * H) * T';
end


fprintf('end inv!\n');
TY=(H' * model{layersNum+1}.OutputWeight)';

weightedFeatures = zeros(size(H));

MissClassificationRate_Training=0;

predLabels = zeros(sampleNum,1);



for i = 1 : sampleNum
    
    [x, label_index_expected]=max(T(:,i));
    [x, label_index_actual]=max(TY(:,i));
    weightedFeatures(:,i) = H(:,i).*(model{layersNum+1}.OutputWeight(:,label_index_actual));
    
    predLabels(i) = label_index_actual;
    if label_index_actual~=label_index_expected
         MissClassificationRate_Training=MissClassificationRate_Training+1;
    end
end
TrainingAccuracy=1-MissClassificationRate_Training/sampleNum

weightedFeatures = reshape(weightedFeatures,inputDim,inputDim, inputDim,param{1}.featuremapsNum,sampleNum);
weightedFeatures = permute(weightedFeatures,[1 2 3 5 4]);

features = H;

features = reshape(features,inputDim,inputDim, inputDim,param{1}.featuremapsNum,sampleNum);
features = permute(features,[1 2 3 5 4]);

beta = model{layersNum+1}.OutputWeight;
% save beta.mat beta;
% save nonweightedFeatures.mat features -v7.3;
% save weightedFeatures.mat weightedFeatures -v7.3;


sumFeatures = sum(features,5);
sumWeightedFeatures = sum(weightedFeatures,5);

% save sumFeatures.mat sumFeatures -v7.3;
save sumWeightedFeatures.mat sumWeightedFeatures -v7.3;

for i = 1:class_number
    index = labels==i;
    minval = min(min(min(min(min(features(:,:,:,index,:))))));
    maxval = max(max(max(max(max(features(:,:,:,index,:))))));
    features(:,:,:,index,:) = (features(:,:,:,index,:) - minval)./(maxval-minval);
    minval = min(min(min(min(min(weightedFeatures(:,:,:,index,:))))));
    maxval = max(max(max(max(max(weightedFeatures(:,:,:,index,:))))));
    weightedFeatures(:,:,:,index,:) = (weightedFeatures(:,:,:,index,:) - minval)./(maxval-minval);
    
    minval = min(min(min(min(sumFeatures(:,:,:,index)))));
    maxval = max(max(max(max(sumFeatures(:,:,:,index)))));
    sumFeatures(:,:,:,index) = (sumFeatures(:,:,:,index) - minval)./(maxval-minval);
    minval = min(min(min(min(sumWeightedFeatures(:,:,:,index)))));
    maxval = max(max(max(max(sumWeightedFeatures(:,:,:,index)))));
    sumWeightedFeatures(:,:,:,index) = (sumWeightedFeatures(:,:,:,index) - minval)./(maxval-minval);    
end
% save normalizefea.mat features -v7.3;
% save normalizewfea.mat weightedFeatures -v7.3;
% save normsumfea.mat sumFeatures -v7.3;
save normsumwfea.mat sumWeightedFeatures -v7.3;


toc

%%%%%%%%%%%%%%%%%%%testing%%%%%%%%%%%%%%%%%%%%%%%%

%load('MnistTestData_1000.mat');
%load('MnistTestLabels_1000.mat');

% load ('testdataset.mat');
% data=testdata;
% labels=testlabels;
% clear testdata
% clear testlabels
data=testData;
labels=testLabel;
clear testData
clear testLabel



%data = data';
inputDim =shapedim; %sqrt(size(data,1));
sampleNum = size(data,2);
data = reshape(data,inputDim,inputDim,inputDim,sampleNum);

labels(labels==0)=class_number;
T = full(sparse(labels,1:sampleNum,1));  %groundTruth [classnumber, samplenumber]

out = data;
clear data
for l = 1:layersNum
    H_array = CAE_getH(out,model{l},param{l});
    for j = 1:param{l}.featuremapsNum
        out_arr{j} = AE_ff(H_array{j},model{l}.W{j},model{l}.b{j},param{l}.Actfunc);
        %out_arr{j} = (out_arr{j}-min(min(min(min(out_arr{j})))))./(max(max(max(max(out_arr{j}))))-min(min(min(min(out_arr{j})))));
        if j == 1
            out = out_arr{j};
        else
            out = cat(5,out,out_arr{j});
        end
    end
    
end
clear out_arr;
H = combine_Harray(out);

clear out
TY=(H' * model{layersNum+1}.OutputWeight)';
clear H

MissClassificationRate_Testing=0;

predLabels = zeros(sampleNum,1);

for i = 1 : sampleNum
       
    [x, label_index_expected]=max(T(:,i));
    [x, label_index_actual]=max(TY(:,i));
    predLabels(i) = label_index_actual;
    if label_index_actual~=label_index_expected
         MissClassificationRate_Testing=MissClassificationRate_Testing+1;
    end
end
TestingAccuracy=1-MissClassificationRate_Testing/sampleNum




