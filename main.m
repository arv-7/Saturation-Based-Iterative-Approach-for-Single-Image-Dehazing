clear all ;
close all;
clc;
disp("-----Welcome to dehazing program------")
disp(" ")
disp("Please enter the name of image")
str = input('Example: forest.png \n','s');
disp(" ")

input = imread(str);

figure;
subplot(1,4,1);
imshow(input);
title("Input Image")
[M,N,D] = size(input);

%Resize if image too large
%input = imresize(input,[270 270]);
%figure;
%mshow(input);
%title("Resized Input Image")

% Hue Saturation Value calculation
HSV = rgb2hsv(input);
S = HSV(:,:,2);
V = HSV(:,:,3);
subplot(1,4,2),imshow(HSV(:,:,1)),title("Hue");
subplot(1,4,3),imshow(S),title("Saturation");
subplot(1,4,4),imshow(V),title("Brightness");

%% Initialization

Savg = mean(mean(HSV(:,:,2)));

if Savg > 0.1
    alpha = 0.7;
else
    alpha = 0.5;
end

beta = 0.1;
t0 = 0.1;

if Savg < 0.1
    epsilon = 1.2;
else
    epsilon = 0.3;
end
disp("Parameters Initial values")
disp("Savg="+Savg+"  alpha="+alpha+"  Beta="+beta+"  epsilon="+epsilon)
disp(" ")
k = 0;
S_k = S;
V_k = V;
bound = 0;

%% Iterating
while bound <= epsilon
    
    k = k+1;
    disp("Parameters after Interartion(k) = "+k)
  

    for i=1:M
        for j=1:N
            S_k(i,j) = min(S_k(i,j)^alpha+beta,1);
        end
    end

    t_new = 1-((1-S_k).*V_k);

    figure;
    subplot(1,2,1),imshow(t_new),title("Transmission before filtering");

    t_new = imguidedfilter(t_new);
    subplot(1,2,2),imshow(t_new),title("Transmission after filtering");

    temp = t_new(:);
    temp_sorted = sort(temp);
    temp_value= temp_sorted(round(M*N*0.001));

    [p,q] = find(t_new == temp_value,1);

    A = im2double(input(p,q,:));
    input_double = im2double(input);

    J(:,:,1) = (((input_double(:,:,1)-A(1,1,1)))./max(t_new,t0))+ A(1,1,1);
    J(:,:,2) = (((input_double(:,:,2)-A(1,1,2)))./max(t_new,t0))+ A(1,1,2);
    J(:,:,3) = (((input_double(:,:,3)-A(1,1,3)))./max(t_new,t0))+ A(1,1,3);

    %figure;
    %subplot(1,2,1)
    %imshow(input),title("input");
    %subplot(1,2,2)
    %imshow(J),title("output");  
    S_kavg = mean(mean(S_k));
    bound = abs((S_kavg/Savg) - 1);
    alpha = max(alpha-0.1,0.5);
    disp("S_kavg="+S_kavg+"  alpha="+alpha+"  Beta="+beta+"  bound="+bound)
    
    HSV2 = rgb2hsv(J);
    S_k = HSV2(:,:,2);
    V_k = HSV2(:,:,3);
    
end

figure;
subplot(1,2,1)
imshow(input),title("input");
subplot(1,2,2)
imshow(J),title("output");  

