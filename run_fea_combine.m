
clear;

for fnum = 10:10:10
    
    layersNum = 1;
    param{1}.featuremapsNum =100;
    param{1}.kernelDim =5;
    param{1}.pooldim = 2;
    param{1}.C = 1e6;
    param{1}.hiddenNum =6^3;%��������������������ʾÿ��featuremap��AEʱ����ڵ����Ŀ
    param{1}.Actfunc = 'sig';
    C = 0.1;
    fprintf('funm=%d, C = %d\n',fnum,C);
    %CAE_ELM_voxel;
    CAE_ELM_combine;
end
% for fnum = 10:10:100
%   
%     layersNum = 1;
%     param{1}.featuremapsNum =fnum;
%     param{1}.kernelDim =5;
%     param{1}.pooldim = 2;
%     param{1}.C = 1e8;
%     param{1}.hiddenNum =6^3;%��������������������ʾÿ��featuremap��AEʱ����ڵ����Ŀ
%     param{1}.Actfunc = 'sig';
%     C = 0.1;
%     fprintf('funm=%d, C = %d\n',fnum,C);
%     CAE_ELM;
% end
% for fnum = 10:10:100
%     layersNum = 1;
%     param{1}.featuremapsNum =fnum;
%     param{1}.kernelDim =5;
%     param{1}.pooldim = 2;
%     param{1}.C = 1e8;
%     param{1}.hiddenNum =6^3;%��������������������ʾÿ��featuremap��AEʱ����ڵ����Ŀ
%     param{1}.Actfunc = 'sig';
%     C = 1;
%     fprintf('funm=%d, C = %d\n',fnum,C);
%     CAE_ELM;
% end
