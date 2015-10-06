MEL_CTRL; %コントロール用変数の読み込み

% 初期設定
MEL_SAMPLE_COMPORT	= 'COM7';% polymate miniのポート番号
MEL_SAMPLE_UNITSIZE	= 1;
MEL_SAMPLE_UNIT_N	= maximun_buffer_samples;
MEL_SAMPLE_FREQ		= sampling_freq;
% MEL_SAMPLE_LIST_CH = [MELCTRL_DEVTYPE_EEG+1 MELCTRL_DEVTYPE_EEG+2 MELCTRL_DEVTYPE_EEG+3];
MEL_SAMPLE_LIST_CH = MELCTRL_DEVTYPE_EEG + ch_numbers;

duration_plot_n = floor(MEL_SAMPLE_FREQ * duration_plot_secs);
duration_classify_n = floor(MEL_SAMPLE_FREQ * duration_classify_secs);
n_channels = size(MEL_SAMPLE_LIST_CH, 1);


% polymate miniの初期化
fprintf('[Init]');
IS_INIT = mel4mex('Init');
if IS_INIT == 0
    fprintf(' NG\n');
    return;
else
    fprintf(' OK\n');
end

% polymate miniとの接続
fprintf('[Open]');
HANDLE = mel4mex('Open', MEL_SAMPLE_COMPORT, MEL_SAMPLE_UNITSIZE, MEL_SAMPLE_UNIT_N, MEL_SAMPLE_FREQ);
if( HANDLE <= 0 )
    fprintf(' NG\n');
    fprintf('[Term]\n');
    mel4mex('Term');
    return;
end
fprintf(' HANDLE: %d\n', HANDLE);


% 計測チャネルの設定
fprintf('[SetCh]');
CH_N = size(MEL_SAMPLE_LIST_CH, 2);
ret = mel4mex('SetCh', HANDLE, CH_N, MEL_SAMPLE_LIST_CH);
if ret == 0
    fprintf(' NG\n');
    fprintf('[Close]\n');
    mel4mex('Close', HANDLE);
    fprintf('[Term]\n');
    mel4mex('Term');
    return;
else
    fprintf(' OK\n');
end

% 脳波チャネルのゲインの設定
for m = 1:length(MEL_SAMPLE_LIST_CH)
    result = mel4mex('SetChInfo', HANDLE, m, MELCTRL_CH_GAIN,gain);
end

%インピーダンスチェック
fprintf('[GetImpedance]');
IMPD = mel4mex('GetImpedance', HANDLE);
if IMPD == 0
    fprintf(' NG\n');
else
    fprintf(' OK\n');
    fprintf('  Impedance:');
    for itemImpd = IMPD
        fprintf(' %d', itemImpd);
    end
    fprintf('\n');
end
