% create_empty_data_struct.m  (CACC)
%
% Written by Christopher Nowakowski
% v.1 11/03/08
% v.2 11/20/08  - Reordered data sources and parameters
% v.3 12/01/08  - Added data.acc.lead_veh_speed metric for post-processing
%               - Added data.acc.time_gap metric for post-processing
%               - Added data.acc.tc metric for post-processing
% v.4 01/15/09  - Added data.meta fields
%               - Added data.ts.utc_ssm (changed data.gps.date to .utc_date)
%               - Added data.comm.lead_veh_speed
% v.5 02/10/10  - Added data.veh.accl
%               - Added data.acc.lead_veh_accl
%               - Added data.comm.accl
%               - Added data.acc.areq
%
% This function creates an empty data structure of the type used in the CACC project.
%

function [data] = create_empty_data_struct()

% ------------------------------------------------------------------------------
% Meta Data - Filled in by load_trip.m
% ------------------------------------------------------------------------------
data.meta.study = [];           %           These fields will be filled in by load_trip.m; however,
data.meta.driver = [];          %           they will be left blank if you load data just using
data.meta.vehicle = [];         %           the load_dat_files.m function.
data.meta.date = [];            %
data.meta.tripid = [];          %           
data.meta.dataset = [];         %           Designated "Full Trip" or "Partial Trip"
data.meta.seq_start = [];       %           First Sequence Directory Loaded
data.meta.seq_end = [];         %           Last Sequence Directory Loaded
data.meta.gmt_offset = [];      %           Conversion from GMT to Pacific Time Zone
data.meta.clockskew = [];       %           Clockskew used to calculate data.ts.utc_ssm
data.meta.pathname = [];        %           Full text pathname from where the data was loaded


% ------------------------------------------------------------------------------
% Time Stamp
% ------------------------------------------------------------------------------
data.ts.text = [];              % D  1      System Time Stamp hh:mm:ss.sss
data.ts.ssm = [];               % D  2      System Time Stamp in Seconds Since Midnight (ssm) - computed in load_dat_files.m
data.ts.utc_ssm = [];           %           data.ts.ssm corrected for mean data.gps.utc_time difference - only computed in load_trip.m
data.ts.eng_sent = [];          % D  5      Time Message was sent by control computer (ssm)
data.ts.eng_recv = [];          % D  6      Time Message was recieved by engineering computer (ssm)
data.ts.comm_sent = [];         % D  3      Time Message was sent from Silver (ssm)
data.ts.comm_recv = [];         % D  4      Time Message was received by Copper (ssm)


% ------------------------------------------------------------------------------
% Vehicle Data
% ------------------------------------------------------------------------------
data.veh.accl = [];             %           Acceleration Derived From Speed (g) (Computed in load_trip.m)
                                %               + if vehicle is accelerating
                                %               - if vehicle is decelerating
data.veh.accl_x = [];           % D  8      Accelerometer Longitudinal Reading (g)
                                %               - if vehicle is accelerating (Recoded to + in load_dat_files.m)
                                %               + if vehicle is decelerating (Recoded to - in load_dat_files.m)
                                %               Offset calibration occurs in load_trip.m
data.veh.accl_y = [];           % D  9      Accelerometer Lateral Reading (g)
                                %               + is a left turn
                                %               - is a right turn
                                %               Offset calibration occurs in load_trip.m
data.veh.brake = [];            % D 20      Brake Activation Flag
data.veh.brake_pressure = [];   % D 22      Vehicle Brake Pressure (bar)
data.veh.gear = [];             % A  7      Current Gear (0-8)
data.veh.shift = [];            % A  6      Gear Shift in Progress Flag
data.veh.speed = [];            % D 23      Vehicle Speed (km/h)
data.veh.throttle = [];         % D 18      Driver Accelerator Pedal Position (%)
data.veh.throttle_virtual=[];   % D 19      Virtual Accelerator Pedal Position (%)
data.veh.yaw_rate = [];         % D  7      Gyro (deg/s)  
data.veh.rpm = [];              % A  4      Engine RPMs (rpm)
data.veh.outputshaft_rpm = [];  % A 11      Output Shaft RPM
data.veh.turbine_rpm = [];      % A 12      Turbine RPM
data.veh.torque = [];           % A  5      Mean Effective Torque (Nm)
data.veh.torque_target = [];    % A 13      Target Engine Torque (Nm)
data.veh.wheel_rpm = [];        % A  8      Front Wheel Speed (rpm)


% ------------------------------------------------------------------------------
% GPS Data
% ------------------------------------------------------------------------------
data.gps.utc_time = [];         % D 24      GPS UTC Time (GMT?) hhmmss.ss
data.gps.utc_date = [];         % D 30      GPS Date (ddmmyy)
data.gps.long = [];             % D 25      GPS Longitude (dddmm.mmmmmm) -> (ddd.ddddddd) in load_dat_files.m
data.gps.lat = [];              % D 26      GPS Latitude  (dddmm.mmmmmm) -> (ddd.ddddddd) in load_dat_files.m
data.gps.alt = [];              % D 27      GPS Altitude (m)
data.gps.speed = [];            % D 28      GSP Speed Over Ground (Originally km/h but Converted to m/s)
data.gps.sat = [];              % D 29      GPS Number of Satellites


