function [xi,w]=rls(x,d,M,lambda,delta)
% Recursive Least Squares
% Call:
% [xi,w]=rls(lambda,M,u,d,delta);
%
% Input arguments:
% lambda = forgetting factor, dim 1x1
% M = filter length, dim 1x1
% u = input signal, dim Nx1
% d = desired signal, dim Nx1
% delta = initial value, P(0)=delta^-1*I, dim 1x1
%
% Output arguments:
% xi = a priori estimation error, dim Nx1
% w = final filter coefficients, dim Mx1
% inital values
w=zeros(M,1);
P=eye(M)/delta;
% make sure that u and d are column vectors
x=x(:);
d=d(:);
% input signal length
N=length(x);
% error vector
xi=d;
% Loop, RLS
for n=M:N
uvec=x(n:-1:n-M+1);
k=lambda^(-1)*P*uvec/(1+lambda^(-1)*uvec'*P*uvec);
e=d(n)-w'*uvec;
w=w+k*conj(e);
xi(n) = e'*e;
P=lambda^(-1)*P-lambda^(-1)*k*uvec'*P;
end