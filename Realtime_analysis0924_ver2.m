
% ���A���^�C���g�`�\���C�t�[���G�ϊ��\��
%�@alldata�Ɍv���f�[�^��ۑ�
% ���ݎ������t�@�C�����̃t�@�C���Ƀf�[�^��ۑ�
% �����I�������ꍇ��mel4mex('Term')�����s����polymate mini�Ƃ̐ڑ���ؒf���Ă��������B

clear
MEL_CTRL;%�R���g���[���p�ϐ��̓ǂݍ���

%�@�����ݒ�
MEL_SAMPLE_COMPORT	= 'COM7';% polymate mini�̃|�[�g�ԍ�
MEL_SAMPLE_UNITSIZE	= 1;
MEL_SAMPLE_UNIT_N	= 5000;
MEL_SAMPLE_FREQ		= 500;
MEL_SAMPLE_LIST_CH = [MELCTRL_DEVTYPE_EEG+1 MELCTRL_DEVTYPE_EEG+2 MELCTRL_DEVTYPE_EEG+3];

gain = 1000; %gain
rec_time = 5; %�v������ (s)

% polymate mini�̏�����
fprintf('[Init]');
IS_INIT = mel4mex('Init');
if IS_INIT == 0
    fprintf(' NG\n');
    return;
else
    fprintf(' OK\n');
end

% polymate mini�Ƃ̐ڑ�
fprintf('[Open]');
HANDLE = mel4mex('Open', MEL_SAMPLE_COMPORT, MEL_SAMPLE_UNITSIZE, MEL_SAMPLE_UNIT_N, MEL_SAMPLE_FREQ);
if( HANDLE <= 0 )
    fprintf(' NG\n');
    fprintf('[Term]\n');
    mel4mex('Term');
    return;
end
fprintf(' HANDLE: %d\n', HANDLE);


% Arduino
% serial_arduino = serial('COM5','BaudRate',9600);

% �v���`���l���̐ݒ�
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

% �]�g�`���l���̃Q�C���̐ݒ�
for m = 1:length(MEL_SAMPLE_LIST_CH)
    result = mel4mex('SetChInfo', HANDLE, m, MELCTRL_CH_GAIN,gain);
end

%�C���s�[�_���X�`�F�b�N
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

pause on;
pause(3)

% �t�B���^�̐ݒ�
% [B1,A1] = butter(4,[1/(MEL_SAMPLE_FREQ/2) 30/(MEL_SAMPLE_FREQ/2)]);
[B1,A1] = butter(4,[2/(MEL_SAMPLE_FREQ/2) 22/(MEL_SAMPLE_FREQ/2)]);

[B2,A2] = butter(4,[5/(MEL_SAMPLE_FREQ/2) 12/(MEL_SAMPLE_FREQ/2)]);

figure;

% Arduino open
% fopen(serial_arduino);

% �v���J�n
fprintf('[Acquision] Start...');
mel4mex('StartAcquision', HANDLE);
pause(3);
UNIT_N = mel4mex('CheckAcqUnitN', HANDLE);
los = mel4mex('ReadAcqDataN', HANDLE, UNIT_N);
pause(2);

DIR_F = imread('res/F.png');
DIR_L = imread('res/L.png');
DIR_R = imread('res/R.png');

for i = 1:50
    % �ϐ��̏�����
    Zf1 = [];
    Zf2 = [];

    alldata = [];
    cir = 1;
    m = 1;
    data1 = [];
    data2 = [];
    tsstart = tic;

    t = tic;


    while(1 > toc(t))

    end
    t=0;
    %     fwrite(serial_arduino, 1000, 'int32');
    try
        % ���A���^�C����͕\��
        while cir

            pause(0.1);

            UNIT_N = mel4mex('CheckAcqUnitN', HANDLE); %�v���f�[�^���̊m�F

            %�o�ߎ��Ԃ̃`�F�b�N
            telapsed = toc(tsstart);
            if telapsed > rec_time
                cir = 0;
            end

            if UNIT_N > 0
                tempdata = mel4mex('ReadAcqDataN', HANDLE, UNIT_N)/gain*(10/2^16)*10^6;% uV�ɕϊ�
                alldata = [alldata tempdata];
                [tempdata1,Zf1] = filter(B1, A1, tempdata',Zf1);
                [tempdata2,Zf2] = filter(B2, A2, tempdata',Zf2);
                data1 = [data1;tempdata1];
                data2 = [data2;tempdata2];
                data3 = data1(end-(MEL_SAMPLE_FREQ-1):end,:);
                data4 = data2(end-(MEL_SAMPLE_FREQ-1):end,:);
                subplot(2,1,1)
                plot([1:MEL_SAMPLE_FREQ]/MEL_SAMPLE_FREQ,data3);
                axis([1/MEL_SAMPLE_FREQ MEL_SAMPLE_FREQ/MEL_SAMPLE_FREQ -300 300])
                title(['EEG (' num2str(telapsed) 's)'])
                xlabel('time (s)')
                ylabel('uV')

                subplot(2,3,4)
                Y = fft(data3);
                Pyy(:,:,m)= sqrt(Y.*conj(Y));
                a =length(data3);
                f=MEL_SAMPLE_FREQ*[1:60-1]/a;
                plot(f,Pyy(2:60,:,m));
                title('Fourier transform')
                xlabel('Hz')
                ylabel('uV')
                subplot(2,3,5)
                plot(f,mean(Pyy(2:60,:,:),3))
                title('Averaged Fourier transform')
                xlabel('Hz')
                ylabel('uV')
                legend('toggle')
                %CCA
                %         f1=[7.56 8.68 10.13];
                f1=[7.5 8.57 10];
                Fs = MEL_SAMPLE_FREQ;
                sample_size = size(data3,1);
                %% CCA
                for ff = 1:length(f1);
                    Y=[ sin(2*pi*f1(ff)*[1:sample_size]./Fs);
                        cos(2*pi*f1(ff)*[1:sample_size]./Fs);
                        sin(4*pi*f1(ff)*[1:sample_size]./Fs);
                        cos(4*pi*f1(ff)*[1:sample_size]./Fs);
                        sin(6*pi*f1(ff)*[1:sample_size]./Fs);
                        cos(6*pi*f1(ff)*[1:sample_size]./Fs)];
                    [Wx, Wy, r] = canoncorr(Y',data3(:,:));
                    pp(ff)=max(r);
                end
                subplot(2,3,6)
                bar(fliplr(f1),fliplr(pp));
                xlim([6.5,11]);
                title('CCA')
                xlabel('Hz')
                ylabel('correlation coefficient')
            end

            m = m+1;

        end
        % 5�b����
        %compare_power
        compare_cca

    catch
        %         fclose(serial_arduino);
        mel4mex('StopAcquision', HANDLE);

        fprintf('[Close]\n');
        mel4mex('Close', HANDLE);

        fprintf('[Term]\n');
        mel4mex('Term');
        fprintf('ERROR\n')
        break;
    end

    pause(2);

end

% fclose(serial_arduino);

mel4mex('StopAcquision', HANDLE);

fprintf('[Close]\n');
mel4mex('Close', HANDLE);

fprintf('[Term]\n');
mel4mex('Term');
% save([datestr(now,30) '.mat'])

beep

