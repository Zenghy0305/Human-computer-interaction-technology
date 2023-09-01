function predict_result = FBCCA(eeg, stimuls, fs, ORDER, FBNUMS)  
    %FBNUMS代表子频带个数N
    c =(1:FBNUMS).^(-1.25)+0.25;
    [num_trs, ~, num_points] = size(eeg);
    num_stimuls = length(stimuls);
    %获取参考信号
    Y = generate_reference(stimuls, fs, num_points, ORDER);
    %获取相关系数矩阵
    R=zeros(FBNUMS,num_stimuls);
    for i = 1:1:num_trs %对每一个trial进行预测
        eeg_tmp = squeeze(eeg(i,:,:)); %取其中一个trial数据
        for k = 1:1:FBNUMS %计算每个子频带与刺激频率参考信号的相关系数
            x = filter_group(eeg_tmp, fs, k); %代表第k个子频带
            for j = 1:1:num_stimuls
             y = squeeze(Y(j, :, :));
             [~,~,Rt] = canoncorr(x', y');
             R(k, j) = Rt(1,1); 
            end
        end
        P = c*R.^2;[~, idx] = max(P);predict_result(i) = idx;
    end
end

function Y = generate_reference(stimuls, Fs, num_points, ORDER)
    num_stimuls = length(stimuls);
    tidx = (1:num_points)/Fs;
    for i = 1:1:num_stimuls
        y = [];
        for j = 1:1:ORDER
            freq = stimuls(i);
            y = [y;sin(2*pi*tidx*j*freq);cos(2*pi*tidx*j*freq)];
        end
        Y(i, 1:2*ORDER, 1:num_points) = y;
    end
end