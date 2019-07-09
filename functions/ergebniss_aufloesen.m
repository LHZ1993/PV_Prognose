function [y, ymean] = ergebniss_aufloesen(x)

    ymean = mean(x);
    resample = [1,[16:16:272] , 287];
    temp = x(resample, :);
    x(resample, 2 ) = temp;
    x(find(x(:, 2) == 0),2) = NaN;
    x(:,2) = fillmissing(x(:,2), 'spline');
    y = x(:,2);
    
end

