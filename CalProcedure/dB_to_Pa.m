function [Pa]=dB_to_Pa(dB, ref)
% % written by Edwdard Zechmann 
% % date 3 september 2009
% % 

if nargin <2 
    ref=0.00002;
end

Pa=ref.*10.^(dB./20);
