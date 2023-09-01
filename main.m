%% Clear workspace
clear all
close all
clc
%子频带数目
FBNUMS = 5;
% 相关系数分析的阶数
ORDER = 5;
% 采样频率
Fs = 250; 
% 刺激频率列表
stimuls = 8:0.3:13.7;
%加载所有文件名列表
filelist = {'dataset\S1\block1.mat','dataset\S1\block2.mat','dataset\S2\block1.mat','dataset\S2\block2.mat','dataset\S3\block1.mat','dataset\S3\block2.mat','dataset\S4\block1.mat','dataset\S4\block2.mat','dataset\S5\block1.mat','dataset\S5\block2.mat'};      
%主程序部分
predict_result=[];
data_length = 100000;
for idx = 1:length(filelist)
    fprintf('start\n')
    name = filelist{idx};
    data = load(name);
    %统计trials个数
    trials = sum(data.data(11,:)==1);
    %找到所有起始位置
    start_position_list = find(data.data(11,:)==1,trials);
    %找到所有结束位置
    end_position_list = find(data.data(11,:)==241,trials);
    for i = 1:length(start_position_list)
        if data_length > end_position_list(i)-start_position_list(i)
            %取最小的trial长度
            data_length = end_position_list(i)-start_position_list(i);
        end
    end
    if idx==2
        data_length=data_length+1;
    end    
    origin_data = zeros(trials,10,data_length); %试验数；通道数；采样点数
    %获取数据
    for k=1:trials
         origin_data(k,:,:)=data.data(1:10,start_position_list(k):start_position_list(k)+data_length-1);
    end
    
    downsample_data = origin_data(:,:,1:floor(1000/Fs):end);
    %滤波去除50hz工频噪声
    w0=50/(Fs/2);
    b0=w0/25;
    [b,a]=iirnotch(w0,b0);
    downsample_data=filtfilt(b,a,downsample_data); 
    %进行预测分类
    predict_result_tmp = FBCCA(downsample_data, stimuls, Fs, ORDER, FBNUMS);
    predict_result=[predict_result predict_result_tmp']
    fprintf('end\n');
end

header = {'S1BLOCK1', 'S1BLOCK2', 'S2BLOCK1','S2BLOCK2','S3BLOCK1','S3BLOCK2','S4BLOCK1','S4BLOCK2','S5BLOCK1','S5BLOCK2'};
fileID = fopen('submission.csv', 'w');
formatSpec = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n';
fprintf(fileID, formatSpec, header{:});
formatSpec = '%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n';
[rows,~] = size(predict_result);
for row = 1:rows
    fprintf(fileID, formatSpec, predict_result(row,:));
end
% 关闭文件
fclose(fileID); 
