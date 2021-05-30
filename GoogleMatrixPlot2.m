% Filename: GoogleMatrixPlot2.m
% M-file to
% - Print out a plot to demonstrate page-rank algorithm over time.

% Enter the transfer matrix_type.
T =[0 1/2 0 1/7 0 0 1/7;
0 0 1/3 1/7 1/2 0 1/7 ;
1 0 0 1/7 0 1/3 1/7;
0 0 1/3 1/7 0 0 1/7;
0 1/2 0 1/7 0 1/3 1/7;
0 0 1/3 1/7 1/2 0 1/7;
0 0 0 1/7 0 1/3 1/7]
% Enter the initial state.
x0 = [1 ; 0 ; 0; 0; 0; 0; 0];

% We will create a matrix X that has three columns.
% Each column will contain time series data for one class.
% Each row will correspond to a time step.
X = zeros(11,7);  

X(1,:) = x0;  %Data for time step t=0

% Use for loop to generate time series data.
for t = 1:10
  X(t+1,:)=T^t*x0; % Data for time step t
end

% the first column.
One = X(:,1);

% Time series information for second page
Two = X(:,2);


Three = X(:,3);
Four = X(:,4);
Five = X(:,5);
Six= X(:,6);
Seven= X(:,7);

% Generate plot
time = [0:10];
plot(time,One,time,Two,time,Three,time,Four,time,Five,time,Six,time,Seven)
legend('One','Two','Three',"Four","Five","Six","Seven")
xlabel('Time step t')
ylabel('Probablity of being in state after t steps.')
title('Circularity')