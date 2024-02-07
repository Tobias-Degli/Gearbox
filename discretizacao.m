function x = discretizacao(vetor,N)
vet=zeros(1,N)';
    for i=1:N
        if vetor(i) < 2
            vet(i)=0;
        end
        if vetor(i) > 2
            vet(i)=1;
        end
    end
    x=vet;
end