s = daq.createSession('ni')
nidaq = daq.getDevices
addAnalogInputChannel(s, nidaq.ID, 'ai0', 'Voltage')
[ch,idx] = addAnalogOutputChannel(s,nidaq.ID,'ao0', 'Voltage')
% [data, time] = s.startForeground;