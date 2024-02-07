function x = interpolacao(t,vet,n)
    j=0 ;
    i=0 ;
    %Encontra a primeira mudança de onde iniciará a interpolação
    while i==0
         j=j+1;
         i=vet(j);
    end
    i;
    status=j;
    vet_novo=vet;
    for i=2:n
        i;
        if vet(i)~=vet(i-1) && i ~= status % procura o próximo degral diferente do primeiro 
           alpha=(vet(i)-vet(status))/(t(i)-t(status));
           for k=status:i
                vet_novo(k)=vet(status)+alpha*(t(k)-t(status));
           end
           status=i;
        end
    end
    % suavisação do primeiro degral
    %vet_novo(j-1)=vet_novo(j)/2;
    x=vet_novo;
end