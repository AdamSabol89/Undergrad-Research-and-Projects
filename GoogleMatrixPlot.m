% Filename: EcoSuccessionPlot.m
% M-file to
% - Print out a plot showing landscape structure over time.

% Enter the transfer matrix_type.
T =[.021429 .446429 .021429 .142857 .021429 .021429 .142857;
.021429 .021429 .304762 .142857 .446429 .021429 .142857;
.871429 .021429 .021429 .142857 .021429 .304762 .142857;
.021429 .021429 .304762 .142857 .021429 .021429 .142857;
.021429 .446429 .021429 .142857 .021429 .304762 .142857;
.021429 .021429 .304762 .142857 .446429 .021429 .142857;
.021429 .021429 .021429 .142857 .021429 .304762 .142857];

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

% Time series information for proportion underwater is in
% the first column.
One = X(:,1);

% Time series information for proportion saturated but
% not underwater is in the second column.
Two = X(:,2);

% Time series information for proportion dry is in
% the third column.
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
title('No Absorbing Boundaries, no Circularity.')