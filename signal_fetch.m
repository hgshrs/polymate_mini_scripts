function data = signal_fetch(HANDLE, data, gain)
    UNIT_N = mel4mex('CheckAcqUnitN', HANDLE); %計測データ数の確認
    % UNIT_N
    tmpdata = mel4mex('ReadAcqDataN', HANDLE, UNIT_N)/gain*(10/2^16)*10^6;% uVに変換
    data = [data tmpdata];
end
