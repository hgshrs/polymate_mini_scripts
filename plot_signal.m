function obj = plot_signal(data, obj)
    signal_length = size(data, 2);
    sampling_freq = obj.sampling_freq;
    duration_n = obj.duration_n;
    figure_handle = obj.figure_handle;
    n_cut_samples = obj.filter.n_cut_samples;
    if duration_n + n_cut_samples < signal_length
        figure(figure_handle)
        time_idxs = (0:signal_length-1)/sampling_freq;
        [tmp, obj.filter.zf] = filter(obj.filter.b, obj.filter.a, data(:, (signal_length - (duration_n + n_cut_samples) + 1):end)', obj.filter.zf);
        plot(time_idxs((signal_length - duration_n + 1):end), tmp((n_cut_samples + 1):end, :))
        xlim([time_idxs(signal_length-duration_n+1), time_idxs(end)])
    else
        [tmp, obj.filter.zf] = filter(obj.filter.b, obj.filter.a, data', obj.filter.zf);
        plot((0:signal_length-1)/sampling_freq, tmp')
        xlim([0, duration_n/sampling_freq])
    end
    xlabel('time [sec]')
    ylabel('Amplitue [uV]')
end
