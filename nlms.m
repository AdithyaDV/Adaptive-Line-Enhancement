function [W, CF] = nlms(undelayed,delayed,order,delta,epoch)
N = length(delayed);
X = zeros(1,order+1);   % Input frame length (+1 for delaying)
W = 0*X;        % Initial weights of NLMS
reg = 1/order*(sum(undelayed(1:order).^2));
for k = 1 : epoch
    for n = 1 : N-order
        X(1,2:end) = X(1,1:end-1);  
        X(1,1) = delayed(n); %Storing of Delayed Input                  
        y = (W)*X';         
        e = undelayed(n) - y; %Comparing with desired signal
        W = W +  (delta/reg)* e * X;                    
        J(k,n) =  e'*e;      
    end
end
CF = mean(J,2); %Cost function