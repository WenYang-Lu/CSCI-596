function y = mycheby_eval(lam,c,arange,graphType)
%   Usage:  y = mycheby_eval(x,c,arange)
%
%   Input parameters:
%       x       : Points to evaluate the polynomial
%       c       : Chebyshef coefficients
%       arrange : arange (range to evaluate the polynomial)
%       graphType:  L or A
%   Output parameters
%       y       : Result
switch graphType 
    case 'L'
        cos_theta=cos(pi*lam/arange(2));
    case 'A'
        cos_theta=cos(-pi*lam/(arange(2)-arange(1))+pi/2);
    case 'chebyA'
        cos_theta=( -2*lam-arange(2)-arange(1) ) / ( arange(2)-arange(1) );
end
Twf_old=1;               % j = 0;
Twf_cur=cos_theta;  % j = 1;
y =  c(1) * Twf_old + 2 * c(2) * Twf_cur;
for k=3:numel(c)
    Twf_new = 2*cos_theta.*Twf_cur-Twf_old;
    y = y + 2*c(k)*Twf_new;
    Twf_old=Twf_cur;
    Twf_cur=Twf_new;
end

end