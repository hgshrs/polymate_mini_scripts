% ���A���^�C���g�`�\��
% data�Ɍv���f�[�^��ۑ�
% Escape key�Ōv���I��
% �����I�������ꍇ��mel4mex('Term')�����s����polymate mini�Ƃ̐ڑ���ؒf���Ă��������B
% ���A���^�C���v���b�g��ҏW����ꍇ�́Cplot_signal()��ҏW
%       plot_obj�Ƀp�����[�^���i�[
% ���A���^�C�����ʂ�ҏW����ꍇ�́Cplot_classify()��ҏW
%       classify_obj�Ƀp�����[�^���i�[

clear all

% �p�����[�^
ch_numbers = [1 2 3];
period_fetch_secs = .2; % period_fetch_secs [sec] ���ɐM�����擾
period_plot_secs = .1; % period_plot_secs [sec] ���ɐM�����v���b�g
duration_plot_secs = 5; % plot����M���� [sec]
period_classify_secs = 1; % period_classify_secs [sec] ���ɐM�����v���b�g
duration_classify_secs = 3; % classify����M���� [sec]
gain = 1000; %gain
sampling_freq = 500;
maximun_buffer_samples = 5000;

% polymate�̏����ݒ�C�C���s�[�_���X�`�F�b�N
setting_polymate

% �ۑ��t�@�C��
file = sprintf('data/%s', datestr(now, 'yyyyddmmHHMM'));
fprintf('Recorded data will be saved as %s.mat\n', file)

% fetch�ptimer�I�u�W�F�N�g�̍쐬
fetch_timer = timer('ExecutionMode', 'fixedRate', 'TimerFcn', 'data = signal_fetch(HANDLE, data, gain);', 'Period', period_fetch_secs);

% plot�ptimer�I�u�W�F�N�g�̍쐬
plot_obj.figure_handle = figure(1);
plot_obj.sampling_freq = sampling_freq;
[b, a] = butter(4,[2/(.5*sampling_freq) 40/(.5*sampling_freq)]);
plot_obj.filter.b = b;
plot_obj.filter.a = a;
plot_obj.filter.zf = [];
plot_obj.filter.n_cut_samples = sampling_freq*5;
plot_obj.duration_n = duration_plot_n;
plot_timer = timer('ExecutionMode', 'fixedRate', 'TimerFcn', 'plot_obj = plot_signal(data, plot_obj);', 'Period', period_plot_secs);

% classify�ptimer�I�u�W�F�N�g�̍쐬
classify_obj.duration_n = duration_classify_n;
classify_timer = timer('ExecutionMode', 'fixedRate', 'TimerFcn', '[class, classify_obj] = classify_signal(data, classify_obj);', 'Period', period_classify_secs);

% �v���J�n
data = zeros([0, n_channels]);
fprintf('[Acquision] Start...');
mel4mex('StartAcquision', HANDLE);

start(fetch_timer)
start(plot_timer)
start(classify_timer)

% �v�����DEscape key�Ōv���I��
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
