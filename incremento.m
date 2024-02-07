function x = incremento(mat,N) % Incrementa ou decrementa
vet=zeros(1,N)';
    for i=2:N
        i;
        if mat(i,:)==mat(i-1,:)
            vet(i)=0;
        else
            if mat(i,:)==[0,0,0,1]
                vet(i)=1;
            end
            if mat(i,:)==[0,1,1,1]
                vet(i)=1;
            end
            if mat(i,:)==[1,0,0,0]
                vet(i)=1;
            end
            if mat(i,:)==[1,1,1,0]
                vet(i)=1;
            end
            if mat(i,:)==[0,0,1,0]
                vet(i)=-1;
            end
            if mat(i,:)==[0,1,0,0]
                vet(i)=-1;
            end
            if mat(i,:)==[1,0,1,1]
                vet(i)=-1;
            end
            if mat(i,:)==[1,1,0,1]
                vet(i)=-1;
            end
        end
        x=vet;
    end
end