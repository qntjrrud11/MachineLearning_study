function [dU,dB] = Update_grad(dU,dB,layer,grad)
arguments
    dU (:,:,:,:) double
    dB (:,:) double
    layer (:,:,:,:) double
    grad (:,:,:,:) double
end

[~,~,u_ch,u_n] = size(dU);
[~,~,~,l_n] = size(layer);

for n = 1:u_n 
    for ch = 1:u_ch 
        for d = 1:l_n 
            dU(:,:,ch,n) = dU(:,:,ch,n) + conv2(layer(:,:,ch,d),rot90(grad(:,:,n,d),2),'valid');
%             dU(:,:,ch,n) = dU(:,:,ch,n) + filter2(grad(:,:,n,d),layer(:,:,ch,d),'valid');
        end
        dB(n) = sum(grad(:,:,n,:),'all');
    end
end


end