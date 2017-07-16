% gregorian_to_date.m------------------------
% Convert the Gregorian day count used in DART to calendar date. 
%
% INPUT:
% greg_days: the day count delivered by DART
% greg_seconds: the second count delivered by DART
% OUTPUT:
% year, month, date, time.
function [year, month, day, hour, minute, second] = gregorian_to_date(greg_days,greg_seconds)

jd0 = date2jd(1601,01,01,0,0,0);
frac_days = greg_seconds/(24*60*60);

jd_new = jd0+greg_days+frac_days;   

[year, month, day, hour, minute, second] = jd2date(jd_new);
