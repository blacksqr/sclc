% SLOC (NCLOC) = 19
% CLOC = 13
function MarkovModel(J,n,m)

% n is the number of time steps %
% M1 is the matrix for local community model %
% M2 is the matrix for the general model with immigration from a meta
% community

%M1 = matrixbuilder1(J);
M2 = matrixbuilder2(J,m);

% Set initial conditions %
N = zeros(1,J+1);
i = ceil((J+1)*rand(1));
N(i) = J+1;

for i =1:n
    N(i+1,:)=N(i,:)*M2;
end
%mov = avifile('MarkovMovie.avi');
for i=1:n+1
    plot([0:1:J],N(i,:),'b.-')
    set(gcf,'Color',[1 1 1]);
    axis([0 J 0 J])
    count = sum(N(i,:));
    str = sprintf('Total Population is %d',round(count));
    title(str)
    input(' ')
%    M(i) = getframe(gcf);
%    mov = addframe(mov,M(i));
    clf;
end
%movie(M,1,2);
%mov=close(mov);
close all
