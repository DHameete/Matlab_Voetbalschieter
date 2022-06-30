TotalWidthOfSPADS	   = 16;
WidthOfSPADsPerZone	   = 4;
NumOfSPADsShiftPerZone = 2;
HorizontalFOVofSensor  = 19.09;
SingleSPADFOV		   = (HorizontalFOVofSensor/TotalWidthOfSPADS);
NumOfZonesPerSensor	   = (((TotalWidthOfSPADS - WidthOfSPADsPerZone) / NumOfSPADsShiftPerZone) + 1);
StartingZoneAngle	   =  (WidthOfSPADsPerZone / 2 * SingleSPADFOV);
ZoneFOVChangePerStep   = (SingleSPADFOV * NumOfSPADsShiftPerZone);

PartZoneAngle = zeros(1,NumOfZonesPerSensor);
for i = 1 : NumOfZonesPerSensor
    CurrentZone = i-1;
    PartZoneAngle(i) = (StartingZoneAngle + ZoneFOVChangePerStep*CurrentZone) - (HorizontalFOVofSensor / 2.0);
end
PartZoneAngle

RadarCircleRadius = 0;
Distance = 50;
CorrectedDistance = sqrt((RadarCircleRadius.^2) + (Distance.^2) - (2 * RadarCircleRadius .* Distance .* cos((180 - PartZoneAngle)./(180) * pi)));

