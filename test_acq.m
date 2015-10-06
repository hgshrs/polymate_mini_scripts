% リアルタイム波形表示
% dataに計測データを保存
% Escape keyで計測終了
% 強制終了した場合はmel4mex('Term')を実行してpolymate miniとの接続を切断してください。
% リアルタイムプロットを編集する場合は，plot_signal()を編集
%       plot_objにパラメータを格納
% リアルタイム識別を編集する場合は，plot_classify()を編集
%       classify_objにパラメータを格納

clear all

% パラメータ
ch_numbers = [1 2 3];
period_fetch_secs = .2; % period_fetch_secs [sec] 毎に信号を取得
period_plot_secs = .1; % period_plot_secs [sec] 毎に信号をプロット
duration_plot_secs = 5; % plotする信号長 [sec]
period_classify_secs = 1; % period_classify_secs [sec] 毎に信号をプロット
duration_classify_secs = 3; % classifyする信号長 [sec]
gain = 1000; %gain
sampling_freq = 500;
maximun_buffer_samples = 5000;

% polymateの初期設定，インピーダンスチェック
setting_polymate

% 保存ファイル
file = sprintf('data/%s', datestr(now, 'yyyyddmmHHMM'));
fprintf('Recorded data will be saved as %s.mat\n', file)

% fetch用timerオブジェクトの作成
fetch_timer = timer('ExecutionMode', 'fixedRate', 'TimerFcn', 'data = signal_fetch(HANDLE, data, gain);', 'Period', period_fetch_secs);

% plot用timerオブジェクトの作成
plot_obj.figure_handle = figure(1);
plot_obj.sampling_freq = sampling_freq;
[b, a] = butter(4,[2/(.5*sampling_freq) 40/(.5*sampling_freq)]);
plot_obj.filter.b = b;
plot_obj.filter.a = a;
plot_obj.filter.zf = [];
plot_obj.filter.n_cut_samples = sampling_freq*5;
plot_obj.duration_n = duration_plot_n;
plot_timer = timer('ExecutionMode', 'fixedRate', 'TimerFcn', 'plot_obj = plot_signal(data, plot_obj);', 'Period', period_plot_secs);

% classify用timerオブジェクトの作成
classify_obj.duration_n = duration_classify_n;
classify_timer = timer('ExecutionMode', 'fixedRate', 'TimerFcn', '[class, classify_obj] = classify_signal(data, classify_obj);', 'Period', period_classify_secs);

% 計測開始
data = zeros([0, n_channels]);
fprintf('[Acquision] Start...');
mel4mex('StartAcquision', HANDLE);

start(fetch_timer)
start(plot_timer)
start(classify_timer)

% 計測中．Escape keyで計測終了
escape = 0;
KbName('UnifyKeyNames');
escape_key = KbName('escape');
while escape == 0
    pause(.1)
    [pressed, sec_dummy, keyCode] = KbCheck;
    if keyCode(escape_key)
        escape = 1;
    end
end

stop(fetch_timer)
delete(fetch_timer)
stop(plot_timer)
delete(plot_timer)
stop(classify_timer)
delete(classify_timer)

mel4mex('StopAcquision', HANDLE);
fprintf('[Close]\n');
mel4mex('Close', HANDLE);
fprintf('[Term]\n');
mel4mex('Term');

save(file)
