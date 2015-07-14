function [tf, dur] = wait_for_breaker(parport, mode, maxt, n)

if ~isa(parport,'digitalio') || length(parport.line) <=0 || nargin == 0
   error('Parallel port is not configured for collecting a response'); 
end

if nargin == 1
    mode = 2;
    maxt = Inf;
    n = 0;
end

if nargin == 2
    maxt = Inf;
    n = 0;
end

if nargin == 3
    n = 0;
end

t = GetSecs;

% Mode 1: Wait for release
done = false;
while ~done
    tf = get_breaker(parport,n);
    if ~any(tf) || GetSecs-t > maxt
        done = true;
    end
end

% Mode 2: Wait for release then press
if mode > 1
    done = false;
    while ~done
        tf = get_breaker(parport,n);
        if any(tf) || GetSecs-t > maxt
            done = true;
        end
    end
end

% Mode 3: Wait for release then press then release
if mode > 2
    done = false;
    while ~done
        tf = get_breaker(parport,n);
        if ~any(tf) || GetSecs-t > maxt
            done = true;
        end
    end
end

dur = GetSecs - t;