% ------------------------------------------------------------------------------
% ACC Related Parameters
% ------------------------------------------------------------------------------
% data.acc.main_sw = [];        % D 21      Identical to acc.enabled
data.acc.enabled = [];          % D 13      Main ACC Switch Toggle Flag (Enabled is not active) 
data.acc.active = [];           % D 10      ACC Active Flag
data.acc.mode = [];             %           Computed on the fly in post processing
                                %               0 = Undefined: system not active
                                %               1 = Speed Regulation
                                %               2 = Gap Regulation
data.acc.set_speed = [];        % D 17      ACC Set Speed (Originally km/h but Converted to m/s)
data.acc.car_space = [];        % D 11      Target Gap Setting (Remapped to 1-6 / Shortest to Longest)
data.acc.gap_setting = [];      %           Computed in load_dat_files.m
data.acc.target_lock = [];      % A 14      ACC Lead Vehicle Lidar Target Lock Flag
data.acc.lidar_target_id = [];  % D 31      Lidar Target Counter - Increments from 0 to 7 as new target appears
data.acc.dist = [];             % D 32      Lidar Reading of Lead Vehicle Distance (m)
data.acc.time_gap = [];         %           Computed in load_dat_files.m
data.acc.rel_speed = [];        % D 33      Lead Vehicle Relative Speed (m/s) based on Lidar
                                %               + if gap is closing (Recoded to - in load_dat_files.m)
                                %               - if gap is opening (Recoded to + in load_dat_files.m)
data.acc.lead_veh_speed = [];   %           Lead Vehicle Speed: Computed in load_dat_files.m from data.acc.rel_speed
data.acc.lead_veh_accl = [];    %           Lead Vehicle Acceleration: Computed in load_trip.m from data.acc.lead_veh_speed
                                %               + if lead vehicle is accelerating
                                %               - if lead vehicle is decelerating
data.acc.ttc = [];              %           Time to Collision: Computed load_dat_files.m
data.acc.areq = [];             %           Required Deceleration (g): Computed in load_trip.m
                                %               + if deceleration is required
                                %               0 if deceleration is not required
data.acc.appr_warn = [];        % D 12      Target Approach Warning - Recoded to a Flag in load_dat_files.m
data.acc.low_speed_warn = [];   %           Flag Computed in load_dat_files.m from data.acc.buzzer
                                %               Note: Warning usually occurs after system disengage
data.acc.buzzer = [];           % D 14      Comes on when System Disengaged Due to Low Speed - Recoded in load_dat_files.m
data.acc.buzzer2 = [];          % D 15      Comes on with Target Approach Warning - Recoded in load_dat_files.m
data.acc.buzzer3 = [];          % D 16      Unknown Use - Recoded in load_dat_files.m
data.acc.virtual_dist = [];     % A 15      ACC Virtual Distance (m) - LV Distance as Modified by PATH
data.acc.virtual_speed = [];    % A 16      ACC Virtual Relative Speed (m/s) - Relative Speed As Modified by PATH
                                %               + if gap is closing (Recoded to - in load_dat_files.m)
                                %               - if gap is opening (Recoded to + in load_dat_files.m)


% ------------------------------------------------------------------------------
% Parameters Communicated From Silver to Copper
% ------------------------------------------------------------------------------                     
data.comm.msg_count = [];       % C  7      Wireless Message Change Counter 0-255
data.comm.brake = [];           % C 16      Lead Vehicle Brake Activation Flag
data.comm.brake_pressure = [];  % C 20      Lead Vehicle Brake Pressure (bar)
data.comm.gear = [];            % C 14      Lead Vehicle Current Gear (0-8)
data.comm.shift = [];           % C 13      Lead Vehicle Gear Shift in Progress Flag
data.comm.speed = [];           % C 24      Lead Vehicle Speed (Originally km/h recoded to m/s in load_dat_files.m)
data.comm.accl = [];            %           Acceleration Derived From Speed (g) (Computed in load_trip.m)
                                %               + if vehicle is accelerating
                                %               - if vehicle is decelerating
data.comm.throttle = [];        % C  9      Lead Vehicle Driver Accelerator Pedal Position (%)
data.comm.throttle_virtual = [];% C 10      Lead Vehicle Virtual Accelerator Pedal Position (%)
data.comm.yaw_rate = [];        % C 23      Lead Vehicle Yaw Rate (deg/s)
data.comm.rpm = [];             % C 11      Lead Vehicle Engine RPM (rpm)
data.comm.torque = [];          % C 12      Lead Vehicle Mean Effective Torque (NM)
data.comm.wheel_rpm = [];       % C 15      Lead Vehicle Frong Wheel Speed (rpm)
data.comm.set_speed = [];       % C 19      Lead Vehicle ACC Set Speed (km/h)
data.comm.car_space = [];       % C 18      Lead Vehicle Target Gap Setting (Remapped to 1-6 / Shortest to Longest)
data.comm.target_lock = [];     % C 17      Lead Vehicle has a Target Lock on a Lead Vehicle
data.comm.dist = [];            % C 21      Lead Vehicle's Lead Vehicle Lidar Range (m)
data.comm.rel_speed = [];       % C 22      Lead Vehicle's Lead Vehicle Relative Speed (m/s) based on Lidar
                                %               + if gap is closing (Recoded to - in load_dat_files.m)
                                %               - if gap is opening (Recoded to + in load_dat_files.m)
data.comm.lead_veh_speed = [];  %           Lead Vehicle's Lead Vehicle Speed: Computed load_dat_files.m

end