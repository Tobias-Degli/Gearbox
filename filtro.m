function x = filtro(vetor,N)
  %cols=size(vetor);cols=cols(1,2)
  for i=2:N-2
       if (vetor(i-1)==0) && (vetor(i)~=0)
           vetor(i)=vetor(i+1)/2;
           j=i
       end
  end
  % Remove a parte da aquisição em que o motor estava desligado
  x=vetor(j-1:N-2);
end