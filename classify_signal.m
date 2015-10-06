function [class, obj] = classify_signal(data, obj)
    signal_length = size(data, 2);
    duration_n = obj.duration_n;
    class = NaN;
    if duration_n < signal_length
        classified_signal = data(:, (signal_length - duration_n + 1):end);
        % feature_extraction()
        % classifier()
        % fprintf('classify to class %s\n', class);
    end
end
