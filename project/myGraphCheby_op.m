function y=myGraphCheby_op(Mtx, c, signal, arange)
%   Usage: y = mycheby_op(A, c, signal, arange, type)
%
%   Input parameters:
%       Mtx     : Graph matrix
%       c       : Chebyshef coefficients
%       signal  : Signal to filter
%       arange  : eigenvalue range
%       type    : type of linear phase filter

%   Output parameters
%       y       : Result of the filtering
% 
N=size(Mtx,1); 
% Mtx=-2*Mtx/(arange(2)-arange(1))-(arange(2)+arange(1))/(arange(2)-arange(1))*eye(N);
a1 = -(arange(2) - arange(1))/2;
a2 = -(arange(2) + arange(1))/2;

Twf_old=signal;               % j = 0;
% Twf_cur=Mtx*signal;  % j = 1;
Twf_cur=(Mtx*signal-a2*signal)/a1; % j = 1;
y =  c(1) * Twf_old + 2 * c(2) * Twf_cur;
for k=3:numel(c)
%     Twf_new = 2*Mtx*Twf_cur-Twf_old;
    Twf_new = (2/a1) * (Mtx*Twf_cur-a2*Twf_cur) - Twf_old;   
    y = y + 2*c(k)*Twf_new;
    Twf_old=Twf_cur;
    Twf_cur=Twf_new;
end









end