clear;
% Estimate Directions of Arrival of Two Signals
% Estimate the DOAs of two signals received by a 50-element URA with a rectangular lattice. The antenna operating frequency is 150 MHz. The actual direction of the first signal is -37? in azimuth and 0? in elevation. The direction of the second signal is 17? in azimuth and 20? in elevation.
antenna = phased.IsotropicAntennaElement('FrequencyRange',[100e6 300e6]);
% array = phased.URA('Element',antenna,'Size',[5 10],'ElementSpacing',[1 0.6]);
fc = 77e9;
c = 3e8;
lambda = c/fc;
dt = lambda/2;
% antenna_pos = [0 dt 2*dt 3*dt 4*dt 5*dt 0  dt 2*dt 3*dt 4*dt 5*dt;...
%                0 0  0    0    0    0    dt dt dt   dt   dt   dt;...
%                0 0  0    0    0    0    0  0  0    0    0    0];
% antenna_pos = [0 0  0  0    0    0    0    0    0    0    0    0;...
%                0 dt dt 2*dt 2*dt 3*dt 3*dt 4*dt 4*dt 5*dt 5*dt 6*dt;...
%                0 0  dt 0    dt   0    dt   0    dt   0    dt   dt;...
%                   ];
antenna_pos = [0 0  0    0    0    0    0    0    0    0    0    0;...
               0 dt 2*dt 3*dt 4*dt 5*dt 3*dt 4*dt 5*dt 6*dt 7*dt 8*dt;...
               0 0  0   0    0    0    dt   dt   dt   dt   dt   dt;...
                  ];
% antenna_pos = [0 0  0    0    0    0    0    0    0    0    0    0;...
%                0 dt 2*dt 3*dt 4*dt 5*dt 0   dt 2*dt 3*dt 4*dt 5*dt;...
%                0 0  0   0    0    0    dt   dt   dt   dt   dt   dt;...
%                   ];
% antenna_pos = [0 0  0    0    0    0    0    0    0    0    0    0;...
%                0 dt 2*dt 3*dt 4*dt 5*dt dt  2*dt 3*dt 4*dt 5*dt 6*dt;...
%                0 0  0   0    0    0    dt   dt   dt   dt   dt   dt;...
%                   ];
array1 = phased.ConformalArray('Element',antenna,'ElementPosition',antenna_pos);
array2 = phased.URA('Element',antenna,'Size',[2 6],'ElementSpacing',[dt dt]);
figure(1);viewArray(array1);
figure(2);viewArray(array2);
% fc = 150e6;
% lambda = physconst('LightSpeed')/fc;
ang1 = [-20; 0];
x = sensorsig(getElementPosition(array1)/lambda,1,[ang1]);
estimator = phased.BeamscanEstimator2D('SensorArray',array1,'OperatingFrequency',fc, ...
    'DOAOutputPort',true,'NumSignals',1,'AzimuthScanAngles',-90:90,'ElevationScanAngles',-90:90);
[Pdoav,doas] = estimator(x);
disp(doas)
% Because the values for the AzimuthScanAngles and ElevationScanAngles properties have a granularity of , the DOA estimates are not accurate. Improve the accuracy by choosing a finer grid
% estimator2 = phased.BeamscanEstimator2D('SensorArray',array1,'OperatingFrequency',fc, ...
%     'DOAOutputPort',true,'NumSignals',2,'AzimuthScanAngles',-50:0.05:50,'ElevationScanAngles',-30:0.05:30);
% [~,doas] = estimator2(x);
% disp(doas)

% Plot the beamscan spatial spectrum
figure(3);
mesh(abs(Pdoav));
% Copyright 2012 The MathWorks, Inc.

Angle_Data = zeros(2,6);
Angle_Data(1,:) = x(1,1:6)';
Angle_Data(2,:) = x(1,7:12)';

Angle_FFT = fftshift(fft2(Angle_Data,181,181));
max_val = max(max(abs(Angle_FFT)));
[max_row,max_col] = ind2sub(size(Angle_FFT),find(abs(Angle_FFT) == max_val,1));
max_row = max_row - 91;
max_col = max_col - 91;

ang1_cos = lambda/dt*max_col/181;
ang2_cos = lambda/dt/sqrt(10)*max_row/181;
temp_z = sqrt(10)*ang2_cos - 3 * ang1_cos;

phi_cos = sqrt(1 -(temp_z)^2);
phi = acos(phi_cos)/pi*180;

Theta_cos = ang1_cos/phi_cos;
Theta = acos(Theta_cos)/pi*180;


figure(4);
mesh((abs(Angle_FFT)));
