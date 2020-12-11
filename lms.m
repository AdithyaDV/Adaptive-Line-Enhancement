function [W, CF] = lms(undelayed,delayed,order,delta,epoch)
N = length(delayed);
X = zeros(1,order+1);   % Input frame length (+1 for delaying)
W = 0*X;        % Initial weights of LMS
for k = 1 : epoch
    for n = 1 : N-order
        X(1,2:end) = X(1,1:end-1);  
        X(1,1) = delayed(n); %Storing of Delayed Input                  
        y = (W)*X';         
        err = undelayed(n) - y; %Comparing with desired signal
        W = W+delta*err*X;                    
        J(k,n) =  err'*err;      
    end
end
CF = mean(J,2); %Cost function       
