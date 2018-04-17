function [ selectedFeatues, time ] = Feature_Addition_2( X,Y )
% author=Ren Diao, Neil Mac Parthal?ain, and Qiang Shen. 
% title=Dynamic Feature Selection with Fuzzy-Rough Sets
% Dynamic Feature Addition based on fuzzy rough set

start=tic;
[n,p]=size(X);
mode=zeros(1,p);
dep_pre=0;

for i=1:p
    mode(1,i)=1;
    dep_current=Fuzzy_Dep(X(:,mode==1),Y);
    
    if dep_current==1
        break;
    end

    if dep_current>dep_pre
        dep_pre=dep_current;
        continue;
    else
        mode(1,i)=0;
    end

end

selectedFeatues=find(mode==1);
time=toc(start);
end

function [ dependency ] = Fuzzy_Dep( S,Y )
% calculate the dependency of subset
% 
[n,p]=size(S);
uni_Y=unique(Y);
num_Y=length(uni_Y);

S_Array=zeros(n,n);
if p==1
    S_Array=sim_fun(S); 
else
    S_Array=sim_fun(S(:,1)); 
   for i=2:p
     S_Array2=sim_fun(S(:,i));
     S_Array=min(S_Array,S_Array2);
   end
end

pos_Array=zeros(num_Y,n);
I=ones(n,n);
for j=1:num_Y
    class=uni_Y(j);
    s_Y=zeros(n,1);
    s_Y(Y==class,1)=1;
    S=I-S_Array+repmat( s_Y , 1 , n );
    pos_Array(j,:)=min(S);
end 
pos=max(pos_Array);   
dependency=sum(pos)/n;

end


function [S_Array] = sim_fun_1(F)
% fuzzy similarity relations 
% std(a)=sqrt(var(a));
% u(x,y)=max{min{[a(y)-a(x)+std(a)]/std(a),[a(x)+std(a)-a(y)]/std(a)},0}

std=sqrt(var(F));
[n,~]=size(F);

S_Array=zeros(n,n);
for i=1:n
    for j=i:n
        if(i==j)
            S_Array(i,j)=1;
        else
            min_1=(F(j)-F(i)+std)/std;
            min_2=(F(i)+std-F(j))/std;
            min=min_1;
            if min_2<min_1
                min=min_2;
            end
            if min<0
                min=0;
            end
            S_Array(i,j)=min;
            S_Array(j,i)=min;
        end
       
    end
end
end

function [S_Array] = sim_fun(F)
% fuzzy similarity relations 
% 
% u(x,y)=1- |a(x)-a(y)|/[a(max)-a(min)]

a_max=max(F);
a_min=min(F);
interval=a_max-a_min;
[n,~]=size(F);

S_Array=zeros(n,n);
for i=1:n
    for j=i:n
        if(i==j)
            S_Array(i,j)=1;
        else
            val=abs(F(j)-F(i))/interval;
            S_Array(i,j)=val;
            S_Array(j,i)=val;
        end       
    end
end

end

function [S_Array] = sim_fun_3(F)
% fuzzy similarity relations 
% 
% u(x,y)=exp[-[a(x)-a(y)]^2/2var(a)

val_var=var(F);
[n,~]=size(F);

S_Array=zeros(n,n);
for i=1:n
    for j=i:n
        if(i==j)
            S_Array(i,j)=1;
        else
            val=exp(-(F(i)-F(j))*(F(i)-F(j))/2*val_var);
            S_Array(i,j)=val;
            S_Array(j,i)=val;
        end       
    end
end

end